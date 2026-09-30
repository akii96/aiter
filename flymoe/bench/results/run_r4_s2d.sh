#!/bin/bash
# Round 4: stage-2 sweep of every candidate cell on the final kernel sources (GPU 0, under flock).
# Supersedes r4_s2_sweep_* / r4_s2b_* / r4_s2c_*, which predate the prologue rewrite.
cd /workspace/aiter_fork/flymoe
export HIP_VISIBLE_DEVICES=0
A64="BM=64,NW=4,pipe=hybrid2,D=2,diag=wpe3+s2nt"
A128="BM=128,NW=4,pipe=hybrid2,D=2,diag=wpe2+s2nt"
for T in 512 1024 2048 4096 8192 16384 32768; do
  python -u bench/s2_sweep.py --I 384 --T $T --out bench/results/r4_s2d_I384_T${T}.json --arms \
    "$A64" "BM=64,NW=4,pipe=hybrid2,D=3,diag=wpe3+s2nt" "$A128" "$A128,HT=1" \
    "BM=128,NW=4,pipe=hybrid2,D=2,diag=wpe2"
done
for I in 768 1536; do
  for T in 512 1024 2048 4096 8192 16384 32768; do
    python -u bench/s2_sweep.py --I $I --T $T --out bench/results/r4_s2d_I${I}_T${T}.json --arms \
      "$A128" "$A128,FC=1" "$A128,HT=1" "$A128,HT=1,FC=1" "$A64" \
      "BM=128,NW=4,pipe=hybrid2,D=2,diag=wpe2,FC=1"
  done
done
echo done > bench/results/r4_s2d_done.txt
