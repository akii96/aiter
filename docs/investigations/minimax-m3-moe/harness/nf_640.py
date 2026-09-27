"""CRITICAL: do 640/704 corrupt with AITER_FLYDSL_STAGE2_FP8 UNSET?

If yes, corruption exists in the DEFAULT path and is far more serious than an
experimental flag. Tests flag-off and flag-on, multiple seeds, and also records
whether an fp8 uint8 buffer was allocated (ground truth for "is fp8 active"),
rather than inferring from kernel names.
"""
import gc, os
import torch, aiter
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, fused_topk
from aiter.ops.shuffle import shuffle_weight

MD, E, TOPK = 6144, 129, 5
M = 4096
SANE = 1e3

def build(ID, seed):
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

def run(t, fp8):
    saw_u8 = []
    _re = torch.empty
    def emp(*a, **k):
        o = _re(*a, **k)
        try:
            if o.is_cuda and o.dtype == torch.uint8 and o.numel() > 50*(1 << 20):
                saw_u8.append(o.numel())
        except Exception: pass
        return o
    old = os.environ.get("AITER_FLYDSL_STAGE2_FP8")
    if fp8: os.environ["AITER_FLYDSL_STAGE2_FP8"] = "1"
    else:   os.environ.pop("AITER_FLYDSL_STAGE2_FP8", None)
    torch.empty = emp
    try:
        o = fused_moe(t["x"], t["w1q"], t["w2q"], t["tw"], t["ti"],
                      quant_type=QuantType.per_1x32,
                      w1_scale=t["w1s"], w2_scale=t["w2s"],
                      activation=ActivationType.Swiglu,
                      doweight_stage1=False, swiglu_limit=7.0)
        torch.cuda.synchronize()
    finally:
        torch.empty = _re
        if old is None: os.environ.pop("AITER_FLYDSL_STAGE2_FP8", None)
        else: os.environ["AITER_FLYDSL_STAGE2_FP8"] = old
    f = torch.isfinite(o); nb = int((~f).sum())
    am = float(o[f].abs().max()) if int(f.sum()) else float('nan')
    return nb, am, bool(saw_u8)

print(f"M={M} model_dim={MD}  preshuffled, fresh tensors\n")
print(f"{'inter':>6} {'seed':>5} {'flag':>5} {'fp8buf':>7} {'non_finite':>11} {'absmax':>11}  verdict")
print("-"*78)
for ID in (640, 704, 384, 896):
    for seed in (0, 1):
        for fp8 in (False, True):
            try:
                t = build(ID, seed)
                nb, am, u8 = run(t, fp8)
                ok = nb == 0 and am == am and am < SANE
                print(f"{ID:>6} {seed:>5} {('ON' if fp8 else 'OFF'):>5} {str(u8):>7} "
                      f"{nb:>11,} {am:>11.3e}  {'OK' if ok else '*** CORRUPT ***'}")
                del t
            except Exception as ex:
                print(f"{ID:>6} {seed:>5} {('ON' if fp8 else 'OFF'):>5}   EXC {type(ex).__name__}: {str(ex)[:34]}")
            gc.collect(); torch.cuda.empty_cache()
    print()
