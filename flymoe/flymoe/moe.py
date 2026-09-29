"""Host-side orchestration: routing plan, activation quant, stage 1, stage 2."""

import torch

from . import gemm, layout, mx


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


def flymoe_forward(x, topk_ids, topk_w, W: MoEWeights, BM1=128, BM2=128, D1=3, D2=3,
                   x_quant=None, return_h=False):
    T, H = x.shape
    k = topk_ids.shape[1]
    R = T * k
    I = W.I
    dev = x.device
    a_q, a_s = mx.quant(x.float()) if x_quant is None else x_quant

    order1, row_tok1, tiles1, nt1, mt1 = make_plan(topk_ids, W.E, BM1)
    h_q = torch.empty(R, I // 2, dtype=torch.uint8, device=dev)
    h_s = torch.empty(R, I // 32, dtype=torch.uint8, device=dev)
    dummy = torch.empty(1, dtype=torch.float32, device=dev)
    gemm.run_gemm(
        1, H, 2 * I, BM1,
        (a_q.data_ptr(), a_s.data_ptr(), W.b1.data_ptr(), W.bs1.data_ptr(),
         tiles1.data_ptr(), nt1.data_ptr(), row_tok1.data_ptr(), dummy.data_ptr(),
         h_q.data_ptr(), h_s.data_ptr(), T, R, T),
        mt1, D=D1,
    )

    if BM2 == BM1:
        tiles2, nt2, mt2 = tiles1, nt1, mt1
    else:
        _, _, tiles2, nt2, mt2 = make_plan(topk_ids, W.E, BM2)
    row_w = topk_w.reshape(-1)[order1].to(torch.float32).contiguous()
    out32 = torch.zeros(T, H, dtype=torch.float32, device=dev)
    gemm.run_gemm(
        2, I, H, BM2,
        (h_q.data_ptr(), h_s.data_ptr(), W.b2.data_ptr(), W.bs2.data_ptr(),
         tiles2.data_ptr(), nt2.data_ptr(), row_tok1.data_ptr(), row_w.data_ptr(),
         out32.data_ptr(), dummy.data_ptr(), R, R, T),
        mt2, D=D2,
    )
    if return_h:
        return out32, (h_q, h_s, order1, row_tok1)
    return out32
