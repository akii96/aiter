"""Is 768's relL2=2.69e-2 a lone outlier, or a family? And is ~3e-4 the true
fp8-partial cost?

Sweeps inter_dim around 768 (plus 3 seeds x 2 M at 768 itself), recording the
dispatched stage-2 kernel so severity can be correlated with variant rather
than with inter_dim alone.
"""
import gc, io, os, re, contextlib, statistics
import torch, aiter
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, fused_topk
from aiter.ops.shuffle import shuffle_weight

MD, E, TOPK = 6144, 129, 5

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
        h  = re.findall(r"kn2='([^']+)'", buf.getvalue())
        return o.float(), (k2[-1] if k2 else (h[-1] if h else "?"))
    finally:
        if old is None: os.environ.pop("AITER_FLYDSL_STAGE2_FP8", None)
        else: os.environ["AITER_FLYDSL_STAGE2_FP8"] = old

def one(M, ID, seed):
    t = build(M, ID, seed)
    b, _  = call(t, False)
    p, k2 = call(t, True)
    bb = int((~torch.isfinite(b)).sum()); pb = int((~torch.isfinite(p)).sum())
    rel = float((p-b).norm()/b.norm()) if (bb == 0 and pb == 0) else float('nan')
    tag = re.sub(r"^flydsl_moe2(_layout)?_afp4_wfp4_bf16_", "", k2)
    del t, b, p
    gc.collect(); torch.cuda.empty_cache()
    return pb, rel, tag

print("PART 1 -- sweep around 768 (M=4096, seed 0)\n")
print(f"{'inter':>6} {'bad':>9} {'relL2':>11} {'level':>8}  kernel2")
print("-"*88)
for ID in (640, 704, 768, 832, 896, 1152, 1280, 1536):
    try:
        pb, rel, tag = one(4096, ID, 0)
        lvl = "GARBAGE" if pb else ("HIGH" if rel > 5e-3 else "low")
        print(f"{ID:>6} {pb:>9,} {rel:>11.3e} {lvl:>8}  {tag[:44]}")
    except Exception as ex:
        print(f"{ID:>6}   EXC {type(ex).__name__}: {str(ex)[:50]}")

print("\nPART 2 -- is 768's value stable? (3 seeds x 2 M)\n")
print(f"{'M':>6} {'seed':>5} {'bad':>7} {'relL2':>11}  kernel2")
print("-"*72)
vals = []
for M in (4096, 8192):
    for seed in (0, 1, 2):
        try:
            pb, rel, tag = one(M, 768, seed)
            vals.append(rel)
            print(f"{M:>6} {seed:>5} {pb:>7,} {rel:>11.3e}  {tag[:40]}")
        except Exception as ex:
            print(f"{M:>6} {seed:>5}   EXC {type(ex).__name__}: {str(ex)[:40]}")
v = [x for x in vals if x == x]
if len(v) > 1:
    print(f"\n768 relL2: mean={statistics.mean(v):.4e} stdev={statistics.stdev(v):.2e} "
          f"-> {'STABLE (deterministic)' if statistics.stdev(v) < 0.05*statistics.mean(v) else 'VARIABLE'}")
