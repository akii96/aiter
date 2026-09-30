"""A/B against a frozen FlyMoE tag, serial on one GPU, with a null arm.

Reference packages live in /workspace/flymoe_<ref>_pkg/ (module flymoe_<ref> plus
flymoe/configs/). Arms: ref, ref_null (identical second instance), cand (current
code). Arms run round-robin with the order rotated every rep; the reported value is
the median over `reps` samples. A delta counts only if it exceeds max(2 x null
spread, 2%).

--flush: before every timed launch sequence, write a 512 MB buffer so the 256 MB
MALL holds no weights (serving-like; small-T numbers are otherwise MALL-inflated).
Each stage is then timed per launch (inner=1) right after a flush.

usage:
  python bench/compare.py --ref v3 --table configs/tiles_v4_I{I}.json --I 384 1536 --T 4096 32768
  python bench/compare.py --ref v1 --flush --T 32 256
"""

import argparse
import importlib
import json
import os
import statistics
import sys

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))

from flymoe import moe  # noqa: E402
from tests.test_moe import make_problem  # noqa: E402

STAGES = ("prologue", "stage1", "stage2", "combine")
REF_TABLES = {"v1": "tiles_I{I}.json", "v3": "tiles_v3_I{I}.json", "v4pre": "tiles_v4_I{I}.json",
              "v4": "tiles_v4_I{I}.json"}
_flush_buf = None


def load_ref(ref):
    path = os.environ.get(f"FLYMOE_{ref.upper()}_PATH", f"/workspace/flymoe_{ref}_pkg")
    if path not in sys.path:
        sys.path.insert(0, path)
    return importlib.import_module(f"flymoe_{ref}.moe"), path


def table_cfg(path, I, T):
    with open(path.format(I=I)) as f:
        c = json.load(f)[str(T)]
    kw = {f"{k}1": v for k, v in c["s1"].items()}
    kw.update({f"{k}2": v for k, v in c["s2"].items()})
    for k, v in c.get("global", {}).items():
        kw[k] = v
    return kw


def flush():
    global _flush_buf
    if _flush_buf is None:
        _flush_buf = torch.empty(512 * 1024 * 1024 // 4, dtype=torch.float32, device="cuda")
    _flush_buf.fill_(1.0)


def sample(fn, inner, do_flush):
    s = torch.cuda.Event(enable_timing=True)
    e = torch.cuda.Event(enable_timing=True)
    if do_flush:
        tot = 0.0
        for _ in range(inner):
            flush()
            s.record()
            fn()
            e.record()
            torch.cuda.synchronize()
            tot += s.elapsed_time(e) * 1000
        return tot / inner
    s.record()
    for _ in range(inner):
        fn()
    e.record()
    torch.cuda.synchronize()
    return s.elapsed_time(e) * 1000 / inner


def compare(ref, ref_moe, ref_path, I, T, cand_cfg, reps=5, inner=10, do_flush=False, quiet=False):
    x, ids, w, wts = make_problem(T, I)
    ref_cfg = table_cfg(os.path.join(ref_path, "flymoe", "configs", REF_TABLES[ref]), I, T)
    arms = {
        "ref": ref_moe.MoERun(x, ids, w, ref_moe.MoEWeights(*wts), **ref_cfg),
        "ref_null": ref_moe.MoERun(x, ids, w, ref_moe.MoEWeights(*wts), **ref_cfg),
        "cand": moe.MoERun(x, ids, w, moe.MoEWeights(*wts), **cand_cfg),
    }
    outs = {}
    for name, r in arms.items():
        r.forward()
        r.forward()
        torch.cuda.synchronize()
        outs[name] = r.out.float().clone()
    diff = ((outs["cand"] - outs["ref"]).norm() / outs["ref"].norm()).item()
    names = list(arms)
    times = {n: {s: [] for s in STAGES} for n in names}
    for rep in range(reps):
        order = names[rep % 3:] + names[:rep % 3]
        for n in order:
            for s in STAGES:
                if not hasattr(arms[n], s):
                    times[n][s].append(0.0)
                    continue
                times[n][s].append(sample(getattr(arms[n], s), 1 if do_flush else inner, do_flush))
    med = {n: {s: statistics.median(times[n][s]) for s in STAGES} for n in names}
    for n in names:
        med[n]["total"] = sum(med[n][s] for s in STAGES)
    rt, nt, ct = med["ref"]["total"], med["ref_null"]["total"], med["cand"]["total"]
    noise = abs(rt - nt) / rt
    gain = (rt - ct) / rt
    thr = max(2 * noise, 0.02)
    flag = "WIN" if gain > thr else ("LOSS" if -gain > thr else "noise")
    if not quiet:
        m = med
        print(f"I={I:5d} T={T:6d} | {ref} {rt:8.1f} null {nt:8.1f} cand {ct:8.1f}us | "
              f"pro {m['ref']['prologue']:6.1f}->{m['cand']['prologue']:6.1f} "
              f"s1 {m['ref']['stage1']:7.1f}->{m['cand']['stage1']:7.1f} "
              f"s2 {m['ref']['stage2']:7.1f}->{m['cand']['stage2']:7.1f} "
              f"cb {m['ref']['combine']:6.1f}->{m['cand']['combine']:6.1f} | "
              f"gain {gain * 100:+5.1f}% noise {noise * 100:4.1f}% {flag} | diff {diff:.1e}", flush=True)
    return {"I": I, "T": T, "ref": ref, "cand_cfg": cand_cfg, "ref_cfg": ref_cfg, "rel_diff_vs_ref": diff, "median_us": med,
            "gain": gain, "noise": noise, "flag": flag}


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--ref", default="v3", choices=sorted(REF_TABLES))
    ap.add_argument("--I", type=int, nargs="+", default=[384, 1536])
    ap.add_argument("--T", type=int, nargs="+", default=[4096, 32768])
    ap.add_argument("--table", default="configs/tiles_v3_I{I}.json",
                    help="candidate tile table (current code)")
    ap.add_argument("--set", nargs="*", default=[], help="override candidate kwargs k=v")
    ap.add_argument("--flush", action="store_true")
    ap.add_argument("--reps", type=int, default=5)
    ap.add_argument("--out")
    a = ap.parse_args()
    ref_moe, ref_path = load_ref(a.ref)
    res = []
    for I in a.I:
        for T in a.T:
            c = table_cfg(a.table, I, T)
            for kv in a.set:
                k, v = kv.split("=")
                c[k] = int(v) if v.lstrip("-").isdigit() else v
            res.append(compare(a.ref, ref_moe, ref_path, I, T, c, reps=a.reps, do_flush=a.flush))
    if a.out:
        with open(a.out, "w") as f:
            json.dump(res, f, indent=1)
