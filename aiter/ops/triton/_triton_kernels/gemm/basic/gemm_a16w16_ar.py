# SPDX-License-Identifier: MIT
# Copyright (c) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""a16w16 GEMM whose epilogue publishes its output tile to every TP peer.

Motivation
----------
A row-parallel projection under tensor parallelism is always followed by an
all-reduce of the partial sums. On MI350X at decode shapes that all-reduce is
*latency* bound, not bandwidth bound: a 384 KiB reduction measures ~9.8 us,
i.e. ~80 GB/s, about 1% of HBM peak. Half of that time is the cross-rank
barrier itself.

Because the collective is a barrier rather than a data movement, the usual
"chunk the GEMM and overlap each chunk's all-reduce" trick *loses* -- every
chunk re-pays the full barrier. Splitting into 4 chunks modelled 42% slower
than the serial pair.

What does work is removing the separate collective launch entirely. The GEMM
has to store its output somewhere regardless; this kernel stores each output
tile into every peer's symmetric buffer at the same time, so the partial sums
are already distributed when the GEMM retires. A single barrier plus a cheap
elementwise reduction then finishes the job, instead of a full 2-stage
collective.

Addressing
----------
``torch.distributed._symmetric_memory`` hands back one base pointer per rank
with *no* uniform stride between them (verified on ROCm: four unrelated VAs),
unlike MORI's flat VA window where a peer address is ``base + rank*STRIDE``.
So peer bases arrive as a small ``int64`` pointer array and the kernel indexes
it, costing one extra scalar load per tile rather than an arithmetic
derivation. This is what lets the kernel work without MORI.

