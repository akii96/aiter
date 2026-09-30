"""Per-kernel roofline for FlyMoE cells from a compare.py --out JSON (cand or ref arm).

Two floors per cell:
  current : the bytes today's dataflow must move (A gathered per row in stage 1,
            [R, H] bf16 expert rows written by stage 2 and re-read by combine, or the
            FC variant), max'ed with MFMA time.
  minimal : the least traffic an unfused two-GEMM schedule needs (x once, weights once,
            h written and re-read once, the final [T, H] output once, no expert rows),
            max'ed with MFMA time. A fused stage1+stage2 kernel would also drop h.
Memory time = read_bytes / BW_read + write_bytes / BW_write, with BW_read the measured
streaming read rate and BW_write the best measured write rate (streaming or the
stage-2-shaped row stores, bench/hbm_bw.py). MFMA time = FLOPs / the best measured MFMA
rate (bench/mfma_peak.py, 7.43 PF with constant scales).

These are HBM floors. The 256 MB MALL can serve a re-read whose working set fits, so a
cell can run above 100% of its floor; cells whose [R, H] bf16 expert rows fit in the MALL
are flagged "mall". At T <= 256 launch overhead (a few us per kernel) dominates the
small kernels, so their percentages say little.

Shape: MiniMax-M3 (H=6144, E=129 = 128 routed + 1 shared, k=5 incl. shared).
"""

import argparse
import json

H, E, K = 6144, 129, 5
SC = 1 + 1 / 16  # fp4 bytes + e8m0 scale bytes (1 per 32 values)
MALL = 256 << 20


def touched(T):
    """Expected distinct experts touched: 128 routed (4 of 128 per token) + shared."""
    return 128 * (1 - (1 - 4 / 128) ** T) + 1


def model(I, T, cfg, peak, bwr, bww):
    R = K * T
    Et = touched(T)
    fc = bool(cfg.get("FC"))
    x_bf16, xq = T * H * 2, T * H / 2 * SC
    w1 = Et * 2 * I * H / 2 * SC
    w2 = Et * H * I / 2 * SC
    hq = R * I / 2 * SC
    rows = R * H * 2
    routed_rows = (K - 1) * T * H * 2
    out = T * H * 2

    def t(rd, wr, fl=0.0):
        mem = rd / bwr + wr / bww
        comp = fl / peak
        return max(mem, comp) * 1e6, ("mfma" if comp > mem else "mem")

    f1 = 2 * R * H * 2 * I
    f2 = 2 * R * I * H
    cur = {
        "prologue": t(x_bf16, xq),
        "stage1": t(R * H / 2 * SC + w1, hq, f1),
    }
    if fc:
        cur["stage2"] = t(hq + w2 + routed_rows, routed_rows + out, f2)
        cur["combine"] = (0.0, "-")
    else:
        cur["stage2"] = t(hq + w2, rows, f2)
        cur["combine"] = t(rows, out)
    mini = {
        "prologue": t(x_bf16, xq),
        "stage1": t(xq + w1, hq, f1),
        "stage2+combine": t(hq + w2, out, f2),
    }
    return cur, mini, rows <= MALL


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("json", nargs="+", help="compare.py --out files")
    ap.add_argument("--bw", default="bench/results/r4_hbm_bw.json")
    ap.add_argument("--peak", type=float, default=7.43e15, help="best measured MFMA FLOP/s (r4_mfma_peak.log)")
    ap.add_argument("--arm", default="cand", choices=("cand", "ref"))
    ap.add_argument("--T", type=int, nargs="*", default=[])
    a = ap.parse_args()
    d = json.load(open(a.bw))
    bw = d["stream"]
    rows_w = max((e["logical_TBs"] for e in d.get("epi", []) if e["mode"] == "rows"), default=0.0)
    bwr, bww = bw["read"] * 1e12, max(bw["write"], rows_w) * 1e12
    print(f"peak {a.peak / 1e15:.2f} PF, read {bw['read']:.2f} TB/s, "
          f"write {bww / 1e12:.2f} TB/s (stream {bw['write']:.2f}, row stores {rows_w:.2f})")
    for path in a.json:
        for r in json.load(open(path)):
            if a.T and r["T"] not in a.T:
                continue
            I, T = r["I"], r["T"]
            m = r["median_us"][a.arm]
            cfg = r["cand_cfg"] if a.arm == "cand" else r.get("ref_cfg")
            if cfg is None:
                raise SystemExit(f"{path}: no ref_cfg recorded; re-run compare.py or use --arm cand")
            cur, mini, fits = model(I, T, cfg, a.peak, bwr, bww)
            s2cb = m["stage2"] + m["combine"]
            parts = []
            for k in ("prologue", "stage1", "stage2", "combine"):
                fl, b = cur[k]
                if fl == 0.0:
                    continue
                parts.append(f"{k[:3]} {m[k]:7.1f}/{fl:6.1f} {100 * fl / m[k]:3.0f}% {b}")
            cur_tot = sum(v[0] for v in cur.values())
            min_tot = sum(v[0] for v in mini.values())
            print(f"I={I:5d} T={T:6d} total {m['total']:7.1f} us | " + " | ".join(parts) + (" | mall" if fits else ""))
            print(f"{'':15s} floor current {cur_tot:7.1f} ({100 * cur_tot / m['total']:3.0f}%)"
                  f"  minimal-unfused {min_tot:7.1f} ({100 * min_tot / m['total']:3.0f}%)"
                  f" | s1 minimal {mini['stage1'][0]:6.1f} ({100 * mini['stage1'][0] / m['stage1']:3.0f}%)"
                  f" | s2+cb minimal {mini['stage2+combine'][0]:6.1f} {mini['stage2+combine'][1]}"
                  f" ({100 * mini['stage2+combine'][0] / s2cb:3.0f}% of {s2cb:.1f})")


if __name__ == "__main__":
    main()
