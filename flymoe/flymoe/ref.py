"""Torch reference for the MiniMax-M3 A4W4 MoE (fused shared expert).

Math (matches vLLM SWIGLUOAI_UNINTERLEAVE with the checkpoint's alpha/limit):
    a       = quant(x)                                  (MX fp4, once per token)
    [g, u]  = deq(a) @ deq(W13[e])^T                    (W13 = [gate; up])
    h       = min(g,L) * sigmoid(alpha*min(g,L)) * (clamp(u,-L,L) + 1)
    h_q     = quant(h)                                  (intermediate requant)
    y[t]    = sum_slot w[t,slot] * deq(h_q) @ deq(W2[e])^T
"""

import torch

from . import mx

ALPHA = 1.702
LIMIT = 7.0


def swiglu_oai(g, u, alpha=ALPHA, limit=LIMIT):
    g = torch.clamp(g, max=limit)
    u = torch.clamp(u, -limit, limit)
    return g * torch.sigmoid(alpha * g) * (u + 1.0)


def moe_ref(x, topk_ids, topk_w, w_gate, s_gate, w_up, s_up, w_down, s_down,
            requant_h=True, x_quant=None, even=True, quant_x=True):
    """x [T, H] bf16; topk_ids [T, k] int; topk_w [T, k] f32; weights fp4x2 + e8m0.

    Returns (y [T, H] f32, a_q, a_s, h dict for debugging).
    """
    T, H = x.shape
    if not quant_x:
        a_q = a_s = None
        a = x.float()
    else:
        if x_quant is None:
            a_q, a_s = mx.quant(x.float(), even)
        else:
            a_q, a_s = x_quant
        a = mx.dequant(a_q, a_s)
    y = torch.zeros(T, w_down.shape[1], dtype=torch.float32, device=x.device)
    E = w_gate.shape[0]
    flat_ids = topk_ids.reshape(-1)
    for e in range(E):
        sel = (flat_ids == e).nonzero().squeeze(-1)
        if sel.numel() == 0:
            continue
        tok = sel // topk_ids.shape[1]
        g = a[tok] @ mx.dequant(w_gate[e], s_gate[e]).T
        u = a[tok] @ mx.dequant(w_up[e], s_up[e]).T
        h = swiglu_oai(g, u)
        if requant_h:
            hq, hs = mx.quant(h, even)
            h = mx.dequant(hq, hs)
        o = h @ mx.dequant(w_down[e], s_down[e]).T
        y.index_add_(0, tok, o * topk_w.reshape(-1)[sel].unsqueeze(-1))
    return y, a_q, a_s


def rel_l2(a, b):
    a = a.float()
    b = b.float()
    return ((a - b).norm() / b.norm().clamp_min(1e-30)).item()
