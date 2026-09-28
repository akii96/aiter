"""Is inter_dim=384 reading OUT OF BOUNDS?

Two observations that look contradictory:
  * 384 with a big fp32 reference allocated in-process -> 6.7% NaN, 28.7% Inf.
  * 384 with nothing else allocated                    -> perfectly clean.
and separately, a hard "Memory access fault by GPU node-6" at inter=384, M=512.

A kernel that reads past its buffer shows exactly this: whether you SEE
corruption depends on what happens to sit in adjacent memory. So control that
memory explicitly instead of guessing.

ARMS
  clean    : no decoy allocation.
  sentinel : a large decoy buffer filled with +1e30 is allocated (and kept
             alive) BEFORE the weights, so any out-of-bounds read lands on a
             huge finite value and shows up as Inf/NaN in the output.
  zeros    : same decoy, filled with 0.0 -- a control proving the effect comes
             from the decoy's CONTENT, not merely from its presence.

If 'sentinel' corrupts the output while 'clean'/'zeros' do not, the kernel is
reading memory it does not own. A multiple-of-256 width is run as the control.
"""
import json, os
import torch
import aiter
import aiter.fused_moe as fm
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, get_2stage_cfgs
from aiter.ops.shuffle import shuffle_weight

dev = "cuda"
MODEL_DIM, E, TOPK = 6144, 129, 5
M = int(os.environ.get("MO_M", "4096"))
SWIGLU_LIMIT = 7.0
GB = float(os.environ.get("MO_DECOY_GB", "3"))
WIDTHS = [int(x) for x in os.environ.get("MO_WIDTHS", "384,512").split(",")]


def trial(INTER, mode):
    torch.cuda.empty_cache()
    decoy = None
    if mode in ("sentinel", "zeros"):
        n = int(GB * (1 << 30) // 4)
        decoy = torch.empty(n, dtype=torch.float32, device=dev)
        decoy.fill_(1e30 if mode == "sentinel" else 0.0)
    torch.manual_seed(0)
    w1 = torch.randint(0, 256, (E, INTER * 2, MODEL_DIM // 2), dtype=torch.uint8, device=dev).view(dtypes.fp4x2)
    w2 = torch.randint(0, 256, (E, MODEL_DIM, INTER // 2), dtype=torch.uint8, device=dev).view(dtypes.fp4x2)
    w1s = torch.full((E, INTER * 2, MODEL_DIM // 32), 127, dtype=torch.uint8, device=dev)
    w2s = torch.full((E, MODEL_DIM, INTER // 32), 127, dtype=torch.uint8, device=dev)
    w1sh = shuffle_weight(w1, layout=(16, 16))
    w2sh = shuffle_weight(w2, layout=(16, 16))
    lg = torch.randn((M, E), dtype=torch.float32, device=dev)
    _tw, _tid = torch.topk(torch.softmax(lg[:, :128], -1), TOPK - 1, -1)
    tid = torch.cat([_tid, torch.full((M, 1), 128, dtype=_tid.dtype, device=dev)], -1).to(torch.int32)
    tw = torch.cat([_tw, torch.ones((M, 1), dtype=_tw.dtype, device=dev)], -1).to(torch.float32)
    hs = (torch.randn((M, MODEL_DIM), dtype=torch.float32, device=dev) * 0.1).to(dtypes.bf16)

    fm.cfg_2stages = ({}, {})
    get_2stage_cfgs.cache_clear()
    o = fused_moe(hs, w1sh, w2sh, tw, tid, activation=ActivationType.Swiglu,
                  quant_type=QuantType.per_1x32, w1_scale=w1s, w2_scale=w2s,
                  dtype=dtypes.bf16, swiglu_limit=SWIGLU_LIMIT).float()
    torch.cuda.synchronize()
    r = dict(inter=INTER, M=M, mode=mode,
             nan_pct=round(100 * torch.isnan(o).float().mean().item(), 4),
             inf_pct=round(100 * torch.isinf(o).float().mean().item(), 4),
             absmax=(None if not torch.isfinite(o).any() else round(o[torch.isfinite(o)].abs().max().item(), 3)))
    del decoy
    torch.cuda.empty_cache()
    return r


for INTER in WIDTHS:
    for mode in ("clean", "zeros", "sentinel"):
        try:
            print("O " + json.dumps(trial(INTER, mode)), flush=True)
        except Exception as ex:
            print("O " + json.dumps(dict(inter=INTER, mode=mode, error=f"{type(ex).__name__}: {ex}")), flush=True)
print("OOBDONE", flush=True)
