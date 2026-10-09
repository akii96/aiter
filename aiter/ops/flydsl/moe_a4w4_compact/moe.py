# SPDX-License-Identifier: MIT
# Copyright (C) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""Host-side orchestration: K0 (quant + plan), K1 (stage 1), K2 (stage 2), combine.

Every device step is a FlyDSL kernel; the host only allocates and launches.
"""

import torch

from . import combine, gemm, layout, prologue


class MoEWeights:
    """Packed MiniMax-M3 expert weights for one TP shard (E experts incl. shared)."""

    def __init__(self, w_gate, s_gate, w_up, s_up, w_down, s_down):
        self.E, self.I, hh = w_gate.shape
        self.H = hh * 2
        self.b1, self.bs1 = layout.pack_w13(w_gate, s_gate, w_up, s_up)
        self.b2, self.bs2 = layout.pack_w2(w_down, s_down)


class MoERun:
    """Buffers + launches for one token count T. Call forward() per step.

    Stage configs: BM, D, pipe, NW, diag, WM, EF, MV, PERS (suffix 1 / 2).
    HT: stage 1 writes h K-step-major (h_t [I/128][R][64 B], step-major h scales), so
        stage 2's A and A-scale fetches are contiguous 1 KB DMAs.
    FC: fused combine. The shared expert (E-1, once per token) gets token-ordered rows;
        stage 2 runs routed tiles (y_rows), then shared tiles whose epilogue adds the
        token's routed rows and writes `out` directly. *F: the shared-tile launch config.
    QP: the activation quant runs as extra CTAs of the plan's first launch.
    SR: e8m0 scale rule for the activation and h quant. "even" = the checkpoint's
        scale_calculation_mode (AITER runtime quant); "ceil" = ceil_pow2(amax / 6).
    """

    def __init__(
        self,
        x,
        topk_ids,
        topk_w,
        W: MoEWeights,
        BM1=128,
        BM2=128,
        D1=3,
        D2=2,
        pipe1="async",
        pipe2="hybrid2",
        NW1=4,
        NW2=4,
        diag1="",
        diag2="",
        WM1=1,
        WM2=1,
        EF1=False,
        EF2=False,
        MV1=0,
        MV2=0,
        PERS1=0,
        PERS2=0,
        HT=False,
        FC=False,
        QP=False,
        SR="even",
        validate=True,
        BMF=None,
        NWF=None,
        DF=None,
        pipeF=None,
        diagF=None,
        WMF=None,
    ):
        T, H = x.shape
        k = topk_ids.shape[1]
        assert (
            x.dtype == torch.bfloat16 and x.is_contiguous()
        ), "x must be contiguous bf16"
        assert H == W.H, f"x has H={H}, weights have H={W.H}"
        assert topk_ids.shape == topk_w.shape == (T, k)
        assert SR in ("ceil", "even")
        self.SE = SR == "even"
        if validate:
            # Host sync, construction only. Ids outside [0, E) (e.g. expert-parallel -1) are
            # not supported: the plan kernels clamp them into range rather than drop them.
            assert bool(
                ((topk_ids >= 0) & (topk_ids < W.E)).all()
            ), "expert ids must be in [0, E)"
        R = T * k
        I = W.I
        dev = x.device
        self.x, self.W = x, W
        self.T, self.H, self.I, self.k, self.R = T, H, I, k, R
        self.cfg1 = {
            "BM": BM1,
            "D": D1,
            "pipe": pipe1,
            "NW": NW1,
            "diag": diag1,
            "WM": WM1,
            "EF": EF1,
            "MV": MV1,
            "PERS": PERS1,
        }
        self.cfg2 = {
            "BM": BM2,
            "D": D2,
            "pipe": pipe2,
            "NW": NW2,
            "diag": diag2,
            "WM": WM2,
            "EF": EF2,
            "MV": MV2,
            "PERS": PERS2,
        }
        # Step-major A scales pay off for large stage-1 tiles; at small tiles the extra
        # transpose launch costs more than it saves (measured).
        self.AST = BM1 >= 128
        self.HT = bool(HT)
        # Private copies: the run never aliases (or later writes into) the caller's routing.
        self.ids = torch.empty(R, dtype=torch.int32, device=dev).copy_(
            topk_ids.reshape(-1)
        )
        self.w = torch.empty(R, dtype=torch.float32, device=dev).copy_(
            topk_w.reshape(-1)
        )
        self.a_q = torch.empty(T, H // 2, dtype=torch.uint8, device=dev)
        self.a_s = torch.empty(T, H // 32, dtype=torch.uint8, device=dev)
        self.row_tok = torch.empty(R, dtype=torch.int32, device=dev)
        self.row_w = torch.empty(R, dtype=torch.float32, device=dev)
        self.inv = torch.empty(R, dtype=torch.int32, device=dev)
        self.FC = bool(FC)
        if self.FC:
            assert not validate or bool(
                ((topk_ids == W.E - 1).sum(1) == 1).all()
            ), "FC needs the shared expert (E-1) exactly once per token"
            assert (
                T * H * 2 < 2**31
            ), "the fused epilogue stores out with 32-bit offsets"
            over = {
                "BM": BMF,
                "NW": NWF,
                "D": DF,
                "pipe": pipeF,
                "diag": diagF,
                "WM": WMF,
            }
            cf = dict(
                self.cfg2, PERS=0, **{k_: v for k_, v in over.items() if v is not None}
            )
            self.launches2 = [
                ((BM2, -2), self.cfg2, "rows"),
                ((cf["BM"], -3), cf, "fused"),
            ]
        else:
            self.launches2 = [(BM2, self.cfg2, "rows")]
        specs = [BM1]
        for s, _, _ in self.launches2:
            if s not in specs:
                specs.append(s)
        self.launches1 = [(0, self.cfg1)]
        self.launches2 = [(specs.index(s), c, e) for s, c, e in self.launches2]
        self.bms = tuple(specs)
        self.spec_mt = [prologue.spec_max_tiles(b, R, W.E) for b in specs]
        self.MAXT = max(self.spec_mt)
        self.QP = bool(QP)
        self.tiles = torch.zeros(
            len(specs) * self.MAXT, 4, dtype=torch.int32, device=dev
        )
        self.ntiles = torch.zeros(len(specs), dtype=torch.int32, device=dev)
        self.plan_scratch = prologue.plan_scratch(R, W.E, dev)
        self.h_q = torch.empty(R, I // 2, dtype=torch.uint8, device=dev)
        self.h_s = torch.empty(R, I // 32, dtype=torch.uint8, device=dev)
        # AST: stage-1 A scales in K-step-major compact-row layout ([H/128, R, 4 B]).
        # +64 B slack: a 16 B/lane scale DMA's last lanes may cover up to 3 rows past R.
        self.a_s_t = (
            torch.empty(R * (H // 32) + 64, dtype=torch.uint8, device=dev)
            if self.AST
            else None
        )
        self.y_rows = torch.empty(R, H, dtype=torch.bfloat16, device=dev)
        self.out = torch.empty(T, H, dtype=torch.bfloat16, device=dev)

    def _tl(self, b):
        return (
            self.tiles.data_ptr() + b * self.MAXT * 16,
            self.ntiles.data_ptr() + b * 4,
        )

    def prologue(self):
        prologue.run_plan(
            self.ids,
            self.w,
            self.row_tok,
            self.row_w,
            self.inv,
            self.tiles,
            self.ntiles,
            self.W.E,
            self.k,
            self.bms,
            self.MAXT,
            scratch=self.plan_scratch,
            shared_last=self.FC,
            quant=(self.x, self.a_q, self.a_s, self.SE) if self.QP else None,
        )
        if not self.QP:
            prologue.run_quant(self.x, self.a_q, self.a_s, even=self.SE)
        if self.AST:
            prologue.run_scale_t(self.a_s, self.row_tok, self.a_s_t)

    def stage1(self):
        W = self.W
        a_s = (self.a_s_t if self.AST else self.a_s).data_ptr()
        for b, c in self.launches1:
            tp, ntp = self._tl(b)
            args = (
                self.a_q.data_ptr(),
                a_s,
                W.b1.data_ptr(),
                W.bs1.data_ptr(),
                tp,
                ntp,
                self.row_tok.data_ptr(),
                0,
                self.h_q.data_ptr(),
                self.h_s.data_ptr(),
                0,
                self.T,
                self.R,
                self.T,
            )
            diag = "+".join(t for t in (c["diag"], "se" if self.SE else "") if t)
            gemm.run_gemm(
                1,
                self.H,
                2 * self.I,
                c["BM"],
                args,
                self.spec_mt[b],
                D=c["D"],
                pipe=c["pipe"],
                NW=c["NW"],
                diag=diag,
                WM=c["WM"],
                EF=c["EF"],
                MV=c["MV"],
                AST=self.AST,
                HT=self.HT,
                PERS=c["PERS"],
            )

    def stage2(self):
        W = self.W
        for b, c, epi in self.launches2:
            tp, ntp = self._tl(b)
            args = (
                self.h_q.data_ptr(),
                self.h_s.data_ptr(),
                W.b2.data_ptr(),
                W.bs2.data_ptr(),
                tp,
                ntp,
                self.row_tok.data_ptr(),
                self.row_w.data_ptr(),
                self.y_rows.data_ptr(),
                self.out.data_ptr(),
                self.inv.data_ptr(),
                self.R,
                self.R,
                self.T,
            )
            gemm.run_gemm(
                2,
                self.I,
                self.H,
                c["BM"],
                args,
                self.spec_mt[b],
                D=c["D"],
                epi=epi,
                KTOP=self.k,
                pipe=c["pipe"],
                NW=c["NW"],
                diag=c["diag"],
                WM=c["WM"],
                EF=c["EF"],
                MV=c["MV"],
                AST=self.HT,
                HT=self.HT,
                PERS=c["PERS"],
            )

    def combine(self):
        if not self.FC:
            combine.run_combine(self.y_rows, self.inv, self.out, self.k)

    def forward(self, x=None, topk_ids=None, topk_w=None):
        """Optional new inputs of the construction shapes: x is re-bound (no copy), routing is
        copied into the run's int32 / fp32 buffers (graph-safe, no host sync)."""
        if x is not None:
            assert (
                x.shape == self.x.shape
                and x.dtype == torch.bfloat16
                and x.is_contiguous()
            )
            self.x = x
        if topk_ids is not None:
            assert topk_ids.shape == (self.T, self.k)
            self.ids.copy_(topk_ids.reshape(-1))
        if topk_w is not None:
            assert topk_w.shape == (self.T, self.k)
            self.w.copy_(topk_w.reshape(-1))
        self.prologue()
        self.stage1()
        self.stage2()
        self.combine()
        return self.out
