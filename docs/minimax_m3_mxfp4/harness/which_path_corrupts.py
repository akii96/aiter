"""Q4: at inter_dim=384, is the corruption on the CKTILE path that the guard
at fused_moe.py:2894 protects, or on the FLYDSL path that takes over?

    fused_moe.py:2894  cktile_mxfp4_unsafe = q_dtype_w == fp4x2 and inter_dim % 256 != 0
    fused_moe.py:3206  if cktile_mxfp4_unsafe and _is_cktile_mxfp4_stage2_name(kn2): cfg = None
    fused_moe.py:3565  cktile_mxfp4_ok = not (cktile_mxfp4_unsafe and flydsl_can_take_over)

If the guard reroutes away from cktile and the surviving FLYDSL kernel still
returns non-finite output, the guard is INCOMPLETE and this is a real bug: the
system believes it has made the shape safe and it has not.

Prints, for each width, the kernel pair actually dispatched, classifies it, and
reports finiteness -- so the failing path is named rather than inferred.
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

print("### guard evaluation (fused_moe.py:2894) ###", flush=True)
for I in (384, 512, 640, 768, 1536):
    print("   inter=%-6d cktile_mxfp4_unsafe=%s" % (I, I % 256 != 0), flush=True)

for INTER in [int(x) for x in os.environ.get("MO_WIDTHS", "384,512").split(",")]:
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
    qa = dtypes.bf16 if M < fm._SWIGLU_MXFP4_BF16_BOUND else dtypes.fp4x2
    try:
        meta = get_2stage_cfgs(M, MODEL_DIM, INTER, E, TOPK, dtypes.bf16, qa, dtypes.fp4x2,
                               QuantType.per_1x32, True, ActivationType.Swiglu, False, 0, 0,
                               is_shuffled=True, gate_mode="separated", opus_weights_shuffled=True)
        k1 = (getattr(meta.stage1, "keywords", {}) or {}).get("kernelName1")
        k2 = (getattr(meta.stage2, "keywords", {}) or {}).get("kernelName2")
        fn1 = getattr(meta.stage1, "func", meta.stage1)
        fn2 = getattr(meta.stage2, "func", meta.stage2)
        n1 = getattr(fn1, "__name__", str(fn1))
        n2 = getattr(fn2, "__name__", str(fn2))
    except Exception as ex:
        k1 = k2 = n1 = n2 = f"ERR:{ex}"

    o = fused_moe(hs, w1sh, w2sh, tw, tid, activation=ActivationType.Swiglu,
                  quant_type=QuantType.per_1x32, w1_scale=w1s, w2_scale=w2s,
                  dtype=dtypes.bf16, swiglu_limit=SWIGLU_LIMIT).float()
    torch.cuda.synchronize()

    def cls(n):
        s = str(n)
        if "flydsl" in s: return "FLYDSL"
        if "cktile" in s or "ck_tile" in s: return "CKTILE"
        if "ck2stages" in s: return "CK2STAGES"
        if "asm" in s: return "ASM"
        return "OTHER/heuristic"

    print("P " + json.dumps(dict(
        inter=INTER, M=M, guard_cktile_unsafe=(INTER % 256 != 0),
        stage1_impl=n1, stage2_impl=n2,
        stage1_class=cls(n1), stage2_class=cls(n2),
        kernelName1=k1, kernelName2=k2,
        nan_pct=round(100 * torch.isnan(o).float().mean().item(), 4),
        inf_pct=round(100 * torch.isinf(o).float().mean().item(), 4))), flush=True)
print("PATHDONE", flush=True)
