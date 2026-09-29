"""Correctness: flymoe vs torch reference (MiniMax-M3 shapes, fused shared expert)."""

import argparse
import os
import sys

import torch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from flymoe import moe, mx, ref


def make_problem(T, I, H=6144, E=129, k_routed=4, seed=0, skew=None, dev="cuda"):
    g = torch.Generator(device=dev).manual_seed(seed)
    x = torch.randn(T, H, device=dev, generator=g).to(torch.bfloat16)
    wg, sg = mx.random_fp4((E, I, H), dev, g, scale_center=121)
    wu, su = mx.random_fp4((E, I, H), dev, g, scale_center=121)
    wd, sd = mx.random_fp4((E, H, I), dev, g, scale_center=122)
    if skew == "one_expert":
        ids = torch.zeros(T, k_routed, dtype=torch.int64, device=dev)
        ids[:, 1:] = torch.arange(1, k_routed, device=dev)
    else:
        scores = torch.rand(T, E - 1, device=dev, generator=g)
        ids = scores.topk(k_routed, dim=-1).indices
    ids = torch.cat([ids, torch.full((T, 1), E - 1, device=dev)], dim=1)
    w = torch.rand(T, k_routed + 1, device=dev, generator=g)
    w[:, -1] = 1.0
    return x, ids, w, (wg, sg, wu, su, wd, sd)


def check(T, I, BM=128, skew=None, seed=0, epis=("rows", "f32atomic", "bf16atomic")):
    x, ids, w, wts = make_problem(T, I, skew=skew, seed=seed)
    W = moe.MoEWeights(*wts)
    y_ref, _, _ = ref.moe_ref(x, ids, w, *wts)
    ok = True
    for epi in epis:
        y = moe.flymoe_forward(x, ids, w, W, BM1=BM, BM2=BM, epi=epi)
        torch.cuda.synchronize()
        e = ref.rel_l2(y, y_ref)
        # bf16 output quantization alone is ~2e-3 rel.
        good = e < 1e-2 and torch.isfinite(y.float()).all().item()
        ok &= good
        print(f"T={T:6d} I={I:5d} BM={BM} skew={skew} epi={epi:10s}: rel_l2={e:.3e} {'OK' if good else 'FAIL'}")
    return ok


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, nargs="+", default=[384])
    ap.add_argument("--T", type=int, nargs="+", default=[1, 7, 256, 1000])
    ap.add_argument("--BM", type=int, default=128)
    a = ap.parse_args()
    ok = True
    for I in a.I:
        for T in a.T:
            ok &= check(T, I, a.BM)
        ok &= check(64, I, a.BM, skew="one_expert")
    print("ALL OK" if ok else "SOME FAILED")
