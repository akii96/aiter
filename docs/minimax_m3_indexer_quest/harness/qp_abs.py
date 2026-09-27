#!/usr/bin/env python3
"""
QUEST PREFILTER -- ABSOLUTE-SCALE DIAGNOSTIC (the mechanism)

The ratio bound/true is a BAD metric here: q.k straddles zero, so for blocks with
true ~ 0 the ratio explodes and for true < 0 it goes negative. Percentiles of it
are meaningless. This script uses the only criterion that matters:

    block j must have its 16 KB of keys read  <=>  bound_j > T*

and explains the outcome on the natural ABSOLUTE scale, in units of

    sigma = std over tokens of (q . k)   -- the natural scale of the score.

The structural claim being tested
---------------------------------
    true_j  = max over 128 tokens of q.k     ~  sigma * sqrt(2 ln 128)  ~ 3.1 sigma
    bound_j = sum_d ( q_d*mid_d + |q_d|*hw_d )

The second term is an L1 object: sum_d |q_d| * hw_d. With D=128 dims it
accumulates ~D terms of size |q_d|*hw_d, whereas q.k concentrates like sqrt(D).
So the bound exceeds the true score by a factor that GROWS like sqrt(D) --
this is a dimensionality problem, not a tuning problem.

If that is what we see, then no amount of sub-boxing fixes it: sub-boxing only
shrinks hw by the expected-range ratio of n samples (range(128)/range(16) ~ 1.43),
while the gap we must close is ~5x, and the summary cost grows 8x.
"""
import argparse, json
import numpy as np

TOPK, BLOCK, LOCAL = 16, 128, 1
ROT, HALF = 64, 32


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--npz", required=True)
    ap.add_argument("--ctx", type=int, nargs="+", required=True)
    ap.add_argument("--queries", type=int, default=16)
    ap.add_argument("--sub", type=int, nargs="+", default=[1, 2, 4, 8, 16, 32])
    ap.add_argument("--json-out", default=None)
    a = ap.parse_args()

    z = np.load(a.npz)
    K = z["index_k_fp8"].astype(np.float32)
    Qa = z["index_q_fp8"].astype(np.float32)
    print(f"[abs] K={K.shape} Q={Qa.shape}")
    out = []

    for ctx in a.ctx:
        if ctx > K.shape[0]:
            continue
        Kc = K[:ctx]; nblk = ctx // BLOCK
        ti = np.linspace(ctx // 2, min(ctx, Qa.shape[0]) - 1, a.queries).astype(int)
        Q = Qa[ti].reshape(-1, Qa.shape[-1]); R = Q.shape[0]

        dots = Q @ Kc.T                                   # [R, ctx]
        sigma = dots.std(1)                               # [R] natural scale
        ts = dots[:, :nblk*BLOCK].reshape(R, nblk, BLOCK).max(-1)
        cont = np.ones(nblk, bool); cont[nblk-LOCAL:] = False
        tsx = ts.copy(); tsx[:, nblk-LOCAL:] = 1e29
        kk = min(TOPK, nblk)
        Tstar = np.partition(tsx, -kk, 1)[:, -kk]

        tc = ts[:, cont]
        s = sigma[:, None]
        print(f"\n######### ctx={ctx} nblk={nblk} rows={R} #########")
        print(f"  sigma (std of q.k over tokens)      = {sigma.mean():.3f}")
        print(f"  true block scores, in units of sigma:")
        print(f"     max  {(tc.max(1)/sigma).mean():6.2f}   "
              f"p99 {(np.percentile(tc,99,1)/sigma).mean():6.2f}   "
              f"med {(np.median(tc,1)/sigma).mean():6.2f}   "
              f"min {(tc.min(1)/sigma).mean():6.2f}")
        print(f"     T* (16th best)                   = {(Tstar/sigma).mean():6.2f} sigma")
        print(f"     spread T* - median               = {((Tstar-np.median(tc,1))/sigma).mean():6.2f} sigma"
              f"   <-- the budget a bound must fit inside")

        e = dict(ctx=ctx, nblk=nblk, sigma=float(sigma.mean()),
                 Tstar_sigma=float((Tstar/sigma).mean()),
                 true_max_sigma=float((tc.max(1)/sigma).mean()),
                 true_med_sigma=float((np.median(tc,1)/sigma).mean()),
                 budget_sigma=float(((Tstar-np.median(tc,1))/sigma).mean()),
                 subs=[])

        for sub in a.sub:
            g = BLOCK // sub
            if g < 1: continue
            # vectorised summaries
            KB = Kc[:nblk*BLOCK].reshape(nblk, sub, g, Kc.shape[1])
            mn = KB.min(2); mx = KB.max(2)                        # [nblk,sub,D]
            mid = 0.5*(mn+mx); hw = 0.5*(mx-mn)
            amp = np.sqrt(KB[..., :HALF]**2 + KB[..., HALF:ROT]**2).max(2)  # [nblk,sub,HALF]

            qp = np.sqrt(Q[:, :HALF]**2 + Q[:, HALF:ROT]**2)
            bx = np.full((R, nblk), -np.inf, np.float32)
            po = np.full((R, nblk), -np.inf, np.float32)
            for s_ in range(sub):
                bx = np.maximum(bx, Q @ mid[:, s_].T + np.abs(Q) @ hw[:, s_].T)
                po = np.maximum(po, qp @ amp[:, s_].T
                                + Q[:, ROT:] @ mid[:, s_, ROT:].T
                                + np.abs(Q[:, ROT:]) @ hw[:, s_, ROT:].T)
            pb = np.minimum(bx, po)

            row = dict(sub=sub, tokens_per_box=g)
            for kind, bd in (("box", bx), ("polar", po), ("pbox", pb)):
                bdx = bd.copy(); bdx[:, nblk-LOCAL:] = 1e29
                ns = ((bdx > Tstar[:, None]) & cont[None, :]).sum(1)
                gap = (bd[:, cont] - ts[:, cont]) / s          # absolute slack, sigma units
                # how far above T* the bound sits for the MEDIAN block
                excess = (np.median(bd[:, cont], 1) - Tstar) / sigma
                sb = {"box": sub*256, "polar": sub*160, "pbox": sub*288}[kind]
                base = nblk*16384
                sp = base/(nblk*sb + ns*16384)
                print(f"   [{kind:5s} sub={sub:2d} {g:3d}tok/box {sb:5d}B] "
                      f"slack={gap.mean():6.2f}s (need <={e['budget_sigma']:.2f}s) | "
                      f"median bound is {excess.mean():+6.2f}s above T* | "
                      f"N*={ns.mean():7.1f}/{nblk} ({100*ns.mean()/nblk:5.1f}%) | "
                      f"traffic {sp.mean():.2f}x")
                row[kind] = dict(slack_sigma=float(gap.mean()),
                                 excess_sigma=float(excess.mean()),
                                 n_mean=float(ns.mean()),
                                 frac=float(ns.mean()/nblk),
                                 traffic=float(sp.mean()), sum_bytes=sb)
            e["subs"].append(row)
        out.append(e)

    if a.json_out:
        json.dump(out, open(a.json_out, "w"), indent=2, default=float)
        print(f"\n[abs] wrote {a.json_out}")


if __name__ == "__main__":
    main()
