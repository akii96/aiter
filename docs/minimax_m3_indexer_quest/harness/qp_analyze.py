#!/usr/bin/env python3
"""
QUEST PREFILTER -- PHASE 1 ANALYSIS (CPU-ONLY)

Given captured real index_k / index_q, measure:

 1. Bound tightness:  ratio = bound_j / true_j   over (query, block) pairs.
 2. THE KEY NUMBER:   N* = |{ j : bound_j > T* }|, T* = true 16th-best score.

    N* is EXACT and ORDER-INDEPENDENT. Proof:
      - descending-bound visit order is optimal for branch-and-bound;
      - every true top-16 block j has bound_j >= true_j >= T*, so all 16 winners
        lie inside the prefix {bound > T*};
      - once that prefix is consumed the running threshold T equals T*, and the
        next block has bound <= T* so the scan provably terminates.
    => "expected fraction of blocks fully read" is a property of the DATA.

 3. Fixed-cap variant:  read exactly the top-C blocks by bound. Exact iff
    bound_(C+1) <= T_C (the 16th-best among those C). That check is itself
    exact and cheap, so the kernel can fall back only when it fires.

 4. Warm start:  seed T from the previous decode step's 16th-best EXACT score.
    NOTE: this is NOT unconditionally safe -- T_seed may exceed T* for the new
    query, which would prune a genuine winner. Measured here both ways.

Score semantics replicated EXACTLY from pa_sparse_block_select_kernels.cuh:
  * score = max over the block's VISIBLE tokens of (q . k), fp32       (:643)
  * per (query token, index head) -- heads are INDEPENDENT rows        (:552)
  * sentinels: row's own last block -> 1e29f; init blocks -> 1e30f     (:544-548)
  * tie-break: pack_score_key puts block idx in LOW 32 bits            (:706-711)
    => among equal scores the LARGER block index wins.
"""
import argparse, json, math, sys
import numpy as np

TOPK = 16
BLOCK = 128
LOCAL_BLOCKS = 1     # sparse_local_block=1
INIT_BLOCKS = 0      # sparse_init_block=0


def pack_key(score_f32, idx):
    """Bit-exact replica of pack_score_key -> uint64, for tie-break fidelity."""
    u = np.asarray(score_f32, dtype=np.float32).view(np.uint32).astype(np.uint64)
    neg = (u & np.uint64(0x80000000)) != 0
    u = np.where(neg, ~u & np.uint64(0xFFFFFFFF), u | np.uint64(0x80000000))
    return (u << np.uint64(32)) | np.asarray(idx, dtype=np.uint64)


def topk_exact(scores, nblk):
    """Reference top-16 with the kernel's exact tie-break. scores [nblk] fp32."""
    keys = pack_key(scores[:nblk], np.arange(nblk))
    order = np.argsort(keys)[::-1]
    return order[:TOPK]


def block_summaries(K, nblk, block=BLOCK, sub=1):
    """Per-SUB-block elementwise min/max. Query-independent.

    sub=1 is vanilla Quest (one box per 128-token block, 256 B).
    sub=S splits the block into S contiguous groups of 128/S tokens and keeps a
    box per group; the block bound becomes max over its groups' bounds, which is
    still a strict upper bound on max_k(q.k) but a much tighter one.
    Summary cost is S*256 B/block.  Quest's own paper used page_size=16, i.e.
    effectively S=8 at our 128-token block -- so S>1 is the faithful port, not
    an embellishment.
    """
    D = K.shape[1]
    g = block // sub
    mn = np.zeros((nblk, sub, D), dtype=np.float32)
    mx = np.zeros((nblk, sub, D), dtype=np.float32)
    for b in range(nblk):
        for s_ in range(sub):
            s = b * block + s_ * g
            e = min(s + g, K.shape[0])
            if e <= s:
                mn[b, s_] = np.inf; mx[b, s_] = -np.inf; continue
            blk = K[s:e]
            mn[b, s_] = blk.min(0)
            mx[b, s_] = blk.max(0)
    return mn, mx


def quest_bound(q, mn, mx):
    """max over sub-boxes of sum_d max(q_d*mn, q_d*mx).
    mn/mx [nblk, sub, D] -> [nblk]."""
    a = q[None, None, :] * mn
    b = q[None, None, :] * mx
    per_sub = np.maximum(a, b).sum(-1)          # [nblk, sub]
    return np.nanmax(np.where(np.isfinite(per_sub), per_sub, -np.inf), axis=1)


