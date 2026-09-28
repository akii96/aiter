# MXFP4 fused-MoE is non-finite at `inter_dim` values that are not multiples of 256

**Model:** MiniMax-M3 · **Shape:** `model_dim=6144, experts=129 (128 routed + 1 shared), topk=5, Swiglu(limit=7.0), per_1x32 MXFP4, fp4x2 weights, use_g1u1=True, doweight_stage1=False` · **Target:** gfx950 (MI355X), `cu_num=256` · **Base:** `8253efc4`

## Headline

At `inter_dim` values that are **not multiples of 256**, the MXFP4 fused-MoE operator returns
**NaN and Inf**, and can **hard-fault the GPU**. Multiples of 256 are clean under identical code.

The 256 round-up in `vllm/model_executor/layers/fused_moe/oracle/mxfp4.py` is therefore
**load-bearing correctness, not untightened padding**. The ~8.5 GB/GPU and +33.3% MoE FLOPs
it costs at TP8 are the **price of a working kernel**, not reclaimable waste.

> **Recommendation: do NOT narrow the alignment rule to dispatch 384.**
> This reverses the proposal that motivated the investigation.

## The controlled experiment

One variable changed — `inter_dim` — everything else identical (same harness, same seed, same
inputs, heuristic dispatch, `M=4096`). `rel_l2` is against an exact fp32 reference computed
from the dequantised MXFP4 weights.

| `inter_dim` | multiple of 256 | NaN | Inf | finite | `rel_l2` vs fp32 truth |
|---|---|---|---|---|---|
| 256  | yes | 0.00% | 0.00% | 100.00% | 0.2200 |
| **384**  | **no**  | **5.99%** | **26.77%** | 67.24% | — (meaningless) |
| 512  | yes | 0.00% | 0.00% | 100.00% | 0.2203 |
| **640**  | **no**  | **10.04%** | **36.00%** | 53.97% | — (meaningless) |
| 768  | yes | 0.00% | 0.00% | 100.00% | 0.2202 |
| 1024 | yes | 0.00% | 0.00% | 100.00% | 0.2204 |
| 1536 | yes | 0.00% | 0.00% | 100.00% | 0.2205 |

Only the two non-multiples of 256 fail. The split is exact.

### Hard GPU faults, reproduced on two nodes

```
inter=384, M=512  ->  Memory access fault by GPU node-6 ... on address 0x7eef83a10000
inter=384, M=1024 ->  Memory access fault by GPU node-7 ... on address 0x7f432660f000
inter=512, same M ->  clean, rel_l2 = 0.2197
```

This is a crash, not merely bad numerics.

## Alternative explanations, each tested and eliminated

**Not activation saturation / input conditioning.** Swept the activation scale over
`0.1 → 0.0002`. The NaN fraction is flat at ~2.5% even where gate saturation is 0.0%.

| scale | gate `|·|>limit` | GT finite | output finite | NaN |
|---|---|---|---|---|
| 0.1 | 76.0% | yes | **no** | 2.95% |
| 0.02 | 12.7% | yes | **no** | 2.80% |
| 0.005 | 0.0% | yes | **no** | 2.55% |
| 0.0002 | 0.0% | yes | **no** | 2.48% |

**Not an out-of-bounds read into neighbouring allocations.** A 3 GB decoy buffer placed before
the weights, filled with `1e30` vs `0.0` vs absent, gives **byte-identical** corruption — so the
corrupt values do not originate in adjacent memory.

| decoy | NaN | Inf | finite absmax |
|---|---|---|---|
| absent | 2.95% | 14.41% | 9.57e+37 |
| zeros (0.0) | 2.95% | 14.41% | 9.57e+37 |
| sentinel (1e30) | 2.95% | 14.41% | 9.57e+37 |
| *(512 control, all three modes)* | 0.00% | 0.00% | 11904.0 |

**Not a harness artifact.** The same harness reproduces the known-good result at `inter_dim=512`
to four decimals (see Validation below), and the fp32 reference is finite (`gt_finite=true`) in
every failing run — the corruption is on the kernel side.

## Which path corrupts (guard is incomplete)

The in-tree guard reroutes away from CK-Tile at non-256 widths, **but the surviving FlyDSL
kernel is what returns non-finite output**:

| `inter_dim` | `cktile_mxfp4_unsafe` | stage1 impl | stage2 impl | NaN | Inf |
|---|---|---|---|---|---|
| 384 | **True** (guard fires) | `_flydsl_stage1_wrapper` | `_flydsl_stage2_wrapper` | 2.95% | 14.41% |
| 512 | False | `_flydsl_stage1_wrapper` | `_flydsl_stage2_wrapper` | 0.00% | 0.00% |

So the guard at `:2894` does its job of avoiding CK-Tile, yet the shape still executes and still
corrupts on FlyDSL. **The guard is incomplete**: it prevents one unsafe path rather than
rejecting the unsafe *shape*. Worth a bug report.

## The in-tree guards (both already present)

```
aiter/fused_moe.py:2894   cktile_mxfp4_unsafe = q_dtype_w == dtypes.fp4x2 and inter_dim % 256 != 0
aiter/fused_moe.py:3206   if cktile_mxfp4_unsafe and _is_cktile_mxfp4_stage2_name(kn2): cfg = None
aiter/fused_moe.py:3565   cktile_mxfp4_ok = not (cktile_mxfp4_unsafe and flydsl_can_take_over)
```

