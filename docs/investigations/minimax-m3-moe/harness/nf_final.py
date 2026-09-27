"""DEFINITIVE test of the fp8-partials claims, with a clean harness.

Earlier evidence was contaminated: weights were passed UNSHUFFLED to tuned
kernels (outside aiter's stated contract), and the harness held multiple
multi-GB weight sets alive at once. This version:
  - uses PRESHUFFLED weights (the supported contract)
  - builds fresh tensors per call and frees them before the next
  - reports free VRAM so memory pressure is visible
  - runs both arms on the SAME inputs, multiple seeds
Answers two questions:
  Q1 does AITER_FLYDSL_STAGE2_FP8=1 ever produce non-finite output?
  Q2 what is the real rel-L2 of fp8 vs bf16 partials under the contract?
"""
import gc, os, torch, aiter
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, fused_topk
from aiter.ops.shuffle import shuffle_weight

MD, E, TOPK = 6144, 129, 5
SANE = 1e3

def vram():
    f, t = torch.cuda.mem_get_info()
    return f / 1024**3

def build(M, ID, seed):
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

def call(t, fp8):
    old = os.environ.get("AITER_FLYDSL_STAGE2_FP8")
    if fp8: os.environ["AITER_FLYDSL_STAGE2_FP8"] = "1"
    else:   os.environ.pop("AITER_FLYDSL_STAGE2_FP8", None)
    try:
        o = fused_moe(t["x"], t["w1q"], t["w2q"], t["tw"], t["ti"],
                      quant_type=QuantType.per_1x32,
                      w1_scale=t["w1s"], w2_scale=t["w2s"],
                      activation=ActivationType.Swiglu,
                      doweight_stage1=False, swiglu_limit=7.0)
        torch.cuda.synchronize(); return o.float()
    finally:
        if old is None: os.environ.pop("AITER_FLYDSL_STAGE2_FP8", None)
        else: os.environ["AITER_FLYDSL_STAGE2_FP8"] = old

print("PRESHUFFLED weights (supported contract), fresh tensors per config\n")
print(f"{'M':>6} {'inter':>6} {'seed':>4} {'freeGB':>7} {'base_bad':>9} {'fp8_bad':>8} "
      f"{'base_amax':>11} {'fp8_amax':>11} {'rel_L2':>11}")
print("-" * 92)
for ID in (384, 768):
    for M in (4096, 8192):
        for seed in (0, 1, 2):
            try:
                t = build(M, ID, seed)
                b = call(t, False)
                p = call(t, True)
                bb = int((~torch.isfinite(b)).sum()); pb = int((~torch.isfinite(p)).sum())
                ba = float(b[torch.isfinite(b)].abs().max()) if bb < b.numel() else float('nan')
                pa = float(p[torch.isfinite(p)].abs().max()) if pb < p.numel() else float('nan')
                rel = float((p-b).norm()/b.norm()) if (bb == 0 and pb == 0) else float('nan')
                print(f"{M:>6} {ID:>6} {seed:>4} {vram():>7.1f} {bb:>9,} {pb:>8,} "
                      f"{ba:>11.3e} {pa:>11.3e} {rel:>11.3e}")
                del t, b, p
            except Exception as ex:
                print(f"{M:>6} {ID:>6} {seed:>4}   EXC {type(ex).__name__}: {str(ex)[:40]}")
            gc.collect(); torch.cuda.empty_cache()
