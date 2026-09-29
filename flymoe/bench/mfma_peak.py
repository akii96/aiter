"""Measured fp4 scaled-MFMA throughput under controlled conditions.

Varies: atom (16x16x128 / 32x32x64), independent accumulator chains per wave,
resident waves per SIMD (via grid = CUs * ctas_per_cu, 4 waves/CTA), and
whether the scale operands vary (per-chain VGPR scale + opsel) like stage 1.
"""

import os
import sys

import torch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import flydsl.compiler as flyc
import flydsl.expr as fx
from flydsl.expr import const_expr, gpu, range_constexpr, rocdl
from flydsl.expr.typing import T

from flymoe import hw

TOTAL_PER_WAVE = 1536  # same MFMA count per wave as one stage-1 tile at K=6144, BM=128


def build(atom, chains, vary_scale):
    iters = TOTAL_PER_WAVE // chains
    nacc = 4 if atom == 16 else 16

    @flyc.kernel(name=f"mfma_peak_{atom}_c{chains}_v{int(vary_scale)}", known_block_size=[256, 1, 1])
    def k(a_ptr: fx.Int64, o_ptr: fx.Int64):
        acc_ty = T.f32x4 if atom == 16 else T.vec(16, T.f32)
        tid = fx.Int32(gpu.thread_id("x"))
        ra = hw.rsrc(a_ptr)
        a = hw.bload(ra, (tid % 64) * 16, T.i32x4)
        b = hw.bload(ra, (tid % 64) * 16 + 1024, T.i32x4)
        sa = [fx.Int32(hw.bload(ra, (tid % 64) * 4 + 2048 + r * 256, T.i32)) for r in range(8)]
        accs = [hw.raw(fx.Vector.filled(nacc, float(c + 1), fx.Float32)) for c in range(chains)]
        fn = rocdl.mfma_scale_f32_16x16x128_f8f6f4 if atom == 16 else rocdl.mfma_scale_f32_32x32x64_f8f6f4
        for i in range_constexpr(iters):
            for c in range_constexpr(chains):
                if const_expr(vary_scale):
                    s_a, s_b, ob = hw.raw(sa[c % 8]), hw.raw(sa[(c // 8) % 8]), c % 4
                else:
                    s_a, s_b, ob = hw.raw(fx.Int32(127)), hw.raw(fx.Int32(127)), 0
                accs[c] = fn(acc_ty, [a, b, accs[c], 4, 4, 0, s_a, ob, s_b])
        s = fx.Float32(fx.Vector(accs[0])[0])
        for c in range_constexpr(1, chains):
            s = s + fx.Float32(fx.Vector(accs[c])[0])
        hw.bstore(s, hw.rsrc(o_ptr), (fx.Int32(gpu.block_id("x")) * 256 + tid) * 4)

    @flyc.jit
    def launch(a_ptr: fx.Int64, o_ptr: fx.Int64, grid: fx.Int32, stream: fx.Stream = fx.Stream(None)):
        k(a_ptr, o_ptr).launch(grid=(grid, 1, 1), block=(256, 1, 1), stream=stream)

    return launch


def run(atom, chains, vary, ctas_per_cu, waves=16):
    a = torch.randint(100, 140, (8192,), dtype=torch.uint8, device="cuda")
    grid = 256 * ctas_per_cu * waves
    o = torch.empty(grid * 256, dtype=torch.float32, device="cuda")
    st = torch.cuda.current_stream()
    f = flyc.compile(build(atom, chains, vary), a.data_ptr(), o.data_ptr(), grid, st)
    torch.cuda.synchronize()
    s, e = torch.cuda.Event(enable_timing=True), torch.cuda.Event(enable_timing=True)
    s.record()
    for _ in range(3):
        f(a.data_ptr(), o.data_ptr(), grid, st)
    e.record()
    torch.cuda.synchronize()
    t = s.elapsed_time(e) / 3 / 1e3
    flop_per = 2 * 16 * 16 * 128 if atom == 16 else 2 * 32 * 32 * 64
    flops = grid * 4 * TOTAL_PER_WAVE * flop_per
    print(f"atom {atom} chains {chains:2d} vary_scale {int(vary)} ctas/CU-wave {ctas_per_cu}: "
          f"{flops / t / 1e15:.2f} PFLOPS", flush=True)


if __name__ == "__main__":
    for atom, chains, vary, cpc in [
        (16, 8, False, 2), (16, 32, False, 1), (16, 32, True, 1), (16, 32, True, 2),
        (16, 8, True, 1), (32, 8, False, 1), (32, 8, True, 1), (32, 16, True, 1),
    ]:
        run(atom, chains, vary, cpc)