The reduction is deliberately left to a separate tiny kernel rather than being
done with atomics here: bf16 atomics are not associative, and a reproducible
result matters more than saving one launch of a bandwidth-bound elementwise op.
"""

import triton
import triton.language as tl

from aiter.ops.triton.utils._triton.kernel_repr import make_kernel_repr
from aiter.ops.triton.utils._triton.pid_preprocessing import pid_grid, remap_xcd

_gemm_a16w16_ar_repr = make_kernel_repr(
    "_gemm_a16_w16_ar_kernel",
    [
        "BLOCK_SIZE_M",
        "BLOCK_SIZE_N",
        "BLOCK_SIZE_K",
        "GROUP_SIZE_M",
        "EVEN_K",
        "EVEN_MN",
        "cache_modifier",
        "WORLD_SIZE",
    ],
)


@triton.heuristics(
    {
        "EVEN_K": lambda args: args["K"] % args["BLOCK_SIZE_K"] == 0,
        "EVEN_MN": lambda args: (
            (args["M"] % args["BLOCK_SIZE_M"] == 0)
            and (args["N"] % args["BLOCK_SIZE_N"] == 0)
        ),
    }
)
@triton.jit(
    repr=_gemm_a16w16_ar_repr,
    do_not_specialize=["M", "N"],
)
def _gemm_a16_w16_ar_kernel(
    a_ptr,
    b_ptr,
    peer_ptrs,  # int64[WORLD_SIZE]: each rank's symmetric slab base
    M,
    N,
    K,
    stride_am,
    stride_ak,
    stride_bk,
    stride_bn,
    gen_off,  # element offset of this launch's generation window
    stride_cm,
    stride_cn,
    stride_crank,  # elements between consecutive rank slots inside a slab
    RANK: tl.constexpr,
    WORLD_SIZE: tl.constexpr,
    out_dtype: tl.constexpr,
    BLOCK_SIZE_M: tl.constexpr,
    BLOCK_SIZE_N: tl.constexpr,
    BLOCK_SIZE_K: tl.constexpr,
    GROUP_SIZE_M: tl.constexpr,
    EVEN_K: tl.constexpr,
    EVEN_MN: tl.constexpr,
    cache_modifier: tl.constexpr,
):
    """C = A x B, with the resulting tile published to all TP peers.

    Peer ``p``'s slab holds ``WORLD_SIZE`` slots; this rank always writes slot
    ``RANK``, so after the grid retires every rank owns a full set of the
    world's partial sums and the follow-up reduction is purely local.
    """
    tl.assume(stride_am > 0)
    tl.assume(stride_ak > 0)
    tl.assume(stride_bk > 0)
    tl.assume(stride_bn > 0)
    tl.assume(stride_cm > 0)
    tl.assume(stride_cn > 0)

    pid = tl.program_id(axis=0)
    num_pid_m = tl.cdiv(M, BLOCK_SIZE_M)
    num_pid_n = tl.cdiv(N, BLOCK_SIZE_N)
    pid = remap_xcd(pid, num_pid_m * num_pid_n, NUM_XCDS=8)
    pid_m, pid_n = pid_grid(pid, num_pid_m, num_pid_n, GROUP_SIZE_M=GROUP_SIZE_M)

    tl.assume(pid_m >= 0)
    tl.assume(pid_n >= 0)

    offs_k = tl.arange(0, BLOCK_SIZE_K)
    if EVEN_MN:
        offs_am = pid_m * BLOCK_SIZE_M + tl.arange(0, BLOCK_SIZE_M)
        offs_bn = pid_n * BLOCK_SIZE_N + tl.arange(0, BLOCK_SIZE_N)
    else:
        offs_am = (pid_m * BLOCK_SIZE_M + tl.arange(0, BLOCK_SIZE_M)) % M
        offs_bn = (pid_n * BLOCK_SIZE_N + tl.arange(0, BLOCK_SIZE_N)) % N

    a_ptrs = a_ptr + (offs_am[:, None] * stride_am + offs_k[None, :] * stride_ak)
    b_ptrs = b_ptr + (offs_k[:, None] * stride_bk + offs_bn[None, :] * stride_bn)

    accumulator = tl.zeros((BLOCK_SIZE_M, BLOCK_SIZE_N), dtype=tl.float32)
    for k in range(tl.cdiv(K, BLOCK_SIZE_K)):
        if EVEN_K:
            a = tl.load(a_ptrs)
            b = tl.load(b_ptrs, cache_modifier=cache_modifier)
        else:
            k_rem = K - k * BLOCK_SIZE_K
            a = tl.load(a_ptrs, mask=offs_k[None, :] < k_rem, other=0.0)
            b = tl.load(
                b_ptrs,
                mask=offs_k[:, None] < k_rem,
                other=0.0,
                cache_modifier=cache_modifier,
            )
        accumulator = tl.dot(a, b, acc=accumulator)
        a_ptrs += BLOCK_SIZE_K * stride_ak
        b_ptrs += BLOCK_SIZE_K * stride_bk

    offs_cm = pid_m.to(tl.int64) * BLOCK_SIZE_M + tl.arange(0, BLOCK_SIZE_M)
    offs_cn = pid_n.to(tl.int64) * BLOCK_SIZE_N + tl.arange(0, BLOCK_SIZE_N)
    tile_off = stride_cm * offs_cm[:, None] + stride_cn * offs_cn[None, :]
    c_mask = (offs_cm[:, None] < M) & (offs_cn[None, :] < N)

    # ---- epilogue: push this tile into every peer's slab --------------------
    # Pushing means the reduction is purely local: by the time a rank reduces,
    # its own slab already holds all WORLD_SIZE partials, so that kernel needs
    # no cross-rank traffic and no atomics at all. The alternative (write
    # locally, have peers pull during the reduction) makes every reducing
    # block a cross-rank reader, which forced a barrier in each of them and
    # measured 0.28x at large block counts.
    c = accumulator.to(out_dtype)
    for p in tl.static_range(WORLD_SIZE):
        base = tl.load(peer_ptrs + p).to(tl.pointer_type(out_dtype))
        dst = base + gen_off + RANK * stride_crank + tile_off
        if EVEN_MN:
            tl.store(dst, c)
        else:
            tl.store(dst, c, mask=c_mask)


_barrier_repr = make_kernel_repr(
    "_peer_barrier_kernel", ["WORLD_SIZE", "NUM_BARRIER_BLOCKS"]
)


@triton.jit(repr=_barrier_repr)
def _peer_barrier_kernel(
    peer_flags,  # int64[WORLD_SIZE]: base of each rank's flag inbox
    self_flags,  # int32[...]: our inbox
    timeout_ptr,  # int32[1]: sticky, set if a block gave up waiting
    seq,  # monotonic sequence number, one per launch
    flag_off,  # element offset of this launch's flag generation
    RANK: tl.constexpr,
    WORLD_SIZE: tl.constexpr,
    MAX_SPIN: tl.constexpr,
):
    """Block until every peer's GEMM epilogue for ``seq`` has landed.

    Launched on its own tiny grid so the handshake cost is fixed, rather than
    scaling with the reduction's block count. Folding this into the reduction
    made every one of its blocks a participant: at M=128 that was 768 blocks
    doing system-scope flag traffic, and the op measured 0.28x.

    Only a start barrier is needed. The matching *end* barrier -- "nobody may
    overwrite a generation until all peers finished reading it" -- is implied
    by stream order plus ``NUM_GENERATIONS >= 3``: a rank signals barrier(j)
    only after its own GEMM(j), which follows its reduce(j-1), so
    barrier(k+G-1) already proves every rank finished reduce(k+G-2). With
    G=4 that leaves two launches of margin over the reduce(k) we must protect.

    ``seq`` is a runtime argument, so a captured graph replays correctly. The
    spin is bounded: an unbounded one deadlocks on the second launch because
    the peer-written value stops being re-read, and a cap also turns a lost
    peer into a reported timeout instead of a wedged device.
    """
    pid = tl.program_id(axis=0)

    for p in tl.static_range(WORLD_SIZE):
        fbase = tl.load(peer_flags + p).to(tl.pointer_type(tl.int32))
        tl.atomic_xchg(
            fbase + flag_off + pid * WORLD_SIZE + RANK,
            seq,
            sem="release",
            scope="sys",
        )
    for q in tl.static_range(WORLD_SIZE):
        spins = 0
        slot = self_flags + flag_off + pid * WORLD_SIZE + q
        got = tl.atomic_add(slot, 0, sem="acquire", scope="sys")
        while got < seq and spins < MAX_SPIN:
            got = tl.atomic_add(slot, 0, sem="acquire", scope="sys")
            spins += 1
        if spins >= MAX_SPIN:
            tl.atomic_xchg(timeout_ptr, 1, sem="release", scope="gpu")


_reduce_repr = make_kernel_repr("_reduce_slab_kernel", ["BLOCK_SIZE", "WORLD_SIZE"])


@triton.jit(repr=_reduce_repr)
def _reduce_slab_kernel(
    slab_ptr,  # our own slab: [WORLD_SIZE, numel] for this generation
    out_ptr,
    gen_off,
    numel,
    stride_crank,
    WORLD_SIZE: tl.constexpr,
    BLOCK_SIZE: tl.constexpr,
):
    """Sum the WORLD_SIZE partials the peers pushed into our slab.

    Entirely local and atomic-free: the epilogue already delivered every
    peer's tile, and the preceding barrier kernel established that they all
    landed. Pure streaming bandwidth.

    Accumulation is fp32 in a fixed rank order, so the result is
    bit-reproducible across runs (unlike a bf16 atomic epilogue).
    """
    pid = tl.program_id(axis=0)
    offs = pid * BLOCK_SIZE + tl.arange(0, BLOCK_SIZE)
    mask = offs < numel

    acc = tl.zeros((BLOCK_SIZE,), dtype=tl.float32)
    for p in tl.static_range(WORLD_SIZE):
        v = tl.load(slab_ptr + gen_off + p * stride_crank + offs, mask=mask, other=0.0)
        acc += v.to(tl.float32)
    tl.store(out_ptr + offs, acc.to(out_ptr.dtype.element_ty), mask=mask)
