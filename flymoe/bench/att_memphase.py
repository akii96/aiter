"""Where the ping-pong memory phase time goes (per-instruction gaps, ATT ui_output)."""
import collections
import glob
import json
import sys

d = sys.argv[1]
code = json.load(open(f"{d}/code.json"))["code"]
text = {c[2]: c[0] for c in code}


def cls(s):
    op = s.split()[0] if s else ""
    if op == "s_barrier":
        return "barrier"
    if op == "s_waitcnt":
        return "wait_vm" if "vmcnt" in s else "wait_lgkm"
    if op.startswith("buffer_load") and s.rstrip().endswith("lds"):
        return "dma"
    if op.startswith("ds_read"):
        return "ds_read"
    if "mfma" in op:
        return "mfma"
    if op.startswith("s_"):
        return "salu"
    return "valu"


tot = collections.Counter()
n_phase = 0
for f in sorted(glob.glob(f"{d}/se*_wv*.json")):
    ins = json.load(open(f))["wave"]["instructions"]
    in_mem = False
    for a, b in zip(ins, ins[1:]):
        s = text.get(a[4], "")
        if s.startswith("s_setprio 0"):
            in_mem = True
            n_phase += 1
            continue
        if s.startswith("s_setprio 1"):
            in_mem = False
            continue
        if in_mem:
            tot[cls(s)] += b[0] - a[0]
all_ = sum(tot.values())
print(f"memory phases: {n_phase}, avg {all_ / max(n_phase, 1):.0f} cycles")
for k, v in tot.most_common():
    print(f"  {k:10s} {v / max(n_phase, 1):7.0f} cyc/phase ({100 * v / all_:4.1f}%)")
