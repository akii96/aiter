#!/usr/bin/env python3
"""
QUEST PREFILTER -- THE CROWDING DIAGNOSTIC

This is the analysis that actually decides the project, and it separates two
failure modes that get confused with each other:

  (A) "the bound is loose"      -- bound_j / true_j is large
  (B) "the scores are crowded"  -- true_j are all nearly equal

Pruning requires   bound_j <= T*.  Write bound_j = r_j * true_j with r_j >= 1.
Then block j is pruned  <=>  true_j <= T* / r_j.

So the fraction pruned is  F(T*/r), where F is the CDF of the true block scores.
BOTH factors matter multiplicatively, and (B) is the one nobody checks.

Why (B) is the structural risk for THIS kernel
----------------------------------------------
score_b = MAX over the block's 128 tokens of (q.k).
The maximum of 128 i.i.d. draws concentrates: for light-tailed q.k the spread of
the max across blocks shrinks like 1/log(n) relative to its level. With 128
tokens per block, every block's max lands near the same upper quantile, so the
true scores are squeezed into a narrow band ABOVE the bulk. A narrow band means
F is steep near T*, so even a modestly loose bound prunes nothing.

This is a property of block_size=128 + score_type='max', NOT of Quest. Quest's
published setting used page_size=16, where the max is over 8x fewer samples and
the per-block maxima are correspondingly more spread out.

Outputs, per context:
  * the true-score CDF shape around T*
  * the REQUIRED bound tightness r_max(f) to prune a target fraction f
  * the ACHIEVED r for each candidate bound
  * => the pruning fraction that actually results
"""
import argparse, json
import numpy as np

TOPK, BLOCK, LOCAL = 16, 128, 1
ROT, HALF = 64, 32


def summaries(K, nblk, sub):
    D = K.shape[1]; g = BLOCK // sub
    mn = np.full((nblk, sub, D), -np.inf, np.float32)
    mx = np.full((nblk, sub, D), -np.inf, np.float32)
    amp = np.zeros((nblk, sub, HALF), np.float32)
    ok = np.zeros((nblk, sub), bool)
    for b in range(nblk):
        for s_ in range(sub):
            s = b * BLOCK + s_ * g; e = min(s + g, K.shape[0])
            if e <= s: continue
            blk = K[s:e]; ok[b, s_] = True
            mn[b, s_] = blk.min(0); mx[b, s_] = blk.max(0)
            amp[b, s_] = np.sqrt(blk[:, :HALF]**2 + blk[:, HALF:ROT]**2).max(0)
    return mn, mx, amp, ok


