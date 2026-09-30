"""Serial stage-2 config sweep for one (I, T) cell (round 4, Phase 1).

Every arm uses the table cell's stage-1 config and overrides the stage-2 config (and
optionally the global HT / FC switches). Each arm's output is gated against the table
arm (rel diff <= 1e-3; the fused-combine arms differ only in summation order), then all
arms are timed round-robin per stage; reports medians of stage1 / stage2 / combine /
total and the change of stage2+combine vs the table arm.

usage: python bench/s2_sweep.py --I 1536 --T 32768 \
         --arms "BM=128,NW=4,pipe=hybrid2,D=2,diag=nos2w+wpe2" "BM=64,NW=4,pipe=hybrid2,D=3,diag=nos2w+wpe3"
"""
import argparse
import json
import os
import statistics
import sys

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, HERE)

from compare import STAGES, sample, table_cfg  # noqa: E402
from flymoe import hw, moe  # noqa: E402
from tests.test_moe import make_problem  # noqa: E402

GLOBAL = ("HT", "FC", "TB1", "TB2", "QAST", "epi")


def arm_cfg(base, spec):
    """Bare keys (BM, pipe, ...) replace the whole stage-2 config (and drop the table's HT/FC/TB2);
    keys ending in 1 or 2 (diag1, D2, ...) and global keys override single entries."""
    kv = [p.split("=") for p in spec.split(",")]
    bare = any(not (k in GLOBAL or k[-1] in "12") for k, _ in kv)
    c = dict(base)
    if bare:
        c = {k: v for k, v in base.items() if not k.endswith("2") or k in GLOBAL}
        for g in ("HT", "FC", "TB2"):
            c.pop(g, None)
    for k, v in kv:
        v = int(v) if v.lstrip("-").isdigit() else v
        c[k if (k in GLOBAL or k[-1] in "12") else f"{k}2"] = v
    return c


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, required=True)
    ap.add_argument("--T", type=int, required=True)
    ap.add_argument("--table", default=os.path.join(HERE, "..", "configs", "tiles_v4_I{I}.json"))
    ap.add_argument("--arms", nargs="+", required=True)
    ap.add_argument("--reps", type=int, default=5)
    ap.add_argument("--out")
    ap.add_argument("--nogate", action="store_true", help="time diagnostic arms whose output is wrong")
    a = ap.parse_args()
    x, ids, w, wts = make_problem(a.T, a.I)
    W = moe.MoEWeights(*wts)
    base = table_cfg(a.table, a.I, a.T)
    cfgs = {"table": base}
    for s in a.arms:
        cfgs[s] = arm_cfg(base, s)
    runs, diffs, ref_out = {}, {}, None
    for n, c in cfgs.items():
        try:
            r = moe.MoERun(x, ids, w, W, **c)
            r.forward()
            torch.cuda.synchronize()
        except Exception as e:  # noqa: BLE001
            print(f"SKIP {n}: {type(e).__name__}: {str(e)[:120]}", flush=True)
            continue
        o = r.out.float()
        if ref_out is None:
            ref_out = o.clone()
        d = ((o - ref_out).norm() / ref_out.norm()).item()
        if not d <= 1e-3 and not a.nogate:
            print(f"REJECT {n}: rel diff {d:.2e} vs table arm", flush=True)
            continue
        runs[n] = r
        diffs[n] = d
    if "table" not in runs:
        raise SystemExit("the table arm failed to build; nothing to compare against")
    names = list(runs)
    t = {n: {s: [] for s in STAGES} for n in names}
    for rep in range(a.reps):
        k = rep % len(names)
        for n in names[k:] + names[:k]:
            for s in STAGES:
                t[n][s].append(sample(getattr(runs[n], s), 10, False) if hasattr(runs[n], s) else 0.0)
    med = {n: {s: statistics.median(v) for s, v in d.items()} for n, d in t.items()}
    b = med["table"]["stage2"] + med["table"]["combine"]
    res = []
    for n in names:
        m = med[n]
        s2cb = m["stage2"] + m["combine"]
        tot = sum(m[s] for s in STAGES)
        print(f"I={a.I:5d} T={a.T:6d} {n[:70]:70s} s1 {m['stage1']:7.1f} s2 {m['stage2']:7.1f} "
              f"cb {m['combine']:6.1f} total {tot:7.1f} | s2+cb {100 * (b - s2cb) / b:+5.1f}% vs table", flush=True)
        res.append(dict(I=a.I, T=a.T, arm=n, cfg=cfgs[n], median_us=m, total=tot, rel_diff=diffs[n],
                        gated=diffs[n] <= 1e-3, src_hash=hw.SRC_HASH))
    if a.out:
        with open(a.out, "w") as f:
            json.dump(res, f, indent=1)


if __name__ == "__main__":
    main()
