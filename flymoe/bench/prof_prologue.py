"""Run only the prologue (plan launches + quant + scale transpose) for rocprofv3 kernel traces.

rocprofv3 --kernel-trace --stats -d <dir> -o pro -- python bench/prof_prologue.py --I 384 --T 32768
"""
import argparse
import os
import sys

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, HERE)

from compare import table_cfg  # noqa: E402
from flymoe import moe  # noqa: E402
from tests.test_moe import make_problem  # noqa: E402

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, default=384)
    ap.add_argument("--T", type=int, nargs="+", default=[32768])
    ap.add_argument("--iters", type=int, default=20)
    ap.add_argument("--table", default=os.path.join(HERE, "..", "configs", "tiles_v4_I{I}.json"))
    a = ap.parse_args()
    for T in a.T:
        x, ids, w, wts = make_problem(T, a.I)
        r = moe.MoERun(x, ids, w, moe.MoEWeights(*wts),
                       **table_cfg(a.table, a.I, T))
        r.forward()
        torch.cuda.synchronize()
        for _ in range(a.iters):
            r.prologue()
        torch.cuda.synchronize()
