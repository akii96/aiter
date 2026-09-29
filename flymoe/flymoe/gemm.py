"""Grouped A4W4 GEMM for the MoE, both stages, one kernel template.

Work unit: a tile (expert, row_start, nrows) of the compact, expert-sorted row
array (exactly T*topk rows, never padded to BM) times a 256-column N block.

CTA = 4 waves. Wave w owns 64 output columns (4 MFMA n16 tiles); all waves
share the BM-row A tile.

pipe="async": A tile, B atoms, B scales and A scales for each 128-K step go
    global -> LDS by async DMA into an NSTG-deep ring (no staging VGPRs).
pipe="regs":  A through VGPRs into a 2-slot LDS ring, B straight into VGPRs,
    D steps ahead.

stage 1: A = quantized hidden rows gathered by token; epilogue = SwiGLU-OAI +
         fp4 requant of h, written in compact row order ([R, I/2] + [R, I/32]).
stage 2: A = h rows (identity); epilogue = topk weight applied, then
         "rows"       : bf16 per compact row, combined by combine.py (deterministic)
         "f32atomic"  : fp32 atomic add into out[T, H]
         "bf16atomic" : packed bf16 atomic add into out[T, H]
"""

import functools

import flydsl.compiler as flyc
import flydsl.expr as fx
from flydsl.expr import const_expr, gpu, range_constexpr, rocdl
from flydsl.expr import math as fmath
from flydsl.expr.typing import T

from . import hw

def _swz(row):
    return ((row >> 2) & 3) * 16


