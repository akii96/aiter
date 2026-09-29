#!/bin/bash
# TA / TCP pressure counters for one stage config.
#   bash bench/prof_ta.sh 1 1536 32768 BM=256,NW=8,WM=2,pipe=pingpong,D=3,EF=1,MV=1,AST=1
STAGE=$1; I=$2; T=$3; CFG=$4
OUT=$(mktemp -d /tmp/flyta_XXXX)
PASSES=(
  "TA_TA_BUSY_sum TA_ADDR_STALLED_BY_TC_CYCLES_sum TA_DATA_STALLED_BY_TC_CYCLES_sum GRBM_GUI_ACTIVE"
  "TCP_PENDING_STALL_CYCLES_sum TCP_TCC_READ_REQ_sum TCP_READ_TAGCONFLICT_STALL_CYCLES_sum TCP_TAGRAM0_REQ_sum"
  "TCP_LFIFO_STALL_CYCLES_sum TCP_RFIFO_STALL_CYCLES_sum TA_ADDR_STALLED_BY_TD_CYCLES_sum SQ_BUSY_CYCLES"
)
i=0
for P in "${PASSES[@]}"; do
  rocprofv3 --pmc $P --kernel-include-regex "flymoe_s${STAGE}" -d $OUT/p$i -o run --output-format csv \
    -- python bench/prof_stage.py --stage $STAGE --I $I --T $T --cfg $CFG >/dev/null 2>&1 || true
  i=$((i+1))
done
python3 - "$OUT" <<'PY'
import csv, glob, sys, collections
agg = collections.defaultdict(list)
for f in glob.glob(f"{sys.argv[1]}/**/*counter_collection.csv", recursive=True):
    for r in csv.DictReader(open(f)):
        agg[r["Counter_Name"]].append(float(r["Counter_Value"]))
for k in sorted(agg):
    v = agg[k]
    print(f"{k:40s} mean={sum(v)/len(v):.4g}")
PY
