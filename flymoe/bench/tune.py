"""Per-bucket tile selection for stage 1 and stage 2 (independent kernels).

Writes configs/tiles_I{I}.json: {token_bucket: {"s1": cfg, "s2": cfg, "us": {...}}}.
"""

import argparse
import json
import os
import sys

import torch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from bench.bench_moe import get_problem, timeit
from flymoe import moe

S1 = [
    dict(BM=16, NW=1, pipe="async", D=4, EF=1, MV=1),
    dict(BM=32, NW=1, pipe="async", D=4, EF=1, MV=1),
    dict(BM=32, NW=2, pipe="async", D=4, EF=1, MV=1),
    dict(BM=64, NW=4, pipe="async", D=3, EF=1, MV=1),
    dict(BM=64, NW=4, pipe="hybrid2", D=3, EF=1, MV=1),
    dict(BM=128, NW=4, pipe="hybrid2", D=3, EF=1, MV=1),
    dict(BM=256, NW=8, WM=2, pipe="pingpong", D=4, EF=1, MV=1),
    dict(BM=256, NW=8, WM=2, pipe="pingpong", D=4, EF=1, MV=1, diag="skip"),
]
S2 = [
    dict(BM=16, NW=1, pipe="async", D=2),
    dict(BM=16, NW=1, pipe="async", D=2, diag="nos2w"),
    dict(BM=32, NW=2, pipe="async", D=2),
    dict(BM=64, NW=4, pipe="async", D=2),
    dict(BM=64, NW=4, pipe="hybrid", D=3),
    dict(BM=64, NW=4, pipe="regs", D=2, diag="nos2w"),
    dict(BM=128, NW=4, pipe="async", D=2, diag="nos2w"),
    dict(BM=128, NW=4, pipe="async", D=2, diag="s2nt"),
    dict(BM=128, NW=4, pipe="hybrid2", D=4),
    dict(BM=128, NW=4, pipe="hybrid2", D=4, diag="nos2w"),
]
GLOBALS = [dict(), dict(HT=True), dict(FC=True), dict(HT=True, FC=True)]
BUCKETS = [32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768]


def tune(I, buckets):
    out = {}
    for T in buckets:
        x, ids, w, W = get_problem(T, I)
        res1, res2 = [], []
        for c in S1:
            if c["BM"] > 16 * max(1, (T * 5) // 129) * 8 and c["BM"] > 64:
                continue
            run = moe.MoERun(x, ids, w, W, BM2=c["BM"] if c["BM"] <= 128 else 128, NW2=4 if c["BM"] >= 64 else 1,
                             pipe2="async", **{f"{k}1": v for k, v in c.items()})
            run.prologue()
            res1.append((timeit(run.stage1), c))
        for c in S2:
            if c["BM"] > 16 * max(1, (T * 5) // 129) * 8 and c["BM"] > 64:
                continue
            run = moe.MoERun(x, ids, w, W, BM1=c["BM"], NW1=4 if c["BM"] >= 64 else 1, pipe1="async",
                             **{f"{k}2": v for k, v in c.items()})
            run.prologue()
            run.stage1()
            res2.append((timeit(run.stage2), c))
        b1 = min(res1, key=lambda r: r[0])
        b2 = min(res2, key=lambda r: r[0])
        c1, c2 = b1[1], b2[1]
        # Global layout/fusion switches (HT: stage-1 h layout, FC: fused combine) change both
        # stages, so pick them on the full forward time with the chosen per-stage configs.
        best = None
        for g in GLOBALS:
            try:
                run = moe.MoERun(x, ids, w, W, **{f"{k}1": v for k, v in c1.items()},
                                 **{f"{k}2": v for k, v in c2.items()}, **g)
                parts = {n: timeit(getattr(run, n)) for n in ("prologue", "stage1", "stage2", "combine")}
            except AssertionError:
                continue
            tot = sum(parts.values())
            if best is None or tot < best[0]:
                best = (tot, g, parts)
        tot, g, parts = best
        out[T] = {"s1": c1, "s2": c2, "global": {k: (1 if v is True else v) for k, v in g.items()},
                  "us": {**parts, "total": tot}}
        print(f"I={I} T={T:6d} s1 {parts['stage1']:8.1f}us {c1} | s2 {parts['stage2']:8.1f}us {c2} | "
              f"global {g} | pro {parts['prologue']:6.1f} comb {parts['combine']:6.1f} | total {tot:8.1f}us",
              flush=True)
    return out


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, required=True)
    ap.add_argument("--T", type=int, nargs="+", default=BUCKETS)
    a = ap.parse_args()
    res = tune(a.I, a.T)
    os.makedirs(os.path.join(os.path.dirname(__file__), "..", "configs"), exist_ok=True)
    path = os.path.join(os.path.dirname(__file__), "..", "configs", f"tiles_v4_I{a.I}.json")
    with open(path, "w") as f:
        json.dump(res, f, indent=1)
    print("wrote", path)
