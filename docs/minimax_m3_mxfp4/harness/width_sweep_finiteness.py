"""Is the NaN specific to inter_dim=384, or does it affect every width?

384 is the ONLY width in this study that is not a multiple of 256, and the
FlyDSL stage-2 kernels carry K-tile 256 (t..x..x256 / ..x128). If stage-2
masking is wrong for a K that is 1.5 tiles, the failure would show at 384 and
640 but not at 512 / 768 / 1536. That distinction decides whether narrowing
the alignment rule to dispatch 384 is SAFE, so test it directly.

Reports, per width and per arm: NaN fraction of the kernel output, whether the
exact fp32 reference is finite, and (on the finite subset, in float64) the
relative L2 against that reference.
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
M = int(os.environ.get("MO_M", "4096"))
SWIGLU_LIMIT = 7.0
WIDTHS = [int(x) for x in os.environ.get("MO_WIDTHS", "256,384,512,640,768,1024,1536").split(",")]

lg = torch.randn((M, E), dtype=torch.float32, device=dev)
_tw, _tid = torch.topk(torch.softmax(lg[:, :128], -1), TOPK - 1, -1)
tid = torch.cat([_tid, torch.full((M, 1), 128, dtype=_tid.dtype, device=dev)], -1).to(torch.int32)
tw = torch.cat([_tw, torch.ones((M, 1), dtype=_tw.dtype, device=dev)], -1).to(torch.float32)
hs = (torch.randn((M, MODEL_DIM), dtype=torch.float32, device=dev) * 0.02).to(dtypes.bf16)

for INTER in WIDTHS:
    torch.manual_seed(0)
    w1 = torch.randint(0, 256, (E, INTER * 2, MODEL_DIM // 2), dtype=torch.uint8, device=dev).view(dtypes.fp4x2)
    w2 = torch.randint(0, 256, (E, MODEL_DIM, INTER // 2), dtype=torch.uint8, device=dev).view(dtypes.fp4x2)
    w1s = torch.full((E, INTER * 2, MODEL_DIM // 32), 127, dtype=torch.uint8, device=dev)
    w2s = torch.full((E, MODEL_DIM, INTER // 32), 127, dtype=torch.uint8, device=dev)
    w1sh = shuffle_weight(w1, layout=(16, 16))
    w2sh = shuffle_weight(w2, layout=(16, 16))
    w1f = fp4_utils.mxfp4_to_f32(w1.view(torch.uint8)).float().view(E, INTER * 2, MODEL_DIM)
    w2f = fp4_utils.mxfp4_to_f32(w2.view(torch.uint8)).float().view(E, MODEL_DIM, INTER)

    out = torch.zeros((M, MODEL_DIM), dtype=torch.float64, device=dev)
    x = hs.float()
    for e in range(E):
        sel = (tid == e)
        if not sel.any():
            continue
        ti, tk = sel.nonzero(as_tuple=True)
        g = x[ti] @ w1f[e].t()
        gate, up = g[:, :INTER], g[:, INTER:]
        gate = gate.clamp(max=SWIGLU_LIMIT)
        up = up.clamp(min=-SWIGLU_LIMIT, max=SWIGLU_LIMIT)
        act = gate * torch.sigmoid(gate) * (up + 1.0)
        out.index_add_(0, ti, ((act @ w2f[e].t()) * tw[ti, tk].unsqueeze(-1).float()).double())
    gt = out

    fm.cfg_2stages = ({}, {})
    get_2stage_cfgs.cache_clear()
    o = fused_moe(hs, w1sh, w2sh, tw, tid, activation=ActivationType.Swiglu,
                  quant_type=QuantType.per_1x32, w1_scale=w1s, w2_scale=w2s,
                  dtype=dtypes.bf16, swiglu_limit=SWIGLU_LIMIT).double()
    torch.cuda.synchronize()

    nan_f = torch.isnan(o).float().mean().item()
    inf_f = torch.isinf(o).float().mean().item()
    fin = torch.isfinite(o) & torch.isfinite(gt)
    msg = "inter=%-6d mult256=%-5s NaN=%7.4f%% Inf=%7.4f%% GT_finite=%-5s" % (
        INTER, INTER % 256 == 0, 100 * nan_f, 100 * inf_f, torch.isfinite(gt).all().item())
    if fin.any():
        a, b = o[fin], gt[fin]
        rel = ((a - b).norm() / b.norm()).item()
        cos = torch.nn.functional.cosine_similarity(a.flatten(), b.flatten(), dim=0).item()
        msg += " rel_l2=%.6f cos_diff=%.3e (finite %.2f%%)" % (rel, 1 - cos, 100 * fin.float().mean().item())
    print(msg, flush=True)
print("SHAPEDONE", flush=True)
