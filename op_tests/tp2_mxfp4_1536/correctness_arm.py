"""Correctness via aiter's OWN validated reference (op_tests/test_moe_2stage.py::test_fmoe).

My hand-rolled fp32 reference mishandled the activation-quant path, so this uses
aiter's reference, which quantises activations exactly as the runtime does.

env: ARM=heuristic|mxmoe  M=<tokens>  TUNEDCSV=...  SEED=0
"""
import os, sys, json, types, functools, traceback
sys.argv = ["gt3"]
sys.path.insert(0, "/workspace/aiter")
sys.path.insert(0, "/workspace/aiter/op_tests")

ARM   = os.environ["ARM"]
M     = int(os.environ["M"])
TUNED = os.environ["TUNEDCSV"]
SEED  = int(os.environ.get("SEED", "0"))

import torch
torch.manual_seed(SEED); torch.cuda.manual_seed_all(SEED)

import aiter
import aiter.fused_moe as FM
from aiter import ActivationType, QuantType, dtypes
from aiter.ops.flydsl.moe_common import GateMode
import aiter.ops.moe_mxfp4_aux as aux

SHAPE = (129, 6144, 1536, 5)
os.environ["AITER_CONFIG_FMOE"] = TUNED
FM.cfg_2stages = None
FM.get_2stage_cfgs.cache_clear()

BASE = frozenset(aux.MXFP4_MOE_SUPPORTED_SHAPES) - {SHAPE}
aux.MXFP4_MOE_SUPPORTED_SHAPES = frozenset(BASE | {SHAPE}) if ARM == "mxmoe" else BASE
FM.get_2stage_cfgs.cache_clear()
assert aiter.is_mxfp4_moe_shape_supported(*SHAPE) == (ARM == "mxmoe"), "gate ineffective"

SRC = "/workspace/aiter/op_tests/test_moe_2stage.py"
src = open(SRC).read()
T = types.ModuleType("t"); T.__file__ = SRC
exec(compile(src[:src.index("_case_iters = []")], SRC, "exec"), T.__dict__)

CAP = {}
_orig = T.checkAllclose
def cap(ref, ck, *a, **k):
    CAP["ref"] = ref.detach().float(); CAP["ck"] = ck.detach().float()
    try:
        return _orig(ref, ck, *a, **k)
    except Exception:
        return float("nan")
T.checkAllclose = cap

WARN = []
_ow = FM.logger.warning
FM.logger.warning = lambda m: (WARN.append(str(m)), _ow(m))[1]

def _bk(fn):
    t = fn.func if isinstance(fn, functools.partial) else fn
    return getattr(t, "__name__", str(t))

res = {"arm": ARM, "M": M, "padded": FM.get_padded_M(M),
       "gate": bool(aiter.is_mxfp4_moe_shape_supported(*SHAPE))}

try:
    meta = FM.get_2stage_cfgs(
        FM.get_padded_M(M), 6144, 1536, 129, 5, dtypes.bf16, dtypes.fp4x2,
        dtypes.fp4x2, QuantType.per_1x32, True, ActivationType.Swiglu,
        False, 0, 0, is_shuffled=True, gate_mode=GateMode.SEPARATED,
        opus_weights_shuffled=True, swiglu_limit=7.0)
    res["stage1"] = _bk(meta.stage1)
    res["is_mxmoe"] = "mxfp4_a4w4" in _bk(meta.stage1)
    res["block_m"] = meta.block_m
except Exception as e:
    res["dispatch_error"] = str(e)

try:
    out = T.test_fmoe(dtypes.bf16, M, 6144, 1536, 129, 5,
                      ActivationType.Swiglu, GateMode.SEPARATED,
                      QuantType.per_1x32, dtypes.fp4x2, dtypes.fp4x2,
                      use_g1u1=True, doweight_stage1=False, preshuffle=True,
                      strict_accuracy=False, check_aot_cache=False,
                      swiglu_limit=7.0)
    res["us"] = None if out is None else out.get("us")
    res["logits_diff"] = None if out is None else out.get("logits_diff")
except Exception as e:
    traceback.print_exc(); res["run_error"] = f"{type(e).__name__}: {e}"

if "ref" in CAP:
    r = CAP["ref"].double(); c = CAP["ck"].double(); d = c - r
    res["rel_l2"]  = float(d.norm() / r.norm())
    res["max_abs"] = float(d.abs().max())
    res["ref_rms"] = float(r.pow(2).mean().sqrt())
    res["ck_rms"]  = float(c.pow(2).mean().sqrt())
    res["n_nan"]   = int(torch.isnan(c).sum())
    res["n_inf"]   = int(torch.isinf(c).sum())
    den = (r*r + c*c).sum()
    res["cos_diff"] = float(1 - 2*(r*c).sum()/den) if den > 0 else None

res["discard_warn"] = any("discarding MXMOE config" in w for w in WARN)
print("@@@GT3@@@ " + json.dumps(res))
