# SPDX-License-Identifier: MIT
# Copyright (C) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""FlyMoE: A4W4 MXFP4 prefill MoE for gfx950, dispatched as a whole-graph impl.

Tuned rows select it with ``kernelName1 = impl__flymoe__<cfg>``; ``<cfg>`` is a
FlyMoE tile config serialized by :func:`config_to_string`. The backend reads the
same preshuffled weights as the other per_1x32 fp4 paths (``shuffle_weight``
with layout (16, 16) and ``e8m0_shuffle`` scales, gate/up SEPARATED) and repacks
them once per weight tensor into the FlyMoE MFMA-native layout. The repacked
copy lives as long as the source weights, so the expert weights are held twice
until the kernels read the AITER layout directly.

Rows are compact (no block_m padding), the activation quant and the expert sort
run on device, and any ``inter_dim`` that is a multiple of 128 runs natively
(TP8 MiniMax-M3 at 384, no padding to 512). Tables cover prefill only
(``token >= MIN_TOKENS``); decode stays on the existing kernels.
"""

import json
import os
import weakref
from functools import lru_cache

import torch

from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe_registry import FusedMoeRequest
from aiter.jit.utils.chip_info import get_gfx

from .flymoe import moe as _moe

_STAGE_KEYS = ("BM", "D", "NW", "WM", "pipe", "diag", "PERS", "EF", "MV")
_GLOBAL_KEYS = ("HT", "FC", "QP", "BMF", "NWF", "WMF", "DF", "pipeF", "diagF")
MIN_TOKENS = 512
_TABLE_DIR = os.path.join(os.path.dirname(__file__), "flymoe", "configs")
_SWIGLU_LIMIT = 7.0
_MAX_RUNS = 8
_FC_KEYS = ("FC", "BMF", "NWF", "WMF", "DF", "pipeF", "diagF")
# Fused combine folds the last expert's tile into the combine. It is exact only
# when expert E-1 is a shared expert routed once per token, which is the
# layout of fused shared experts (e.g. vLLM VLLM_ROCM_USE_AITER_FUSION_SHARED_EXPERTS).
_FUSED_SHARED_EXPERT = os.environ.get("AITER_FLYMOE_FUSED_SHARED_EXPERT", "0") == "1"
# e8m0 rule for the activation and intermediate quant. "ceil" matches AITER's
# runtime MX quant (MxScaleRoundMode.RoundUp); "even" matches checkpoints
# calibrated with scale_calculation_mode="even" (Quark).
_SCALE_RULE = os.environ.get("AITER_FLYMOE_SCALE_RULE", "ceil")


def config_to_string(cell: dict) -> str:
    """Serialize a tile-table cell to a CSV/registry-safe token string."""
    parts = []
    for stage in ("s1", "s2"):
        for key in _STAGE_KEYS:
            if key in cell[stage]:
                parts.append(f"{stage}{key}={cell[stage][key]}")
    for key in _GLOBAL_KEYS:
        if key in cell.get("global", {}):
            parts.append(f"{key}={cell['global'][key]}")
    return "-".join(parts)


@lru_cache(maxsize=256)
def config_from_string(config: str) -> tuple:
    """Inverse of :func:`config_to_string`, as sorted ``MoERun`` kwargs."""
    kwargs = {}
    for part in config.split("-"):
        key, _, value = part.partition("=")
        if key[:2] in ("s1", "s2"):
            key = key[2:] + key[1]
        kwargs[key] = int(value) if value.lstrip("-").isdigit() else value
    return tuple(sorted(kwargs.items()))


def tune_space(inter_dim: int) -> list[str]:
    """Distinct shipped configs for ``inter_dim``; candidates for the tuner."""
    path = os.path.join(_TABLE_DIR, f"tiles_v7_I{inter_dim}.json")
    if not os.path.exists(path):
        return []
    with open(path) as f:
        table = json.load(f)
    seen = []
    for token in sorted(table, key=int):
        if int(token) < MIN_TOKENS:
            continue
        config = config_to_string(table[token])
        if config not in seen:
            seen.append(config)
    return seen


def _unshuffle_weight(w: torch.Tensor) -> torch.Tensor:
    """Inverse of ``shuffle_weight(w, layout=(16, 16))`` for fp4x2 [E, N, K/2]."""
    e, n, kh = w.shape
    w = w.view(torch.uint8).view(e, n // 16, kh // 32, 2, 16, 16)
    return w.permute(0, 1, 4, 2, 3, 5).reshape(e, n, kh)


def _unshuffle_scale(s: torch.Tensor, e: int, n: int, groups: int) -> torch.Tensor:
    """Inverse of ``e8m0_shuffle`` for an [e * n, groups] e8m0 scale."""
    s = s.view(torch.uint8).reshape(-1)
    cols = (groups + 7) // 8 * 8
    rows = s.numel() // cols
    s = s.view(rows // 32, cols // 8, 4, 16, 2, 2).permute(0, 5, 3, 1, 4, 2)
    return s.reshape(rows, cols)[: e * n, :groups].reshape(e, n, groups)


_packed: dict[tuple, tuple] = {}
# Workspaces are shared by every layer with the same shape and config; layers
# run back to back on one stream, so only the output buffer is per call.
_runs: dict[tuple, _moe.MoERun] = {}


def _weights(w1, w2, w1_scale, w2_scale) -> _moe.MoEWeights:
    key = (w1.data_ptr(), w2.data_ptr(), w1_scale.data_ptr(), w2_scale.data_ptr())
    hit = _packed.get(key)
    if hit is not None and hit[0]() is not None:
        return hit[1]
    e, n13, kh = w1.shape
    inter, hidden = n13 // 2, kh * 2
    w13 = _unshuffle_weight(w1)
    s13 = _unshuffle_scale(w1_scale, e, n13, hidden // 32)
    packed = _moe.MoEWeights(
        w13[:, :inter],
        s13[:, :inter],
        w13[:, inter:],
        s13[:, inter:],
        _unshuffle_weight(w2),
        _unshuffle_scale(w2_scale, e, hidden, inter // 32),
    )
    _packed[key] = (weakref.ref(w1), packed)
    weakref.finalize(w1, _packed.pop, key, None)
    return packed


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


def run_flymoe_impl(request: FusedMoeRequest, config: str) -> torch.Tensor:
    reason = unsupported_reason(request)
    if reason is not None:
        raise NotImplementedError(f"FlyMoE does not support {reason}")
    x = request.hidden_states.contiguous()
    weights = _weights(request.w1, request.w2, request.w1_scale, request.w2_scale)
    key = (x.shape, request.topk_ids.shape, x.device, weights.E, weights.I, config)
    run = _runs.pop(key, None)
    if run is None:
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
        if len(_runs) >= _MAX_RUNS:
            _runs.pop(next(iter(_runs)))
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
