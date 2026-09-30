"""Serial stage-1 config sweep for one (I, T) cell (round 5).

Every arm uses the table cell's config with the stage-1 config replaced (bare keys) or
single stage-1 / global entries overridden (keys ending in 1, e.g. diag1=...). Gate: the
arm's stage-1 outputs (h_q, h_s: the fp4 h rows and their e8m0 scales, in (token, slot)
order) must be byte-identical to the table arm's (every stage-1 variant accumulates K in the
same order), and the final
output must match. Then all gated arms are timed round-robin per stage (medians).

usage: python bench/s1_sweep.py --I 1536 --T 32768 --arms "BM=256,NW=4,WM=2,pipe=il4,D=4,EF=1"
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
    kv = [p.split("=") for p in spec.split(",") if p]
    bare = any(not (k in GLOBAL or k[-1] in "12") for k, _ in kv)
    c = dict(base)
    if bare:
        c = {k: v for k, v in base.items() if not k.endswith("1") or k in GLOBAL}
        c.pop("TB1", None)
    for k, v in kv:
        v = int(v) if v.lstrip("-").isdigit() else v
        c[k if (k in GLOBAL or k[-1] in "12") else f"{k}1"] = v
    return c


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, required=True)
    ap.add_argument("--T", type=int, required=True)
    ap.add_argument("--table", default=os.path.join(HERE, "..", "configs", "tiles_v5_I{I}.json"))
    ap.add_argument("--arms", nargs="+", required=True)
    ap.add_argument("--reps", type=int, default=5)
    ap.add_argument("--notime", action="store_true", help="correctness gate only")
    ap.add_argument("--knockout", action="store_true",
                    help="also time gate-rejected arms (diagnostic knock-outs; never shippable)")
    ap.add_argument("--out")
    a = ap.parse_args()
    x, ids, w, wts = make_problem(a.T, a.I)
    W = moe.MoEWeights(*wts)
    base = table_cfg(a.table, a.I, a.T)
    cfgs = {"table": base}
    for s in a.arms:
        cfgs[s] = arm_cfg(base, s)
    runs, ref, gate = {}, None, {}
    for n, c in cfgs.items():
        try:
            r = moe.MoERun(x, ids, w, W, **c)
            r.forward()
            torch.cuda.synchronize()
        except Exception as e:  # noqa: BLE001
            print(f"SKIP {n}: {type(e).__name__}: {str(e)[:160]}", flush=True)
            continue
        # The plan's row order inside an expert is not fixed run to run: compare h in
        # (token, slot) order through inv.
        inv = r.inv.long()
        cur = (r.h_q[inv].clone(), r.h_s[inv].clone(), r.out.float().clone())
        if ref is None:
            ref = cur
        hq_bad = int((cur[0] != ref[0]).sum())
        hs_bad = int((cur[1] != ref[1]).sum())
        d = ((cur[2] - ref[2]).norm() / ref[2].norm()).item()
        ok = hq_bad == 0 and hs_bad == 0 and d == 0.0
        gate[n] = dict(hq_bad=hq_bad, hs_bad=hs_bad, rel_diff=d, ok=ok)
        print(f"{'OK    ' if ok else 'REJECT'} {n}: h_q mismatched bytes {hq_bad}, h_s {hs_bad}, out rel diff {d:.2e}",
              flush=True)
        if ok or a.knockout:
            runs[n] = r
    if a.notime or "table" not in runs:
        return
    names = list(runs)
    t = {n: {s: [] for s in STAGES} for n in names}
    for rep in range(a.reps):
        k = rep % len(names)
        for n in names[k:] + names[:k]:
            for s in STAGES:
                t[n][s].append(sample(getattr(runs[n], s), 10, False))
    med = {n: {s: statistics.median(v) for s, v in d.items()} for n, d in t.items()}
    b = med["table"]["stage1"]
    res = []
    for n in names:
        m = med[n]
        tot = sum(m[s] for s in STAGES)
        print(f"I={a.I:5d} T={a.T:6d} {n[:64]:64s} s1 {m['stage1']:7.1f} s2 {m['stage2']:7.1f} "
              f"total {tot:7.1f} | s1 {100 * (b - m['stage1']) / b:+5.1f}% vs table", flush=True)
        res.append(dict(I=a.I, T=a.T, arm=n, cfg=cfgs[n], median_us=m, total=tot, gate=gate[n],
                        src_hash=hw.SRC_HASH))
    if a.out:
        with open(a.out, "w") as f:
            json.dump(res, f, indent=1)


if __name__ == "__main__":
    main()
