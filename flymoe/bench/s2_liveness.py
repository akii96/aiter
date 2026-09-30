"""Live-register profile of a compiled GEMM kernel's final ISA (round 4, A1).

Backward liveness over the ISA in program order (branches ignored: the stage-2 K loop
is straight-line), counting VGPRs and AGPRs separately. Not valid for PERS kernels, whose
dynamic tile loop has a back-edge, and returning atomics are treated as defining no register. At the peak-pressure
instruction, every live register is attributed to the opcode class of its reaching
definition, e.g. "global B load" (buffer_load_dwordx4 into VGPRs), "LDS read",
"MFMA acc". For hybrid2, each K step's B tile is 16 VGPRs, so
live "global B load" registers / 16 = B steps held in registers at the peak.

usage: python bench/s2_liveness.py --I 384 768 1536 --s2 BM=128,NW=4,pipe=hybrid2,D=4,diag=nos2w
"""
import argparse
import collections
import glob
import os
import re
import shutil

import occupancy  # sets the dump env before flydsl is imported

REG = re.compile(r"\b([va])(?:\[(\d+):(\d+)\]|(\d+)\b)")
NODEF = re.compile(r"^(buffer_store|global_store|ds_write|ds_store|buffer_atomic|global_atomic|s_|"
                   r"buffer_load\w*.*\blds\b|v_cmp|v_cmpx|v_readfirstlane|v_readlane|exp|scratch_store)")


def regs(tok):
    out = []
    for m in REG.finditer(tok):
        k = m.group(1)
        if m.group(4) is not None:
            out.append((k, int(m.group(4))))
        else:
            out += [(k, i) for i in range(int(m.group(2)), int(m.group(3)) + 1)]
    return out


def klass(op):
    if op.startswith("buffer_load") or op.startswith("global_load"):
        return "global B/scale load"
    if op.startswith("ds_read") or op.startswith("ds_load"):
        return "LDS read"
    if op.startswith("v_mfma"):
        return "MFMA acc"
    if op.startswith("v_accvgpr"):
        return "acc copy"
    if op.startswith("scratch_load"):
        return "spill reload"
    return "VALU/other"


def parse(path):
    ins = []
    for line in open(path):
        line = line.split(";")[0].strip()
        if not line or line.endswith(":") or line.startswith("."):
            continue
        op, _, rest = line.partition(" ")
        ops = [o.strip() for o in rest.split(",")] if rest else []
        if NODEF.match(line) or not ops:
            d, u = [], regs(rest)
        else:
            d, u = regs(ops[0]), regs(",".join(ops[1:]))
        ins.append((op, d, u))
    return ins


def profile(path):
    ins = parse(path)
    live = set()
    press = [0] * len(ins)
    lives = [None] * len(ins)
    for i in range(len(ins) - 1, -1, -1):
        op, d, u = ins[i]
        live -= set(d)
        live |= set(u)
        press[i] = sum(1 for k, _ in live if k == "v") + sum(1 for k, _ in live if k == "a")
        lives[i] = frozenset(live)
    pk = max(range(len(ins)), key=lambda i: press[i])
    # reaching definition class for each live register at the peak
    last_def = {}
    for i in range(pk):
        for r in ins[i][1]:
            last_def[r] = klass(ins[i][0])
    cls = collections.Counter(last_def.get(r, "kernel arg/undef") for r in lives[pk])
    nb_loads = sum(1 for op, d, _ in ins if op.startswith("buffer_load_dwordx4") and d)
    return dict(n=len(ins), peak=press[pk], at=pk, op=ins[pk][0], cls=cls, b_x4_loads=nb_loads)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, nargs="+", default=[384, 768, 1536])
    ap.add_argument("--s1", default="BM=128,NW=4,pipe=async,D=3")
    ap.add_argument("--s2", nargs="+", default=["BM=128,NW=4,pipe=hybrid2,D=4,diag=nos2w"])
    ap.add_argument("--extra", default="", help="global MoERun kwargs, e.g. HT=1")
    a = ap.parse_args()
    extra = occupancy.kv(a.extra) if a.extra else {}
    for I, s2 in [(I, s2) for s2 in a.s2 for I in a.I]:
        for d in glob.glob(os.path.join(occupancy.DUMP, "flymoe_s*")):
            shutil.rmtree(d, ignore_errors=True)
        rows = occupancy.probe(I, occupancy.kv(a.s1), occupancy.kv(s2), extra=extra)
        for d in sorted(glob.glob(os.path.join(occupancy.DUMP, "flymoe_s2_*"))):
            isa = glob.glob(os.path.join(d, "*final_isa.s"))
            if not isa:
                continue
            info = dict(rows)[os.path.basename(d)]
            p = profile(isa[0])
            b = p["cls"].get("global B/scale load", 0)
            print(f"I={I:5d} {os.path.basename(d)[:64]:64s} vgpr={info['vgpr']:3d} agpr={info['agpr']:3d} "
                  f"spill v{info['vspill']}/s{info['sspill']} scratch={info['scratch']} | ISA peak live={p['peak']} at #{p['at']}/{p['n']} ({p['op']}) "
                  f"| global-load regs live={b} (~{b / 16:.1f} B steps) | {dict(p['cls'])} "
                  f"| dwordx4 VGPR loads={p['b_x4_loads']}", flush=True)


if __name__ == "__main__":
    main()
