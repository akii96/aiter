"""SR="even" activation quant vs AITER's runtime quantizer (aiter dynamic_mxfp4_quant).

Needs aiter importable (the container's install). Scales must be byte-exact everywhere,
including edge rows: zeros, denormal-range, near bf16 max (exponent-field overflow) and inf.
fp4 codes must be byte-exact for every finite group with scale < 2^127 (e8m0 < 254). At
e8m0 254, AITER multiplies by the reciprocal 2^-127, which is subnormal and gets flushed,
so its codes there are not a reference; those groups are only counted.
"""
import os
import sys

import torch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from flymoe import mx, prologue  # noqa: E402


def main():
    from aiter.utility import fp4_utils

    T, H = 1024, 6144
    g = torch.Generator(device="cuda").manual_seed(3)
    ok = True
    for scale in (3.0, 0.02, 1e-38, 3e38):
        x = (torch.randn(T, H, device="cuda", generator=g) * scale).to(torch.bfloat16)
        x[0] = 0
        x[1, :32] = float("inf")
        x[2, :32] = torch.finfo(torch.bfloat16).max
        q = torch.empty(T, H // 2, dtype=torch.uint8, device="cuda")
        s = torch.empty(T, H // 32, dtype=torch.uint8, device="cuda")
        prologue.run_quant(x, q, s, even=True)
        torch.cuda.synchronize()
        qa, sa = fp4_utils.dynamic_mxfp4_quant(x)
        qa = qa.view(torch.uint8).reshape(T, -1)[:, :H // 2]
        sa = sa.view(torch.uint8).reshape(T, -1)[:, :H // 32]
        _, sm = mx.quant(x.float(), even=True)
        grp = torch.isfinite(x.float()).view(T, H // 32, 32).all(-1) & (s < 254)
        mism = (q != qa).view(T, H // 32, 16).any(-1)
        good = torch.equal(s, sa) and torch.equal(s, sm) and not bool((mism & grp).any())
        ok &= good
        print(f"x*{scale:g}: scales==aiter {torch.equal(s, sa)} scales==mx {torch.equal(s, sm)} | "
              f"groups compared {int(grp.sum())}, code mismatches {int((mism & grp).sum())} | "
              f"e8m0-254 groups (not compared) {int((s == 254).sum())} {'OK' if good else 'FAIL'}", flush=True)
    print("ALL OK" if ok else "SOME FAILED")


if __name__ == "__main__":
    main()
