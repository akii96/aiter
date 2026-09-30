"""Build configs/tiles_v5_I{I}.json from tiles_v4 + the round-4 stage-2 sweeps.

For each (I, T) cell, every bench/results/r4_s2*_I{I}_T{T}.json sweep holds a "table" arm (the
v4 cell) and stage-2 arms timed round-robin in the same process. The best arm replaces the v4
stage-2 config (and HT / FC switches) only if it beat the table arm by more than --min-gain.
Stage 1 is left as in v4. The serial A/B vs flymoe-v4 (bench/compare.py) is the final check.
"""
import argparse
import glob
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
GLOBAL = ("HT", "FC", "TB1", "TB2", "QAST", "epi")


def split_cfg(c):
    s1 = {k[:-1]: v for k, v in c.items() if k.endswith("1") and k not in GLOBAL}
    s2 = {k[:-1]: v for k, v in c.items() if k.endswith("2") and k not in GLOBAL}
    g = {k: v for k, v in c.items() if k in GLOBAL}
    return s1, s2, g


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--min-gain", type=float, default=0.015)
    a = ap.parse_args()
    for I in (384, 768, 1536):
        v4 = json.load(open(os.path.join(ROOT, "configs", f"tiles_v4_I{I}.json")))
        out = {}
        for T, cell in v4.items():
            best = None
            for f in sorted(glob.glob(os.path.join(HERE, "results", f"r4_s2*_I{I}_T{T}.json"))):
                rs = json.load(open(f))
                base = next(r for r in rs if r["arm"] == "table")["total"]
                for r in rs:
                    if r["arm"] == "table":
                        continue
                    g = (base - r["total"]) / base
                    if best is None or g > best[0]:
                        best = (g, r, os.path.basename(f))
            new = dict(cell)
            if best and best[0] > a.min_gain:
                g, r, f = best
                s1, s2, glob_ = split_cfg(r["cfg"])
                new = {"s1": cell["s1"], "s2": s2, "global": glob_, "us": r["median_us"],
                       "note": f"r4: stage-2 arm '{r['arm']}' from {f}, {100 * g:+.1f}% vs the v4 cell in-run"}
                print(f"I={I:5d} T={T:>6s} {100 * g:+5.1f}%  {r['arm']}")
            else:
                print(f"I={I:5d} T={T:>6s} keep v4" + (f" (best {100 * best[0]:+.1f}% {best[1]['arm']})" if best else ""))
            out[T] = new
        with open(os.path.join(ROOT, "configs", f"tiles_v5_I{I}.json"), "w") as fh:
            json.dump(out, fh, indent=1)


if __name__ == "__main__":
    main()
