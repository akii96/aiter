"""Grouped A4W4 GEMM for the MoE, both stages, one kernel template.

Work unit: a tile (expert, row_start, nrows) of the compact, expert-sorted row
array (exactly T*topk rows, never padded to BM) times a 256-column N block.

CTA = 4 waves. Wave w owns 64 output columns (4 MFMA n16 tiles); all waves
share the BM-row A tile staged in LDS. B (weights) streams straight from HBM
into registers in the MFMA lane layout, D steps ahead of use.

stage 1: A = quantized hidden rows gathered by token, epilogue = SwiGLU-OAI +
         fp4 requant of h, written in compact row order ([R, I/2] + [R, I/32]).
stage 2: A = h rows (identity), epilogue = topk-weighted fp32 atomic add into
         out32[T, H].
"""

import functools

import flydsl.compiler as flyc
import flydsl.expr as fx
from flydsl.expr import const_expr, gpu, range_constexpr, rocdl
from flydsl.expr import math as fmath
from flydsl.expr.typing import T

from . import hw

BN = 256
NWAVES = 4


def _swz(row):
    return ((row >> 2) & 3) * 16


@functools.lru_cache(maxsize=None)
def build_gemm(stage: int, K: int, N: int, BM: int, D: int = 3, b_nt: bool = False,
               alpha: float = 1.702, limit: float = 7.0):
    assert stage in (1, 2)
    assert K % 128 == 0 and N % BN == 0 and BM % 64 == 0
    KS = K // 128
    MB = BM // 16
    NB = N // BN
    A_CH = BM // 64
    KH = K // 2
    KG = K // 32
    SLOT = BM * 64
    INTER = N // 2
    D = max(1, min(D, KS))
    b_cm = hw.NT if b_nt else 0
    name = f"flymoe_s{stage}_k{K}_n{N}_bm{BM}_d{D}{'_nt' if b_nt else ''}"

    @fx.struct
    class SharedStorage:
        raw: fx.Array[fx.Uint8, 2 * SLOT, 16]

    @flyc.kernel(name=name, known_block_size=[256, 1, 1])
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
        tile = bid // NB
        nblk = bid % NB

        r_misc = hw.rsrc(ntiles_ptr, 4)
        ntiles = fx.Int32(rocdl.readfirstlane(T.i32, hw.bload(r_misc, 0, T.i32)))
        if tile < ntiles:
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

            # A global->LDS staging: thread owns A_CH 16 B chunks per step.
            lc = tid % 4
            a_voff = []
            a_lds = []
            for i in range_constexpr(A_CH):
                row = fx.Int32(i * 64) + tid // 4
                a_voff.append(a_row_of(row) * KH + lc * 16)
                a_lds.append(row * 64 + ((lc * 16) ^ _swz(row)))

            # MFMA A operand: lane -> (row lane%16, K chunk lane//16).
            l16 = lane % 16
            lg = lane // 16
            a_rd = l16 * 64 + ((lg * 16) ^ _swz(l16))
            as_voff = []
            for rb in range_constexpr(MB):
                as_voff.append(a_row_of(fx.Int32(rb * 16) + l16) * KG)
            as_shift = lg * 8

            b_voff = []
            for j in range_constexpr(4):
                nt = nblk * 16 + wave * 4 + j
                b_voff.append(nt * (KS * 1024) + lane * 16)
            bs_voff = (nblk * 4 + wave) * (KS * 256) + lane * 4

            lds_base = fx.Int32(
                fx.ptrtoint(fx.SharedAllocator().allocate(SharedStorage).peek().raw.ptr)
            )

            def issue(s):
                a = [hw.bload(r_a, a_voff[i], T.i32x4, soff=s * 64) for i in range_constexpr(A_CH)]
                b = [hw.bload(r_b, b_voff[j], T.i32x4, soff=s * 1024, cm=b_cm) for j in range_constexpr(4)]
                bs = hw.bload(r_bs, bs_voff, T.i32, soff=s * 256, cm=b_cm)
                sa = [hw.bload(r_as, as_voff[rb], T.i32, soff=s * 4) for rb in range_constexpr(MB)]
                return a, b, bs, sa

            def stage_a(regs, slot):
                for i in range_constexpr(A_CH):
                    hw.lds_store(regs[i], lds_base, a_lds[i] + slot * SLOT, T.vec(4, T.i32))

            zero = hw.raw(fx.Vector.filled(4, 0.0, fx.Float32))
            acc = [[zero] * 4 for _ in range(MB)]

            inflight = {}
            for s in range_constexpr(D):
                inflight[s] = issue(s)
            stage_a(inflight[0][0], 0)
            gpu.barrier()

            for s in range_constexpr(KS):
                if const_expr(s + D < KS):
                    inflight[s + D] = issue(s + D)
                if const_expr(s + 1 < KS):
                    stage_a(inflight[s + 1][0], (s + 1) % 2)
                _, b, bs, sa = inflight.pop(s)
                slot = s % 2
                for rb in range_constexpr(MB):
                    a_op = hw.lds_load(lds_base, a_rd + (slot * SLOT + rb * 1024), T.i32x4, T.i32)
                    sa_rb = fx.Int32(sa[rb]).shrui(as_shift)
                    for j in range_constexpr(4):
                        acc[rb][j] = hw.mfma_fp4(acc[rb][j], a_op, b[j], sa_rb, bs, 0, j)
                gpu.barrier()

            if const_expr(stage == 1):
                g = nblk * 4 + wave
                r_o = hw.rsrc(o_ptr, fx.Int64(n_rows) * fx.Int64(INTER // 2))
                r_os = hw.rsrc(os_ptr, fx.Int64(n_rows) * fx.Int64(INTER // 32))
                lim = fx.Float32(limit)
                for rb in range_constexpr(MB):
                    vg_e = fx.Vector(acc[rb][0])
                    vg_o = fx.Vector(acc[rb][1])
                    vu_e = fx.Vector(acc[rb][2])
                    vu_o = fx.Vector(acc[rb][3])
                    for v in range_constexpr(4):
                        row = fx.Int32(rb * 16) + lg * 4 + v
                        hs = []
                        for gv, uv in ((vg_e[v], vu_e[v]), (vg_o[v], vu_o[v])):
                            gg = fx.min(fx.Float32(gv), lim)
                            uu = fx.max(fx.min(fx.Float32(uv), lim), -lim)
                            sig = fx.Float32(1.0) / (fx.Float32(1.0) + fmath.exp(gg * fx.Float32(-alpha)))
                            hs.append(gg * sig * (uu + fx.Float32(1.0)))
                        m = fx.max(fmath.absf(hs[0]), fmath.absf(hs[1]))
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
                r_o = hw.rsrc(o_ptr, fx.Int64(n_out) * fx.Int64(N * 4))
                r_w = hw.rsrc(rw_ptr, fx.Int64(n_rows) * fx.Int64(4))
                for rb in range_constexpr(MB):
                    vs = [fx.Vector(acc[rb][j]) for j in range_constexpr(4)]
                    for v in range_constexpr(4):
                        row = fx.Int32(rb * 16) + lg * 4 + v
                        valid = row < nrows
                        grow = row_start + row
                        tok = fx.Int32(hw.bload(r_tok, grow * 4, T.i32))
                        w = fx.Float32(hw.bload(r_w, grow * 4, T.f32))
                        base = tok * (N * 4) + (nblk * BN + wave * 64 + l16) * 4
                        base = valid.select(base, fx.Int32(0x7FFFFF00))
                        for j in range_constexpr(4):
                            hw.batomic_fadd(fx.Float32(vs[j][v]) * w, r_o, base + j * 64)

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
            grid=(grid, 1, 1), block=(256, 1, 1), stream=stream)

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


def run_gemm(stage, K, N, BM, args, max_tiles, D=3, b_nt=False, stream=None):
    import torch

    key = (stage, K, N, BM, D, b_nt)
    if key not in _runners:
        launch, nb = build_gemm(stage, K, N, BM, D, b_nt)
        _runners[key] = (_Runner(launch), nb)
    r, nb = _runners[key]
    stream = torch.cuda.current_stream() if stream is None else stream
    r(*args, max_tiles * nb, stream)
