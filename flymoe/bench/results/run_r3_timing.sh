#!/bin/bash
# Round-3 archived timing: one process at a time on GPU 0, node otherwise idle.
cd /workspace/aiter_fork/flymoe
R=bench/results
git -C .. rev-parse HEAD > $R/r3_timing_commit.txt
git -C .. status --short >> $R/r3_timing_commit.txt
for I in 384 768 1536; do
  python bench/compare.py --ref v3 --I $I --T 32 64 128 256 512 1024 2048 4096 8192 16384 32768 \
    --table 'configs/tiles_v4_I{I}.json' --out $R/r3_final_vs_v3_I$I.json 2>&1 | grep -E "^I=|rror|Traceback"
done > $R/r3_final_vs_v3.log
for I in 384 768 1536; do
  python bench/compare.py --ref v3 --flush --I $I --T 32 64 128 256 \
    --table 'configs/tiles_v4_I{I}.json' --out $R/r3_flush_vs_v3_I$I.json 2>&1 | grep -E "^I=|rror|Traceback"
done > $R/r3_flush_vs_v3.log
for I in 384 768 1536; do
  python bench/compare.py --ref v1 --I $I --T 4096 32768 \
    --table 'configs/tiles_v4_I{I}.json' --out $R/r3_vs_v1_I$I.json 2>&1 | grep -E "^I=|rror|Traceback"
done > $R/r3_vs_v1.log
python bench/bisect_s2.py --I 384 --T 8192 v3=/workspace/bisect/flymoe_v3:fm_flymoe_v3 \
  c7f24=/workspace/bisect/7f2480433:fm_7f2480433 c5db0=/workspace/bisect/5db00ad2b:fm_5db00ad2b \
  head_nos2w=/workspace/aiter_fork/flymoe:flymoe:nos2w head_nos2w_wpe3=/workspace/aiter_fork/flymoe:flymoe:nos2w+wpe3 \
  2>&1 | grep -E "^I=|rror|Traceback" > $R/r3_stage2_bisect.log
cd bench
for I in 384 768 1536; do for d in nos2w nos2w+wpe3; do
  python occupancy.py --I $I --s1 BM=256,NW=8,WM=2,pipe=pingpong,D=4,EF=1,MV=1 --s2 BM=128,NW=4,pipe=hybrid2,D=4,diag=$d 2>&1 | grep "^flymoe_s2"
done; done > results/r3_stage2_registers.log
echo done > results/r3_timing_done.txt
