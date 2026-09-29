"""Driver for rocprofv3 counter collection on one stage config.

python bench/prof_stage.py --stage 1 --I 1536 --T 32768 --cfg BM=128,NW=4,pipe=hybrid2,D=3
Runs the stage `iters` times after warmup; wrap with
rocprofv3 --pmc <counters> --kernel-include-regex flymoe_s -d <dir> -o <name> -- python ...
"""

import argparse
import os
import sys

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))

from bench.bench_moe import get_problem  # noqa: E402
from bench.screen import kv  # noqa: E402
from flymoe import moe  # noqa: E402

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--stage", type=int, default=1)
    ap.add_argument("--I", type=int, default=1536)
    ap.add_argument("--T", type=int, default=32768)
    ap.add_argument("--cfg", required=True)
    ap.add_argument("--iters", type=int, default=3)
    a = ap.parse_args()
    c = kv(a.cfg)
    n = str(a.stage)
    kw = {(k if k in ("AST",) else f"{k}{n}"): v for k, v in c.items()}
    x, ids, w, W = get_problem(a.T, a.I)
    run = moe.MoERun(x, ids, w, W, **kw)
    run.prologue()
    if a.stage == 2:
        run.stage1()
    fn = run.stage1 if a.stage == 1 else run.stage2
    fn()
    torch.cuda.synchronize()
    for _ in range(a.iters):
        fn()
    torch.cuda.synchronize()
