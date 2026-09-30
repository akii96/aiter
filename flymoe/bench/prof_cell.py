"""Driver for rocprofv3 (ATT or counters) on one shipped table cell.

Builds MoERun from a table cell (optionally overridden with an s2_sweep-style arm spec),
warms up, then runs the whole pipeline `iters` times (each stage once per iteration).
Select the kernel with rocprofv3's --kernel-include-regex (flymoe_s1 / flymoe_s2 / ...).

python bench/prof_cell.py --I 1536 --T 32768 [--table configs/tiles_v5_I{I}.json]
       [--arm "BM=128,NW=4,pipe=hybrid2,D=2,diag=wpe2"] [--flush] [--iters 1]
"""

import argparse
import os
import sys

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, HERE)

from compare import STAGES, flush, table_cfg  # noqa: E402
from s2_sweep import arm_cfg  # noqa: E402
from flymoe import moe  # noqa: E402
from tests.test_moe import make_problem  # noqa: E402

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, required=True)
    ap.add_argument("--T", type=int, required=True)
    ap.add_argument("--table", default=os.path.join(HERE, "..", "configs", "tiles_v5_I{I}.json"))
    ap.add_argument("--arm", default="")
    ap.add_argument("--flush", action="store_true")
    ap.add_argument("--iters", type=int, default=1)
    a = ap.parse_args()
    x, ids, w, wts = make_problem(a.T, a.I)
    cfg = table_cfg(a.table, a.I, a.T)
    if a.arm:
        cfg = arm_cfg(cfg, a.arm)
    print("cfg", cfg, flush=True)
    r = moe.MoERun(x, ids, w, moe.MoEWeights(*wts), **cfg)
    for _ in range(2):
        r.forward()
    torch.cuda.synchronize()
    for _ in range(a.iters):
        for s in STAGES:
            if a.flush:
                flush()
                torch.cuda.synchronize()
            getattr(r, s)()
        torch.cuda.synchronize()
