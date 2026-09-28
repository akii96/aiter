"""Production-path A/B at inter_dim I, with the two flaws of the first pass fixed.

FLAW 1 (found empirically): the ACTIVE tuned table already contains the shipped
384 rows, so restoring fm.cfg_2stages to ORIG does NOT give a heuristic arm --
it gives the shipped arm under another name. A genuine heuristic baseline needs
an EMPTY table so the lookup misses and the dispatcher falls back.

FLAW 2 (proved by flaw 1): with a fixed arm order inside each repeat, the arm
measured first is systematically slower. Two arms holding an IDENTICAL config
showed a 3.44% apparent 'gain' at M=4096. So:
  * arm order is ROTATED every repeat (cyclic), cancelling first-position bias;
  * a NULL arm (a literal duplicate of the shipped config) is measured alongside
    the real arms, and its apparent gain is the harness noise floor. Any real
    gain must be read against that floor.

Everything else follows the measurement discipline: serial, one GPU, one
process, first touch discarded, medians over MO_REP repeats, spreads reported,
and timing of the REAL fused_moe op rather than the tuner's two-GEMM `us`.
"""
import csv, json, os, statistics
import torch
import aiter
import aiter.fused_moe as fm
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, get_2stage_cfgs
from aiter.ops.shuffle import shuffle_weight

torch.manual_seed(0)
dev = "cuda"
MODEL_DIM, E, TOPK = 6144, 129, 5
INTER = int(os.environ["MO_INTER"])
REPEATS = int(os.environ.get("MO_REP", "8"))
ITERS = int(os.environ.get("MO_ITERS", "20"))
WARM = int(os.environ.get("MO_WARM", "10"))
SWIGLU_LIMIT = 7.0
ONLY = os.environ.get("MO_ONLY", "")
only = set(int(x) for x in ONLY.split(",")) if ONLY else None

arms = {}
for spec in os.environ["MO_ARMS"].split(","):
    name, path = spec.split("=", 1)
    rows = {}
    if os.path.exists(path):
        with open(path) as f:
            for r in csv.DictReader(f):
                if not r.get("kernelName1"):
                    continue
                if int(r["inter_dim"]) != INTER:
                    continue
                rows[int(r["token"])] = r
    arms[name] = rows
    print(f"arm {name}: {len(rows)} rows from {path}", flush=True)

tokens = sorted({t for rows in arms.values() for t in rows})
if only:
    tokens = [t for t in tokens if t in only]
print(f"tokens at inter={INTER}: {tokens}", flush=True)

