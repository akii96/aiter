"""D1: does the shared expert (T rows vs ~T/32 per routed expert) cause load imbalance?

Same R = 5T rows, two routings:
  shared : 4 routed (top-4 of 128) + the shared expert on every token (production)
  routed : 5 routed (top-5 of 128), shared expert unused
Stage 1 and stage 2 are timed per arm (round-robin, medians) with the table config for
the cell, FC off (FC needs the shared expert). If the shared expert's 32x-larger row
count created a tail, "shared" would be slower per row than "routed".

usage: python bench/d1_shared.py --I 384 768 1536 --T 32768
"""
import argparse
import os
import statistics
import sys

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, HERE)

from compare import sample, table_cfg  # noqa: E402
from flymoe import moe  # noqa: E402
from tests.test_moe import make_problem  # noqa: E402


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, nargs="+", default=[384, 768, 1536])
    ap.add_argument("--T", type=int, nargs="+", default=[32768])
    ap.add_argument("--table", default=os.path.join(HERE, "..", "configs", "tiles_v4_I{I}.json"))
    ap.add_argument("--reps", type=int, default=7)
    a = ap.parse_args()
    for I in a.I:
        for T in a.T:
            x, ids, w, wts = make_problem(T, I)
            g = torch.Generator(device="cuda").manual_seed(1)
            ids5 = torch.rand(T, 128, device="cuda", generator=g).topk(5, dim=-1).indices
            cfg = table_cfg(a.table, I, T)
            cfg.pop("FC", None)
            W = moe.MoEWeights(*wts)
            arms = {"shared": moe.MoERun(x, ids, w, W, **cfg),
                    "routed": moe.MoERun(x, ids5, w, W, **cfg)}
            for r in arms.values():
                r.forward()
            torch.cuda.synchronize()
            t = {n: {"stage1": [], "stage2": []} for n in arms}
            for rep in range(a.reps):
                for n in (list(arms) if rep % 2 == 0 else list(arms)[::-1]):
                    for s in ("stage1", "stage2"):
                        t[n][s].append(sample(getattr(arms[n], s), 10, False))
            m = {n: {s: statistics.median(v) for s, v in d.items()} for n, d in t.items()}
            print(f"I={I:5d} T={T:6d} | s1 shared {m['shared']['stage1']:7.1f} routed {m['routed']['stage1']:7.1f} "
                  f"({100 * (m['shared']['stage1'] / m['routed']['stage1'] - 1):+5.1f}%) | "
                  f"s2 shared {m['shared']['stage2']:7.1f} routed {m['routed']['stage2']:7.1f} "
                  f"({100 * (m['shared']['stage2'] / m['routed']['stage2'] - 1):+5.1f}%) | cfg {cfg}", flush=True)


if __name__ == "__main__":
    main()
