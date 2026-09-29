"""Per-wave phase timing from a rocprofv3 ATT ui_output dir (ping-pong kernels).

compute phase = s_setprio 1 .. s_setprio 0; memory phase = s_setprio 0 .. next s_setprio 1.
"""
import glob
import json
import statistics
import sys

d = sys.argv[1]
code = json.load(open(f"{d}/code.json"))["code"]
text = {c[2]: c[0] for c in code}
res = []
for f in sorted(glob.glob(f"{d}/se*_wv*.json")):
    w = json.load(open(f))["wave"]
    marks = []
    for ins in w["instructions"]:
        t, idx = ins[0], ins[4]
        s = text.get(idx, "")
        if s.startswith("s_setprio 1"):
            marks.append(("c", t))
        elif s.startswith("s_setprio 0"):
            marks.append(("m", t))
    comp, mem = [], []
    for (a, ta), (b, tb) in zip(marks, marks[1:]):
        (comp if a == "c" else mem).append(tb - ta)
    if comp:
        res.append((f.split("/")[-1], w["simd"], len(comp), statistics.median(comp),
                    statistics.median(mem) if mem else 0, w["end"] - w["begin"]))
for r in res[:16]:
    print(f"{r[0]:22s} simd={r[1]} phases={r[2]:3d} compute_med={r[3]:6.0f} mem_med={r[4]:6.0f} wave_dur={r[5]}")
cm = statistics.median([r[3] for r in res]); mm = statistics.median([r[4] for r in res])
print(f"ALL waves: compute phase median {cm:.0f} cyc, memory phase median {mm:.0f} cyc "
      f"-> MFMA duty per SIMD ~ {2 * cm / (cm + mm) * 100 / 2:.0f}% of 2-wave ideal")
