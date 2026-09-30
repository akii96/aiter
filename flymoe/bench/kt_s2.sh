#!/bin/bash
# usage: kt_s2.sh GPU I T ARM  -> min kernel time per stage-2 kernel (rocprofv3 kernel trace)
G=$1; I=$2; T=$3; ARM=$4; D=/workspace/kt_$G
docker exec aaknawaz_m3_dev rm -rf $D
docker exec -e HIP_VISIBLE_DEVICES=$G aaknawaz_m3_dev bash -c "cd /workspace/aiter_fork/flymoe && rocprofv3 --kernel-trace --output-format csv -d $D -o run -- python bench/prof_cell.py --I $I --T $T --iters 5 --arm '$ARM' > /dev/null 2>&1"
docker exec aaknawaz_m3_dev bash -c "chown -R $(id -u):$(id -g) $D"
f=$(find /home/aaknawaz/kt_$G -name '*kernel_trace.csv' | head -1)
python3 - "$f" "$ARM" <<'PY'
import csv,sys,collections
d=collections.defaultdict(list)
for r in csv.DictReader(open(sys.argv[1])):
    n=r['Kernel_Name']
    if 'flymoe_s' in n or 'combine' in n:
        k=n.split('_')[1]+('_rows' if '_rows' in n else '_fused' if '_fused' in n else '')
        d[k].append((int(r['End_Timestamp'])-int(r['Start_Timestamp']))/1e3)
print(sys.argv[2], {k: round(min(v),1) for k,v in d.items()})
PY
