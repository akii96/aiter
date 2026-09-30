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


def _il4_plan(n_dma, has_next, mbw, bar, dsp=0):
    """il4 issue plan for one K step: per MFMA slot (MFMA i = half i // 32, row block
    (i % 32) // 4, tile 4 * half + i % 4), the (kind, index) ops issued after that MFMA.
      own: this step's B scale / B tiles 4-7 (5 reads, slots 0-4)
      bar: DMA wait + barrier (slot `bar`); d: next DMAs, one every `dsp` slots after the
           barrier (0: spread over the rest of the step; bursts fill the TA queue and stall
           issue, measured ~300 cycles per DMA at 2 slots)
      nb:  next step's B scale / B tiles 0-3 (5 reads, after slot 31, their last use)
      na:  next step's A row block rb + its scale (after slot 35 + 4 rb, its last use)"""
    slots = [[] for _ in range(32 * 2)]
    for k in range(5):
        slots[k].append(("own", k))
    if has_next:
        slots[bar].append(("bar", 0))
    step = dsp or max(1, (63 - bar) // max(n_dma, 1))
    for k in range(n_dma):
        slots[min(bar + 1 + step * k, 63)].append(("d", k))
    if has_next:
        for k in range(5):
            slots[31 + k].append(("nb", k))
        for rb in range(mbw):
            slots[35 + 4 * rb].append(("na", rb))
    return slots


@functools.lru_cache(maxsize=None)
def build_gemm(stage: int, K: int, N: int, BM: int, D: int = 3, b_nt: bool = False,
               epi: str = "rows", xcd_remap: bool = True, pipe: str = "async", NW: int = 4,
               GM: int = 1, diag: str = "", WM: int = 1, EF: bool = False, MV: int = 0, AST: bool = False,
               HT: bool = False, KTOP: int = 5, PERS: int = 0,
               alpha: float = 1.702, limit: float = 7.0):
    assert stage in (1, 2)
    assert epi in ("rows", "f32atomic", "bf16atomic", "fused")
    assert epi != "fused" or stage == 2
    assert pipe in ("async", "regs", "hybrid", "hybrid2", "async2", "pingpong", "il4")
    assert NW in (1, 2, 4, 8) and WM in (1, 2, 4) and NW % WM == 0
    WN = NW // WM  # waves along N; WM wave-rows share each B slice through LDS
    # il4: one wave per SIMD owning 128 output columns (two 64-column groups, 8 n16 tiles)
    CG = 2 if pipe == "il4" else 1
    TWN = 4 * CG  # n16 tiles per wave
    BN = 64 * WN * CG
    THREADS = 64 * NW
    assert K % 128 == 0 and N % BN == 0 and BM % (16 * WM) == 0
    assert WM == 1 or pipe in ("async", "async2", "pingpong", "il4"), "WM > 1 needs B staged in LDS"
    assert pipe != "pingpong" or WM == 2, "pingpong alternates the two wave-rows (WM=2)"
    assert pipe != "il4" or (NW == 4 and stage == 1 and not HT and AST and BM == 256 and WM == 2), \
        "il4: 4 waves as 2x2 (256x256 CTA), stage 1, step-major A scales, non-HT h"
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
    if pipe in ("async", "hybrid", "hybrid2", "async2", "pingpong", "il4"):
        prefetch = pipe in ("hybrid2", "async2")
        NSTG = max(3 if pipe in ("hybrid2", "async2", "pingpong", "il4") else 2, min(D, KS + 1))
        DB = min(D, KS) if pipe in ("hybrid", "hybrid2") else min(3, KS)
        b_lds = pipe in ("async", "async2", "pingpong", "il4")
        # LDS is laid out per buffer kind across ring slots ([A x NSTG][B x NSTG][BS][AS]) so
        # every LDS read is (one hoisted base VGPR per kind) + an immediate offset < 64 KB:
        # no per-read address VALU, which would queue behind the partner wave's MFMAs.
        SA = BM * 64
        SB = WN * CG * 4096 if b_lds else 0
        SBS = WN * CG * 256 if b_lds else 0
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
    IL4_BAR = next((int(t[3:]) for t in DG if t.startswith("bar") and t[3:].isdigit()), 5)
    IL4_DSP = next((int(t[3:]) for t in DG if t.startswith("dsp") and t[3:].isdigit()), 0)
    IL4_ASM = pipe == "il4" and "noasm" not in DG
    SE = "se" in DG  # "even" e8m0 scale rule (checkpoint / runtime quant), else ceil_pow2(amax/6)
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
    # S1S: stage-1 non-HT epilogue staged per wave in a private LDS region past the ring (no
    # barrier): ROWS_W rows x CG*16 B of h, then ROWS_W x CG scale bytes; written back as
    # 16 B/lane h rows and CG-byte scale runs instead of one global byte store per value.
    S1S = stage == 1 and not HT and pipe == "il4" and "nos1s" not in DG
    assert not S1S or CG == 2
    S1S_H = ROWS_W * CG * 16
    S1S_W = S1S_H + ROWS_W * CG
    S1S_BASE = lds_bytes
    IL4P = bool(PERS) and pipe == "il4" and "nopro" not in DG
    if S1S:
        lds_bytes = S1S_BASE + NW * S1S_W
        assert lds_bytes <= 160 * 1024, lds_bytes

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
        lds_base = fx.Int32(
            fx.ptrtoint(fx.SharedAllocator().allocate(SharedStorage).peek().raw.ptr)
        )
        n_rows_k, n_a_rows_k, lane_k, wave_k = n_rows, n_a_rows, lane, wave

        def _decode(work):
            if const_expr(GM == 1):
                return work // NB, work % NB
            # Groups of GM m-tiles sweep the N blocks together, so concurrently
            # running CTAs share a few weight column slices (L2 reuse).
            grp = work // (GM * NB)
            within = work % (GM * NB)
            gsize = fx.min(ntiles - grp * GM, fx.Int32(GM))
            return grp * GM + within % gsize, within // gsize

        def _tile_body(work, mode="full", nxt=None, st=None, defer=False):
            # IL4P modes: "pro" = setup + prologue DMAs only; "main" = the tile with its
            # prologue already in flight, issuing tile `nxt`'s prologue before its epilogue.
            # st = [e, row_start, nrows, raw token of each A DMA row]: a tile's loaded state,
            # carried across the tile loop so no body waits on its own tile / token loads.
            # Returns the state of the tile it set up ("pro") or of tile `nxt` ("main").
            # Per-tile opaque copies: LICM would otherwise hoist every n_rows-derived
            # per-step scale offset out of the tile loop and spill them.
            n_rows = hw.s_opaque(n_rows_k, work) if const_expr(IL4P) else n_rows_k
            n_a_rows = hw.s_opaque(n_a_rows_k, work) if const_expr(IL4P) else n_a_rows_k
            lane = hw.v_opaque(lane_k, work) if const_expr(IL4P) else lane_k
            wave = hw.s_opaque(wave_k, work) if const_expr(IL4P) else wave_k
            wm, wn = wave // WN, wave % WN
            if const_expr(PERS and mode == "full"):
                gpu.barrier()  # previous tile's LDS use is finished before the ring refills
            tile, nblk = _decode(work)
            r_tiles = hw.rsrc(tiles_ptr)
            if const_expr(st is None):
                tv = fx.Vector(hw.bload(r_tiles, tile * 16, T.i32x4))
                e = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tv[0])))
                row_start = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tv[1])))
                nrows = fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tv[2])))
                toks = None
            else:
                e, row_start, nrows = st[0], st[1], st[2]
                toks = st[3:]
            st_out = None
            pro_ops = []

            r_a = hw.rsrc(a_ptr, fx.Int64(n_a_rows) * fx.Int64(KH))
            r_as = hw.rsrc(as_ptr, fx.Int64(n_rows if const_expr(AST) else n_a_rows) * fx.Int64(KG))
            r_tok = hw.rsrc(rtok_ptr, fx.Int64(n_rows) * fx.Int64(4))
            b_exp = fx.Int64(N // 16) * fx.Int64(KS * 1024)
            bs_exp = fx.Int64(N // 64) * fx.Int64(KS * 256)
            r_b = hw.rsrc(fx.Int64(b_ptr) + fx.Int64(e) * b_exp, b_exp)
            r_bs = hw.rsrc(fx.Int64(bs_ptr) + fx.Int64(e) * bs_exp, bs_exp)

            def a_row_of(row, it=None):
                valid = row < nrows
                if const_expr(toks is not None and it is not None):
                    t = toks[it]
                elif const_expr(stage == 1):
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
            b4_voff = (nblk * (WN * TWN) + wave) * (KS * 1024) + lane * 16
            bs4_voff = (nblk * (WN * CG) + wave) * 256 + lane * 4
            # One 16 B/lane DMA covers the CTA's 4 B-scale blocks (1 KB) for a step.
            BS1 = WN == 4 and stage == 1
            bs16_voff = (nblk * WN) * 256 + lane * 16
            bs_wave = 1 if NW <= 4 else 4  # the wave issuing the B-scale DMA
            rb0 = wm * MBW  # first row block owned by this wave
            zero = hw.raw(fx.Vector.filled(4, 0.0, fx.Float32))
            acc = [[zero] * TWN for _ in range(MBW)]

            if const_expr(pipe != "regs"):
                # Physical 16 B chunk pc of LDS row r holds logical chunk pc ^ swz(r).
                pc = lane % 4
                a_dma_voff = []
                if const_expr(IL4P and toks is None):
                    toks = [fx.Int32(hw.bload(r_tok, (row_start + (wave + it * NW) * 16 + lane // 4) * 4, T.i32))
                            for it in range_constexpr(A_IT)]
                    st_out = [e, row_start, nrows] + toks
                for it in range_constexpr(A_IT):
                    row = (wave + it * NW) * 16 + lane // 4
                    a_dma_voff.append(a_row_of(row, it) * (64 if HTA else KH) + ((pc * 16) ^ _swz(row, SWZ)))
                as_uni_voff = as_off(wn * 64 + lane)
                as4_voff = as_off(wave * (BM // NW) + lane)
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
                    if const_expr(pipe == "il4"):
                        # Branch-free: every wave issues the same DMA mix. B: WN*TWN 1 KB tiles
                        # dealt round-robin; B scales: WN*CG 256 B blocks (4 B/lane); A scales:
                        # BM/NW rows of 4 B per wave (4 B/lane).
                        for q in range_constexpr((WN * TWN) // NW):
                            ops.append(lambda q=q: hw.dma_async(
                                r_b, lds_base, wave * 1024 + (oB + q * NW * 1024),
                                b4_voff + (q * NW) * (KS * 1024), soff=s * 1024, cm=b_cm))
                        for q in range_constexpr((WN * CG) // NW):
                            ops.append(lambda q=q: hw.dma_async(
                                r_bs, lds_base, wave * 256 + (oBS + q * NW * 256), bs4_voff + (q * NW) * 256,
                                soff=s * BS_STEP, nbytes=4, cm=b_cm))
                        ops.append(lambda: hw.dma_async(r_as, lds_base, wave * 256 + oAS, as4_voff,
                                                        soff=n_rows * (s * 4), nbytes=4))
                        return ops
                    elif const_expr(b_lds and "nodmaB" not in DG):
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
                if const_expr(mode == "pro" and defer):
                    # (issue order) the prologue's DMAs + asyncmarks, for the caller to spread
                    thunks = []
                    for p in range_constexpr(min(NSTG, KS)):
                        thunks += dma_ops(p) + [rocdl.asyncmark]
                    return thunks
                for p in range_constexpr(min(NSTG if pipe == "il4" else NSTG - 1, KS) if mode != "main" else 0):
                    issue(p)
                if const_expr(mode == "pro"):
                    return st_out

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

                if const_expr(pipe == "il4"):
                    # One wave per SIMD, 128x128 per wave, no operand double buffer. A step is
                    # two halves: half h runs every row block against B tiles 4h..4h+3, so B
                    # tiles 0-3 of step s+1 load during half 1 of step s, tiles 4-7 of step s
                    # at the start of step s (used from half 1), and each A row block reloads
                    # right after its last use. Mid-step barrier: step s+1 has landed and step
                    # s's slot is no longer read, so step s+NSTG's DMAs refill it right away.
                    b_rd4 = lane * 16 + wn * (TWN * 1024) + RB
                    bs_rd4 = lane * 4 + wn * (CG * 256) + RBS
                    a_rd4 = a_rd + rb0 * 1024

                    def offs(s):
                        slot = s % NSTG
                        return slot * SA, slot * SB, slot * SBS, slot * SAS

                    def rd_bh(s, h):
                        oA, oB, oBS, oAS = offs(s)
                        return ([lambda: hw.lds_load(lds_base, bs_rd4 + (oBS + h * 256), T.i32, align=4)]
                                + [lambda j=j: hw.lds_load(lds_base, b_rd4 + (oB + (4 * h + j) * 1024), T.i32x4)
                                   for j in range_constexpr(4)])

                    def rd_a(s, rb):
                        oA, oB, oBS, oAS = offs(s)
                        return [lambda: hw.lds_load(lds_base, a_rd4 + (oA + rb * 1024), T.i32x4),
                                lambda: hw.lds_load_u8(lds_base, as_rd + (oAS + rb * 64))]

                    rocdl.wait_asyncmark(max(0, min(NSTG, KS) - 1))
                    gpu.barrier()
                    v = [f() for f in rd_bh(0, 0)]
                    bsv = [v[0], None]
                    b_ops = v[1:] + [None] * 4
                    a_ops, sa = [None] * MBW, [None] * MBW
                    for rb in range_constexpr(MBW):
                        a_ops[rb], sa[rb] = [f() for f in rd_a(0, rb)]
                    NMF = MBW * TWN
                    if const_expr(mode == "main"):
                        # Tile `nxt`'s state loads, long before its prologue needs them.
                        tvn = fx.Vector(hw.bload(r_tiles, _decode(nxt)[0] * 16, T.i32x4))
                    for s in range_constexpr(KS):
                        has_next = s + 1 < KS
                        dms = dma_ops(s + NSTG) if const_expr(s + NSTG < KS) else []
                        plan = _il4_plan(len(dms), has_next, MBW, IL4_BAR, IL4_DSP)
                        own = rd_bh(s, 1)
                        nb0 = rd_bh(s + 1, 0) if const_expr(has_next) else []
                        nxt_b, nxt_bs = [None] * 4, None
                        nxt_a, nxt_sa = [None] * MBW, [None] * MBW
                        for i in range_constexpr(NMF):
                            h, rb, j = i // 32, (i % 32) // 4, i % 4
                            t = 4 * h + j
                            if const_expr(IL4_ASM):
                                acc[rb][t] = hw.mfma_fp4_agpr(acc[rb][t] if const_expr(s > 0) else None,
                                                              a_ops[rb], b_ops[t], sa[rb], bsv[h], j)
                            else:
                                acc[rb][t] = hw.mfma_fp4(acc[rb][t], a_ops[rb], b_ops[t], sa[rb], bsv[h], 0, j)
                            if const_expr(mode == "main" and s == KS // 2 and i == 16):
                                rocdl.sched_barrier(0)
                                e_n, rs_n, nr_n = [fx.Int32(rocdl.readfirstlane(T.i32, hw.raw(tvn[q])))
                                                   for q in range_constexpr(3)]
                                st_out = [e_n, rs_n, nr_n] + [
                                    fx.Int32(hw.bload(r_tok, (rs_n + (wave + it * NW) * 16 + lane // 4) * 4, T.i32))
                                    for it in range_constexpr(A_IT)]
                                rocdl.sched_barrier(0)
                            for k2 in range_constexpr(len(plan[i])):
                                kind, idx = plan[i][k2]
                                rocdl.sched_barrier(0)
                                if const_expr(kind == "own"):
                                    val = own[idx]()
                                    if const_expr(idx == 0):
                                        bsv[1] = val
                                    else:
                                        b_ops[4 + idx - 1] = val
                                elif const_expr(kind == "bar"):
                                    last = min(s - 1 + NSTG, KS - 1)
                                    rocdl.wait_asyncmark(max(0, last - (s + 1)))
                                    gpu.barrier()
                                elif const_expr(kind == "d"):
                                    dms[idx]()
                                    if const_expr(idx == len(dms) - 1):
                                        rocdl.asyncmark()
                                elif const_expr(kind == "nb"):
                                    val = nb0[idx]()
                                    if const_expr(idx == 0):
                                        nxt_bs = val
                                    else:
                                        nxt_b[idx - 1] = val
                                else:
                                    nxt_a[idx], nxt_sa[idx] = [f() for f in rd_a(s + 1, idx)]
                                rocdl.sched_barrier(0)
                        if const_expr(has_next):
                            bsv = [nxt_bs, None]
                            b_ops = nxt_b + [None] * 4
                            a_ops, sa = nxt_a, nxt_sa
                    if const_expr(IL4_ASM):
                        rocdl.sched_barrier(0)
                        fenced = hw.mfma_drain([acc[rb][t] for rb in range_constexpr(MBW) for t in range_constexpr(TWN)])
                        acc = [fenced[rb * TWN:(rb + 1) * TWN] for rb in range_constexpr(MBW)]
                        rocdl.sched_barrier(0)
                    if const_expr(mode == "main"):
                        gpu.barrier()  # every wave is past its last ring read
                        pro_ops = _tile_body(nxt, "pro", st=st_out, defer=True)
                        rocdl.sched_barrier(0)

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
                for s in range_constexpr(KS if not (prefetch or pipe in ("pingpong", "il4")) else 0):
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
                    for j in range_constexpr(TWN):
                        tot = tot + fx.Float32(fx.Vector(acc[rb][j])[0])
                hw.bstore(tot, hw.rsrc(o_ptr, 4), fx.Int32(0) * tid)
            elif const_expr(stage == 1):
                r_o = hw.rsrc(o_ptr, fx.Int64(n_rows) * fx.Int64(INTER // 2))
                if const_expr(HTW):
                    gpu.barrier()  # all waves done with the LDS ring
                    hwb = wave * (max(ROWS_W, 64) * 16)
                r_os = hw.rsrc(os_ptr, fx.Int64(n_rows) * fx.Int64(INTER // 32))
                lim = fx.Float32(limit)

                def swiglu(gv, uv):
                    gg = fx.min(fx.Float32(gv), lim)
                    uu = fx.max(fx.min(fx.Float32(uv), lim), -lim)
                    if const_expr(EF):
                        sig = hw.fast_rcp(fx.Float32(1.0) + hw.exp2_raw(gg * fx.Float32(NEG_ALPHA_LOG2E)))
                    else:
                        sig = fx.Float32(1.0) / (fx.Float32(1.0) + fmath.exp(gg * fx.Float32(-alpha)))
                    return gg * sig * (uu + fx.Float32(1.0))

                def swiglu2(g0, g1, u0, u1):
                    """swiglu of an (even, odd) pair: same operations and order, the
                    elementwise mul/add as packed v_pk_*_f32. EF only."""
                    gg = fx.Vector.from_elements([fx.min(fx.Float32(g0), lim), fx.min(fx.Float32(g1), lim)],
                                                 fx.Float32)
                    uu = fx.Vector.from_elements([hw.fmed3(u0, -lim, lim), hw.fmed3(u1, -lim, lim)], fx.Float32)
                    t = gg * fx.Vector.filled(2, NEG_ALPHA_LOG2E, fx.Float32)
                    den = fx.Vector.from_elements([hw.exp2_raw(t[0]), hw.exp2_raw(t[1])], fx.Float32) \
                        + fx.Vector.filled(2, 1.0, fx.Float32)
                    sig = fx.Vector.from_elements([hw.fast_rcp(den[0]), hw.fast_rcp(den[1])], fx.Float32)
                    h = gg * sig * (uu + fx.Vector.filled(2, 1.0, fx.Float32))
                    return fx.Float32(h[0]), fx.Float32(h[1])

                PK = EF and "nopk" not in DG
                for rb in range_constexpr(MBW if S1S else 0):
                    # All CG*4 (group, row) chains of a row block at once: the DPP row-max
                    # levels interleave across chains instead of stalling on DPP hazards.
                    per = -(-len(pro_ops) // MBW)
                    for op in pro_ops[rb * per:(rb + 1) * per]:
                        rocdl.sched_barrier(0)
                        op()
                        rocdl.sched_barrier(0)
                    sw = S1S_BASE + wave * S1S_W
                    ch = []
                    for gi in range_constexpr(CG):
                        vg_e = fx.Vector(acc[rb][4 * gi + 0])
                        vg_o = fx.Vector(acc[rb][4 * gi + 1])
                        vu_e = fx.Vector(acc[rb][4 * gi + 2])
                        vu_o = fx.Vector(acc[rb][4 * gi + 3])
                        for v in range_constexpr(4):
                            if const_expr(PK):
                                ch.append((gi, v) + swiglu2(vg_e[v], vg_o[v], vu_e[v], vu_o[v]))
                            else:
                                ch.append((gi, v, swiglu(vg_e[v], vu_e[v]), swiglu(vg_o[v], vu_o[v])))
                    ms = [fx.max(fmath.absf(h0), fmath.absf(h1)) for _, _, h0, h1 in ch]
                    if const_expr(EF):
                        ms = hw.row16_max_nonneg_f32_multi(ms)
                    else:
                        for k in range_constexpr(len(ms)):
                            for off in (1, 2, 4, 8):
                                ms[k] = fx.max(ms[k], ms[k].shuffle_xor(fx.Int32(off), fx.Int32(64)))
                    bx = {}
                    for k in range_constexpr(len(ch)):
                        gi, v, h0, h1 = ch[k]
                        if const_expr(SE):
                            # |h| <= limit * (limit + 1): the bounded form is exact
                            bexp = hw.e8m0_even_small(ms[k])
                        else:
                            bits = (ms[k] * fx.Float32(1.0 / 6.0)).bitcast(fx.Int32)
                            bexp = fx.min(((bits + fx.Int32(0x7FFFFF)).shrui(fx.Int32(23))) & fx.Int32(0xFF),
                                          fx.Int32(254))
                        qs = (bexp << fx.Int32(23)).bitcast(fx.Float32)
                        pk = rocdl.cvt_scalef32_pk_fp4_f32(
                            T.i32, hw.raw(fx.Int32(0)), hw.raw(h0), hw.raw(h1), hw.raw(qs), 0)
                        rl = fx.Int32(rb * 16) + lg * 4 + v
                        hw.lds_store(fx.Int32(pk).to(fx.Int8), lds_base, sw + rl * (CG * 16) + (gi * 16) + l16,
                                     align=1)
                        bx[(v, gi)] = bexp
                    # The row block's scales for this lane's 4 rows x CG groups are 8 contiguous
                    # bytes (row-major, CG == 2): one 8 B write. The 16 lanes of a row group
                    # write the same bytes to the same address.
                    sd = [bx[(2 * q, 0)] | (bx[(2 * q, 1)] << fx.Int32(8)) | (bx[(2 * q + 1, 0)] << fx.Int32(16))
                          | (bx[(2 * q + 1, 1)] << fx.Int32(24)) for q in range_constexpr(2)]
                    hw.lds_store(fx.Vector.from_elements(sd, fx.Int32), lds_base,
                                 sw + S1S_H + (fx.Int32(rb * 16) + lg * 4) * CG, align=8)
                if const_expr(not S1S):
                    for op in pro_ops:
                        op()
                for rbg in range_constexpr(MBW * CG if not S1S else 0):
                    rb, gi = rbg // CG, rbg % CG
                    g = (nblk * WN + wn) * CG + gi
                    vg_e = fx.Vector(acc[rb][4 * gi + 0])
                    vg_o = fx.Vector(acc[rb][4 * gi + 1])
                    vu_e = fx.Vector(acc[rb][4 * gi + 2])
                    vu_o = fx.Vector(acc[rb][4 * gi + 3])
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
                        if const_expr(SE):
                            bexp = hw.e8m0_even(m)
                        else:
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
                if const_expr(S1S):
                    # h[row][g0*16 .. g0*16 + CG*16): CG*16 B per row, 16 B per lane
                    sw = S1S_BASE + wave * S1S_W
                    g0 = (nblk * WN + wn) * CG
                    LPR = CG  # lanes per row
                    for it in range_constexpr((ROWS_W * LPR) // 64):
                        rl = fx.Int32(it * (64 // LPR)) + lane // LPR
                        part = lane % LPR
                        v16 = hw.lds_load(lds_base, sw + rl * (CG * 16) + part * 16, T.i32x4)
                        row = rb0 * 16 + rl
                        off = (row_start + row) * (INTER // 2) + g0 * 16 + part * 16
                        hw.bstore(v16, r_o, (row < nrows).select(off, fx.Int32(0x7FFFFFF0)))
                    # scales: CG bytes per row at h_s[row][g0 .. g0 + CG)
                    for it in range_constexpr((ROWS_W + 63) // 64):
                        rl = fx.Int32(it * 64) + lane
                        row = rb0 * 16 + rl
                        sv = hw.lds_load(lds_base, sw + S1S_H + rl * CG, T.i16, align=2)
                        off = (row_start + row) * (INTER // 32) + g0
                        hw.bstore(sv, r_os, ((row < nrows) & (rl < fx.Int32(ROWS_W))).select(off, fx.Int32(0x7FFFFFF0)))
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
            return st_out

        # CTAs are dealt round-robin over the 8 XCDs; each XCD gets a contiguous range of
        # work so an expert's m-tiles share one L2.
        xq = bound // 8
        xr = bound % 8
        xc = bid % 8
        xstart = xc * xq + fx.min(xc, xr)
        if const_expr(IL4P):
            # Persistent il4: tile w+1's prologue DMAs overlap tile w's epilogue. The next
            # work index is clamped (the last tile re-fetches itself), so nothing branches.
            gx = fx.Int32(gpu.grid_dim.x) // 8
            wend = xstart + xq + (xc < xr).select(fx.Int32(1), fx.Int32(0))
            first = xstart + bid // 8
            st = _tile_body(fx.max(fx.min(first, bound - 1), fx.Int32(0)), "pro")
            for w in range(first, wend, gx):
                st = _tile_body(fx.Int32(w), "main", fx.min(fx.Int32(w) + gx, wend - 1), st)
            rocdl.wait_asyncmark(0)
        elif const_expr(PERS):
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
