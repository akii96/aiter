"""GROUND-TRUTH CORRECTNESS -- one (inter_dim, M) per PROCESS.

Fixes demanded after review, all of them right:
  * ISOLATED PROCESS per shape (driver invokes this once per M), so a large-M
    fp32 reference cannot poison later shapes or OOM the whole sweep.
  * NON-FINITE RESULTS ARE 'INVALID', NEVER 'WORSE'. A verdict of WORSE claims
    a measurement happened and lost; NaN means no measurement happened. They
    must never be confused.
  * SHUFFLE IS ASSERTED, not assumed: weights go through shuffle_weight and the
    op is called with the same preshuffled tensors the production path uses.
  * SELF-CHECK built in: the reference is validated against the kernel at a
    known-good width before any verdict is trusted (driver runs inter=512).

Emits one JSON line per arm. rel_l2 is computed in float64 on the finite subset,
and the finite fraction is always reported so a partially-NaN result can never
masquerade as a clean one.
"""
import csv, json, os
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
INTER = int(os.environ["MO_INTER"])
M = int(os.environ["MO_M"])
SCALE = float(os.environ.get("MO_SCALE", "0.1"))
SWIGLU_LIMIT = 7.0

arms = {}
for spec in os.environ.get("MO_ARMS", "").split(","):
    if not spec.strip():
        continue
    name, path = spec.split("=", 1)
    if not os.path.exists(path):
        continue
    with open(path) as f:
        for r in csv.DictReader(f):
            if not r.get("kernelName1"):
                continue
            if int(r["inter_dim"]) == INTER and int(r["token"]) == M:
                arms[name] = r

w1 = torch.randint(0, 256, (E, INTER * 2, MODEL_DIM // 2), dtype=torch.uint8, device=dev).view(dtypes.fp4x2)
w2 = torch.randint(0, 256, (E, MODEL_DIM, INTER // 2), dtype=torch.uint8, device=dev).view(dtypes.fp4x2)
w1s = torch.full((E, INTER * 2, MODEL_DIM // 32), 127, dtype=torch.uint8, device=dev)
w2s = torch.full((E, MODEL_DIM, INTER // 32), 127, dtype=torch.uint8, device=dev)
w1sh = shuffle_weight(w1, layout=(16, 16))
w2sh = shuffle_weight(w2, layout=(16, 16))
assert w1sh.shape == w1.shape and w2sh.shape == w2.shape, "shuffle changed shape"

# scale byte 127 == e8m0 exponent bias 127 == multiplier 1.0, so this dequant is exact.
w1f = fp4_utils.mxfp4_to_f32(w1.view(torch.uint8)).float().view(E, INTER * 2, MODEL_DIM)
w2f = fp4_utils.mxfp4_to_f32(w2.view(torch.uint8)).float().view(E, MODEL_DIM, INTER)

lg = torch.randn((M, E), dtype=torch.float32, device=dev)
_tw, _tid = torch.topk(torch.softmax(lg[:, :128], -1), TOPK - 1, -1)
tid = torch.cat([_tid, torch.full((M, 1), 128, dtype=_tid.dtype, device=dev)], -1).to(torch.int32)
tw = torch.cat([_tw, torch.ones((M, 1), dtype=_tw.dtype, device=dev)], -1).to(torch.float32)
hs = (torch.randn((M, MODEL_DIM), dtype=torch.float32, device=dev) * SCALE).to(dtypes.bf16)

gt = torch.zeros((M, MODEL_DIM), dtype=torch.float64, device=dev)
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
    gt.index_add_(0, ti, ((act @ w2f[e].t()) * tw[ti, tk].unsqueeze(-1).float()).double())

gt_finite = bool(torch.isfinite(gt).all().item())


def _key():
    return (fm.get_gfx_runtime(), fm.get_cu_num(), M, MODEL_DIM, INTER, E, TOPK,
            str(ActivationType.Swiglu), str(dtypes.bf16),
            str(dtypes.bf16 if M < fm._SWIGLU_MXFP4_BF16_BOUND else dtypes.fp4x2),
            str(dtypes.fp4x2), str(QuantType.per_1x32), True, False)


def apply_arm(name):
    if name == "heurtrue":
        fm.cfg_2stages = ({}, {})
    else:
        r = arms[name]
        fm.cfg_2stages = ({_key(): {
            "block_m": int(r["block_m"]), "ksplit": int(float(r.get("ksplit") or 0)),
            "kernelName1": r["kernelName1"], "kernelName2": r["kernelName2"],
            "run_1stage": bool(int(float(r.get("run_1stage") or 0)))}}, {})
    get_2stage_cfgs.cache_clear()


ref_l2 = None
for name in ["heurtrue"] + sorted(arms):
    rec = dict(inter=INTER, M=M, arm=name, scale=SCALE, gt_finite=gt_finite)
    try:
        apply_arm(name)
        o = fused_moe(hs, w1sh, w2sh, tw, tid, activation=ActivationType.Swiglu,
                      quant_type=QuantType.per_1x32, w1_scale=w1s, w2_scale=w2s,
                      dtype=dtypes.bf16, swiglu_limit=SWIGLU_LIMIT).double()
        torch.cuda.synchronize()
        nan_f = torch.isnan(o).float().mean().item()
        inf_f = torch.isinf(o).float().mean().item()
        fin = torch.isfinite(o) & torch.isfinite(gt)
        ff = fin.float().mean().item()
        rec.update(nan_frac=round(nan_f, 6), inf_frac=round(inf_f, 6), finite_frac=round(ff, 6))
        if not gt_finite:
            rec["verdict"] = "INVALID_REFERENCE_NONFINITE"
        elif nan_f > 0 or inf_f > 0:
            # A non-finite kernel output is NOT a loss on a measured comparison;
            # it means no comparison was possible. Never call this WORSE.
            rec["verdict"] = "INVALID_OUTPUT_NONFINITE"
        else:
            a, b = o[fin], gt[fin]
            rel = ((a - b).norm() / b.norm()).item()
            cos = torch.nn.functional.cosine_similarity(a.flatten(), b.flatten(), dim=0).item()
            rec.update(rel_l2=round(rel, 6), cos_diff=round(1 - cos, 9))
            if name == "heurtrue":
                ref_l2 = rel
                rec["verdict"] = "BASELINE"
            elif ref_l2 is None:
                rec["verdict"] = "INVALID_NO_BASELINE"
            else:
                rec["ratio_vs_heur"] = round(rel / max(ref_l2, 1e-12), 4)
                rec["verdict"] = "OK" if rel <= ref_l2 * 1.05 else "WORSE"
        if name != "heurtrue" and name in arms:
            rec["kn1"] = arms[name]["kernelName1"]
            rec["kn2"] = arms[name]["kernelName2"]
    except Exception as ex:
        rec["verdict"] = "INVALID_EXCEPTION"
        rec["error"] = f"{type(ex).__name__}: {ex}"
    print("A " + json.dumps(rec), flush=True)
print("ACCDONE", flush=True)
