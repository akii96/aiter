"""Round-5 pick sweeps for configs/tiles_v6 (three passes, each on the previous pass's table).

  pass 1  stage 1     bench/s1_sweep.py  on tiles_v5   -> make_tiles_v6.py --pass 1 -> tiles_v6a
  pass 2  stage 2     bench/s2_sweep.py  on tiles_v6a  -> make_tiles_v6.py --pass 2 -> tiles_v6b
  pass 3  forward     bench/st2_sweep.py on tiles_v6b  -> make_tiles_v6.py --pass 3 -> tiles_v6
          (QP / QF launch removal and the small-T hybrid2 pairs; warm, plus clean flush at T <= 256)

The arms are the round-5 verdicts (bench/results/r5_verdicts.log). Every sweep adds a repeated
table arm (table_null) and records SRC_HASH and its gate. Timing: GPU 0 only, serially, under
flock (run this script itself under flock -n /tmp/gpu0_timing.lock). --notime --shard k/n
compiles and gates on another GPU first (fills the JIT cache, nothing is timed).

usage: python bench/v6_sweeps.py --pass 1 [--I 384 768 1536] [--T ...] [--notime --shard 0/6]
"""
import argparse
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "..")
TABLES = {1: "tiles_v5_I{I}.json", 2: "tiles_v6a_I{I}.json", 3: "tiles_v6b_I{I}.json"}
SCRIPT = {1: "s1_sweep.py", 2: "s2_sweep.py", 3: "st2_sweep.py"}

IL4_S1 = "BM=256,NW=4,WM=2,pipe=il4,D=3,EF=1,diag=bar8,PERS=1"
S2D = "BM=256,NW=4,WM=2,pipe=il4,D=3,PERS=1,diag=s2nt,HT=1,FC=1,pipeF=hybrid,BMF=128,NWF=4,WMF=1,DF=3,diagF="
H2_16 = "BM1=16,NW1=1,pipe1=hybrid2,D1={d},BM2=16,NW2=1,pipe2=hybrid2,D2=2,diag2=nos2w"


def plus(diag, tok):
    return "+".join(t for t in (diag or "").split("+") + [tok] if t)


def arms(p, I, T, c):
    s1, s2, g = c["s1"], c["s2"], c.get("global", {})
    a = []
    if p == 1:
        if T >= 4096:
            a.append(IL4_S1)
        if T <= 256:
            a += ["BM=16,NW=1,pipe=hybrid2,D=4,EF=1,MV=1", "BM=16,NW=1,pipe=hybrid2,D=4,EF=1,MV=1,diag=s1st",
                  "BM=16,NW=1,pipe=hybrid2,D=8,EF=1,MV=1"]
        if not g.get("HT") and not s1.get("PERS"):
            st = plus(s1.get("diag"), "s1st")
            a.append(f"diag1={st}")
            if s1["pipe"] == "pingpong":
                a.append(f"diag1={st}+s1sd")
    elif p == 2:
        if s1["pipe"] == "il4" and ((I == 1536 and T >= 4096) or (I == 768 and T >= 8192)):
            a += [S2D, S2D.replace("diag=s2nt,", "diag=,"), S2D.replace("diagF=", "diagF=agf136")]
        if g.get("FC") and s2["pipe"] == "hybrid2" and "agf" not in s2.get("diag", ""):
            a.append(f"diag2={plus(s2.get('diag'), 'agf136')}")
        if (I == 768 and 256 <= T <= 8192) or (I == 1536 and 256 <= T <= 4096):
            a += ["BM=64,NW=4,pipe=hybrid2,D=2,diag=wpe3+s2nt+ag32", "BM=64,NW=4,pipe=hybrid2,D=2,diag=wpe3+s2nt+ag64",
                  "BM=32,NW=2,pipe=hybrid2,D=2,diag=wpe3+s2nt+ag32"]
        if T <= 256:
            a += ["BM=16,NW=1,pipe=hybrid2,D=2,diag=nos2w", "BM=16,NW=1,pipe=hybrid2,D=3,diag=nos2w",
                  "BM=16,NW=1,pipe=async,D=3,diag=nos2w"]
    else:
        a.append("QP=1")
        if T <= 256:
            p8, p2 = H2_16.format(d=8), H2_16.format(d=2)
            a += [p8, p8 + ",QP=1", p2 + ",QP=1"]
            if T <= 64:
                a.append(p8 + ",QF=1")
    return a


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pass", dest="p", type=int, required=True, choices=(1, 2, 3))
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
        modes = [False] + ([True] if a.p == 3 and T <= 256 and not a.notime else [])
        for fl in modes:
            out = os.path.join(HERE, "results", f"r5_v6p{a.p}_I{I}_T{T}{'_flush' if fl else ''}.json")
            cmd = [sys.executable, os.path.join(HERE, SCRIPT[a.p]), "--I", str(I), "--T", str(T),
                   "--table", os.path.join(ROOT, "configs", TABLES[a.p]), "--reps", str(a.reps), "--arms", *ar]
            cmd += ["--notime"] if a.notime else ["--out", out]
            env = dict(os.environ)
            if fl:
                cmd.append("--flush")
                env["FLYMOE_FLUSH"] = "read"
            print(f"== pass {a.p} I={I} T={T}{' flush' if fl else ''}: {len(ar)} arms", flush=True)
            subprocess.run(cmd, check=False, env=env)


if __name__ == "__main__":
    main()
