"""Serial whole-forward sweep for one (I, T) cell (round 5, ST-2 fused small-T kernel).

Arms are the table cell with explicit overrides (k=v, keys as MoERun kwargs, e.g. BM1=16,BM2=16,
FZ=8). Gate: h_q / h_s in (token, slot) order and the final output byte-identical to the table
arm's. Timing: the whole forward() (prologue, stage 1, stage 2, combine) round-robin, warm (10
back-to-back) or flushed before every forward (--flush; FLYMOE_FLUSH=read for the clean flush),
so a fused launch is compared with the unfused sequence, not with per-stage flushed stages.

usage: python bench/st2_sweep.py --I 384 --T 32 --arms "BM1=16,BM2=16,FZ=8,pipe1=hybrid2,D1=4"
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

from compare import h_rows, sample, table_cfg  # noqa: E402
from flymoe import hw, moe  # noqa: E402
from tests.test_moe import make_problem  # noqa: E402


def arm_cfg(base, spec):
    c = dict(base)
    for p in spec.split(","):
        if not p:
            continue
        k, v = p.split("=", 1)
        c[k] = int(v) if v.lstrip("-").isdigit() else v
    return c


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, required=True)
    ap.add_argument("--T", type=int, required=True)
    ap.add_argument("--table", default=os.path.join(HERE, "..", "configs", "tiles_v5_I{I}.json"))
    ap.add_argument("--arms", nargs="+", required=True)
    ap.add_argument("--reps", type=int, default=7)
    ap.add_argument("--notime", action="store_true")
    ap.add_argument("--flush", action="store_true")
    ap.add_argument("--checks", type=int, default=3, help="forwards compared per arm (FZ re-arm)")
    ap.add_argument("--knockout", action="store_true", help="also time gate-rejected arms (never shippable)")
    ap.add_argument("--out")
    a = ap.parse_args()
    x, ids, w, wts = make_problem(a.T, a.I)
    W = moe.MoEWeights(*wts)
    base = table_cfg(a.table, a.I, a.T)
    cfgs = {"table": base, "table_null": dict(base)}
    for s in a.arms:
        cfgs[s] = arm_cfg(base, s)
    runs, ref, gate = {}, None, {}
    for n, c in cfgs.items():
        try:
            r = moe.MoERun(x, ids, w, W, **c)
            bad = None
            for _ in range(a.checks):
                r.forward()
                torch.cuda.synchronize()
                cur = h_rows(r) + (r.out.clone(),)
                if ref is None:
                    ref = cur
                b = (int((cur[0] != ref[0]).sum()), int((cur[1] != ref[1]).sum()),
                     int((cur[2].view(torch.int16) != ref[2].view(torch.int16)).sum()))
                bad = b if bad is None else tuple(max(p, q) for p, q in zip(bad, b))
        except Exception as e:  # noqa: BLE001
            print(f"SKIP {n}: {type(e).__name__}: {str(e)[:300]}", flush=True)
            continue
        ok = bad == (0, 0, 0)
        gate[n] = dict(hq_bad=bad[0], hs_bad=bad[1], out_bad=bad[2], ok=ok)
        print(f"{'OK    ' if ok else 'REJECT'} {n}: h_q / h_s / out mismatched {bad} over {a.checks} forwards",
              flush=True)
        if ok or a.knockout:
            runs[n] = r
    if a.notime or "table" not in runs:
        return
    names = list(runs)
    t = {n: [] for n in names}
    for rep in range(a.reps):
        k = rep % len(names)
        for n in names[k:] + names[:k]:
            t[n].append(sample(runs[n].forward, 10, a.flush))
    med = {n: statistics.median(v) for n, v in t.items()}
    b = med["table"]
    mode = ("flush-" + os.environ.get("FLYMOE_FLUSH", "write")) if a.flush else "warm"
    res = []
    for n in names:
        print(f"{mode:11s} I={a.I:5d} T={a.T:6d} {n[:72]:72s} fwd {med[n]:7.1f} | {100 * (b - med[n]) / b:+5.1f}%"
              f" vs table", flush=True)
        res.append(dict(I=a.I, T=a.T, arm=n, cfg=cfgs[n], fwd_us=med[n], mode=mode, gate=gate[n],
                        src_hash=hw.SRC_HASH))
    if a.out:
        with open(a.out, "w") as f:
            json.dump(res, f, indent=1)


if __name__ == "__main__":
    main()
