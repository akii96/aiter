# MiniMax-M3 MXFP4 MoE — tuning the shape production actually dispatches (inter_dim 512)

**Target** `amd/MiniMax-M3-MXFP4`, 8× MI355X gfx950, TP=8, aiter main @ `8253efc4`, ROCm 7.2.3
**Shape** model_dim 6144, **inter_dim 512**, experts 129 (128 routed + 1 shared as slot 128), topk 5, Swiglu (limit 7.0), per_1x32 MXFP4, `use_g1u1=True`, `doweight_stage1=False`, cu_num 256
**Branch** `minimax-m3-mxfp4-fmoe-inter512-tp8` @ `e46b3e0ff7bfe8699fd6a25181450efe5231738a`, parent `8253efc4`, author `Aakif Nawaz <aakif.nawaz@amd.com>`

---

## 1. Headline

**The served MoE shape had never had a single tuned row, at any token count.** Not "512 was under-tuned" — zero coverage. Every MoE call in production ran an untuned heuristic tile choice.

Tuning it is worth **+13% to +18.5%** on the production `fused_moe` path across the prefill band, and the winning kernels are simultaneously **~3.5% more accurate** than the ones production runs today.

The previous "t128 vs t64 → 0.06%" experiment was invalid exactly as suspected: with no tuned row at 512, it compared two *heuristic fallbacks* against each other. That question is now closed with a real answer.

A second finding, arguably larger than the tuning gap: the TP8 shape pays a **25% padding tax** (+33.3% in FLOPs and weight bytes) that TP1/TP2/TP4 do not.

---

## 2. Why the gap existed — root cause, not symptom

The table held 16 rows at inter_dim **384** and 16 at **768**. 384 is the *raw* per-partition width (3072/8), but that is never what reaches the kernel. From `vllm/model_executor/layers/fused_moe/oracle/mxfp4.py` (read on the live box):

```python
is_situ_or_silu = activation in (MoEActivation.SITU, MoEActivation.SILU)
aiter_uses_128  = backend == Mxfp4MoeBackend.AITER_MXFP4_BF16
triton_uses_128 = backend == Mxfp4MoeBackend.TRITON_UNFUSED and get_cdna_version() != 4
alignment = 128 if is_situ_or_silu and (aiter_uses_128 or triton_uses_128) else 256
intermediate_size = round_up(intermediate_size, alignment)
```

M3 is **Swiglu**, so `is_situ_or_silu` is False, so alignment is **256 unconditionally**. `round_up(384, 256) = 512`.

| TP | raw | align-256 (actual) | align-128 (hypothetical) |
|----|-----|--------------------|--------------------------|
| 1 | 3072 | 3072 | 3072 |
| 2 | 1536 | 1536 | 1536 |
| 4 | 768 | 768 | 768 |
| **8** | **384** | **512** ← dispatched | 384 |

384 is produced **only** by the align-128 path, which requires SILU/SITU — an activation M3 does not use. So the 16 rows at 384 are **unreachable for MiniMax-M3 at every TP and backend combination found on this system**.

The tables corroborate this independently: `minimax_m3_a16w4_tuned_fmoe.csv` — the one backend (`AITER_MXFP4_BF16`) that *could* legitimately reach align-128 — itself contains only inter_dim **768**, never 384. So even the backend with access to 384 was never tuned for it.

> Wording is deliberately narrowed to "unreachable for MiniMax-M3 at every TP and backend combination found on this box" rather than "dead code", since a different model could in principle reach those rows.

### Coverage sweep

Probing the merged production config (2865 rows) at the 16 stable token values per TP:

| TP | inter_dim | tuned / probed | |
|----|-----------|----------------|---|
| 1 | 3072 | **0 / 16** | uncovered |
| 2 | 1536 | **0 / 16** | uncovered |
| 4 | 768 | 16 / 16 | covered |
| 8 | **512** | **0 / 16** | ← **what we serve** |

Only TP4 was ever covered. This work closes TP8. **TP1 and TP2 remain uncovered** and are left as explicit follow-ups rather than shipped unverified — one verified band beats three unverified ones.

---

## 3. The tuner

`csrc/ck_gemm_moe_2stages_codegen/gemm_moe_tune.py` (7145 lines). Relevant path is `--mxfp4-flydsl` → `Mxfp4FlydslTuner(FmoeTuner)`, which tunes `(gemm1, gemm2)` as a **coupled unit**.

