"""Final isolation: the corruption is a MEMORY-PRESSURE / allocator effect, not a
shape or flag effect.

nf_640.py built ONE tensor set per (shape, seed, flag) and freed it -> everything
clean, including 384 which corrupted in every earlier sweep.
Earlier sweeps kept several multi-GB sets alive across iterations -> corruption.

Arms (384, fp8 ON, same seed, PRESHUFFLED):
  isolated  : build, run, free.                      -> expect CLEAN
  pressure  : hold N extra weight sets alive, run.   -> expect CORRUPT
If corruption tracks VRAM pressure rather than shape, the defect is an
allocation/initialisation interaction, and every "shape-dependent" conclusion
from the earlier sweeps is confounded.
"""
import gc, os
import torch, aiter
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, fused_topk
from aiter.ops.shuffle import shuffle_weight

MD, E, TOPK = 6144, 129, 5
M, ID, SEED = 4096, 384, 0
SANE = 1e3
os.environ["AITER_FLYDSL_STAGE2_FP8"] = "1"

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
    return dict(x=x, tw=tw, ti=ti,
                w1q=shuffle_weight(w1q.view(E, ID*2, MD//2), layout=(16, 16)),
                w2q=shuffle_weight(w2q.view(E, MD, ID//2),  layout=(16, 16)),
                w1s=w1s.view(E, ID*2, MD//32), w2s=w2s.view(E, MD, ID//32))

def run(t):
    o = fused_moe(t["x"], t["w1q"], t["w2q"], t["tw"], t["ti"],
                  quant_type=QuantType.per_1x32,
                  w1_scale=t["w1s"], w2_scale=t["w2s"],
                  activation=ActivationType.Swiglu,
                  doweight_stage1=False, swiglu_limit=7.0)
    torch.cuda.synchronize()
    f = torch.isfinite(o); nb = int((~f).sum())
    am = float(o[f].abs().max()) if int(f.sum()) else float('nan')
    return nb, am

def freeGB():
    return torch.cuda.mem_get_info()[0]/1024**3

print(f"inter_dim={ID} M={M} seed={SEED} fp8=ON  preshuffled\n")
print(f"{'arm':>22} {'freeGB':>8} {'non_finite':>11} {'absmax':>11}  verdict")
print("-"*70)

# isolated
t = build(ID, SEED)
nb, am = run(t)
print(f"{'isolated':>22} {freeGB():>8.1f} {nb:>11,} {am:>11.3e}  "
      f"{'OK' if nb==0 and am<SANE else '*** CORRUPT ***'}")
del t; gc.collect(); torch.cuda.empty_cache()

# increasing pressure: hold extra live weight sets
for n in (1, 2, 4):
    held = [build(ID, SEED + 100 + i) for i in range(n)]
    t = build(ID, SEED)
    nb, am = run(t)
    print(f"{('pressure x%d' % n):>22} {freeGB():>8.1f} {nb:>11,} {am:>11.3e}  "
          f"{'OK' if nb==0 and am<SANE else '*** CORRUPT ***'}")
    del t, held; gc.collect(); torch.cuda.empty_cache()

# repeated calls on ONE set (the other earlier pattern)
t = build(ID, SEED)
for i in range(4):
    nb, am = run(t)
    print(f"{('repeat call %d' % i):>22} {freeGB():>8.1f} {nb:>11,} {am:>11.3e}  "
          f"{'OK' if nb==0 and am<SANE else '*** CORRUPT ***'}")
del t; gc.collect(); torch.cuda.empty_cache()