w1 = torch.randint(0, 256, (E, INTER * 2, MODEL_DIM // 2), dtype=torch.uint8, device=dev).view(dtypes.fp4x2)
w2 = torch.randint(0, 256, (E, MODEL_DIM, INTER // 2), dtype=torch.uint8, device=dev).view(dtypes.fp4x2)
w1s = torch.full((E, INTER * 2, MODEL_DIM // 32), 127, dtype=torch.uint8, device=dev)
w2s = torch.full((E, MODEL_DIM, INTER // 32), 127, dtype=torch.uint8, device=dev)
w1sh = shuffle_weight(w1, layout=(16, 16))
w2sh = shuffle_weight(w2, layout=(16, 16))


def _key(M, qa):
    return (fm.get_gfx_runtime(), fm.get_cu_num(), M, MODEL_DIM, INTER, E, TOPK,
            str(ActivationType.Swiglu), str(dtypes.bf16), str(qa),
            str(dtypes.fp4x2), str(QuantType.per_1x32), True, False)


def apply_arm(name, M, qa):
    """Install the config for one arm. 'heurtrue' installs an EMPTY table so the
    lookup misses and production's heuristic fallback runs."""
    if name == "heurtrue":
        fm.cfg_2stages = ({}, {})
    else:
        row = arms[name][M] if name in arms else arms["shipped"][M]
        fm.cfg_2stages = ({_key(M, qa): {
            "block_m": int(row["block_m"]),
            "ksplit": int(float(row.get("ksplit") or 0)),
            "kernelName1": row["kernelName1"],
            "kernelName2": row["kernelName2"],
            "run_1stage": bool(int(float(row.get("run_1stage") or 0)))}}, {})
    get_2stage_cfgs.cache_clear()


for M in tokens:
    qa = dtypes.bf16 if M < fm._SWIGLU_MXFP4_BF16_BOUND else dtypes.fp4x2
    hs = torch.randn((M, MODEL_DIM), dtype=dtypes.bf16, device=dev) * 0.1
    lg = torch.randn((M, E), dtype=torch.float32, device=dev)
    _tw, _tid = torch.topk(torch.softmax(lg[:, :128], -1), TOPK - 1, -1)
    tid = torch.cat([_tid, torch.full((M, 1), 128, dtype=_tid.dtype, device=dev)], -1).to(torch.int32)
    tw = torch.cat([_tw, torch.ones((M, 1), dtype=_tw.dtype, device=dev)], -1).to(torch.float32)

    def run():
        return fused_moe(hs, w1sh, w2sh, tw, tid, activation=ActivationType.Swiglu,
                         quant_type=QuantType.per_1x32, w1_scale=w1s, w2_scale=w2s,
                         dtype=dtypes.bf16, swiglu_limit=SWIGLU_LIMIT)

    def timed():
        run(); torch.cuda.synchronize()          # DISCARD first touch
        for _ in range(WARM):
            run()
        torch.cuda.synchronize()
        a = torch.cuda.Event(True); b = torch.cuda.Event(True)
        a.record()
        for _ in range(ITERS):
            run()
        b.record(); torch.cuda.synchronize()
        return a.elapsed_time(b) * 1000.0 / ITERS

    # arm list: true heuristic, every supplied arm with a row here, plus a NULL
    # duplicate of 'shipped' used purely to calibrate ordering bias.
    present = [n for n in arms if M in arms[n]]
    order = ["heurtrue"] + present
    if "shipped" in present:
        order.append("null_dup_shipped")

    kn = {}
    for n in order:
        apply_arm("shipped" if n == "null_dup_shipped" else n, M, qa)
        try:
            meta = get_2stage_cfgs(M, MODEL_DIM, INTER, E, TOPK, dtypes.bf16, qa, dtypes.fp4x2,
                                   QuantType.per_1x32, True, ActivationType.Swiglu, False, 0, 0,
                                   is_shuffled=True, gate_mode="separated", opus_weights_shuffled=True)
            k1 = (getattr(meta.stage1, "keywords", {}) or {}).get("kernelName1")
            k2 = (getattr(meta.stage2, "keywords", {}) or {}).get("kernelName2")
        except Exception as ex:
            k1 = k2 = f"ERR:{ex}"
        kn[n] = (k1, k2)

    samples = {n: [] for n in order}
    try:
        for rep in range(REPEATS):
            rot = order[rep % len(order):] + order[:rep % len(order)]   # ROTATE
            for n in rot:
                apply_arm("shipped" if n == "null_dup_shipped" else n, M, qa)
                samples[n].append(timed())
    except Exception as ex:
        print("V " + json.dumps(dict(M=M, error=f"{type(ex).__name__}: {ex}")), flush=True)
        continue

    med = {n: statistics.median(s) for n, s in samples.items()}
    base = med["heurtrue"]
    out = dict(M=M, qa=str(qa).replace("torch.", ""), repeats=REPEATS, arms=order)
    for n in order:
        s = samples[n]
        out[f"{n}_us"] = round(med[n], 2)
        out[f"{n}_min"] = round(min(s), 2)
        out[f"{n}_max"] = round(max(s), 2)
        out[f"{n}_spread_pct"] = round(100.0 * (max(s) - min(s)) / med[n], 2)
        out[f"{n}_gain_vs_heur_pct"] = round(100.0 * (base - med[n]) / base, 2)
        out[f"{n}_kn1"], out[f"{n}_kn2"] = kn[n]
        out[f"{n}_samples"] = [round(x, 2) for x in s]
    if "null_dup_shipped" in order:
        out["noise_floor_pct"] = abs(round(
            out["null_dup_shipped_gain_vs_heur_pct"] - out["shipped_gain_vs_heur_pct"], 2))
    out["all_clean_lt1pct"] = all(out[f"{n}_spread_pct"] < 1.0 for n in order)
    print("V " + json.dumps(out), flush=True)
print("VERIFYDONE", flush=True)
