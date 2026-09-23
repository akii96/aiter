# SPDX-License-Identifier: MIT
# Copyright (c) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""Fused a16w16 GEMM + tensor-parallel all-reduce.

Replaces the ``gemm -> all_reduce`` pair that every row-parallel projection
emits under TP. Instead of storing the partial sum locally and then running a
2-stage collective over it, the GEMM's epilogue writes its output tile into
every peer's symmetric buffer, so an in-kernel barrier plus a local elementwise
sum finishes the reduction.

Why this shape of fusion
------------------------
Measured on MI350X (gfx950), TP=4, o_proj at decode (M=32, N=6144, K=2048):

    gemm                        9.07 us
    cross_device_reduce_2stage  9.84 us   (384 KiB -> ~80 GB/s, ~1% of HBM peak)

The collective is barrier-dominated, so chunk-and-overlap makes things worse
(each chunk re-pays the barrier; a 4-chunk pipeline models 42% slower). The
win comes from deleting the second launch, not from hiding it.

Graph-capture safety
--------------------
Two properties are required to survive HIP graph capture, and an earlier
revision of this op had neither:

1. **No host-side collective in the hot path.** ``rendezvous().barrier()`` is
   not capturable; calling it from ``forward`` crashes the worker. The barrier
   now lives inside the reduction kernel, driven by a monotonic ``seq``
   counter in symmetric memory.
2. **No allocation in the hot path.** A serving engine varies M per step, so
   allocating a slab on first sight of a shape would run ``symm_mem.empty`` and
   a rendezvous mid-capture. ``reserve()`` pre-registers every shape the engine
   will capture; ``__call__`` only looks slabs up.

Usage
-----
    op = GemmA16W16AllReduce(group)
    op.reserve(m_values, n)        # once, before capture
    y = op(x, w)                   # == all_reduce(x @ w)

