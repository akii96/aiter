"""LEAD A: does fp8-partial corruption correlate exactly with inter_dim % tile_k != 0?

Sweeps inter_dim and records, per shape: the dispatched stage-2 kernel name (which
encodes the actual tile_k), and whether fp8 output is non-finite. If NaN tracks a
single modulus condition, that is the root-cause predicate.
"""
import gc, io, os, re, contextlib
import torch, aiter
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, fused_topk
from aiter.ops.shuffle import shuffle_weight

MD, E, TOPK = 6144, 129, 5
M = int(os.environ.get("NF_M", "4096"))
IDS = [int(x) for x in os.environ.get(
    "NF_IDS", "128,256,384,512,640,768,896,1024").split(",")]

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

def call(t, fp8):
    old = os.environ.get("AITER_FLYDSL_STAGE2_FP8")
    if fp8: os.environ["AITER_FLYDSL_STAGE2_FP8"] = "1"
    else:   os.environ.pop("AITER_FLYDSL_STAGE2_FP8", None)
    buf = io.StringIO()
    try:
        with contextlib.redirect_stderr(buf):
            o = fused_moe(t["x"], t["w1q"], t["w2q"], t["tw"], t["ti"],
                          quant_type=QuantType.per_1x32,
                          w1_scale=t["w1s"], w2_scale=t["w2s"],
                          activation=ActivationType.Swiglu,
                          doweight_stage1=False, swiglu_limit=7.0)
            torch.cuda.synchronize()
        k2 = re.findall(r"kernelName2='([^']+)'", buf.getvalue())
        return o.float(), (k2[-1] if k2 else "")
    finally:
        if old is None: os.environ.pop("AITER_FLYDSL_STAGE2_FP8", None)
        else: os.environ["AITER_FLYDSL_STAGE2_FP8"] = old

print(f"M={M} model_dim={MD}  PRESHUFFLED, fresh tensors per shape\n")
print(f"{'inter':>6} {'%256':>5} {'%128':>5} {'base_bad':>9} {'fp8_bad':>9} "
      f"{'fp8_amax':>11} {'relL2':>10}  stage2 kernel")
print("-"*118)
rows = []
for ID in IDS:
    try:
        t = build(ID)
        b, _  = call(t, False)
        p, k2 = call(t, True)
        bb = int((~torch.isfinite(b)).sum()); pb = int((~torch.isfinite(p)).sum())
        pa = float(p[torch.isfinite(p)].abs().max()) if pb < p.numel() else float('nan')
        rel = float((p-b).norm()/b.norm()) if (bb == 0 and pb == 0) else float('nan')
        tag = re.sub(r"^flydsl_moe2_layout_afp4_wfp4_bf16_", "", k2)
        print(f"{ID:>6} {ID%256:>5} {ID%128:>5} {bb:>9,} {pb:>9,} {pa:>11.3e} "
              f"{rel:>10.3e}  {tag[:44]}")
        rows.append((ID, pb))
        del t, b, p
    except Exception as ex:
        print(f"{ID:>6} {ID%256:>5} {ID%128:>5}   EXC {type(ex).__name__}: {str(ex)[:46]}")
    gc.collect(); torch.cuda.empty_cache()

print("\n--- predicate check ---")
for name, pred in (("inter_dim % 256 != 0", lambda d: d % 256 != 0),
                   ("inter_dim % 128 != 0", lambda d: d % 128 != 0),
                   ("inter_dim % 512 != 0", lambda d: d % 512 != 0)):
    ok = all((pb > 0) == pred(ID) for ID, pb in rows)
    print(f"  {name:<24} predicts NaN exactly: {ok}")
