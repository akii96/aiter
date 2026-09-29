"""Correctness of every tunable option (tails, diag paths, HT, FC, ...) vs the torch reference.

Checks both the whole-tensor rel_l2 and the worst single row, so a few corrupt rows
cannot hide in the global norm.  python tests/test_options.py [I ...]
"""
import os, sys
import torch
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from flymoe import moe, ref
from tests.test_moe import make_problem

PP = dict(BM1=256, NW1=8, WM1=2, pipe1="pingpong", D1=4, EF1=1, MV1=1)
H2 = dict(BM2=128, NW2=4, pipe2="hybrid2", D2=4)
A2 = dict(BM2=128, NW2=4, pipe2="async", D2=2)
CONFIGS = [
    dict(PP, **H2),
    dict(PP, **H2, diag1="skip"),
    dict(PP, **H2, diag1="ilm0"),
    dict(PP, **H2, diag1="uni"),
    dict(PP, **H2, diag2="nos2w"),
    dict(PP, **H2, diag2="nos2w+wpe3"),
    dict(PP, **A2, diag2="s2nt"),
    dict(PP, **A2, diag1="skip", diag2="skip+s2nt"),
    dict(PP, **H2, HT=1),
    dict(PP, **H2, FC=1),
    dict(PP, **A2, HT=1, FC=1, diag2="s2nt"),
    dict(PP, **H2, TB1=64),
    dict(PP, **A2, TB2=32),
    dict(PP, **H2, QAST=1),
    dict(PP, **H2, PERS1=1),
    dict(BM1=128, NW1=4, pipe1="async", D1=3, BM2=64, NW2=4, pipe2="regs", D2=2),
    dict(BM1=128, NW1=4, pipe1="async", D1=3, BM2=64, NW2=4, pipe2="regs", D2=2, HT=1, FC=1),
    dict(BM1=64, NW1=4, pipe1="async", D1=3, AST=0, BM2=32, NW2=2, pipe2="async", D2=2),
]


def worst_row(y, y_ref):
    d = (y.float() - y_ref.float()).norm(dim=1)
    return (d / y_ref.float().norm(dim=1).clamp_min(1e-30)).max().item()


def main():
    Is = [int(a) for a in sys.argv[1:]] or [384, 768, 1536]
    ok = True
    for I in Is:
        for T in (5, 300, 4097):
            x, ids, w, wts = make_problem(T, I)
            W = moe.MoEWeights(*wts)
            y_ref, _, _ = ref.moe_ref(x, ids, w, *wts)
            for cfg in CONFIGS:
                run = moe.MoERun(x, ids, w, W, **cfg)
                run.forward()
                y = run.forward()
                torch.cuda.synchronize()
                e, wr = ref.rel_l2(y, y_ref), worst_row(y, y_ref)
                good = e < 1e-2 and wr < 3e-2 and bool(torch.isfinite(y).all())
                ok &= good
                print(f"I={I} T={T} {cfg}: rel_l2={e:.2e} worst_row={wr:.2e} {'OK' if good else 'FAIL'}",
                      flush=True)
    print("ALL OK" if ok else "SOME FAILED")


if __name__ == "__main__":
    main()
