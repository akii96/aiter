"""Op-level production-path A/B at the prefill buckets.

Both arms are the SAME process, SAME tensors, SAME tuned CSV loaded. The ONLY
difference is whether (129,6144,1536,5) is in MXFP4_MOE_SUPPORTED_SHAPES.
Arms are interleaved round-robin and rotated; a null-duplicate arm establishes
the noise floor.

env: BUCKETS="2048,8192"  TUNEDCSV=/path.csv  REPS=7  SEED=0
"""
import os, sys, json, time, statistics, functools
sys.argv = ["ab"]
sys.path.insert(0, "/workspace/aiter")

import torch
torch.cuda.set_device(0)
torch.set_default_device("cuda")
import aiter
import aiter.fused_moe as FM
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, fused_topk
from aiter.ops.flydsl.moe_common import GateMode
from aiter.ops.shuffle import shuffle_weight, shuffle_scale
from aiter.ops.quant import per_1x32_f4_quant
import aiter.ops.moe_mxfp4_aux as aux

MODEL_DIM, E, TOPK, INTER = 6144, 129, 5, 1536
SWIGLU_LIMIT = 7.0
SHAPE = (129, 6144, 1536, 5)

BUCKETS = [int(x) for x in os.environ.get("BUCKETS", "2048,8192").split(",")]
TUNED   = os.environ["TUNEDCSV"]
REPS    = int(os.environ.get("REPS", "7"))
SEED    = int(os.environ.get("SEED", "0"))

os.environ["AITER_CONFIG_FMOE"] = TUNED
FM.cfg_2stages = None
FM.get_2stage_cfgs.cache_clear()

BASE = frozenset(aux.MXFP4_MOE_SUPPORTED_SHAPES) - {SHAPE}

def set_gate(on: bool):
    aux.MXFP4_MOE_SUPPORTED_SHAPES = frozenset(BASE | {SHAPE}) if on else BASE
    FM.get_2stage_cfgs.cache_clear()
    assert aiter.is_mxfp4_moe_shape_supported(*SHAPE) == on, "gate patch ineffective"

def _bk(fn):
    t = fn.func if isinstance(fn, functools.partial) else fn
    return getattr(t, "__name__", str(t))

def describe(M):
    meta = FM.get_2stage_cfgs(
        FM.get_padded_M(M), MODEL_DIM, INTER, E, TOPK, dtypes.bf16, dtypes.fp4x2,
        dtypes.fp4x2, QuantType.per_1x32, True, ActivationType.Swiglu,
        False, 0, 0, is_shuffled=True, gate_mode=GateMode.SEPARATED,
        opus_weights_shuffled=True, swiglu_limit=SWIGLU_LIMIT)
    return {"stage1": _bk(meta.stage1), "stage2": _bk(meta.stage2),
            "block_m": meta.block_m,
            "is_mxmoe": "mxfp4_a4w4" in _bk(meta.stage1),
            "kn1": (getattr(meta.stage1, "keywords", {}) or {}).get("kernelName"),
            "kn2": (getattr(meta.stage2, "keywords", {}) or {}).get("kernelName")}

def build(M):
    torch.manual_seed(SEED); torch.cuda.manual_seed_all(SEED)
    x  = torch.randn((M, MODEL_DIM), dtype=dtypes.bf16)
    w1 = torch.randn((E, INTER * 2, MODEL_DIM), dtype=dtypes.bf16)
    w2 = torch.randn((E, MODEL_DIM, INTER), dtype=dtypes.bf16)
    sc = torch.randn((M, E), dtype=dtypes.bf16)
    tw, ti = fused_topk(x, sc, TOPK, True)
    w1q, w1s = per_1x32_f4_quant(w1, quant_dtype=dtypes.fp4x2)
    w2q, w2s = per_1x32_f4_quant(w2, quant_dtype=dtypes.fp4x2)
    # fp4x2 packs 2 nibbles/byte -> halved last dim (matches test_moe_2stage)
    w1q = w1q.view(E, INTER * 2, MODEL_DIM // 2)
    w2q = w2q.view(E, MODEL_DIM, INTER // 2)
    return dict(x=x, tw=tw, ti=ti,
                w1=shuffle_weight(w1q, layout=(16, 16)),
                w2=shuffle_weight(w2q, layout=(16, 16)),
                w1s=shuffle_scale(w1s), w2s=shuffle_scale(w2s))

def call(T):
    return fused_moe(T["x"], T["w1"], T["w2"], T["tw"], T["ti"],
                     w1_scale=T["w1s"], w2_scale=T["w2s"],
                     quant_type=QuantType.per_1x32,
                     activation=ActivationType.Swiglu,
                     doweight_stage1=False, swiglu_limit=SWIGLU_LIMIT,
                     gate_mode=GateMode.SEPARATED)

def timed(T, iters=3):
    torch.cuda.synchronize(); t0 = time.perf_counter()
    for _ in range(iters):
        call(T)
    torch.cuda.synchronize()
    return (time.perf_counter() - t0) / iters * 1e6   # us

OUT = {"tuned_csv": TUNED, "reps": REPS, "buckets": {}}

for M in BUCKETS:
    T = build(M)
    rec = {"M": M, "padded": FM.get_padded_M(M)}
    # dispatch identity per arm
    for name, on in (("heuristic", False), ("mxmoe", True)):
        set_gate(on)
        rec[f"dispatch_{name}"] = describe(M)
    # first-touch discard for both arms
    for on in (False, True):
        set_gate(on); call(T); torch.cuda.synchronize()
    samples = {"heuristic": [], "mxmoe": [], "null": []}
    # arms: A=gate off, B=gate on, N=null duplicate of A (noise floor)
    for r in range(REPS):
        order = [("heuristic", False), ("mxmoe", True), ("null", False)]
        if r % 2: order = list(reversed(order))
        for nm, on in order:
            set_gate(on)
            samples[nm].append(timed(T))
    for k, v in samples.items():
        v = sorted(v)
        rec[k] = {"median_us": statistics.median(v),
                  "min_us": v[0], "max_us": v[-1],
                  "spread_pct": (v[-1] - v[0]) / statistics.median(v) * 100,
                  "n": len(v)}
    h, m, n = rec["heuristic"]["median_us"], rec["mxmoe"]["median_us"], rec["null"]["median_us"]
    rec["delta_pct_mxmoe_vs_heuristic"] = (h - m) / h * 100
    rec["null_calibration_pct"] = (h - n) / h * 100
    OUT["buckets"][str(M)] = rec
    print(f"[bucket {M}] heuristic={h:.1f}us  mxmoe={m:.1f}us  "
          f"delta={rec['delta_pct_mxmoe_vs_heuristic']:+.2f}%  "
          f"null={rec['null_calibration_pct']:+.2f}%  "
          f"mxmoe_dispatched={rec['dispatch_mxmoe']['is_mxmoe']}", flush=True)
    del T; torch.cuda.empty_cache()

print("@@@AB@@@ " + json.dumps(OUT))