def true_scores(q, K, nblk, kv_len, block=BLOCK):
    """score_b = max over visible tokens of q.k ; -inf if no visible token."""
    dots = K[:kv_len] @ q
    out = np.full(nblk, -np.inf, dtype=np.float32)
    for b in range(nblk):
        s = b * block
        e = min(s + block, kv_len)
        if e > s:
            out[b] = dots[s:e].max()
    return out


def apply_sentinels(scores, nblk):
    """Replicate decode_epilogue sentinel overwrite."""
    out = scores.copy()
    if INIT_BLOCKS:
        out[:INIT_BLOCKS] = 1e30
    if LOCAL_BLOCKS:
        out[nblk - LOCAL_BLOCKS:nblk] = 1e29
    return out


def analyze_row(q, K, kv_len, mn, mx, warm_T=None):
    nblk = (kv_len + BLOCK - 1) // BLOCK
    ts_raw = true_scores(q, K, nblk, kv_len)
    ts = apply_sentinels(ts_raw, nblk)

    bd_raw = quest_bound(q, mn[:nblk], mx[:nblk])
    bd = apply_sentinels(bd_raw, nblk)   # sentinels bound themselves exactly

    sel = topk_exact(ts, nblk)
    kth = ts[sel[-1]]                     # T* = 16th-best exact score

    # ---- N*: blocks whose full keys must be read ----
    # sentinel blocks never need their keys read (score is forced)
    contested = np.ones(nblk, dtype=bool)
    if LOCAL_BLOCKS: contested[nblk - LOCAL_BLOCKS:nblk] = False
    if INIT_BLOCKS:  contested[:INIT_BLOCKS] = False

    n_star = int(((bd > kth) & contested).sum())

    # tightness only over contested, finite-true blocks
    m = contested & np.isfinite(ts_raw) & (np.abs(ts_raw) > 1e-12)
    ratio = (bd_raw[m] / ts_raw[m]) if m.any() else np.array([])
    gap = (bd_raw[m] - ts_raw[m]) if m.any() else np.array([])

    res = dict(nblk=nblk, n_star=n_star, kth=float(kth),
               frac=n_star / max(1, nblk),
               ratio=ratio, gap=gap,
               bd=bd, ts=ts, sel=sel, contested=contested)

    if warm_T is not None:
        # seed T from previous step; prune bound <= T_seed
        n_warm = int(((bd > max(kth, warm_T)) & contested).sum())
        # safety: would seeding have pruned a genuine winner?
        unsafe = bool(warm_T > kth)
        n_warm_unsafe = int(((bd > warm_T) & contested).sum())
        res.update(n_warm=n_warm, warm_unsafe=unsafe, n_warm_raw=n_warm_unsafe)
    return res


