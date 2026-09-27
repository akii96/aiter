#!/usr/bin/env python3
"""
QUEST PREFILTER -- PHASE 1 ANALYSIS v3

Adds the bound that this architecture actually needs.

WHY VANILLA QUEST IS EXPECTED TO BE LOOSE HERE
----------------------------------------------
index_k is stored POST-RoPE (verified: fused_qknorm_idxrqknorm.cu leaves
do_rope=true for the is_ik slot; only is_v clears it). Partial NeoX RoPE with
rotary_dim=64 rotates the pairs (i, i+32) for i in 0..31 by angle theta_i * pos.
The fastest frequency is inv_freq[0] = 1.0 rad/token, so across ONE 128-token
block that pair sweeps 128 rad ~ 20 full revolutions.

An elementwise min/max box over a coordinate that sweeps a full circle is
[-A, +A] -- the widest possible interval. So for the fast-rotating dims the
Quest box carries essentially NO information, and it is exactly those dims that
dominate the bound's slack. Quest's own setting used page_size=16 (8x fewer
tokens per box), which is why this did not bite them as hard.

THE FIX: A ROTATION-INVARIANT BOUND ON THE ROTATING HALF
--------------------------------------------------------
For a rotating pair, writing u = (k_i, k_{i+32}) PRE-rotation and the rotation
by angle phi:
    contribution = q_i*(k_i c - k_j s) + q_j*(k_j c + k_i s)
                 = c*(q_i k_i + q_j k_j) + s*(q_j k_i - q_i k_j)
which is an inner product of the fixed vector (q_i, q_j) with a rotated copy of
(k_i, k_j). Hence, for ANY phase whatsoever,
    |contribution| <= sqrt(q_i^2 + q_j^2) * sqrt(k_i^2 + k_j^2)
and sqrt(k_i^2+k_j^2) is ROTATION-INVARIANT -- identical pre- and post-RoPE.

So one scalar per pair per block,  A_i = max over the block's tokens of
|k_pair_i|, gives the valid upper bound

    rot_part <= sum_{i<32} |q_pair_i| * A_i

that is completely immune to the phase problem. The non-rotating dims 64..127
get the ordinary Quest box. Total summary:

    32 amplitudes + 2 x 64 box   = 160 bytes/block   (SMALLER than Quest's 256)

Bounds implemented
    box    : vanilla Quest elementwise min/max
    ball   : centroid + radius
    polar  : RoPE-aware (amplitudes on the rotating half, box on the rest)
    pbox   : min(polar, box)      -- both are valid, so the min is valid
"""
import argparse, json, time
import numpy as np

TOPK, BLOCK, LOCAL_BLOCKS, INIT_BLOCKS = 16, 128, 1, 0
ROT = 64          # rotary_dim
HALF = ROT // 2   # 32 rotating pairs


def summaries(K, nblk, sub, block=BLOCK):
    D = K.shape[1]; g = block // sub
    mn = np.full((nblk, sub, D), -np.inf, np.float32)
    mx = np.full((nblk, sub, D), -np.inf, np.float32)
    cen = np.zeros((nblk, sub, D), np.float32)
    rad = np.full((nblk, sub), -np.inf, np.float32)
    amp = np.zeros((nblk, sub, HALF), np.float32)      # rotating-pair amplitudes
    for b in range(nblk):
        for s_ in range(sub):
            s = b * block + s_ * g; e = min(s + g, K.shape[0])
            if e <= s: continue
            blk = K[s:e]
            mn[b, s_] = blk.min(0); mx[b, s_] = blk.max(0)
            c = blk.mean(0); cen[b, s_] = c
            rad[b, s_] = np.linalg.norm(blk - c, axis=1).max()
            amp[b, s_] = np.sqrt(blk[:, :HALF] ** 2 + blk[:, HALF:ROT] ** 2).max(0)
    return mn, mx, cen, rad, amp


def bounds_for(Q, mn, mx, cen, rad, amp, kind):
    R = Q.shape[0]; nblk, sub, D = mn.shape
    out = np.full((R, nblk), -np.inf, np.float32)
    live = np.isfinite(rad)
    qpair = np.sqrt(Q[:, :HALF] ** 2 + Q[:, HALF:ROT] ** 2)      # [R, HALF]
    qn = np.linalg.norm(Q, axis=1)
    for s_ in range(sub):
        L = live[:, s_]
        if not L.any(): continue
        bx = bl = po = None
        if kind in ("box", "pbox"):
            mid = 0.5 * (mn[L, s_] + mx[L, s_]); hw = 0.5 * (mx[L, s_] - mn[L, s_])
            bx = Q @ mid.T + np.abs(Q) @ hw.T
        if kind == "ball":
            bl = Q @ cen[L, s_].T + qn[:, None] * rad[L, s_][None, :]
        if kind in ("polar", "pbox"):
            # rotating half: rotation-invariant amplitude bound
            rot = qpair @ amp[L, s_].T
            # non-rotating dims ROT..D: ordinary box
            midn = 0.5 * (mn[L, s_, ROT:] + mx[L, s_, ROT:])
            hwn = 0.5 * (mx[L, s_, ROT:] - mn[L, s_, ROT:])
            nonrot = Q[:, ROT:] @ midn.T + np.abs(Q[:, ROT:]) @ hwn.T
            po = rot + nonrot
        v = {"box": bx, "ball": bl, "polar": po}.get(kind)
        if kind == "pbox": v = np.minimum(bx, po)
        out[:, L] = np.maximum(out[:, L], v)
    return out


