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
from tests.test_options import worst_row
PP = dict(BM1=256, NW1=8, WM1=2, pipe1="pingpong", D1=4, EF1=1, MV1=1)
IL4 = dict(BM1=256, NW1=4, WM1=2, pipe1="il4", D1=3, EF1=1, diag1="bar8", PERS1=1)
for cfg in (dict(IL4, HT=1, BM2=256, NW2=4, WM2=2, pipe2="il4", D2=3, PERS2=1),
            dict(IL4, HT=1, BM2=256, NW2=4, WM2=2, pipe2="il4", D2=3, PERS2=1, diag2="s2nt",
                 FC=1, pipeF="hybrid", BMF=128, NWF=4, WMF=1, DF=3, diagF=""),
            dict(PP, BM2=128, pipe2="hybrid2", D2=2, diag2="wpe2+s2nt+agf136", FC=1),
            dict(PP, BM2=64, pipe2="hybrid2", D2=2, diag2="wpe3+s2nt+ag64"),
            dict(PP, BM2=64, pipe2="hybrid2", D2=3, diag2="wpe2+s2nt+pf+pfb", PERS2=2),
            dict(PP, BM2=64, pipe2="hybrid2", D2=2, diag2="wpe3+s2nt+pf+pfl", PERS2=3),
            dict(PP, BM2=128, pipe2="hybrid2", D2=4),
            dict(PP, diag1="sk2", BM2=128, pipe2="hybrid2", D2=4),
            dict(PP, BM2=128, pipe2="hybrid2", D2=4, diag2="nos2w"),
            dict(PP, BM2=128, pipe2="async", D2=2, HT=1, FC=1, diag2="s2nt"),
            dict(PP, BM2=64, pipe2="hybrid2", D2=2, diag2="wpe3+s2nt"),
            dict(PP, BM2=128, pipe2="hybrid2", D2=2, diag2="wpe2+s2nt", FC=1),
            dict(BM1=64, NW1=4, pipe1="async", D1=3, BM2=64, NW2=4, pipe2="regs", D2=2),
            dict(PP, BM2=128, pipe2="hybrid2", D2=4, QP=1),
            dict(PP, diag1="s1st+s1sd", BM2=128, pipe2="hybrid2", D2=4),
            dict(BM1=64, NW1=4, pipe1="hybrid2", D1=3, EF1=1, MV1=1, diag1="s1st", BM2=64, NW2=4,
                 pipe2="hybrid2", D2=2),
            dict(BM1=16, NW1=1, pipe1="hybrid2", D1=8, BM2=16, NW2=1, pipe2="hybrid2", D2=2, QP=1, CF=1),
            dict(BM1=16, NW1=1, pipe1="hybrid2", D1=8, BM2=16, NW2=1, pipe2="hybrid2", D2=2, QF=1, CF=1)):
    run = moe.MoERun(x, ids, w, moe.MoEWeights(*wts), **cfg)
    run.forward()
    y = run.forward()
    torch.cuda.synchronize()
    e, wr = ref.rel_l2(y, y_ref), worst_row(y, y_ref)
    good = e < 1e-2 and wr < 3e-2
    print(f"T={T} R*H*2={T*5*6144*2/2**31:.2f}x2^31 {cfg}: rel_l2={e:.3e} worst_row={wr:.2e} "
          f"{'OK' if good else 'FAIL'}", flush=True)
