# SPDX-License-Identifier: MIT
# Copyright (c) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""Correctness, graph-capture safety, and perf for fused a16w16 GEMM+all-reduce.

The capture test is the important one: an earlier revision passed every eager
check here and still crashed a serving worker, because the barrier was a
host-side ``rendezvous().barrier()`` and the slab was allocated lazily. Both
are illegal inside a graph.

    torchrun --nproc_per_node=4 op_tests/triton_tests/test_gemm_a16w16_ar.py
"""

from __future__ import annotations

import os

import torch
import torch.distributed as dist

from aiter.ops.triton.gemm.basic.gemm_a16w16_ar import GemmA16W16AllReduce

# (M, N, K) -- MiniMax-M3 at TP=4 plus a couple of neighbours.
SHAPES = [
    (32, 6144, 2048),  # o_proj, decode conc=32     <- the motivating shape
    (1, 6144, 2048),  # o_proj, single stream (below MIN_M -> fallback)
    (128, 6144, 2048),  # o_proj, conc=128
    (32, 6144, 1536),  # MoE gemm2-ish
    (64, 4096, 4096),  # square control
]


def _rel_rms(got: torch.Tensor, want: torch.Tensor) -> float:
    """Error relative to the RMS of the reference, not its max element.

    A max-relative metric is misleading for this op. Both paths accumulate in
    fp32 and round to bf16, so the absolute error is ~2 ulp regardless of
    shape; but summing more rows in bf16 increases cancellation, shrinking
    ``want.abs().max()`` and inflating a max-relative ratio even though the
    kernel is bit-exact. Measured here: at M=128 every peer slot matched its
    rank's partial exactly, while max-relative still read 0.78.
    """
    diff = (got.float() - want.float()).pow(2).mean().sqrt()
    scale = want.float().pow(2).mean().sqrt().clamp(min=1e-6)
    return (diff / scale).item()


def bench(fn, warmup=20, iters=100):
    for _ in range(warmup):
        fn()
    torch.cuda.synchronize()
    s = torch.cuda.Event(enable_timing=True)
    e = torch.cuda.Event(enable_timing=True)
    s.record()
    for _ in range(iters):
        fn()
    e.record()
    torch.cuda.synchronize()
    return s.elapsed_time(e) / iters * 1000  # us


def main() -> int:
    rank = int(os.environ["RANK"])
    world = int(os.environ["WORLD_SIZE"])
    torch.cuda.set_device(rank)
    dist.init_process_group("nccl", rank=rank, world_size=world)
    dev = torch.device("cuda", rank)
    dt = torch.bfloat16
    torch.manual_seed(1234 + rank)

    op = GemmA16W16AllReduce(dtype=dt)
    # Registration is collective: same shapes, same order, on every rank.
    for n in sorted({n for _, n, _ in SHAPES}):
        op.reserve([m for m, nn, _ in SHAPES if nn == n], n)

    failures = []
    if rank == 0:
        print(f"world={world}  dtype={dt}\n")
        print(
            f"{'shape':>22} {'max rel':>10} {'ref us':>9} {'fused us':>9} {'speedup':>8}"
        )

    for M, N, K in SHAPES:
        a = torch.randn(M, K, dtype=dt, device=dev) * 0.1
        b = torch.randn(K, N, dtype=dt, device=dev) * 0.1

        def ref(a=a, b=b):
            y = torch.mm(a, b)
            dist.all_reduce(y, group=dist.group.WORLD)
            return y

        got = op(a, b)
        want = ref()
        rel = _rel_rms(got, want)
        ok = rel < 5e-2
        if not ok:
            failures.append((M, N, K, rel))

        t_ref = bench(ref)
        t_fused = bench(lambda a=a, b=b: op(a, b))
        if rank == 0:
            flag = "" if ok else "  <-- MISMATCH"
            print(
                f"{f'{M}x{N}x{K}':>22} {rel:10.2e} {t_ref:9.2f} {t_fused:9.2f} "
                f"{t_ref / t_fused:7.2f}x{flag}"
            )

    # -- determinism -------------------------------------------------------
    M, N, K = SHAPES[0]
    a = torch.randn(M, K, dtype=dt, device=dev) * 0.1
    b = torch.randn(K, N, dtype=dt, device=dev) * 0.1
    deterministic = torch.equal(op(a, b).clone(), op(a, b).clone())

    # -- graph capture: the regression an eager-only suite cannot catch -----
    capture_ok, capture_correct = True, True
    try:
        want = torch.mm(a, b)
        dist.all_reduce(want, group=dist.group.WORLD)

        g = torch.cuda.CUDAGraph()
        s = torch.cuda.Stream()
        s.wait_stream(torch.cuda.current_stream())
        with torch.cuda.stream(s):
            for _ in range(3):
                op(a, b)
        torch.cuda.current_stream().wait_stream(s)
        dist.barrier()

        with torch.cuda.graph(g):
            captured = op(a, b)
        for _ in range(3):
            g.replay()
        torch.cuda.synchronize()

        capture_correct = _rel_rms(captured, want) < 5e-2
    except Exception as exc:  # noqa: BLE001
        capture_ok = False
        if rank == 0:
            print(f"\ngraph capture raised: {type(exc).__name__}: {str(exc)[:160]}")

    if rank == 0:
        print(f"\nbit-reproducible across repeats : {deterministic}")
        print(f"HIP graph capture + replay       : {capture_ok}")
        print(f"replayed result correct          : {capture_correct}")
        if failures:
            print(f"\nFAILURES ({len(failures)}):")
            for M, N, K, rel in failures:
                print(f"  {M}x{N}x{K}: rel={rel:.3e}")
        else:
            print("ALL SHAPES MATCH")

    dist.barrier()
    dist.destroy_process_group()
    bad = failures or not deterministic or not capture_ok or not capture_correct
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
