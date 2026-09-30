#!/bin/bash
# usage: att_cell.sh GPU OUTNAME I T ARM REGEX [tile_mfmas] -> ATT decode under ~/att_r5/OUTNAME + budget
G=$1; OUT=$2; I=$3; T=$4; ARM=$5; RX=$6; TM=${7:-0}
docker exec -e HIP_VISIBLE_DEVICES=$G aaknawaz_m3_dev bash -c "rm -rf /workspace/att_r5/$OUT; cd /workspace/aiter_fork/flymoe && rocprofv3 --att --att-library-path /workspace/tools/trace_decoder/rocprof-trace-decoder-manylinux-2.28-0.1.6-Linux/opt/rocm/lib --att-target-cu 1 --kernel-include-regex '$RX' -d /workspace/att_r5/$OUT -o run -- python bench/prof_cell.py --I $I --T $T --arm '$ARM' --iters 1 >/dev/null 2>&1; chown -R $(id -u):$(id -g) /workspace/att_r5/$OUT"
d=$(ls -d /home/aaknawaz/att_r5/$OUT/ui_output_* | tail -1); echo $d
if [ "$TM" != "0" ]; then python3 /home/aaknawaz/aiter_fork/flymoe/bench/att_budget.py $d --tile-mfmas $TM; else python3 /home/aaknawaz/aiter_fork/flymoe/bench/att_budget.py $d; fi
