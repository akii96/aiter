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
                 epi="rows", pipe1="async", pipe2="regs", NW1=4, NW2=4, GM1=1, GM2=1, diag1="", diag2="", WM1=1, WM2=1):
        T, H = x.shape
        k = topk_ids.shape[1]
        R = T * k
        I = W.I
        dev = x.device
        self.x, self.W = x, W
        self.T, self.H, self.I, self.k, self.R = T, H, I, k, R
        self.cfg1 = dict(BM=BM1, D=D1, pipe=pipe1, NW=NW1, GM=GM1, diag=diag1, WM=WM1)
        self.cfg2 = dict(BM=BM2, D=D2, pipe=pipe2, NW=NW2, GM=GM2, diag=diag2, WM=WM2, epi=epi)
        self.epi = epi
        self.ids = topk_ids.reshape(-1).to(torch.int32).contiguous()
        self.w = topk_w.reshape(-1).to(torch.float32).contiguous()
        self.a_q = torch.empty(T, H // 2, dtype=torch.uint8, device=dev)
        self.a_s = torch.empty(T, H // 32, dtype=torch.uint8, device=dev)
        self.row_tok = torch.empty(R, dtype=torch.int32, device=dev)
        self.row_w = torch.empty(R, dtype=torch.float32, device=dev)
        self.inv = torch.empty(R, dtype=torch.int32, device=dev)
        self.bms = (BM1,) if BM2 == BM1 else (BM1, BM2)
        self.mt1 = max_tiles_for(R, W.E, BM1)
        self.mt2 = max_tiles_for(R, W.E, BM2)
        self.tiles = torch.zeros(self.mt1 + self.mt2, 4, dtype=torch.int32, device=dev)
        self.ntiles = torch.zeros(2, dtype=torch.int32, device=dev)
        self.plan_scratch = prologue.plan_scratch(R, W.E, dev)
        self.h_q = torch.empty(R, I // 2, dtype=torch.uint8, device=dev)
        self.h_s = torch.empty(R, I // 32, dtype=torch.uint8, device=dev)
        self.dummy = torch.empty(1, dtype=torch.float32, device=dev)
        if epi == "rows":
            self.y_rows = torch.empty(R, H, dtype=torch.bfloat16, device=dev)
            self.out = torch.empty(T, H, dtype=torch.bfloat16, device=dev)
        elif epi == "f32atomic":
            self.out = torch.zeros(T, H, dtype=torch.float32, device=dev)
        else:
            self.out = torch.zeros(T, H, dtype=torch.bfloat16, device=dev)

    def _tiles2(self):
        if len(self.bms) == 1:
            return self.tiles.data_ptr(), self.ntiles.data_ptr()
        return self.tiles.data_ptr() + self.mt1 * 16, self.ntiles.data_ptr() + 4

    def prologue(self):
        prologue.run_quant(self.x, self.a_q, self.a_s)
        prologue.run_plan(self.ids, self.w, self.row_tok, self.row_w, self.inv, self.tiles,
                          self.ntiles, self.W.E, self.k, self.bms, self.mt1, scratch=self.plan_scratch)

    def stage1(self):
        W, c = self.W, self.cfg1
        gemm.run_gemm(
            1, self.H, 2 * self.I, c["BM"],
            (self.a_q.data_ptr(), self.a_s.data_ptr(), W.b1.data_ptr(), W.bs1.data_ptr(),
             self.tiles.data_ptr(), self.ntiles.data_ptr(), self.row_tok.data_ptr(), self.dummy.data_ptr(),
             self.h_q.data_ptr(), self.h_s.data_ptr(), self.T, self.R, self.T),
            self.mt1, D=c["D"], pipe=c["pipe"], NW=c["NW"], GM=c["GM"], diag=c["diag"], WM=c["WM"],
        )

    def stage2(self):
        W, c = self.W, self.cfg2
        dst = self.y_rows if self.epi == "rows" else self.out
        if self.epi != "rows":
            self.out.zero_()
        tp, ntp = self._tiles2()
        gemm.run_gemm(
            2, self.I, self.H, c["BM"],
            (self.h_q.data_ptr(), self.h_s.data_ptr(), W.b2.data_ptr(), W.bs2.data_ptr(),
             tp, ntp, self.row_tok.data_ptr(), self.row_w.data_ptr(),
             dst.data_ptr(), self.dummy.data_ptr(), self.R, self.R, self.T),
            self.mt2, D=c["D"], epi=self.epi, pipe=c["pipe"], NW=c["NW"], GM=c["GM"], diag=c["diag"], WM=c["WM"],
        )

    def combine(self):
        if self.epi == "rows":
            combine.run_combine(self.y_rows, self.inv, self.out, self.k)

    def forward(self):
        self.prologue()
        self.stage1()
        self.stage2()
        self.combine()
        return self.out


def flymoe_forward(x, topk_ids, topk_w, W: MoEWeights, **kw):
    return MoERun(x, topk_ids, topk_w, W, **kw).forward()
