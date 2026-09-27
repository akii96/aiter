#!/usr/bin/env python3
"""
QUEST PREFILTER -- PHASE 1 ANALYSIS v2 (vectorised, CPU or GPU)

Measures the ONLY number that decides this project:

    N*  =  |{ j : bound_j > T* }|,   T* = the true 16th-best block score.

N* is EXACT and ORDER-INDEPENDENT (proof in report): it is the number of blocks
whose full 16 KB of keys ANY correct branch-and-bound must read, no matter how
clever the visit order. So this is a property of the DATA, not of a heuristic.

Also reports the diagnostic that explains N*:
    * bound/true ratio distribution (tightness)
    * separation: how far the true top-16 stand above the rest
      -- if true scores are tightly packed, NO bound of this family can prune.

Bounds implemented:
    box   : Quest.  max_k q.k <= sum_d max(q_d*min_d, q_d*max_d)     [2*D bytes]
    ball  : centroid+radius.  q.c + |q|*max_k|k-c|                   [D+1 bytes]
    both  : min(box, ball) -- still a valid upper bound, tighter than either.
Sub-boxes: split a 128-token block into S groups, bound = max over groups.
Quest's paper used page_size=16 == S=8 here, so S>1 is the faithful port.
"""
import argparse, json, math, time
import numpy as np

TOPK = 16
BLOCK = 128
LOCAL_BLOCKS = 1
INIT_BLOCKS = 0


def summaries(K, nblk, sub, block=BLOCK):
    """-> mn,mx [nblk,sub,D] ; cen [nblk,sub,D] ; rad [nblk,sub]"""
    D = K.shape[1]
    g = block // sub
    mn = np.full((nblk, sub, D), -np.inf, np.float32)
    mx = np.full((nblk, sub, D), -np.inf, np.float32)
    cen = np.zeros((nblk, sub, D), np.float32)
    rad = np.full((nblk, sub), -np.inf, np.float32)
    for b in range(nblk):
        for s_ in range(sub):
            s = b * block + s_ * g
            e = min(s + g, K.shape[0])
            if e <= s:
                continue
            blk = K[s:e]
            mn[b, s_] = blk.min(0)
            mx[b, s_] = blk.max(0)
            c = blk.mean(0)
            cen[b, s_] = c
            rad[b, s_] = np.linalg.norm(blk - c, axis=1).max()
    return mn, mx, cen, rad


