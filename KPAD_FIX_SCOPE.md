# MXFP4 MoE non-256-aligned `inter_dim`: diagnosis and fix scope

**Author:** Aakif Nawaz <aakif.nawaz@amd.com>
**Node:** `smci355-ccs-aus-n04-05` (gfx950), container `aaknawaz_m3_oob`, one GPU (`HIP_VISIBLE_DEVICES=2`)
**aiter HEAD:** `bcb56d9c4` (never modified; all patching was in-process monkeypatching)
**Scope:** op-level only, no serving runs

---

## 0. Executive summary

| Question | Answer |
|---|---|
| Is the K-pad (`has_pad`/`i32_kpad`) lead correct? | **No.** The kernel that serves this path contains no `has_pad`/`i32_kpad` at all. The lead describes a real gap in a *different* kernel. |
| Where is the bug? | A **floor-vs-ceil disagreement in the e8m0 B-scale stride** between the host padding rule and the v1 kernel helpers, in `mxfp4_gemm_common.py:334-335`. |
| Is it fixable in FlyDSL Python? | **Partially, and not by the one-line change it first appears to be.** The one-line host fix was measured and did **not** fix the fault. |
| Should `oracle/mxfp4.py` narrow 256 → 128? | **No — not on this evidence.** |
| Is `inter_dim=384` broken? | **Only under some kernel selections.** On the default path it is clean and bitwise-reproducible. The blanket claim "384 produces NaN" is **not supported**. |

Two results here are negative, and they are the most useful part of the report: the stated lead is wrong, and the obvious fix does not work.

---

## 1. The lead is refuted

The brief pointed at `fused_moe.py:2553-2555`:

> *"This path does not thread the v2 gemm2's K-pad skip (`has_pad` + `i32_kpad`), so the pad columns would be accumulated instead of skipped."*

That comment is accurate, but it is **not about the corrupting kernel**.

`has_pad` / `i32_kpad` exist in exactly one place — the MegaMoE **comm/P2P** stage2:

- `aiter/ops/flydsl/kernels/mega_moe/gemm2.py:171,181` — `i32_kpad`, `has_pad` parameters
- `gemm2.py:225-228` — `K_real = K_rt - i32_kpad`, `halves_real`, `N_real`
- `gemm2.py:398-402` — masks B loads: `load_mask = (col < N_real) & (kt*kHalves + half < halves_real)`
- `mega_moe_stage2.py:302,384,500-501` — plumbs them through

That kernel **does** implement the K-pad skip correctly.

The kernel that actually serves the MXFP4 MoE stage2 on our path is a **different file**, and a repo-wide grep over `aiter/ops/flydsl/kernels/` returns **zero** matches for `has_pad`, `i32_kpad`, `K_real`, `N_real` outside `mega_moe/`.

So the comment describes an unfinished *feature port between two kernel families*, not the defect that corrupts. **The corrupting kernel has no pad concept at all** — it assumes `K` is a multiple of the scale-group stride and indexes accordingly.

---

## 2. There are TWO stage2 kernels, and this is the crux

This is the single most important structural fact, and it was not in the brief.

| | **v1 "native"** | **v2 "layout"** |
|---|---|---|
| File | `kernels/mxfp4_gemm2.py` | `kernels/mxmoe_gemm_v2.py` |
| Kernel name | `flydsl_moe2_afp4_wfp4_...` | `flydsl_moe2_**layout**_afp4_wfp4_...` |
| B-scale stride | **host**, compile-time | **device**, runtime |
| Rounding | **FLOOR** (buggy) | **CEIL** (correct) |
| Source | `mxfp4_gemm2.py:350-356` via `kbs_stride_n0_dw_for` | `mxmoe_gemm_v2.py:285` `kc_rt = (K_rt+255)//256` |

**v2 is already correct.** `mxmoe_gemm_v2.py:285-291`:

```python
kc_rt = _udiv(K_rt + fx.Int32(255), fx.Int32(256))   # CEIL, on device
kAS_per_chunk_dw = kc_rt * fx.Int32(64)
kBS_stride_n0_dw = kc_rt * fx.Int32(64)
kbs_per_expert_dw = _udiv(N_OUT_rt, fx.Int32(32)) * kBS_stride_n0_dw
```

