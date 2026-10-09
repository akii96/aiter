"""Probe: one v_mfma_scale_f32_16x16x128_f8f6f4 (fp4 x fp4) vs torch.

Confirms operand lane layout, scale byte selection (opsel) and output layout.
"""

import os
import sys

import torch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import flydsl.compiler as flyc
import flydsl.expr as fx
from flydsl.expr import gpu
from flydsl.expr.typing import T

from flymoe import hw, mx


def build(opsel_a, opsel_b):
    @flyc.kernel(name=f"probe_mfma_{opsel_a}{opsel_b}", known_block_size=[64, 1, 1])
    def k(a_ptr: fx.Int64, b_ptr: fx.Int64, sa_ptr: fx.Int64, sb_ptr: fx.Int64, o_ptr: fx.Int64):
        lane = fx.Int32(gpu.thread_id("x"))
        ra, rb, rsa, rsb, ro = (hw.rsrc(p) for p in (a_ptr, b_ptr, sa_ptr, sb_ptr, o_ptr))
        a = hw.bload(ra, lane * 16, T.i32x4)
        b = hw.bload(rb, lane * 16, T.i32x4)
        sa = hw.bload(rsa, lane * 4, T.i32)
        sb = hw.bload(rsb, lane * 4, T.i32)
        zero = fx.Vector.filled(4, 0.0, fx.Float32)
        acc = hw.mfma_fp4(hw.raw(zero), a, b, sa, sb, opsel_a, opsel_b)
        hw.bstore(acc, ro, lane * 16)

    @flyc.jit
    def launch(a_ptr: fx.Int64, b_ptr: fx.Int64, sa_ptr: fx.Int64, sb_ptr: fx.Int64, o_ptr: fx.Int64,
               stream: fx.Stream = fx.Stream(None)):
        k(a_ptr, b_ptr, sa_ptr, sb_ptr, o_ptr).launch(grid=(1, 1, 1), block=(64, 1, 1), stream=stream)

    return launch


def lanes_from_rows(packed_rows):
    """[16, 64B] -> [64 lanes, 16B]: lane l = row l%16, K bytes (l//16)*16.."""
    return packed_rows.view(16, 4, 16).permute(1, 0, 2).reshape(64, 16).contiguous()


def main():
    dev = "cuda"
    g = torch.Generator(device=dev).manual_seed(0)
    A, SA = mx.random_fp4((16, 128), dev, g)
    B, SB = mx.random_fp4((16, 128), dev, g)
    ref = mx.dequant(A, SA) @ mx.dequant(B, SB).T
    for opsel_a, opsel_b in [(0, 0), (1, 2), (3, 3)]:
        a_l = lanes_from_rows(A)
        b_l = lanes_from_rows(B)
        # lane l scale for (row l%16, group l//16) placed in byte `opsel`
        sa_b = SA.T.reshape(64)  # index g*16 + r
        sb_b = SB.T.reshape(64)
        sa_w = torch.full((64, 4), 0x55, dtype=torch.uint8, device=dev)
        sb_w = torch.full((64, 4), 0x55, dtype=torch.uint8, device=dev)
        sa_w[:, opsel_a] = sa_b
        sb_w[:, opsel_b] = sb_b
        out = torch.zeros(64, 4, dtype=torch.float32, device=dev)
        launch = build(opsel_a, opsel_b)
        flyc.compile(launch, a_l.data_ptr(), b_l.data_ptr(), sa_w.data_ptr(), sb_w.data_ptr(),
                     out.data_ptr(), torch.cuda.current_stream())
        torch.cuda.synchronize()
        # lane l, v -> row (l//16)*4 + v, col l%16
        C = torch.empty(16, 16, device=dev)
        for l in range(64):
            for v in range(4):
                C[(l // 16) * 4 + v, l % 16] = out[l, v]
        err = (C - ref).abs().max().item()
        print(f"opsel=({opsel_a},{opsel_b}) max_abs_err={err:.3e} ref_absmax={ref.abs().max().item():.3e}")
        assert err <= 1e-3 * ref.abs().max().item(), "MFMA layout mismatch"
    print("PROBE OK")


if __name__ == "__main__":
    main()
