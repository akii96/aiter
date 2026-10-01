"""Round-6 pick sweeps for configs/tiles_v7 (large T only, two passes, each on the previous table).

  pass 1  stage 1          bench/s1_sweep.py on tiles_v6   -> make_tiles_v7.py --pass 1 -> tiles_v7a
  pass 2  stage 2 + comb.  bench/s2_sweep.py on tiles_v7a  -> make_tiles_v7.py --pass 2 -> tiles_v7

The arms are the round-6 verdicts (bench/results/r6_verdicts.log): s1tr (+ epgN) on the il4 stage-1
cells; s2tl / s2db on the il4 stage-2 cells; fcsk on every FC cell; il4 stage 2 + FC at I=768
T=32768 (S2-D re-pick). Every sweep adds a repeated table arm (table_null) and records SRC_HASH
and its gate. Timing: GPU 0 only, serially, under flock (run this script itself under
flock -n /tmp/gpu0_timing.lock). --notime --shard k/n compiles and gates on another GPU first.

usage: python bench/v7_sweeps.py --pass 1 [--I 384 768 1536] [--T ...] [--notime --shard 0/6]
"""
import argparse
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
TABLES = {1: "tiles_v6_I{I}.json", 2: "tiles_v7a_I{I}.json"}
SCRIPT = {1: "s1_sweep.py", 2: "s2_sweep.py"}
S2D = "BM=256,NW=4,WM=2,pipe=il4,D=3,PERS=1,HT=1,FC=1,pipeF=hybrid,BMF=128,NWF=4,WMF=1,DF=3"


def plus(diag, *toks):
    return "+".join(t for t in (diag or "").split("+") + list(toks) if t)


def arms(p, I, T, c):
    s1, s2, g = c["s1"], c["s2"], c.get("global", {})
    a = []
    if T < 4096:
        return a
    if p == 1:
        if s1["pipe"] == "il4":
            d = s1.get("diag")
            a += [f"diag1={plus(d, 's1tr')}"] + [f"diag1={plus(d, 's1tr', f'epg{n}')}" for n in (2, 4, 8)]
    else:
        fsk = f"diagF={plus(g.get('diagF'), 'fcsk')}" if g.get("FC") else ""
        if s2["pipe"] == "il4":
            d = s2.get("diag")
            for t in (("s2tl",), ("s2tl", "s2db")):
                a.append(f"diag2={plus(d, *t)}")
                if fsk:
                    a.append(f"diag2={plus(d, *t)},{fsk}")
        elif g.get("FC") and I == 768 and T == 32768:
            for d2 in ("s2nt", "s2nt+s2tl+s2db"):
                for dF in ("", "fcsk"):
                    a.append(f"{S2D},diag={d2},diagF={dF}")
        if fsk:
            a.append(fsk)
    return a


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pass", dest="p", type=int, required=True, choices=(1, 2))
    ap.add_argument("--I", type=int, nargs="+", default=[384, 768, 1536])
    ap.add_argument("--T", type=int, nargs="*", default=[])
    ap.add_argument("--notime", action="store_true")
    ap.add_argument("--shard", default="0/1")
    ap.add_argument("--reps", type=int, default=5)
    ap.add_argument("--list", action="store_true", help="print the arms only")
    a = ap.parse_args()
    k, n = map(int, a.shard.split("/"))
    jobs = []
    for I in a.I:
        tab = json.load(open(os.path.join(ROOT, "configs", TABLES[a.p].format(I=I))))
        for T, c in tab.items():
            if a.T and int(T) not in a.T:
                continue
            ar = arms(a.p, I, int(T), c)
            if ar:
                jobs.append((I, int(T), ar))
    for j, (I, T, ar) in enumerate(jobs):
        if j % n != k:
            continue
        if a.list:
            print(I, T, ar)
            continue
        out = os.path.join(HERE, "results", f"r6_v7p{a.p}_I{I}_T{T}.json")
        cmd = [sys.executable, os.path.join(HERE, SCRIPT[a.p]), "--I", str(I), "--T", str(T),
               "--table", os.path.join(ROOT, "configs", TABLES[a.p]), "--reps", str(a.reps), "--arms", *ar]
        cmd += ["--notime"] if a.notime else ["--out", out]
        print(f"== pass {a.p} I={I} T={T}: {len(ar)} arms", flush=True)
        subprocess.run(cmd, check=False)


if __name__ == "__main__":
    main()
