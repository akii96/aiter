"""Split-K + HT stage-1 check: compare h_t / h scales of a split arm against two unsplit runs
(the second unsplit run separates never-written bytes from real differences).

python bench/sk_ht_check.py --I 768 --T 2048 --diag1 sk2
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

ap = argparse.ArgumentParser()
ap.add_argument("--I", type=int, default=768)
ap.add_argument("--T", type=int, default=2048)
ap.add_argument("--diag1", default="sk2")
a = ap.parse_args()
x, ids, w, wts = make_problem(a.T, a.I)
W = moe.MoEWeights(*wts)
base = table_cfg(os.path.join(HERE, "..", "configs", "tiles_v5_I{I}.json"), a.I, a.T)
runs = {}
for n, d in (("ref", ""), ("ref2", ""), ("arm", a.diag1)):
    c = dict(base, diag1=d)
    r = moe.MoERun(x, ids, w, W, **c)
    r.h_q.fill_(0xAB if n != "ref2" else 0xCD)
    r.h_s.fill_(0xAB if n != "ref2" else 0xCD)
    r.forward()
    torch.cuda.synchronize()
    runs[n] = r
R, I = runs["ref"].R, a.I
for n in ("ref2", "arm"):
    dq = (runs[n].h_q != runs["ref"].h_q)
    ds = (runs[n].h_s != runs["ref"].h_s)
    print(f"{n}: h_q diff bytes {int(dq.sum())} / {dq.numel()}, h_s diff {int(ds.sum())} / {ds.numel()}, "
          f"out equal {bool(torch.equal(runs[n].out, runs['ref'].out))}")
    if int(dq.sum()):
        flat = dq.flatten().nonzero().flatten()
        print("  first diff byte offsets", flat[:8].tolist(), "rows (R-major 64 B / HT plane)",
              sorted(set(((flat % (R * 64)) // 64).tolist()))[:12])
