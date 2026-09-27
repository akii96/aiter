"""Verify directly whether the fp8 route-out buffer is ALLOCATED, per inter_dim.

Infers nothing from logs: intercepts torch.empty and looks for a large uint8
allocation, which exists ONLY when the fp8 route-out is active. Also records
whether a bf16 partial buffer of shape (M*topk, model_dim) appears (reduce) or
not (atomic).
"""
import gc, os
import torch, aiter
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, fused_topk
from aiter.ops.shuffle import shuffle_weight

MD, E, TOPK = 6144, 129, 5
M = 4096

def build(ID, seed=0):
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

def probe(t, fp8):
    allocs = []
    _re = torch.empty
    def emp(*a, **k):
        o = _re(*a, **k)
        try:
            nb = o.numel()*o.element_size()
            if nb > (1 << 20) and o.is_cuda:
                allocs.append((str(o.dtype), tuple(o.shape), nb))
        except Exception: pass
        return o
    old = os.environ.get("AITER_FLYDSL_STAGE2_FP8")
    if fp8: os.environ["AITER_FLYDSL_STAGE2_FP8"] = "1"
    else:   os.environ.pop("AITER_FLYDSL_STAGE2_FP8", None)
    torch.empty = emp
    try:
        fused_moe(t["x"], t["w1q"], t["w2q"], t["tw"], t["ti"],
                  quant_type=QuantType.per_1x32,
                  w1_scale=t["w1s"], w2_scale=t["w2s"],
                  activation=ActivationType.Swiglu,
                  doweight_stage1=False, swiglu_limit=7.0)
        torch.cuda.synchronize()
    finally:
        torch.empty = _re
        if old is None: os.environ.pop("AITER_FLYDSL_STAGE2_FP8", None)
        else: os.environ["AITER_FLYDSL_STAGE2_FP8"] = old
    u8   = [a for a in allocs if a[0] == "torch.uint8" and a[2] > 50*(1 << 20)]
    part = [a for a in allocs if a[0] == "torch.bfloat16" and a[1] == (M*TOPK, MD)]
    part += [a for a in allocs if a[0] == "torch.bfloat16" and a[1] == (M, TOPK, MD)]
    return u8, part

print(f"M={M} model_dim={MD}   does the fp8 route-out buffer actually get allocated?\n")
print(f"{'inter':>6} {'fp8 uint8 buf':>16} {'bf16 partial buf':>18}  verdict")
print("-"*72)
for ID in (384, 512, 640, 704, 768, 896):
    try:
        t = build(ID)
        u8, part = probe(t, True)
        v = "FP8 ACTIVE" if u8 else ("reduce/bf16 partials" if part else "ATOMIC (no partial buf)")
        us = f"{u8[0][2]/1024**2:.0f} MB" if u8 else "-"
        ps = f"{part[0][2]/1024**2:.0f} MB" if part else "-"
        print(f"{ID:>6} {us:>16} {ps:>18}  {v}")
        del t
    except Exception as ex:
        print(f"{ID:>6}   EXC {type(ex).__name__}: {str(ex)[:44]}")
    gc.collect(); torch.cuda.empty_cache()
