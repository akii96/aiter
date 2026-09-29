"""K0: routing plan + activation quantization, both FlyDSL, no host sync.

plan  : one CTA counting sort of topk_ids into the compact expert-sorted row
        array (exactly T*k rows), plus BM tile lists and the inverse map used by
        the combine. Row order inside an expert is arbitrary; results are not
        affected because every row is computed independently and the combine
        sums a token's slots in fixed slot order.
quant : x bf16 [T, H] -> MX fp4 [T, H/2] + e8m0 [T, H/32], one thread per 32-group.
        Same scale rule as mx.quant (ceil_pow2(amax/6)), hardware RNE convert.
"""

import functools

import flydsl.compiler as flyc
import flydsl.expr as fx
from flydsl._mlir.dialects import llvm
from flydsl.expr import const_expr, gpu, range_constexpr, rocdl
from flydsl.expr import math as fmath
from flydsl.expr.typing import T

from . import hw

PLAN_THREADS = 1024


def _lds_atomic_add(base_i32, byte_off, val):
    ptr = hw.lds_llvm_ptr(base_i32, byte_off)
    return llvm.AtomicRMWOp(
        llvm.AtomicBinOp.add, ptr, hw.raw(fx.Int32(val)), llvm.AtomicOrdering.monotonic
    ).result


