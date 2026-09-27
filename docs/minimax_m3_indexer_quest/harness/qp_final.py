#!/usr/bin/env python3
"""
QUEST PREFILTER -- FINAL CONTROLLED EXPERIMENT

Isolates CAUSE from AGGRAVATOR by running the identical pruning measurement on
the PRE-RoPE index vectors (captured alongside the post-RoPE ones).

If the prefilter still fails pre-RoPE, then RoPE is not the reason and the
sqrt(D) L1-slack argument is the whole story. That is the difference between
"we could fix this by storing index_k pre-RoPE" (a cheap change worth doing)
and "this approach cannot work here at all" (close the path).

Also sweeps head_dim by truncation to show where, if anywhere, the method WOULD
have worked -- which is what makes the negative result actionable rather than
merely discouraging.
"""
import argparse
import numpy as np

TOPK, BLOCK, LOCAL = 16, 128, 1


def measure(K, Q, nblk, sub=1, label=""):
    R = Q.shape[0]
    dots = Q @ K.T
    sig = dots.std(1)
    ts = dots[:, :nblk*BLOCK].reshape(R, nblk, BLOCK).max(-1)
    cont = np.ones(nblk, bool); cont[nblk-LOCAL:] = False
    tsx = ts.copy(); tsx[:, nblk-LOCAL:] = 1e29
    kk = min(TOPK, nblk)
    Tstar = np.partition(tsx, -kk, 1)[:, -kk]

    g = BLOCK // sub
    KB = K[:nblk*BLOCK].reshape(nblk, sub, g, K.shape[1])
    mn = KB.min(2); mx = KB.max(2)
    mid = 0.5*(mn+mx); hw = 0.5*(mx-mn)
    bd = np.full((R, nblk), -np.inf, np.float32)
    for s_ in range(sub):
        bd = np.maximum(bd, Q @ mid[:, s_].T + np.abs(Q) @ hw[:, s_].T)
    bdx = bd.copy(); bdx[:, nblk-LOCAL:] = 1e29
    ns = ((bdx > Tstar[:, None]) & cont[None, :]).sum(1)
    slack = ((bd[:, cont] - ts[:, cont]) / sig[:, None]).mean()
    budget = ((Tstar - np.median(ts[:, cont], 1)) / sig).mean()
    sb = sub*2*K.shape[1]
    sp = (nblk*16384)/(nblk*sb + ns*16384)
    return dict(label=label, slack=float(slack), budget=float(budget),
                n=float(ns.mean()), frac=float(ns.mean()/nblk),
                traffic=float(sp.mean()), D=K.shape[1], sub=sub)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--npz", required=True)
    ap.add_argument("--ctx", type=int, default=131072)
    ap.add_argument("--queries", type=int, default=12)
    a = ap.parse_args()
    z = np.load(a.npz)
    ctx = a.ctx; nblk = ctx // BLOCK

    print("=" * 84)
    print("E1. CONTROLLED: post-RoPE vs pre-RoPE, identical everything else")
    print("=" * 84)
    print(f"  {'variant':<28} {'slack':>8} {'budget':>8} {'N*':>9} {'%read':>7} {'traffic':>8}")
    rows = []
    for tag, ks, qs in (("post-RoPE (as shipped)", "index_k_fp8", "index_q_fp8"),
                        ("pre-RoPE  (hypothetical)", "index_k_norope", "index_q_norope")):
        K = z[ks].astype(np.float32)[:ctx]
        Qa = z[qs].astype(np.float32)
        ti = np.linspace(ctx//2, min(ctx, Qa.shape[0])-1, a.queries).astype(int)
        Q = Qa[ti].reshape(-1, Qa.shape[-1])
        for sub in (1, 8):
            r = measure(K, Q, nblk, sub, f"{tag} sub={sub}")
            rows.append(r)
            print(f"  {r['label']:<28} {r['slack']:8.2f} {r['budget']:8.2f} "
                  f"{r['n']:9.1f} {100*r['frac']:6.1f}% {r['traffic']:7.2f}x")
    print("\n  If pre-RoPE also fails -> RoPE is an aggravator, not the cause.")

    print("\n" + "=" * 84)
    print("E2. WHERE WOULD THIS METHOD HAVE WORKED? (head_dim and block_size sweep)")
    print("=" * 84)
    K = z["index_k_fp8"].astype(np.float32)[:ctx]
    Qa = z["index_q_fp8"].astype(np.float32)
    ti = np.linspace(ctx//2, min(ctx, Qa.shape[0])-1, a.queries).astype(int)
    Qf = Qa[ti].reshape(-1, Qa.shape[-1])
    print(f"  {'head_dim':>9} {'tok/box':>8} {'slack':>8} {'budget':>8} {'%read':>7} {'traffic':>8}")
    for D in (16, 32, 64, 128):
        for sub in (1, 8):
            r = measure(K[:, :D], Qf[:, :D], nblk, sub)
            mark = "  <== WOULD WORK" if r["traffic"] > 2.0 else ""
            print(f"  {D:9d} {BLOCK//sub:8d} {r['slack']:8.2f} {r['budget']:8.2f} "
                  f"{100*r['frac']:6.1f}% {r['traffic']:7.2f}x{mark}")
    print("\n  Our config is head_dim=128, 128 tok/box (top-right of this table).")


if __name__ == "__main__":
    main()
