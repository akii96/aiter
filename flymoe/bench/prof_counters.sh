#!/bin/bash
# Collect hardware counters for one stage config; prints per-counter mean over the
# profiled launches of the flymoe stage kernel.
#   bash bench/prof_counters.sh 1 1536 32768 BM=128,NW=4,pipe=hybrid2,D=3
set -e
STAGE=$1; I=$2; T=$3; CFG=$4
OUT=$(mktemp -d /tmp/flyprof_XXXX)
PASSES=(
  "SQ_WAVE_CYCLES SQ_BUSY_CYCLES SQ_WAIT_INST_ANY SQ_VALU_MFMA_BUSY_CYCLES"
  "SQ_LDS_BANK_CONFLICT SQ_LDS_IDX_ACTIVE SQ_WAIT_INST_LDS SQ_INSTS_LDS"
  "TCC_HIT_sum TCC_MISS_sum TCC_EA0_RDREQ_sum TCC_REQ_sum"
  "GRBM_GUI_ACTIVE SQ_INSTS_MFMA SQ_INSTS_VMEM_RD SQ_WAVES"
)
i=0
for P in "${PASSES[@]}"; do
  rocprofv3 --pmc $P --kernel-include-regex "flymoe_s${STAGE}" -d $OUT/p$i -o run --output-format csv \
    -- python bench/prof_stage.py --stage $STAGE --I $I --T $T --cfg $CFG >/dev/null 2>&1 || true
  i=$((i+1))
done
python3 - "$OUT" <<'EOF'
import csv, glob, sys, collections
out = sys.argv[1]
agg = collections.defaultdict(list)
for f in glob.glob(f"{out}/**/*counter_collection.csv", recursive=True):
    for r in csv.DictReader(open(f)):
        agg[r["Counter_Name"]].append(float(r["Counter_Value"]))
# counter rows are per dispatch (summed over dimensions by rocprofv3 in recent versions)
for k in sorted(agg):
    v = agg[k]
    print(f"{k:28s} mean={sum(v)/len(v):.4g} n={len(v)}")
EOF
