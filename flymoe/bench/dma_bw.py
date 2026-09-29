"""Global -> CU data-path throughput on this GPU, three ways, from an L2-resident source.

  dma  : buffer_load_dwordx4 ... lds (async LDS DMA), 16 B/lane
  vgpr : buffer_load_dwordx4 into VGPRs (value folded into a checksum)
  vlds : buffer_load_dwordx4 into VGPRs, then ds_write_b128 into LDS

Each CTA (256 threads) repeatedly streams a per-XCD-slice of a buffer small
enough to stay in L2 (default 2 MB per XCD). Reports TB/s aggregate and B/clk/CU.
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

ITERS = 64
INFLIGHT = 8  # 16 B loads in flight per thread per iteration


def build(mode, slice_bytes):
    @fx.struct
    class S:
        raw: fx.Array[fx.Uint8, INFLIGHT * 4096 * 2, 16]

    @flyc.kernel(name=f"dma_bw_{mode}_{slice_bytes}", known_block_size=[256, 1, 1])
    def k(src: fx.Int64, out: fx.Int64):
        tid = fx.Int32(gpu.thread_id("x"))
        bid = fx.Int32(gpu.block_id("x"))
        lane = tid % 64
        wave = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tid // 64)))
        rs = hw.rsrc(src)
        base = fx.Int32(fx.ptrtoint(fx.SharedAllocator().allocate(S).peek().raw.ptr))
        xcd = bid % 8
        acc = fx.Int32(0)
        chunk = 256 * 16 * INFLIGHT
        nchunk = slice_bytes // chunk
        for it in range_constexpr(ITERS):
            c = (bid // 8 + it) % nchunk
            off0 = xcd * slice_bytes + c * chunk
            for j in range_constexpr(INFLIGHT):
                if const_expr(mode == "g128dma"):
                    # 8 rows x 128 B per instruction (2 K-steps of A): 8 lanes x 16 B per row
                    rowid = ((bid * 131 + it * 17 + j * 7) * 64 + tid // 8) * 2654435761
                    row = (rowid >> 7) % (slice_bytes // 3072 - 1)
                    voff = xcd * slice_bytes + row * 3072 + (tid % 8) * 16
                elif const_expr(mode.startswith("g")):
                    # gathered rows like the stage-1 A tile: 4 lanes x 16 B per 3 KB-strided row,
                    # rows spread pseudo-randomly over the slice.
                    rowid = ((bid * 131 + it * 17 + j * 7) * 64 + tid // 4) * 2654435761
                    row = (rowid >> 7) % (slice_bytes // 3072 - 1)
                    voff = xcd * slice_bytes + row * 3072 + (tid % 4) * 16
                else:
                    voff = off0 + (j * 256 + tid) * 16
                if const_expr(mode in ("dma", "gdma", "g128dma")):
                    hw.dma_async(rs, base, wave * 1024 + ((it % 2) * INFLIGHT + j) * 4096, voff)
                else:
                    v = hw.bload(rs, voff, T.i32x4)
                    if const_expr(mode == "vlds"):
                        hw.lds_store(v, base, tid * 16 + ((it % 2) * INFLIGHT + j) * 4096)
                    else:
                        acc = acc ^ fx.Int32(fx.Vector(v)[0])
            if const_expr(mode in ("dma", "gdma", "g128dma")):
                rocdl.asyncmark()
                rocdl.wait_asyncmark(1)
        if const_expr(mode in ("dma", "gdma", "g128dma")):
            rocdl.wait_asyncmark(0)
            acc = fx.Int32(hw.lds_load(base, tid * 4, T.i32, align=4))
        elif const_expr(mode == "vlds"):
            gpu.barrier()
            acc = fx.Int32(hw.lds_load(base, tid * 4, T.i32, align=4))
        hw.bstore(acc, hw.rsrc(out), (bid * 256 + tid) * 4)

    @flyc.jit
    def launch(src: fx.Int64, out: fx.Int64, grid: fx.Int32, stream: fx.Stream = fx.Stream(None)):
        k(src, out).launch(grid=(grid, 1, 1), block=(256, 1, 1), stream=stream)

    return launch


def main():
    slice_bytes = 2 * 1024 * 1024
    src = torch.randint(0, 255, (8 * slice_bytes,), dtype=torch.uint8, device="cuda")
    for mode in ("dma", "gdma", "g128dma"):
        for ctas_per_cu in (1, 2):
            grid = 256 * ctas_per_cu * 4
            out = torch.empty(grid * 256, dtype=torch.int32, device="cuda")
            st = torch.cuda.current_stream()
            f = flyc.compile(build(mode, slice_bytes), src.data_ptr(), out.data_ptr(), grid, st)
            torch.cuda.synchronize()
            s, e = torch.cuda.Event(enable_timing=True), torch.cuda.Event(enable_timing=True)
            s.record()
            for _ in range(5):
                f(src.data_ptr(), out.data_ptr(), grid, st)
            e.record()
            torch.cuda.synchronize()
            t = s.elapsed_time(e) / 5 / 1e3
            nbytes = grid * ITERS * INFLIGHT * 256 * 16
            tbs = nbytes / t / 1e12
            print(f"{mode:5s} ctas/CU~{ctas_per_cu}: {tbs:6.2f} TB/s aggregate, "
                  f"{nbytes / t / 256 / 2.1e9:6.1f} B/clk/CU (at 2.1 GHz)", flush=True)


if __name__ == "__main__":
    main()
