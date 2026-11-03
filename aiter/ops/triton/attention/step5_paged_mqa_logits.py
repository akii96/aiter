# SPDX-License-Identifier: MIT
# Copyright (C) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.

import torch
import triton

from aiter.ops.triton._triton_kernels.attention.step5_paged_mqa_logits import (
    _step5_paged_mqa_logits_kernel,
)
from aiter.ops.triton.utils._triton import arch_info

_FNUZ_ARCHS = ("gfx942",)


def step5_paged_mqa_logits(
    q: torch.Tensor,
    kv_fused: torch.Tensor,
    weights: torch.Tensor,
    block_tables: torch.Tensor,
    seq_lens: torch.Tensor,
    max_seq_len: int,
    *,
    schedule_meta: torch.Tensor | None = None,
    block_r: int | None = None,
    tile: int = 128,
    tiles_per_program: int = 8,
    num_warps: int = 8,
) -> torch.Tensor:
    """Step-5 CSA indexer logits over packed FP8 summary pages.

    Same contract as vLLM's ``paged_mqa_logits_sm90``:
      q:            fp8 e4m3fn [batch, next_n, heads, 256], heads in (4, 8, 16)
      kv_fused:     uint8 [pages, page_size, 1, 260]; each page holds
                    page_size * 256 FP8 keys followed by page_size FP32 scales
      weights:      fp32 [batch * next_n, heads]
      block_tables: int32 [batch, pages_per_req]
      seq_lens:     int32 [batch], number of visible regions per request
    Returns fp32 [batch * next_n, max_seq_len] holding
    ``scale[k] * sum_h(w[h] * relu(q[h] . key[k]))``, ``-inf`` past each length.

    Rows sharing a page mapping reuse one key tile across ``block_r`` rows.
    On gfx942 the OCP e4m3 bits run on the native fnuz MFMA path.
    """
    del schedule_meta
    batch, next_n, heads, dim = q.shape
    assert q.dtype == torch.float8_e4m3fn and dim == 256
    assert heads in (4, 8, 16) and q.stride(-1) == 1
    assert kv_fused.dtype == torch.uint8 and kv_fused.is_contiguous()
    assert kv_fused.shape[2:] == (1, 260)
    assert weights.shape == (batch * next_n, heads)
    rows = batch * next_n
    output = torch.empty((rows, max_seq_len), dtype=torch.float32, device=q.device)
    if not (rows and max_seq_len):
        return output
    if block_r is None:
        block_r = 128 // heads
    tiles = triton.cdiv(max_seq_len, tile)
    tiles_per_program = max(1, min(tiles_per_program, tiles))
    _step5_paged_mqa_logits_kernel[
        (triton.cdiv(rows, block_r), triton.cdiv(tiles, tiles_per_program))
    ](
        q.view(torch.uint8),
        kv_fused,
        weights,
        seq_lens,
        block_tables,
        output,
        rows,
        *q.stride()[:3],
        *weights.stride(),
        kv_fused.stride(0),
        *block_tables.stride(),
        seq_lens.stride(0),
        max_seq_len,
        next_n,
        heads,
        kv_fused.shape[1],
        block_r,
        tile,
        tiles_per_program,
        arch_info.get_arch() in _FNUZ_ARCHS,
        num_warps=num_warps,
    )
    return output
