# MiniMax-M3 TP2 (inter_dim=1536) MXFP4 MoE: gate analysis, tuned rows, and traps

Node: `smci355-ccs-aus-n04-05` (gfx950, cu_num 256). aiter `bcb56d9c4`, `amd-aiter 0.1.25.dev4`.
Shape: model_dim 6144, **inter_dim 1536 (TP2)**, experts 129 (128 routed + 1 shared as slot 128),
topk 5, activation Swiglu (limit 7.0), q_type `per_1x32` (MXFP4), q_dtype_w `fp4x2`,
`use_g1u1=True`, `doweight_stage1=False`, gate_mode SEPARATED.

---

## 1. Verdict: is the frozenset gate the only blocker for TP2?

**No â€” it is one of two blockers, and it is dormant until the other is removed.**

TP2 at inter_dim=1536 needs **both**:

1. a **tuned config row** at the relevant token bucket, and
2. `(129, 6144, 1536, 5)` present in `MXFP4_MOE_SUPPORTED_SHAPES`.

The gate at `aiter/fused_moe.py:3183` sits inside:

```python
if cfg is not None and _is_mxfp4_kname(kn1):
```

With no tuned row, `cfg is None`, the gate is never evaluated, and the
`discarding MXMOE config ...` warning never appears. Once a tuned row exists the
gate fires and discards it. This **reconciles two contradictory prior reports** â€”
"136 occurrences of the discard warning" and "the message never fires" â€” as the
same code in two different states.

Proven by a controlled A/B in which an identical tuned MXMOE row was injected in
**both** arms, so the only difference was the frozenset:

| arm | gate | discard warning | stage1 dispatched |
|---|---|---|---|
| baseline | False | **yes** | `_flydsl_stage1_wrapper` (heuristic) |
| patched | True | **no** | `_mxfp4_a4w4_stage1_fw` (MXMOE) |

The aux kernels are genuinely **not keyed on inter_dim**: `module_moe_mxfp4_aux`
builds 330 instances and the 1536 shape runs on them with no new codegen.

### Scope limitation (important)

This fix covers **prefill and large-batch decode only**. `_is_mxfp4_kname` is
literally `kname.startswith("flydsl_mxmoe_g")`, which only matches the **a4w4**
family. The runtime picks the activation dtype by
`_bound_split(M, GPTOSS_SWIGLU_MXFP4_BF16_BOUND=256, bf16, fp4x2)`:

```
token 1/64/128/255 -> bf16   |   token 256/512/2048 -> fp4x2
```

Below 256 the kernels are the **a16w4** family `flydsl_moe1_abf16_wfp4_*`, which
`_is_mxfp4_kname` does not match, so the frozenset is unreachable there â€”
patched or not. **Small-batch decode at TP2 is unaffected by this change.**

---

## 2. TRAP: `get_padded_M` rounds **up** (nextPow2), not floor-to-tier

`_PADDED_M_TIERS = [32768, 131072]`, so the floor-to-tier branch only applies
at/above 32768. Below that it is `nextPow2(M)`. Measured:

```
2048 -> 2048    2049 -> 4096    8191 -> 8192    8192 -> 8192
8193 -> 16384   8207 -> 16384   12288 -> 16384  16384 -> 16384
16385 -> 32768  40000 -> 32768
```

Full bucket set: `1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768`.

**Consequence for benchmarking:** with `--max-num-batched-tokens 8192`, a step
carrying 8192 prefill tokens **plus even one decode token** gives M=8193 â†’
bucket **16384**. Coverage must include the packing slack, not just the nominal
chunk size. A treatment arm missing that row silently falls back to the
heuristic while every config flag still says "treatment".

**Always report the bucket, not the prompt length** â€” the bucket selects the row.

Also note `enable_chunked_prefill=True` and `max_num_batched_tokens=2048` are
vLLM defaults here, so an 8192-token prompt is split into 4Ã—2048 (bucket 2048)
unless `--max-num-batched-tokens` is raised explicitly.

---

## 3. Op-level results (production path `fused_moe`)

Identical tensors, same process, same tuned CSV loaded in both arms; the only
difference is the frozenset entry. Arms interleaved round-robin with order
rotated per rep, first-touch discarded, n=7, plus a **null arm** (duplicate of
heuristic) as noise floor.

