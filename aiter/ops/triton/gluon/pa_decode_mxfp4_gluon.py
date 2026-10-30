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
def _perm(hi, lo, sel):
    """v_perm_b32: byte i of the result = byte sel[i] of the 8-byte {hi, lo}."""
    return gl.inline_asm_elementwise(
        "v_perm_b32 $0, $1, $2, $3", "=v,v,v,v", [hi, lo, sel],
        dtype=gl.int32, is_pure=True, pack=1,
    )


@gluon.jit
def _perm_mfma(hi, lo, sel):
    """v_perm_b32 whose result feeds an MFMA operand directly: LLVM's hazard
    recognizer does not see inside inline asm, so wait out VALU -> MFMA here."""
    return gl.inline_asm_elementwise(
        "v_perm_b32 $0, $1, $2, $3\ns_nop 2", "=v,v,v,v", [hi, lo, sel],
        dtype=gl.int32, is_pure=True, pack=1,
    )


@gluon.jit
def _dec_dword(d, lo, hi):
    """8 packed e2m1 nibbles -> (fp8 bytes of elements 0..3, 4..7) using the
    per-chunk LUT words (lo: magnitudes 0..3, hi: 4..7). FNUZ -0 -> 0x00."""
    me = _perm(hi, lo, d & 0x07070707)
    mo = _perm(hi, lo, (d >> 4) & 0x07070707)
    se = ((d << 4) & ((me + 0x7F7F7F7F) & -0x7F7F7F80))
    so = (d & ((mo + 0x7F7F7F7F) & -0x7F7F7F80))
    e = me | se
    o = mo | so
    return _perm_mfma(o, e, gl.full(d.shape, 0x05010400, gl.int32, d.type.layout)), _perm_mfma(
        o, e, gl.full(d.shape, 0x07030602, gl.int32, d.type.layout)
    )


@gluon.jit
def _cvt_pk4(a, b, c, d):
    """Four f32 -> one dword of e4m3fnuz bytes [a, b, c, d] (RNE, saturating)."""
    return gl.inline_asm_elementwise(
        "v_cvt_pk_fp8_f32 $0, $1, $2\nv_cvt_pk_fp8_f32 $0, $3, $4 op_sel:[0,0,1]",
        "=&v,v,v,v,v", [a, b, c, d], dtype=gl.int32, is_pure=True, pack=1,
    )


@gluon.jit
def _e2m1_lut(k):
    """k = emax - e_chunk (>= 0) -> e4m3fnuz bytes of the e2m1 magnitudes
    [0, .5, 1, 1.5] and [2, 3, 4, 6] times 2^-k (exact while representable,
    RNE into the fp8 subnormals, zero past them)."""
    sc = ((127 - gl.minimum(k, 100)) << 23).to(gl.float32, bitcast=True)
    lo = _cvt_pk4(sc * 0.0, sc * 0.5, sc, sc * 1.5)
    hi = _cvt_pk4(sc * 2.0, sc * 3.0, sc * 4.0, sc * 6.0)
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
    o0, o1 = _dec_dword(raw, lo, hi)
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
def _decode_v(raw, w, shift, NW: gl.constexpr, SPW: gl.constexpr):
    """raw int32 [4, 4, 16, 16] packed e2m1 (dword g = head dims 8g..8g+7) of
    [warp, sub-page, token, g]; w int32 [4, 4, 16, 1] token scale words ->
    uint8 [4, 64, 128] e4m3fnuz, column n = 16 * e + g holding dim 8g + e."""
    emax = gl.maximum(
        gl.maximum(w & 255, (w >> 8) & 255), gl.maximum((w >> 16) & 255, (w >> 24) & 255)
    )
    emax = gl.minimum(emax, 254)
    ec = (w >> shift) & 255
    lo, hi = _e2m1_lut(gl.maximum(emax - ec, 0))
    o0, o1 = _dec_dword(raw, lo, hi)
    d = gl.join(o0, o1)  # [4, 4, 16, 16, 2]
    b0 = d.to(gl.uint8)
    b1 = (d >> 8).to(gl.uint8)
    b2 = (d >> 16).to(gl.uint8)
    b3 = (d >> 24).to(gl.uint8)
    x = gl.reshape(gl.join(gl.join(b0, b2), gl.join(b1, b3)), [NW, SPW, 16, 16, 8])
    x = gl.permute(x, [0, 1, 2, 4, 3])  # [w, sp, t, e, g]
    return gl.reshape(x, [NW, SPW * 16, 128])


