# SPDX-License-Identifier: MIT
# Copyright (c) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""Kernels for an in-place all-reduce over symmetric memory.

Broadcast a rank's tensor into every peer's slot of a symmetric slab,
barrier, then sum the slots locally. See ``aiter/ops/peer_all_reduce.py`` for
the host side and for when this is preferable to a collective.
"""

import triton
import triton.language as tl

from aiter.ops.triton.utils._triton.kernel_repr import make_kernel_repr

_bcast_repr = make_kernel_repr("_peer_bcast_kernel", ["WORLD_SIZE", "BLOCK_SIZE"])


@triton.jit(repr=_bcast_repr)
def _peer_bcast_kernel(
    src_ptr,
    peer_ptrs,  # int64[WORLD_SIZE]: each rank's slab base
    numel,
    slot_elems,  # per-rank slot pitch within a slab
    RANK: tl.constexpr,
    WORLD_SIZE: tl.constexpr,
    BLOCK_SIZE: tl.constexpr,
):
    """Publish this rank's tensor into slot ``RANK`` of every peer's slab.

    Plain stores, not atomics. Scattering from a producing kernel's epilogue
    instead requires remote read-modify-writes and measured far worse.
    """
    pid = tl.program_id(axis=0)
    offs = pid * BLOCK_SIZE + tl.arange(0, BLOCK_SIZE)
    mask = offs < numel
    v = tl.load(src_ptr + offs, mask=mask, other=0.0)

    for p in tl.static_range(WORLD_SIZE):
        base = tl.load(peer_ptrs + p).to(tl.pointer_type(v.dtype))
        tl.store(base + RANK * slot_elems + offs, v, mask=mask)


_barrier_repr = make_kernel_repr("_peer_barrier_kernel", ["WORLD_SIZE", "MAX_SPIN"])


@triton.jit(repr=_barrier_repr)
def _peer_barrier_kernel(
    peer_flags,  # int64[WORLD_SIZE]: each rank's flag inbox base
    self_flags,  # int32[NUM_BLOCKS * WORLD_SIZE]: our inbox
    timeout_ptr,  # int32[1]: sticky, set when a block gives up
    seq,  # monotonic, one per launch
    flag_off,
    RANK: tl.constexpr,
    WORLD_SIZE: tl.constexpr,
    MAX_SPIN: tl.constexpr,
):
    """Block until every peer has announced ``seq``.

    Launched on a small fixed grid so the handshake cost does not scale with
    the reduction's block count.

    ``seq`` is a runtime argument, so a captured graph replays correctly; a
    host-side rendezvous barrier is not capturable at all.

    The spin is bounded. An unbounded one deadlocks on the second launch
    because the peer-written value stops being re-read, and the cap also turns
    a lost peer into a reported timeout rather than an uninterruptible kernel.
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


_reduce_repr = make_kernel_repr("_reduce_slab_kernel", ["WORLD_SIZE", "BLOCK_SIZE"])


@triton.jit(repr=_reduce_repr)
def _reduce_slab_kernel(
    slab_ptr,
    out_ptr,
    numel,
    stride_crank,
    WORLD_SIZE: tl.constexpr,
    BLOCK_SIZE: tl.constexpr,
    ZERO_AFTER: tl.constexpr = False,
):
    """Sum the WORLD_SIZE slots of our slab into ``out``.

    Local and atomic-free; the preceding barrier established that every peer's
    store landed. Accumulates in fp32 in a fixed rank order, so the result is
    reproducible.

    ``ZERO_AFTER`` clears each slot as it is consumed, which is free because
    the line is already resident and saves a separate clearing pass.
    """
    pid = tl.program_id(axis=0)
    offs = pid * BLOCK_SIZE + tl.arange(0, BLOCK_SIZE)
    mask = offs < numel

    acc = tl.zeros((BLOCK_SIZE,), dtype=tl.float32)
    for p in tl.static_range(WORLD_SIZE):
        src = slab_ptr + p * stride_crank + offs
        v = tl.load(src, mask=mask, other=0.0)
        acc += v.to(tl.float32)
        if ZERO_AFTER:
            tl.store(src, tl.zeros((BLOCK_SIZE,), dtype=v.dtype), mask=mask)
    tl.store(out_ptr + offs, acc.to(out_ptr.dtype.element_ty), mask=mask)