**v1 is not.** `mxfp4_gemm2.py:350-356` reads the host helpers, and bakes the results into the kernel at compile time (`:372` buffer bound, `:395-396` per-expert base and stride).

---

## 3. The actual defect: floor vs ceil in the B-scale stride

The host pads e8m0 scale columns **up** to a multiple of 8 (one 256-element K group):

```python
# fused_moe.py:269-271
def _padded_scale_cols(size, group_size=32):
    return (((size + group_size - 1) // group_size + 7) // 8) * 8
```

`e8m0_shuffle` / `shuffle_scale` pads the same way, and `fused_moe.py:386-391` validates weight scales against this **padded** stride.

Kernel-side, in `aiter/ops/flydsl/kernels/mxfp4_gemm_common.py`:

```python
# :328-331  A-scale — CEIL, and someone explicitly fixed this
def kas_c_k1_for(k):
    # A scales are e8m0_shuffle'd in groups of 8 columns, so the stride rounds
    # up: k=384 has 12 valid scale columns padded to 16, not truncated to 8.
    return ((k // 32) + 7) // 8

# :334-335  B-scale — FLOOR, NOT fixed
def kbs_c_k1_for(k):
    return (k // 32) // 4 // 2
```

The comment on `kas_c_k1_for` **names the exact failing width** and explains the correct rule. Its sibling `kbs_c_k1_for` truncates. Everything downstream inherits the truncation:

- `:338-339` `kbs_stride_n0_dw_for` → per-N-block stride
- `:354-355` `kbs_per_expert_dw_for` → **per-expert base offset**
- `:362-363` `bscale_bytes_for` → **buffer descriptor bound**

### 3.1 It predicts the failing widths exactly

| K | host cols | `kas` (ceil) | `kbs` (floor) | mismatch | v1 bytes/expert | host bytes/expert | v1 correct |
|---:|---:|---:|---:|:--:|---:|---:|:--:|
| 256 | 8 | 1 | 1 | — | 49152 | 49152 | yes |
| **384** | 16 | 2 | **1** | **YES** | 49152 | 98304 | **no** |
| 512 | 16 | 2 | 2 | — | 98304 | 98304 | yes |
| **640** | 24 | 3 | **2** | **YES** | 98304 | 147456 | **no** |
| 768 | 24 | 3 | 3 | — | 147456 | 147456 | yes |
| 1024 | 32 | 4 | 4 | — | 196608 | 196608 | yes |
| 1536 | 48 | 6 | 6 | — | 294912 | 294912 | yes |

Mismatch iff `(k//32) % 8 != 0`, i.e. iff `k % 256 != 0`. **6/6 agreement with the reported failure table** — a genuine prediction, not a post-hoc fit.

### 3.2 Why this mechanism fits every previously ruled-out hypothesis

- **Not OOB into neighbours.** The per-expert base under-strides, so expert `e>0` reads **misaligned bytes inside the same `w2_scale` allocation**. Matches the 3 GB sentinel test being byte-identical for 1e30 / 0.0 / absent.
- **NaN *and* Inf.** Misread e8m0 bytes are arbitrary exponents; `0xFF` is e8m0 NaN, large exponents give Inf. Explains NaN + Inf together rather than merely wrong-but-finite values.
- **Hard faults.** `bscale_bytes_for` under-sizes the buffer descriptor bound (`mxfp4_gemm2.py:372`), so large grids walk off the descriptor → `Memory access fault`.
- **Scale-invariant.** It is an *index* bug, not a *range* bug — flat NaN fraction across a 500× input-scale sweep is expected.
- **Stage1 unaffected.** Stage1 reduces over `model_dim`; 7168/32 = 224, and 224 % 8 == 0, so no mismatch.

---

## 4. Measurements

Harness: `MODEL_DIM=6144`, `E=129`, `topk=5`, Swiglu, `per_1x32`, gfx950, one GPU.

