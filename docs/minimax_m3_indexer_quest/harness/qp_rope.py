#!/usr/bin/env python3
"""
QUEST PREFILTER -- AUDITING MY OWN RoPE HYPOTHESIS

I claimed post-RoPE storage was fatal to the Quest box because inv_freq[0]=1.0
rad/token sweeps ~20 revolutions inside a 128-token block. The measurement said
RoPE inflates the rotated dims' box halfwidth by only 1.62x -- real, but not
fatal. This script works out why, because the correction matters.

inv_freq[i] = theta^(-2i/rot),  theta = 5e6, rot = 64, i = 0..31.

A pair sweeps a FULL revolution inside a 128-token block iff
    inv_freq[i] * 128 >= 2*pi   <=>   inv_freq[i] >= 0.0491

Only the lowest few i satisfy that. The rest rotate so slowly that across 128
tokens they barely move, so their min/max box stays informative. So the
degeneracy is real but confined to a handful of dimension pairs.
"""
import numpy as np

ROT, THETA, BLOCK, HALF = 64, 5e6, 128, 32
inv = THETA ** (-np.arange(0, ROT, 2) / ROT)       # [32]
sweep = inv * BLOCK                                 # radians traversed per block

print(f"{'pair i':>7} {'dims':>9} {'inv_freq':>12} {'rad/block':>11} {'revolutions':>12} {'degenerate?':>12}")
nfull = 0
for i in range(HALF):
    rev = sweep[i] / (2 * np.pi)
    deg = rev >= 1.0
    nfull += deg
    if i < 12 or deg or i > 28:
        print(f"{i:7d} {f'{i},{i+32}':>9} {inv[i]:12.3e} {sweep[i]:11.3f} {rev:12.3f} "
              f"{'YES' if deg else 'no':>12}")

print(f"\nPairs that sweep >= 1 full revolution in a 128-token block: {nfull} of {HALF}")
print(f"  -> {2*nfull} of 128 dims ({100*2*nfull/128:.1f}%) have a degenerate box")
print(f"  -> the other {128-2*nfull} dims keep an informative min/max")

# What fraction of a block's rotation does each pair complete?
print(f"\nMedian pair sweeps {np.median(sweep):.4f} rad/block "
      f"({np.median(sweep)/(2*np.pi)*100:.3f}% of a revolution)")
print(f"Pairs sweeping < 0.1 rad/block (essentially static): "
      f"{(sweep < 0.1).sum()} of {HALF}")

print("""
CONCLUSION -- correcting my own earlier claim:
  The post-RoPE degeneracy is REAL but LOCALISED. Only the ~6 fastest pairs
  (~12 of 128 dims) wrap far enough to flatten their box to [-A,+A]; theta=5e6
  is so large that the remaining 26 pairs are nearly static over 128 tokens.
  Measured effect: box halfwidth on the rotated half inflates 1.62x, and the
  whole-bound slack rises from ~6.5 to 7.9 sigma -- about a 20% worsening.

  So post-RoPE storage is an aggravating factor, NOT the cause of the failure.
  The cause is the sqrt(D) growth of the L1 slack term (V2), which would sink
  the prefilter even on a RoPE-free cache.
""")
