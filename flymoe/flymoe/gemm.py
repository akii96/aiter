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

NUM_CUS = 256
OOB = 0x7FFFFFC0  # voffset sentinel: >= hw.REC_CAP even with a 63 B chunk offset added


def _swz(row, mode=3):
    """XOR (in 16 B units) applied to the logical K chunk of an A-tile LDS row (64 B rows)."""
    if mode == 0:
        return row * 0
    if mode == 1:
        return ((row >> 2) & 3) * 16
    if mode == 2:
        return (row & 3) * 16
    if mode == 3:
        return ((row >> 1) & 3) * 16
    return (((row >> 2) ^ row) & 3) * 16


@functools.lru_cache(maxsize=None)
def build_gemm(stage: int, K: int, N: int, BM: int, D: int = 3, b_nt: bool = False,
               epi: str = "rows", xcd_remap: bool = True, pipe: str = "async", NW: int = 4,
               GM: int = 1, diag: str = "", WM: int = 1, EF: bool = False, MV: int = 0, AST: bool = False,
               HT: bool = False, KTOP: int = 5, PERS: int = 0,
               alpha: float = 1.702, limit: float = 7.0):
    assert stage in (1, 2)
    assert epi in ("rows", "f32atomic", "bf16atomic", "fused")
    assert epi != "fused" or stage == 2
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
        # LDS is laid out per buffer kind across ring slots ([A x NSTG][B x NSTG][BS][AS]) so
        # every LDS read is (one hoisted base VGPR per kind) + an immediate offset < 64 KB:
        # no per-read address VALU, which would queue behind the partner wave's MFMAs.
        SA = BM * 64
        SB = WN * 4096 if b_lds else 0
        SBS = WN * 256 if b_lds else 0
        SAS = max(BM * 4, 1024) if (AST and BM >= 256) else max(BM, 64) * 4
        RB = NSTG * SA
        RBS = RB + NSTG * SB
        RAS = RBS + NSTG * SBS
        lds_bytes = RAS + NSTG * SAS
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
    if MV:
        name += f"_mv{MV}"
    if AST:
        name += "_ast"
    if HT:
        name += "_ht"
    if epi == "fused":
        name += f"_k{KTOP}"
    if PERS:
        name += f"_p{PERS}"
    NEG_ALPHA_LOG2E = -alpha * 1.4426950408889634
    if diag:
        name += f"_diag{diag.replace('+', '_')}"
    if (alpha, limit) != (1.702, 7.0):
        name += f"_a{alpha}_l{limit}".replace(".", "p")
    name += "_" + hw.SRC_HASH
    DG = tuple(sorted(diag.split("+"))) if diag else ()  # tuple: part of the FlyDSL JIT cache key (sets are not)
    SKIP = "skip" in DG
    HTA = HT and stage == 2   # stage-2 A (= h) is K-step-major: h_t[I/128][R][64 B]
    HTW = HT and stage == 1   # stage-1 epilogue writes h_t + step-major h scales
    # Uniform scale DMAs for the 2x4 ping-pong tile: every wave issues exactly one 256 B
    # scale DMA per step (wave-row 0: its B-scale block, wave-row 1: a quarter of the
    # step-major A scales), so all waves carry identical DMA counts and vmcnt is exact.
    UNI = "uni" in DG and pipe == "pingpong" and WM == 2 and WN == 4 and BM == 256 and AST
    SWZ = next((int(t[3:]) for t in DG if t.startswith("swz")), 3)  # mode 3: zero LDS bank conflicts (measured)

    # Stage-2 wide stores: each wave stages its weighted bf16 tile (rows x 64 cols = 128 B
    # per row) in LDS, then writes 16 B/lane full-line row segments.
    S2W = stage == 2 and ((epi == "rows" and "nos2w" not in DG) or epi == "fused")
    S2NT = "s2nt" in DG
    ROWS_W = MBW * 16
    if S2W:
        lds_bytes = max(lds_bytes, NW * ROWS_W * 128)
    if HT and stage == 1:
        lds_bytes = max(lds_bytes, NW * max(ROWS_W, 64) * 16)

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
        aux_ptr: fx.Int64,
        n_a_rows: fx.Int32,
        n_rows: fx.Int32,
        n_out: fx.Int32,
    ):
        if const_expr(name == "" or MV < 0):  # name + MV in the JIT cache key (name encodes every build param)
            pass
        tid = fx.Int32(gpu.thread_id("x"))
        bid = fx.Int32(gpu.block_id("x"))
        lane = tid % 64
        wave = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tid // 64)))
        wm = wave // WN
        wn = wave % WN

        r_misc = hw.rsrc(ntiles_ptr, 4)
        ntiles = fx.Int32(rocdl.readfirstlane(T.i32, hw.bload(r_misc, 0, T.i32)))
        bound = ntiles * NB
        def _tile_body(work):
            if const_expr(PERS):
                gpu.barrier()  # previous tile's LDS use is finished before the ring refills
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
            r_as = hw.rsrc(as_ptr, fx.Int64(n_rows if const_expr(AST) else n_a_rows) * fx.Int64(KG))
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
                # HT planes are addressed via soffset, which the buffer range check ignores:
                # invalid rows need an out-of-range voffset of their own.
                return valid.select(t, (OOB // 64) if const_expr(HTA) else n_a_rows)

            def as_off(row):
                return (row < nrows).select((row_start + row) * 4, OOB)

            l16 = lane % 16
            lg = lane // 16

            def a_soff(s):
                # h_t layout: K step s of every row lives in plane s ([KS][R][64 B])
                return n_rows * (s * 64) if const_expr(HTA) else s * 64
            a_rd = l16 * 64 + ((lg * 16) ^ _swz(l16, SWZ))
            b_voff = []
            for j in range_constexpr(4):
                nt = nblk * (4 * WN) + wn * 4 + j
                b_voff.append(nt * (KS * 1024) + lane * 16)
            if const_expr(stage == 1):
                # stage-1 B scales are K-step-major (layout.pack_w13)
                bs_voff = (nblk * WN + wn) * 256 + lane * 4
                BS_STEP = (N // 64) * 256
            else:
                bs_voff = (nblk * WN + wn) * (KS * 256) + lane * 4
                BS_STEP = 256
            # One 16 B/lane DMA covers the CTA's 4 B-scale blocks (1 KB) for a step.
            BS1 = WN == 4 and stage == 1
            bs16_voff = (nblk * WN) * 256 + lane * 16
            bs_wave = 1 if NW <= 4 else 4  # the wave issuing the B-scale DMA
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
                    a_dma_voff.append(a_row_of(row) * (64 if HTA else KH) + ((pc * 16) ^ _swz(row, SWZ)))
                as_uni_voff = as_off(wn * 64 + lane)
                AS16 = AST and BM >= 256
                if const_expr(AS16):
                    # K-step-major compact scales: 256 rows x 4 B = one 16 B/lane DMA per 256 rows.
                    AS_W = (BM + 255) // 256
                    AS_IT = (AS_W + NW - 1) // NW
                    as_dma_voff = [as_off((wave + it * NW) * 256 + lane * 4)
                                   for it in range_constexpr(AS_IT)]
                elif const_expr(AST):
                    # K-step-major compact scales, 64 rows (256 B) per 4 B/lane DMA: exact for BM < 256.
                    AS_W = (max(BM, 64) // 64)
                    AS_IT = (AS_W + NW - 1) // NW
                    as_dma_voff = [as_off((wave + it * NW) * 64 + lane)
                                   for it in range_constexpr(AS_IT)]
                else:
                    AS_W = (max(BM, 64) // 64)
                    AS_IT = (AS_W + NW - 1) // NW
                    as_dma_voff = [a_row_of((wave + it * NW) * 64 + lane) * KG for it in range_constexpr(AS_IT)]

                def dma_ops(s):
                    """This wave's DMA instructions for K step s, as thunks (issue order)."""
                    slot = s % NSTG
                    oA, oB, oBS, oAS = slot * SA, RB + slot * SB, RBS + slot * SBS, RAS + slot * SAS
                    ops = []
                    for it in range_constexpr(A_IT if "nodmaA" not in DG else 0):
                        if const_expr(A_INSTR % NW == 0):
                            ops.append(lambda it=it: hw.dma_async(
                                r_a, lds_base, wave * 1024 + (oA + it * NW * 1024), a_dma_voff[it], soff=a_soff(s)))
                        else:
                            def _a(it=it):
                                if wave + it * NW < fx.Int32(A_INSTR):
                                    hw.dma_async(r_a, lds_base, wave * 1024 + (oA + it * NW * 1024),
                                                 a_dma_voff[it], soff=a_soff(s))
                            ops.append(_a)
                    if const_expr(UNI):
                        def _sc():
                            if wm == fx.Int32(0):
                                hw.dma_async(r_bs, lds_base, wn * 256 + oBS, bs_voff,
                                             soff=s * BS_STEP, nbytes=4, cm=b_cm)
                            else:
                                hw.dma_async(r_as, lds_base, wn * 256 + oAS, as_uni_voff,
                                             soff=n_rows * (s * 4), nbytes=4)
                    if const_expr(b_lds and "nodmaB" not in DG):
                        for jj in range_constexpr(4 // WM):
                            if const_expr(WM == 1):
                                ops.append(lambda jj=jj: hw.dma_async(
                                    r_b, lds_base, wn * 4096 + (oB + jj * 1024), b_voff[jj],
                                    soff=s * 1024, cm=b_cm))
                            else:
                                def _b(jj=jj):
                                    j = wm * (4 // WM) + jj
                                    hw.dma_async(r_b, lds_base, wn * 4096 + j * 1024 + oB,
                                                 b_voff[0] + j * (KS * 1024), soff=s * 1024, cm=b_cm)
                                ops.append(_b)
                        if const_expr(UNI):
                            ops.append(_sc)
                        elif const_expr(BS1 and NW > 1):
                            def _bs1():
                                if wave == fx.Int32(bs_wave):
                                    hw.dma_async(r_bs, lds_base, oBS, bs16_voff, soff=s * BS_STEP,
                                                 nbytes=16, cm=b_cm)
                            ops.append(_bs1)
                        elif const_expr(WM == 1):
                            ops.append(lambda: hw.dma_async(r_bs, lds_base, wn * 256 + oBS, bs_voff,
                                                            soff=s * BS_STEP, nbytes=4, cm=b_cm))
                        else:
                            def _bs():
                                if wm == fx.Int32(0):
                                    hw.dma_async(r_bs, lds_base, wn * 256 + oBS, bs_voff,
                                                 soff=s * BS_STEP, nbytes=4, cm=b_cm)
                            ops.append(_bs)
                    for it in range_constexpr(AS_IT if not UNI else 0):
                        if const_expr(AS16):
                            def _as(it=it):
                                if wave + it * NW < fx.Int32(AS_W):
                                    hw.dma_async(r_as, lds_base, wave * 1024 + (oAS + it * NW * 1024),
                                                 as_dma_voff[it], soff=n_rows * (s * 4), nbytes=16)
                        elif const_expr(AST):
                            def _as(it=it):
                                if wave + it * NW < fx.Int32(AS_W):
                                    hw.dma_async(r_as, lds_base, wave * 256 + (oAS + it * NW * 256),
                                                 as_dma_voff[it], soff=n_rows * (s * 4), nbytes=4)
                        else:
                            def _as(it=it):
                                if wave + it * NW < fx.Int32(AS_W):
                                    hw.dma_async(r_as, lds_base, wave * 256 + (oAS + it * NW * 256),
                                                 as_dma_voff[it], soff=s * 4, nbytes=4)
                        ops.append(_as)
                    return ops

                def issue(s):
                    for op in dma_ops(s):
                        op()
                    rocdl.asyncmark()

                def issue_b(s):
                    bb = [hw.bload(r_b, b_voff[j], T.i32x4, soff=s * 1024, cm=b_cm) for j in range_constexpr(4)]
                    return bb, hw.bload(r_bs, bs_voff, T.i32, soff=s * BS_STEP, cm=b_cm)

                breg = {}
                if const_expr(not b_lds):
                    for p in range_constexpr(DB):
                        breg[p] = issue_b(p)
                for p in range_constexpr(min(NSTG - 1, KS)):
                    issue(p)

                # Per-kind LDS read bases (lane-varying part + region start), computed once.
                as_rd = l16 * 4 + lg + rb0 * 64 + RAS
                b_rd = lane * 16 + wn * 4096 + RB
                bs_rd = lane * 4 + wn * 256 + RBS

                def read_a(s, dmas=None, every=3):
                    """LDS operand reads for step s. dmas: DMA thunks to interleave, one after
                    every `every` reads, fenced so the scheduler keeps the interleave."""
                    if const_expr(dmas is not None):
                        return read_a_il(s, dmas, every)
                    slot = s % NSTG
                    oA, oB, oBS, oAS = slot * SA, slot * SB, slot * SBS, slot * SAS
                    ops = [hw.lds_load(lds_base, a_rd + rb0 * 1024 + (oA + rb * 1024), T.i32x4)
                           for rb in range_constexpr(MBW)]
                    sc = [fx.Int32(fx.Uint8(hw.lds_load(lds_base, as_rd + (oAS + rb * 64),
                                                        T.i8, align=1)))
                          for rb in range_constexpr(MBW)]
                    if const_expr(b_lds):
                        bo = [hw.lds_load(lds_base, b_rd + (oB + j * 1024), T.i32x4)
                              for j in range_constexpr(4)]
                        bsv = hw.lds_load(lds_base, bs_rd + oBS, T.i32, align=4)
                        return ops, sc, (bo, bsv)
                    return ops, sc, None

                def read_a_il(s, dmas, every):
                    slot = s % NSTG
                    oA, oB, oBS, oAS = slot * SA, slot * SB, slot * SBS, slot * SAS
                    thunks = []
                    for rb in range_constexpr(MBW):
                        thunks.append(lambda rb=rb: hw.lds_load(lds_base, a_rd + rb0 * 1024 + (oA + rb * 1024), T.i32x4))
                    for j in range_constexpr(4):
                        thunks.append(lambda j=j: hw.lds_load(lds_base, b_rd + (oB + j * 1024), T.i32x4))
                    thunks.append(lambda: hw.lds_load(lds_base, bs_rd + oBS, T.i32, align=4))
                    for rb in range_constexpr(MBW):
                        thunks.append(lambda rb=rb: hw.lds_load(lds_base, as_rd + (oAS + rb * 64), T.i8, align=1))
                    vals = []
                    di = 0
                    for i in range_constexpr(len(thunks)):
                        vals.append(thunks[i]())
                        if const_expr(i % every == every - 1 and di < len(dmas)):
                            rocdl.sched_barrier(0)
                            dmas[di]()
                            di += 1
                            rocdl.sched_barrier(0)
                    for k2 in range_constexpr(di, len(dmas)):
                        dmas[k2]()
                    ops = vals[:MBW]
                    bo = vals[MBW:MBW + 4]
                    bsv = vals[MBW + 4]
                    sc = [fx.Int32(fx.Uint8(v)) for v in vals[MBW + 5:]]
                    return ops, sc, (bo, bsv)

                if const_expr(pipe == "pingpong"):
                    # Ping-pong: wave-row 1 runs one barrier behind wave-row 0, so on every
                    # SIMD one wave is in its MFMA phase while the other is in its memory
                    # phase (DMA issue + LDS operand reads + DMA completion wait).
                    rocdl.wait_asyncmark(max(0, min(NSTG - 2, KS - 1)))
                    gpu.barrier()
                    if const_expr("nobar" not in DG):
                        if wm == fx.Int32(1):
                            gpu.barrier()
                    IL = "il" in DG  # DMA issue interleaved into the MFMA phase
                    for s in range_constexpr(KS):
                        dma_now = s + NSTG - 1 < KS and "nodma" not in DG
                        # RF: LDS operand reads first, then DMA issue, so the LDS pipe and the
                        # texture/DMA path work concurrently (they touch different ring slots).
                        RF = "dmafirst" not in DG
                        ILM = next((int(t[3:]) for t in DG if t.startswith("ilm")), 2)  # measured best: 2
                        if const_expr(dma_now and not IL and not RF and not ILM):
                            issue(s + NSTG - 1)
                        if const_expr(ILM and dma_now and not IL):
                            # LDS reads and this step's DMA issue interleaved (TA and LDS overlap)
                            a_ops, sa, bl = read_a(s, dmas=dma_ops(s + NSTG - 1), every=ILM)
                            rocdl.asyncmark()
                        else:
                            a_ops, sa, bl = read_a(0 if const_expr("nolds" in DG) else s)
                        b_ops, bs = bl
                        if const_expr(dma_now and not IL and RF and not ILM):
                            issue(s + NSTG - 1)
                        if const_expr(s + 1 < KS and "nodma" not in DG):
                            # IL: this step's DMA has not been issued yet (it goes into the MFMA phase).
                            pend = min(NSTG - 2, KS - 2 - s) - (1 if IL and dma_now else 0)
                            rocdl.wait_asyncmark(max(0, pend))
                        rocdl.sched_barrier(0)
                        if const_expr("nobar" not in DG):
                            gpu.barrier()
                        rocdl.s_setprio(1)
                        ops = dma_ops(s + NSTG - 1) if const_expr(IL and dma_now) else []
                        for rb in range_constexpr(MBW):
                            if const_expr(SKIP):
                                # Row blocks past the tile's valid rows skip their MFMAs
                                # (wave-uniform: nrows and rb0 are SGPR values).
                                acc_rb = acc[rb]
                                if (rb0 + rb) * 16 < nrows:
                                    acc_rb = [hw.mfma_fp4(acc_rb[j], a_ops[rb], b_ops[j], sa[rb], bs, 0, j)
                                              for j in range_constexpr(4)]
                                acc[rb] = acc_rb
                            else:
                                for j in range_constexpr(4):
                                    acc[rb][j] = hw.mfma_fp4(acc[rb][j], a_ops[rb], b_ops[j], sa[rb], bs, 0, j)
                            if const_expr(IL and rb < len(ops)):
                                rocdl.sched_barrier(0)
                                ops[rb]()
                                rocdl.sched_barrier(0)
                        if const_expr(IL and dma_now):
                            for k2 in range_constexpr(MBW, len(ops)):
                                ops[k2]()
                            rocdl.asyncmark()
                        rocdl.s_setprio(0)
                        rocdl.sched_barrier(0)
                        if const_expr("nobar" not in DG):
                            gpu.barrier()
                    if const_expr("nobar" not in DG):
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
                    a_voff.append(a_row_of(row) * (64 if HTA else KH) + lc * 16)
                    a_lds.append(row * 64 + ((lc * 16) ^ _swz(row, SWZ)))
                as_voff = []
                for rb in range_constexpr(MB):
                    if const_expr(AST):
                        as_voff.append(as_off(fx.Int32(rb * 16) + l16) + lg)
                    else:
                        as_voff.append(a_row_of(fx.Int32(rb * 16) + l16) * KG + lg)

                def issue_r(s):
                    a = [hw.bload(r_a, a_voff[i], T.i32x4, soff=a_soff(s)) for i in range_constexpr(A_CH)]
                    b = [hw.bload(r_b, b_voff[j], T.i32x4, soff=s * 1024, cm=b_cm)
                         for j in range_constexpr(4)]
                    bs = hw.bload(r_bs, bs_voff, T.i32, soff=s * BS_STEP, cm=b_cm)
                    sa = [fx.Int32(fx.Uint8(hw.bload(r_as, as_voff[rb], T.i8,
                                                     soff=(n_rows * (s * 4)) if const_expr(AST) else s * 4)))
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
                if const_expr(HTW):
                    gpu.barrier()  # all waves done with the LDS ring
                    hwb = wave * (max(ROWS_W, 64) * 16)
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
                                # gate <= limit bounds the exp2 argument from below; a very negative gate
                                # gives exp2 -> inf, rcp -> 0, silu -> gg * 0 = 0 (finite inputs only)
                                sig = hw.fast_rcp(fx.Float32(1.0) + hw.exp2_raw(gg * fx.Float32(NEG_ALPHA_LOG2E)))
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
                        soff_ok = valid & (l16 == fx.Int32(0))
                        if const_expr(HTW):
                            # stage h bytes per wave in LDS (rows x 16 B), stored below as 16 B rows
                            rl = fx.Int32(rb * 16) + lg * 4 + v
                            hw.lds_store(fx.Int32(pk).to(fx.Int8), lds_base, hwb + rl * 16 + l16, align=1)
                            hs_off = ((g // 4) * n_rows + grow) * 4 + (g % 4)
                        else:
                            off = valid.select(grow * (INTER // 2) + g * 16 + l16, fx.Int32(0x7FFFFFF0))
                            hw.bstore(fx.Int32(pk).to(fx.Int8), r_o, off)
                            hs_off = grow * (INTER // 32) + g
                        soff = soff_ok.select(hs_off, fx.Int32(0x7FFFFFF0))
                        hw.bstore(bexp.to(fx.Int8), r_os, soff)
                if const_expr(HTW):
                    # h_t[g//4][row][64 B]: this wave's 16 B column group of each row
                    for it in range_constexpr((ROWS_W + 63) // 64):
                        rl = fx.Int32(it * 64) + lane
                        v16 = hw.lds_load(lds_base, hwb + rl * 16, T.i32x4)
                        row = rb0 * 16 + rl
                        off = ((g // 4) * n_rows + row_start + row) * 64 + (g % 4) * 16
                        ok = (row < nrows) & (rl < fx.Int32(ROWS_W))
                        hw.bstore(v16, r_o, ok.select(off, fx.Int32(0x7FFFFFF0)))
            else:
                # W2 columns are even/odd interleaved per 32: tiles (0,1) and (2,3) of
                # this wave give each lane output columns (gb + 2c, gb + 2c + 1).
                r_w = hw.rsrc(rw_ptr, fx.Int64(n_rows) * fx.Int64(4))
                if const_expr(epi == "f32atomic"):
                    r_o = hw.rsrc(o_ptr, fx.Int64(n_out) * fx.Int64(N * 4))
                elif const_expr(epi == "bf16atomic"):
                    r_o = hw.rsrc(o_ptr, fx.Int64(n_out) * fx.Int64(N * 2))
                else:
                    # Per-tile 64-bit base: offsets stay < BM*N*2 and rows past nrows fall
                    # outside the descriptor (dropped), for any number of rows.
                    # 64-bit per-tile base (no 32-bit offset overflow for any R). The record
                    # count spans all remaining rows: a tile-sized count measured ~30% slower.
                    r_o = hw.rsrc(fx.Int64(o_ptr) + fx.Int64(row_start) * fx.Int64(N * 2),
                                  fx.Int64(n_rows - row_start) * fx.Int64(N * 2))
                col0 = nblk * BN + wn * 64 + l16 * 2
                if const_expr(S2W):
                    gpu.barrier()  # every wave is done reading the LDS ring
                    wb = wave * (ROWS_W * 128)
                    for rb in range_constexpr(MBW):
                        vs = [fx.Vector(acc[rb][j]) for j in range_constexpr(4)]
                        r4 = rb0 * 16 + fx.Int32(rb * 16) + lg * 4
                        wv = fx.Vector(hw.bload(r_w, (row_start + r4) * 4, T.vec(4, T.f32)))
                        for v in range_constexpr(4):
                            rl = fx.Int32(rb * 16) + lg * 4 + v  # wave-local row
                            w = fx.Float32(wv[v])
                            for p in range_constexpr(2):
                                pk = fx.Vector.from_elements(
                                    [fx.Float32(vs[2 * p][v]) * w, fx.Float32(vs[2 * p + 1][v]) * w],
                                    fx.Float32).to(fx.BFloat16)
                                ch = (fx.Int32(p * 4) + l16 // 4) ^ (rl & 7)
                                hw.lds_store(pk, lds_base, wb + rl * 128 + ch * 16 + (l16 % 4) * 4, align=4)
                    cm_o = hw.NT if const_expr(S2NT) else 0
                    if const_expr(epi == "fused"):
                        # Shared-expert tile: out[t] = own row + the token's routed rows
                        # (y_rows, via inv), summed in fp32; no combine pass, no shared y rows.
                        r_inv = hw.rsrc(aux_ptr, fx.Int64(n_rows) * fx.Int64(4))
                        r_out = hw.rsrc(os_ptr, fx.Int64(n_out) * fx.Int64(N * 2))
                    for it in range_constexpr(ROWS_W // 8):
                        rl = fx.Int32(it * 8) + lane // 8
                        ch = lane % 8
                        v16 = hw.lds_load(lds_base, wb + rl * 128 + ((ch ^ (rl & 7)) * 16), T.i32x4)
                        row = rb0 * 16 + rl
                        colb = (nblk * BN + wn * 64) * 2 + ch * 16
                        if const_expr(epi == "fused"):
                            # Bad token / row ids (FC invariant broken) stay in bounds: the out
                            # store is buffer-checked and routed rows are clamped into y_rows.
                            if row < nrows:
                                grow = row_start + row
                                t = fx.Int32(hw.bload(r_tok, grow * 4, T.i32))
                                accv = fx.Vector(v16).bitcast(fx.BFloat16).to(fx.Float32)
                                for sl in range_constexpr(KTOP):
                                    rs = fx.Int32(hw.bload(r_inv, (t * KTOP + sl) * 4, T.i32))
                                    rs = fx.max(fx.min(rs, n_rows - 1), fx.Int32(0))
                                    other = rs != grow
                                    src = other.select(rs, grow)
                                    yv = fx.Vector(hw.gload(fx.Int64(o_ptr) + fx.Int64(src) * fx.Int64(N * 2)
                                                            + fx.Int64(colb), T.vec(8, T.bf16))).to(fx.Float32)
                                    zero8 = fx.Vector.filled(8, 0.0, fx.Float32)
                                    accv = accv + other.select(yv, zero8)
                                hw.bstore(accv.to(fx.BFloat16), r_out, t * (N * 2) + colb)
                        else:
                            off = row * (N * 2) + colb
                            hw.bstore(v16, r_o, (row < nrows).select(off, fx.Int32(0x7FFFFF00)), cm=cm_o)
                for rb in range_constexpr(MBW if not S2W else 0):
                    vs = [fx.Vector(acc[rb][j]) for j in range_constexpr(4)]
                    for v in range_constexpr(4):
                        row = rb0 * 16 + fx.Int32(rb * 16) + lg * 4 + v
                        valid = row < nrows
                        grow = row_start + row
                        w = fx.Float32(hw.bload(r_w, grow * 4, T.f32))
                        if const_expr(epi == "rows"):
                            dst_row = row
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

        # CTAs are dealt round-robin over the 8 XCDs; each XCD gets a contiguous range of
        # work so an expert's m-tiles share one L2.
        xq = bound // 8
        xr = bound % 8
        xc = bid % 8
        xstart = xc * xq + fx.min(xc, xr)
        if const_expr(PERS):
            # Persistent: grid = CUs * PERS CTAs; CTA c walks its XCD's range with stride
            # (CTAs per XCD).
            gx = fx.Int32(gpu.grid_dim.x) // 8
            wend = xstart + xq + (xc < xr).select(fx.Int32(1), fx.Int32(0))
            for w in range(xstart + bid // 8, wend, gx):
                _tile_body(fx.Int32(w))
        else:
            work0 = (xstart + bid // 8) if const_expr(xcd_remap) else bid
            if bid < bound:
                _tile_body(work0)

    @flyc.jit
    def launch(
        a_ptr: fx.Int64, as_ptr: fx.Int64, b_ptr: fx.Int64, bs_ptr: fx.Int64,
        tiles_ptr: fx.Int64, ntiles_ptr: fx.Int64, rtok_ptr: fx.Int64, rw_ptr: fx.Int64,
        o_ptr: fx.Int64, os_ptr: fx.Int64, aux_ptr: fx.Int64,
        n_a_rows: fx.Int32, n_rows: fx.Int32, n_out: fx.Int32, grid: fx.Int32,
        stream: fx.Stream = fx.Stream(None),
    ):
        kern(a_ptr, as_ptr, b_ptr, bs_ptr, tiles_ptr, ntiles_ptr, rtok_ptr, rw_ptr,
             o_ptr, os_ptr, aux_ptr, n_a_rows, n_rows, n_out).launch(
            grid=(grid, 1, 1), block=(THREADS, 1, 1), stream=stream)

    if MV:
        # MV=1: no AGPRs at all (amdgpu-agpr-alloc=0) -> MFMA accumulators in arch VGPRs,
        #       no AGPR<->VGPR copies; MV=2: same + waves_per_eu=2.
        launch.compile_hints = {"fn_attrs": {"amdgpu-agpr-alloc": "0"}}
        if MV == 2:
            launch.compile_hints["waves_per_eu"] = 2
    wpe = [int(t[3:]) for t in DG if t.startswith("wpe") and t[3:].isdigit()]
    if wpe:
        # diag=wpeN: cap registers so N waves/SIMD fit (e.g. wpe3: <= 168 VGPRs).
        launch.compile_hints = dict(getattr(launch, "compile_hints", None) or {}, waves_per_eu=wpe[0])
    launch.persistent = PERS
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
             pipe="async", NW=4, GM=1, diag="", WM=1, EF=False, MV=0, AST=False, HT=False, KTOP=5,
             PERS=0, stream=None):
    import torch

    key = (stage, K, N, BM, D, b_nt, epi, xcd_remap, pipe, NW, GM, diag, WM, EF, MV, AST, HT, KTOP, PERS)
    if key not in _runners:
        launch, nb = build_gemm(stage, K, N, BM, D, b_nt, epi, xcd_remap, pipe, NW, GM, diag, WM, EF, MV,
                                AST, HT, KTOP, PERS)
        _runners[key] = (_Runner(launch), nb)
    r, nb = _runners[key]
    stream = torch.cuda.current_stream() if stream is None else stream
    grid = NUM_CUS * PERS if PERS else max_tiles * nb
    r(*args, grid, stream)
