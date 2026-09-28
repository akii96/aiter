"""Find an input scale where the MXFP4 kernel itself is numerically well-posed.

With hs~N(0,0.1) and uniform-random fp4 weights over K=6144, stage-1 outputs
reach ~1e4. swiglu_limit=7 then clamps almost every gate, so the stage-1
activation collapses to a bimodal {0, 7*(up+1)} signal. Whole 32-element
quantisation blocks come out all-zero, and the per-block e8m0 scale for such a
block is degenerate -> NaN. That is an artifact of synthetic data, and it hits
the heuristic and tuned arms alike; it says nothing about either kernel.

So: sweep the activation scale and pick one where BOTH the fp32 reference and
the kernel output are finite, i.e. where gate magnitudes sit inside the swiglu
limit instead of saturating it.
"""
import os
import torch
import aiter
import aiter.fused_moe as fm
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, get_2stage_cfgs
from aiter.ops.shuffle import shuffle_weight
from aiter.utility import fp4_utils

torch.manual_seed(0)
dev = "cuda"
MODEL_DIM, E, TOPK = 6144, 129, 5
INTER = int(os.environ.get("MO_INTER", "384"))
M = int(os.environ.get("MO_M", "4096"))
SWIGLU_LIMIT = 7.0

w1 = torch.randint(0, 256, (E, INTER * 2, MODEL_DIM // 2), dtype=torch.uint8, device=dev).view(dtypes.fp4x2)
w2 = torch.randint(0, 256, (E, MODEL_DIM, INTER // 2), dtype=torch.uint8, device=dev).view(dtypes.fp4x2)
w1s = torch.full((E, INTER * 2, MODEL_DIM // 32), 127, dtype=torch.uint8, device=dev)
w2s = torch.full((E, MODEL_DIM, INTER // 32), 127, dtype=torch.uint8, device=dev)
w1sh = shuffle_weight(w1, layout=(16, 16))
w2sh = shuffle_weight(w2, layout=(16, 16))
w1f = fp4_utils.mxfp4_to_f32(w1.view(torch.uint8)).float().view(E, INTER * 2, MODEL_DIM)
w2f = fp4_utils.mxfp4_to_f32(w2.view(torch.uint8)).float().view(E, MODEL_DIM, INTER)

lg = torch.randn((M, E), dtype=torch.float32, device=dev)
_tw, _tid = torch.topk(torch.softmax(lg[:, :128], -1), TOPK - 1, -1)
tid = torch.cat([_tid, torch.full((M, 1), 128, dtype=_tid.dtype, device=dev)], -1).to(torch.int32)
tw = torch.cat([_tw, torch.ones((M, 1), dtype=_tw.dtype, device=dev)], -1).to(torch.float32)
base = torch.randn((M, MODEL_DIM), dtype=torch.float32, device=dev)


def ref(hs):
    out = torch.zeros((M, MODEL_DIM), dtype=torch.float32, device=dev)
    x = hs.float()
    for e in range(E):
        sel = (tid == e)
        if not sel.any():
            continue
        ti, tk = sel.nonzero(as_tuple=True)
        g = x[ti] @ w1f[e].t()
        gate, up = g[:, :INTER], g[:, INTER:]
        satur = (gate > SWIGLU_LIMIT).float().mean().item()
        gate = gate.clamp(max=SWIGLU_LIMIT)
        up = up.clamp(min=-SWIGLU_LIMIT, max=SWIGLU_LIMIT)
        act = gate * torch.sigmoid(gate) * (up + 1.0)
        out.index_add_(0, ti, (act @ w2f[e].t()) * tw[ti, tk].unsqueeze(-1).float())
    return out


fm.cfg_2stages = ({}, {})
get_2stage_cfgs.cache_clear()
for s in (0.1, 0.02, 0.005, 0.002, 0.001, 0.0005, 0.0002):
    hs = (base * s).to(dtypes.bf16)
    g0 = (hs.float() @ w1f[0].t())
    sat = (g0[:, :INTER].abs() > SWIGLU_LIMIT).float().mean().item()
    gt = ref(hs)
    o = fused_moe(hs, w1sh, w2sh, tw, tid, activation=ActivationType.Swiglu,
                  quant_type=QuantType.per_1x32, w1_scale=w1s, w2_scale=w2s,
                  dtype=dtypes.bf16, swiglu_limit=SWIGLU_LIMIT).float()
    torch.cuda.synchronize()
    okg, oko = torch.isfinite(gt).all().item(), torch.isfinite(o).all().item()
    line = "scale=%-8g gate|>limit|=%5.1f%%  GT_finite=%-5s OUT_finite=%-5s OUT_nan=%.4f" % (
        s, 100 * sat, okg, oko, torch.isnan(o).float().mean().item())
    if okg and oko:
        rel = ((o - gt).norm() / gt.norm()).item()
        cos = torch.nn.functional.cosine_similarity(o.flatten(), gt.flatten(), dim=0).item()
        line += "  rel_l2=%.6f cos_diff=%.3e" % (rel, 1 - cos)
    print(line, flush=True)
print("SWEEPDONE", flush=True)
