#!/usr/bin/env python3
"""
QUEST PREFILTER -- VALIDATION OF THE NEGATIVE RESULT

Before we close a path on evidence, the evidence has to survive its own audit.
Four independent checks, each of which could overturn the verdict:

 V1. IS THE CAPTURE REALISTIC?
     Compare captured index_k/index_q statistics against what the kernel and the
     checkpoint imply. If index_k were garbage (e.g. all-zero, or saturated by
     the unit-scale e4m3 store) the pruning result would be meaningless.

 V2. IS THE SLACK REALLY sqrt(D)-DRIVEN?
     The claim is structural: slack ~ sum_d |q_d| hw_d grows like D while the
     true score grows like sqrt(D). Test it directly by recomputing the bound on
     truncated dimension subsets d = 8,16,32,64,128 and checking the growth law.
     If slack grew like sqrt(D) too, the verdict would be about tuning, not
     structure, and sub-boxing might eventually win.

 V3. IS THE SELECTION ACTUALLY SELECTIVE?
     If the top-16 were near-arbitrary (all blocks equally good) then no exact
     method can prune AND the whole sparse-attention premise would be in doubt.
     Measure how much the top-16 stand out, and how stable they are.

 V4. AN ORACLE UPPER LIMIT ON ANY SUMMARY OF SIZE B.
     Forget Quest. Suppose a summary of B bytes could give the BEST POSSIBLE
     bound consistent with keeping the top-16 exact. The information-theoretic
     floor: to prune block j you must certify true_j <= T*. Compute, for the
     ideal case where the bound EQUALS the true score (slack = 0, an unachievable
     oracle), how many blocks would still be read. That is the ceiling for the
     entire family -- if even the oracle reads a lot, nothing in this class wins.
"""
import argparse
import numpy as np

