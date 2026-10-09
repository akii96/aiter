"""Correctness of tile/pipe/wave variants vs the torch reference."""
import os, sys
import torch
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from flymoe import moe, ref
from tests.test_moe import make_problem

VARIANTS = [
    dict(BM1=16, BM2=16, NW1=1, NW2=1, pipe1="async", pipe2="async", D1=4, D2=2),
    dict(BM1=32, BM2=32, NW1=1, NW2=2, pipe1="async", pipe2="async", D1=4, D2=2),
    dict(BM1=64, BM2=32, NW1=2, NW2=4, pipe1="async", pipe2="async", D1=3, D2=2),
    dict(BM1=128, BM2=64, NW1=4, NW2=4, pipe1="async", pipe2="regs", D1=3, D2=2),
    dict(BM1=256, BM2=128, NW1=4, NW2=4, pipe1="async", pipe2="regs", D1=3, D2=2),
]
ok = True
for I in (384, 1536):
    for T in (5, 300):
        x, ids, w, wts = make_problem(T, I)
        W = moe.MoEWeights(*wts)
        y_ref, _, _ = ref.moe_ref(x, ids, w, *wts)
        for v in VARIANTS:
            y = moe.flymoe_forward(x, ids, w, W, **v)
            torch.cuda.synchronize()
            e = ref.rel_l2(y, y_ref)
            good = e < 1e-2
            ok &= good
            print(f"I={I} T={T} {v}: {e:.3e} {'OK' if good else 'FAIL'}", flush=True)
print("ALL OK" if ok else "SOME FAILED")
