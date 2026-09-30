"""Activation/h e8m0 scale rule: "ceil" (ceil_pow2(amax/6)) vs "even" (checkpoint / AITER).

For each rule: device output vs its own bit-exact torch reference, and vs an unquantized-
activation reference (fp32 x and h, same fp4 weights), i.e. the quantization error.
python bench/scale_rule_accuracy.py [--I 384 768 1536] [--T 1024]
"""
import argparse
import os
import sys

import torch

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from flymoe import configs, moe, ref  # noqa: E402
from tests.test_moe import make_problem  # noqa: E402
from tests.test_options import worst_row  # noqa: E402


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, nargs="+", default=[384, 768, 1536])
    ap.add_argument("--T", type=int, nargs="+", default=[1024])
    ap.add_argument("--xscale", type=float, nargs="+", default=[1.0, 0.05])
    a = ap.parse_args()
    for I in a.I:
        for T in a.T:
            for xs in a.xscale:
                x, ids, w, wts = make_problem(T, I)
                x = (x.float() * xs).to(torch.bfloat16)
                y_fp, _, _ = ref.moe_ref(x, ids, w, *wts, quant_x=False, requant_h=False)
                W = moe.MoEWeights(*wts)
                for sr in ("ceil", "even"):
                    y_ref, _, _ = ref.moe_ref(x, ids, w, *wts, even=sr == "even")
                    run = moe.MoERun(x, ids, w, W, SR=sr, **configs.select_cfg(I, T))
                    y = run.forward()
                    torch.cuda.synchronize()
                    print(f"I={I} T={T} x*{xs} SR={sr:4s}: vs own ref {ref.rel_l2(y, y_ref):.2e} "
                          f"(worst row {worst_row(y, y_ref):.2e}) | quant error vs fp32-activation ref "
                          f"{ref.rel_l2(y, y_fp):.4e} (torch ref {ref.rel_l2(y_ref, y_fp):.4e})", flush=True)


if __name__ == "__main__":
    main()
