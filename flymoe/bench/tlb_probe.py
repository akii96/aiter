"""Flushed small-T stage time: cold caches vs cold caches with warm address translation.

Arms per stage (v5 table cell, median of 15):
  warm      back-to-back launches
  flush     L2/MALL flushed (512 MB write) before the launch
  flush+tlb flushed, then one byte per page of the stage's weights touched in a separate launch
            (~3% of the bytes at 4 KB pages: warms the TLBs, not the data)
  rflush    flushed by reading 512 MB instead (caches full of clean lines)

python bench/tlb_probe.py --I 384 --T 32 [--page 4096]
"""
import argparse
import os
import statistics
import sys

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, HERE)

from compare import flush, table_cfg  # noqa: E402
from flymoe import moe  # noqa: E402
from tests.test_moe import make_problem  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("--I", type=int, required=True)
ap.add_argument("--T", type=int, required=True)
ap.add_argument("--page", type=int, default=4096)
ap.add_argument("--n", type=int, default=15)
a = ap.parse_args()
x, ids, w, wts = make_problem(a.T, a.I)
W = moe.MoEWeights(*wts)
r = moe.MoERun(x, ids, w, W, **table_cfg(os.path.join(HERE, "..", "configs", "tiles_v5_I{I}.json"), a.I, a.T))
r.forward()
torch.cuda.synchronize()
weights = {"stage1": (W.b1, W.bs1), "stage2": (W.b2, W.bs2)}
sink = torch.zeros(1, device="cuda")


_rbuf = torch.ones(512 * 1024 * 1024 // 4, dtype=torch.float32, device="cuda")


def rflush():
    """Read-only flush: evicts L2/MALL with clean lines (no dirty write-back left behind)."""
    sink.add_(_rbuf.sum())


def touch(ts):
    for t in ts:
        sink.add_(t.view(torch.uint8).view(-1)[::a.page].sum())


def timed(fn, pre):
    s, e = torch.cuda.Event(enable_timing=True), torch.cuda.Event(enable_timing=True)
    out = []
    for _ in range(a.n):
        pre()
        torch.cuda.synchronize()
        s.record()
        fn()
        e.record()
        torch.cuda.synchronize()
        out.append(s.elapsed_time(e) * 1000)
    return statistics.median(out)


for st in ("stage1", "stage2"):
    fn = getattr(r, st)
    res = {"warm": timed(fn, lambda: None),
           "flush": timed(fn, flush),
           "flush+tlb": timed(fn, lambda: (flush(), touch(weights[st]))),
           "rflush": timed(fn, rflush)}
    print(f"I={a.I:5d} T={a.T:5d} {st}: " + "  ".join(f"{k} {v:7.1f}" for k, v in res.items()), flush=True)
