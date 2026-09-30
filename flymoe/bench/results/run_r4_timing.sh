#!/bin/bash
# Round 4 final timing: serial, GPU 0 only, one process at a time (run under flock
# /tmp/gpu0_timing.lock with no other GPU jobs). Candidate = working tree + tiles_v5.
cd /workspace/aiter_fork/flymoe
export HIP_VISIBLE_DEVICES=0
R=bench/results
python -c "import sys; sys.path.insert(0, '.'); from flymoe import hw; print('SRC_HASH', hw.SRC_HASH)" > $R/r4_timing_srchash.txt
sha1sum configs/tiles_v5_I*.json flymoe/*.py >> $R/r4_timing_srchash.txt
ALL="32 64 128 256 512 1024 2048 4096 8192 16384 32768"
for I in 384 768 1536; do
  python -u bench/compare.py --ref v4 --table "configs/tiles_v5_I{I}.json" --I $I --T $ALL \
    --out $R/r4_final_vs_v4_I$I.json
done > $R/r4_final_vs_v4.log 2>&1
for I in 384 768 1536; do
  python -u bench/compare.py --ref v4 --table "configs/tiles_v5_I{I}.json" --I $I --T 32 64 128 256 \
    --flush --reps 7 --out $R/r4_flush_vs_v4_I$I.json
done > $R/r4_flush_vs_v4.log 2>&1
for I in 384 768 1536; do
  python -u bench/compare.py --ref v1 --table "configs/tiles_v5_I{I}.json" --I $I --T 4096 32768 \
    --out $R/r4_vs_v1_I$I.json
done > $R/r4_vs_v1.log 2>&1
echo done > $R/r4_timing_done.txt
