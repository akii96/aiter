"""A/B against the frozen v1 (tag flymoe-v1), serial on one GPU, with a null arm.

Arms: v1 (v1 code + v1 tile table), v1_null (identical second instance of v1),
cand (current code + candidate config). Arms run round-robin with the order
rotated every rep; each sample is the mean over `inner` launches, and the
reported value is the median of `reps` samples. A candidate delta counts only if
it exceeds the |v1 - v1_null| spread for that cell.

v1 package: FLYMOE_V1_PATH (default /workspace/flymoe_v1_pkg) containing
flymoe_v1/ and flymoe/configs/tiles_I*.json.
"""

import argparse
import json
import os
import statistics
import sys

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
V1_PATH = os.environ.get("FLYMOE_V1_PATH", "/workspace/flymoe_v1_pkg")
sys.path.insert(0, V1_PATH)

import flymoe_v1.moe as v1moe  # noqa: E402

from flymoe import moe  # noqa: E402
from tests.test_moe import make_problem  # noqa: E402

STAGES = ("stage1", "stage2", "combine")


def v1_cfg(I, T):
    with open(os.path.join(V1_PATH, "flymoe", "configs", f"tiles_I{I}.json")) as f:
        c = json.load(f)[str(T)]
    s1, s2 = c["s1"], c["s2"]
    return dict(BM1=s1["BM"], NW1=s1["NW"], pipe1=s1["pipe"], D1=s1["D"],
                BM2=s2["BM"], NW2=s2["NW"], pipe2=s2["pipe"], D2=s2["D"])


def sample(fn, inner):
    s = torch.cuda.Event(enable_timing=True)
    e = torch.cuda.Event(enable_timing=True)
    s.record()
    for _ in range(inner):
        fn()
    e.record()
    torch.cuda.synchronize()
    return s.elapsed_time(e) * 1000 / inner


def compare(I, T, cand_cfg, reps=5, inner=10, quiet=False):
    x, ids, w, wts = make_problem(T, I)
    arms = {
        "v1": v1moe.MoERun(x, ids, w, v1moe.MoEWeights(*wts), **v1_cfg(I, T)),
        "v1_null": v1moe.MoERun(x, ids, w, v1moe.MoEWeights(*wts), **v1_cfg(I, T)),
        "cand": moe.MoERun(x, ids, w, moe.MoEWeights(*wts), **cand_cfg),
    }
    outs = {}
    for name, r in arms.items():
        r.forward()
        r.forward()
        torch.cuda.synchronize()
        outs[name] = r.out.float().clone()
    diff = ((outs["cand"] - outs["v1"]).norm() / outs["v1"].norm()).item()
    names = list(arms)
    times = {n: {s: [] for s in STAGES} for n in names}
    for rep in range(reps):
        order = names[rep % 3:] + names[:rep % 3]
        for n in order:
            for s in STAGES:
                times[n][s].append(sample(getattr(arms[n], s), inner))
    med = {n: {s: statistics.median(times[n][s]) for s in STAGES} for n in names}
    for n in names:
        med[n]["total"] = sum(med[n][s] for s in STAGES)
    res = {"I": I, "T": T, "cand_cfg": cand_cfg, "rel_diff_vs_v1": diff, "median_us": med}
    if not quiet:
        v1t, nt, ct = med["v1"]["total"], med["v1_null"]["total"], med["cand"]["total"]
        noise = abs(v1t - nt) / v1t
        gain = (v1t - ct) / v1t
        thr = max(2 * noise, 0.02)
        flag = "WIN" if gain > thr else ("LOSS" if -gain > thr else "noise")
        print(f"I={I:5d} T={T:6d} | v1 {v1t:8.1f} null {nt:8.1f} cand {ct:8.1f}us | "
              f"s1 {med['v1']['stage1']:7.1f}->{med['cand']['stage1']:7.1f} "
              f"s2 {med['v1']['stage2']:7.1f}->{med['cand']['stage2']:7.1f} | "
              f"gain {gain*100:+5.1f}% noise {noise*100:4.1f}% {flag} | diff {diff:.1e}", flush=True)
    return res


def cand_from_args(a, I, T):
    c = v1_cfg(I, T)
    for k in ("BM1", "NW1", "pipe1", "D1", "BM2", "NW2", "pipe2", "D2"):
        v = getattr(a, k)
        if v is not None:
            c[k] = v
    for kv in a.extra or []:
        k, v = kv.split("=")
        c[k] = type(c.get(k, 0))(v) if k in c else (int(v) if v.isdigit() else v)
    return c


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, nargs="+", default=[384, 1536])
    ap.add_argument("--T", type=int, nargs="+", default=[4096, 32768])
    for k in ("BM1", "NW1", "D1", "BM2", "NW2", "D2"):
        ap.add_argument(f"--{k}", type=int)
    ap.add_argument("--pipe1")
    ap.add_argument("--pipe2")
    ap.add_argument("--extra", nargs="*", help="extra MoERun kwargs k=v for new levers")
    ap.add_argument("--out")
    a = ap.parse_args()
    results = []
    for I in a.I:
        for T in a.T:
            results.append(compare(I, T, cand_from_args(a, I, T)))
    if a.out:
        with open(a.out, "w") as f:
            json.dump(results, f, indent=1)
