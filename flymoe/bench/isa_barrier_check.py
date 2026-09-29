"""ISA check: can an s_barrier be passed with this wave's ds_reads still in flight?

gfx950 barriers do not wait for LDS reads. If a wave's ds_reads of a ring slot are
still outstanding at the barrier after which another wave DMAs into that slot, the
read can observe the new data. For each s_barrier in the final ISA this reports the
number of LDS ops that may still be outstanding (linear scan; lgkmcnt(N) bounds the
count) and whether an LDS-DMA (buffer_load ... lds) follows before the next lgkm wait.

usage: python bench/isa_barrier_check.py --I 768 --s1 BM=256,NW=8,WM=2,pipe=pingpong,D=4,EF=1,MV=1 \
                                         --s2 BM=128,NW=4,pipe=hybrid2,D=4
"""
import argparse
import glob
import os
import re
import sys

import occupancy  # sets the dump env before flydsl is imported

LDS_OP = re.compile(r"^\s*(ds_read|ds_load|ds_write|ds_store|ds_bpermute|ds_swizzle|s_load|s_buffer_load)")
WAIT = re.compile(r"^\s*s_waitcnt\b.*lgkmcnt\((\d+)\)")
DMA = re.compile(r"^\s*buffer_load\w*.*\blds\b")


def check(path):
    lines = [l.split(";")[0] for l in open(path).read().splitlines()]
    out, pending, flagged = [], 0, 0
    for i, l in enumerate(lines):
        if LDS_OP.match(l):
            pending += 1
        m = WAIT.match(l)
        if m:
            pending = min(pending, int(m.group(1)))
        if re.match(r"^\s*s_barrier\b", l):
            dma_before_wait = False
            for l2 in lines[i + 1:]:
                if WAIT.match(l2) or re.match(r"^\s*s_barrier\b", l2):
                    break
                if DMA.match(l2):
                    dma_before_wait = True
                    break
            if pending and dma_before_wait:
                flagged += 1
                out.append((i + 1, pending))
    return sum(1 for l in lines if re.match(r"^\s*s_barrier\b", l)), flagged, out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, default=768)
    ap.add_argument("--s1", default="BM=256,NW=8,WM=2,pipe=pingpong,D=4,EF=1,MV=1")
    ap.add_argument("--s2", default="BM=128,NW=4,pipe=hybrid2,D=4")
    a = ap.parse_args()
    occupancy.probe(a.I, occupancy.kv(a.s1), occupancy.kv(a.s2))
    bad = 0
    for d in sorted(glob.glob(os.path.join(occupancy.DUMP, "flymoe_s[12]_*"))):
        isa = glob.glob(os.path.join(d, "*final_isa.s"))
        if not isa:
            continue
        n, f, where = check(isa[0])
        bad += f
        print(f"{os.path.basename(d)[:70]:70s} barriers={n:3d} ds_reads-in-flight-then-DMA={f}"
              + (f" at lines {where[:8]}" if where else ""))
    print("OK" if bad == 0 else f"{bad} barrier(s) can be passed with LDS reads outstanding before a DMA")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
