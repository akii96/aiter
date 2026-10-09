# SPDX-License-Identifier: MIT
# Copyright (C) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""Weight / scale packing into the MFMA-native layout. No padding at any width.

B operand of v_mfma_scale_f32_16x16x128_f8f6f4 (fp4): lane l supplies column
(l % 16) and K elements [(l // 16) * 32, +32) of a 128-wide K step, i.e. 16
contiguous bytes. One (16-column, 128-K) atom is therefore 1024 contiguous
bytes and a wave loads it with a single 16 B/lane load.

    packed B       : [E][N/16][K/128][64 lanes][16 B]
    packed B scale : [E][K/128][N/64][64 lanes][4 B] (stage 1) or [E][N/64][K/128][64][4 B] (stage 2)
                                                        byte j -> n16 tile 4*n64+j,
                                                       lane l -> (col l%16, group l//16)

Requires N % 64 == 0 and K % 128 == 0, which holds for every MiniMax-M3 width
(I = 384 / 768 / 1536, H = 6144): nothing is padded.

Stage-1 column order. W13 = [gate; up] (each I rows). Packed row
p = g*64 + q*16 + c (g = 32-column quant group, c = 0..15) holds
    q=0: gate[32g+2c]  q=1: gate[32g+2c+1]  q=2: up[32g+2c]  q=3: up[32g+2c+1]
so a wave owning one 64-column block holds, per lane, the gate and up values of
two adjacent intermediate columns: SwiGLU + fp4 packing happen in registers.
"""

import torch


def stage1_row_perm(inter: int, device=None) -> torch.Tensor:
    """Index into [gate; up] (2I rows) for each packed stage-1 row."""
    g = torch.arange(inter // 32, device=device).view(-1, 1, 1)
    q = torch.arange(4, device=device).view(1, -1, 1)
    c = torch.arange(16, device=device).view(1, 1, -1)
    col = 32 * g + 2 * c + (q % 2)
    src = col + inter * (q // 2)
    return src.reshape(-1)


def pack_b(w: torch.Tensor, s: torch.Tensor, bs_step_major: bool = False):
    """w [E, N, K/2] uint8 (fp4x2), s [E, N, K/32] uint8 -> (packed_b, packed_bs)."""
    E, N, KH = w.shape
    K = KH * 2
    assert N % 64 == 0 and K % 128 == 0, (N, K)
    b = (
        w.view(E, N // 16, 16, K // 128, 4, 16)
        .permute(0, 1, 3, 4, 2, 5)
        .contiguous()
        .view(E, N // 16, K // 128, 1024)
    )
    if bs_step_major:
        # K-step-major: a CTA's consecutive 64-column blocks for one step are contiguous
        # (4 blocks = one 1 KB DMA). Used for stage 1 (DMA'd into LDS by the ping-pong tile).
        bs = (
            s.view(E, N // 64, 4, 16, K // 128, 4)
            .permute(0, 4, 1, 5, 3, 2)
            .contiguous()
            .view(E, K // 128, N // 64, 256)
        )
    else:
        # Column-block-major: one 64-column block's scales are contiguous over K (better
        # for pipes that load B scales per lane from global memory every step).
        bs = (
            s.view(E, N // 64, 4, 16, K // 128, 4)
            .permute(0, 1, 4, 5, 3, 2)
            .contiguous()
            .view(E, N // 64, K // 128, 256)
        )
    return b, bs


def pack_w13(w_gate, s_gate, w_up, s_up):
    """gate/up [E, I, H/2] + scales [E, I, H/32] -> packed stage-1 B (N = 2I)."""
    inter = w_gate.shape[1]
    w = torch.cat([w_gate, w_up], dim=1)
    s = torch.cat([s_gate, s_up], dim=1)
    perm = stage1_row_perm(inter, w.device)
    return pack_b(w[:, perm].contiguous(), s[:, perm].contiguous(), bs_step_major=True)


def stage2_row_perm(hidden: int, device=None) -> torch.Tensor:
    """Packed row p = g*32 + q*16 + c holds output column 32g + 2c + q, so each lane
    of an MFMA tile pair holds two adjacent output columns (packed bf16x2 stores)."""
    g = torch.arange(hidden // 32, device=device).view(-1, 1, 1)
    q = torch.arange(2, device=device).view(1, -1, 1)
    c = torch.arange(16, device=device).view(1, 1, -1)
    return (32 * g + 2 * c + q).reshape(-1)


def pack_w2(w_down, s_down):
    """down [E, H, I/2] + scales [E, H, I/32] -> packed stage-2 B (N = H, K = I)."""
    perm = stage2_row_perm(w_down.shape[1], w_down.device)
    return pack_b(w_down[:, perm].contiguous(), s_down[:, perm].contiguous())