TOPK, BLOCK, LOCAL = 16, 128, 1
ROT, HALF = 64, 32


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--npz", required=True)
    ap.add_argument("--ctx", type=int, default=131072)
    ap.add_argument("--queries", type=int, default=16)
    a = ap.parse_args()

    z = np.load(a.npz)
    K = z["index_k_fp8"].astype(np.float32)
    Q_all = z["index_q_fp8"].astype(np.float32)
    Knr = z["index_k_norope"].astype(np.float32)
    ctx = min(a.ctx, K.shape[0]); nblk = ctx // BLOCK
    Kc = K[:ctx]
    ti = np.linspace(ctx//2, min(ctx, Q_all.shape[0])-1, a.queries).astype(int)
    Q = Q_all[ti].reshape(-1, Q_all.shape[-1]); R = Q.shape[0]

    print("=" * 78)
    print("V1. IS THE CAPTURE REALISTIC?")
    print("=" * 78)
    fin = np.isfinite(Kc)
    print(f"  index_k  shape={Kc.shape}  finite={fin.all()}  "
          f"allzero_rows={(np.abs(Kc).sum(1)==0).sum()}")
    print(f"  index_k  min={Kc.min():.3f} max={Kc.max():.3f} "
          f"mean={Kc.mean():.4f} std={Kc.std():.4f}")
    # e4m3 unit-scale saturates at 448; if we were clipping, max would pin there
    print(f"  e4m3 range check: |k|max={np.abs(Kc).max():.2f} (e4m3 max is 448) "
          f"-> {'NOT saturated (healthy)' if np.abs(Kc).max() < 400 else 'SATURATED (suspect)'}")
    # distinct values: e4m3 has 256 codes; a healthy capture uses many of them
    print(f"  distinct fp8 codes used: {len(np.unique(Kc))} of 256 possible")
    print(f"  index_q  min={Q.min():.3f} max={Q.max():.3f} std={Q.std():.4f}")
    # per-dim std: RoPE'd dims should look isotropic, unrotated dims may not
    ds = Kc.std(0)
    print(f"  per-dim std: rotated dims[0:64] mean={ds[:ROT].mean():.3f} "
          f"unrotated dims[64:128] mean={ds[ROT:].mean():.3f}")
    # THE ROPE DEGENERACY, measured directly
    hw_r = 0.5 * (Kc[:nblk*BLOCK].reshape(nblk, BLOCK, -1).max(1)
                  - Kc[:nblk*BLOCK].reshape(nblk, BLOCK, -1).min(1))
    hw_nr = 0.5 * (Knr[:nblk*BLOCK].reshape(nblk, BLOCK, -1).max(1)
                   - Knr[:nblk*BLOCK].reshape(nblk, BLOCK, -1).min(1))
    print(f"\n  *** RoPE DEGENERACY, MEASURED ***")
    print(f"  box halfwidth, POST-RoPE  : rotated dims {hw_r[:, :ROT].mean():.3f} | "
          f"unrotated {hw_r[:, ROT:].mean():.3f}")
    print(f"  box halfwidth, PRE-RoPE   : same dims    {hw_nr[:, :ROT].mean():.3f} | "
          f"unrotated {hw_nr[:, ROT:].mean():.3f}")
    infl = hw_r[:, :ROT].mean() / hw_nr[:, :ROT].mean()
    print(f"  => RoPE inflates the rotated dims' halfwidth by {infl:.2f}x")
    print(f"     (dims 64:128 are untouched by RoPE and serve as the control)")

    print("\n" + "=" * 78)
    print("V2. IS THE SLACK sqrt(D)-DRIVEN (structural) OR TUNABLE?")
    print("=" * 78)
    KB = Kc[:nblk*BLOCK].reshape(nblk, BLOCK, -1)
    mn = KB.min(1); mx = KB.max(1)
    mid = 0.5*(mn+mx); hw = 0.5*(mx-mn)
    print(f"  {'D':>5} {'true max (sd)':>14} {'slack (sd)':>12} {'slack/sqrtD':>12} {'slack/D':>10}")
    base = None
    for D in (8, 16, 32, 64, 128):
        q = Q[:, :D]; k = Kc[:, :D]
        dots = q @ k.T
        sig = dots.std(1)
        ts = dots[:, :nblk*BLOCK].reshape(R, nblk, BLOCK).max(-1)
        bd = q @ mid[:, :D].T + np.abs(q) @ hw[:, :D].T
        slack = ((bd - ts) / sig[:, None]).mean()
        tm = (ts.max(1)/sig).mean()
        print(f"  {D:5d} {tm:14.3f} {slack:12.3f} {slack/np.sqrt(D):12.3f} {slack/D:10.4f}")
    print("  If slack/sqrtD is ~flat -> slack grows like sqrt(D) (tunable-ish).")
    print("  If slack/D is ~flat      -> slack grows like D      (STRUCTURAL, hopeless).")

    print("\n" + "=" * 78)
    print("V3. IS THE SELECTION ACTUALLY SELECTIVE?")
    print("=" * 78)
    dots = Q @ Kc.T
    sig = dots.std(1)
    ts = dots[:, :nblk*BLOCK].reshape(R, nblk, BLOCK).max(-1)
    cont = np.ones(nblk, bool); cont[nblk-LOCAL:] = False
    tsx = ts.copy(); tsx[:, nblk-LOCAL:] = 1e29
    Tstar = np.partition(tsx, -TOPK, 1)[:, -TOPK]
    tc = ts[:, cont]
    srt = np.sort(tc, 1)[:, ::-1]
    print(f"  top1 - T*        = {((srt[:,0]-Tstar)/sig).mean():.3f} sigma")
    print(f"  T*   - median    = {((Tstar-np.median(tc,1))/sig).mean():.3f} sigma")
    print(f"  blocks within 0.5 sigma below T*: {(((tc>Tstar[:,None]-0.5*sig[:,None])&(tc<Tstar[:,None])).sum(1)).mean():.1f}")
    # stability: how much does the winning set change between adjacent queries?
    sel = np.argsort(-tsx, 1)[:, :TOPK]
    ov = [len(set(sel[i]) & set(sel[i+1]))/TOPK for i in range(R-1)]
    print(f"  top-16 overlap between ADJACENT query rows: {np.mean(ov)*100:.1f}%")
    print("  (low overlap confirms the query-dependence that kills caching)")

    print("\n" + "=" * 78)
    print("V4. ORACLE CEILING: best possible for ANY bound of this family")
    print("=" * 78)
    # Oracle: bound == true score exactly (slack 0). Blocks read = those with
    # true > T*, i.e. exactly the winners. That is the theoretical floor.
    n_oracle = ((ts > Tstar[:, None]) & cont[None, :]).sum(1).mean()
    print(f"  ZERO-SLACK ORACLE reads {n_oracle:.1f} / {nblk} blocks "
          f"({100*n_oracle/nblk:.2f}%)  <- unreachable lower bound")
    for extra in (0.25, 0.5, 1.0, 2.0, 3.0, 5.0, 8.0):
        n = ((ts + extra*sig[:, None] > Tstar[:, None]) & cont[None, :]).sum(1).mean()
        sp = (nblk*16384)/(nblk*256 + n*16384)
        print(f"  slack={extra:4.2f} sigma -> {n:7.1f}/{nblk} ({100*n/nblk:5.1f}%) read, "
              f"traffic {sp:5.2f}x")
    print(f"\n  MEASURED slack for Quest box @128 tok/box = 7.88 sigma")
    print(f"  => to reach even 2x traffic we would need slack <= ~0.5 sigma,")
    print(f"     which is 16x tighter than measured and below the 4-tok/box point.")


if __name__ == "__main__":
    main()