**A methodological correction to my own first attempt:** my initial run used `w1_scale = w2_scale = torch.full(127)`. With every e8m0 scale identical, a wrong scale *index* still reads the value 127, so a stride bug is **completely invisible**. That run returned bitwise-identical results and was a **masked test, not a clean result**. All numbers below use randomised e8m0 scales in a narrow finite window (exponents 124-130, no `0xFF`), so a wrong stride reads a genuinely different value.

### 4.1 Kernel selection and results

| `inter_dim` | dispatched stage2 | result |
|---|---|---|
| **384** | `flydsl_moe2_**layout**_afp4_wfp4_bf16_t64x256x128_reduce_sbm64` (**v2, ceil**) | **NaN 0.00%, Inf 0.00% — CLEAN**, bitwise-reproducible |
| 512 | v1 native (heuristic fallback) | clean, but **non-deterministic** (§4.3) |
| **640** | v1 native (`flydsl_moe2_afp4_...`, no `_layout_`) | **HARD FAULT**, `Memory access fault by GPU node-4`, at M=4096 **and** M=128 |
| 768 | v1 native, same harness | **SURVIVED**, NaN 0.00% |

### 4.2 The control pair — this is the real result

At M=128, same kernel family, same harness, same dtypes, same randomised scales:

- **`inter=640`** (`kbs_floor=2`, `kas_ceil=3`, **mismatch**) → **hard fault**
- **`inter=768`** (`kbs_floor=3`, `kas_ceil=3`, **match**) → **survives, clean**

The only variable is the width, and the width that fails is exactly the one where floor ≠ ceil. This is a clean controlled comparison and it **supports the stride hypothesis for the v1 path**.

### 4.3 ⚠️ Non-determinism noise floor — affects other agents' conclusions

At `inter=512` (atomic epilog) I ran the **same config twice, with no patch at all**:

```
run1 == run2 bitwise: False
max_abs_diff = 256        rel = 3.597e-03
```

**The atomic-epilogue stage2 is non-deterministic across runs.** Atomics accumulate across blocks in arbitrary order.

> **Any A/B on this op must be read against a same-config noise floor of ~3.6e-3 relative / ~256 max_abs at atomic-epilogue widths. A delta at or below that is not evidence.**

I briefly misread this myself: an earlier run reported "patch changed the result" at 512, but the patch is numerically a **no-op** there (`kbs == 2` either way), so the difference was pure noise. Retracted.

**This may bear on a separate finding.** A sibling agent characterised bucket 2048 @ `inter_dim=1536` as an accuracy regression and dropped the row:

```
heuristic:   rel_l2 0.00374,  max_abs 32,       stable across 4 seeds
mxmoe@2048:  rel_l2 0.0078-0.0112, max_abs 183-296, variable across seeds
```

Their max_abs range (183-296) sits **on top of** the 256 non-determinism magnitude measured here, their tuned stage2 at that bucket is an `_atomic_nt_` variant, and the stable-32 arm is the heuristic. That is **consistent with** the "regression" being atomic-epilogue non-determinism rather than precision loss. I am **not** asserting it — their 8192 row is also `_atomic_` and came back clean and stable, which cuts against the simple version. But the same-config noise floor is the control that comparison lacked, and it should be re-run with one before the row stays dropped.

### 4.4 ❌ The obvious fix does NOT work

Monkeypatching `kbs_c_k1_for` to ceil (and re-pointing `kbs_stride_n0_dw_for`, `kbs_per_expert_dw_for`, `bscale_bytes_for`, plus every module that imported them by value):

```
inter=640 unpatched:  kbs=2  bscale_bytes=12681216  -> HARD FAULT
inter=640 patched:    kbs=3  bscale_bytes=19021824  -> HARD FAULT
```

The host numbers **did** change; the device behaviour **did not**.

My first explanation was stale kernel caching — v1 bakes strides at compile time (`mxfp4_gemm2.py:350-356`) and caches per `_tag`, and FlyDSL keeps an **on-disk** cache at `/root/.flydsl` (6.1 MB). So I re-ran with that cache **moved aside** (cold compile), both arms:

