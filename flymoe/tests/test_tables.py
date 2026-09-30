"""Every shipped table cell, selected via configs.select_cfg, vs the torch reference.

Per cell (bucket b): T = b, b - 1 and a ragged T inside the bucket, uniform routing;
plus T = b with skewed routing (every token on experts 0..3 + shared).
python tests/test_tables.py [I ...] [--T b ...] [--sr even]
"""
import argparse
import os
import sys

import torch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from flymoe import configs, moe, ref  # noqa: E402
from tests.test_moe import make_problem  # noqa: E402
from tests.test_options import worst_row  # noqa: E402


def cases(b):
    ts = {b, max(1, b - 1)}
    if b > 32:
        ts.add(b // 2 + 37)
    return [(t, None) for t in sorted(ts)] + [(b, "one_expert")]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("I", type=int, nargs="*", default=[384, 768, 1536])
    ap.add_argument("--T", type=int, nargs="*")
    ap.add_argument("--sr", default="even")
    a = ap.parse_args()
    ok = True
    for I in a.I:
        for b in a.T or sorted(configs.load_table(I)):
            for T, skew in cases(b):
                assert configs.bucket(I, T) == b or T > b
                x, ids, w, wts = make_problem(T, I, skew=skew)
                kw = configs.select_cfg(I, T)
                y_ref, _, _ = ref.moe_ref(x, ids, w, *wts, even=a.sr == "even")
                run = moe.MoERun(x, ids, w, moe.MoEWeights(*wts), SR=a.sr, **kw)
                run.forward()
                y = run.forward()
                torch.cuda.synchronize()
                e, wr = ref.rel_l2(y, y_ref), worst_row(y, y_ref)
                good = e < 1e-2 and wr < 3e-2 and bool(torch.isfinite(y).all())
                ok &= good
                print(f"I={I} bucket={b} T={T} skew={skew} {kw}: rel_l2={e:.2e} worst_row={wr:.2e} "
                      f"{'OK' if good else 'FAIL'}", flush=True)
                del run, x, ids, w, wts, y_ref, y
                torch.cuda.empty_cache()
    print("ALL OK" if ok else "SOME FAILED")


if __name__ == "__main__":
    main()
