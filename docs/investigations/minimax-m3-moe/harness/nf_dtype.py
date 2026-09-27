"""Runtime proof of the stage-2 partial buffer dtype and size.

Intercepts the partial ("target") allocation in the a4w4 reduce path and
reports its actual dtype/nbytes, so the traffic claim rests on an observed
allocation rather than on reading the source.
"""
import os, torch, aiter
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, fused_topk

MD, E, TOPK = 6144, 129, 5
ID = int(os.environ.get("NF_ID", "384"))
M  = int(os.environ.get("NF_M", "16384"))
torch.manual_seed(0)
dev = "cuda"

inp = torch.randn((M, MD), dtype=dtypes.bf16, device=dev) * (8.0/(MD**0.5))
w1  = torch.randn((E, ID*2, MD), dtype=dtypes.bf16, device=dev) * (1.0/(MD**0.5))
w2  = torch.randn((E, MD, ID),  dtype=dtypes.bf16, device=dev) * (1.0/(ID**0.5))
score = torch.randn((M, E), dtype=dtypes.bf16, device=dev)
tw, tid = fused_topk(inp, score, TOPK, True)
tq = aiter.get_torch_quant(QuantType.per_1x32)
w1q, w1s = tq(w1, quant_dtype=dtypes.fp4x2)
w2q, w2s = tq(w2, quant_dtype=dtypes.fp4x2)
del w1, w2

# Intercept every sizeable empty/zeros allocation during the call.
allocs = []
_re, _rz = torch.empty, torch.zeros
def rec(kind, size, kwargs, out):
    try:
        if out.numel()*out.element_size() > (1<<20):
            allocs.append((kind, tuple(out.shape), str(out.dtype),
                           out.numel()*out.element_size()))
    except Exception: pass
def emp(*a, **k):
    o=_re(*a, **k); rec("empty", a, k, o); return o
def zer(*a, **k):
    o=_rz(*a, **k); rec("zeros", a, k, o); return o

torch.empty, torch.zeros = emp, zer
try:
    out = fused_moe(inp, w1q.view(E, ID*2, MD//2), w2q.view(E, MD, ID//2), tw, tid,
                    quant_type=QuantType.per_1x32,
                    w1_scale=w1s.view(E, ID*2, MD//32),
                    w2_scale=w2s.view(E, MD, ID//32),
                    activation=ActivationType.Swiglu,
                    doweight_stage1=False, swiglu_limit=7.0)
    torch.cuda.synchronize()
finally:
    torch.empty, torch.zeros = _re, _rz

print(f"M={M} inter_dim={ID} model_dim={MD} topk={TOPK}")
print(f"expected partial elems = M*topk*model_dim = {M*TOPK*MD:,}")
print(f"  if fp32 -> {M*TOPK*MD*4/1024**2:,.0f} MB")
print(f"  if bf16 -> {M*TOPK*MD*2/1024**2:,.0f} MB\n")
print(f"{'kind':>6} {'shape':>26} {'dtype':>16} {'MB':>10}")
print("-"*64)
for k, s, d, b in sorted(allocs, key=lambda x:-x[3])[:10]:
    print(f"{k:>6} {str(s):>26} {d:>16} {b/1024**2:>10,.1f}")
print(f"\nout dtype={out.dtype} finite={torch.isfinite(out).all().item()}")