def bounds_for(Q, mn, mx, cen, rad, kind):
    """Q [R,D] -> [R,nblk]. Vectorised over queries and blocks."""
    R = Q.shape[0]
    nblk, sub, D = mn.shape
    out = np.full((R, nblk), -np.inf, np.float32)
    live = np.isfinite(rad)                            # [nblk,sub]
    for s_ in range(sub):
        L = live[:, s_]
        if not L.any():
            continue
        if kind in ("box", "both"):
            # sum_d max(q*mn, q*mx) = sum_d (q*(mn+mx)/2 + |q|*(mx-mn)/2)
            mid = 0.5 * (mn[L, s_] + mx[L, s_])
            hw = 0.5 * (mx[L, s_] - mn[L, s_])
            bx = Q @ mid.T + np.abs(Q) @ hw.T          # [R, nL]
        if kind in ("ball", "both"):
            bl = Q @ cen[L, s_].T + np.linalg.norm(Q, axis=1)[:, None] * rad[L, s_][None, :]
        if kind == "box":    v = bx
        elif kind == "ball": v = bl
        else:                v = np.minimum(bx, bl)
        out[:, L] = np.maximum(out[:, L], v)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--npz", required=True)
    ap.add_argument("--ctx", type=int, nargs="+", required=True)
    ap.add_argument("--queries", type=int, default=128)
    ap.add_argument("--rope", choices=["rope", "norope"], default="rope")
    ap.add_argument("--sub", type=int, nargs="+", default=[1])
    ap.add_argument("--bound", nargs="+", default=["box"])
    ap.add_argument("--json-out", default=None)
    a = ap.parse_args()

    z = np.load(a.npz)
    suf = "_fp8" if a.rope == "rope" else "_norope"
    K = z["index_k" + suf].astype(np.float32)
    Qa = z["index_q" + suf].astype(np.float32)
    print(f"[a2] K={K.shape} Q={Qa.shape} rope={a.rope}", flush=True)

    out = []
    for ctx in a.ctx:
        if ctx > K.shape[0]:
            print(f"[a2] skip ctx={ctx} > {K.shape[0]}"); continue
        Kc = K[:ctx]
        nblk = ctx // BLOCK
        # queries = real index_q rows from the second half of the context
        ti = np.linspace(ctx // 2, min(ctx, Qa.shape[0]) - 1, a.queries).astype(int)
        Q = Qa[ti].reshape(-1, Qa.shape[-1])            # [R, D], R = queries*heads

        # ---- exact scores ----
        t0 = time.time()
        dots = Q @ Kc.T                                  # [R, ctx]
        ts = dots[:, :nblk * BLOCK].reshape(Q.shape[0], nblk, BLOCK).max(-1)  # [R,nblk]
        contested = np.ones(nblk, bool)
        contested[nblk - LOCAL_BLOCKS:] = False
        if INIT_BLOCKS: contested[:INIT_BLOCKS] = False

        tsx = ts.copy()
        tsx[:, nblk - LOCAL_BLOCKS:] = 1e29
        # T* = 16th best exact score (sentinels included, as the kernel does)
        kk = min(TOPK, nblk)
        part = np.partition(tsx, -kk, axis=1)
        Tstar = part[:, -kk]                             # [R]

        # separation diagnostic: spread of contested true scores
        tc = ts[:, contested]
        srt = np.sort(tc, axis=1)[:, ::-1]
        sep = dict(
            top1=float(np.mean(srt[:, 0])),
            top16=float(np.mean(srt[:, min(TOPK - 1, srt.shape[1] - 1)])),
            med=float(np.mean(np.median(tc, axis=1))),
            p99blk=float(np.mean(np.percentile(tc, 99, axis=1))),
            std=float(np.mean(tc.std(axis=1))),
            # how many blocks lie within 1 std of T*  (the "crowding" number)
            crowd=float(np.mean(((tc > (Tstar[:, None] - tc.std(axis=1, keepdims=True)))
                                 & (tc < Tstar[:, None])).sum(1))),
        )
        print(f"\n##### ctx={ctx} nblk={nblk} R={Q.shape[0]} "
              f"(exact {time.time()-t0:.1f}s) #####")
        print(f"  true scores: top1={sep['top1']:.2f} top16={sep['top16']:.2f} "
              f"p99blk={sep['p99blk']:.2f} median={sep['med']:.2f} std={sep['std']:.2f}")
        print(f"  crowding: {sep['crowd']:.1f} blocks sit within 1sd just below T*")

        for sub in a.sub:
            mn, mx, cen, rad = summaries(Kc, nblk, sub)
            for kind in a.bound:
                bd = bounds_for(Q, mn, mx, cen, rad, kind)
                bdx = bd.copy()
                bdx[:, nblk - LOCAL_BLOCKS:] = 1e29

                ns = ((bdx > Tstar[:, None]) & contested[None, :]).sum(1).astype(float)
                m = np.isfinite(ts) & contested[None, :] & (np.abs(ts) > 1e-9)
                ratio = (bd[m] / ts[m])

                sb = sub * 2 * 128 if kind == "box" else (
                     sub * (128 + 4) if kind == "ball" else sub * (2 * 128 + 128 + 4))
                base = nblk * 16384
                traf = nblk * sb + ns * 16384
                sp = base / traf

                print(f"  [{kind:4s} sub={sub}] summary={sb:5d} B/blk | "
                      f"ratio p50={np.percentile(ratio,50):.2f} "
                      f"p99={np.percentile(ratio,99):.2f} | "
                      f"N* mean={ns.mean():.0f} p50={np.percentile(ns,50):.0f} "
                      f"p99={np.percentile(ns,99):.0f} max={ns.max():.0f} /{nblk} "
                      f"({100*ns.mean()/nblk:.1f}%) | "
                      f"TRAFFIC {sp.mean():.2f}x")
                caps = {}
                for C in (16, 24, 32, 48, 64, 96, 128, 192, 256, 384, 512):
                    if C > nblk: break
                    caps[C] = dict(fallback=float((ns > C).mean()),
                                   speedup=float(base / (nblk * sb + C * 16384)))
                best = [f"C={C}:{v['fallback']*100:.1f}%/{v['speedup']:.1f}x"
                        for C, v in caps.items()]
                print(f"       fixed-cap  " + "  ".join(best))
                out.append(dict(ctx=ctx, nblk=nblk, sub=sub, bound=kind,
                                summary_bytes=sb,
                                ratio_p50=float(np.percentile(ratio, 50)),
                                ratio_p99=float(np.percentile(ratio, 99)),
                                n_mean=float(ns.mean()),
                                n_p50=float(np.percentile(ns, 50)),
                                n_p99=float(np.percentile(ns, 99)),
                                n_p999=float(np.percentile(ns, 99.9)),
                                n_max=float(ns.max()),
                                frac=float(ns.mean() / nblk),
                                traffic=float(sp.mean()), cap=caps, sep=sep))
    if a.json_out:
        json.dump(out, open(a.json_out, "w"), indent=2, default=float)
        print(f"\n[a2] wrote {a.json_out}")


if __name__ == "__main__":
    main()
