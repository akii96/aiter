#!/bin/bash
# Round 4 Phase 5: remaining stage-2 buckets and FC+s2nt combinations (GPU 0, under flock).
cd /workspace/aiter_fork/flymoe
export HIP_VISIBLE_DEVICES=0
A64="BM=64,NW=4,pipe=hybrid2,D=2,diag=wpe3+s2nt"
A128="BM=128,NW=4,pipe=hybrid2,D=2,diag=wpe2+s2nt"
for T in 512 1024 4096; do
  python -u bench/s2_sweep.py --I 384 --T $T --out bench/results/r4_s2b_I384_T${T}.json --arms \
    "$A64" "$A128" "$A128,HT=1" "BM=64,NW=4,pipe=hybrid2,D=3,diag=wpe3+s2nt"
done
for I in 768 1536; do
  for T in 512 1024 2048 4096 8192 16384; do
    python -u bench/s2_sweep.py --I $I --T $T --out bench/results/r4_s2b_I${I}_T${T}.json --arms \
      "$A128" "$A128,FC=1" "$A128,HT=1" "$A128,HT=1,FC=1" "$A64"
  done
done
echo done > bench/results/r4_s2b_done.txt
