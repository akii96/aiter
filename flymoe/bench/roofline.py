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

On-chip floor (stage 1 and stage 2, per cell): the busiest CU's work units (tile x N block;
expected tiles per expert from the binomial routing, units spread over 256 CUs, or over
256 x PERS workers when persistent) times the per-unit, per-128-K-step cost of the binding
on-chip resource: MFMA issue (bench/micro_r5.py mfma), LDS bytes (DMA writes plus ds_reads for
the pipe's staging; hybrid pipes keep B out of LDS) at the measured LDS rate (micro_r5.py
lds), and load bytes at the measured TA rate (bench/dma_bw.py: gathered 64 B rows for the
A operand unless HT, contiguous for weights). The wave-quantization factor q is the
average units per CU over the busiest CU's units (1.0 = perfectly balanced); with --occ
(bench/occupancy.py --cfg) the resident-CTA rounds are reported as well. Rates are per ns
at the kernel's running clock (bench/results/r5_micro.log).

These are HBM floors. The 256 MB MALL can serve a re-read whose working set fits, so a
cell can run above 100% of its floor; cells whose [R, H] bf16 expert rows fit in the MALL
are flagged "mall" (weights and xq are not considered: at small T the touched weights,
and at any T the quantized activations, can also be MALL-resident). At T <= 256 launch overhead (a few us per kernel) dominates the
small kernels, so their percentages say little.

Shape: MiniMax-M3 (H=6144, E=129 = 128 routed + 1 shared, k=5 incl. shared).
"""

import argparse
import functools
import json
import math

H, E, K = 6144, 129, 5
SC = 1 + 1 / 16  # fp4 bytes + e8m0 scale bytes (1 per 32 values)
MALL = 256 << 20
CUS = 256
# r5_micro.log: MFMA 16x16x128 fp4 issue at 9.2 PF (0.137 per ns per SIMD), LDS reads with
# DMA in flight ~275-290 B/ns/CU, TA: contiguous 27.05 TB/s, gathered 16x64 B 17.44 TB/s.
R_MFMA = 9.2e15 / (CUS * 4 * 2 * 16 * 16 * 128) / 1e9
R_LDS = 280.0
R_CONT = 27.05e12 / CUS / 1e9
R_GATH = 17.44e12 / CUS / 1e9


@functools.lru_cache(maxsize=None)
def exp_tiles(T, BM):
    """Expected BM-row tiles: 128 routed experts with Binomial(T, 4/128) rows, plus shared (T rows)."""
    p = 4 / 128
    mu, sd = T * p, math.sqrt(T * p * (1 - p))
    lo, hi = max(0, int(mu - 12 * sd)), min(T, int(mu + 12 * sd) + 1)
    e = 0.0
    for n in range(lo, hi + 1):
        lp = (math.lgamma(T + 1) - math.lgamma(n + 1) - math.lgamma(T - n + 1)
              + n * math.log(p) + (T - n) * math.log1p(-p))
        e += math.exp(lp) * -(-n // BM)
    return 128 * e + -(-T // BM)


def onchip(stage, I, T, cfg, occ=None):
    """On-chip floor (us), binding resource, wave-quantization factor, resident rounds."""
    s = str(stage)
    BM, NW, pipe = cfg.get("BM" + s, 128), cfg.get("NW" + s, 4), cfg.get("pipe" + s, "async")
    WM = cfg.get("WM" + s, 2 if pipe in ("pingpong", "il4") else 1)
    CG = 2 if pipe == "il4" else 1
    WN = NW // WM
    BN = 64 * WN * CG
    Kd, N = (H, 2 * I) if stage == 1 else (I, H)
    KS, NB = Kd // 128, N // BN
    units = exp_tiles(T, BM) * NB
    pers = cfg.get("PERS" + s, 0)
    workers = CUS * pers if pers else units
    per_cu = (pers * math.ceil(units / workers)) if pers else math.ceil(units / CUS)
    q = units / CUS / per_cu
    a_b, b_b = BM * 64 * SC, BN * 64 * SC
    b_lds = pipe not in ("hybrid", "hybrid2")
    lds = a_b + WN * BM * 64 + (b_b + WM * BN * 64 if b_lds else 0)
    gath = stage == 1 or not cfg.get("HT")
    cost = {"mfma": (BM // 16) * (BN // 16) / (4 * R_MFMA),
            "lds": lds / R_LDS,
            "ta": a_b / (R_GATH if gath else R_CONT) + b_b / R_CONT}
    bind = max(cost, key=cost.get)
    t = per_cu * KS * cost[bind] / 1e3
    rounds = None
    if occ:
        slots = CUS * occ
        rounds = math.ceil((workers if pers else units) / slots)
    return t, bind, q, rounds


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
    ap.add_argument("--occ", default=None, help="occupancy.py --cfg output: {\"I,T\": {\"1\": CTAs/CU, \"2\": ...}}")
    a = ap.parse_args()
    occ = json.load(open(a.occ)) if a.occ else {}
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
            for k, lab in (("prologue", "pro"), ("stage1", "s1"), ("stage2", "s2"), ("combine", "cb")):
                fl, b = cur[k]
                if fl == 0.0:
                    continue
                parts.append(f"{lab} {m[k]:7.1f}/{fl:6.1f} {100 * fl / m[k]:3.0f}% {b}")
            cur_tot = sum(v[0] for v in cur.values())
            min_tot = sum(v[0] for v in mini.values())
            print(f"I={I:5d} T={T:6d} total {m['total']:7.1f} us | " + " | ".join(parts) + (" | mall" if fits else ""))
            print(f"{'':15s} floor current {cur_tot:7.1f} ({100 * cur_tot / m['total']:3.0f}%)"
                  f"  minimal-unfused {min_tot:7.1f} ({100 * min_tot / m['total']:3.0f}%)"
                  f" | s1 minimal {mini['stage1'][0]:6.1f} ({100 * mini['stage1'][0] / m['stage1']:3.0f}%)"
                  f" | s2+cb minimal {mini['stage2+combine'][0]:6.1f} {mini['stage2+combine'][1]}"
                  f" ({100 * mini['stage2+combine'][0] / s2cb:3.0f}% of {s2cb:.1f})")
            parts = []
            for st, key in ((1, "stage1"), (2, "stage2")):
                o = occ.get(f"{I},{T}", {}).get(str(st))
                t, bind, q, rounds = onchip(st, I, T, cfg, o)
                hb, hsrc = cur[key]
                fl, src = (t, bind) if t > hb else (hb, "hbm" if hsrc == "mem" else hsrc)
                parts.append(f"s{st} on-chip {t:6.1f} ({bind}, q={q:.2f}"
                             + (f", {rounds} rounds @{o}/CU" if rounds else "")
                             + f") binding {fl:6.1f} {src} ({100 * fl / m[key]:3.0f}%)")
            print(f"{'':15s} " + " | ".join(parts))


if __name__ == "__main__":
    main()