Any shape not reserved falls back to ``mm + all_reduce`` rather than
allocating, so an unexpected M degrades instead of crashing.
"""

from __future__ import annotations

import torch
import torch.distributed as dist
import torch.distributed._symmetric_memory as symm_mem
import triton
import triton.language as tl

from aiter.ops.triton._triton_kernels.gemm.basic.gemm_a16w16_ar import (
    _gemm_a16_w16_ar_kernel,
    _peer_barrier_kernel,
    _reduce_slab_kernel,
)

#: Blocks that participate in the in-kernel handshake. Keep small: every one
#: costs a round of peer flag traffic.
NUM_BARRIER_BLOCKS = 8

#: Spin iterations a barrier block will wait for a peer before giving up. The
#: loop must be bounded -- an unbounded one deadlocks on the second launch --
#: and a cap also stops a lost peer from wedging the device. Large enough that
#: healthy peers never reach it.
MAX_SPIN = 100_000_000

#: Number of rotating slab/flag generations.
#:
#: Ranks do not run in lockstep: nothing forces rank 0's Nth call to line up
#: with rank 3's Nth call. With a single buffer and a monotonic flag, a rank
#: that has raced ahead to seq=N+k publishes a value that satisfies a slower
#: peer still waiting on seq=N, so the slow peer proceeds and reduces a slab
#: the fast peer is concurrently overwriting. Rotating generations give each
#: in-flight launch its own slab and flag row, so a peer can only satisfy the
#: launch it actually belongs to. Two is enough while at most one launch is in
#: flight per rank; four leaves headroom for drift.
NUM_GENERATIONS = 4


def tl_dtype(dtype: torch.dtype):
    """Triton element type for a torch dtype, for the epilogue's peer stores.

    The stores go through pointers reconstructed from an int64 array, so the
    element type cannot be inferred from the pointer and has to be passed in.
    """
    return {torch.bfloat16: tl.bfloat16, torch.float16: tl.float16}[dtype]


def is_available() -> bool:
    """Whether symmetric memory can back the peer-store epilogue here."""
    if not (dist.is_available() and dist.is_initialized()):
        return False
    if not torch.cuda.is_available():
        return False
    return hasattr(symm_mem, "empty") and hasattr(symm_mem, "rendezvous")


class GemmA16W16AllReduce:
    """Fused GEMM + all-reduce over a torch symmetric-memory slab.

    Args:
        group: Tensor-parallel process group; ``None`` uses the default group.
        dtype: Operand and output dtype.
    """

    #: Smallest M for which the fused path beats gemm + all_reduce. Below this
    #: the collective is cheaper than the peer-store epilogue that replaces it.
    #: Measured on MI350X/gfx950 at TP=4; deliberately conservative.
    MIN_M = 8

    def __init__(self, group=None, dtype: torch.dtype = torch.bfloat16) -> None:
        if not is_available():
            raise RuntimeError(
                "GemmA16W16AllReduce needs an initialised process group and "
                "torch.distributed._symmetric_memory support"
            )
        self.group = group if group is not None else dist.group.WORLD
        self.group_name = self.group.group_name
        self.rank = dist.get_rank(self.group)
        self.world = dist.get_world_size(self.group)
        self.dtype = dtype
        self.device = torch.device("cuda", torch.cuda.current_device())

        self._slabs: dict[tuple[int, int], tuple] = {}
        self._flags = None
        self._peer_flags = None
        self._timeout = None
        self._seq = 0

    # -- one-time registration ---------------------------------------------
    def _ensure_flags(self) -> None:
        """Allocate the symmetric flag inbox used by the in-kernel barrier."""
        if self._flags is not None:
            return
        n = NUM_GENERATIONS * NUM_BARRIER_BLOCKS * self.world
        flags = symm_mem.empty(n, dtype=torch.int32, device=self.device)
        flags.zero_()
        hdl = symm_mem.rendezvous(flags, self.group_name)
        ptrs = [
            hdl.get_buffer(r, (n,), torch.int32).data_ptr() for r in range(self.world)
        ]
        self._flags = flags
        self._peer_flags = torch.tensor(ptrs, dtype=torch.int64, device=self.device)
        # Device-side sticky bit: set if any barrier block exhausts MAX_SPIN.
        # Checked out-of-band, never on the hot path, so it stays capturable.
        self._timeout = torch.zeros(1, dtype=torch.int32, device=self.device)

    def reserve(self, m_values, n: int) -> None:
        """Pre-register slabs for every M the engine will capture.

        Must be called before graph capture. ``symm_mem.empty`` and
        ``rendezvous`` are collectives, so every rank must call this with the
        same arguments in the same order.
        """
        self._ensure_flags()
        for m in sorted({int(m) for m in m_values if int(m) >= self.MIN_M}):
            self._reserve_one(m, int(n))

    def _reserve_one(self, m: int, n: int) -> tuple:
        key = (m, n)
        cached = self._slabs.get(key)
        if cached is not None:
            return cached
        numel = m * n
        total = NUM_GENERATIONS * self.world * numel
        slab = symm_mem.empty(total, dtype=self.dtype, device=self.device)
        # symm_mem.empty is uninitialised; a generation read before it is first
        # written would otherwise contribute garbage to the sum.
        slab.zero_()
        hdl = symm_mem.rendezvous(slab, self.group_name)
        ptrs = [
            hdl.get_buffer(r, (total,), self.dtype).data_ptr()
            for r in range(self.world)
        ]
        peer = torch.tensor(ptrs, dtype=torch.int64, device=self.device)
        outs = [
            torch.empty((m, n), dtype=self.dtype, device=self.device)
            for _ in range(NUM_GENERATIONS)
        ]
        entry = (slab, peer, outs, numel)
        self._slabs[key] = entry
        return entry

    # -- forward ------------------------------------------------------------
    def __call__(self, a: torch.Tensor, b: torch.Tensor) -> torch.Tensor:
        """Return ``all_reduce(a @ b)`` across the TP group."""
        assert a.ndim == 2 and b.ndim == 2, "expected 2-D operands"
        assert a.shape[1] == b.shape[0], f"shape mismatch {a.shape} x {b.shape}"
        assert a.dtype == b.dtype == self.dtype, "operand dtype mismatch"
        M, K = a.shape
        _, N = b.shape

        entry = self._slabs.get((M, N))
        if M < self.MIN_M or entry is None:
            # Unreserved shape, or too small to pay for the epilogue. Falling
            # back here keeps allocation and rendezvous out of the hot path.
            out = torch.mm(a, b)
            dist.all_reduce(out, group=self.group)
            return out

        # The slab itself is reached through peer_ptrs[RANK]; both kernels take
        # the pointer array so the pull-side reads need no separate handle.
        slab, peer_ptrs, outs, numel = entry

        # Rotate generation before launching so concurrent in-flight calls on
        # different ranks never share a slab or a flag row.
        self._seq += 1
        gen = self._seq % NUM_GENERATIONS
        out = outs[gen]
        gen_elems = self.world * numel

        BLOCK_M = 32 if M <= 32 else 64
        BLOCK_N = 64
        BLOCK_K = 128
        grid = (triton.cdiv(M, BLOCK_M) * triton.cdiv(N, BLOCK_N),)

        _gemm_a16_w16_ar_kernel[grid](
            a,
            b,
            peer_ptrs,
            M,
            N,
            K,
            a.stride(0),
            a.stride(1),
            b.stride(0),
            b.stride(1),
            gen * gen_elems,  # base offset of this generation's slab window
            N,  # stride_cm: row pitch inside a slot
            1,  # stride_cn
            numel,  # stride_crank: one slot per rank
            RANK=self.rank,
            WORLD_SIZE=self.world,
            out_dtype=tl_dtype(self.dtype),
            BLOCK_SIZE_M=BLOCK_M,
            BLOCK_SIZE_N=BLOCK_N,
            BLOCK_SIZE_K=BLOCK_K,
            GROUP_SIZE_M=1,
            cache_modifier=None,
        )

        # Fixed-size handshake, independent of the reduction's grid.
        _peer_barrier_kernel[(NUM_BARRIER_BLOCKS,)](
            self._peer_flags,
            self._flags,
            self._timeout,
            self._seq,
            gen * NUM_BARRIER_BLOCKS * self.world,
            RANK=self.rank,
            WORLD_SIZE=self.world,
            MAX_SPIN=MAX_SPIN,
        )

        BLOCK = 1024
        _reduce_slab_kernel[(triton.cdiv(numel, BLOCK),)](
            slab,
            out,
            gen * gen_elems,
            numel,
            numel,
            WORLD_SIZE=self.world,
            BLOCK_SIZE=BLOCK,
        )
        return out

    def barrier_timed_out(self) -> bool:
        """Whether any barrier block has ever exhausted its spin budget.

        Syncs the device, so call it for diagnostics rather than per step.
        """
        return self._timeout is not None and bool(self._timeout.item())


_OP_CACHE: dict = {}


def get_gemm_a16w16_ar(group=None, dtype: torch.dtype = torch.bfloat16):
    """Return the cached op for ``(group, dtype)``, creating it if needed.

    The op owns symmetric allocations and a rendezvous, so it must outlive a
    single call; callers should fetch it once and call ``reserve`` before any
    graph capture.
    """
    key = (id(group), dtype)
    op = _OP_CACHE.get(key)
    if op is None:
        op = _OP_CACHE[key] = GemmA16W16AllReduce(group=group, dtype=dtype)
    return op


def gemm_a16w16_ar(a: torch.Tensor, b: torch.Tensor, group=None) -> torch.Tensor:
    """Functional wrapper around :class:`GemmA16W16AllReduce`."""
    return get_gemm_a16w16_ar(group=group, dtype=a.dtype)(a, b)
