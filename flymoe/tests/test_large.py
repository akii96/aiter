"""Large-T correctness: R*H*2 > 2^31 bytes (y_rows offsets must not overflow)."""
import os, sys
import torch
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from flymoe import moe, ref
from tests.test_moe import make_problem

T = int(sys.argv[1]) if len(sys.argv) > 1 else 40000
I = 384
x, ids, w, wts = make_problem(T, I)
y_ref, _, _ = ref.moe_ref(x, ids, w, *wts)
for cfg in (dict(BM1=256, NW1=8, WM1=2, pipe1="pingpong", D1=4, EF1=1, MV1=1, BM2=128, pipe2="hybrid2", D2=4),
            dict(BM1=64, NW1=4, pipe1="async", D1=3, BM2=64, NW2=4, pipe2="regs", D2=2)):
    run = moe.MoERun(x, ids, w, moe.MoEWeights(*wts), **cfg)
    run.forward()
    y = run.forward()
    torch.cuda.synchronize()
    e = ref.rel_l2(y, y_ref)
    print(f"T={T} R*H*2={T*5*6144*2/2**31:.2f}x2^31 {cfg['pipe1']}: rel_l2={e:.3e} {'OK' if e < 1e-2 else 'FAIL'}")
