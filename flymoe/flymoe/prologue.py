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


CHUNK = 4096  # routing entries per CTA in the parallel plan


def spec_of(b):
    """Tile-list spec: int BM (all rows) or (BM, parent): parent=-1 -> only full BM tiles;
    parent=P>0 -> only the rows left after an expert's full P-row tiles, in BM tiles."""
    return (b, 0) if isinstance(b, int) else (int(b[0]), int(b[1]))


def spec_tag(bms):
    names = {0: "", -1: "f", -2: "ro", -3: "sh"}
    return "_".join(f"{bm}{names[p]}" if p <= 0 else f"{bm}r{p}" for bm, p in map(spec_of, bms))


def spec_max_tiles(b, R, E):
    bm, p = spec_of(b)
    if p == 0:
        return (R + bm - 1) // bm + E
    if p == -1:
        return R // bm + 1
    if p in (-2, -3):
        return (R + bm - 1) // bm + E
    return E * ((p + bm - 1) // bm)


@functools.lru_cache(maxsize=None)
def build_plan_par(E: int, k: int, bms: tuple, shared_last: bool = False):
    """Parallel plan in 3 launches (hist -> prefix/tiles -> scatter).

    hist   : CTA c counts its CHUNK of topk_ids in LDS, then one global atomic per
             expert returns the CTA's base inside that expert (cbase[c, e]).
    prefix : one CTA turns gcount into expert offsets and tile lists; re-zeroes gcount.
    scatter: CTA c re-walks its chunk; row = offs[e] + cbase[c, e] + local position.
    """
    NBM = len(bms)
    TH = 1024
    assert E <= 256, "k_prefix runs one thread per expert in a 256-thread CTA"

    @fx.struct
    class HistStorage:
        raw: fx.Array[fx.Uint8, ((2 * E * 4 + 15) // 16) * 16, 16]

    @flyc.kernel(name=f"flymoe_plan_hist_e{E}", known_block_size=[TH, 1, 1])
    def k_hist(ids_ptr: fx.Int64, gcount_ptr: fx.Int64, cbase_ptr: fx.Int64, n_rows: fx.Int32):
        tid = fx.Int32(gpu.thread_id("x"))
        c = fx.Int32(gpu.block_id("x"))
        base = fx.Int32(fx.ptrtoint(fx.SharedAllocator().allocate(HistStorage).peek().raw.ptr))
        r_ids = hw.rsrc(ids_ptr, fx.Int64(n_rows) * fx.Int64(4))
        r_cb = hw.rsrc(cbase_ptr)
        if tid < fx.Int32(E):
            hw.lds_store(fx.Int32(0), base, tid * 4, align=4)
        gpu.barrier()
        for j in range_constexpr(CHUNK // TH):
            i = c * CHUNK + j * TH + tid
            if i < n_rows:
                e = fx.Int32(hw.bload(r_ids, i * 4, T.i32))
                _lds_atomic_add(base, e * 4, 1)
        gpu.barrier()
        if tid < fx.Int32(E):
            cnt = fx.Int32(hw.lds_load(base, tid * 4, T.i32, align=4))
            prev = fx.Int32(llvm.AtomicRMWOp(
                llvm.AtomicBinOp.add,
                hw.raw(_global_ptr(gcount_ptr, tid * 4)),
                hw.raw(cnt), llvm.AtomicOrdering.monotonic, syncscope="agent").result)
            hw.bstore(prev, r_cb, (c * E + tid) * 4)

    specs = tuple(spec_of(b) for b in bms)  # tuple: part of the JIT cache key (lists are not)

    def _nt(c, bm, parent, e):
        """Tiles of expert e (Python int or thread id) in a spec's list."""
        if parent == 0:
            return (c + (bm - 1)) // bm
        if parent == -1:
            return c // bm
        if parent in (-2, -3):
            n = (c + (bm - 1)) // bm
            if isinstance(e, int):
                keep = (e < E - 1) if parent == -2 else (e == E - 1)
                return n if keep else fx.Int32(0)
            keep = (e < fx.Int32(E - 1)) if parent == -2 else (e == fx.Int32(E - 1))
            return keep.select(n, fx.Int32(0))
        return (c % parent + (bm - 1)) // bm

    ptag = f"flymoe_plan_prefix_e{E}_{spec_tag(bms)}"

    @flyc.kernel(name=ptag, known_block_size=[256, 1, 1])
    def k_prefix(gcount_ptr: fx.Int64, offs_ptr: fx.Int64, tiles_ptr: fx.Int64, ntiles_ptr: fx.Int64,
                 max_tiles0: fx.Int32):
        if const_expr(ptag == ""):  # tag string in the JIT cache key
            pass
        tid = fx.Int32(gpu.thread_id("x"))
        r_gc = hw.rsrc(gcount_ptr)
        r_offs = hw.rsrc(offs_ptr)
        r_tiles = hw.rsrc(tiles_ptr)
        r_nt = hw.rsrc(ntiles_ptr)
        if tid < fx.Int32(E):
            # Each thread sums the counts before it (E is small; loads hit L2).
            cnt = fx.Int32(hw.bload(r_gc, tid * 4, T.i32))
            off = fx.Int32(0)
            toffs = [fx.Int32(0)] * NBM
            for e2 in range_constexpr(E):
                c2 = fx.Int32(hw.bload(r_gc, e2 * 4, T.i32))
                before = fx.Int32(e2) < tid
                off = off + before.select(c2, fx.Int32(0))
                for b in range_constexpr(NBM):
                    toffs[b] = toffs[b] + before.select(_nt(c2, *specs[b], e2), fx.Int32(0))
            hw.bstore(off, r_offs, tid * 4)
            for b in range_constexpr(NBM):
                bm, parent = specs[b]
                nt = _nt(cnt, bm, parent, tid)
                tb = max_tiles0 * b  # spec b's tile list starts at b * stride
                if const_expr(parent > 0):
                    # remainder rows after this expert's full parent-size tiles
                    base = off + (cnt // parent) * parent
                    left = cnt % parent
                else:
                    base = off
                    left = cnt
                for m in range(0, nt, 1):
                    mi = fx.Int32(m)
                    nr = fx.Int32(bm) if const_expr(parent == -1) else fx.min(left - mi * bm, fx.Int32(bm))
                    v = fx.Vector.from_elements([tid, base + mi * bm, nr, fx.Int32(0)], fx.Int32)
                    hw.bstore(v, r_tiles, (tb + toffs[b] + mi) * 16)
                if tid == fx.Int32(E - 1):
                    hw.bstore(toffs[b] + nt, r_nt, b * 4)
        gpu.barrier()
        # Every thread has read every count above; re-zero here (single CTA, same launch
        # that consumed them) so an aborted later launch cannot leave gcount dirty.
        if tid < fx.Int32(E):
            hw.bstore(fx.Int32(0), r_gc, tid * 4)

    @fx.struct
    class ScatStorage:
        raw: fx.Array[fx.Uint8, ((2 * E * 4 + 15) // 16) * 16, 16]

    @flyc.kernel(name=f"flymoe_plan_scatter_e{E}_k{k}{'_sl' if shared_last else ''}", known_block_size=[TH, 1, 1])
    def k_scatter(ids_ptr: fx.Int64, w_ptr: fx.Int64, offs_ptr: fx.Int64, cbase_ptr: fx.Int64,
                  rtok_ptr: fx.Int64, rw_ptr: fx.Int64, inv_ptr: fx.Int64, gcount_ptr: fx.Int64,
                  n_rows: fx.Int32):
        tid = fx.Int32(gpu.thread_id("x"))
        c = fx.Int32(gpu.block_id("x"))
        base = fx.Int32(fx.ptrtoint(fx.SharedAllocator().allocate(ScatStorage).peek().raw.ptr))
        r_ids = hw.rsrc(ids_ptr, fx.Int64(n_rows) * fx.Int64(4))
        r_w = hw.rsrc(w_ptr, fx.Int64(n_rows) * fx.Int64(4))
        r_offs = hw.rsrc(offs_ptr)
        r_cb = hw.rsrc(cbase_ptr)
        r_rt = hw.rsrc(rtok_ptr, fx.Int64(n_rows) * fx.Int64(4))
        r_rw = hw.rsrc(rw_ptr, fx.Int64(n_rows) * fx.Int64(4))
        r_inv = hw.rsrc(inv_ptr, fx.Int64(n_rows) * fx.Int64(4))
        if tid < fx.Int32(E):
            start = fx.Int32(hw.bload(r_offs, tid * 4, T.i32)) + fx.Int32(hw.bload(r_cb, (c * E + tid) * 4, T.i32))
            hw.lds_store(start, base, tid * 4, align=4)
        gpu.barrier()
        for j in range_constexpr(CHUNK // TH):
            i = c * CHUNK + j * TH + tid
            if i < n_rows:
                e = fx.Int32(hw.bload(r_ids, i * 4, T.i32))
                if const_expr(shared_last):
                    # Shared expert (E-1, exactly once per token): token-ordered rows.
                    row = fx.Int32(0)
                    if e == fx.Int32(E - 1):
                        row = fx.Int32(hw.bload(r_offs, (E - 1) * 4, T.i32)) + i // k
                    else:
                        row = fx.Int32(_lds_atomic_add(base, e * 4, 1))
                else:
                    row = fx.Int32(_lds_atomic_add(base, e * 4, 1))
                hw.bstore(i // k, r_rt, row * 4)
                hw.bstore(fx.Float32(hw.bload(r_w, i * 4, T.f32)), r_rw, row * 4)
                hw.bstore(row, r_inv, i * 4)

    @flyc.jit
    def launch(ids_ptr: fx.Int64, w_ptr: fx.Int64, rtok_ptr: fx.Int64, rw_ptr: fx.Int64,
               inv_ptr: fx.Int64, tiles_ptr: fx.Int64, ntiles_ptr: fx.Int64, gcount_ptr: fx.Int64,
               offs_ptr: fx.Int64, cbase_ptr: fx.Int64, n_rows: fx.Int32, n_cta: fx.Int32,
               max_tiles0: fx.Int32, stream: fx.Stream = fx.Stream(None)):
        k_hist(ids_ptr, gcount_ptr, cbase_ptr, n_rows).launch(
            grid=(n_cta, 1, 1), block=(TH, 1, 1), stream=stream)
        k_prefix(gcount_ptr, offs_ptr, tiles_ptr, ntiles_ptr, max_tiles0).launch(
            grid=(1, 1, 1), block=(256, 1, 1), stream=stream)
        k_scatter(ids_ptr, w_ptr, offs_ptr, cbase_ptr, rtok_ptr, rw_ptr, inv_ptr, gcount_ptr,
                  n_rows).launch(grid=(n_cta, 1, 1), block=(TH, 1, 1), stream=stream)

    return launch


def _global_ptr(addr_i64, byte_off):
    ptr_ty = fx.PointerType.get(T.i32, fx.AddressSpace.Global, 4)
    base = fx.inttoptr(fx.PointerType.get(T.i8, fx.AddressSpace.Global, 4), fx.Int64(addr_i64))
    return fx.to_llvm_ptr(fx.recast_iter(ptr_ty, fx.add_offset(base, fx.Int32(byte_off))))


@functools.lru_cache(maxsize=None)
def build_scale_t(KG: int, threads: int = 256):
    """a_s [T, KG] bytes (token-major) -> a_s_t [KG/4, R, 4] (K-step-major, compact rows).

    With this layout a tile's A scales for one 128-K step are BM*4 contiguous bytes,
    so the GEMM fetches them with one 16 B/lane DMA instead of a 4 B-per-row gather.
    """
    KS = KG // 4

    @flyc.kernel(name=f"flymoe_scale_t_kg{KG}", known_block_size=[threads, 1, 1])
    def kern(as_ptr: fx.Int64, rtok_ptr: fx.Int64, ast_ptr: fx.Int64, n_rows: fx.Int32, n_tok: fx.Int32):
        b = fx.Int32(gpu.block_id("x"))
        row = (b % ((n_rows + threads - 1) // threads)) * threads + fx.Int32(gpu.thread_id("x"))
        s = b // ((n_rows + threads - 1) // threads)
        r_tok = hw.rsrc(rtok_ptr, fx.Int64(n_rows) * fx.Int64(4))
        r_as = hw.rsrc(as_ptr, fx.Int64(n_tok) * fx.Int64(KG))
        r_ast = hw.rsrc(ast_ptr, fx.Int64(n_rows) * fx.Int64(KG))
        if row < n_rows:
            t = fx.Int32(hw.bload(r_tok, row * 4, T.i32))
            v = fx.Int32(hw.bload(r_as, t * KG + s * 4, T.i32))
            hw.bstore(v, r_ast, (s * n_rows + row) * 4)

    @flyc.jit
    def launch(as_ptr: fx.Int64, rtok_ptr: fx.Int64, ast_ptr: fx.Int64, n_rows: fx.Int32, n_tok: fx.Int32,
               grid: fx.Int32, stream: fx.Stream = fx.Stream(None)):
        kern(as_ptr, rtok_ptr, ast_ptr, n_rows, n_tok).launch(
            grid=(grid, 1, 1), block=(threads, 1, 1), stream=stream)

    return launch


def run_scale_t(a_s, row_tok, a_s_t, stream=None):
    import torch

    n_tok, KG = a_s.shape
    R = row_tok.numel()
    grid = ((R + 255) // 256) * (KG // 4)
    stream = torch.cuda.current_stream() if stream is None else stream
    _run(("st", KG), build_scale_t(KG),
         (a_s.data_ptr(), row_tok.data_ptr(), a_s_t.data_ptr(), R, n_tok, grid, stream))


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


def run_plan(ids_i32, w_f32, row_tok, row_w, inv, tiles, ntiles, E, k, bms, max_tiles0, stream=None,
             scratch=None, shared_last=False):
    """scratch: (gcount [E] int32 zero-initialised once, offs [E], cbase [n_cta*E])."""
    import torch

    stream = torch.cuda.current_stream() if stream is None else stream
    n = ids_i32.numel()
    if scratch is None:
        _run(("p", E, k, bms), build_plan(E, k, bms),
             (ids_i32.data_ptr(), w_f32.data_ptr(), row_tok.data_ptr(), row_w.data_ptr(), inv.data_ptr(),
              tiles.data_ptr(), ntiles.data_ptr(), n, max_tiles0, stream))
        return
    gcount, offs, cbase = scratch
    n_cta = (n + CHUNK - 1) // CHUNK
    _run(("pp", E, k, bms, shared_last), build_plan_par(E, k, bms, shared_last),
         (ids_i32.data_ptr(), w_f32.data_ptr(), row_tok.data_ptr(), row_w.data_ptr(), inv.data_ptr(),
          tiles.data_ptr(), ntiles.data_ptr(), gcount.data_ptr(), offs.data_ptr(), cbase.data_ptr(),
          n, n_cta, max_tiles0, stream))


def plan_scratch(R, E, device):
    import torch

    n_cta = (R + CHUNK - 1) // CHUNK
    return (torch.zeros(E, dtype=torch.int32, device=device),
            torch.empty(E, dtype=torch.int32, device=device),
            torch.empty(n_cta * E, dtype=torch.int32, device=device))