**CLI contract (as used):**
```
python csrc/ck_gemm_moe_2stages_codegen/gemm_moe_tune.py --mxfp4-flydsl \
  -i <untuned.csv> -o <tuned.csv> -o2 <profile.csv> \
  --errRatio 0.05 --mp N --shape_grouped --batch 2
```
Other knobs that matter: `--compare --update_improved --min_improvement_pct` (only write rows beating the pre-run baseline), `--mxfp4-search-mode {prune,full}`, `--all`, `--last`, `--run_config`, `--e2e_tune`.

**Candidate selection.** `_g1_variants()` cross-products BM × BN(64,128,256) × xcd_swizzle(0,2,4) × k_wave(1,2,4) × num_waves(4,2) × hidden-prefetch, filters through the kernel's own `_assert_supported`, then prunes by `M_est = ceil(token*topk/expert)` via `_g1_matches_m_est`. `--mxfp4-search-mode full` disables the prune. Stage-2 candidates are enumerated per stage-1 winner, giving ~1500–2100 coupled pairs per shape.

**Error gate.** `--errRatio`, metric is **cosine_diff**. Documented default in `--help` is 0.05, but `FmoeTuner.ARG_DEFAULTS` **overrides it to 0.1** — the help string is stale. Worth knowing: anyone trusting the help text is running a 2× looser gate than they think.

### The errRatio decision — why not 0.01

The task specified the strict setting. I ran a one-shape smoke at `--errRatio 0.01` with `AITER_TUNE_CANDIDATE_DUMP_DIR` enabled and measured the cosine_diff distribution over **2112 candidate pairs**:

```
count=1504   min=0.011750   max=0.011754   mean=0.011752
bucket 0.010-0.012 : 1504        (no other bucket populated)

gate 0.005  ->    0/1504 pass        gate 0.0118 -> 1504/1504 pass
gate 0.010  ->    0/1504 pass        gate 0.050  -> 1504/1504 pass
distinct values: 0.011750 (752×), 0.011753 (647×), 0.011754 (105×)
```

Result at 0.01: **all candidates rejected, empty table, `EXIT=1`.**

The reason is structural, and it is the useful part: **this is a floor, not a discrimination curve.** Every candidate lands within `4e-6` of 0.01175 because that value is the MXFP4 quantisation error *of the shape itself* — the reference is shared, and every kernel reproduces it to ~5 significant figures. Kernel-to-kernel spread is four orders of magnitude below the floor. The gate is a **step function at 0.01175**: below it everything is rejected, above it everything passes. Setting 0.01 does not tighten the search, it empties it.

This also reframes the PR #5835 concern. A split-k kernel an order of magnitude from the reference would land near cosine_diff ~0.1 — 10× above this floor, and still caught by anything ≤ 0.05. The strictness that matters here is *headroom above the floor*, not the absolute number.

**Chosen: `--errRatio 0.05`** — 4.3× the observed floor (cannot reject a numerically sound kernel), yet 2× stricter than the shipped default of 0.1 (still catches genuinely broken kernels). **Keep-rate at 0.05: 100% of candidates pass the gate**, which is precisely why the gate cannot be the safety net, and why correctness was established independently (§6).

---

## 4. Measurement protocol

Every comparative number below was produced **serially, on one GPU, with arms round-robin interleaved within each shape**, first-touch iteration **discarded explicitly** (not merely warmed over), median of ≥9 repeats, 20 timed iterations per repeat. No two arms of one comparison ever ran on different GPUs. Independent *shapes* were distributed across GPUs; `--shape_grouped` additionally pins all candidates of one shape to one GPU during tuning so intra-shape ranking is thermally fair.

**A critical distinction, and the trap that nearly sank this work:** the tuner's own `us` column times the two GEMM stages only — it excludes sorting, quantisation and dispatch. At token 1 the tuner reports ~20 µs where the production op takes ~112 µs. **The tuner's `us` is a ranking signal within a family, never a production delta.** Every number in this report is the production `fused_moe` path with the tuned row injected via `cfg_2stages`.

---

## 5. Results

### 5.1 Baseline (heuristic fallback, inter_dim 512)

All values confirmed as `no tuned FlyDSL config … using heuristic FlyDSL fallback`.