`aiter/ops/moe_mxfp4_aux.py:59` contains the trap that makes 384 *look* supported:

```python
def is_mxfp4_moe_shape_supported(expert, model_dim, inter_dim, topk):
    padded_inter = ((int(inter_dim) + 255) // 256) * 256      # <-- pads BEFORE the test
    return (int(expert), int(model_dim), padded_inter, int(topk)) in MXFP4_MOE_SUPPORTED_SHAPES
```

The raw supported set for this model contains **only** `(129, 6144, 512, 5)` and
`(129, 6144, 768, 5)`. **There is no 384 entry.** A query for 384 returns `True` only because it
is answered for 512 — it reports on the *padded* shape, never the requested one.

| `inter_dim` | in raw set | pads to | `supported()` | `% 256 != 0` | actual behaviour |
|---|---|---|---|---|---|
| 384 | **no** | 512 | **True** *(misleading)* | True | **dispatches, non-finite** |
| 512 | yes | 512 | True | False | OK |
| 768 | yes | 768 | True | False | OK |
| 1536 | **no** | 1536 | False | False | rejected at dispatch |
| 3072 | no | 3072 | False | False | rejected at dispatch |

## ⚠️ The actionable hazard: the 16 shipped 384 rows

`aiter/configs/model_configs/minimax_m3_fp4_tuned_fmoe.csv` ships **16 tuned rows at
`inter_dim=384`** for this exact model. Measured on the production path they are **reached and
genuinely fast** — and **wrong**.

| tokens | tuned vs true heuristic | ordering-noise floor | correctness |
|---|---|---|---|
| 4096 | **+14.82%** | 0.08% | **non-finite** |
| 8192 | **+18.38%** | 0.04% | **non-finite** |
| 16384 | **+29.29%** | 0.11% | **non-finite** |
| 32768 | **+25.21%** | 0.01% | **non-finite** |

They are **fast at producing NaN**. Speed without finiteness is not a result.

Today they are harmless *only* because production never dispatches 384 — the oracle rounds it to
512. **They would become live the moment the alignment rule were narrowed**, which is precisely
the change under consideration. Anyone finding 16 tuned rows at 384 would reasonably read that
as "384 has coverage"; coverage here does **not** imply correctness.

*(Note: 8 of the 16 rows carry `q_dtype_a=fp4x2` at tokens 1–128, where production uses **bf16**
activations. Since `q_dtype_a` is part of the lookup key, those 8 could never match production
anyway — they were written for a different backend.)*

## Validation of the harness (why these numbers are trustworthy)

The correctness harness was rebuilt after review and validated against a known-good
configuration **before** any verdict was trusted. At `inter_dim=512` it reproduces the prior
independently-measured result to four decimals:

| shape | heuristic `rel_l2` | tuned `rel_l2` | ratio | prior run |
|---|---|---|---|---|
| 512 / M=4096 | 0.308014 | 0.297077 | **0.9645** | 0.9644–0.9662 ✓ |
| 512 / M=8192 | 0.307996 | 0.297110 | **0.9647** | 0.9644–0.9662 ✓ |

Harness properties: isolated process per `(inter_dim, M)`; preshuffled weights asserted;
non-finite results emit `INVALID_*` and **never** a `WORSE`/`OK` verdict; `rel_l2` in float64 on
the finite subset with the finite fraction always reported.

Timing protocol: serial, one GPU, one process; arms **rotated** each repeat to cancel
first-position bias; a **null-duplicate arm** (a literal copy of the shipped config) calibrates
the ordering-noise floor at 0.01–0.11%; first touch discarded; medians of 8.

> The rotation and null-duplicate arm were added after an earlier pass showed a *3.44% apparent
> gain between two arms holding an identical config* — a pure ordering artifact that would have
> been reported as a win.

## Reproduction

```
docs/minimax_m3_mxfp4/harness/width_sweep_finiteness.py    # the six-width table
docs/minimax_m3_mxfp4/harness/activation_scale_sweep.py    # saturation eliminated
docs/minimax_m3_mxfp4/harness/sentinel_oob_test.py         # neighbour-memory eliminated
docs/minimax_m3_mxfp4/harness/which_path_corrupts.py       # FlyDSL vs CK-Tile
docs/minimax_m3_mxfp4/harness/verify_ground_truth.py       # fp32 reference, isolated
docs/minimax_m3_mxfp4/harness/verify_production_path.py    # rotated-arm timing
```

## Outcome

- **No `inter_dim=384` row is shipped.** Every one is unverifiable by construction: the operator
  is non-finite at that width.
- **No `inter_dim=1536` row is shipped.** They tune and they are finite, but `(129,6144,1536,5)`
  is absent from `MXFP4_MOE_SUPPORTED_SHAPES`, so the dispatcher discards every one
  (`discarding MXMOE config: generated MXFP4 auxiliary kernels do not cover ...`, 136×).
  Measured gains are 0.00 ± 0.08% — the heuristic, measured against itself.
- Tuned candidates are committed as **evidence only**, under `candidates/` with
  `UNSHIPPABLE` / `UNDISPATCHABLE` in their filenames, and are wired into no lookup table.
- **Decode band (tokens 1–128, bf16 activations): clean structural negative.** Both 384 and 1536
  report `stage1 asm tasks is 0, tasks_ck is 0, task_1stage is 0` for all 8 shapes — an empty
  candidate set, no crash and no setup failure. Nothing to tune, matching the prior run at 512.
