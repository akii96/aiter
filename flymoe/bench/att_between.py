"""Per-opcode budget of the region between tiles of a persistent kernel (ATT ui_output dir).

Region = last MFMA of a tile -> first MFMA of the next tile (epilogue + spread next-tile prologue).
For every instruction in the region: count per tile and the issue delay charged to it (its issue time
minus the previous instruction's), i.e. the time the wave waited before it could issue.

usage: python bench/att_between.py <ui_output dir> --tile-mfmas N [--top 30]
"""
import collections
import glob
import json
import sys


def main():
    d = sys.argv[1]
    tm = int(sys.argv[sys.argv.index("--tile-mfmas") + 1])
    top = int(sys.argv[sys.argv.index("--top") + 1]) if "--top" in sys.argv else 30
    code = json.load(open(f"{d}/code.json"))["code"]
    text = {c[2]: c[0] for c in code}
    cnt, cyc, big = collections.Counter(), collections.Counter(), collections.Counter()
    regions, span = 0, 0
    for f in sorted(glob.glob(f"{d}/se*_wv*.json")):
        ins = json.load(open(f))["wave"]["instructions"]
        mf = [i for i, x in enumerate(ins) if "mfma" in text.get(x[4], "")]
        chunks = [mf[k:k + tm] for k in range(0, len(mf), tm)]
        for c in range(len(chunks) - 1):
            a, b = chunks[c][-1], chunks[c + 1][0]
            regions += 1
            span += ins[b][0] - ins[a][0]
            for i in range(a + 1, b + 1):
                s = text.get(ins[i][4], "?")
                op = s.split()[0]
                dt = ins[i][0] - ins[i - 1][0]
                cnt[op] += 1
                cyc[op] += dt
                if dt >= 64:
                    big[(s, 10 * ((i - a) * 10 // max(b - a, 1)))] += dt
    if not regions:
        print("no between-tile regions")
        return
    print(f"{regions} regions, median-free mean span {span / regions:.0f} cycles; "
          f"{sum(cnt.values()) / regions:.0f} instructions per region")
    print(f"  {'opcode':36s} {'count':>7s} {'cycles':>8s} {'cyc/ins':>8s}")
    for op, g in cyc.most_common(top):
        print(f"  {op:36s} {cnt[op] / regions:7.1f} {g / regions:8.0f} {g / max(cnt[op], 1):8.1f}")
    print("largest single issue delays (mean per region, by instruction text, region position %):")
    for (s, pos), g in big.most_common(top // 2):
        print(f"  {g / regions:7.0f}  @{pos:3d}%  {s[:90]}")


if __name__ == "__main__":
    main()
