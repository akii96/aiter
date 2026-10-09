# SPDX-License-Identifier: MIT
# Copyright (C) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""FlyDSL A4W4 compact MoE: MXFP4 prefill MoE for gfx950, dispatched as a whole-graph impl.

Tuned rows select it with ``kernelName1 = impl__flydsl_a4w4_compact__<cfg>``; ``<cfg>`` is a
FlyDSL A4W4 compact MoE tile config serialized by :func:`config_to_string`. The backend reads the
same preshuffled weights as the other per_1x32 fp4 paths (``shuffle_weight``
with layout (16, 16) and ``e8m0_shuffle`` scales, gate/up SEPARATED). The
kernels read the fp4 weight bytes in place; only the e8m0 scales (~6% of the
weight bytes) are repacked, once per weight tensor, and cached as long as the
source weights live.

Rows are compact (no block_m padding), the activation quant and the expert sort
run on device, and any ``inter_dim`` that is a multiple of 128 runs natively
(TP8 MiniMax-M3 at 384, no padding to 512). Tables cover prefill only
(``token >= MIN_TOKENS``); decode stays on the existing kernels.
"""

import os
import weakref
from functools import lru_cache

import torch

from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe_registry import FusedMoeRequest
from aiter.jit.utils.chip_info import get_gfx

from .moe_a4w4_compact import configs as _configs
from .moe_a4w4_compact import layout as _layout
from .moe_a4w4_compact import moe as _moe

_STAGE_KEYS = ("BM", "D", "NW", "WM", "pipe", "diag", "PERS", "EF", "MV")
_GLOBAL_KEYS = ("HT", "FC", "QP", "BMF", "NWF", "WMF", "DF", "pipeF", "diagF")
MIN_TOKENS = 512
_SWIGLU_LIMIT = 7.0
_FC_KEYS = ("FC", "BMF", "NWF", "WMF", "DF", "pipeF", "diagF")
# Fused combine computes expert E-1 last and folds the combine into its
# epilogue. It is exact only when E-1 is a shared expert routed exactly once per
# token, i.e. fused shared experts. Opt in when the caller guarantees that
# routing; otherwise those tables run the unfused combine.
_FUSED_SHARED_EXPERT = (
    os.environ.get("AITER_MOE_A4W4_COMPACT_FUSED_SHARED_EXPERT", "0") == "1"
)
# e8m0 rule for the activation and intermediate quant. "ceil" matches AITER's
# runtime MX quant (MxScaleRoundMode.RoundUp); "even" matches checkpoints
# calibrated with scale_calculation_mode="even" (Quark).
_SCALE_RULE = os.environ.get("AITER_MOE_A4W4_COMPACT_SCALE_RULE", "ceil")


# Kernel option tokens (``diag`` values in the tile tables, read by gemm.py) and
# their names in serialized configs. A trailing ``N`` is the token's integer.
_OPTION_NAMES = {
    "s1tr": "s1_transposed_epilogue",
    "epgN": "epilogue_batch_N",
    "barN": "barrier_slot_N",
    "s2nt": "s2_nontemporal_store",
    "s2tl": "s2_transposed_store",
    "s2db": "s2_double_buffer",
    "wpeN": "waves_per_eu_N",
    "agfN": "fused_agpr_N",
    "agN": "agpr_N",
    "nos2w": "no_s2_lds_store",
    "fcsk": "fused_skip_own_slot",
}
_OPTION_TOKENS = {name: token for token, name in _OPTION_NAMES.items()}


def _translate(value: str, table: dict) -> str:
    """Map each ``+``-joined option through ``table``, keeping integer suffixes."""
    out = []
    for option in value.split("+"):
        stem = option.rstrip("0123456789")
        num = option[len(stem) :]
        key = stem + "N" if num else option
        if key not in table:
            raise ValueError(f"unknown kernel option {option!r}")
        out.append(table[key][:-1] + num if num else table[key])
    return "+".join(out)


def config_to_string(cell: dict) -> str:
    """Serialize a tile-table cell to a readable CSV/registry-safe string."""
    parts = []
    for stage in ("s1", "s2"):
        for key in _STAGE_KEYS:
            if key in cell[stage]:
                value = cell[stage][key]
                if key == "diag":
                    value = _translate(value, _OPTION_NAMES)
                parts.append(f"{stage}{key}={value}")
    for key in _GLOBAL_KEYS:
        if key in cell.get("global", {}):
            value = cell["global"][key]
            if key == "diagF":
                value = _translate(value, _OPTION_NAMES)
            parts.append(f"{key}={value}")
    return "-".join(parts)


@lru_cache(maxsize=256)
def config_from_string(config: str) -> tuple:
    """Inverse of :func:`config_to_string`, as sorted ``MoERun`` kwargs."""
    kwargs = {}
    for part in config.split("-"):
        key, _, value = part.partition("=")
        if key[:2] in ("s1", "s2"):
            key = key[2:] + key[1]
        if key.startswith("diag"):
            value = _translate(value, _OPTION_TOKENS)
        kwargs[key] = int(value) if value.lstrip("-").isdigit() else value
    return tuple(sorted(kwargs.items()))


def tune_space(inter_dim: int) -> list[str]:
    """Distinct prefill configs for ``inter_dim``; candidates for the tuner."""
    seen = []
    for token, cell in sorted(_configs.load_table(inter_dim).items()):
        config = config_to_string(cell)
        if token >= MIN_TOKENS and config not in seen:
            seen.append(config)
    return seen


def _unshuffle_scale(s: torch.Tensor, e: int, n: int, groups: int) -> torch.Tensor:
    """Inverse of ``e8m0_shuffle`` for an [e * n, groups] e8m0 scale."""
    s = s.view(torch.uint8).reshape(-1)
    cols = (groups + 7) // 8 * 8
    rows = s.numel() // cols
    s = s.view(rows // 32, cols // 8, 4, 16, 2, 2).permute(0, 5, 3, 1, 4, 2)
    return s.reshape(rows, cols)[: e * n, :groups].reshape(e, n, groups)


# Repacked scales only; the entries hold no reference to the weights.
_packed: dict[tuple, tuple] = {}
# One workspace, shared by every layer of a forward step (same shape and
# config, run back to back on one stream); only the output is per call. It is
# released before a new shape allocates, so at most one exists at a time.
_runs: dict[tuple, _moe.MoERun] = {}


def _weights(w1, w2, w1_scale, w2_scale) -> _moe.MoEWeights:
    """The preshuffled fp4 weights in place, plus their repacked scales (cached for
    the lifetime of the source tensors)."""
    sources = (w1, w2, w1_scale, w2_scale)
    key = tuple((t.data_ptr(), t.shape) for t in sources)
    hit = _packed.get(key)
    if hit is None or not all(r() is t for r, t in zip(hit[0], sources)):
        e, n13, kh = w1.shape
        inter, hidden = n13 // 2, kh * 2
        bs1 = _layout.pack_scales(1, _unshuffle_scale(w1_scale, e, n13, hidden // 32))
        bs2 = _layout.pack_scales(2, _unshuffle_scale(w2_scale, e, hidden, inter // 32))
        hit = (tuple(weakref.ref(t) for t in sources), bs1, bs2)
        _packed[key] = hit
        weakref.finalize(w1, _packed.pop, key, None)
    return _moe.MoEWeights(w1, w2, hit[1], hit[2])


def unsupported_reason(request: FusedMoeRequest) -> str | None:
    w1, w2 = request.w1, request.w2
    if get_gfx() != "gfx950":
        return f"gfx {get_gfx()!r}"
    if not (getattr(w1, "is_shuffled", False) and getattr(w2, "is_shuffled", False)):
        return "weights not preshuffled"
    if w1.dtype != dtypes.fp4x2 or w2.dtype != dtypes.fp4x2:
        return f"weight dtype {w1.dtype}"
    if request.quant_type != QuantType.per_1x32:
        return f"quant_type {request.quant_type}"
    if request.activation != ActivationType.Swiglu:
        return f"activation {request.activation}"
    if request.hidden_states.dtype != dtypes.bf16:
        return f"hidden dtype {request.hidden_states.dtype}"
    if request.dtype not in (None, dtypes.bf16):
        return f"output dtype {request.dtype}"
    if request.expert_mask is not None or request.num_local_tokens is not None:
        return "expert parallelism"
    if request.bias1 is not None or request.bias2 is not None:
        return "per-expert bias"
    if request.doweight_stage1:
        return "doweight_stage1"
    if request.a1_scale is not None or request.a2_scale is not None:
        return "prequantized activations"
    if request.hidden_pad or request.intermediate_pad:
        return "hidden/intermediate padding"
    if request.swiglu_limit not in (None, _SWIGLU_LIMIT):
        return f"swiglu_limit {request.swiglu_limit}"
    gate_mode = getattr(request.gate_mode, "value", request.gate_mode)
    if gate_mode not in (None, "separated"):
        return f"gate_mode {gate_mode!r}"
    _, n13, kh = w1.shape
    if n13 % 128 or (kh * 2) % 256:
        return f"shape inter_dim={n13 // 2} model_dim={kh * 2}"
    return None


def run_moe_a4w4_compact(request: FusedMoeRequest, config: str) -> torch.Tensor:
    reason = unsupported_reason(request)
    if reason is not None:
        raise NotImplementedError(f"FlyDSL A4W4 compact MoE does not support {reason}")
    x = request.hidden_states.contiguous()
    weights = _weights(request.w1, request.w2, request.w1_scale, request.w2_scale)
    key = (x.shape, request.topk_ids.shape, x.device, weights.E, weights.I, config)
    # Every buffer a run owns is a per-shape workspace; inputs, weights and the
    # output are rebound per call below.
    run = _runs.get(key)
    if run is None:
        _runs.clear()
        kwargs = dict(config_from_string(config))
        if kwargs.get("FC") and not _FUSED_SHARED_EXPERT:
            kwargs = {k: v for k, v in kwargs.items() if k not in _FC_KEYS}
        run = _moe.MoERun(
            x,
            request.topk_ids,
            request.topk_weight,
            weights,
            SR=_SCALE_RULE,
            validate=False,
            **kwargs,
        )
        _runs[key] = run
    run.W = weights
    run.x = x
    run.ids = _flat(request.topk_ids, torch.int32)
    run.w = _flat(request.topk_weight, torch.float32)
    run.out = torch.empty_like(x)
    return run.forward()


def _flat(t: torch.Tensor, dtype: torch.dtype) -> torch.Tensor:
    """Flat routing buffer for the plan kernel; no copy when already in place."""
    return (
        t.reshape(-1)
        if t.dtype == dtype and t.is_contiguous()
        else t.reshape(-1).to(dtype)
    )
