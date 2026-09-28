"""Test the `nt` (non-temporal stage2) hypothesis at bucket 2048.

Forces a specific (kn1,kn2) pair into the tuned table and measures BOTH
accuracy (aiter's own reference) and perf. Distinguishes:
  H1: the `_atomic_nt_` stage2 causes the elevated error -> non-nt is clean
  H2: the MXMOE family itself is less accurate at this shape -> non-nt also dirty

env: KN1 KN2 TAG M SEED
"""
import os, sys, json, types, functools, time, statistics, traceback
sys.argv = ["nt"]
sys.path.insert(0, "/workspace/aiter")
sys.path.insert(0, "/workspace/aiter/op_tests")

KN1 = os.environ["KN1"]; KN2 = os.environ["KN2"]
TAG = os.environ["TAG"]; M = int(os.environ["M"])
SEED = int(os.environ.get("SEED", "0"))
BM = int(os.environ.get("BM", "128"))

import torch
torch.manual_seed(SEED); torch.cuda.manual_seed_all(SEED)

import aiter
import aiter.fused_moe as FM
from aiter import ActivationType, QuantType, dtypes
from aiter.ops.flydsl.moe_common import GateMode
import aiter.ops.moe_mxfp4_aux as aux

SHAPE = (129, 6144, 1536, 5)
aux.MXFP4_MOE_SUPPORTED_SHAPES = frozenset(
    set(aux.MXFP4_MOE_SUPPORTED_SHAPES) | {SHAPE})
assert aiter.is_mxfp4_moe_shape_supported(*SHAPE)

GFX, CU = FM.get_gfx_runtime(), FM.get_cu_num()
KEY = (GFX, CU, FM.get_padded_M(M), 6144, 1536, 129, 5,
       str(ActivationType.Swiglu), str(dtypes.bf16), str(dtypes.fp4x2),
       str(dtypes.fp4x2), str(QuantType.per_1x32), True, False)
ROW = {"block_m": BM, "ksplit": 0, "run_1stage": False,
       "kernelName1": KN1, "kernelName2": KN2, "xbf16": False, "flat": False}

FM.cfg_2stages = ({KEY: ROW}, {})
FM.get_2stage_cfgs.cache_clear()

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

def _bk(fn):
    t = fn.func if isinstance(fn, functools.partial) else fn
    return getattr(t, "__name__", str(t))

res = {"tag": TAG, "M": M, "seed": SEED, "kn1": KN1, "kn2": KN2, "block_m": BM,
       "nt_in_kn2": "_nt_" in KN2}

try:
    meta = FM.get_2stage_cfgs(
        FM.get_padded_M(M), 6144, 1536, 129, 5, dtypes.bf16, dtypes.fp4x2,
        dtypes.fp4x2, QuantType.per_1x32, True, ActivationType.Swiglu,
        False, 0, 0, is_shuffled=True, gate_mode=GateMode.SEPARATED,
        opus_weights_shuffled=True, swiglu_limit=7.0)
    res["stage1"] = _bk(meta.stage1)
    res["is_mxmoe"] = "mxfp4_a4w4" in _bk(meta.stage1)
except Exception as e:
    res["dispatch_error"] = str(e)

FM.cfg_2stages = ({KEY: ROW}, {})
FM.get_2stage_cfgs.cache_clear()

try:
    out = T.test_fmoe(dtypes.bf16, M, 6144, 1536, 129, 5,
                      ActivationType.Swiglu, GateMode.SEPARATED,
                      QuantType.per_1x32, dtypes.fp4x2, dtypes.fp4x2,
                      use_g1u1=True, doweight_stage1=False, preshuffle=True,
                      strict_accuracy=False, check_aot_cache=False,
                      swiglu_limit=7.0)
    res["us"] = None if out is None else out.get("us")
except Exception as e:
    traceback.print_exc(); res["run_error"] = f"{type(e).__name__}: {e}"

if "ref" in CAP:
    r = CAP["ref"].double(); c = CAP["ck"].double(); d = c - r
    res["rel_l2"]  = float(d.norm() / r.norm())
    res["max_abs"] = float(d.abs().max())
    res["n_nan"]   = int(torch.isnan(c).sum())
    res["n_inf"]   = int(torch.isinf(c).sum())
    den = (r*r + c*c).sum()
    res["cos_diff"] = float(1 - 2*(r*c).sum()/den) if den > 0 else None

print("@@@NT@@@ " + json.dumps(res))