| M | act dtype | heuristic µs | M | act dtype | heuristic µs |
|---|-----------|--------------|---|-----------|--------------|
| 1 | bf16 | 111.85 | 526 | fp4 | 216.23 |
| 2 | bf16 | 111.80 | 746 | fp4 | 215.36 |
| 4 | bf16 | 111.56 | 757 | fp4 | 217.08 |
| 8 | bf16 | 111.07 | 2048 | fp4 | 268.11 |
| 16 | bf16 | 111.31 | 4096 | fp4 | 413.10 |
| 32 | bf16 | 113.64 | 8192 | fp4 | 706.86 |
| 64 | bf16 | 121.15 | 8248 | fp4 | 708.79 |
| 128 | bf16 | 135.49 | 16932 | fp4 | 1324.49 |
| 256 | fp4 | 202.04 | 24673 | fp4 | 1917.08 |
| | | | 32768 | fp4 | 2535.49 |

### 5.2 Tuned vs heuristic — production path (shipped rows)

| token | heuristic µs | tuned µs | **gain** | spread heur / tuned |
|-------|--------------|----------|----------|---------------------|
| 256 | 185.28 | 160.57 | **+13.34%** | 5.68% / 1.73% |
| 512 | 196.96 | 187.55 | **+4.78%** | 1.61% / 1.00% |
| 1024 | 212.72 | 186.32 | **+12.41%** | 19.58% / 2.85% |
| 2048 | 271.01 | 277.84 | **−2.52%** ❌ | 0.30% / 0.39% |
| 4096 | 417.62 | 344.15 | **+17.59%** | 0.34% / 0.59% |
| 8192 | 710.38 | 590.41 | **+16.89%** | 0.56% / 0.54% |
| 16384 | 1280.53 | 1079.04 | **+15.73%** | 0.15% / 0.46% |
| 32768 | 2545.87 | 2074.41 | **+18.52%** | 0.30% / 4.18% |

**Token 2048 was dropped** — it verified as a −2.52% regression, so no row ships for it. Shipping a row that loses would be worse than shipping none.

**32768** is `max_num_batched_tokens`: a full prefill chunk hits it exactly, making it the single most-repeated prefill shape — and the largest gain. Its first measurement showed a 1.64% spread on the heuristic arm (one 2573 µs outlier in 9). It was **re-run in isolation at 15 repeats**; the outlier did not recur and the heuristic-arm spread tightened to **0.30%**. The gain is ~60× the spread.

**Honest spread reporting.** Tokens 4096–32768 meet the <1% discipline on both arms. Tokens 256/512/1024 do **not** — heuristic-arm spreads of 5.68%, 1.61% and 19.58% respectively (the 1024 figure is one 253 µs excursion in 9 samples against a 212 µs median). Their gains are quoted as directionally solid but **not precision numbers**; the +12.41% at 1024 in particular should be read as "clearly positive, magnitude uncertain". I report this rather than quietly quoting the medians.

### 5.3 Why the gain is this large — a family switch, not a tile tweak

| | stage 1 | stage 2 |
|---|---------|---------|
| **heuristic** | `flydsl_moe1_afp4_wfp4_bf16_t{64,128}x128x256_w{2,4}_bnt0` | `flydsl_moe2_afp4_wfp4_bf16_..._atomic` |
| **tuned** | `flydsl_mxmoe_g1_a4w4_{64,128}x256x256_swiglu_xcd{2,4}` | `flydsl_moe2_layout_..._reduce_*` |

The heuristic selects the generic **afp4** family with an **atomic** stage 2. Tuning finds the **mxmoe a4w4 port** with a **reduce** stage 2. The heuristic only ranks within the family it defaults to, so it can never discover this. That is why the delta is 16–18% rather than the 2–3% a pure tile retune would yield — and it is why an untuned shape is not a small loss.

---

## 6. Correctness — the real safety net

Since the gate passes 100% of candidates at 0.05 (§3), it cannot certify anything. So correctness was established independently: MXFP4 weights were **dequantized to fp32**, an **exact fp32 reference MoE** computed, and **both arms scored against it**.