```
cold cache, patched:    STILL HARD FAULT
cold cache, unpatched:  HARD FAULT (control)
```

**This refutes the caching explanation.** A host-side stride fix alone is **not sufficient** for v1. Either the v1 kernel bakes the floor assumption somewhere my patch did not reach, or there is a **second defect** at 640. I could not separate these before the deadline.

**Do not report this as "a one-line fix, proven."** It is not.

### 4.5 ⚠️ The "384 produces NaN" claim must be narrowed

The brief reports `inter=384` → NaN 5.99% / Inf 26.77% at M=4096. **I measured 384 as clean, twice, bitwise-reproducible.**

The difference is kernel selection: my run took the tuned/heuristic default and got the **v2 layout** kernel, which is ceil-correct. The earlier NaN measurement must have pinned a **different stage2** (a v1/native or BM16 row).

> **"384 is broken" and "384 is broken under kernel X" are very different claims, and only the second is supported.**

The 16 tuned rows at `inter_dim=384` live in `configs/model_configs/kimik3_a4w4_tuned_fmoe.csv` — and note they are a **different shape** (`model_dim=3584`, `E=896`, `topk=16`), mostly BM16 `flydsl_moe2_layout_..._sbm16`. Before any alignment decision, the exact row that produced the NaN must be identified.

---

## 5. Fix scope

### 5.1 What the fix is *not*

It is **not** "thread `has_pad`/`i32_kpad` through v2 stage2". v2 is already correct, by a different and simpler mechanism (runtime ceil). Porting the comm kernel's pad-masking into v2 would add complexity to a kernel that has no bug.

### 5.2 What the fix appears to be

1. **Make `kbs_c_k1_for` ceil**, matching `kas_c_k1_for` and the host's `_padded_scale_cols` — `mxfp4_gemm_common.py:334-335`. **Measured insufficient on its own (§4.4).**
2. **Audit the v1 kernel's own indexing** — `mxfp4_gemm2.py:350-356, 372, 395-396`. Strides are compile-time constants folded into buffer descriptors and per-expert bases; the floor assumption may be encoded in more than the helper.
3. **Find the second 640 defect**, which §4.4 shows must exist or must be reachable independently of the helper.
4. **Audit every consumer** of the four helpers (`mxfp4_gemm1.py:106-114`, `mxfp4_gemm2.py:350-356`) — stage1 also uses `kas_per_chunk_dw_for`, and `fused_moe.py:2193-2202` already special-cases this padding for the intermediate buffer, showing the codebase has hit this class of bug before.

### 5.3 Honest effort estimate

- **Host helper + consumer audit:** ~0.5-1 day. Low risk, but **measured not to be sufficient**.
- **v1 kernel indexing audit and fix:** **3-7 days.** This is real FlyDSL kernel work — compile-time stride constants, buffer-resource bounds, per-expert base arithmetic, plus the unexplained 640 fault.
- **Validation:** +2-3 days. Needs every width × BM × epilog × dtype combination, **and** a non-determinism-aware comparison methodology (§4.3) which does not currently exist in the test harness.

**Realistic total: 1-2 weeks**, with genuine risk it is longer, because the one clean experiment that should have confirmed the mechanism did not.

**A cheaper alternative worth considering first:** since **v2 is already correct**, route all non-256-aligned `inter_dim` to the v2 layout gemm2 and forbid v1 for those shapes. That converts a kernel-arithmetic bug into a dispatch guard — hours rather than weeks — and mirrors what `cktile_mxfp4_unsafe` already does for CK-Tile. The existing guard prevents an unsafe *path*; this would extend the same idea to the v1 FlyDSL path.

### 5.4 Risks

- The 640 fault is **unexplained after the stride fix**. Any estimate that assumes the helper is the whole story is unsafe.
- Changing `bscale_bytes_for` changes an **allocation size contract** shared with stage1 and the host validator — a fix that widens the stride without widening every allocation trades a fault for silent corruption.
- The atomic epilog is non-deterministic, so "did the fix work?" cannot be answered bitwise at those widths.

---

## 6. The prize, stated honestly

