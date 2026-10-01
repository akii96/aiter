"""Round-6 microbenchmarks (gfx950): the MALL for a reused dirty buffer, and FC-style row gathers.

  mall   : write (normal stores) then read the same S-byte buffer, back to back, for S = 32 MB .. 2 GB.
           If the 256 MB MALL keeps a reused buffer's dirty lines resident, the write + read pair runs
           above the HBM rate for S <= ~192 MB (the S2-W windowed-rows premise).
  gather : routed-row gather like the FC epilogue: rows of H*2 = 12 KB at random positions in a
           1.5 GB buffer, P-byte pieces (P = 512 / 1024 / 2048, at a P-aligned column offset), N loads
           in flight per lane, into VGPRs or by async DMA into LDS.

usage: python bench/micro_r6.py mall | gather
"""
import os
import sys

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, HERE)

import flydsl.compiler as flyc  # noqa: E402
import flydsl.expr as fx  # noqa: E402
from flydsl.expr import const_expr, gpu, range_constexpr, rocdl  # noqa: E402
from flydsl.expr.typing import T  # noqa: E402

from flymoe import hw  # noqa: E402
from hbm_bw import build_stream, timeit  # noqa: E402

ROW = 6144 * 2
ITERS = 32


def build_gather(piece, inflight, dma):
    lpr = piece // 16  # lanes per row piece

    @fx.struct
    class S:
        raw: fx.Array[fx.Uint8, 2 * 16 * 4096, 16]

    @flyc.kernel(name=f"micro6_gather_{piece}_{inflight}_{int(dma)}", known_block_size=[256, 1, 1])
    def k(src: fx.Int64, out: fx.Int64, nrows: fx.Int32):
        tid = fx.Int32(gpu.thread_id("x"))
        bid = fx.Int32(gpu.block_id("x"))
        wave = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tid // 64)))
        base = fx.Int32(fx.ptrtoint(fx.SharedAllocator().allocate(S).peek().raw.ptr))
        acc = fx.Int32(0)
        for it in range(ITERS):
            vals = []
            for j in range_constexpr(inflight):
                h = ((bid * 977 + it * 131 + j * 29) * (256 // lpr) + tid // lpr) * 2654435761
                row = (h >> 5) % nrows
                col = ((h >> 3) % (ROW // piece)) * piece
                voff = fx.Int64(row) * fx.Int64(ROW) + fx.Int64(col + (tid % lpr) * 16)
                if const_expr(dma):
                    hw.dma_async(hw.rsrc(src), base, wave * 1024 + ((it % 2) * inflight + j) * 4096,
                                 fx.Int32(voff))
                else:
                    vals.append(hw.gload(fx.Int64(src) + voff, T.i32x4))
            if const_expr(dma):
                rocdl.asyncmark()
                rocdl.wait_asyncmark(1)
            else:
                for v in vals:
                    acc = acc ^ fx.Int32(fx.Vector(v)[0])
        if const_expr(dma):
            rocdl.wait_asyncmark(0)
            acc = fx.Int32(hw.lds_load(base, tid * 4, T.i32, align=4))
        hw.bstore(acc, hw.rsrc(out), (bid * 256 + tid) * 4)

    @flyc.jit
    def launch(src: fx.Int64, out: fx.Int64, nrows: fx.Int32, grid: fx.Int32, stream: fx.Stream = fx.Stream(None)):
        k(src, out, nrows).launch(grid=(grid, 1, 1), block=(256, 1, 1), stream=stream)

    return launch


def main():
    what = sys.argv[1] if len(sys.argv) > 1 else "mall"
    st = torch.cuda.current_stream()
    if what == "mall":
        big = 2 << 30
        buf = torch.empty(big // 4, dtype=torch.int32, device="cuda")
        fw, CH = build_stream("write")
        fr, _ = build_stream("read")
        sink = torch.empty(1024, dtype=torch.int32, device="cuda")
        grid = 256 * 8
        n0 = (32 << 20) // CH
        cw = flyc.compile(fw, buf.data_ptr(), buf.data_ptr(), n0, grid, st)
        cr = flyc.compile(fr, buf.data_ptr(), sink.data_ptr(), n0, grid, st)
        for mb in (32, 64, 96, 128, 160, 192, 256, 512, 2048):
            n = (mb << 20) // CH

            def pair():
                cw(buf.data_ptr(), buf.data_ptr(), n, grid, st)
                cr(buf.data_ptr(), sink.data_ptr(), n, grid, st)

            us = timeit(pair, reps=20)
            wus = timeit(lambda: cw(buf.data_ptr(), buf.data_ptr(), n, grid, st), reps=20)
            rus = timeit(lambda: cr(buf.data_ptr(), sink.data_ptr(), n, grid, st), reps=20)
            b = n * CH
            print(f"mall {mb:5d} MB: write+read {2 * b / us / 1e6:6.2f} TB/s | write alone (rewritten) "
                  f"{b / wus / 1e6:6.2f} | read alone {b / rus / 1e6:6.2f} TB/s", flush=True)
    else:
        nb = 1536 << 20
        src = torch.empty(nb // 4, dtype=torch.int32, device="cuda")
        nrows = nb // ROW
        for piece in (512, 1024, 2048):
            for inflight in (4, 8, 16):
                for dma in (False, True):
                    if dma and inflight > 8:
                        continue
                    for cpc in (2, 4):
                        grid = 256 * cpc
                        out = torch.empty(grid * 256, dtype=torch.int32, device="cuda")
                        f = flyc.compile(build_gather(piece, inflight, dma), src.data_ptr(), out.data_ptr(),
                                         nrows, grid, st)
                        us = timeit(lambda: f(src.data_ptr(), out.data_ptr(), nrows, grid, st))
                        b = grid * 256 * ITERS * inflight * 16
                        print(f"gather piece={piece:4d} inflight={inflight:2d} {'dma ' if dma else 'vgpr'} "
                              f"ctas/CU={cpc}: {b / us / 1e6:6.2f} TB/s", flush=True)


if __name__ == "__main__":
    main()
