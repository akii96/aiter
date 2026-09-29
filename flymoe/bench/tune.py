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
    dict(BM=16, NW=1, pipe="async", D=4),
    dict(BM=32, NW=1, pipe="async", D=4),
    dict(BM=32, NW=2, pipe="async", D=4),
    dict(BM=64, NW=2, pipe="async", D=3),
    dict(BM=64, NW=4, pipe="async", D=3),
    dict(BM=128, NW=4, pipe="async", D=3),
    dict(BM=256, NW=4, pipe="async", D=3),
]
S2 = [
    dict(BM=16, NW=1, pipe="async", D=2),
    dict(BM=32, NW=2, pipe="async", D=2),
    dict(BM=64, NW=4, pipe="async", D=2),
    dict(BM=64, NW=4, pipe="regs", D=2),
    dict(BM=128, NW=4, pipe="regs", D=2),
    dict(BM=128, NW=4, pipe="async", D=2),
    dict(BM=256, NW=4, pipe="regs", D=2),
]
BUCKETS = [32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768]


def tune(I, buckets):
    out = {}
    for T in buckets:
        x, ids, w, W = get_problem(T, I)
        res1, res2 = [], []
        for c in S1:
            if c["BM"] > 16 * max(1, (T * 5) // 129) * 8 and c["BM"] > 64:
                continue
            run = moe.MoERun(x, ids, w, W, BM1=c["BM"], BM2=c["BM"], D1=c["D"], pipe1=c["pipe"], NW1=c["NW"])
            run.prologue()
            res1.append((timeit(run.stage1), c))
        for c in S2:
            if c["BM"] > 16 * max(1, (T * 5) // 129) * 8 and c["BM"] > 64:
                continue
            run = moe.MoERun(x, ids, w, W, BM1=c["BM"], BM2=c["BM"], D2=c["D"], pipe2=c["pipe"], NW2=c["NW"])
            run.prologue()
            run.stage1()
            res2.append((timeit(run.stage2), c))
        b1 = min(res1, key=lambda r: r[0])
        b2 = min(res2, key=lambda r: r[0])
        c1, c2 = b1[1], b2[1]
        run = moe.MoERun(x, ids, w, W, BM1=c1["BM"], BM2=c2["BM"], D1=c1["D"], D2=c2["D"],
                         pipe1=c1["pipe"], pipe2=c2["pipe"], NW1=c1["NW"], NW2=c2["NW"])
        tp = timeit(run.prologue)
        run.prologue()
        run.stage1()
        run.stage2()
        tc = timeit(run.combine)
        out[T] = {"s1": b1[1], "s2": b2[1],
                  "us": {"prologue": tp, "s1": b1[0], "s2": b2[0], "combine": tc,
                         "total": tp + b1[0] + b2[0] + tc}}
        print(f"I={I} T={T:6d} s1 {b1[0]:8.1f}us {b1[1]} | s2 {b2[0]:8.1f}us {b2[1]} | pro {tp:6.1f} comb {tc:6.1f}"
              f" | total {tp + b1[0] + b2[0] + tc:8.1f}us", flush=True)
    return out


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, required=True)
    ap.add_argument("--T", type=int, nargs="+", default=BUCKETS)
    a = ap.parse_args()
    res = tune(a.I, a.T)
    os.makedirs(os.path.join(os.path.dirname(__file__), "..", "configs"), exist_ok=True)
    path = os.path.join(os.path.dirname(__file__), "..", "configs", f"tiles_I{a.I}.json")
    with open(path, "w") as f:
        json.dump(res, f, indent=1)
    print("wrote", path)