@functools.lru_cache(maxsize=None)
def build_plan(E: int, k: int, bms: tuple):
    NBM = len(bms)
    # LDS: counts[E], cursor[E], offs[E], tile_off[NBM][E]
    lds_words = 3 * E + NBM * E
    lds_bytes = ((lds_words * 4 + 15) // 16) * 16

    @fx.struct
    class SharedStorage:
        raw: fx.Array[fx.Uint8, lds_bytes, 16]

    @flyc.kernel(name=f"flymoe_plan_e{E}_k{k}_bm{'_'.join(map(str, bms))}",
                 known_block_size=[PLAN_THREADS, 1, 1])
    def kern(ids_ptr: fx.Int64, w_ptr: fx.Int64, rtok_ptr: fx.Int64, rw_ptr: fx.Int64,
             inv_ptr: fx.Int64, tiles_ptr: fx.Int64, ntiles_ptr: fx.Int64, n_rows: fx.Int32,
             max_tiles0: fx.Int32):
        tid = fx.Int32(gpu.thread_id("x"))
        base = fx.Int32(fx.ptrtoint(fx.SharedAllocator().allocate(SharedStorage).peek().raw.ptr))
        C_OFF, CUR_OFF, OFFS_OFF, TOFF_OFF = 0, E * 4, 2 * E * 4, 3 * E * 4
        r_ids = hw.rsrc(ids_ptr, fx.Int64(n_rows) * fx.Int64(4))
        r_w = hw.rsrc(w_ptr, fx.Int64(n_rows) * fx.Int64(4))
        r_rt = hw.rsrc(rtok_ptr, fx.Int64(n_rows) * fx.Int64(4))
        r_rw = hw.rsrc(rw_ptr, fx.Int64(n_rows) * fx.Int64(4))
        r_inv = hw.rsrc(inv_ptr, fx.Int64(n_rows) * fx.Int64(4))
        r_tiles = hw.rsrc(tiles_ptr)
        r_nt = hw.rsrc(ntiles_ptr)

        if tid < fx.Int32(E):
            hw.lds_store(fx.Int32(0), base, C_OFF + tid * 4, align=4)
            hw.lds_store(fx.Int32(0), base, CUR_OFF + tid * 4, align=4)
        gpu.barrier()
        for i in range(tid, n_rows, PLAN_THREADS):
            e = fx.Int32(hw.bload(r_ids, fx.Int32(i) * 4, T.i32))
            _lds_atomic_add(base, C_OFF + e * 4, 1)
        gpu.barrier()
        if tid == fx.Int32(0):
            run = fx.Int32(0)
            runs = [fx.Int32(0)] * NBM
            for e in range_constexpr(E):
                c = fx.Int32(hw.lds_load(base, C_OFF + e * 4, T.i32, align=4))
                hw.lds_store(run, base, OFFS_OFF + e * 4, align=4)
                run = run + c
                for b in range_constexpr(NBM):
                    hw.lds_store(runs[b], base, TOFF_OFF + (b * E + e) * 4, align=4)
                    runs[b] = runs[b] + (c + (bms[b] - 1)) // bms[b]
            for b in range_constexpr(NBM):
                hw.bstore(runs[b], r_nt, b * 4)
        gpu.barrier()
        # Tile lists: thread e writes expert e's tiles for every BM.
        if tid < fx.Int32(E):
            c = fx.Int32(hw.lds_load(base, C_OFF + tid * 4, T.i32, align=4))
            off = fx.Int32(hw.lds_load(base, OFFS_OFF + tid * 4, T.i32, align=4))
            tile_base = fx.Int32(0)
            for b in range_constexpr(NBM):
                bm = bms[b]
                t0 = fx.Int32(hw.lds_load(base, TOFF_OFF + (b * E) * 4 + tid * 4, T.i32, align=4))
                nt = (c + (bm - 1)) // bm
                for m in range(0, nt, 1):
                    mi = fx.Int32(m)
                    rs = off + mi * bm
                    nr = fx.min(c - mi * bm, fx.Int32(bm))
                    v = fx.Vector.from_elements([tid, rs, nr, fx.Int32(0)], fx.Int32)
                    hw.bstore(v, r_tiles, (tile_base + t0 + mi) * 16)
                tile_base = tile_base + max_tiles0 if const_expr(b == 0) else tile_base
        gpu.barrier()
        for i in range(tid, n_rows, PLAN_THREADS):
            ii = fx.Int32(i)
            e = fx.Int32(hw.bload(r_ids, ii * 4, T.i32))
            pos = fx.Int32(_lds_atomic_add(base, CUR_OFF + e * 4, 1))
            row = fx.Int32(hw.lds_load(base, OFFS_OFF + e * 4, T.i32, align=4)) + pos
            hw.bstore(ii // k, r_rt, row * 4)
            hw.bstore(fx.Float32(hw.bload(r_w, ii * 4, T.f32)), r_rw, row * 4)
            hw.bstore(row, r_inv, ii * 4)

    @flyc.jit
    def launch(ids_ptr: fx.Int64, w_ptr: fx.Int64, rtok_ptr: fx.Int64, rw_ptr: fx.Int64,
               inv_ptr: fx.Int64, tiles_ptr: fx.Int64, ntiles_ptr: fx.Int64, n_rows: fx.Int32,
               max_tiles0: fx.Int32, stream: fx.Stream = fx.Stream(None)):
        kern(ids_ptr, w_ptr, rtok_ptr, rw_ptr, inv_ptr, tiles_ptr, ntiles_ptr, n_rows,
             max_tiles0).launch(grid=(1, 1, 1), block=(PLAN_THREADS, 1, 1), stream=stream)

    return launch


@functools.lru_cache(maxsize=None)
def build_quant(H: int, threads: int = 256):
    G = H // 32

    @flyc.kernel(name=f"flymoe_quant_h{H}", known_block_size=[threads, 1, 1])
    def kern(x_ptr: fx.Int64, q_ptr: fx.Int64, s_ptr: fx.Int64, n_groups: fx.Int32):
        gid = fx.Int32(gpu.block_id("x")) * threads + fx.Int32(gpu.thread_id("x"))
        r_x = hw.rsrc(x_ptr, fx.Int64(n_groups) * fx.Int64(64))
        r_q = hw.rsrc(q_ptr, fx.Int64(n_groups) * fx.Int64(16))
        r_s = hw.rsrc(s_ptr, fx.Int64(n_groups))
        vals = []
        for c in range_constexpr(4):
            v = fx.Vector(hw.bload(r_x, gid * 64 + c * 16, T.vec(8, T.bf16))).to(fx.Float32)
            for i in range_constexpr(8):
                vals.append(fx.Float32(v[i]))
        m = fmath.absf(vals[0])
        for i in range_constexpr(1, 32):
            m = fx.max(m, fmath.absf(vals[i]))
        bits = (m * fx.Float32(1.0 / 6.0)).bitcast(fx.Int32)
        bexp = ((bits + fx.Int32(0x7FFFFF)).shrui(fx.Int32(23))) & fx.Int32(0xFF)
        bexp = fx.min(bexp, fx.Int32(254))
        qs = (bexp << fx.Int32(23)).bitcast(fx.Float32)
        words = []
        for wi in range_constexpr(4):
            pk = hw.raw(fx.Int32(0))
            for p in range_constexpr(4):
                pk = rocdl.cvt_scalef32_pk_fp4_f32(
                    T.i32, pk, hw.raw(vals[wi * 8 + 2 * p]), hw.raw(vals[wi * 8 + 2 * p + 1]),
                    hw.raw(qs), p)
            words.append(fx.Int32(pk))
        hw.bstore(fx.Vector.from_elements(words, fx.Int32), r_q, gid * 16)
        hw.bstore(bexp.to(fx.Int8), r_s, gid)

    @flyc.jit
    def launch(x_ptr: fx.Int64, q_ptr: fx.Int64, s_ptr: fx.Int64, n_groups: fx.Int32, grid: fx.Int32,
               stream: fx.Stream = fx.Stream(None)):
        kern(x_ptr, q_ptr, s_ptr, n_groups).launch(grid=(grid, 1, 1), block=(threads, 1, 1), stream=stream)

    return launch


_cf = {}


def _run(key, launch, args):
    if key not in _cf:
        _cf[key] = flyc.compile(launch, *args)
    else:
        _cf[key](*args)


def run_quant(x, q, s, stream=None):
    import torch

    Tn, H = x.shape
    ng = Tn * (H // 32)
    grid = (ng + 255) // 256
    stream = torch.cuda.current_stream() if stream is None else stream
    _run(("q", H), build_quant(H), (x.data_ptr(), q.data_ptr(), s.data_ptr(), ng, grid, stream))


def run_plan(ids_i32, w_f32, row_tok, row_w, inv, tiles, ntiles, E, k, bms, max_tiles0, stream=None):
    import torch

    stream = torch.cuda.current_stream() if stream is None else stream
    _run(("p", E, k, bms), build_plan(E, k, bms),
         (ids_i32.data_ptr(), w_f32.data_ptr(), row_tok.data_ptr(), row_w.data_ptr(), inv.data_ptr(),
          tiles.data_ptr(), ntiles.data_ptr(), ids_i32.numel(), max_tiles0, stream))
