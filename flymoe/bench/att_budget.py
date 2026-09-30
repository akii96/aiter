"""Per-wave cycle budget from an ATT decode folder (rocprofv3 --att ui_output_*).

For every traced wave: prologue (wave start -> first MFMA), main loop (first -> last MFMA),
epilogue (last MFMA -> wave end), and the main loop's MFMA duty (n_mfma * 16 cycles / span,
16x16x128 fp4 = 16 cycles each). Also the loop's non-MFMA gaps attributed to the instruction
issued right before the late MFMA (per opcode, cycles per wave).

--tile-mfmas N: persistent kernels, N MFMAs per tile. Each wave is cut into tiles; the
budget is per tile: loop = the tile's first -> last MFMA, "between" = last MFMA of a tile ->
first MFMA of the next (epilogue + next prologue), plus the first tile's lead-in and the
last tile's tail.

usage: python bench/att_budget.py <ui_output dir> [--mfma-cycles 16] [--tile-mfmas N]
"""
import collections
import glob
import json
import statistics
import sys


def main():
    d = sys.argv[1]
    mc = int(sys.argv[sys.argv.index("--mfma-cycles") + 1]) if "--mfma-cycles" in sys.argv else 16
    tm = int(sys.argv[sys.argv.index("--tile-mfmas") + 1]) if "--tile-mfmas" in sys.argv else 0
    code = json.load(open(f"{d}/code.json"))["code"]
    text = {c[2]: c[0] for c in code}
    rows = []
    gaps = collections.Counter()
    ntiles = 0
    for f in sorted(glob.glob(f"{d}/se*_wv*.json")):
        w = json.load(open(f))["wave"]
        ins = w["instructions"]
        if not ins:
            continue
        mf = [i for i, x in enumerate(ins) if "mfma" in text.get(x[4], "")]
        if len(mf) < 2:
            continue
        t0, t1 = ins[0][0], ins[-1][0]
        chunks = [mf[k:k + tm] for k in range(0, len(mf), tm)] if tm else [mf]
        for c, ch in enumerate(chunks):
            a, b = ins[ch[0]][0], ins[ch[-1]][0]
            nxt = ins[chunks[c + 1][0]][0] if c + 1 < len(chunks) else t1
            rows.append(dict(pro=(a - t0) if c == 0 else 0, loop=b - a, epi=nxt - b, n=len(ch),
                             duty=len(ch) * mc / max(b - a, 1)))
            for p, q in zip(ch, ch[1:]):
                g = ins[q][0] - ins[p][0] - mc
                if g > 0:
                    op = text.get(ins[q - 1][4], "").split()[0] if q - 1 > p else "mfma->mfma"
                    gaps[op] += g
        ntiles += len(chunks)
    n = len(rows)
    med = {k: statistics.median(r[k] for r in rows) for k in ("pro", "loop", "epi", "n", "duty")}
    unit = "tiles" if tm else "waves"
    print(f"{n} {unit} | median cycles: prologue {med['pro']:.0f}  main loop {med['loop']:.0f}  "
          f"{'between tiles' if tm else 'epilogue'} {med['epi']:.0f} | MFMAs {med['n']:.0f}  "
          f"loop MFMA duty {100 * med['duty']:.1f}%")
    tot = sum(r["pro"] + r["loop"] + r["epi"] for r in rows)
    print(f"share of wave time: prologue {100 * sum(r['pro'] for r in rows) / tot:.1f}%  "
          f"loop {100 * sum(r['loop'] for r in rows) / tot:.1f}%  "
          f"{'between' if tm else 'epilogue'} {100 * sum(r['epi'] for r in rows) / tot:.1f}%")
    print(f"loop gaps beyond back-to-back MFMA, by the instruction before the late MFMA (cycles/{unit[:-1]}):")
    for op, g in gaps.most_common(12):
        print(f"  {op:36s} {g / n:9.0f}")


if __name__ == "__main__":
    main()
