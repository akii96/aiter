"""Summarize a rocprofv3 ATT stats CSV: cycles by instruction class and top stalls."""
import collections
import csv
import sys

rows = list(csv.DictReader(open(sys.argv[1])))
cat = collections.defaultdict(lambda: [0, 0, 0, 0])
tot = [0, 0, 0]
for r in rows:
    ins = r["Instruction"].strip()
    if ins.startswith(";") or not ins:
        continue
    op = ins.split()[0]
    if "mfma" in op:
        key = "mfma"
    elif op == "s_waitcnt":
        key = "waitcnt_vm" if "vmcnt" in ins else "waitcnt_lgkm"
    elif op == "s_barrier":
        key = "barrier"
    elif op.startswith("buffer_load") and ins.endswith(" lds"):
        key = "dma"
    elif op.startswith(("buffer_load", "global_load", "s_load", "s_buffer_load")):
        key = "load"
    elif op.startswith(("buffer_store", "global_store")):
        key = "store"
    elif op.startswith("ds_read"):
        key = "ds_read"
    elif op.startswith("ds_"):
        key = "ds_other"
    elif op.startswith("s_"):
        key = "salu"
    else:
        key = "valu"
    h, l, s, i = (int(r[k]) for k in ("Hitcount", "Latency", "Stall", "Idle"))
    c = cat[key]
    c[0] += h; c[1] += l; c[2] += s; c[3] += i
    tot[0] += l; tot[1] += s; tot[2] += i
print(f"total latency={tot[0]:.3e} stall={tot[1]:.3e} idle={tot[2]:.3e}")
for k, v in sorted(cat.items(), key=lambda kv: -kv[1][1]):
    print(f"{k:13s} hits={v[0]:9d} latency={v[1]:11d} ({100 * v[1] / max(tot[0], 1):5.1f}%) "
          f"stall={v[2]:11d} idle={v[3]:11d}")
print("--- top 15 instructions by latency (latency stall idle hits instr)")
for r in sorted(rows, key=lambda r: -int(r["Latency"]))[:15]:
    print(r["Latency"], r["Stall"], r["Idle"], r["Hitcount"], r["Instruction"][:90])