def bound(Q, mn, mx, amp, ok, kind):
    R = Q.shape[0]; nblk, sub, D = mn.shape
    out = np.full((R, nblk), -np.inf, np.float32)
    qp = np.sqrt(Q[:, :HALF]**2 + Q[:, HALF:ROT]**2)
    for s_ in range(sub):
        L = ok[:, s_]
        if not L.any(): continue
        mid = 0.5*(mn[L, s_]+mx[L, s_]); hw = 0.5*(mx[L, s_]-mn[L, s_])
        bx = Q @ mid.T + np.abs(Q) @ hw.T
        if kind == "box":
            v = bx
        else:
            midn = 0.5*(mn[L, s_, ROT:]+mx[L, s_, ROT:])
            hwn = 0.5*(mx[L, s_, ROT:]-mn[L, s_, ROT:])
            po = qp @ amp[L, s_].T + Q[:, ROT:] @ midn.T + np.abs(Q[:, ROT:]) @ hwn.T
            v = po if kind == "polar" else np.minimum(bx, po)
        out[:, L] = np.maximum(out[:, L], v)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--npz", required=True)
    ap.add_argument("--ctx", type=int, nargs="+", required=True)
    ap.add_argument("--queries", type=int, default=64)
    ap.add_argument("--sub", type=int, nargs="+", default=[1, 8])
    ap.add_argument("--json-out", default=None)
    a = ap.parse_args()

    z = np.load(a.npz)
    K = z["index_k_fp8"].astype(np.float32)
    Qa = z["index_q_fp8"].astype(np.float32)
    print(f"[crowd] K={K.shape} Q={Qa.shape}")
    res = []

    for ctx in a.ctx:
        if ctx > K.shape[0]:
            print(f"[crowd] skip {ctx}"); continue
        Kc = K[:ctx]; nblk = ctx // BLOCK
        ti = np.linspace(ctx//2, min(ctx, Qa.shape[0])-1, a.queries).astype(int)
        Q = Qa[ti].reshape(-1, Qa.shape[-1])
        R = Q.shape[0]

        ts = (Q @ Kc.T)[:, :nblk*BLOCK].reshape(R, nblk, BLOCK).max(-1)
        cont = np.ones(nblk, bool); cont[nblk-LOCAL:] = False
        tsx = ts.copy(); tsx[:, nblk-LOCAL:] = 1e29
        kk = min(TOPK, nblk)
        Tstar = np.partition(tsx, -kk, 1)[:, -kk]
        tc = ts[:, cont]

        print(f"\n########## ctx={ctx}  nblk={nblk}  rows={R} ##########")
        # --- (B) CROWDING: the CDF of true scores, normalised by T* ---
        rel = tc / Tstar[:, None]           # >1 means "beats the cutoff"
        qs = [1, 5, 10, 25, 50, 75, 90, 99]
        rq = {p: float(np.percentile(rel, p)) for p in qs}
        print("  true/T* percentiles: " + "  ".join(f"p{p}={rq[p]:.3f}" for p in qs))
        print(f"  => a block is pruned only if bound/true <= T*/true, i.e. <= 1/(true/T*)")
        # required tightness to prune a given fraction of blocks
        print("  REQUIRED bound tightness r to prune X% of blocks:")
        for f in (50, 75, 90, 95, 98, 99):
            # prune fraction f  <=>  r <= 1/ percentile_{100-f}(rel)
            need = 1.0 / np.percentile(rel, 100 - f)
            print(f"      prune {f:2d}%  needs  r <= {need:.3f}"
                  + ("   (IMPOSSIBLE: r>=1 always)" if need < 1.0 else ""))

        entry = dict(ctx=ctx, nblk=nblk, rel_pct=rq,
                     need={f: float(1.0/np.percentile(rel, 100-f))
                           for f in (50, 75, 90, 95, 98, 99)})

        # --- (A) ACHIEVED tightness, and the resulting prune fraction ---
        for sub in a.sub:
            mn, mx, amp, ok = summaries(Kc, nblk, sub)
            for kind in ("box", "polar", "pbox"):
                bd = bound(Q, mn, mx, amp, ok, kind)
                m = cont[None, :] & (np.abs(ts) > 1e-9)
                r = bd[m] / ts[m]
                bdx = bd.copy(); bdx[:, nblk-LOCAL:] = 1e29
                ns = ((bdx > Tstar[:, None]) & cont[None, :]).sum(1)
                sb = {"box": sub*256, "polar": sub*160, "pbox": sub*288}[kind]
                base = nblk*16384
                sp = base/(nblk*sb + ns*16384)
                print(f"    [{kind:5s} sub={sub}] r p50={np.percentile(r,50):5.2f} "
                      f"p10={np.percentile(r,10):5.2f} min={r.min():5.2f} | "
                      f"N*={ns.mean():6.1f}/{nblk} ({100*ns.mean()/nblk:5.1f}%) | "
                      f"traffic {sp.mean():.2f}x")
                entry.setdefault("bounds", []).append(
                    dict(sub=sub, kind=kind, r_p50=float(np.percentile(r, 50)),
                         r_min=float(r.min()), n_mean=float(ns.mean()),
                         frac=float(ns.mean()/nblk), traffic=float(sp.mean())))
        res.append(entry)
    if a.json_out:
        json.dump(res, open(a.json_out, "w"), indent=2, default=float)
        print(f"\n[crowd] wrote {a.json_out}")


if __name__ == "__main__":
    main()
