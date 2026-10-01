"""Host-side orchestration: K0 (quant + plan), K1 (stage 1), K2 (stage 2), combine.

Every device step is a FlyDSL kernel; the host only allocates and launches.
make_plan() is a torch implementation kept as a test oracle for the plan kernel.
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


def max_tiles_for(R, E, BM):
    return (R + BM - 1) // BM + E


def _tail_cfg(TB, stage, c):
    """Small-tile kernel for an expert's leftover rows (after full BM tiles)."""
    nw = 1 if TB <= 16 else (2 if TB <= 32 else 4)
    return dict(BM=TB, D=4 if stage == 1 else 2, pipe="async", NW=nw, GM=1, diag="", WM=1,
                EF=c.get("EF", False), MV=c.get("MV", 0))


def make_plan(topk_ids: torch.Tensor, E: int, BM: int):
    """Torch oracle: compact expert-sorted rows and a BM tile list (host-synchronizing)."""
    T, k = topk_ids.shape
    flat = topk_ids.reshape(-1).to(torch.int32)
    order = torch.argsort(flat, stable=True)
    counts = torch.bincount(flat, minlength=E)
    offs = torch.cumsum(counts, 0) - counts
    row_tok = (order // k).to(torch.int32)
    nt = (counts + BM - 1) // BM
    total = int(nt.sum().item())
    te = torch.repeat_interleave(torch.arange(E, device=flat.device), nt)
    first = torch.cumsum(nt, 0) - nt
    m = torch.arange(total, device=flat.device) - torch.repeat_interleave(first, nt)
    rs = offs[te] + m * BM
    nr = torch.minimum(counts[te] - m * BM, torch.full_like(rs, BM))
    max_tiles = max_tiles_for(T * k, E, BM)
    tiles = torch.zeros(max_tiles, 4, dtype=torch.int32, device=flat.device)
    tiles[:total, 0] = te.to(torch.int32)
    tiles[:total, 1] = rs.to(torch.int32)
    tiles[:total, 2] = nr.to(torch.int32)
    ntiles = torch.tensor([total], dtype=torch.int32, device=flat.device)
    return order, row_tok, tiles, ntiles, max_tiles


class MoERun:
    """Buffers + launches for one token count T. Call forward() per step."""

    def __init__(self, x, topk_ids, topk_w, W: MoEWeights, BM1=128, BM2=128, D1=3, D2=2,
                 epi="rows", pipe1="async", pipe2="regs", NW1=4, NW2=4, GM1=1, GM2=1, diag1="", diag2="", WM1=1, WM2=1, EF1=False, EF2=False, MV1=0, MV2=0, AST="auto", TB1=0, TB2=0, HT=False, FC=False, QAST=False, PERS1=0, PERS2=0, SR="even", validate=True, FZ=0, FZS=1, FZK="", QF=False, CF=False, QP=False,
                 BMF=None, NWF=None, DF=None, pipeF=None, diagF=None, WMF=None, GMF=None):
        T, H = x.shape
        k = topk_ids.shape[1]
        assert x.dtype == torch.bfloat16 and x.is_contiguous(), "x must be contiguous bf16"
        assert H == W.H, f"x has H={H}, weights have H={W.H}"
        assert topk_ids.shape == topk_w.shape == (T, k)
        # SR: e8m0 scale rule for the activation and h quant. "even" = the checkpoint's
        # scale_calculation_mode (AITER runtime quant); "ceil" = ceil_pow2(amax / 6).
        assert SR in ("ceil", "even")
        self.SE = SR == "even"
        if validate:
            # Host sync, construction only. Ids outside [0, E) (e.g. expert-parallel -1) are
            # not supported: the plan kernels clamp them into range rather than drop them.
            assert bool(((topk_ids >= 0) & (topk_ids < W.E)).all()), "expert ids must be in [0, E)"
        R = T * k
        I = W.I
        dev = x.device
        self.x, self.W = x, W
        self.T, self.H, self.I, self.k, self.R = T, H, I, k, R
        self.cfg1 = dict(BM=BM1, D=D1, pipe=pipe1, NW=NW1, GM=GM1, diag=diag1, WM=WM1, EF=EF1, MV=MV1, PERS=PERS1)
        self.cfg2 = dict(BM=BM2, D=D2, pipe=pipe2, NW=NW2, GM=GM2, diag=diag2, WM=WM2, EF=EF2, MV=MV2, epi=epi,
                         PERS=PERS2)
        self.epi = epi
        # Step-major A scales pay off for large stage-1 tiles; at small tiles the extra
        # transpose launch costs more than it saves (measured).
        self.AST = (BM1 >= 128) if AST == "auto" else bool(AST)
        # HT: stage 1 writes h K-step-major (h_t[I/128][R][64 B], step-major h scales), so
        # stage 2's A and A-scale fetches are contiguous 1 KB DMAs.
        self.HT = bool(HT)
        self.QAST = bool(QAST)
        # Private copies: the run never aliases (or later writes into) the caller's routing.
        self.ids = torch.empty(R, dtype=torch.int32, device=dev).copy_(topk_ids.reshape(-1))
        self.w = torch.empty(R, dtype=torch.float32, device=dev).copy_(topk_w.reshape(-1))
        self.a_q = torch.empty(T, H // 2, dtype=torch.uint8, device=dev)
        self.a_s = torch.empty(T, H // 32, dtype=torch.uint8, device=dev)
        self.row_tok = torch.empty(R, dtype=torch.int32, device=dev)
        self.row_w = torch.empty(R, dtype=torch.float32, device=dev)
        self.inv = torch.empty(R, dtype=torch.int32, device=dev)
        # Tile lists. TB>0: the main kernel runs only full BM tiles and a small-tile (TB)
        # kernel runs each expert's leftover rows, so tail tiles never cost a full BM tile.
        self.TB1, self.TB2 = TB1, TB2
        specs = []

        def spec(x):
            if x not in specs:
                specs.append(x)
            return specs.index(x)

        self.launches1 = [(spec((BM1, -1) if TB1 else BM1), self.cfg1)]
        if TB1:
            self.launches1.append((spec((TB1, BM1)), _tail_cfg(TB1, 1, self.cfg1)))
        # FC: fused combine. The shared expert (E-1, on every token) gets token-ordered rows;
        # stage 2 runs routed tiles first (y_rows), then shared tiles whose epilogue adds the
        # token's routed rows and writes `out` directly (no combine kernel, no shared y rows).
        self.FC = bool(FC)
        if self.FC:
            assert epi == "rows" and not TB2, "FC needs the rows epilogue and no stage-2 tail split"
            assert not validate or bool(((topk_ids == W.E - 1).sum(1) == 1).all()), \
                "FC needs the shared expert (E-1) exactly once per token"
            assert T * H * 2 < 2**31, "the fused epilogue stores out with 32-bit offsets"
            # *F: optional shared-tile (fused) launch config; defaults to the routed config.
            over = {k: v for k, v in dict(BM=BMF, NW=NWF, D=DF, pipe=pipeF, diag=diagF, WM=WMF, GM=GMF).items()
                    if v is not None}
            cf = dict(self.cfg2, epi="fused", PERS=0, **over)
            ytl = ["ytl" in c["diag"].split("+") for c in (self.cfg2, cf)]
            assert ytl[0] == ytl[1] and (not ytl[0] or (cf["NW"], cf["WM"]) == (NW2, WM2)), \
                "ytl: both FC launches need it, with the same N-block width"
            self.launches2 = [(spec((BM2, -2)), self.cfg2), (spec((cf["BM"], -3)), cf)]
        else:
            self.launches2 = [(spec((BM2, -1) if TB2 else BM2), self.cfg2)]
            if TB2:
                self.launches2.append((spec((TB2, BM2)), dict(_tail_cfg(TB2, 2, self.cfg2), epi=epi)))
        self.bms = tuple(specs)
        # FZ: stage 1 + stage 2 in one persistent launch of FZ CTAs per CU (gemm.build_fused);
        # both stages walk the same tile list.
        self.FZ, self.FZS, self.FZK = int(FZ), int(FZS), FZK
        if self.FZ:
            assert not self.FC and not TB1 and not TB2 and BM1 == BM2 and epi == "rows", \
                "FZ: one tile list (BM1 == BM2, no tail split), rows epilogue, no FC"
            assert pipe1 not in ("regs", "il4") and pipe2 not in ("regs", "il4") and GM1 == GM2 == 1
            assert not PERS1 and not PERS2 and gemm.split_k(diag1) == 1
        self.spec_mt = [prologue.spec_max_tiles(b, R, W.E) for b in specs]
        self.MAXT = max(self.spec_mt)
        # QF: the activation quant runs in the stage-1 launch (gemm "qf"); CF: the combine runs
        # in the stage-2 launch (gemm "cf"). Their flags re-arm themselves, so zeroed only here.
        self.QF, self.CF = bool(QF), bool(CF)
        # QP: the activation quant runs as extra CTAs of the plan's first launch.
        self.QP = bool(QP)
        assert not self.QP or (not self.QF and not (self.AST and self.QAST)), "QP: one quant path"
        # Flags are epoch-valued (the plan bumps the epoch at ntiles + EPOCH_OFF each forward).
        if self.QF or self.CF:
            assert len(specs) == 1 and not self.FZ, "QF / CF: one tile list"
        if self.QF:
            assert not self.AST and not PERS1 and gemm.split_k(diag1) == 1
            self.qf_sync = torch.zeros(T * 4 + (8 * 65536 if "qft" in diag1 else 0), dtype=torch.int32, device=dev)
        if self.CF:
            assert epi == "rows" and not self.FC and not PERS2
            self.cf_sync = torch.zeros(R * (H // (64 * NW2 // WM2)), dtype=torch.int32, device=dev)
        self.tiles = torch.zeros(len(specs) * self.MAXT, 4, dtype=torch.int32, device=dev)
        self.ntiles = torch.zeros(len(specs) + gemm.EPOCH_OFF // 4, dtype=torch.int32, device=dev)
        self.plan_scratch = prologue.plan_scratch(R, W.E, dev)
        self.fz_sync = torch.zeros(self.MAXT * gemm.SYNC_STRIDE // 4, dtype=torch.int32, device=dev) if self.FZ else None
        self.h_q = torch.empty(R, I // 2, dtype=torch.uint8, device=dev)
        self.h_s = torch.empty(R, I // 32, dtype=torch.uint8, device=dev)
        # AST: stage-1 A scales in K-step-major compact-row layout ([H/128, R, 4 B]).
        # +64 B allocation slack: a 16 B/lane scale DMA's last lanes may cover up to 3 rows past R.
        self.a_s_t = torch.empty(R * (H // 32) + 64, dtype=torch.uint8, device=dev) if self.AST else None
        # ap (diag1): the quant writes stage-1 A pre-gathered, K-step-major ([H/128][R][64 B]).
        self.AP = "ap" in diag1.split("+")
        if self.AP:
            assert self.AST and not self.QF and not self.QP and not self.FZ and not TB1, \
                "ap: step-major A scales, quant in its own launch, one stage-1 launch"
            assert R * H // 2 < 2**31, "ap: 32-bit offsets into a_q_t"
        self.a_q_t = torch.empty(R * H // 2, dtype=torch.uint8, device=dev) if self.AP else None
        self.dummy = torch.empty(1, dtype=torch.float32, device=dev)
        # split-K stage 1 (diag skN): fp32 partial workspace + per-tile arrival counters (the
        # last arriving unit re-arms its counter, so they are zeroed only here).
        self.sk1 = {}
        for b, c in self.launches1:
            sk = gemm.split_k(c["diag"])
            if sk > 1:
                units = self.spec_mt[b] * (2 * self.I) // (64 * c["NW"] // c["WM"])
                self.sk1[b] = (torch.empty(units * sk * c["BM"] * (64 * c["NW"] // c["WM"]), dtype=torch.float32,
                                           device=dev),
                               torch.zeros(units, dtype=torch.int32, device=dev))
        if epi == "rows":
            self.y_rows = torch.empty(R, H, dtype=torch.bfloat16, device=dev)
            self.out = torch.empty(T, H, dtype=torch.bfloat16, device=dev)
        elif epi == "f32atomic":
            assert T * H * 4 < 2**31, "atomic epilogues use 32-bit offsets into out"
            self.out = torch.zeros(T, H, dtype=torch.float32, device=dev)
        else:
            assert T * H * 2 < 2**31, "atomic epilogues use 32-bit offsets into out"
            self.out = torch.zeros(T, H, dtype=torch.bfloat16, device=dev)

    def _tl(self, b):
        return self.tiles.data_ptr() + b * self.MAXT * 16, self.ntiles.data_ptr() + b * 4

    def prologue(self):
        # Plan first (needs only the routing ids). With QAST, quant also writes the step-major
        # compact A scales; otherwise a separate scale_t launch does (the default, faster).
        prologue.run_plan(self.ids, self.w, self.row_tok, self.row_w, self.inv, self.tiles,
                          self.ntiles, self.W.E, self.k, self.bms, self.MAXT, scratch=self.plan_scratch,
                          shared_last=self.FC, epoch=self.QF or self.CF,
                          quant=(self.x, self.a_q, self.a_s, self.SE) if self.QP else None)
        if self.AP:
            prologue.run_quant(self.x, self.a_q_t, self.a_s, inv=self.inv, a_s_t=self.a_s_t, k=self.k,
                               even=self.SE, ap=True)
        elif self.AST and self.QAST:
            prologue.run_quant(self.x, self.a_q, self.a_s, inv=self.inv, a_s_t=self.a_s_t, k=self.k,
                               even=self.SE)
        else:
            # Separate transpose measured faster than quant-side strided scale stores
            # (32k: 170 vs 194 us prologue).
            if not self.QF and not self.QP:
                prologue.run_quant(self.x, self.a_q, self.a_s, even=self.SE)
            if self.AST:
                prologue.run_scale_t(self.a_s, self.row_tok, self.a_s_t)

    def _calls1(self):
        W = self.W
        a_s = (self.a_s_t if self.AST else self.a_s).data_ptr()
        out = []
        for b, c in self.launches1:
            tp, ntp = self._tl(b)
            ws, cnt = self.sk1.get(b, (self.dummy, self.dummy))
            args = ((self.a_q_t if self.AP else self.a_q).data_ptr(), a_s, W.b1.data_ptr(), W.bs1.data_ptr(),
                    tp, ntp, self.row_tok.data_ptr(), cnt.data_ptr(),
                    self.h_q.data_ptr(), self.h_s.data_ptr(), ws.data_ptr(), self.R if self.AP else self.T,
                    self.R, self.T)
            kw = dict(K=self.H, N=2 * self.I, BM=c["BM"], D=c["D"], pipe=c["pipe"], NW=c["NW"], GM=c["GM"],
                      diag="+".join(t for t in (c["diag"], "se" if self.SE else "", "qf" if self.QF else "") if t),
                      WM=c["WM"], EF=c["EF"], MV=c["MV"], AST=self.AST, HT=self.HT, PERS=c.get("PERS", 0))
            if self.QF:
                args = args[:7] + (self.qf_sync.data_ptr(),) + args[8:10] + (self.x.data_ptr(),) + args[11:]
                kw.update(KTOP=self.k, extra=gemm.qf_ctas(self.T, self.H, c["NW"]))
            out.append((b, args, kw))
        return out

    def _calls2(self):
        W = self.W
        dst = self.y_rows if self.epi == "rows" else self.out
        out = []
        for b, c in self.launches2:
            tp, ntp = self._tl(b)
            args = (self.h_q.data_ptr(), self.h_s.data_ptr(), W.b2.data_ptr(), W.bs2.data_ptr(),
                    tp, ntp, self.row_tok.data_ptr(), self.row_w.data_ptr(),
                    dst.data_ptr(), self.out.data_ptr(), self.inv.data_ptr(), self.R, self.R, self.T)
            kw = dict(K=self.I, N=self.H, BM=c["BM"], D=c["D"], epi=c.get("epi", self.epi), KTOP=self.k,
                      pipe=c["pipe"], NW=c["NW"], GM=c["GM"], diag=c["diag"], WM=c["WM"], EF=c["EF"],
                      MV=c["MV"], AST=self.HT, HT=self.HT, PERS=c.get("PERS", 0))
            if self.CF:
                args = args[:6] + (self.cf_sync.data_ptr(),) + args[7:]
                kw.update(diag="+".join(t for t in (c["diag"], "cf") if t), extra=self.T * gemm.CF_CC)
            out.append((b, args, kw))
        return out

    def stage1(self):
        if self.FZ:
            (_, a1, k1), = self._calls1()
            if "tsr" in self.FZK:
                if getattr(self, "fz_ts", None) is None:
                    self.fz_ts = torch.zeros(gemm.NUM_CUS * self.FZ * 8, dtype=torch.int64, device=self.x.device)
                a1 = a1[:10] + (self.fz_ts.data_ptr(),) + a1[11:]
            (_, a2, k2), = self._calls2()
            tag = "" if "nocoh" in self.FZK else "fz"  # nocoh: timing knock-out, h races across XCDs
            fz = lambda k: dict(k, PERS=1, diag="+".join(t for t in (k["diag"], tag) if t))  # noqa: E731
            gemm.run_fused(fz(k1), fz(k2), a1, a2, self.fz_sync.data_ptr(), gemm.NUM_CUS * self.FZ,
                           sched=self.FZS, ko=self.FZK)
            return
        for b, args, kw in self._calls1():
            gemm.run_gemm(1, kw.pop("K"), kw.pop("N"), kw.pop("BM"), args, self.spec_mt[b], **kw)

    def stage2(self):
        if self.epi != "rows":
            self.out.zero_()
        if self.FZ:
            return  # ran inside stage1's fused launch
        for b, args, kw in self._calls2():
            gemm.run_gemm(2, kw.pop("K"), kw.pop("N"), kw.pop("BM"), args, self.spec_mt[b], **kw)

    def combine(self):
        if self.epi == "rows" and not self.FC and not self.CF:
            combine.run_combine(self.y_rows, self.inv, self.out, self.k)

    def forward(self, x=None, topk_ids=None, topk_w=None):
        """Optional new inputs of the construction shapes: x is re-bound (no copy), routing is
        copied into the run's int32 / fp32 buffers (graph-safe, no host sync)."""
        if x is not None:
            assert x.shape == self.x.shape and x.dtype == torch.bfloat16 and x.is_contiguous()
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


def flymoe_forward(x, topk_ids, topk_w, W: MoEWeights, **kw):
    return MoERun(x, topk_ids, topk_w, W, **kw).forward()
