"""Build configs/tiles_v7 from tiles_v6 through the two round-6 pick passes (bench/v7_sweeps.py).

  --pass 1: tiles_v6  + r6_v7p1_* (s1_sweep)  -> tiles_v7a   ranked on stage 1
  --pass 2: tiles_v7a + r6_v7p2_* (s2_sweep)  -> tiles_v7    ranked on stage 2 + combine (+ stage 1
                                                              when the arm changes HT, which moves
                                                              stage 1's h layout)

Same rules as make_tiles_v6.py: every sweep times the table cell twice (table, table_null). An arm
replaces the cell only if its gain on the ranked stages beats max(--min-gain, 3 x the null arm's
|gain|) and no timed mode loses more than --max-loss. Only gated arms timed with the current kernel
sources (SRC_HASH as flymoe/hw.py computes it) are eligible; a sweep file with any other hash
aborts. Cells without a sweep file are copied unchanged.
"""
import argparse
import glob
import hashlib
import json
import os
import pathlib

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
SRC = pathlib.Path(ROOT) / "flymoe"
SRC_HASH = hashlib.sha1(b"".join(
    (SRC / f).read_bytes() for f in ("hw.py", "gemm.py", "prologue.py", "combine.py"))).hexdigest()[:8]
IO = {1: ("tiles_v6", "tiles_v7a"), 2: ("tiles_v7a", "tiles_v7")}
GLOBAL_KEYS = ("HT", "FC", "TB1", "TB2", "QAST", "epi", "QP", "QF", "CF",
               "BMF", "NWF", "DF", "pipeF", "diagF", "WMF", "GMF")


def split_cfg(c):
    s1 = {k[:-1]: v for k, v in c.items() if k.endswith("1") and k not in GLOBAL_KEYS}
    s2 = {k[:-1]: v for k, v in c.items() if k.endswith("2") and k not in GLOBAL_KEYS}
    g = {k: v for k, v in c.items() if k in GLOBAL_KEYS and v not in (None, 0, "")}
    return s1, s2, g


def metric(p, r, with_s1=False):
    if p == 3:
        return r["fwd_us"]
    m = r["median_us"]
    if p == 1:
        return m["stage1"]
    return m["stage2"] + m["combine"] + (m["stage1"] if with_s1 else 0.0)


def gated(r):
    return r.get("gated", r.get("gate", {}).get("ok", False))


def gains(p, path):
    rs = json.load(open(path))
    for r in rs:
        if r.get("src_hash") != SRC_HASH:
            raise SystemExit(f"{path}: arm '{r['arm']}' timed on sources {r.get('src_hash')}, need {SRC_HASH}")
    by = {r["arm"]: r for r in rs}
    t, tn = by["table"], by["table_null"]
    null = abs(metric(p, t) - metric(p, tn)) / metric(p, t)
    g = {}
    for n, r in by.items():
        if n in ("table", "table_null") or not gated(r):
            continue
        s1 = bool(r["cfg"].get("HT")) != bool(t["cfg"].get("HT"))
        base = metric(p, t, s1)
        g[n] = ((base - metric(p, r, s1)) / base, r)
    return g, null


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pass", dest="p", type=int, required=True, choices=(1, 2))
    ap.add_argument("--min-gain", type=float, default=0.015)
    ap.add_argument("--max-loss", type=float, default=0.005)
    a = ap.parse_args()
    src, dst = IO[a.p]
    for I in (384, 768, 1536):
        tab = json.load(open(os.path.join(ROOT, "configs", f"{src}_I{I}.json")))
        out = {}
        for T, cell in tab.items():
            files = sorted(glob.glob(os.path.join(HERE, "results", f"r6_v7p{a.p}_I{I}_T{T}.json")) +
                           glob.glob(os.path.join(HERE, "results", f"r6_v7p{a.p}_I{I}_T{T}_flush.json")))
            out[T] = cell
            if not files:
                continue
            per = [gains(a.p, f) for f in files]
            thr = max([a.min_gain] + [3 * nl for _, nl in per])
            best, top = None, None
            for arm in per[0][0]:
                gs = [g[arm][0] for g, _ in per if arm in g]
                if len(gs) != len(per):
                    continue
                mean = sum(gs) / len(gs)
                if top is None or mean > top[0]:
                    top = (mean, arm)
                if min(gs) < -a.max_loss:
                    continue
                if best is None or mean > best[0]:
                    best = (mean, arm, per[0][0][arm][1], gs)
            nulls = "/".join(f"{100 * nl:.1f}" for _, nl in per)
            if best and best[0] > thr:
                mean, arm, r, gs = best
                s1, s2, g = split_cfg(r["cfg"])
                modes = " / ".join(f"{100 * x:+.1f}%" for x in gs)
                out[T] = {"s1": s1, "s2": s2, "global": g,
                          "note": f"r6 pass {a.p}: arm '{arm}' {modes} vs the {src} cell in-run "
                                  f"(null {nulls}%), {os.path.basename(files[0])}"}
                print(f"I={I:5d} T={T:>6s} {modes:>17s}  null {nulls:>9s}%  {arm}")
            else:
                why = f"best {100 * top[0]:+.1f}% {top[1]}" if top else "no gated arm"
                print(f"I={I:5d} T={T:>6s} keep {src} ({why}; threshold {100 * thr:.1f}%, null {nulls}%)")
        with open(os.path.join(ROOT, "configs", f"{dst}_I{I}.json"), "w") as fh:
            json.dump(out, fh, indent=1)


if __name__ == "__main__":
    main()
