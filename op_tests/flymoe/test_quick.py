"""Quick correctness for one config: python tests/test_quick.py BM1=128,NW1=4,pipe1=hybrid2,D1=3 ..."""
import os, sys
import torch
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from flymoe import moe, ref
from tests.test_moe import make_problem

kw = {}
for arg in sys.argv[1:]:
    for part in arg.split(","):
        k, v = part.split("=")
        kw[k] = int(v) if v.isdigit() else v
ok = True
for I in (384, 1536):
    for T in (5, 700):
        x, ids, w, wts = make_problem(T, I)
        y_ref, _, _ = ref.moe_ref(x, ids, w, *wts)
        run = moe.MoERun(x, ids, w, moe.MoEWeights(*wts), **kw)
        run.forward()
        y = run.forward()
        torch.cuda.synchronize()
        e = ref.rel_l2(y, y_ref)
        ok &= e < 1e-2
        print(f"I={I} T={T} {kw}: rel_l2={e:.3e} {'OK' if e < 1e-2 else 'FAIL'}", flush=True)
print("ALL OK" if ok else "SOME FAILED")
