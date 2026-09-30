"""Round-5 microbenchmarks (gfx950), clock-independent (bytes or ops per ns per CU).

  lds   : ds_read_b128 throughput per CU vs waves per CU (1 CTA per CU), conflict-free
          (lane*16) and the stage-1 operand pattern (16 rows x 64 B, xor-swizzled chunks),
          optionally with concurrent async LDS DMA traffic from the same waves.
  mfma  : 16x16x128 fp4 MFMA rate per SIMD for 1 and 2 waves/SIMD, with and without
          ds_read_b128 interleaved from the same wave (does the LDS pipe overlap MFMA?).

usage: python bench/micro_r5.py lds | mfma
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

NCU = 256
UNROLL = 16
INNER = 32
IMM = os.environ.get("MICRO_IMM", "1") == "1"


def build_lds(nw, pattern, dma, iters):
    @fx.struct
    class S:
        raw: fx.Array[fx.Uint8, 128 * 1024, 16]

    th = nw * 64

    @flyc.kernel(name=f"micro_lds_{nw}_{pattern}_{int(dma)}_{iters}", known_block_size=[th, 1, 1])
    def k(src: fx.Int64, out: fx.Int64):
        tid = fx.Int32(gpu.thread_id("x"))
        bid = fx.Int32(gpu.block_id("x"))
        lane = tid % 64
        wave = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tid // 64)))
        base = fx.Int32(fx.ptrtoint(fx.SharedAllocator().allocate(S).peek().raw.ptr))
        rs = hw.rsrc(src)
        if const_expr(pattern == "lin"):
            inner = lane * 16
        else:
            # stage-1 A operand read: lane l -> row (l % 16), 16 B chunk (l // 16) of a 64 B row,
            # chunk xor-swizzled by (row >> 1) & 3; 16 rows per 1 KB block
            row = lane % 16
            inner = row * 64 + ((lane // 16) ^ ((row >> 1) & 3)) * 16
        acc = fx.Int32(0)
        for it in range(iters):
            blk0 = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw((wave * 5 + it * 3) % 64)))
            for u in range_constexpr(UNROLL):
                if const_expr(dma > 0 and u % (UNROLL // dma) == 0):
                    hw.dma_async(rs, base, 64 * 1024 + (wave % 8) * 4096 + (u // (UNROLL // dma)) % 4 * 1024,
                                 ((bid * 64 + lane) * 16 + u * 4096 + it * 65536) % (4 << 20))
                v = hw.lds_load(base, ((blk0 + u * 4) % 64) * 1024 + inner, T.i32x4)
                acc = acc ^ fx.Int32(fx.Vector(v)[u % 4])
            if const_expr(dma > 0):
                rocdl.asyncmark()
                rocdl.wait_asyncmark(1)
        if const_expr(dma > 0):
            rocdl.wait_asyncmark(0)
        hw.bstore(acc, hw.rsrc(out), (bid * th + tid) * 4)

    @flyc.jit
    def launch(src: fx.Int64, out: fx.Int64, stream: fx.Stream = fx.Stream(None)):
        k(src, out).launch(grid=(NCU, 1, 1), block=(th, 1, 1), stream=stream)

    return launch


def build_mfma(nw, lds_per_mfma, iters):
    @fx.struct
    class S:
        raw: fx.Array[fx.Uint8, 96 * 1024, 16]

    th = nw * 64

    @flyc.kernel(name=f"micro_mfma_{nw}_{lds_per_mfma}_{iters}_{int(IMM)}", known_block_size=[th, 1, 1])
    def k(out: fx.Int64):
        tid = fx.Int32(gpu.thread_id("x"))
        bid = fx.Int32(gpu.block_id("x"))
        lane = tid % 64
        wave = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tid // 64)))
        base = fx.Int32(fx.ptrtoint(fx.SharedAllocator().allocate(S).peek().raw.ptr))
        a = fx.Vector.filled(4, 0, fx.Int32)
        acc = [fx.Vector.filled(4, 0.0, fx.Float32) for _ in range(8)]
        chk = fx.Int32(0)
        every = max(1, int(round(1 / lds_per_mfma))) if lds_per_mfma > 0 else 0
        for it in range(iters // INNER):
            got = []
            opv = a
            vb = ((wave * 5 + it * 7) % 16) * 1024 + lane * 16
            for u in range_constexpr(16 * INNER):
                j = u % 8
                if const_expr(every > 0 and u % max(every, 1) == 0):
                    # the MFMAs use the operand loaded two loads ago (latency hidden behind 2*every MFMAs)
                    if const_expr(len(got) >= 2):
                        opv = got[-2]
                    if const_expr(IMM):
                        v = hw.lds_load(base + vb, (u // every) % 48 * 1024, T.i32x4)
                    else:
                        v = hw.lds_load(base, ((wave * 5 + it * 7 + u) % 64) * 1024 + lane * 16, T.i32x4)
                    got.append(fx.Vector(v))
                    rocdl.sched_barrier(0)
                acc[j] = fx.Vector(hw.mfma_fp4(hw.raw(acc[j]), hw.raw(opv), hw.raw(a), 127, 127))
                rocdl.sched_barrier(0)
            for g in got[-2:]:
                chk = chk ^ fx.Int32(g[0])
        s = fx.Float32(chk)
        for j in range_constexpr(8):
            s = s + fx.Float32(acc[j][0])
        hw.bstore(s, hw.rsrc(out), (bid * th + tid) * 4)

    @flyc.jit
    def launch(out: fx.Int64, stream: fx.Stream = fx.Stream(None)):
        k(out).launch(grid=(NCU, 1, 1), block=(th, 1, 1), stream=stream)

    return launch


def timeit(f, n=5):
    f()
    torch.cuda.synchronize()
    s, e = torch.cuda.Event(enable_timing=True), torch.cuda.Event(enable_timing=True)
    s.record()
    for _ in range(n):
        f()
    e.record()
    torch.cuda.synchronize()
    return s.elapsed_time(e) / n * 1e3  # us


def main():
    what = sys.argv[1] if len(sys.argv) > 1 else "lds"
    st = torch.cuda.current_stream()
    if what == "lds":
        iters = 2048
        src = torch.randint(0, 255, (64 << 20,), dtype=torch.uint8, device="cuda")
        for pattern in ("lin", "s1a"):
            for dma in (0, 1, 4):
                for nw in (1, 2, 4, 8, 16):
                    out = torch.empty(NCU * nw * 64, dtype=torch.int32, device="cuda")
                    f = flyc.compile(build_lds(nw, pattern, dma, iters), src.data_ptr(), out.data_ptr(), st)
                    us = timeit(lambda: f(src.data_ptr(), out.data_ptr(), st))
                    rd = NCU * nw * iters * UNROLL * 1024
                    print(f"lds {pattern:3s} dma={int(dma)} waves/CU={nw:2d}: {rd / us / 1e3 / NCU:7.1f} B/ns/CU read "
                          f"({us:8.1f} us)", flush=True)
    else:
        iters = 4096
        for nw in (4, 8):
            for lpm in (0, 0.125, 0.25, 0.34, 0.5, 1):
                out = torch.empty(NCU * nw * 64, dtype=torch.float32, device="cuda")
                f = flyc.compile(build_mfma(nw, lpm, iters), out.data_ptr(), st)
                us = timeit(lambda: f(out.data_ptr(), st))
                n_mfma = NCU * nw * iters * 16
                flops = n_mfma * 16 * 16 * 128 * 2
                print(f"mfma waves/CU={nw} lds_reads/mfma={lpm:4.2f}: {flops / us / 1e9:6.2f} PF "
                      f"({n_mfma / us / 1e3 / NCU / 4:6.2f} MFMA/ns/SIMD)", flush=True)


if __name__ == "__main__":
    main()