SUMBYTES = {"box": lambda s: s * 2 * 128,
            "ball": lambda s: s * (128 + 4),
            "polar": lambda s: s * (HALF + 2 * 64),
            "pbox": lambda s: s * (2 * 128 + HALF)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--npz", required=True)
    ap.add_argument("--ctx", type=int, nargs="+", required=True)
    ap.add_argument("--queries", type=int, default=64)
    ap.add_argument("--rope", choices=["rope", "norope"], default="rope")
    ap.add_argument("--sub", type=int, nargs="+", default=[1])
    ap.add_argument("--bound", nargs="+", default=["box", "polar", "pbox"])
    ap.add_argument("--json-out", default=None)
    a = ap.parse_args()

    z = np.load(a.npz)
    suf = "_fp8" if a.rope == "rope" else "_norope"
    K = z["index_k" + suf].astype(np.float32)
    Qa = z["index_q" + suf].astype(np.float32)
    print(f"[a3] K={K.shape} Q={Qa.shape} rope={a.rope}", flush=True)

    res = []
    for ctx in a.ctx:
        if ctx > K.shape[0]:
            print(f"[a3] skip ctx={ctx} > {K.shape[0]}"); continue
        Kc = K[:ctx]; nblk = ctx // BLOCK
        ti = np.linspace(ctx // 2, min(ctx, Qa.shape[0]) - 1, a.queries).astype(int)
        Q = Qa[ti].reshape(-1, Qa.shape[-1])

        t0 = time.time()
        ts = (Q @ Kc.T)[:, :nblk * BLOCK].reshape(Q.shape[0], nblk, BLOCK).max(-1)
        contested = np.ones(nblk, bool); contested[nblk - LOCAL_BLOCKS:] = False
        tsx = ts.copy(); tsx[:, nblk - LOCAL_BLOCKS:] = 1e29
        kk = min(TOPK, nblk)
        Tstar = np.partition(tsx, -kk, axis=1)[:, -kk]

        tc = ts[:, contested]
        srt = np.sort(tc, 1)[:, ::-1]
        print(f"\n##### ctx={ctx} nblk={nblk} R={Q.shape[0]} ({time.time()-t0:.1f}s) #####")
        print(f"  true: top1={srt[:,0].mean():.2f} top16={srt[:,min(15,srt.shape[1]-1)].mean():.2f} "
              f"med={np.median(tc,1).mean():.2f} min={tc.min(1).mean():.2f} "
              f"std={tc.std(1).mean():.2f}")
        # how selective is the task at all: ratio of T* to the median block
        print(f"  selectivity T*/median = {(Tstar/np.median(tc,1)).mean():.3f}  "
              f"T*/top1 = {(Tstar/srt[:,0]).mean():.3f}")

        for sub in a.sub:
            mn, mx, cen, rad, amp = summaries(Kc, nblk, sub)
            for kind in a.bound:
                bd = bounds_for(Q, mn, mx, cen, rad, amp, kind)
                bdx = bd.copy(); bdx[:, nblk - LOCAL_BLOCKS:] = 1e29
                ns = ((bdx > Tstar[:, None]) & contested[None, :]).sum(1).astype(float)
                m = contested[None, :] & np.isfinite(ts) & (np.abs(ts) > 1e-9)
                ratio = bd[m] / ts[m]
                sb = SUMBYTES[kind](sub)
                base = nblk * 16384
                sp = base / (nblk * sb + ns * 16384)
                print(f"  [{kind:5s} sub={sub}] {sb:5d}B/blk | ratio p50={np.percentile(ratio,50):6.2f} "
                      f"p99={np.percentile(ratio,99):6.2f} | N* mean={ns.mean():6.1f} "
                      f"p99={np.percentile(ns,99):5.0f} max={ns.max():5.0f} /{nblk} "
                      f"({100*ns.mean()/nblk:5.1f}%) | TRAFFIC {sp.mean():5.2f}x")
                caps = {}
                for C in (16, 24, 32, 48, 64, 96, 128, 192, 256, 384, 512):
                    if C > nblk: break
                    caps[C] = dict(fallback=float((ns > C).mean()),
                                   speedup=float(base / (nblk * sb + C * 16384)))
                print("        cap " + "  ".join(
                    f"C{C}:{v['fallback']*100:.1f}%/{v['speedup']:.1f}x" for C, v in caps.items()))
                res.append(dict(ctx=ctx, nblk=nblk, sub=sub, bound=kind, sum_bytes=sb,
                                ratio_p50=float(np.percentile(ratio, 50)),
                                ratio_p99=float(np.percentile(ratio, 99)),
                                n_mean=float(ns.mean()), n_p99=float(np.percentile(ns, 99)),
                                n_p999=float(np.percentile(ns, 99.9)), n_max=float(ns.max()),
                                frac=float(ns.mean() / nblk), traffic=float(sp.mean()),
                                cap=caps))
    if a.json_out:
        json.dump(res, open(a.json_out, "w"), indent=2, default=float)
        print(f"\n[a3] wrote {a.json_out}")


if __name__ == "__main__":
    main()
