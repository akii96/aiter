# SPDX-License-Identifier: MIT
# Copyright (C) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""Sparse paged-attention decode over an MXFP4 K/V cache (gfx942 gluon).

Derived from ``pa_decode_gluon`` (the ``ps=True`` sliding-window head-1 kernel,
specialized to head_dim 128, page 16, partition 256, fp8 compute, per-token KV
scales). Only the K/V load stage differs: each token's 64 packed e2m1 bytes and
four e8m0 chunk scales are read from the MXFP4 page and decoded in registers to
e4m3fnuz with the chunk scale folded in relative to the token's largest chunk
exponent (``v_perm_b32`` LUT). The token's 2^(emax-127) then rides the existing
per-token KV-scale path, so the MFMA / softmax stages are unchanged.

Cache layout ``kv_cache``: uint8 ``[num_blocks, 2H, 128, 68]``; per (block, head
slot) an 8704-byte page ``[128 tok x 64 B e2m1][128 tok x 4 B e8m0]``; K heads in
slots ``[0, H)``, V heads in ``[H, 2H)``. ``block_tables`` row ``r*H + h`` lists
page-16 entries ``(block*8 + j)*H + h`` (sub-page j = tokens 16j..16j+15).

Decode is exact while a token's chunk exponents are within 6 binades of its max
(normal fp8) and exact up to fp8 subnormal rounding to 13 binades; beyond that
the chunk flushes to zero.
"""

import torch
import triton
import triton.language as tl
from triton.experimental import gluon
from triton.experimental.gluon import language as gl
from triton.language.extra.hip import libdevice as hip_libdevice

from aiter.ops.triton.gluon.pa_decode_gluon import (
    _fused_max_combine,
    _paged_attention_decode_v2_reduce_kernel_wrapper,
    define_layout,
    get_cdna_version,
    get_recommended_splits,
)

PAGE_TOKENS = 128
HEAD_DIM = 128
PAGE_BYTES = PAGE_TOKENS * (HEAD_DIM // 2 + HEAD_DIM // 32)  # 8704

# One packed dword $5 (8 e2m1 nibbles, element 2i = low nibble of byte i) ->
# $0 = fp8 bytes of elements 0..3, $1 = elements 4..7. $6 / $7 are the
# per-(token, chunk) LUT words for magnitudes 0..3 / 4..7 (v_perm_b32 picks
# bytes 0-3 from src1, 4-7 from src0). FNUZ: -0 must not become 0x80 (NaN), so
# the sign is applied only where the magnitude byte is nonzero (byte + 0x7F
# sets bit 7 iff byte != 0; magnitudes are <= 0x54 so no carry escapes).
# gfx942 VOP3 takes no literals, hence the v_mov for the selectors.
_DEC_ASM = gl.constexpr(
    """
