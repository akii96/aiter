import sqlite3, collections, sys

db = sys.argv[1] if len(sys.argv) > 1 else "/tmp/rp3/pmc1_results.db"
c = sqlite3.connect(db)
rows = list(c.execute("""
 select kernel_name, dispatch_id, counter_name, value, duration, grid_size,
        workgroup_size, vgpr_count, accum_vgpr_count, lds_block_size
 from counters_collection"""))

SKIP = ("at::native", "elementwise", "reduce_kernel", "vectorized", "fill_", "CatArrayBatched")
agg = collections.defaultdict(lambda: collections.defaultdict(float))
meta = {}
for kn, did, cn, val, dur, gs, ws, v, av, lds in rows:
    if any(s in kn for s in SKIP):
        continue
    k = (kn, did)
    agg[k][cn] += (val or 0)
    meta[k] = (dur, gs, ws, v, av, lds)

byname = collections.defaultdict(list)
for (kn, did), d in agg.items():
    byname[kn].append((d, meta[(kn, did)]))

CLK, CU, SIMD = 2.4e9, 256, 4
PASSES = 16

print("%-56s %5s %9s %11s %10s %11s %8s %7s %6s %7s"
      % ("kernel", "n", "dur_us", "MFMA_inst", "MFMApipe%", "VALU_inst", "SQbusy%", "grid", "vgpr", "lds"))
print("-" * 145)
tot = 0.0
for kn, lst in sorted(byname.items(), key=lambda x: -(sum(m[0] for _, m in x[1]) / max(1, len(x[1])))):
    lst.sort(key=lambda x: x[1][0])
    d, m = lst[len(lst) // 2]
    dur, gs, ws, v, av, lds = m
    mfma = d.get("SQ_INSTS_MFMA", 0)
    valu = d.get("SQ_INSTS_VALU", 0)
    busy = d.get("SQ_BUSY_CYCLES", 0)
    avail = dur * 1e-9 * CLK * CU * SIMD
    mp = 100 * mfma * PASSES / avail if avail else 0
    sq = 100 * busy / (dur * 1e-9 * CLK * CU) if dur else 0
    print("%-56s %5d %9.1f %11.3e %9.1f%% %11.3e %7.1f%% %7d %6d %7d"
          % (kn.split("(")[0][:56], len(lst), dur / 1000.0, mfma, mp, valu, sq, int(gs), int(v), int(lds)))
    tot += dur / 1000.0
print("\nkernels listed: %d" % len(byname))