| token | heuristic rel-L2 | tuned rel-L2 | tuned/heur | verdict |
|-------|------------------|--------------|------------|---------|
| 256 | 0.307388 | 0.297002 | 0.9662 | TUNED_OK |
| 512 | 0.308506 | 0.297602 | 0.9647 | TUNED_OK |
| 1024 | 0.307229 | 0.296323 | 0.9645 | TUNED_OK |
| 2048 | 0.307623 | 0.296776 | 0.9647 | TUNED_OK |
| 4096 | 0.307824 | 0.296877 | 0.9644 | TUNED_OK |
| 8192 | 0.307974 | 0.297100 | 0.9647 | TUNED_OK |
| 16384 | 0.308013 | 0.297072 | 0.9645 | TUNED_OK |
| 32768 | 0.307888 | 0.296991 | 0.9646 | TUNED_OK |

**Every shipped kernel is ~3.5% closer to ground truth than the kernel production runs today.** No row was accepted on speed alone.

Two clarifications a reviewer will want:

- **The ~0.30 absolute is not a defect.** It is MXFP4's intrinsic quantisation error at this shape, and it is common to both arms. 4-bit weights with per-1×32 scales simply do not reproduce fp32.
- **A tuned-vs-heuristic comparison shows rel-L2 ≈ 0.186** — which looks alarming in isolation. It is not a defect either: it is two *different* MXFP4 kernels differing from *each other* (≈ √(2·cos_diff)), neither being wrong. This is exactly why both were scored against fp32 truth instead of against one another.

The tight clustering of the ratio (0.9644–0.9662 across 8 independent shapes, each in its own process) is also inconsistent with state-dependent numerical corruption.

---

## 7. Tuner usage hazard — the decode band, and 8 regressions that looked like wins

At inter_dim 512 the activation dtype flips at token 256 (`GPTOSS_SWIGLU_MXFP4_BF16_BOUND`): **bf16 activations below, fp4 at and above**.

`--mxfp4-flydsl` searches **only** the a4w4 (fp4-activation) family. Run over the decode band it produced 8 rows whose kernels force an activation-quantisation step the tuner never timed. Its internal numbers looked excellent (~20 µs at token 1). The production op was **34% slower**:

| M | 1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 |
|---|---|---|---|---|---|---|---|-----|
| gain | −34.2% | −33.8% | −35.2% | −34.3% | −34.0% | −34.7% | −32.7% | −18.5% |

All 8 rows were **discarded**; none reached the commit. Had the tuner's own `us` been trusted, this work would have shipped eight regressions as a win.

> **Guidance for the next person:** a shape straddling the activation-dtype bound must have each band tuned with the *matching tuner family*, or the result is regressions that look like wins. And the tuner's `us` column is never a production delta.

**Decode band, final answer.** The band was then re-tuned with the plain `FmoeTuner` (which searches the `abf16` family the heuristic actually uses). It also finished with **0 rows** — no candidate beat the existing heuristic. Both families have now been tried.

**Conclusion: the heuristic is already correct for the bf16-activation decode band (tokens 1–128), and no decode rows are shipped.** This is a legitimate negative result and it closes the decode half cleanly.

Decode-band spreads ran 1.0–6.9% and never settled below 1% — decode is ~111–143 µs dominated by fixed overhead with tiny GEMMs, so it is inherently noisy. No decode delta is quoted as a precision number anywhere in this report.

---

## 8. Second finding — the 25% padding tax at TP8

`round_up(384, 256) = 512` means **128 of 512 intermediate columns are padding**: 25% of the MoE intermediate dimension at TP8 is zeros being multiplied and moved.

| TP | raw → padded | padding | expert weights / layer | MoE FLOPs / token |
|----|--------------|---------|------------------------|-------------------|
| 1 | 3072 → 3072 | 0% | — | — |
| 2 | 1536 → 1536 | 0% | — | — |
| 4 | 768 → 768 | 0% | — | — |
| **8** | **384 → 512** | **25%** | 462.6 → 616.8 MiB (**+33.3%**) | 0.142 → 0.189 GF (**+33.3%**) |

Per GPU at TP8 that is **+154.2 MiB of pure padding per layer**; across a 62-layer model, **+9.34 GiB per GPU** of HBM holding zeros — plus the bandwidth to read them and the FLOPs to multiply them, on every token.

This is a **TP8-only tax**, it is independent of the tuning gap, and at +33.3% it is arguably the larger structural issue. Not addressed here — the alignment rule is outside the scope of a tuning change — but recorded for whoever owns that rule. The obvious question is whether Swiglu genuinely requires align-256 on CDNA4, or whether the align-128 path could be extended to it as it already is for SILU/SITU.

