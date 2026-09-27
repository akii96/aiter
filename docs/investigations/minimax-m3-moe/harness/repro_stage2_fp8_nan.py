# SPDX-License-Identifier: MIT
"""Minimal reproducer: AITER_FLYDSL_STAGE2_FP8=1 yields non-finite MoE output
at inter_dim=384 (but NOT at inter_dim=768) on gfx950.

Shape is the MiniMax-M3 TP8 MoE layer, which has shipped tuned rows in
aiter/configs/model_configs/minimax_m3_fp4_tuned_fmoe.csv.

The failure is DETERMINISTIC and selects on inter_dim, because inter_dim picks
a different stage-2 reducer variant:

    inter_dim=384 -> ..._t64x256x128_reduce_sbm64           <-- BROKEN
    inter_dim=768 -> ..._t64x256x128_reduce_persist_sbm64   <-- clean

With tile_k=128: 384 = 3*128 (odd tile count), 768 = 6*128 (even).

Usage
-----
    python repro_stage2_fp8_nan.py                                  # baseline: finite
    AITER_FLYDSL_STAGE2_FP8=1 python repro_stage2_fp8_nan.py        # ~140k non-finite
    AITER_FLYDSL_STAGE2_FP8=1 python repro_stage2_fp8_nan.py --inter-dim 768   # clean

NOTE: weights MUST be preshuffled. Passing unshuffled weights to a tuned kernel
is outside aiter's contract (it logs `is_shuffled=False ... may produce incorrect
results`) and produces unrelated corruption that is NOT this bug.

Exit status is 1 if any repeat produced non-finite or out-of-range output.
"""
import argparse, os, sys
import torch

import aiter
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, fused_topk
from aiter.ops.shuffle import shuffle_weight

MODEL_DIM = 6144
EXPERTS = 129          # 128 routed + 1 shared
TOPK = 5
SWIGLU_LIMIT = 7.0
# Sanity bound: with the scaling below the true output is O(1). Anything past this
# is corruption, not a numerical edge case.
SANE_ABSMAX = 1.0e3


def build(M, inter_dim, seed, device="cuda"):
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    # std ~ 1/sqrt(fan_in) so SwiGLU does not saturate its limit and the
    # reference output is O(1).
    x = torch.randn((M, MODEL_DIM), dtype=dtypes.bf16, device=device) * (8.0 / MODEL_DIM**0.5)
    w1 = torch.randn((EXPERTS, inter_dim * 2, MODEL_DIM), dtype=dtypes.bf16, device=device) * (1.0 / MODEL_DIM**0.5)
    w2 = torch.randn((EXPERTS, MODEL_DIM, inter_dim), dtype=dtypes.bf16, device=device) * (1.0 / inter_dim**0.5)
    score = torch.randn((M, EXPERTS), dtype=dtypes.bf16, device=device)
    topk_w, topk_id = fused_topk(x, score, TOPK, True)

    quant = aiter.get_torch_quant(QuantType.per_1x32)
    w1q, w1s = quant(w1, quant_dtype=dtypes.fp4x2)
    w2q, w2s = quant(w2, quant_dtype=dtypes.fp4x2)
    del w1, w2
    return dict(
        x=x, topk_w=topk_w, topk_id=topk_id,
        w1q=w1q.view(EXPERTS, inter_dim * 2, MODEL_DIM // 2),
        w2q=w2q.view(EXPERTS, MODEL_DIM, inter_dim // 2),
        w1s=w1s.view(EXPERTS, inter_dim * 2, MODEL_DIM // 32),
        w2s=w2s.view(EXPERTS, MODEL_DIM, inter_dim // 32),
    )


def run(t):
    out = fused_moe(
        t["x"], t["w1q"], t["w2q"], t["topk_w"], t["topk_id"],
        quant_type=QuantType.per_1x32,
        w1_scale=t["w1s"], w2_scale=t["w2s"],
        activation=ActivationType.Swiglu,
        doweight_stage1=False,
        swiglu_limit=SWIGLU_LIMIT,
    )
    torch.cuda.synchronize()
    return out


def main():
    p = argparse.ArgumentParser()
    p.add_argument("-M", type=int, default=4096, help="tokens (4096 reproduces most readily)")
    p.add_argument("--inter-dim", type=int, default=384, help="384 reproduces; 768 does not")
    p.add_argument("--seed", type=int, default=0)
    p.add_argument("--repeat", type=int, default=3, help="failure is non-deterministic")
    a = p.parse_args()

    flag = os.environ.get("AITER_FLYDSL_STAGE2_FP8", "0")
    print(f"AITER_FLYDSL_STAGE2_FP8={flag}")
    print(f"device={torch.cuda.get_device_name(0)}")
    print(f"M={a.M} model_dim={MODEL_DIM} inter_dim={a.inter_dim} "
          f"E={EXPERTS} topk={TOPK} act=Swiglu qtype=per_1x32 a4w4\n")

    t = build(a.M, a.inter_dim, a.seed)
    bad_runs = 0
    print(f"{'run':>4} {'non_finite':>12} {'absmax(finite)':>16} {'verdict':>10}")
    print("-" * 48)
    for i in range(a.repeat):
        out = run(t)
        finite = torch.isfinite(out)
        n_bad = int((~finite).sum())
        absmax = float(out[finite].abs().max()) if int(finite.sum()) else float("nan")
        ok = (n_bad == 0) and (absmax == absmax) and (absmax < SANE_ABSMAX)
        bad_runs += (not ok)
        print(f"{i:>4} {n_bad:>12,} {absmax:>16.3e} {'OK' if ok else 'CORRUPT':>10}")

    print()
    if bad_runs:
        print(f"FAIL: {bad_runs}/{a.repeat} runs produced non-finite or out-of-range output "
              f"(sane |x| < {SANE_ABSMAX:g}).")
        return 1
    print(f"PASS: all {a.repeat} runs finite and in range.")
    if flag == "1":
        print("NOTE: non-deterministic -- re-run or raise --repeat; also try -M 4096 --inter-dim 384.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
