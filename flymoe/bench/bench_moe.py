"""Kernel timing for flymoe stages per token bucket.

Median of `reps` CUDA-event measurements over `inner` back-to-back launches.
"""

import argparse
import os
import statistics
import sys

import torch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from flymoe import moe
from tests.test_moe import make_problem


def timeit(fn, inner=10, reps=7):
    fn()
    torch.cuda.synchronize()
    ts = []
    for _ in range(reps):
        s = torch.cuda.Event(enable_timing=True)
        e = torch.cuda.Event(enable_timing=True)
        s.record()
        for _ in range(inner):
            fn()
        e.record()
        torch.cuda.synchronize()
        ts.append(s.elapsed_time(e) * 1000 / inner)
    return statistics.median(ts)


_problems = {}


def get_problem(T, I):
    key = (T, I)
    if key not in _problems:
        _problems.clear()
        x, ids, w, wts = make_problem(T, I)
        _problems[key] = (x, ids, w, moe.MoEWeights(*wts))
    return _problems[key]


def bench(T, I, BM1=128, BM2=128, D1=3, D2=2, epi="rows", H=6144, E=129, quiet=False,
          pipe1="async", pipe2="regs", NW1=4, NW2=4):
    x, ids, w, W = get_problem(T, I)
    run = moe.MoERun(x, ids, w, W, BM1=BM1, BM2=BM2, D1=D1, D2=D2, epi=epi, pipe1=pipe1,
                     pipe2=pipe2, NW1=NW1, NW2=NW2)
    R = run.R
    tp = timeit(run.prologue)
    t1 = timeit(run.stage1)
    t2 = timeit(run.stage2)
    tc = timeit(run.combine) if epi == "rows" else 0.0
    fl1 = 2 * R * H * 2 * I
    fl2 = 2 * R * I * H
    if not quiet:
        print(f"T={T:6d} I={I:5d} s1[bm{BM1} w{NW1} {pipe1}{D1}] s2[bm{BM2} w{NW2} {pipe2}{D2}] {epi} | pro {tp:6.1f}"
              f" | s1 {t1:7.1f}us {fl1/t1/1e6:5.0f}TF | s2 {t2:7.1f}us {fl2/t2/1e6:5.0f}TF | comb {tc:6.1f}us"
              f" | gemm+comb {t1+t2+tc:7.1f}us | all {tp+t1+t2+tc:7.1f}us", flush=True)
    return tp, t1, t2, tc


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--T", type=int, nargs="+", default=[32, 256, 2048, 4096, 16384, 32768])
    ap.add_argument("--I", type=int, nargs="+", default=[384])
    ap.add_argument("--BM1", type=int, default=128)
    ap.add_argument("--BM2", type=int, default=128)
    ap.add_argument("--D1", type=int, default=3)
    ap.add_argument("--D2", type=int, default=2)
    ap.add_argument("--pipe1", default="async")
    ap.add_argument("--pipe2", default="regs")
    ap.add_argument("--NW1", type=int, default=4)
    ap.add_argument("--NW2", type=int, default=4)
    ap.add_argument("--epi", nargs="+", default=["rows"])
    a = ap.parse_args()
    for I in a.I:
        for T in a.T:
            for epi in a.epi:
                bench(T, I, a.BM1, a.BM2, a.D1, a.D2, epi, pipe1=a.pipe1, pipe2=a.pipe2, NW1=a.NW1, NW2=a.NW2)