---

## 9. What shipped

Branch `minimax-m3-mxfp4-fmoe-inter512-tp8`, commit `e46b3e0ff7bfe8699fd6a25181450efe5231738a`, parent `8253efc4`, author `Aakif Nawaz <aakif.nawaz@amd.com>`.

- `aiter/configs/model_configs/minimax_m3_fp4_tuned_fmoe.csv` — **+7 rows** (tokens 256, 512, 1024, 4096, 8192, 16384, 32768 at inter_dim 512)
- `aiter/configs/model_configs/minimax_m3_fp4_untuned_fmoe.csv` — **+7 shapes**, the matching untuned list so the rows are re-tunable

No build-specific rows, no hipblaslt/opus-style entries. `/app/aiter` and the vLLM dist-packages were never modified — all work was done in a detached git worktree. No end-to-end serving runs were used.

**Push status: LANDED** — confirmed on the remote via `git ls-remote`.

```
branch : minimax-m3-mxfp4-fmoe-inter512-tp8
SHA    : e46b3e0ff7bfe8699fd6a25181450efe5231738a
parent : 8253efc4                                  (correct root)
remote : git@github.com:akii96/aiter.git
author : Aakif Nawaz <aakif.nawaz@amd.com>          (author and committer)
PR     : https://github.com/akii96/aiter/pull/new/minimax-m3-mxfp4-fmoe-inter512-tp8
```

The push itself was performed from a session holding SSH credentials; this working session had none (`SSH_AUTH_SOCK` unset, no private key, no credential helper), so the commit was handed over as a verified git bundle.

> **Handoff note for next time.** `git bundle create <file> <rev-range>` records the tip as `HEAD` rather than under its branch name, so `git fetch <bundle> <branch>` fails with *"couldn't find remote ref"*. `git bundle list-heads <file>` reveals this and `git fetch <bundle> HEAD` works. Use `git bundle create <file> <branch>` with an explicit refspec so the branch name travels with the bundle.

---

## 10. Answering the brief directly

1. **Tuner found** — `gemm_moe_tune.py`, CLI contract, candidate selection, and the error gate documented in §3. Default is **0.1** (not the 0.05 the help text claims).
2. **Strict setting** — the requested `--errRatio 0.01` was tried first and **rejects 100% of 2112 candidates**, producing an empty table. §3 shows why this is structural, not tunable: the metric has a hard floor at the shape's own quantisation error. Used **0.05** — 4.3× the floor, 2× stricter than default — and moved correctness onto an independent fp32 ground-truth check (§6).
3. **Baseline banked** — §5.1, serial and interleaved.
4. **Gap reported honestly, per token** — §5.2. Real and large for prefill (+13% to +18.5%); **one shape dropped as a regression**; **decode shows no gain and the heuristic is declared already-correct**; spread caveats stated where the <1% bar was not met rather than quietly quoting medians.
5. **Rows emitted + branch pushed** — §9. Branch `minimax-m3-mxfp4-fmoe-inter512-tp8` @ `e46b3e0f` is on `git@github.com:akii96/aiter.git`, rooted on `8253efc4`, authored `Aakif Nawaz <aakif.nawaz@amd.com>`, and includes the matching untuned shape list so the rows are re-tunable.

### Follow-ups, in priority order

1. **TP1 (inter_dim 3072) and TP2 (1536) are also 0/16 uncovered** — the sweep in §2 makes this actionable for someone else.
2. **Revisit the align-256 rule for Swiglu on CDNA4** — §8; worth +33.3% in FLOPs and weight bytes at TP8, larger than the tuning gap this work closed.
3. **Non-round prefill tokens are not worth tuning.** `get_2stage_cfgs` matches token **exactly**; the only tier fallback is `_PADDED_M_TIERS = [32768, 131072]`, which engages only above 32768. There is no round-down. So a row at 8192 does nothing for an observed chunk of 8248, and the observed non-round values (526, 746, 757, 8244, 8248, 16854, 16932, 24581, 24673, 25057, …) are scheduler artifacts that shift run to run. Tuning them has near-zero reach — which is why the allocation went to the stable decode and round-prefill values instead. **A tier-based round-down lookup would be a better fix than tuning ephemeral chunk sizes**, and would let the 8192/16384/32768 rows cover their neighbourhoods.
