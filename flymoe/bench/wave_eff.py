"""Stage-1 wave quantization per table cell: CTAs (m-tiles x N blocks) vs resident CTA slots.

Uniform-random routing as in tests/test_moe.make_problem (k=4 routed + 1 shared over 128 + 1
experts). CTAs/CU from the table config's measured occupancy (--occ I:T=n overrides; default:
1 for BM=256 pipes, else 2). Persistent stage 1 (PERS1) deals the same tiles over CUs x PERS1.
eff = CTAs / (rounds * slots): the fraction of CU time the last round keeps busy.

usage: python bench/wave_eff.py [--table configs/tiles_v5_I{I}.json] [--occ 384:1024=3 ...]
"""
import argparse
import json
import math
import os

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
CUS = 256


def counts(T, seed=0):
    g = torch.Generator().manual_seed(seed)
    ids = torch.rand(T, 128, generator=g).topk(4, dim=-1).indices
    c = torch.bincount(ids.flatten(), minlength=128).tolist()
    return c + [T]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--table", default=os.path.join(HERE, "..", "configs", "tiles_v5_I{I}.json"))
    ap.add_argument("--occ", nargs="*", default=[])
    a = ap.parse_args()
    occ = {k: int(v) for k, v in (s.split("=") for s in a.occ)}
    for I in (384, 768, 1536):
        tab = json.load(open(a.table.format(I=I)))
        for T, cell in tab.items():
            s1 = cell["s1"]
            BM, NW, WM = s1["BM"], s1["NW"], s1.get("WM", 1)
            BN = 64 * (NW // WM) * (2 if s1["pipe"] == "il4" else 1)
            nb = (2 * I) // BN
            c = counts(int(T))
            mt = sum(math.ceil(x / BM) for x in c if x)
            fill = sum(c) / (mt * BM)
            ctas = mt * nb
            k = occ.get(f"{I}:{T}", 1 if BM == 256 else 2)
            slots = CUS * k
            rounds = math.ceil(ctas / slots)
            print(f"I={I:5d} T={T:>6s} BM={BM:3d} BN={BN:3d} pipe={s1['pipe']:8s} m-tiles={mt:5d} CTAs={ctas:6d} "
                  f"slots={slots:4d} rounds={rounds:3d} wave-eff={ctas / (rounds * slots):.2f} row-fill={fill:.2f}")


if __name__ == "__main__":
    main()
