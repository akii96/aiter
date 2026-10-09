# SPDX-License-Identifier: MIT
# Copyright (C) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""FlyDSL A4W4 compact MoE (MXFP4 prefill) through ``aiter.fused_moe``.

Weights are prepared exactly as the per_1x32 fp4 MoE paths expect them
(``shuffle_weight`` (16, 16) + ``e8m0_shuffle``, gate/up SEPARATED) and a tuned
``impl__flydsl_a4w4_compact__<cfg>`` row routes the call to FlyDSL A4W4 compact MoE. The output is compared
with a torch reference that quantizes activations with AITER's runtime MX rule.
"""

import os

import pandas as pd
import pytest
import torch

import aiter
import aiter.fused_moe as fused_moe_module
import aiter.fused_moe_registry as _registry
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, get_2stage_cfgs, get_padded_M
from aiter.jit.utils.chip_info import get_gfx
from aiter.ops.shuffle import shuffle_weight
from aiter.utility import fp4_utils

pytestmark = pytest.mark.skipif(
    get_gfx() != "gfx950", reason="FlyDSL A4W4 compact MoE is gfx950-only"
)

MODEL_DIM = 6144
EXPERTS = 129
TOPK = 5
SWIGLU_LIMIT = 7.0
TUNED_COLUMNS = [
    "gfx",
    "cu_num",
    "token",
    "model_dim",
    "inter_dim",
    "expert",
    "topk",
    "act_type",
    "dtype",
    "q_dtype_a",
    "q_dtype_w",
    "q_type",
    "use_g1u1",
    "doweight_stage1",
    "block_m",
    "ksplit",
    "us1",
    "kernelName1",
    "err1",
    "us2",
    "kernelName2",
    "err2",
    "us",
    "run_1stage",
    "xbf16",
    "flat",
    "tflops",
    "bw",
    "_tag",
]


def _problem(tokens, inter_dim, shared_expert=True, seed=0):
    gen = torch.Generator(device="cuda").manual_seed(seed)
    x = torch.randn(tokens, MODEL_DIM, device="cuda", generator=gen).to(dtypes.bf16)
    w1 = torch.randn(EXPERTS, 2 * inter_dim, MODEL_DIM, device="cuda", generator=gen)
    w2 = torch.randn(EXPERTS, MODEL_DIM, inter_dim, device="cuda", generator=gen)
    quant = aiter.get_torch_quant(QuantType.per_1x32)
    w1_q, w1_s = quant((w1 / 10).to(dtypes.bf16), quant_dtype=dtypes.fp4x2)
    w2_q, w2_s = quant((w2 / 30).to(dtypes.bf16), quant_dtype=dtypes.fp4x2)
    w1_q = w1_q.view(EXPERTS, 2 * inter_dim, MODEL_DIM // 2)
    w2_q = w2_q.view(EXPERTS, MODEL_DIM, inter_dim // 2)
    routed = TOPK - 1 if shared_expert else TOPK
    scores = torch.rand(tokens, EXPERTS - 1, device="cuda", generator=gen)
    ids = scores.topk(routed, dim=-1).indices.to(torch.int32)
    weights = torch.rand(tokens, routed, device="cuda", generator=gen)
    if shared_expert:
        shared = torch.full((tokens, 1), EXPERTS - 1, device="cuda", dtype=torch.int32)
        ids = torch.cat([ids, shared], dim=1)
        weights = torch.cat([weights, torch.ones(tokens, 1, device="cuda")], dim=1)
    return x, (w1_q, w1_s, w2_q, w2_s), ids, weights.float()


def _aiter_weights(w1_q, w1_s, w2_q, w2_s):
    w1 = shuffle_weight(w1_q, layout=(16, 16))
    w2 = shuffle_weight(w2_q, layout=(16, 16))
    w1.is_shuffled = w2.is_shuffled = True
    return w1, w2, fp4_utils.e8m0_shuffle(w1_s), fp4_utils.e8m0_shuffle(w2_s)


def _dequant(q, s):
    values = fp4_utils.mxfp4_to_f32(q.view(torch.uint8))
    scales = fp4_utils.e8m0_to_f32(s.view(torch.uint8).view(*q.shape[:-1], -1))
    return (values.view(*scales.shape, 32) * scales.unsqueeze(-1)).view(values.shape)


def _reference(x, weights, ids, topk_weight):
    w1_q, w1_s, w2_q, w2_s = weights
    quant = aiter.get_torch_quant(QuantType.per_1x32)
    a_q, a_s = quant(x, quant_dtype=dtypes.fp4x2)
    a = _dequant(a_q.view(x.shape[0], -1), a_s.view(x.shape[0], -1))
    out = torch.zeros(x.shape, dtype=torch.float32, device=x.device)
    inter_dim = w2_q.shape[-1] * 2
    w1_s = w1_s.view(EXPERTS, 2 * inter_dim, -1)
    w2_s = w2_s.view(EXPERTS, MODEL_DIM, -1)
    for expert in ids.unique().tolist():
        token, slot = (ids == expert).nonzero(as_tuple=True)
        gate_up = a[token] @ _dequant(w1_q[expert], w1_s[expert]).T
        h = aiter.fused_moe.swiglu(
            gate_up[:, :inter_dim], gate_up[:, inter_dim:], limit=SWIGLU_LIMIT
        )
        h_q, h_s = quant(h, quant_dtype=dtypes.fp4x2)
        h = _dequant(h_q.view(h.shape[0], -1), h_s.view(h.shape[0], -1))
        y = h @ _dequant(w2_q[expert], w2_s[expert]).T
        out.index_add_(0, token, y * topk_weight[token, slot, None])
    return out


def _install_row(path, monkeypatch, tokens, inter_dim, config):
    """Point the tuned-config lookup at a single compact row for this shape."""
    row = dict.fromkeys(TUNED_COLUMNS, 0)
    row.update(
        gfx="gfx950",
        cu_num=torch.cuda.get_device_properties(0).multi_processor_count,
        token=get_padded_M(tokens),
        model_dim=MODEL_DIM,
        inter_dim=inter_dim,
        expert=EXPERTS,
        topk=TOPK,
        act_type=str(ActivationType.Swiglu),
        dtype=str(dtypes.bf16),
        q_dtype_a=str(dtypes.fp4x2),
        q_dtype_w=str(dtypes.fp4x2),
        q_type=str(QuantType.per_1x32),
        use_g1u1=1,
        kernelName1=f"impl__flydsl_a4w4_compact__{config}",
        kernelName2="",
        err1="0%",
        err2="0%",
        _tag="",
    )
    pd.DataFrame([row], columns=TUNED_COLUMNS).to_csv(path, index=False)
    monkeypatch.setenv("AITER_CONFIG_FMOE", str(path))
    _reset_tuned_config_caches()


def _spy_impl(monkeypatch):
    """Record every call the registry makes to the compact impl."""
    from aiter.ops.flydsl import fused_moe_a4w4_compact

    calls = []
    impl = fused_moe_a4w4_compact.run_moe_a4w4_compact

    def spy(request, config):
        calls.append(config)
        return impl(request, config)

    monkeypatch.setitem(_registry._IMPLEMENTATIONS, "flydsl_a4w4_compact", spy)
    return calls


@pytest.fixture
def tuned_row(tmp_path, monkeypatch):
    from aiter.ops.flydsl.fused_moe_a4w4_compact import tune_space

    def install(tokens, inter_dim, config=None):
        config = config or tune_space(inter_dim)[-1]
        path = tmp_path / "moe_a4w4_compact_tuned_fmoe.csv"
        _install_row(path, monkeypatch, tokens, inter_dim, config)
        return config

    calls = _spy_impl(monkeypatch)
    yield install
    monkeypatch.undo()
    _reset_tuned_config_caches()
    assert calls, "fused_moe did not dispatch to FlyDSL A4W4 compact MoE"


def _reset_tuned_config_caches():
    from aiter.jit.core import AITER_CONFIGS

    type(AITER_CONFIGS).get_config_file.cache_clear()
    fused_moe_module.cfg_2stages = None
    get_2stage_cfgs.cache_clear()


def _run(x, weights, ids, topk_weight, **kwargs):
    w1, w2, w1_s, w2_s = _aiter_weights(*weights)
    return fused_moe(
        x,
        w1,
        w2,
        topk_weight,
        ids,
        activation=ActivationType.Swiglu,
        quant_type=QuantType.per_1x32,
        w1_scale=w1_s,
        w2_scale=w2_s,
        dtype=dtypes.bf16,
        swiglu_limit=SWIGLU_LIMIT,
        **kwargs,
    )


def _rel_l2(out, ref):
    return ((out.float() - ref).norm() / ref.norm()).item()


@pytest.mark.parametrize("inter_dim", [384, 768, 1536])
@pytest.mark.parametrize("tokens", [512, 1000, 4096])
def test_moe_a4w4_compact_matches_reference(tuned_row, inter_dim, tokens):
    tuned_row(tokens, inter_dim)
    x, weights, ids, topk_weight = _problem(tokens, inter_dim)
    out = _run(x, weights, ids, topk_weight)
    assert _rel_l2(out, _reference(x, weights, ids, topk_weight)) < 2e-2


@pytest.mark.parametrize("inter_dim", [384, 768, 1536])
def test_moe_a4w4_compact_every_shipped_config(tuned_row, inter_dim):
    from aiter.ops.flydsl.fused_moe_a4w4_compact import tune_space

    x, weights, ids, topk_weight = _problem(777, inter_dim)
    ref = _reference(x, weights, ids, topk_weight)
    for config in tune_space(inter_dim):
        tuned_row(777, inter_dim, config)
        assert _rel_l2(_run(x, weights, ids, topk_weight), ref) < 2e-2, config


def test_moe_a4w4_compact_arbitrary_routing(tuned_row, monkeypatch):
    """Tokens without the shared expert must stay exact even for fused-combine rows."""
    from aiter.ops.flydsl import fused_moe_a4w4_compact
    from aiter.ops.flydsl.fused_moe_a4w4_compact import tune_space

    monkeypatch.setattr(fused_moe_a4w4_compact, "_FUSED_SHARED_EXPERT", False)
    config = next(c for c in tune_space(768) if "FC=1" in c)
    tuned_row(2048, 768, config)
    x, weights, ids, topk_weight = _problem(2048, 768, shared_expert=False)
    out = _run(x, weights, ids, topk_weight)
    assert _rel_l2(out, _reference(x, weights, ids, topk_weight)) < 2e-2


def _checkpoint_layer(path, layer, inter_dim):
    """TP rank-0 shard of one MiniMax-M3-MXFP4 MoE layer, shared expert as E-1."""
    import json

    from safetensors import safe_open

    with open(os.path.join(path, "model.safetensors.index.json")) as f:
        weight_map = json.load(f)["weight_map"]
    prefix = f"language_model.model.layers.{layer}.block_sparse_moe."
    experts = [
        (f"experts.{e}.w1", f"experts.{e}.w3", f"experts.{e}.w2") for e in range(128)
    ]
    experts.append(
        (
            "shared_experts.gate_proj",
            "shared_experts.up_proj",
            "shared_experts.down_proj",
        )
    )
    files = {}

    def get(name, index=slice(None)):
        file = weight_map[prefix + name]
        if file not in files:
            files[file] = safe_open(os.path.join(path, file), "pt", device="cpu")
        return files[file].get_slice(prefix + name)[index].cuda()

    rows, cols = slice(0, inter_dim), (slice(None), slice(0, inter_dim // 32))
    w1, s1, w2, s2 = [], [], [], []
    for gate, up, down in experts:
        w1.append(torch.cat([get(f"{gate}.weight", rows), get(f"{up}.weight", rows)]))
        s1.append(
            torch.cat(
                [get(f"{gate}.weight_scale", rows), get(f"{up}.weight_scale", rows)]
            )
        )
        w2.append(get(f"{down}.weight", (slice(None), slice(0, inter_dim // 2))))
        s2.append(get(f"{down}.weight_scale", cols))
    w1, w2 = torch.stack(w1).view(dtypes.fp4x2), torch.stack(w2).view(dtypes.fp4x2)
    s1 = torch.stack(s1).view(EXPERTS * 2 * inter_dim, -1)
    s2 = torch.stack(s2).view(EXPERTS * MODEL_DIM, -1)
    return (w1, s1, w2, s2), get("gate.weight").float(), get("e_score_correction_bias")


@pytest.mark.skipif(
    not os.environ.get("AITER_MINIMAX_M3_MXFP4_PATH"),
    reason="set AITER_MINIMAX_M3_MXFP4_PATH to a MiniMax-M3-MXFP4 checkpoint",
)
@pytest.mark.parametrize("inter_dim", [384, 768, 1536])
def test_moe_a4w4_compact_checkpoint_weights(tuned_row, inter_dim):
    """Real MiniMax-M3-MXFP4 expert weights and router, one MoE layer, every config."""
    from aiter.ops.flydsl.fused_moe_a4w4_compact import tune_space

    path = os.environ["AITER_MINIMAX_M3_MXFP4_PATH"]
    weights, gate, bias = _checkpoint_layer(path, 30, inter_dim)
    gen = torch.Generator(device="cuda").manual_seed(0)
    x = torch.randn(2048, MODEL_DIM, device="cuda", generator=gen).to(dtypes.bf16)
    scores = torch.sigmoid(x.float() @ gate.T)
    ids = (scores + bias.float()).topk(TOPK - 1, dim=-1).indices
    topk_weight = scores.gather(1, ids)
    topk_weight = topk_weight / topk_weight.sum(-1, keepdim=True)
    shared = torch.full((x.shape[0], 1), EXPERTS - 1, device="cuda")
    ids = torch.cat([ids, shared], dim=1).to(torch.int32)
    topk_weight = torch.cat([topk_weight, torch.ones_like(shared)], dim=1).float()
    ref = _reference(x, weights, ids, topk_weight)
    for config in tune_space(inter_dim):
        tuned_row(x.shape[0], inter_dim, config)
        assert _rel_l2(_run(x, weights, ids, topk_weight), ref) < 1e-2, config


def test_moe_a4w4_compact_layout_roundtrip():
    from aiter.ops.flydsl.fused_moe_a4w4_compact import _unshuffle_scale, _weights

    _, (w1_q, w1_s, w2_q, w2_s), _, _ = _problem(1, 384)
    w1, w2, w1_sh, w2_sh = _aiter_weights(w1_q, w1_s, w2_q, w2_s)
    for shuffled, raw in ((w1, w1_q), (w2, w2_q)):
        # B atom: [E][N/16][K/128][lane][16 B], lane l = row l % 16, bytes 16 (l // 16)
        e, n, kh = raw.shape
        atoms = raw.view(torch.uint8).view(e, n // 16, 16, kh // 64, 4, 16)
        atoms = atoms.permute(0, 1, 3, 4, 2, 5).reshape(e, n, kh)
        assert torch.equal(shuffled.view(torch.uint8), atoms)
    # the kernels read the weights in place: no weight copy
    weights = _weights(w1, w2, w1_sh, w2_sh)
    assert weights.b1.data_ptr() == w1.data_ptr()
    assert weights.b2.data_ptr() == w2.data_ptr()
    for packed, raw in ((w1_sh, w1_s), (w2_sh, w2_s)):
        e_n, groups = raw.shape
        unpacked = _unshuffle_scale(packed, 1, e_n, groups)
        assert torch.equal(unpacked.view(e_n, groups), raw.view(torch.uint8))


def test_moe_a4w4_compact_config_roundtrip():
    from aiter.ops.flydsl.fused_moe_a4w4_compact import (
        MIN_TOKENS,
        config_from_string,
        config_to_string,
    )
    from aiter.ops.flydsl.moe_a4w4_compact import configs

    for inter_dim in (384, 768, 1536):
        for tokens, cell in configs.load_table(inter_dim).items():
            assert tokens >= MIN_TOKENS
            text = config_to_string(cell)
            assert "," not in text and " " not in text and "__" not in text
            assert dict(config_from_string(text)) == configs.cfg_kwargs(cell)


def test_moe_a4w4_compact_rejects_unsupported():
    from aiter.fused_moe_registry import FusedMoeRequest
    from aiter.ops.flydsl.fused_moe_a4w4_compact import unsupported_reason

    x, weights, ids, topk_weight = _problem(512, 768)
    w1, w2, w1_s, w2_s = _aiter_weights(*weights)
    base = {
        "hidden_states": x,
        "w1": w1,
        "w2": w2,
        "topk_weight": topk_weight,
        "topk_ids": ids,
        "activation": ActivationType.Swiglu,
        "quant_type": QuantType.per_1x32,
        "w1_scale": w1_s,
        "w2_scale": w2_s,
    }
    assert unsupported_reason(FusedMoeRequest(**base)) is None
    for change in (
        {"activation": ActivationType.Silu},
        {"intermediate_pad": 128},
        {"hidden_pad": 256},
        {"doweight_stage1": True},
        {"expert_mask": torch.ones(EXPERTS, device="cuda")},
        {"gate_mode": "interleave"},
    ):
        assert unsupported_reason(FusedMoeRequest(**{**base, **change})) is not None


def test_moe_a4w4_compact_shipped_rows_resolve():
    """Every shipped compact row parses and names a cell of its inter_dim table."""
    from aiter.ops.flydsl.fused_moe_a4w4_compact import (
        config_from_string,
        tune_space,
    )
    from aiter.ops.flydsl.moe_a4w4_compact import configs

    path = os.path.join(
        os.path.dirname(aiter.__file__),
        "configs/model_configs/minimax_m3_fp4_tuned_fmoe.csv",
    )
    rows = pd.read_csv(path)
    prefix = "impl__flydsl_a4w4_compact__"
    rows = rows[rows["kernelName1"].str.startswith(prefix)]
    assert len(rows) > 0
    for kernel_name, inter_dim in zip(rows["kernelName1"], rows["inter_dim"]):
        assert _registry.resolve_fused_moe_impl(kernel_name) is not None
        config = kernel_name[len(prefix) :]
        assert config in tune_space(int(inter_dim)), kernel_name
        cells = configs.load_table(int(inter_dim)).values()
        kwargs = dict(config_from_string(config))
        assert any(configs.cfg_kwargs(c) == kwargs for c in cells), kernel_name


def _pad_weights(weights, inter_dim, padded):
    """Zero-pad an MXFP4 inter_dim shard as vLLM does at TP8 (scales 0x7F)."""
    w1_q, w1_s, w2_q, w2_s = weights
    pad = padded - inter_dim
    w1 = w1_q.view(torch.uint8).view(EXPERTS, 2, inter_dim, -1)
    w1 = torch.nn.functional.pad(w1, (0, 0, 0, pad))
    s1 = w1_s.view(torch.uint8).view(EXPERTS, 2, inter_dim, -1)
    s1 = torch.nn.functional.pad(s1, (0, 0, 0, pad), value=0x7F)
    w2 = torch.nn.functional.pad(w2_q.view(torch.uint8), (0, pad // 2))
    s2 = w2_s.view(torch.uint8).view(EXPERTS, MODEL_DIM, -1)
    s2 = torch.nn.functional.pad(s2, (0, pad // 32), value=0x7F)
    return (
        w1.view(EXPERTS, 2 * padded, -1).view(dtypes.fp4x2),
        s1.view(EXPERTS * 2 * padded, -1).view(dtypes.fp8_e8m0),
        w2.view(dtypes.fp4x2),
        s2.view(EXPERTS * MODEL_DIM, -1).view(dtypes.fp8_e8m0),
    )


def test_moe_a4w4_compact_skips_padded_calls(tmp_path, monkeypatch):
    """A padded call never reaches the compact family, even with a tuned row."""
    from aiter.ops.flydsl.fused_moe_a4w4_compact import tune_space

    tokens, inter_dim, padded = 1024, 384, 512
    calls = _spy_impl(monkeypatch)
    path = tmp_path / "moe_a4w4_compact_tuned_fmoe.csv"
    _install_row(path, monkeypatch, tokens, padded, tune_space(inter_dim)[-1])
    try:
        x, weights, ids, topk_weight = _problem(tokens, inter_dim)
        weights = _pad_weights(weights, inter_dim, padded)
        try:
            _run(x, weights, ids, topk_weight, intermediate_pad=padded - inter_dim)
        except NotImplementedError as error:  # a non-compact path may reject padding
            assert "compact" not in str(error), error
        assert not calls, "padded call dispatched to the compact family"
    finally:
        monkeypatch.undo()
        _reset_tuned_config_caches()


if __name__ == "__main__":
    raise SystemExit(pytest.main([__file__, "-v", *os.sys.argv[1:]]))