If fully fixed, `oracle/mxfp4.py` could narrow 256 → 128, TP8 would dispatch 384 instead of 512: **−25% MoE FLOPs and expert-weight bytes, ~8.5 GB/GPU freed.** Against a prior measurement of ~2.3% e2e at ~30% kernel-to-e2e conversion — real, not enormous.

**Recommendation: do not narrow the alignment now.** Reasons:

1. The fix is **not proven** — the one decisive experiment failed (§4.4).
2. The headline "384 is broken" is **not reproducible on the default path** (§4.5); the failure is kernel-specific and the responsible row is not yet identified.
3. This is a **vLLM-side change that must not land before the aiter fix is merged**, or anyone who takes it gets the NaN.

### 6.1 The standing hazard — must be part of any recommendation

The tuned rows aiter ships at `inter_dim=384` are **reachable, fast, and were reported to produce NaN**. They are latent traps that go live the moment anyone narrows the alignment.

Given §4.5, the hazard is now **more precisely scoped and no less serious**: the danger is not the width itself but **specific (width, kernel) pairs**. Required regardless of whether the alignment is ever narrowed:

1. **Identify exactly which tuned 384 rows produce NaN, and under which stage2 kernel.** Until then neither "these rows are broken" nor "these rows are fine" is supported.
2. **Add a correctness gate to the tuner.** These rows were tuned on speed and shipped while numerically wrong; a fast NaN-producing row is worse than no row. This is the root process failure and it will recur at other widths.
3. **Extend the `cktile_mxfp4_unsafe` pattern** to reject unsafe *shapes* on the v1 FlyDSL path, not merely steer away from one unsafe path.

---

## 7. Reproduction

```bash
# floor/ceil asymmetry, no GPU needed
python3 -c "
def padded(s,g=32): return (((s+g-1)//g+7)//8)*8
def kas(k): return ((k//32)+7)//8
def kbs(k): return (k//32)//4//2
for K in (256,384,512,640,768,1024,1536):
    print(K, padded(K), kas(K), kbs(K), 'MISMATCH' if kas(K)!=kbs(K) else '')
"

# control pair (one GPU, ~2 min each)
HIP_VISIBLE_DEVICES=2 KP_M=128 KP_INTER=640 python3 kpad_exp5.py   # FAULTS
HIP_VISIBLE_DEVICES=2 KP_M=128 KP_INTER=768 python3 kpad_exp5.py   # SURVIVES

# non-determinism noise floor
HIP_VISIBLE_DEVICES=2 KP_M=4096 KP_WIDTHS=512 python3 kpad_exp3.py # run1 != run2
```

Scripts: `kpad_exp2.py` (randomised scales A/B), `kpad_exp3.py` (determinism control), `kpad_exp4.py` (640 patched/unpatched), `kpad_exp5.py` (stage isolation).

---

## 8. Conclusions

1. **The K-pad lead is refuted.** `has_pad`/`i32_kpad` live only in the comm/P2P stage2; the kernel serving this path has no pad concept.
2. **There are two stage2 kernels.** v2 (`mxmoe_gemm_v2.py`) derives the B-scale stride on device as ceil and is correct. v1 (`mxfp4_gemm2.py`) takes it from a host helper that floors.
3. **The defect is `kbs_c_k1_for`'s floor** vs `kas_c_k1_for`'s ceil and the host's `_padded_scale_cols` — `mxfp4_gemm_common.py:334-335`. It predicts the failing widths 6/6 and explains NaN, Inf, hard faults, scale-invariance and the sentinel result.
4. **The one-line fix does not work.** Measured, including with a cold kernel cache. A second defect exists or the assumption is baked deeper.
5. **`inter_dim=384` is clean on the default path.** The blanket NaN claim is unsupported and must be narrowed to specific kernel selections.
6. **The atomic epilog is non-deterministic** at ~3.6e-3 relative / ~256 max_abs — a noise floor that may invalidate at least one other accuracy conclusion.
7. **Do not narrow the alignment.** Fix scope is realistically 1-2 weeks; a dispatch guard routing non-aligned widths to the already-correct v2 kernel is a far cheaper first move.