@functools.lru_cache(maxsize=None)
def build_gemm(stage: int, K: int, N: int, BM: int, D: int = 3, b_nt: bool = False,
               epi: str = "rows", xcd_remap: bool = True, pipe: str = "async", NW: int = 4,
               GM: int = 1, diag: str = "", WM: int = 1, EF: bool = False,
               alpha: float = 1.702, limit: float = 7.0):
    assert stage in (1, 2)
    assert epi in ("rows", "f32atomic", "bf16atomic")
    assert pipe in ("async", "regs", "hybrid", "hybrid2", "async2", "pingpong")
    assert NW in (1, 2, 4, 8) and WM in (1, 2, 4) and NW % WM == 0
    WN = NW // WM  # waves along N; WM wave-rows share each B slice through LDS
    BN = 64 * WN
    THREADS = 64 * NW
    assert K % 128 == 0 and N % BN == 0 and BM % (16 * WM) == 0
    assert WM == 1 or pipe in ("async", "async2", "pingpong"), "WM > 1 needs B staged in LDS"
    assert pipe != "pingpong" or WM == 2, "pingpong alternates the two wave-rows (WM=2)"
    KS = K // 128
    MB = BM // 16
    MBW = MB // WM  # row blocks per wave
    NB = N // BN
    A_INSTR = BM // 16  # 1 KB (16 rows x 64 B) per wave-wide DMA / load
    A_IT = (A_INSTR + NW - 1) // NW
    A_CH = (BM * 4) // THREADS
    KH = K // 2
    KG = K // 32
    INTER = N // 2
    b_cm = hw.NT if b_nt else 0

    SLOT = BM * 64
    if pipe in ("async", "hybrid", "hybrid2", "async2", "pingpong"):
        prefetch = pipe in ("hybrid2", "async2")
        NSTG = max(3 if pipe in ("hybrid2", "async2", "pingpong") else 2, min(D, KS + 1))
        DB = min(D, KS) if pipe in ("hybrid", "hybrid2") else min(3, KS)
        b_lds = pipe in ("async", "async2", "pingpong")
        OFF_B = BM * 64
        OFF_BS = OFF_B + (WN * 4096 if b_lds else 0)
        OFF_AS = OFF_BS + (WN * 256 if b_lds else 0)
        STAGE = OFF_AS + max(BM, 64) * 4
        lds_bytes = NSTG * STAGE
        assert lds_bytes <= 160 * 1024, lds_bytes
    else:
        assert A_CH >= 1 and (BM * 4) % THREADS == 0, "regs pipe needs BM*4 >= threads"
        D = max(1, min(D, KS))
        SLOT = BM * 64
        lds_bytes = 2 * SLOT

    name = f"flymoe_s{stage}_k{K}_n{N}_bm{BM}_w{NW}{'x' + str(WM) if WM > 1 else ''}_{pipe}{D}{'_nt' if b_nt else ''}"
    if stage == 2:
        name += f"_{epi}"
    if xcd_remap:
        name += "_xcd"
    if GM > 1:
        name += f"_gm{GM}"
    if EF:
        name += "_ef"
    NEG_ALPHA_LOG2E = -alpha * 1.4426950408889634
    if diag:
        name += f"_diag{diag.replace('+', '_')}"
    DG = tuple(sorted(diag.split("+"))) if diag else ()  # tuple: part of the FlyDSL JIT cache key (sets are not)

    @fx.struct
    class SharedStorage:
        raw: fx.Array[fx.Uint8, lds_bytes, 16]

    @flyc.kernel(name=name, known_block_size=[THREADS, 1, 1])
    def kern(
        a_ptr: fx.Int64,
        as_ptr: fx.Int64,
        b_ptr: fx.Int64,
        bs_ptr: fx.Int64,
        tiles_ptr: fx.Int64,
        ntiles_ptr: fx.Int64,
        rtok_ptr: fx.Int64,
        rw_ptr: fx.Int64,
        o_ptr: fx.Int64,
        os_ptr: fx.Int64,
        n_a_rows: fx.Int32,
        n_rows: fx.Int32,
        n_out: fx.Int32,
    ):
        tid = fx.Int32(gpu.thread_id("x"))
        bid = fx.Int32(gpu.block_id("x"))
        lane = tid % 64
        wave = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tid // 64)))
        wm = wave // WN
        wn = wave % WN

        r_misc = hw.rsrc(ntiles_ptr, 4)
        ntiles = fx.Int32(rocdl.readfirstlane(T.i32, hw.bload(r_misc, 0, T.i32)))
        bound = ntiles * NB
        if bid < bound:
            # CTAs are dealt round-robin over the 8 XCDs; give each XCD a contiguous
            # range of work so an expert's m-tiles share one L2.
            if const_expr(xcd_remap):
                xq = bound // 8
                xr = bound % 8
                xc = bid % 8
                work = xc * xq + fx.min(xc, xr) + bid // 8
            else:
                work = bid
            if const_expr(GM == 1):
                tile = work // NB
                nblk = work % NB
            else:
                # Groups of GM m-tiles sweep the N blocks together, so concurrently
                # running CTAs share a few weight column slices (L2 reuse).
                grp = work // (GM * NB)
                within = work % (GM * NB)
                gsize = fx.min(ntiles - grp * GM, fx.Int32(GM))
                nblk = within // gsize
                tile = grp * GM + within % gsize
            r_tiles = hw.rsrc(tiles_ptr)
            tv = fx.Vector(hw.bload(r_tiles, tile * 16, T.i32x4))
            e = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tv[0])))
            row_start = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tv[1])))
            nrows = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tv[2])))

            r_a = hw.rsrc(a_ptr, fx.Int64(n_a_rows) * fx.Int64(KH))
            r_as = hw.rsrc(as_ptr, fx.Int64(n_a_rows) * fx.Int64(KG))
            r_tok = hw.rsrc(rtok_ptr, fx.Int64(n_rows) * fx.Int64(4))
            b_exp = fx.Int64(N // 16) * fx.Int64(KS * 1024)
            bs_exp = fx.Int64(N // 64) * fx.Int64(KS * 256)
            r_b = hw.rsrc(fx.Int64(b_ptr) + fx.Int64(e) * b_exp, b_exp)
            r_bs = hw.rsrc(fx.Int64(bs_ptr) + fx.Int64(e) * bs_exp, bs_exp)

            def a_row_of(row):
                valid = row < nrows
                if const_expr(stage == 1):
                    t = fx.Int32(hw.bload(r_tok, (row_start + row) * 4, T.i32))
                else:
                    t = row_start + row
                return valid.select(t, n_a_rows)

            l16 = lane % 16
            lg = lane // 16
            a_rd = l16 * 64 + ((lg * 16) ^ _swz(l16))
            b_voff = []
            for j in range_constexpr(4):
                nt = nblk * (4 * WN) + wn * 4 + j
                b_voff.append(nt * (KS * 1024) + lane * 16)
            bs_voff = (nblk * WN + wn) * (KS * 256) + lane * 4
            rb0 = wm * MBW  # first row block owned by this wave
            lds_base = fx.Int32(
                fx.ptrtoint(fx.SharedAllocator().allocate(SharedStorage).peek().raw.ptr)
            )
            zero = hw.raw(fx.Vector.filled(4, 0.0, fx.Float32))
            acc = [[zero] * 4 for _ in range(MBW)]

            if const_expr(pipe != "regs"):
                # Physical 16 B chunk pc of LDS row r holds logical chunk pc ^ swz(r).
                pc = lane % 4
                a_dma_voff = []
                for it in range_constexpr(A_IT):
                    row = (wave + it * NW) * 16 + lane // 4
                    a_dma_voff.append(a_row_of(row) * KH + ((pc * 16) ^ _swz(row)))
                AS_W = (max(BM, 64) // 64)
                AS_IT = (AS_W + NW - 1) // NW
                as_dma_voff = [a_row_of((wave + it * NW) * 64 + lane) * KG for it in range_constexpr(AS_IT)]

                def issue(s):
                    base = (s % NSTG) * STAGE
                    for it in range_constexpr(A_IT):
                        if const_expr(A_INSTR % NW == 0):
                            hw.dma_async(r_a, lds_base, wave * 1024 + (base + it * NW * 1024),
                                         a_dma_voff[it], soff=s * 64)
                        else:
                            if wave + it * NW < fx.Int32(A_INSTR):
                                hw.dma_async(r_a, lds_base, wave * 1024 + (base + it * NW * 1024),
                                             a_dma_voff[it], soff=s * 64)
                    if const_expr(b_lds):
                        for jj in range_constexpr(4 // WM):
                            if const_expr(WM == 1):
                                hw.dma_async(r_b, lds_base, wn * 4096 + (base + OFF_B + jj * 1024),
                                             b_voff[jj], soff=s * 1024, cm=b_cm)
                            else:
                                j = wm * (4 // WM) + jj
                                hw.dma_async(r_b, lds_base, wn * 4096 + j * 1024 + (base + OFF_B),
                                             b_voff[0] + j * (KS * 1024), soff=s * 1024, cm=b_cm)
                        if const_expr(WM == 1):
                            hw.dma_async(r_bs, lds_base, wn * 256 + (base + OFF_BS), bs_voff,
                                         soff=s * 256, nbytes=4, cm=b_cm)
                        else:
                            if wm == fx.Int32(0):
                                hw.dma_async(r_bs, lds_base, wn * 256 + (base + OFF_BS), bs_voff,
                                             soff=s * 256, nbytes=4, cm=b_cm)
                    for it in range_constexpr(AS_IT):
                        if wave + it * NW < fx.Int32(AS_W):
                            hw.dma_async(r_as, lds_base, wave * 256 + (base + OFF_AS + it * NW * 256),
                                         as_dma_voff[it], soff=s * 4, nbytes=4)
                    rocdl.asyncmark()

                def issue_b(s):
                    bb = [hw.bload(r_b, b_voff[j], T.i32x4, soff=s * 1024, cm=b_cm) for j in range_constexpr(4)]
                    return bb, hw.bload(r_bs, bs_voff, T.i32, soff=s * 256, cm=b_cm)

                breg = {}
                if const_expr(not b_lds):
                    for p in range_constexpr(DB):
                        breg[p] = issue_b(p)
                for p in range_constexpr(min(NSTG - 1, KS)):
                    issue(p)

                def read_a(s):
                    base = (s % NSTG) * STAGE
                    ops = [hw.lds_load(lds_base, a_rd + rb0 * 1024 + (base + rb * 1024), T.i32x4)
                           for rb in range_constexpr(MBW)]
                    sc = [fx.Int32(fx.Uint8(hw.lds_load(lds_base, l16 * 4 + lg + rb0 * 64 + (base + OFF_AS + rb * 64),
                                                        T.i8, align=1)))
                          for rb in range_constexpr(MBW)]
                    if const_expr(b_lds):
                        bo = [hw.lds_load(lds_base, lane * 16 + wn * 4096 + (base + OFF_B + j * 1024), T.i32x4)
                              for j in range_constexpr(4)]
                        bsv = hw.lds_load(lds_base, lane * 4 + wn * 256 + (base + OFF_BS), T.i32, align=4)
                        return ops, sc, (bo, bsv)
                    return ops, sc, None

                if const_expr(pipe == "pingpong"):
                    # Ping-pong: wave-row 1 runs one barrier behind wave-row 0, so on every
                    # SIMD one wave is in its MFMA phase while the other is in its memory
                    # phase (DMA issue + LDS operand reads + DMA completion wait).
                    rocdl.wait_asyncmark(max(0, min(NSTG - 2, KS - 1)))
                    gpu.barrier()
                    if wm == fx.Int32(1):
                        gpu.barrier()
                    for s in range_constexpr(KS):
                        if const_expr(s + NSTG - 1 < KS):
                            issue(s + NSTG - 1)
                        a_ops, sa, bl = read_a(s)
                        b_ops, bs = bl
                        if const_expr(s + 1 < KS):
                            rocdl.wait_asyncmark(max(0, min(NSTG - 2, KS - 2 - s)))
                        rocdl.sched_barrier(0)
                        gpu.barrier()
                        rocdl.s_setprio(1)
                        for rb in range_constexpr(MBW):
                            for j in range_constexpr(4):
                                acc[rb][j] = hw.mfma_fp4(acc[rb][j], a_ops[rb], b_ops[j], sa[rb], bs, 0, j)
                        rocdl.s_setprio(0)
                        rocdl.sched_barrier(0)
                        gpu.barrier()
                    if wm == fx.Int32(0):
                        gpu.barrier()
                if const_expr(prefetch):
                    # LDS operands for step s+1 are read while step s's MFMAs run.
                    rocdl.wait_asyncmark(max(0, min(NSTG - 2, KS - 1)))
                    gpu.barrier()
                    cur = read_a(0)
                    cur0 = cur
                    for s in range_constexpr(KS):
                        a_ops, sa, bl = cur
                        if const_expr(b_lds):
                            b_ops, bs = bl
                        else:
                            b_ops, bs = breg[s]
                            if const_expr(s + DB < KS):
                                breg[s + DB] = breg[s] if const_expr("nob" in DG and s + DB >= DB) else issue_b(s + DB)
                        for rb in range_constexpr(MBW):
                            for j in range_constexpr(4):
                                acc[rb][j] = hw.mfma_fp4(acc[rb][j], a_ops[rb], b_ops[j], sa[rb], bs, 0, j)
                        if const_expr(s + 1 < KS):
                            if const_expr("nobar" not in DG):
                                rocdl.wait_asyncmark(max(0, min(NSTG - 3, KS - 2 - s)))
                                gpu.barrier()
                            if const_expr(s + NSTG - 1 < KS and "nodma" not in DG):
                                issue(s + NSTG - 1)
                            cur = cur0 if const_expr("nolds" in DG) else read_a(s + 1)
                for s in range_constexpr(KS if not (prefetch or pipe == "pingpong") else 0):
                    rocdl.wait_asyncmark(min(NSTG - 2, KS - 1 - s))
                    gpu.barrier()
                    if const_expr(s + NSTG - 1 < KS):
                        issue(s + NSTG - 1)
                    if const_expr((not b_lds) and s + DB < KS):
                        breg[s + DB] = issue_b(s + DB)
                    a_ops, sa, bl = read_a(s)
                    if const_expr(b_lds):
                        b_ops, bs = bl
                    else:
                        b_ops, bs = breg.pop(s)
                    for rb in range_constexpr(MBW):
                        for j in range_constexpr(4):
                            acc[rb][j] = hw.mfma_fp4(acc[rb][j], a_ops[rb], b_ops[j], sa[rb], bs, 0, j)
            else:
                lc = tid % 4
                a_voff = []
                a_lds = []
                for i in range_constexpr(A_CH):
                    row = fx.Int32(i * (THREADS // 4)) + tid // 4
                    a_voff.append(a_row_of(row) * KH + lc * 16)
                    a_lds.append(row * 64 + ((lc * 16) ^ _swz(row)))
                as_voff = []
                for rb in range_constexpr(MB):
                    as_voff.append(a_row_of(fx.Int32(rb * 16) + l16) * KG + lg)

                def issue_r(s):
                    a = [hw.bload(r_a, a_voff[i], T.i32x4, soff=s * 64) for i in range_constexpr(A_CH)]
                    b = [hw.bload(r_b, b_voff[j], T.i32x4, soff=s * 1024, cm=b_cm)
                         for j in range_constexpr(4)]
                    bs = hw.bload(r_bs, bs_voff, T.i32, soff=s * 256, cm=b_cm)
                    sa = [fx.Int32(fx.Uint8(hw.bload(r_as, as_voff[rb], T.i8, soff=s * 4)))
                          for rb in range_constexpr(MB)]
                    return a, b, bs, sa

                def stage_a(regs, slot):
                    for i in range_constexpr(A_CH):
                        hw.lds_store(regs[i], lds_base, a_lds[i] + slot * SLOT)

                inflight = {}
                for s in range_constexpr(D):
                    inflight[s] = issue_r(s)
                stage_a(inflight[0][0], 0)
                gpu.barrier()
                for s in range_constexpr(KS):
                    if const_expr(s + D < KS):
                        inflight[s + D] = issue_r(s + D)
                    if const_expr(s + 1 < KS):
                        stage_a(inflight[s + 1][0], (s + 1) % 2)
                    _, b, bs, sa = inflight.pop(s)
                    slot = s % 2
                    a_ops = [hw.lds_load(lds_base, a_rd + (slot * SLOT + rb * 1024), T.i32x4)
                             for rb in range_constexpr(MB)]
                    for rb in range_constexpr(MB):
                        for j in range_constexpr(4):
                            acc[rb][j] = hw.mfma_fp4(acc[rb][j], a_ops[rb], b[j], sa[rb], bs, 0, j)
                    gpu.barrier()

            if const_expr("noepi" in DG):
                tot = fx.Float32(0.0)
                for rb in range_constexpr(MBW):
                    for j in range_constexpr(4):
                        tot = tot + fx.Float32(fx.Vector(acc[rb][j])[0])
                hw.bstore(tot, hw.rsrc(o_ptr, 4), fx.Int32(0) * tid)
            elif const_expr(stage == 1):
                g = nblk * WN + wn
                r_o = hw.rsrc(o_ptr, fx.Int64(n_rows) * fx.Int64(INTER // 2))
                r_os = hw.rsrc(os_ptr, fx.Int64(n_rows) * fx.Int64(INTER // 32))
                lim = fx.Float32(limit)
                for rb in range_constexpr(MBW):
                    vg_e = fx.Vector(acc[rb][0])
                    vg_o = fx.Vector(acc[rb][1])
                    vu_e = fx.Vector(acc[rb][2])
                    vu_o = fx.Vector(acc[rb][3])
                    for v in range_constexpr(4):
                        row = rb0 * 16 + fx.Int32(rb * 16) + lg * 4 + v
                        hs = []
                        for gv, uv in ((vg_e[v], vu_e[v]), (vg_o[v], vu_o[v])):
                            gg = fx.min(fx.Float32(gv), lim)
                            uu = fx.max(fx.min(fx.Float32(uv), lim), -lim)
                            if const_expr(EF):
                                sig = hw.fast_rcp(fx.Float32(1.0) + fmath.exp2(gg * fx.Float32(NEG_ALPHA_LOG2E)))
                            else:
                                sig = fx.Float32(1.0) / (fx.Float32(1.0) + fmath.exp(gg * fx.Float32(-alpha)))
                            hs.append(gg * sig * (uu + fx.Float32(1.0)))
                        m = fx.max(fmath.absf(hs[0]), fmath.absf(hs[1]))
                        if const_expr(EF):
                            m = hw.row16_max_nonneg_f32(m)
                        else:
                            for off in (1, 2, 4, 8):
                                m = fx.max(m, m.shuffle_xor(fx.Int32(off), fx.Int32(64)))
                        bits = (m * fx.Float32(1.0 / 6.0)).bitcast(fx.Int32)
                        bexp = ((bits + fx.Int32(0x7FFFFF)).shrui(fx.Int32(23))) & fx.Int32(0xFF)
                        bexp = fx.min(bexp, fx.Int32(254))
                        qs = (bexp << fx.Int32(23)).bitcast(fx.Float32)
                        pk = rocdl.cvt_scalef32_pk_fp4_f32(
                            T.i32, hw.raw(fx.Int32(0)), hw.raw(hs[0]), hw.raw(hs[1]), hw.raw(qs), 0
                        )
                        valid = row < nrows
                        grow = row_start + row
                        off = valid.select(grow * (INTER // 2) + g * 16 + l16, fx.Int32(0x7FFFFFF0))
                        hw.bstore(fx.Int32(pk).to(fx.Int8), r_o, off)
                        soff_ok = valid & (l16 == fx.Int32(0))
                        soff = soff_ok.select(grow * (INTER // 32) + g, fx.Int32(0x7FFFFFF0))
                        hw.bstore(bexp.to(fx.Int8), r_os, soff)
            else:
                # W2 columns are even/odd interleaved per 32: tiles (0,1) and (2,3) of
                # this wave give each lane output columns (gb + 2c, gb + 2c + 1).
                r_w = hw.rsrc(rw_ptr, fx.Int64(n_rows) * fx.Int64(4))
                if const_expr(epi == "f32atomic"):
                    r_o = hw.rsrc(o_ptr, fx.Int64(n_out) * fx.Int64(N * 4))
                elif const_expr(epi == "bf16atomic"):
                    r_o = hw.rsrc(o_ptr, fx.Int64(n_out) * fx.Int64(N * 2))
                else:
                    r_o = hw.rsrc(o_ptr, fx.Int64(n_rows) * fx.Int64(N * 2))
                col0 = nblk * BN + wn * 64 + l16 * 2
                for rb in range_constexpr(MBW):
                    vs = [fx.Vector(acc[rb][j]) for j in range_constexpr(4)]
                    for v in range_constexpr(4):
                        row = rb0 * 16 + fx.Int32(rb * 16) + lg * 4 + v
                        valid = row < nrows
                        grow = row_start + row
                        w = fx.Float32(hw.bload(r_w, grow * 4, T.f32))
                        if const_expr(epi == "rows"):
                            dst_row = grow
                        else:
                            dst_row = fx.Int32(hw.bload(r_tok, grow * 4, T.i32))
                        for p in range_constexpr(2):
                            ve = fx.Float32(vs[2 * p][v]) * w
                            vo = fx.Float32(vs[2 * p + 1][v]) * w
                            col = col0 + p * 32
                            if const_expr(epi == "f32atomic"):
                                off = valid.select((dst_row * N + col) * 4, fx.Int32(0x7FFFFF00))
                                hw.batomic_fadd(ve, r_o, off)
                                hw.batomic_fadd(vo, r_o, off + 4)
                            else:
                                pk = fx.Vector.from_elements([ve, vo], fx.Float32).to(fx.BFloat16)
                                off = valid.select((dst_row * N + col) * 2, fx.Int32(0x7FFFFF00))
                                if const_expr(epi == "bf16atomic"):
                                    hw.batomic_fadd(pk, r_o, off)
                                else:
                                    hw.bstore(pk, r_o, off)

    @flyc.jit
    def launch(
        a_ptr: fx.Int64, as_ptr: fx.Int64, b_ptr: fx.Int64, bs_ptr: fx.Int64,
        tiles_ptr: fx.Int64, ntiles_ptr: fx.Int64, rtok_ptr: fx.Int64, rw_ptr: fx.Int64,
        o_ptr: fx.Int64, os_ptr: fx.Int64,
        n_a_rows: fx.Int32, n_rows: fx.Int32, n_out: fx.Int32, grid: fx.Int32,
        stream: fx.Stream = fx.Stream(None),
    ):
        kern(a_ptr, as_ptr, b_ptr, bs_ptr, tiles_ptr, ntiles_ptr, rtok_ptr, rw_ptr,
             o_ptr, os_ptr, n_a_rows, n_rows, n_out).launch(
            grid=(grid, 1, 1), block=(THREADS, 1, 1), stream=stream)

    return launch, NB


class _Runner:
    def __init__(self, launch):
        self.launch = launch
        self.cf = None

    def __call__(self, *args):
        if self.cf is None:
            self.cf = flyc.compile(self.launch, *args)
        else:
            self.cf(*args)


_runners = {}


def run_gemm(stage, K, N, BM, args, max_tiles, D=3, b_nt=False, epi="rows", xcd_remap=True,
             pipe="async", NW=4, GM=1, diag="", WM=1, EF=False, stream=None):
    import torch

    key = (stage, K, N, BM, D, b_nt, epi, xcd_remap, pipe, NW, GM, diag, WM, EF)
    if key not in _runners:
        launch, nb = build_gemm(stage, K, N, BM, D, b_nt, epi, xcd_remap, pipe, NW, GM, diag, WM, EF)
        _runners[key] = (_Runner(launch), nb)
    r, nb = _runners[key]
    stream = torch.cuda.current_stream() if stream is None else stream
    r(*args, max_tiles * nb, stream)
