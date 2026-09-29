"""Stage-2 bisect across frozen package snapshots, timed round-robin in one process.

Each arm: name=/path/to/pkg_dir:module[:diag2]. The package dir holds the module
(a renamed copy of flymoe/flymoe at some commit). Stage 1 and the plan are identical
across arms; only stage 2 is timed.

usage: python bench/bisect_s2.py --I 384 --T 8192 v3=/workspace/bisect/v3:fm_v3 head=/workspace/aiter_fork/flymoe:flymoe:nos2w
"""
import argparse
import importlib
import statistics
import sys
import os

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
from tests.test_moe import make_problem  # noqa: E402
from compare import sample  # noqa: E402

S1 = dict(BM1=256, NW1=8, WM1=2, pipe1="pingpong", D1=4, EF1=1, MV1=1)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, default=384)
    ap.add_argument("--T", type=int, default=8192)
    ap.add_argument("--s2", default="BM2=128,NW2=4,pipe2=hybrid2,D2=4")
    ap.add_argument("--reps", type=int, default=7)
    ap.add_argument("arms", nargs="+")
    a = ap.parse_args()
    s2 = {k: (int(v) if v.isdigit() else v) for k, v in (p.split("=") for p in a.s2.split(","))}
    x, ids, w, wts = make_problem(a.T, a.I)
    runs, outs = {}, {}
    for arm in a.arms:
        name, spec = arm.split("=", 1)
        parts = spec.split(":")
        path, mod = parts[0], parts[1]
        diag2 = parts[2] if len(parts) > 2 else ""
        if path not in sys.path:
            sys.path.insert(0, path)
        m = importlib.import_module(f"{mod}.moe")
        cfg = dict(S1, **s2)
        if diag2:
            cfg["diag2"] = diag2
        r = m.MoERun(x, ids, w, m.MoEWeights(*wts), **cfg)
        r.forward()
        r.forward()
        torch.cuda.synchronize()
        runs[name], outs[name] = r, r.out.float().clone()
    names = list(runs)
    base = outs[names[0]]
    t = {n: [] for n in names}
    for rep in range(a.reps):
        for n in names[rep % len(names):] + names[:rep % len(names)]:
            t[n].append(sample(runs[n].stage2, 10, False))
    for n in names:
        d = ((outs[n] - base).norm() / base.norm()).item()
        print(f"I={a.I} T={a.T} {n:12s} stage2 {statistics.median(t[n]):8.1f}us "
              f"(min {min(t[n]):7.1f}) diff_vs_{names[0]} {d:.1e}", flush=True)


if __name__ == "__main__":
    main()
