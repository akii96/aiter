"""Host-side orchestration: routing plan, activation quant, stage 1, stage 2, combine."""

import torch

from . import combine, gemm, layout, mx


class MoEWeights:
    """Packed MiniMax-M3 expert weights for one TP shard (E experts incl. shared)."""

    def __init__(self, w_gate, s_gate, w_up, s_up, w_down, s_down):
        self.E, self.I, hh = w_gate.shape
        self.H = hh * 2
        self.b1, self.bs1 = layout.pack_w13(w_gate, s_gate, w_up, s_up)
        self.b2, self.bs2 = layout.pack_w2(w_down, s_down)


def make_plan(topk_ids: torch.Tensor, E: int, BM: int):
    """Compact expert-sorted rows (exactly T*k, no padding) and a BM tile list."""
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
    max_tiles = (T * k + BM - 1) // BM + E
    tiles = torch.zeros(max_tiles, 4, dtype=torch.int32, device=flat.device)
    tiles[:total, 0] = te.to(torch.int32)
    tiles[:total, 1] = rs.to(torch.int32)
    tiles[:total, 2] = nr.to(torch.int32)
    ntiles = torch.tensor([total], dtype=torch.int32, device=flat.device)
    return order, row_tok, tiles, ntiles, max_tiles


class MoERun:
    """All buffers for one (T, routing) problem; stage callables for timing."""

    def __init__(self, x, topk_ids, topk_w, W: MoEWeights, BM1=128, BM2=128, D1=5, D2=4,
                 epi="rows", x_quant=None, pipe="async"):
        T, H = x.shape
        k = topk_ids.shape[1]
        R = T * k
        I = W.I
        dev = x.device
        self.T, self.H, self.I, self.k, self.R, self.W = T, H, I, k, R, W
        self.BM1, self.BM2, self.D1, self.D2, self.epi, self.pipe = BM1, BM2, D1, D2, epi, pipe
        self.a_q, self.a_s = mx.quant(x.float()) if x_quant is None else x_quant
        self.order, self.row_tok, self.tiles1, self.nt1, self.mt1 = make_plan(topk_ids, W.E, BM1)
        if BM2 == BM1:
            self.tiles2, self.nt2, self.mt2 = self.tiles1, self.nt1, self.mt1
        else:
            _, _, self.tiles2, self.nt2, self.mt2 = make_plan(topk_ids, W.E, BM2)
        self.row_w = topk_w.reshape(-1)[self.order].to(torch.float32).contiguous()
        self.inv = torch.empty(R, dtype=torch.int32, device=dev)
        self.inv[self.order] = torch.arange(R, dtype=torch.int32, device=dev)
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

    def stage1(self):
        W = self.W
        gemm.run_gemm(
            1, self.H, 2 * self.I, self.BM1,
            (self.a_q.data_ptr(), self.a_s.data_ptr(), W.b1.data_ptr(), W.bs1.data_ptr(),
             self.tiles1.data_ptr(), self.nt1.data_ptr(), self.row_tok.data_ptr(), self.dummy.data_ptr(),
             self.h_q.data_ptr(), self.h_s.data_ptr(), self.T, self.R, self.T),
            self.mt1, D=self.D1, pipe=self.pipe,
        )

    def stage2(self):
        W = self.W
        dst = self.y_rows if self.epi == "rows" else self.out
        if self.epi != "rows":
            self.out.zero_()
        gemm.run_gemm(
            2, self.I, self.H, self.BM2,
            (self.h_q.data_ptr(), self.h_s.data_ptr(), W.b2.data_ptr(), W.bs2.data_ptr(),
             self.tiles2.data_ptr(), self.nt2.data_ptr(), self.row_tok.data_ptr(), self.row_w.data_ptr(),
             dst.data_ptr(), self.dummy.data_ptr(), self.R, self.R, self.T),
            self.mt2, D=self.D2, epi=self.epi, pipe=self.pipe,
        )

    def combine(self):
        if self.epi == "rows":
            combine.run_combine(self.y_rows, self.inv, self.out, self.k)

    def forward(self):
        self.stage1()
        self.stage2()
        self.combine()
        return self.out


def flymoe_forward(x, topk_ids, topk_w, W: MoEWeights, **kw):
    return MoERun(x, topk_ids, topk_w, W, **kw).forward()