def pct(a, p):
    return float(np.percentile(a, p)) if len(a) else float("nan")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--npz", required=True)
    ap.add_argument("--ctx", type=int, nargs="+", default=[8192])
    ap.add_argument("--queries", type=int, default=64)
    ap.add_argument("--rope", choices=["rope", "norope"], default="rope")
    ap.add_argument("--tile", type=int, default=0,
                    help="if >0, tile the captured K to reach longer ctx")
    ap.add_argument("--sub", type=int, default=1,
                    help="sub-boxes per 128-token block (1=vanilla Quest, 8=page16)")
    ap.add_argument("--json-out", default=None)
    a = ap.parse_args()

    z = np.load(a.npz)
    suf = "_fp8" if a.rope == "rope" else "_norope"
    K = z["index_k" + suf].astype(np.float32)      # [T, 128]
    Q = z["index_q" + suf].astype(np.float32)      # [T, 4, 128]
    print(f"[analyze] K={K.shape} Q={Q.shape} rope={a.rope}")

    report = {}
    for ctx in a.ctx:
        if ctx > K.shape[0]:
            if not a.tile:
                print(f"[analyze] ctx={ctx} > captured {K.shape[0]}, skip "
                      f"(use --tile to extrapolate)"); continue
            reps = math.ceil(ctx / K.shape[0])
            Kc = np.tile(K, (reps, 1))[:ctx]
            note = f"TILED x{reps}"
        else:
            Kc = K[:ctx]
            note = "native"
        kv_len = ctx
        nblk = (kv_len + BLOCK - 1) // BLOCK
        mn, mx = block_summaries(Kc, nblk, sub=a.sub)

        # queries: real index_q rows, sampled from the *latest* positions
        # (a decode step's query is the newest token)
        qidx = np.linspace(max(0, min(ctx, Q.shape[0]) - 1) * 0.5,
                           min(ctx, Q.shape[0]) - 1, a.queries).astype(int)
        rows = []
        prev_kth = {}
        for t in qidx:
            for h in range(Q.shape[1]):
                warm = prev_kth.get(h)
                r = analyze_row(Q[t, h], Kc, kv_len, mn, mx, warm_T=warm)
                prev_kth[h] = r["kth"]
                rows.append(r)

        ns = np.array([r["n_star"] for r in rows], float)
        fr = np.array([r["frac"] for r in rows], float)
        ratio = np.concatenate([r["ratio"] for r in rows]) if rows else np.array([])
        nw = np.array([r.get("n_warm", np.nan) for r in rows], float)
        unsafe = np.array([r.get("warm_unsafe", False) for r in rows], bool)

        # traffic model: summaries always read (256 B/blk), keys only for N*
        # baseline 16384 B/blk
        sum_bytes = a.sub * 2 * 128 * 1  # fp8 min + fp8 max per sub-box
        traffic = (nblk * sum_bytes + ns * 16384)
        base = nblk * 16384
        speed = base / traffic

        e = dict(ctx=ctx, nblk=nblk, note=note, sub=a.sub, sum_bytes=sum_bytes,
                 n_star_mean=float(ns.mean()), n_star_p50=pct(ns, 50),
                 n_star_p90=pct(ns, 90), n_star_p99=pct(ns, 99),
                 n_star_p999=pct(ns, 99.9), n_star_max=float(ns.max()),
                 frac_mean=float(fr.mean()), frac_p99=pct(fr, 99),
                 ratio_p50=pct(ratio, 50), ratio_p90=pct(ratio, 90),
                 ratio_p99=pct(ratio, 99), ratio_mean=float(ratio.mean()) if len(ratio) else float('nan'),
                 ratio_min=float(ratio.min()) if len(ratio) else float('nan'),
                 ratio_max=float(ratio.max()) if len(ratio) else float('nan'),
                 traffic_speedup_mean=float(speed.mean()),
                 traffic_speedup_p99=float(base / np.percentile(traffic, 99)),
                 warm_n_mean=float(np.nanmean(nw)),
                 warm_unsafe_frac=float(unsafe.mean()),
                 rows=len(rows))
        report[ctx] = e
        print(f"\n===== ctx={ctx} ({note}) nblk={nblk} sub={a.sub} ({sum_bytes} B/blk summary) rows={len(rows)} =====")
        print(f"  bound/true ratio   p50={e['ratio_p50']:.3f} p90={e['ratio_p90']:.3f} "
              f"p99={e['ratio_p99']:.3f}  [min {e['ratio_min']:.3f} max {e['ratio_max']:.3f}]")
        print(f"  N* (blocks read)   mean={e['n_star_mean']:.1f} p50={e['n_star_p50']:.0f} "
              f"p90={e['n_star_p90']:.0f} p99={e['n_star_p99']:.0f} "
              f"p99.9={e['n_star_p999']:.0f} max={e['n_star_max']:.0f}  of {nblk}")
        print(f"  fraction read      mean={e['frac_mean']*100:.2f}%  p99={e['frac_p99']*100:.2f}%")
        print(f"  TRAFFIC SPEEDUP    mean={e['traffic_speedup_mean']:.2f}x  "
              f"p99={e['traffic_speedup_p99']:.2f}x")
        print(f"  warm-start N mean={e['warm_n_mean']:.1f} "
              f"(unsafe seed in {e['warm_unsafe_frac']*100:.1f}% of rows)")

        # fixed-cap analysis
        print(f"  --- fixed-cap C (exactness check: bound_(C+1) <= T_C) ---")
        for C in (16, 32, 48, 64, 96, 128, 192, 256):
            if C > nblk: break
            fail = float((ns > C).mean())
            tr = (nblk * sum_bytes + C * 16384)
            print(f"      C={C:4d}  fallback_rate={fail*100:7.3f}%   "
                  f"traffic={base/tr:5.2f}x")
        e["cap"] = {C: dict(fallback=float((ns > C).mean()),
                            speedup=float(base / (nblk * sum_bytes + C * 16384)))
                    for C in (16, 32, 48, 64, 96, 128, 192, 256) if C <= nblk}

    if a.json_out:
        json.dump({str(k): {kk: vv for kk, vv in v.items() if kk != "rows"}
                   for k, v in report.items()},
                  open(a.json_out, "w"), indent=2, default=float)
        print(f"\n[analyze] wrote {a.json_out}")


if __name__ == "__main__":
    main()
