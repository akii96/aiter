"""Fast screening of one stage across candidate configs (no v1 arms).

Winners are then confirmed with bench/compare_v1.py (null arm, round-robin).

usage: python bench/screen.py --stage 1 --I 1536 --T 4096 32768 \
           --cfg BM=128,NW=4,pipe=hybrid,D=3,GM=1 --cfg BM=128,NW=4,pipe=hybrid,D=3,GM=4
"""

import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))

from bench.bench_moe import get_problem, timeit  # noqa: E402
from flymoe import moe  # noqa: E402


def kv(s):
    d = {}
    for part in s.split(","):
        k, v = part.split("=")
        d[k] = int(v) if v.lstrip("-").isdigit() else v
    return d


GLOBAL = ("AST",)


def screen(stage, I, T, cfgs, reps=7, inner=10):
    x, ids, w, W = get_problem(T, I)
    out = []
    for c in cfgs:
        n = "1" if stage == 1 else "2"
        kw = {(k if k in GLOBAL else f"{k}{n}"): v for k, v in c.items()}
        other = "2" if stage == 1 else "1"
        kw.setdefault(f"BM{other}", c["BM"])
        kw.setdefault(f"MV{other}", 0)
        kw.setdefault(f"NW{other}", 4 if c["BM"] >= 64 else c.get("NW", 4))
        kw.setdefault(f"pipe{other}", "async")
        run = moe.MoERun(x, ids, w, W, **kw)
        run.prologue()
        if stage == 2:
            run.stage1()
        fn = run.stage1 if stage == 1 else run.stage2
        t = timeit(fn, inner=inner, reps=reps)
        out.append((t, c))
        print(f"s{stage} I={I:5d} T={T:6d} {c}: {t:8.1f}us", flush=True)
    return out


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--stage", type=int, default=1)
    ap.add_argument("--I", type=int, nargs="+", default=[1536])
    ap.add_argument("--T", type=int, nargs="+", default=[4096, 32768])
    ap.add_argument("--cfg", action="append", required=True)
    a = ap.parse_args()
    for I in a.I:
        for T in a.T:
            screen(a.stage, I, T, [kv(c) for c in a.cfg])
