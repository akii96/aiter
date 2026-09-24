# SPDX-License-Identifier: MIT
# Copyright (c) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""In-place all-reduce over symmetric memory, for small tensor-parallel tensors.

Replaces a collective with three kernels: broadcast the tensor into every
peer's slot of a symmetric slab, barrier, then sum the slots locally in fp32.

Worth doing because at these sizes the collective is barrier-dominated rather
than bandwidth bound -- a 384 KiB all-reduce at TP=4 on MI350X measures
~9.8 us, i.e. ~80 GB/s, about 1% of HBM peak. The win comes from removing the
launch, not from overlapping it.

That also bounds where this helps. The broadcast moves ``world - 1`` times
more bytes than a ring all-reduce, so as tensors grow there is a crossover
beyond which the collective is the better choice. Measured only at TP=4 on
tensors of a few hundred KiB; larger worlds trade off worse, because broadcast
traffic grows with ``world`` while a ring's per-rank traffic does not.

Opt in with ``AITER_PEER_ALL_REDUCE=1``; unset, nothing is allocated.
"""

from __future__ import annotations

import os

import torch

_ENABLED = os.environ.get("AITER_PEER_ALL_REDUCE", "0") == "1"

#: Blocks in the barrier launch. Fixed and small: the handshake must not scale
#: with the reduction's grid, or it dominates at large M.
NUM_BARRIER_BLOCKS = 8

#: Spin iterations before a barrier block reports a timeout. The loop must be
#: bounded -- an unbounded one deadlocks on the second launch, and the cap is
#: what keeps a lost peer from wedging the device. ~2 s at TP=4.
MAX_SPIN = 2_000_000

_BLOCK = 1024


def enabled() -> bool:
    """Whether the peer all-reduce path is opted in."""
    return _ENABLED


class _State:
    """Symmetric slabs and barrier flags, allocated once per row width."""

    def __init__(self) -> None:
        self.slabs: dict[tuple, tuple] = {}
        self.group = None
        self.rank = 0
        self.world = 1
        self.ready = False
        self.flags = None
        self.peer_flags = None
        self.timeout = None
        self.seq = 0

    def init(self) -> bool:
        if self.ready:
            return True
        import torch.distributed as dist

        if not (dist.is_available() and dist.is_initialized()):
            return False
        self.group = dist.group.WORLD
        self.rank = dist.get_rank()
        self.world = dist.get_world_size()
        self.ready = self.world > 1
        return self.ready

    def alloc_flags(self) -> None:
        import torch.distributed._symmetric_memory as symm_mem

        n = NUM_BARRIER_BLOCKS * self.world
        dev = torch.cuda.current_device()
        flags = symm_mem.empty(n, dtype=torch.int32, device=dev)
        flags.zero_()
        hdl = symm_mem.rendezvous(flags, self.group.group_name)
        self.flags = flags
        self.peer_flags = torch.tensor(
            [
                hdl.get_buffer(r, (n,), torch.int32).data_ptr()
                for r in range(self.world)
            ],
            dtype=torch.int64,
            device=flags.device,
        )
        self.timeout = torch.zeros(1, dtype=torch.int32, device=flags.device)

    def slab_for(self, width: int, max_rows: int, dtype: torch.dtype):
        """Return ``(slab, peer_ptrs, slot_elems)`` for a given row width.

        One slab per (width, dtype), sized for the largest row count seen;
        smaller calls use the front of each slot. ``symm_mem`` rounds
        allocations up steeply, so a slab per shape is not affordable.

        Allocation and rendezvous are collectives: every rank must reach this
        with the same arguments, in the same order.
        """
        import torch.distributed._symmetric_memory as symm_mem

        key = (width, dtype)
        cached = self.slabs.get(key)
        if cached is not None and cached[2] >= max_rows * width:
            return cached

        slot = max_rows * width
        total = self.world * slot
        slab = symm_mem.empty(total, dtype=dtype, device=torch.cuda.current_device())
        slab.zero_()
        hdl = symm_mem.rendezvous(slab, self.group.group_name)
        ptrs = torch.tensor(
            [hdl.get_buffer(r, (total,), dtype).data_ptr() for r in range(self.world)],
            dtype=torch.int64,
            device=slab.device,
        )
        entry = (slab, ptrs, slot)
        self.slabs[key] = entry
        return entry

    def timed_out(self) -> bool:
        """Whether a barrier ever exhausted its spin budget. Syncs; diagnostic."""
        return self.timeout is not None and bool(self.timeout.item())


STATE = _State()
_READY: dict = {}


def _run(tensor: torch.Tensor, width: int, rows: int) -> None:
    import triton

    from aiter.ops.triton._triton_kernels.peer_all_reduce import (
        _peer_barrier_kernel,
        _peer_bcast_kernel,
        _reduce_slab_kernel,
    )

    st = STATE
    slab, ptrs, slot = st.slabs[(width, tensor.dtype)]
    numel = rows * width
    grid = (triton.cdiv(numel, _BLOCK),)
    flat = tensor.view(-1)

    if st.flags is None:
        st.alloc_flags()

    _peer_bcast_kernel[grid](
        flat,
        ptrs,
        numel,
        slot,
        RANK=st.rank,
        WORLD_SIZE=st.world,
        BLOCK_SIZE=_BLOCK,
    )

    st.seq += 1
    _peer_barrier_kernel[(NUM_BARRIER_BLOCKS,)](
        st.peer_flags,
        st.flags,
        st.timeout,
        st.seq,
        0,
        RANK=st.rank,
        WORLD_SIZE=st.world,
        MAX_SPIN=MAX_SPIN,
    )

    # Safe in place: the only reader of `tensor` was the broadcast above, which
    # has already retired on this stream. Reducing into a scratch buffer and
    # returning it instead invites the caller to rebind a local name, which
    # leaves each rank holding its own un-summed partial.
    _reduce_slab_kernel[grid](
        slab,
        flat,
        numel,
        slot,
        WORLD_SIZE=st.world,
        BLOCK_SIZE=_BLOCK,
        ZERO_AFTER=True,
    )


def maybe_all_reduce(tensor: torch.Tensor) -> bool:
    """All-reduce ``tensor`` in place across the TP group.

    Returns False without touching ``tensor`` when the path is disabled or
    unavailable, so the caller can fall back to its usual collective.

    ``tensor`` must be contiguous and 2-D, ``[rows, width]``.

    Eligibility depends only on the env flag and on ``(width, rows, dtype)``,
    all of which are identical across ranks. This matters: both branches
    contain collectives, so a per-rank decision -- an exception on one rank, an
    allocation that fails on another -- deadlocks the group.
    """
    if not _ENABLED:
        return False
    if tensor.dim() != 2 or not tensor.is_contiguous():
        return False

    rows, width = tensor.shape
    key = (width, rows, tensor.dtype)
    state = _READY.get(key, False)
    if state is False:
        if not STATE.init():
            _READY[key] = None
            return False
        STATE.slab_for(width, rows, tensor.dtype)
        _READY[key] = True
    elif state is None:
        return False

    _run(tensor, width, rows)
    return True