| bucket | heuristic | mxmoe | delta | null-calibration | recommendation |
|---:|---:|---:|---:|---:|---|
| 2048 | 736.24 Âµs | 580.19 Âµs | **+21.2 %** | +0.47 % | **DROP â€” accuracy** |
| 8192 | 1339.02 Âµs | 1162.37 Âµs | **+13.2 %** | âˆ’0.65 % | **ship** |
| 16384 | 2281.95 Âµs | 2034.57 Âµs | **+10.8 %** | âˆ’0.18 % | **ship** |

The null arm lands within Â±0.65 % at every bucket, so these deltas are far
outside noise. Min-to-min gives 20.8/13.2/11.0 %, i.e. not a median artifact.

**`block_m` observation:** the heuristic picks `block_m=64` at buckets 2048 and
16384 where the tuned row picks 128. Part of the win is the heuristic
**mis-sizing block_m**, not only the kernel-family switch.

### Dispatch evidence (bucket â†’ kernel â†’ arm)

```
2048  heuristic  flydsl_moe1_afp4_wfp4_bf16_t64x128x256_w3_bnt0  + _atomic   (block_m 64)
2048  mxmoe      _mxfp4_a4w4_stage1_fw / _mxfp4_a4w4_stage2_fw              (block_m 128)
8192  heuristic  flydsl_moe1_afp4_wfp4_bf16_t128x128x256_w2_bnt0 + _atomic   (block_m 128)
8192  mxmoe      _mxfp4_a4w4_stage1_fw / _mxfp4_a4w4_stage2_fw              (block_m 128)
16384 heuristic  flydsl_moe1_afp4_wfp4_bf16_t64x128x256_w4_bnt0  + _atomic   (block_m 64)
16384 mxmoe      _mxfp4_a4w4_stage1_fw / _mxfp4_a4w4_stage2_fw              (block_m 128)
```

The discard warning appears in **every** heuristic rep and **no** mxmoe rep.

---

## 4. Correctness â€” and why bucket 2048 is dropped

Scored against aiter's own `op_tests/test_moe_2stage.py::test_fmoe` reference,
which quantises activations exactly as the runtime does.

**Bucket 8192 â€” clean** (arms agree to 5 s.f.):

| arm | rel_l2 | max_abs | cos_diff | NaN/Inf |
|---|---:|---:|---:|---:|
| heuristic | 0.0037471 | 32 | 7.020e-06 | 0 / 0 |
| mxmoe | 0.0037477 | 32 | 7.023e-06 | 0 / 0 |

**Bucket 16384 â€” clean, and ~29 % *better* than the heuristic** (4 seeds):

| seed | heuristic rel_l2 (max_abs) | mxmoe rel_l2 (max_abs) |
|---:|---:|---:|
| 0 | 0.0037474 (32) | 0.0026606 (16) |
| 1 | 0.0037455 (32) | 0.0026617 (16) |
| 2 | 0.0037453 (32) | 0.0026626 (32) |
| 3 | 0.0037445 (32) | 0.0026618 (16) |

**Bucket 2048 â€” REGRESSION, reproducible on every seed. This row is dropped.**

| seed | heuristic rel_l2 (max_abs) | mxmoe rel_l2 (max_abs) |
|---:|---:|---:|
| 0 | 0.0037383 (32) | **0.0103989 (296)** |
| 1 | 0.0037442 (32) | **0.0078250 (196)** |
| 2 | 0.0037512 (32) | **0.0080353 (183)** |
| 3 | 0.0037434 (32) | **0.0111927 (252)** |

Zero NaN/Inf and sane RMS, so this is a **precision regression, not corruption**.
The heuristic is rock-steady at 0.00374 / max_abs 32; the mxmoe arm at this bucket
is 2â€“3Ã— worse on rel_l2, ~6â€“9Ã— on max_abs, and **input-dependent** (high
seed-to-seed variance), while the same kernel family at 8192/16384 is stable and
at-or-below the heuristic.

### The `_nt_` hypothesis was tested and **refuted**

Bucket 2048's tuned stage2 was `_atomic_nt_` (non-temporal) while 8192's was
plain `_atomic_`. Forcing the best non-`nt` stage2 at 2048 (same g1):

