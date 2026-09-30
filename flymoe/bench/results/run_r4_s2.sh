#!/bin/bash
# Round 4 Phase 1: serial stage-2 sweep on GPU 0 (run under flock /tmp/gpu0_timing.lock).
cd /workspace/aiter_fork/flymoe
export HIP_VISIBLE_DEVICES=0
for I in 384 768 1536; do
  for T in 2048 8192 16384 32768; do
    python bench/s2_sweep.py --I $I --T $T --out bench/results/r4_s2_sweep_I${I}_T${T}.json --arms \
      "BM=128,NW=4,pipe=hybrid2,D=2,diag=wpe2" \
      "BM=128,NW=4,pipe=hybrid2,D=2,diag=wpe2+s2nt" \
      "BM=128,NW=4,pipe=hybrid2,D=3,diag=wpe2+s2nt" \
      "BM=64,NW=4,pipe=hybrid2,D=2,diag=wpe3+s2nt" \
      "BM=128,NW=4,pipe=async,D=2,diag=wpe2+s2nt,HT=1" \
      "BM=128,NW=4,pipe=hybrid2,D=2,diag=wpe2,FC=1" \
      "BM=128,NW=4,pipe=hybrid2,D=2,diag=wpe2+s2nt,HT=1" 2>&1 | grep "I=\|SKIP\|REJ"
  done
done
echo done > bench/results/r4_s2_sweep_done.txt
