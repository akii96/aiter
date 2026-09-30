"""Occupancy probe: registers, LDS and resident waves/CTAs for each GEMM variant.

Compiles the requested stage-1 / stage-2 variants with FLYDSL_DUMP_IR into a
private dump dir and parses the final ISA metadata. gfx950: 512 unified
VGPR+AGPR registers per lane per SIMD (granule 8), up to 8 waves/SIMD,
160 KB LDS per CU, 4 SIMDs per CU.

usage: python bench/occupancy.py --I 1536 --s1 BM=128,NW=4,pipe=hybrid,D=3 --s2 BM=128,NW=4,pipe=async,D=2
"""

import argparse
import glob
import os
import re
import sys
import tempfile

DUMP = tempfile.mkdtemp(prefix="flymoe_occ_")
os.environ["FLYDSL_DUMP_IR"] = "1"
os.environ["FLYDSL_DUMP_DIR"] = DUMP
os.environ["FLYDSL_RUNTIME_CACHE_DIR"] = os.path.join(DUMP, "cache")

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))

import io  # noqa: E402
import contextlib  # noqa: E402

from flymoe import moe  # noqa: E402
from tests.test_moe import make_problem  # noqa: E402


def parse_isa(path):
    txt = open(path).read()

    def grab(key):
        m = re.search(rf"\.{key}:\s+(\d+)", txt)
        return int(m.group(1)) if m else 0

    vgpr, agpr, lds = grab("vgpr_count"), grab("agpr_count"), grab("group_segment_fixed_size")
    spill = grab("vgpr_spill_count") + grab("sgpr_spill_count")
    scratch = grab("private_segment_fixed_size")
    return dict(vgpr=vgpr, agpr=agpr, lds=lds, spill=spill, scratch=scratch,
                mfma=txt.count("v_mfma"), barrier=txt.count("s_barrier"), waitcnt=txt.count("s_waitcnt"))


def occupancy(info, nw):
    regs = ((max(info["vgpr"], 1) + 7) // 8) * 8
    waves_simd = min(8, 512 // regs)
    cta_by_waves = (waves_simd * 4) // nw
    cta_by_lds = (160 * 1024) // info["lds"] if info["lds"] else 99
    ctas = min(cta_by_waves, cta_by_lds)
    return dict(waves_per_simd=waves_simd, ctas_per_cu=ctas, waves_per_cu=ctas * nw,
                limiter="lds" if cta_by_lds < cta_by_waves else "regs")


def kv(s):
    d = {}
    for part in s.split(","):
        k, v = part.split("=")
        d[k] = int(v) if v.isdigit() else v
    return d


def probe(I, s1, s2, T=64, extra=None):
    x, ids, w, wts = make_problem(T, I)
    kw = {f"{k}1": v for k, v in s1.items()}
    kw.update({f"{k}2": v for k, v in s2.items()})
    kw.update(extra or {})
    run = moe.MoERun(x, ids, w, moe.MoEWeights(*wts), **kw)
    with contextlib.redirect_stdout(io.StringIO()):
        run.forward()
    rows = []
    for d in sorted(glob.glob(os.path.join(DUMP, "flymoe_s[12]_*"))):
        isa = glob.glob(os.path.join(d, "*final_isa.s"))
        if not isa:
            continue
        name = os.path.basename(d)
        nw = int(re.search(r"_w(\d)", name).group(1))
        info = parse_isa(isa[0])
        info.update(occupancy(info, nw))
        if "_mv" in name:
            assert info["agpr"] == 0, f"{name}: MV set but {info['agpr']} AGPRs allocated (fn-attr hook failed)"
        rows.append((name, info))
    return rows


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, default=384)
    ap.add_argument("--s1", default="BM=128,NW=4,pipe=async,D=3")
    ap.add_argument("--s2", default="BM=128,NW=4,pipe=regs,D=2")
    a = ap.parse_args()
    for name, i in probe(a.I, kv(a.s1), kv(a.s2)):
        print(f"{name:60s} vgpr={i['vgpr']:3d} agpr={i['agpr']:3d} lds={i['lds']:6d} spill={i['spill']} "
              f"| waves/SIMD={i['waves_per_simd']} CTAs/CU={i['ctas_per_cu']} ({i['limiter']}) "
              f"| mfma={i['mfma']} barrier={i['barrier']} waitcnt={i['waitcnt']}")
