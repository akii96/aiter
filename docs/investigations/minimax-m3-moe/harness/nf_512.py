"""Production-shape check: fp8 partials at inter_dim=512 (clean per the sweep).

Speed AND accuracy on the shape MiniMax-M3 actually dispatches. Arms round-robin
interleaved, serial, one GPU, medians.
"""
import gc, os, statistics
import torch, aiter
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, fused_topk
from aiter.ops.shuffle import shuffle_weight
from aiter.test_common import run_perftest

MD, E, TOPK = 6144, 129, 5
ID = int(os.environ.get("NF_ID", "512"))
ROUNDS = int(os.environ.get("NF_ROUNDS", "5"))

def build(M, seed=0):
    torch.manual_seed(seed); torch.cuda.manual_seed(seed)
    d = "cuda"
    x  = torch.randn((M, MD), dtype=dtypes.bf16, device=d) * (8.0/MD**0.5)
    w1 = torch.randn((E, ID*2, MD), dtype=dtypes.bf16, device=d) * (1.0/MD**0.5)
    w2 = torch.randn((E, MD, ID),  dtype=dtypes.bf16, device=d) * (1.0/ID**0.5)
    sc = torch.randn((M, E), dtype=dtypes.bf16, device=d)
    tw, ti = fused_topk(x, sc, TOPK, True)
    q = aiter.get_torch_quant(QuantType.per_1x32)
    w1q, w1s = q(w1, quant_dtype=dtypes.fp4x2)
    w2q, w2s = q(w2, quant_dtype=dtypes.fp4x2)
    del w1, w2, sc
    t = dict(x=x, tw=tw, ti=ti,
             w1q=shuffle_weight(w1q.view(E, ID*2, MD//2), layout=(16, 16)),
             w2q=shuffle_weight(w2q.view(E, MD, ID//2),  layout=(16, 16)),
             w1s=w1s.view(E, ID*2, MD//32), w2s=w2s.view(E, MD, ID//32))
    gc.collect(); torch.cuda.empty_cache()
    return t

def mk(t):
    return lambda: fused_moe(t["x"], t["w1q"], t["w2q"], t["tw"], t["ti"],
                             quant_type=QuantType.per_1x32,
                             w1_scale=t["w1s"], w2_scale=t["w2s"],
                             activation=ActivationType.Swiglu,
                             doweight_stage1=False, swiglu_limit=7.0)

def with_fp8(on, fn):
    old = os.environ.get("AITER_FLYDSL_STAGE2_FP8")
    if on: os.environ["AITER_FLYDSL_STAGE2_FP8"] = "1"
    else:  os.environ.pop("AITER_FLYDSL_STAGE2_FP8", None)
    try: return fn()
    finally:
        if old is None: os.environ.pop("AITER_FLYDSL_STAGE2_FP8", None)
        else: os.environ["AITER_FLYDSL_STAGE2_FP8"] = old

print(f"PRODUCTION SHAPE: model_dim={MD} inter_dim={ID} E={E} topk={TOPK} Swiglu a4w4")
print(f"dev={torch.cuda.get_device_name(0)}  serial, arms interleaved, medians of {ROUNDS}\n")
print(f"{'M':>7} {'bf16_us':>10} {'fp8_us':>10} {'speedup':>9} {'fp8_bad':>8} {'relL2':>11}")
print("-"*62)
for M in (4096, 8192, 16384):
    try:
        t = build(M); call = mk(t)
        b = with_fp8(False, call); torch.cuda.synchronize()
        p = with_fp8(True,  call); torch.cuda.synchronize()
        bb = int((~torch.isfinite(b)).sum()); pb = int((~torch.isfinite(p)).sum())
        rel = float((p.float()-b.float()).norm()/b.float().norm()) if (bb == 0 and pb == 0) else float('nan')
        sb, sp = [], []
        for _ in range(ROUNDS):           # ROUND-ROBIN INTERLEAVED
            sb.append(with_fp8(False, lambda: run_perftest(call, num_iters=20, num_warmup=3))[1])
            sp.append(with_fp8(True,  lambda: run_perftest(call, num_iters=20, num_warmup=3))[1])
        mb, mp = statistics.median(sb), statistics.median(sp)
        print(f"{M:>7} {mb:>10.2f} {mp:>10.2f} {mb/mp:>8.3f}x {pb:>8,} {rel:>11.3e}")
        del t, b, p
    except Exception as ex:
        print(f"{M:>7}   EXC {type(ex).__name__}: {str(ex)[:44]}")
    gc.collect(); torch.cuda.empty_cache()
