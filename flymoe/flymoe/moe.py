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
                 epi="rows", pipe1="async", pipe2="regs", NW1=4, NW2=4, GM1=1, GM2=1, diag1="", diag2="", WM1=1, WM2=1, EF1=False, EF2=False, MV1=0, MV2=0, AST="auto", TB1=0, TB2=0, HT=False, FC=False, QAST=False, PERS1=0):
        T, H = x.shape
        k = topk_ids.shape[1]
        R = T * k
        I = W.I
        dev = x.device
        self.x, self.W = x, W
        self.T, self.H, self.I, self.k, self.R = T, H, I, k, R
        self.cfg1 = dict(BM=BM1, D=D1, pipe=pipe1, NW=NW1, GM=GM1, diag=diag1, WM=WM1, EF=EF1, MV=MV1, PERS=PERS1)
        self.cfg2 = dict(BM=BM2, D=D2, pipe=pipe2, NW=NW2, GM=GM2, diag=diag2, WM=WM2, EF=EF2, MV=MV2, epi=epi)
        self.epi = epi
        # Step-major A scales pay off for large stage-1 tiles; at small tiles the extra
        # transpose launch costs more than it saves (measured).
        self.AST = (BM1 >= 128) if AST == "auto" else bool(AST)
        # HT: stage 1 writes h K-step-major (h_t[I/128][R][64 B], step-major h scales), so
        # stage 2's A and A-scale fetches are contiguous 1 KB DMAs.
        self.HT = bool(HT)
        self.QAST = bool(QAST)
        self.ids = topk_ids.reshape(-1).to(torch.int32).contiguous()
        self.w = topk_w.reshape(-1).to(torch.float32).contiguous()
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
            assert bool(((topk_ids == W.E - 1).sum(1) == 1).all()), \
                "FC needs the shared expert (E-1) exactly once per token"
            assert T * H * 2 < 2**31, "the fused epilogue stores out with 32-bit offsets"
            self.launches2 = [(spec((BM2, -2)), self.cfg2), (spec((BM2, -3)), dict(self.cfg2, epi="fused"))]
        else:
            self.launches2 = [(spec((BM2, -1) if TB2 else BM2), self.cfg2)]
            if TB2:
                self.launches2.append((spec((TB2, BM2)), dict(_tail_cfg(TB2, 2, self.cfg2), epi=epi)))
        self.bms = tuple(specs)
        self.spec_mt = [prologue.spec_max_tiles(b, R, W.E) for b in specs]
        self.MAXT = max(self.spec_mt)
        self.tiles = torch.zeros(len(specs) * self.MAXT, 4, dtype=torch.int32, device=dev)
        self.ntiles = torch.zeros(len(specs), dtype=torch.int32, device=dev)
        self.plan_scratch = prologue.plan_scratch(R, W.E, dev)
        self.h_q = torch.empty(R, I // 2, dtype=torch.uint8, device=dev)
        self.h_s = torch.empty(R, I // 32, dtype=torch.uint8, device=dev)
        # AST: stage-1 A scales in K-step-major compact-row layout ([H/128, R, 4 B]).
        # +64 B allocation slack: a 16 B/lane scale DMA's last lanes may cover up to 3 rows past R.
        self.a_s_t = torch.empty(R * (H // 32) + 64, dtype=torch.uint8, device=dev) if self.AST else None
        self.dummy = torch.empty(1, dtype=torch.float32, device=dev)
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
        # Plan first (needs only the routing ids); quant then writes the step-major compact A
        # scales for stage 1 directly (no separate scale-transpose launch).
        prologue.run_plan(self.ids, self.w, self.row_tok, self.row_w, self.inv, self.tiles,
                          self.ntiles, self.W.E, self.k, self.bms, self.MAXT, scratch=self.plan_scratch,
                          shared_last=self.FC)
        if self.AST and self.QAST:
            prologue.run_quant(self.x, self.a_q, self.a_s, inv=self.inv, a_s_t=self.a_s_t, k=self.k)
        else:
            # Separate transpose measured faster than quant-side strided scale stores
            # (32k: 170 vs 194 us prologue).
            prologue.run_quant(self.x, self.a_q, self.a_s)
            if self.AST:
                prologue.run_scale_t(self.a_s, self.row_tok, self.a_s_t)

    def stage1(self):
        W = self.W
        a_s = (self.a_s_t if self.AST else self.a_s).data_ptr()
        for b, c in self.launches1:
            tp, ntp = self._tl(b)
            gemm.run_gemm(
                1, self.H, 2 * self.I, c["BM"],
                (self.a_q.data_ptr(), a_s, W.b1.data_ptr(), W.bs1.data_ptr(),
                 tp, ntp, self.row_tok.data_ptr(), self.dummy.data_ptr(),
                 self.h_q.data_ptr(), self.h_s.data_ptr(), self.dummy.data_ptr(), self.T, self.R, self.T),
                self.spec_mt[b], D=c["D"], pipe=c["pipe"], NW=c["NW"], GM=c["GM"], diag=c["diag"],
                WM=c["WM"], EF=c["EF"], MV=c["MV"], AST=self.AST, HT=self.HT, PERS=c.get("PERS", 0),
            )

    def stage2(self):
        W = self.W
        dst = self.y_rows if self.epi == "rows" else self.out
        if self.epi != "rows":
            self.out.zero_()
        for b, c in self.launches2:
            tp, ntp = self._tl(b)
            gemm.run_gemm(
                2, self.I, self.H, c["BM"],
                (self.h_q.data_ptr(), self.h_s.data_ptr(), W.b2.data_ptr(), W.bs2.data_ptr(),
                 tp, ntp, self.row_tok.data_ptr(), self.row_w.data_ptr(),
                 dst.data_ptr(), self.out.data_ptr(), self.inv.data_ptr(), self.R, self.R, self.T),
                self.spec_mt[b], D=c["D"], epi=c.get("epi", self.epi), KTOP=self.k, pipe=c["pipe"], NW=c["NW"], GM=c["GM"],
                diag=c["diag"], WM=c["WM"], EF=c["EF"], MV=c["MV"], AST=self.HT, HT=self.HT,
            )

    def combine(self):
        if self.epi == "rows" and not self.FC:
            combine.run_combine(self.y_rows, self.inv, self.out, self.k)

    def forward(self):
        self.prologue()
        self.stage1()
        self.stage2()
        self.combine()
        return self.out


def flymoe_forward(x, topk_ids, topk_w, W: MoEWeights, **kw):
    return MoERun(x, topk_ids, topk_w, W, **kw).forward()