@gluon.jit
def _decode_k(raw, w, shift):
    """raw int32 [16, 256] (dword q of token n), w int32 [1, 256] scale words
    -> uint8 [128, 256] e4m3fnuz, row k = head dim."""
    emax = gl.maximum(
        gl.maximum(w & 255, (w >> 8) & 255), gl.maximum((w >> 16) & 255, (w >> 24) & 255)
    )
    emax = gl.minimum(emax, 254)
    ec = (w >> shift) & 255
    lo, hi = _e2m1_lut(gl.maximum(emax - ec, 0))
    o0, o1 = _dec_dword(raw, lo, hi)
    d = gl.join(o0, o1)  # [16, 256, 2]
    b0 = d.to(gl.uint8)
    b1 = (d >> 8).to(gl.uint8)
    b2 = (d >> 16).to(gl.uint8)
    b3 = (d >> 24).to(gl.uint8)
    x = gl.reshape(gl.join(gl.join(b0, b2), gl.join(b1, b3)), [16, 256, 8])
    x = gl.permute(x, [0, 2, 1])
    return gl.reshape(x, [128, 256])


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
    e = e.to(gl.uint32)  # entries are >= 0; unsigned div/mod by constants is shifts
    h = (e % NUM_KV_HEADS).to(gl.int32)
    j = ((e // NUM_KV_HEADS) % 8).to(gl.int32)
    blk = (e // (8 * NUM_KV_HEADS)).to(gl.int32)
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
    NUM_WARPS: gl.constexpr = 4,
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
        warps_per_cta=[NUM_WARPS // 4, 4],
        order=[1, 0],
    )
    kv8: gl.constexpr = gl.BlockedLayout(
        size_per_thread=[1, 1, 1, 2],
        threads_per_warp=[1, 4, 16, 1],
        warps_per_cta=[NUM_WARPS, 1, 1, 1],
        order=[3, 2, 1, 0],
    )
    kv16: gl.constexpr = gl.BlockedLayout(
        size_per_thread=[1, 1, 1, 16],
        threads_per_warp=[1, 4, 16, 1],
        warps_per_cta=[NUM_WARPS, 1, 1, 1],
        order=[3, 2, 1, 0],
    )
    mfma_layout: gl.constexpr = gl.amd.AMDMFMALayout(
        version=CDNA_VERSION,
        instr_shape=[16, 16, 32],
        transposed=True,
        warps_per_cta=[1, NUM_WARPS],
    )
    lhs_layout: gl.constexpr = gl.DotOperandLayout(
        operand_index=0, parent=mfma_layout, k_width=16
    )
    rhs_layout: gl.constexpr = gl.DotOperandLayout(
        operand_index=1, parent=mfma_layout, k_width=16
    )
    qk_linear_layout: gl.constexpr = mfma_layout
    # PV runs as a batched MFMA: warp w owns tokens 64w..64w+63 of the partition
    # and all 128 output columns; the four partial accumulators are summed once
    # at the end. Output column n holds head dim d = 8 * (n % 16) + n // 16, so
    # the eight columns a lane holds per token are one packed e2m1 dword: the
    # V loads stay 64 B-coalesced per token and the token-major -> K-contiguous
    # transpose the MFMA operand needs is register-local.
    NW: gl.constexpr = NUM_WARPS
    TPW: gl.constexpr = PART // NW  # tokens per warp slice (64 or 32)
    SPW: gl.constexpr = TPW // 16  # sub-pages per warp slice
    pv3_layout: gl.constexpr = gl.amd.AMDMFMALayout(
        version=CDNA_VERSION,
        instr_shape=[16, 16, 32],
        transposed=True,
        warps_per_cta=[NW, 1, 1],
    )
    p3_layout: gl.constexpr = gl.DotOperandLayout(
        operand_index=0, parent=pv3_layout, k_width=8
    )
    v3_layout: gl.constexpr = gl.DotOperandLayout(
        operand_index=1, parent=pv3_layout, k_width=8
    )
    # [warp, sub-page in warp, token in sub-page, dword] matching v3_layout
    if NW == 4:
        vload_layout: gl.constexpr = gl.DistributedLinearLayout(
            reg_bases=[[0, 0, 1, 0], [0, 0, 2, 0], [0, 0, 4, 0], [0, 2, 0, 0]],
            lane_bases=[[0, 0, 0, 1], [0, 0, 0, 2], [0, 0, 0, 4], [0, 0, 0, 8], [0, 0, 8, 0], [0, 1, 0, 0]],
            warp_bases=[[1, 0, 0, 0], [2, 0, 0, 0]],
            block_bases=[],
            shape=[NW, SPW, 16, 16],
        )
        kload_layout: gl.constexpr = gl.DistributedLinearLayout(
            reg_bases=[[1, 0], [8, 0], [0, 64], [0, 128]],
            lane_bases=[[0, 1], [0, 2], [0, 4], [0, 8], [2, 0], [4, 0]],
            warp_bases=[[0, 16], [0, 32]],
            block_bases=[],
            shape=[16, 256],
        )
    else:
        vload_layout: gl.constexpr = gl.DistributedLinearLayout(
            reg_bases=[[0, 0, 1, 0], [0, 0, 2, 0], [0, 0, 4, 0]],
            lane_bases=[[0, 0, 0, 1], [0, 0, 0, 2], [0, 0, 0, 4], [0, 0, 0, 8], [0, 0, 8, 0], [0, 1, 0, 0]],
            warp_bases=[[1, 0, 0, 0], [2, 0, 0, 0], [4, 0, 0, 0]],
            block_bases=[],
            shape=[NW, SPW, 16, 16],
        )
        kload_layout: gl.constexpr = gl.DistributedLinearLayout(
            reg_bases=[[1, 0], [8, 0], [0, 128]],
            lane_bases=[[0, 1], [0, 2], [0, 4], [0, 8], [2, 0], [4, 0]],
            warp_bases=[[0, 16], [0, 32], [0, 64]],
            block_bases=[],
            shape=[16, 256],
        )
    shared_p3_layout: gl.constexpr = gl.SwizzledSharedLayout(8, 1, 8, order=[2, 1, 0])
    acc_layout: gl.constexpr = gl.SliceLayout(0, pv3_layout)
    # kload: [dword q of the token (head dims 8q..8q+7), token n] matching
    # rhs_layout (k_width 16): a lane holds dwords 2c, 2c+1 of a token.
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

    vw_idx = gl.arange(0, NW, layout=gl.SliceLayout(1, gl.SliceLayout(2, gl.SliceLayout(3, vload_layout))))
    vsp_idx = gl.arange(0, SPW, layout=gl.SliceLayout(0, gl.SliceLayout(2, gl.SliceLayout(3, vload_layout))))
    vt_idx = gl.arange(0, 16, layout=gl.SliceLayout(0, gl.SliceLayout(1, gl.SliceLayout(3, vload_layout))))
    vg_idx = gl.arange(0, 16, layout=gl.SliceLayout(0, gl.SliceLayout(1, gl.SliceLayout(2, vload_layout))))
    v_sub = vw_idx[:, None] * SPW + vsp_idx[None, :]  # sub-page within the partition
    v_tok_dw = vt_idx[None, None, :, None] * 16 + vg_idx[None, None, None, :]
    v_shift = ((vg_idx // 4) * 8)[None, None, None, :]  # chunk of head dims 8g..8g+7

    kq_idx = gl.arange(0, 16, layout=gl.SliceLayout(1, kload_layout))
    kn_idx = gl.arange(0, PART, layout=gl.SliceLayout(0, kload_layout))
    k_shift = ((kq_idx // 4) * 8)[:, None]

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
    acc3 = gl.zeros((NW, GROUP, HEAD), dtype=gl.float32, layout=pv3_layout)

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
            gl.store(
                output_ptr + out_offsets,
                gl.zeros((GROUP, HEAD), dtype=gl.bfloat16, layout=mfma_layout),
                mask=out_mask,
            )
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
        COMPUTE_TYPE, [NW, GROUP, TPW], shared_p3_layout
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
        kbase, krow = _page_bases(
            block_tables_ptr, bt_off + p * NB, nvalid, kn_idx // 16, stride_kv_block, NUM_KV_HEADS
        )
        k_tok = kbase // 4 + krow * 16 + (kn_idx % 16) * 16  # token's first dword
        k_raw = gl.load(kv_i32_ptr + (k_tok[None, :] + kq_idx[:, None]))
        k_w = gl.load(kv_i32_ptr + (kbase // 4 + 2048 + krow + kn_idx % 16))[None, :]
        vbase, vrow = _page_bases(
            block_tables_ptr, bt_off + p * NB, nvalid, v_sub, stride_kv_block, NUM_KV_HEADS
        )
        v_dw = vbase // 4 + V_OFF // 4 + vrow * 16
        v_raw = gl.load(kv_i32_ptr + (v_dw[:, :, None, None] + v_tok_dw))
        v_w = gl.load(
            kv_i32_ptr + ((v_dw - vrow * 15 + 2048)[:, :, None, None] + vt_idx[None, None, :, None])
        )
        sc_off = (dw0 + 2048 + row)[:, None, None, None] + t8[None, None, :, None]

        # ---- K: decode, QK^T ----
        k_op = _decode_k(k_raw, k_w, k_shift)
        k_op = gl.convert_layout(k_op.to(COMPUTE_TYPE, bitcast=True), rhs_layout)
        scores = gl.amd.cdna3.mfma(
            query_op, k_op, gl.zeros((GROUP, PART), dtype=gl.float32, layout=mfma_layout)
        )
        # ---- V: decode (token-major) ----
        v_op = _decode_v(v_raw, v_w, v_shift, NW, SPW)
        v_op = gl.convert_layout(v_op.to(COMPUTE_TYPE, bitcast=True), v3_layout)

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
        p3 = gl.permute(gl.reshape(probs.to(COMPUTE_TYPE), [GROUP, NW, TPW]), [1, 0, 2])
        probs_shared.store(p3)
        probs_op = probs_shared.load(p3_layout)
        alpha3 = gl.convert_layout(alpha, gl.SliceLayout(0, gl.SliceLayout(2, pv3_layout)))
        acc3 = acc3 * alpha3[None, :, None]
        pv = gl.amd.cdna3.mfma(
            probs_op, v_op, gl.zeros((NW, GROUP, HEAD), dtype=gl.float32, layout=pv3_layout)
        )
        acc3 += prob_scale * pv
        max_logits = new_max

    safe = gl.where(exp_sums > 0, exp_sums, 1.0)
    accf = gl.sum(acc3, axis=0)
    inv = gl.convert_layout(1.0 / safe, gl.SliceLayout(1, acc_layout))
    accf = accf * inv[:, None]
    # column n = 16 e + g holds head dim 8 g + e: undo it in registers, then store
    # row-contiguous.
    accf = gl.reshape(gl.permute(gl.reshape(accf.to(gl.bfloat16), [GROUP, 8, 16]), [0, 2, 1]), [GROUP, HEAD])
    accf = gl.convert_layout(accf, blocked_query_layout)
    a_g = gl.arange(0, GROUP, layout=gl.SliceLayout(1, blocked_query_layout))
    a_d = gl.arange(0, HEAD, layout=gl.SliceLayout(0, blocked_query_layout))
    if ONE_SHOT:
        a_off = seq * stride_out_seq + a_g[:, None] * stride_out_group + a_d[None, :]
    else:
        a_off = (
            seq * stride_out_seq
            + split * stride_out_part
            + a_g[:, None] * stride_out_group
            + a_d[None, :]
        )
        gl.store(max_logits_ptr + ml_offsets, max_logits, mask=row_mask)
        gl.store(exp_sums_ptr + ml_offsets, exp_sums, mask=row_mask)
    a_mask = (a_g < query_group_size)[:, None]
    gl.store(output_ptr + a_off, accf, mask=a_mask)


@triton.jit
def _pa_decode_mxfp4_reduce_kernel(
    out_ptr,  # [num_seqs, G, D] bf16 (rows of the 3-D output view)
    max_logits_ptr,  # [num_seqs, splits, G] fp32
    exp_sums_ptr,  # [num_seqs, splits, G] fp32
    tmp_ptr,  # [num_seqs, splits, G, D] bf16
    stride_out_seq,
    stride_out_group,
    NSPLIT: tl.constexpr,
    NSPLIT_POW2: tl.constexpr,
    G: tl.constexpr,
    D: tl.constexpr,
):
    """Merge the per-split (max, sum, normalized partial output) of one
    (row, query head)."""
    s = tl.program_id(0).to(tl.int64)
    g = tl.program_id(1)
    sp = tl.arange(0, NSPLIT_POW2)
    d = tl.arange(0, D)
    valid = sp < NSPLIT
    ml_off = s * (NSPLIT * G) + sp * G + g
    m = tl.load(max_logits_ptr + ml_off, mask=valid, other=float("-inf"))
    e = tl.load(exp_sums_ptr + ml_off, mask=valid, other=0.0)
    m_all = tl.max(m, axis=0)
    m_all = tl.where(m_all == float("-inf"), 0.0, m_all)
    w = e * tl.exp(m - m_all)
    w_sum = tl.sum(w, axis=0)
    w = w / tl.where(w_sum > 0, w_sum, 1.0)
    o = tl.load(tmp_ptr + ml_off[:, None] * D + d[None, :], mask=valid[:, None], other=0.0)
    r = tl.sum(o.to(tl.float32) * w[:, None], axis=0)
    tl.store(out_ptr + s * stride_out_seq + g * stride_out_group + d, r.to(out_ptr.dtype.element_ty))


# ---------------------------------------------------------------------------
# Host launch path. Decode runs once per layer per step with persistent
# buffers, so the launcher keeps (a) the split partials in a per-device buffer
# grown on demand and (b) the resolved launches (compiled kernel + bound
# argument list) keyed by the tensors' pointers / shapes / strides, the
# scalars and the stream, and replays them without Triton's per-call argument
# binding. Shape checks run only when a launch is first resolved.
# ---------------------------------------------------------------------------
_PARTIALS: dict = {}
_LAUNCHES: dict = {}
_MAX_LAUNCHES = 4096
_SPLITS: dict = {}


def _partials(device, num_seqs, splits, group, head, dtype):
    n = num_seqs * splits * group
    key = (device, dtype)
    buf = _PARTIALS.get(key)
    if buf is None or buf[0].numel() < n:
        cap = max(n, 1 << 16)
        buf = (
            torch.empty(cap, dtype=torch.float32, device=device),
            torch.empty(cap, dtype=torch.float32, device=device),
            torch.empty(cap * head, dtype=dtype, device=device),
        )
        _PARTIALS[key] = buf
        _LAUNCHES.clear()  # cached launches point into the old buffers
    return (
        buf[0][:n].view(num_seqs, splits, group),
        buf[1][:n].view(num_seqs, splits, group),
        buf[2][: n * head].view(num_seqs, splits, group, head),
    )


def _resolve_launch(kernel, grid, args, kwargs, stream):
    """Launch ``kernel[grid](*args, **kwargs)`` once and return a closure that
    replays exactly that launch (same compiled kernel and bound values)."""
    compiled = kernel[grid](*args, **kwargs)
    try:
        device = triton.runtime.driver.active.get_current_device()
        binder = kernel.device_caches[device][4]
        bound_args, _, _ = binder(*args, **kwargs)
        values = tuple(bound_args.values())
        g = tuple(grid) + (1,) * (3 - len(grid))
        meta = compiled.launch_metadata(g, stream, *values)
        knobs = triton.knobs.runtime

        def replay():
            compiled.run(
                g[0], g[1], g[2], stream, compiled.function,
                compiled.packed_metadata, meta,
                knobs.launch_enter_hook, knobs.launch_exit_hook, *values,
            )

        return replay
    except Exception:  # noqa: BLE001 - Triton internals moved: plain JIT launch
        return lambda: kernel[grid](*args, **kwargs)


def _recommended_splits(device, num_seqs):
    key = (device, num_seqs)
    s = _SPLITS.get(key)
    if s is None:
        s = _SPLITS[key] = get_recommended_splits(num_seqs, 1)
    return s


def pa_decode_mxfp4_gluon(
    output: torch.Tensor,  # [rows, Hq, 128] bf16
    query: torch.Tensor,  # [rows, Hq, 128] bf16
    kv_cache: torch.Tensor,  # uint8 [num_blocks, 2H, 128, 68]
    context_lengths: torch.Tensor,  # int32 [rows * H]
    block_tables: torch.Tensor,  # int32 [rows * H, >= 128], page-16 entries
    softmax_scale: float,
    num_kv_heads: int,
    max_context_partition_num: int | None = None,
    num_warps: int = 4,
) -> torch.Tensor:
    """Sparse MXFP4 paged-attention decode; row ``r*H + h`` of ``block_tables``
    / ``context_lengths`` drives query row r, KV head h (heads h*G..h*G+G-1).
    ``max_context_partition_num`` (splits per row) defaults to AITER's
    recommendation; 1 writes ``output`` directly without a reduce."""
    stream = torch.cuda.current_stream(query.device).cuda_stream
    key = (
        output.data_ptr(), query.data_ptr(), query.shape[0], query.shape[1],
        kv_cache.data_ptr(), kv_cache.shape[0], kv_cache.stride(0),
        context_lengths.data_ptr(), block_tables.data_ptr(), block_tables.stride(0),
        float(softmax_scale), num_kv_heads, max_context_partition_num, num_warps, stream,
    )
    hit = _LAUNCHES.get(key)
    if hit is not None:
        for launch in hit:
            launch()
        return output

    rows, num_q_heads, head = query.shape
    H = num_kv_heads
    group = num_q_heads // H
    if head != HEAD_DIM or group != 16 or num_q_heads != H * group:
        raise ValueError("pa_decode_mxfp4_gluon: head_dim 128 and GQA group 16 only")
    if kv_cache.dtype != torch.uint8 or kv_cache[0].numel() != 2 * H * PAGE_BYTES:
        raise ValueError("MXFP4 K/V cache must be uint8 [blocks, 2H, 128, 68]")
    if kv_cache.stride(-1) != 1 or kv_cache[0].is_contiguous() is False:
        raise ValueError("MXFP4 K/V cache blocks must be contiguous")
    if not (query.is_contiguous() and output.is_contiguous()):
        raise ValueError("query and output must be contiguous")
    if block_tables.dtype != torch.int32 or block_tables.stride(1) != 1:
        raise ValueError("block_tables must be int32 with contiguous rows")
    if context_lengths.dtype != torch.int32:
        raise ValueError("context_lengths must be int32")
    num_seqs = rows * H
    if num_seqs == 0:
        return output
    q_view = query.view(num_seqs, group, head)
    out_view = output.view(num_seqs, group, head)
    splits = max_context_partition_num or _recommended_splits(query.device, num_seqs)
    one_shot = splits <= 1
    if one_shot:
        exp_sums = max_logits = out_k = out_view  # exp/max unused
        so_seq, so_part, so_group = out_view.stride(0), 0, out_view.stride(1)
        ml_seq = ml_part = 0
    else:
        max_logits, exp_sums, out_k = _partials(
            query.device, num_seqs, splits, group, head, query.dtype
        )
        so_seq, so_part, so_group = out_k.stride(0), out_k.stride(1), out_k.stride(2)
        ml_seq, ml_part = exp_sums.stride(0), exp_sums.stride(1)
    launches = [
        _resolve_launch(
            pa_decode_mxfp4_kernel,
            (num_seqs, 1, splits),
            (
                exp_sums, max_logits, out_k, q_view, kv_cache,
                kv_cache.view(torch.int32), block_tables, context_lengths,
                float(softmax_scale), ml_seq, ml_part, so_seq, so_part, so_group,
                q_view.stride(0), q_view.stride(1), kv_cache.stride(0),
                block_tables.stride(0), group,
            ),
            dict(
                NUM_KV_HEADS=H, CDNA_VERSION=get_cdna_version(), ONE_SHOT=one_shot,
                NUM_WARPS=num_warps, num_warps=num_warps,
            ),
            stream,
        )
    ]
    if not one_shot:
        launches.append(
            _resolve_launch(
                _pa_decode_mxfp4_reduce_kernel,
                (num_seqs, group),
                (out_view, max_logits, exp_sums, out_k, out_view.stride(0), out_view.stride(1)),
                dict(
                    NSPLIT=splits, NSPLIT_POW2=triton.next_power_of_2(splits),
                    G=group, D=head, num_warps=1,
                ),
                stream,
            )
        )
    if len(_LAUNCHES) >= _MAX_LAUNCHES:
        _LAUNCHES.clear()
    _LAUNCHES[key] = tuple(launches)
    return output