| seed | `nt` rel_l2 (max_abs) | plain rel_l2 (max_abs) |
|---:|---:|---:|
| 0 | 0.010806 (256) | 0.007879 (276) |
| 1 | 0.006126 (154) | 0.005745 (138.6) |
| 2 | 0.007190 (218) | 0.006494 (138.5) |

Plain is marginally better but still 1.5â€“2Ã— the heuristic. **Non-temporal stores
are not the cause**; cost of avoiding them would have been only ~1.2â€“1.6 % perf,
but it does not fix the accuracy. Remaining (untested) hypothesis: an
accumulation-order / tail-tile effect specific to M=2048 with block_m=128
(2048/128 = exactly 16 blocks, vs 64 and 128 blocks at the larger buckets).

**Dropping bucket 2048 costs nothing versus the status quo** â€” M in (1024, 2048]
simply keeps falling back to the heuristic, which is today's behaviour.

---

## 5. Methodological traps worth recording

- **State which reference, and what error it includes, before quoting any accuracy
  number.** Three different "rel_l2" values are all legitimate and mean different
  things: kernel-vs-quantised-reference (~0.0037, discriminates a broken kernel),
  fused-vs-fp32-from-original-weights (~0.3â€“0.5, dominated by MXFP4 quantisation
  and can hide a bad kernel), and a mis-specified hand-rolled reference (garbage).
  A hand-rolled fp32 reference was discarded here after it produced `ck_rms` 703
  vs 601 **between arms** â€” a quantity the arms must agree on â€” proving it was not
  comparing like with like.
- **`errRatio 0.05`, not 0.01.** All candidates land at cosine_diff â‰ˆ 0.0118, the
  MXFP4 quantisation floor; 0.01 rejects 100 % of them. It is a step function,
  not a discrimination curve.
- **`TUNE_ONLY` gates which tuner backends are enumerated.** It defaults to
  `flydslv2`. The bf16 **a16w4** generator lives in `gen_flydsl_2stages_task` and
  is only reached with `TUNE_ONLY=flydsl`. With the default, tuning a bf16
  activation shape reports `stage1 asm tasks is 0, tasks_ck is 0` and tunes
  nothing; with `TUNE_ONLY=flydsl` the same shape enumerates 1104â€“8832 candidates
  (960 `flydsl_moe1_abf16_wfp4_bf16_*` stage1 + 256 stage2 kernels exist).
  **This is the named follow-up that would close the sub-256 decode gap.**
- **Cross-check the tuner is on the intended tuple** via its own pruner line:
  `M_est = ceil(token*topk/expert)` â†’ `ceil(2048*5/129)=80` and
  `ceil(8192*5/129)=318`, both matching the logged `M_est`.
- **Pre-warm the JIT cache** before tuning. With modules built once up front,
  tuning 2 buckets took 673 s and 1 bucket took 329 s.

---

## 6. Pre-existing dead rows (not introduced here)

- `minimax_m3_fp4_tuned_fmoe.csv` carries `q_dtype_a=fp4x2` rows for tokens
  **1â€“255** at inter 384/768. The runtime's activation-dtype bound selects
  **bf16** below 256, so those rows can never be selected.
- The **inter_dim 384** rows are unreachable for M3 at every TP, because
  `is_mxfp4_moe_shape_supported` pads 384 â†’ 512. This one is actively risky:
  384 % 256 â‰  0 makes `cktile_mxfp4_unsafe` true and triggers the FlyDSL reroute
  that a prior investigation associated with NaN and GPU faults.

Both are "tuned coverage exists on paper but not at runtime".

---

## 7. What is in this branch

- `(129, 6144, 1536, 5)` added to `MXFP4_MOE_SUPPORTED_SHAPES`
  (`aiter/ops/moe_mxfp4_aux.py`) and to the codegen `SHAPES`
  (`csrc/kernels/mxfp4_moe/moe_aux/codegen/gen_instances.py`), which the
  frozenset's own comment requires to stay synchronized. Adding the shape
  produces **no new kernel instances** â€” the aux kernels already cover it.
- Tuned rows for **buckets 8192 and 16384 only**, both verified faster **and** no
  less accurate than the heuristic. Bucket 2048 is deliberately **excluded**.