v_and_b32 $2, 0x07070707, $5
v_lshrrev_b32 $3, 4, $5
v_and_b32 $3, 0x07070707, $3
v_perm_b32 $2, $7, $6, $2
v_perm_b32 $3, $7, $6, $3
v_add_u32 $4, 0x7F7F7F7F, $2
v_and_b32 $4, 0x80808080, $4
v_lshlrev_b32 $0, 4, $5
v_and_or_b32 $2, $0, $4, $2
v_add_u32 $4, 0x7F7F7F7F, $3
v_and_b32 $4, 0x80808080, $4
v_and_or_b32 $3, $5, $4, $3
v_mov_b32 $4, 0x05010400
v_perm_b32 $0, $3, $2, $4
v_mov_b32 $4, 0x07030602
v_perm_b32 $1, $3, $2, $4
s_nop 4
"""
)
_DEC_CON = gl.constexpr("=&v,=&v,=&v,=&v,=&v,v,v,v")


@gluon.jit
def _e2m1_lut(k):
    """k = emax - e_chunk (>= 0) -> e4m3fnuz bytes of e2m1 magnitudes * 2^-k."""
    lo = 0x44403800 - k * 0x08080800  # 0, .5, 1, 1.5   (normal for k <= 6)
    hi = 0x54504C48 - k * 0x08080808  # 2, 3, 4, 6      (normal for k <= 8)
    lo = gl.where(k == 7, 0x0C080400, lo)
    lo = gl.where(k == 8, 0x06040200, lo)
    lo = gl.where(k == 9, 0x03020100, lo)
    lo = gl.where(k == 10, 0x02010000, lo)
    lo = gl.where(k == 11, 0x01000000, lo)
    lo = gl.where(k >= 12, 0, lo)
    hi = gl.where(k == 9, 0x0C080604, hi)
    hi = gl.where(k == 10, 0x06040302, hi)
    hi = gl.where(k == 11, 0x03020201, hi)
    hi = gl.where(k == 12, 0x02010100, hi)
    hi = gl.where(k == 13, 0x01000000, hi)
    hi = gl.where(k >= 14, 0, hi)
    return lo, hi


@gluon.jit
def _decode_tile(raw, w, split_idx, NB: gl.constexpr, LAYOUT16: gl.constexpr):
    """raw int32 [NB, 8, 16, 2] packed e2m1 dwords (split s = elements
    16s..16s+15), w int32 [NB, 1, 16, 1] the token's four e8m0 bytes.
    Returns (fp8 [NB, 8, 16, 16], per-token scale fp32 [NB, 1, 16, 1])."""
    e0 = w & 255
    e1 = (w >> 8) & 255
    e2 = (w >> 16) & 255
    e3 = (w >> 24) & 255
    emax = gl.maximum(gl.maximum(e0, e1), gl.maximum(e2, e3))
    emax = gl.minimum(emax, 254)
    shift = (split_idx[None, :, None, None] // 2) * 8
    ec = (w >> shift) & 255
    lo, hi = _e2m1_lut(gl.maximum(emax - ec, 0))
    o0, o1, _t0, _t1, _t2 = gl.inline_asm_elementwise(
        _DEC_ASM,
        _DEC_CON,
        [raw, lo, hi],
        dtype=(gl.int32, gl.int32, gl.int32, gl.int32, gl.int32),
        is_pure=True,
        pack=1,
    )
    d = gl.reshape(gl.join(o0, o1), [NB, 8, 16, 4])  # dwords of elements 0..15
    b0 = d.to(gl.uint8)
    b1 = (d >> 8).to(gl.uint8)
    b2 = (d >> 16).to(gl.uint8)
    b3 = (d >> 24).to(gl.uint8)
    x = gl.reshape(gl.join(gl.join(b0, b2), gl.join(b1, b3)), [NB, 8, 16, 16])
    x = gl.convert_layout(x, LAYOUT16)
    scale = (emax << 23).to(gl.float32, bitcast=True)
    return x.to(gl.float8e4b8, bitcast=True), scale


@gluon.jit
def _token_scale(w):
    emax = gl.maximum(
        gl.maximum(w & 255, (w >> 8) & 255), gl.maximum((w >> 16) & 255, (w >> 24) & 255)
    )
    return (gl.minimum(emax, 254) << 23).to(gl.float32, bitcast=True)


@gluon.jit
def _page_bases(
    bt_ptr, bt_off, nvalid, idx, stride_kv_block, NUM_KV_HEADS: gl.constexpr
):
    e = gl.load(bt_ptr + bt_off + idx, mask=idx < nvalid, other=0)
    h = e % NUM_KV_HEADS
    j = (e // NUM_KV_HEADS) % 8
    blk = e // (8 * NUM_KV_HEADS)
    base = blk.to(gl.int64) * stride_kv_block + h * 8704
    return base, j * 16


@gluon.jit
def pa_decode_mxfp4_kernel(
    exp_sums_ptr,  # [num_seqs, 1, max_parts, group]
    max_logits_ptr,
    output_ptr,  # one-shot: [num_seqs, group, D]; else [num_seqs, 1, parts, group, D]
    query_ptr,  # [num_seqs, group, D] bf16
    kv_ptr,  # uint8 cache
    kv_i32_ptr,  # same cache as int32
    block_tables_ptr,  # [num_seqs, >= 128] int32 page-16 entries
    context_lengths_ptr,  # [num_seqs]
    softmax_scale,
    stride_ml_seq,
    stride_ml_part,
    stride_out_seq,
    stride_out_part,
    stride_out_group,
    stride_q_seq,
    stride_q_group,
    stride_kv_block,  # bytes per cache block (2H * 8704)
    stride_bt_seq,
    query_group_size,
    NUM_KV_HEADS: gl.constexpr,
    CDNA_VERSION: gl.constexpr,
    ONE_SHOT: gl.constexpr,
):
    GROUP: gl.constexpr = 16
    HEAD: gl.constexpr = 128
    PART: gl.constexpr = 256
    NB: gl.constexpr = PART // 16
    SPLITS: gl.constexpr = HEAD // 16
    COMPUTE_TYPE: gl.constexpr = gl.float8e4b8
    FP8_MAX: gl.constexpr = 240.0
    LOG2_E: gl.constexpr = 1.4426950408889634
    V_OFF: gl.constexpr = NUM_KV_HEADS * 8704

    seq = gl.program_id(0)
    split = gl.program_id(2)

    shared_query_layout: gl.constexpr = gl.SwizzledSharedLayout(8, 1, 16, order=[1, 0])
    shared_probs_layout: gl.constexpr = gl.SwizzledSharedLayout(8, 1, 8, order=[1, 0])
    blocked_query_layout: gl.constexpr = gl.BlockedLayout(
        size_per_thread=[1, 8],
        threads_per_warp=[4, 16],
        warps_per_cta=[1, 4],
        order=[1, 0],
    )
    kv8: gl.constexpr = gl.BlockedLayout(
        size_per_thread=[1, 1, 1, 2],
        threads_per_warp=[1, 4, 16, 1],
        warps_per_cta=[4, 1, 1, 1],
        order=[3, 2, 1, 0],
    )
    kv16: gl.constexpr = gl.BlockedLayout(
        size_per_thread=[1, 1, 1, 16],
        threads_per_warp=[1, 4, 16, 1],
        warps_per_cta=[4, 1, 1, 1],
        order=[3, 2, 1, 0],
    )
    mfma_layout: gl.constexpr = gl.amd.AMDMFMALayout(
        version=CDNA_VERSION,
        instr_shape=[16, 16, 32],
        transposed=True,
        warps_per_cta=[1, 4],
    )
    lhs_layout: gl.constexpr = gl.DotOperandLayout(
        operand_index=0, parent=mfma_layout, k_width=16
    )
    rhs_layout: gl.constexpr = gl.DotOperandLayout(
        operand_index=1, parent=mfma_layout, k_width=16
    )
    qk_linear_layout: gl.constexpr = define_layout(GROUP, PART, 1)
    col_layout: gl.constexpr = gl.SliceLayout(0, qk_linear_layout)
    row_layout: gl.constexpr = gl.SliceLayout(1, qk_linear_layout)

    # Index vectors (kv8 for byte loads, kv16 for decode-side tensors).
    b8 = gl.arange(0, NB, layout=gl.SliceLayout(1, gl.SliceLayout(2, gl.SliceLayout(3, kv8))))
    s8 = gl.arange(0, SPLITS, layout=gl.SliceLayout(0, gl.SliceLayout(2, gl.SliceLayout(3, kv8))))
    t8 = gl.arange(0, 16, layout=gl.SliceLayout(0, gl.SliceLayout(1, gl.SliceLayout(3, kv8))))
    c8 = gl.arange(0, 2, layout=gl.SliceLayout(0, gl.SliceLayout(1, gl.SliceLayout(2, kv8))))
    # dword offsets of a token's packed data within its 16-token sub-page
    in_page8 = (
        t8[None, None, :, None] * 16 + s8[None, :, None, None] * 2 + c8[None, None, None, :]
    )

    context_length = gl.load(context_lengths_ptr + seq)
    num_splits = gl.num_programs(2)
    page_size = gl.cdiv(context_length, num_splits)
    seq_start = page_size * split
    seq_end = gl.minimum(context_length, page_size + seq_start)
    part_start = seq_start // PART
    part_end = gl.cdiv(seq_end, PART)
    max_nb = gl.cdiv(context_length, 16)
    bt_off = seq * stride_bt_seq

    g_offs = gl.arange(0, GROUP, layout=gl.SliceLayout(1, blocked_query_layout))
    d_offs = gl.arange(0, HEAD, layout=gl.SliceLayout(0, blocked_query_layout))
    qrow_mask = g_offs < query_group_size
    row_mask = gl.convert_layout(qrow_mask, row_layout)
    pv_row_mask = gl.convert_layout(row_mask, gl.SliceLayout(1, mfma_layout))
    out_g = gl.arange(0, GROUP, layout=gl.SliceLayout(1, mfma_layout))
    out_d = gl.arange(0, HEAD, layout=gl.SliceLayout(0, mfma_layout))

    max_logits = gl.full((GROUP,), float("-inf"), dtype=gl.float32, layout=row_layout)
    exp_sums = gl.full((GROUP,), 0.0, dtype=gl.float32, layout=row_layout)
    acc = gl.zeros((GROUP, HEAD), dtype=gl.float32, layout=mfma_layout)

    if ONE_SHOT:
        out_offsets = seq * stride_out_seq + g_offs[:, None] * stride_out_group + d_offs[None, :]
        out_mask = qrow_mask[:, None]
    else:
        out_offsets = (
            seq * stride_out_seq
            + split * stride_out_part
            + out_g[:, None] * stride_out_group
            + out_d[None, :]
        )
        out_mask = pv_row_mask[:, None]
        ml_offsets = seq * stride_ml_seq + split * stride_ml_part + gl.arange(
            0, GROUP, layout=row_layout
        )

    if (seq_start >= context_length) | (part_start >= part_end):
        if not ONE_SHOT:
            gl.store(max_logits_ptr + ml_offsets, max_logits, mask=row_mask)
            gl.store(exp_sums_ptr + ml_offsets, exp_sums, mask=row_mask)
            gl.store(output_ptr + out_offsets, acc.to(gl.bfloat16), mask=out_mask)
        return

    q = gl.load(
        query_ptr + seq * stride_q_seq + g_offs[:, None] * stride_q_group + d_offs[None, :],
        mask=qrow_mask[:, None],
        other=0.0,
    )
    query_shared = gl.allocate_shared_memory(
        COMPUTE_TYPE, [GROUP, HEAD], shared_query_layout
    )
    probs_shared = gl.allocate_shared_memory(
        COMPUTE_TYPE, [GROUP, PART], shared_probs_layout
    )
    query_shared.store(q.to(COMPUTE_TYPE))
    query_op = query_shared.load(lhs_layout)
    col_idx = gl.arange(0, PART, layout=col_layout)

    for p in range(part_start, part_end):
        nvalid = max_nb - p * NB
        base, row = _page_bases(
            block_tables_ptr, bt_off + p * NB, nvalid, b8, stride_kv_block, NUM_KV_HEADS
        )
        dw0 = base // 4
        k_off = (dw0 + row * 16)[:, None, None, None] + in_page8
        k_raw = gl.load(kv_i32_ptr + k_off)
        v_raw = gl.load(kv_i32_ptr + (k_off + V_OFF // 4))
        sc_off = (dw0 + 2048 + row)[:, None, None, None] + t8[None, None, :, None]
        k_w = gl.load(kv_i32_ptr + sc_off)
        v_w = gl.load(kv_i32_ptr + (sc_off + V_OFF // 4))

        # ---- K: decode, QK^T ----
        k_dec, _ks = _decode_tile(k_raw, k_w, s8, NB, kv16)
        k_op = gl.permute(k_dec, [1, 3, 0, 2])
        k_op = gl.reshape(k_op, [HEAD, PART])
        k_op = gl.convert_layout(k_op, layout=rhs_layout)
        scores = gl.amd.cdna3.mfma(
            query_op, k_op, gl.zeros((GROUP, PART), dtype=gl.float32, layout=mfma_layout)
        )
        # ---- V: decode (token-major) ----
        v_dec, _vs = _decode_tile(v_raw, v_w, s8, NB, kv16)
        v_op = gl.permute(v_dec, [0, 2, 1, 3])
        v_op = gl.reshape(v_op, [PART, HEAD])
        v_op = gl.convert_layout(v_op, layout=rhs_layout)

        # Per-token scales straight in the score-column layout (reshaping the
        # replicated [NB, 1, 16, 1] decode-side tensor is not layout-safe).
        cbase, crow = _page_bases(
            block_tables_ptr, bt_off + p * NB, nvalid, col_idx // 16, stride_kv_block, NUM_KV_HEADS
        )
        c_off = cbase // 4 + 2048 + crow + col_idx % 16
        k_scale = _token_scale(gl.load(kv_i32_ptr + c_off))
        v_scale = _token_scale(gl.load(kv_i32_ptr + (c_off + V_OFF // 4)))

        cols = p * PART + col_idx
        mask = row_mask[:, None] & ((cols >= seq_start) & (cols < seq_end))[None, :]
        scores = gl.convert_layout(scores, layout=qk_linear_layout)
        scores = (softmax_scale * k_scale[None, :]) * scores
        scores = gl.where(mask, scores, -3.4e38)

        v_scale = gl.where(cols < context_length, v_scale, 0.0)
        v_scale_b = tl.broadcast_to(v_scale[None, :], scores.shape)
        cur_max, v_scale_max_2d = gl.reduce(
            (scores, v_scale_b), axis=1, combine_fn=_fused_max_combine
        )
        v_scale_max = gl.max(v_scale_max_2d, axis=0)
        new_max = gl.maximum(max_logits, cur_max)
        alpha = tl.math.exp2((max_logits - new_max) * LOG2_E)
        probs = tl.math.exp2((scores - new_max[:, None]) * LOG2_E)
        exp_sums = alpha * exp_sums + gl.sum(probs, axis=1)

        inv_vmax = hip_libdevice.fast_dividef(1.0, v_scale_max + 1e-30)
        probs = (v_scale_b * (FP8_MAX * inv_vmax)) * probs
        prob_scale = v_scale_max * (1.0 / FP8_MAX)
        probs_shared.store(probs.to(COMPUTE_TYPE))
        probs_op = probs_shared.load(lhs_layout)
        acc = acc * gl.convert_layout(alpha[:, None], layout=mfma_layout)
        pv = gl.amd.cdna3.mfma(
            probs_op, v_op, gl.zeros((GROUP, HEAD), dtype=gl.float32, layout=mfma_layout)
        )
        acc += prob_scale * pv
        max_logits = new_max

    safe = gl.where(exp_sums > 0, exp_sums, 1.0)
    acc = acc * gl.convert_layout((1.0 / safe)[:, None], layout=mfma_layout)
    if ONE_SHOT:
        res = gl.convert_layout(acc.to(gl.bfloat16), layout=blocked_query_layout)
        gl.store(output_ptr + out_offsets, res, mask=out_mask)
    else:
        gl.store(max_logits_ptr + ml_offsets, max_logits, mask=row_mask)
        gl.store(exp_sums_ptr + ml_offsets, exp_sums, mask=row_mask)
        gl.store(output_ptr + out_offsets, acc.to(gl.bfloat16), mask=out_mask)


def pa_decode_mxfp4_gluon(
    output: torch.Tensor,  # [rows, Hq, 128] bf16
    query: torch.Tensor,  # [rows, Hq, 128] bf16
    kv_cache: torch.Tensor,  # uint8 [num_blocks, 2H, 128, 68]
    context_lengths: torch.Tensor,  # int32 [rows * H]
    block_tables: torch.Tensor,  # int32 [rows * H, >= 128], page-16 entries
    softmax_scale: float,
    num_kv_heads: int,
    max_context_partition_num: int | None = None,
    exp_sums: torch.Tensor | None = None,
    max_logits: torch.Tensor | None = None,
    temporary_output: torch.Tensor | None = None,
) -> torch.Tensor:
    """Sparse MXFP4 paged-attention decode; row ``r*H + h`` of ``block_tables``
    / ``context_lengths`` drives query row r, KV head h (heads h*G..h*G+G-1)."""
    rows, num_q_heads, head = query.shape
    H = num_kv_heads
    group = num_q_heads // H
    assert head == HEAD_DIM and group == 16, "head_dim 128, GQA group 16 only"
    assert kv_cache.dtype == torch.uint8 and kv_cache.is_contiguous()
    assert kv_cache[0].numel() == 2 * H * PAGE_BYTES
    assert query.is_contiguous() and output.is_contiguous()
    assert block_tables.dtype == torch.int32 and block_tables.stride(1) == 1
    num_seqs = rows * H
    if num_seqs == 0:
        return output
    q_view = query.view(num_seqs, group, head)
    out_view = output.view(num_seqs, group, head)
    splits = max_context_partition_num or get_recommended_splits(num_seqs, 1)
    one_shot = splits <= 1
    if not one_shot:
        shape = (num_seqs, 1, splits, group)
        if exp_sums is None:
            exp_sums = torch.empty(shape, dtype=torch.float32, device=query.device)
        if max_logits is None:
            max_logits = torch.empty(shape, dtype=torch.float32, device=query.device)
        if temporary_output is None:
            temporary_output = torch.empty(
                *shape, head, dtype=query.dtype, device=query.device
            )
        out_k = temporary_output
        so_seq, so_part, so_group = out_k.stride(0), out_k.stride(2), out_k.stride(3)
        ml_seq, ml_part = exp_sums.stride(0), exp_sums.stride(2)
    else:
        out_k = out_view
        exp_sums = max_logits = out_view  # unused
        so_seq, so_part, so_group = out_view.stride(0), 0, out_view.stride(1)
        ml_seq = ml_part = 0
    pa_decode_mxfp4_kernel[(num_seqs, 1, splits)](
        exp_sums,
        max_logits,
        out_k,
        q_view,
        kv_cache,
        kv_cache.view(torch.int32),
        block_tables,
        context_lengths,
        softmax_scale,
        ml_seq,
        ml_part,
        so_seq,
        so_part,
        so_group,
        q_view.stride(0),
        q_view.stride(1),
        kv_cache.stride(0),
        block_tables.stride(0),
        group,
        NUM_KV_HEADS=H,
        CDNA_VERSION=get_cdna_version(),
        ONE_SHOT=one_shot,
        num_warps=4,
    )
    if not one_shot:
        out5 = out_view.view(num_seqs, 1, 1, group, head)
        _paged_attention_decode_v2_reduce_kernel_wrapper(
            (num_seqs, 1, 1),
            out5,
            exp_sums,
            max_logits,
            temporary_output,
            context_lengths,
            None,
            out5.stride(0),
            out5.stride(1),
            out5.stride(2),
            out5.stride(3),
            exp_sums.stride(0),
            exp_sums.stride(1),
            exp_sums.stride(2),
            temporary_output.stride(0),
            temporary_output.stride(1),
            temporary_output.stride(2),
            temporary_output.stride(3),
            query_seq_len=1,
            query_group_size=group,
            head_size=head,
            CONTEXT_PARTITION_SIZE=256,
            PS=True,
            context_partition_num=splits,
        )
    return output
