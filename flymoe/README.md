# FlyMoE: A4W4 (MXFP4) FlyDSL MoE for MiniMax-M3 on gfx950

This is a standalone, from-scratch MoE kernel family. It depends only on the FlyDSL compiler and torch. It reuses no AITER kernels, sorting, weight shuffles or dispatch.

Target shape (MiniMax-M3-MXFP4, with the shared expert fused):

| | |
|---|---|
| Hidden size H | 6144 |
| Experts E | 129 (128 routed + 1 shared) |
| topk | 5 |
| Intermediate I (TP2 / TP4 / TP8) | 1536 / 768 / 384, all native |
| Activations and weights | fp4 e2m1 |
| Scales | e8m0 per 1x32 group |
| Activation function | SwiGLU-OAI (alpha 1.702, limit 7, gate and up packed as `[gate; up]`) |

## Zero padding

- **Weights and scales are stored at their true shapes.** Our own layout is MFMA-native. K is always a multiple of 128 and N a multiple of 64 at every MiniMax-M3 width, so nothing is padded. TP8 runs at 384, not 512.
- **Rows are compact.** There are exactly `T*topk` expert-sorted rows, with no rounding up to `block_m` in memory. Padding rows never touch HBM: no loads, no stores.
- **Activations are quantized once per token**, not once per (token, expert) pair.
- **Tail tiles cost compute, not bytes.** Rows past a tile's `nrows` are never loaded from HBM (out-of-bounds DMA returns zeros) and never stored. The MFMA work is a different story:
  - **Without skipping, a tail tile runs full BM.** With BM=256 that wastes about 10% of stage-1 MFMA rows at T=32768 and about 45% at T=4096.
  - **`diag=skip` skips MFMAs row block by row block** (16-row granules, wave-uniform), so waste drops to under one 16-row block per tile. It measures −5 to −10% at T=4096–8192 and 0 to +2% at T=32768, where tail tiles are rare, so it is chosen per bucket.
  - **A separate small-tile launch for the tails (`TB`) was measured slower everywhere.** The tail kernel is far less efficient per row, and it runs after the main kernel.

  In the streaming band (32–256 tokens) the kernel is limited by HBM, so idle MFMA lanes cost little there. Masked rows move no bytes, but they still take MFMA slots and still issue their (out-of-range) DMA instructions. At BM=16 and T=32, about 90% of stage-1 MFMA rows are masked.

## Pipeline (all FlyDSL kernels)

`forward()` allocates nothing and never syncs with the host. `MoERun(..., validate=True)` runs host-side routing checks once, at construction.

| Kernel | File | What it does |
|---|---|---|
| K0 quant | `prologue.py` | bf16 to MX fp4. Bit-exact with `mx.quant`. With the default `SR="even"` it matches AITER's runtime `dynamic_mxfp4_quant` (see "Scale rule"). |
| K0 plan | `prologue.py` | Parallel counting sort in 3 launches (histogram with atomic CTA bases, prefix plus tile lists, scatter). Produces compact rows, per-BM tile lists and the inverse map. |
| K1 | `gemm.py` stage 1 | Gathered-A gate/up GEMM. SwiGLU and fp4 requantization of h happen in registers; the W13 column interleave puts gate and up for two adjacent columns in each lane. |
| K2 | `gemm.py` stage 2 | Down GEMM. The topk weight is applied in the epilogue, and output is bf16 per compact row. |
| Combine | `combine.py` | Deterministic sum of each token's 5 rows in fixed slot order. |

GEMM template knobs:

| Knob | Values | Meaning |
|---|---|---|
| `BM` | 16–256 | rows per tile |
| `NW` | 1, 2, 4 | waves per CTA; each wave owns 64 output columns |
| `pipe` | `async` | async global-to-LDS DMA ring for A, B and scales |
| | `hybrid` | A through an async LDS ring, B straight to VGPRs, prefetched |
| | `regs` | register-staged pipeline |
| `D` | integer | pipeline depth |
| XCD remap | on/off | keeps each XCD's work contiguous so an expert's weights stay in one L2 |

`flymoe.configs.select_cfg(I, T)` returns `MoERun` kwargs for any T: the smallest tuned power-of-two bucket ≥ T, clamped to 32–32768. It reads `configs/tiles_v4_I{384,768,1536}.json`. Those tables started from `bench/tune.py` picks and were then curated by serial A/B, and `tests/test_tables.py` checks every cell. Older tables (`tiles_I*`, `tiles_v2_*`, `tiles_v3_*`) are kept for the frozen comparisons.

## Correctness

Every test compares against our own torch reference (`ref.py`), which quantizes exactly like the kernels. With `SR="even"` it quantizes the way the checkpoint and AITER's runtime do. Each test checks both the whole-tensor `rel_l2` and the worst single row, so a few corrupt rows can't hide.

- **`tests/test_moe.py`:**
  - quant is bit-exact under both scale rules;
  - T = 1, 7, 256, 1000 by default (others via `--T`), all three epilogues, plus all tokens routed to one expert;
  - `rel_l2` is about 1e-8 with the fp32-atomic epilogue, and 2.3e-3 on the bf16 output paths (bf16 rounding).
- **`tests/test_variants.py`:** `async` / `regs` pipes, BM 16–256, NW 1–4, mixed BM between stages.
- **`tests/test_options.py`:** every tunable option at T = 5, 300, 4097, all three widths: `pingpong`, `hybrid2`, `skip`, `ilm0`, `uni`, `nos2w`, `wpe3`, `s2nt`, HT, FC, HT+FC, TB1/TB2 tails, QAST, PERS, BM1 ≠ BM2.
- **`tests/test_tables.py`:** every shipped table cell, selected via `select_cfg`, at the bucket T, one below it and a ragged T inside the bucket, plus skewed routing.
- **`tests/test_large.py`:** T=40000 (R·H·2 > 2³¹), including HT+FC.
- **`tests/probe_mfma.py`:** pins down the scaled fp4 MFMA lane, scale and opsel layout.

Not covered yet: real checkpoint weights end to end, CUDA/HIP graph capture and replay, and k ≠ 5 or E ≠ 129.

## Round 1 performance (historical: v1 code, v1 configs)

MI355X, one GPU, median of 7 × 10 launches. Times are in µs and exclude the prologue, which is reported separately. It's unknown whether AITER's CSV times include its sort and quant, so the AITER columns below may not be like-for-like. They cover K1 + K2 + combine. AITER numbers come from AITER's own tuned CSV (`minimax_m3_fp4_tuned_fmoe.csv`) for 384/768 and from `FLYDSL_MOE_REQUIREMENTS.md` for 512 and 1536. They were not re-timed in this session.

| T | I=384 flymoe | AITER@384 (raw rows) | AITER@512 (what vLLM dispatches for TP8) |
|---:|---:|---:|---:|
| 32 | 64.9 | 57.1 | – |
| 256 | 93.7 | 82.7 | – |
| 2048 | 173 | 173 | – |
| 4096 | 279 | 272 | 313.8 |
| 8192 | 486 | 501 | 544 |
| 16384 | 880 | 892 | 1008 |
| 32768 | 1754 | 1692 | 1901 |

| T | I=768 flymoe | AITER@768 | I=1536 flymoe | AITER@1536 |
|---:|---:|---:|---:|---:|
| 32 | 115 | 162 | 232 | – |
| 2048 | 300 | 258 | 509 | – |
| 8192 | 757 | 685 | 1270 | 1162 |
| 16384 | 1373 | 1203 | 2216 | 2035 |
| 32768 | 2606 | 2188 | 4118 | 3586 |

Prologue (quant + plan): about 21 µs at T=32, 40 µs at 4096 and 119 µs at 32768.

## Where it stood after round 1 (historical)

- **TP8.** Parity with AITER's raw-384 rows (which vLLM never reaches today). About 10–15% faster than the 512-padded path vLLM actually runs.
- **TP4 and TP2.** 10–20% behind AITER at large T.
- **Stage 1 plateaus at about 2.7 PF.** The next levers:
  - Put accumulators in AGPRs so 2 waves fit per SIMD.
  - Cut to one barrier per 2 K steps.
  - Use a 2x2 wave layout to raise MFMA density per LDS read.
  - Add `sched_group_barrier` interleaving.
- **Stage 2 plus combine is dominated by the `[T*5, H]` bf16 row round trip** (2 GB each way at 32k). The combine already runs at about 5.6 TB/s. Beating it means not materializing those rows:
  - token-chunked scheduling so they stay in the Infinity Cache, or
  - the fused E4 experiment. That is gated first on the shared-expert load-imbalance test at T=32768.
- **Streaming band (32–256 tokens).** About 10–15% behind at I=384. Candidates: split-K for stage 1, and a persistent weight-streaming variant.
- **Not measured yet:**
  - the null-arm A/B for each micro-flag (non-temporal loads, `s_setprio`), as the plan requires;
  - a live AITER re-time under the same harness;
  - end-to-end served-model quality.

## Run

```bash
# inside the container, from this directory
HIP_VISIBLE_DEVICES=0 python tests/test_moe.py --I 384 768 1536
HIP_VISIBLE_DEVICES=0 python tests/test_variants.py
HIP_VISIBLE_DEVICES=0 python bench/bench_moe.py --T 32 4096 32768 --I 384
HIP_VISIBLE_DEVICES=0 python bench/tune.py --I 384
```


## Round 2 (v3) vs frozen v1 (tag `flymoe-v1`)

Measured serially on one GPU with `bench/compare_v1.py`: arms run round-robin, with a null arm (v1 vs v1). Times cover prologue + K1 + K2 + combine. The output is bit-identical to v1 in every cell. Small T (≤ 512) is within noise at all widths.

| T | I=384 v1 -> v3 | I=768 v1 -> v3 | I=1536 v1 -> v3 |
|---:|---:|---:|---:|
| 4096 | 317 -> 299 (+5.7%) | 486 -> 463 (+4.8%) | 782 -> 727 (+7.0%) |
| 32768 | 1971 -> 1756 (+10.9%) | 2760 -> 2531 (+8.3%) | 4426 -> 3859 (+12.8%) |

Stage 1 alone at T=32768 is down 20–29% (I=1536: 2448 -> 1741 µs, 3.55 PF). Most of those levers came from rocprofv3 counters and thread traces:

| Lever | Stage-1 effect |
|---|---|
| Ping-pong schedule (2x4 waves, 256x256 CTA tile; wave-rows alternate MFMA and memory phases) | -10 to -14% |
| Fast SwiGLU epilogue (exp2 + hardware rcp, DPP amax) | -5 to -10% |
| A-tile LDS swizzle `xor((row>>1)&3)` | bank conflicts 1.03e8 -> 0 |
| `amdgpu-agpr-alloc=0`, attached to the lowered `llvm.func` (no AGPR<->VGPR accumulator copies) | -2 to -4% |
| K-step-major compact A scales (1 contiguous DMA instead of a 4 B-per-row gather) | -6 to -8% |
| Per-kind LDS ring layout (every LDS read = base + immediate) | memory-phase VALU 21 -> 1 |
| Ring depth 4 | -2 to -4% |
| LDS operand reads issued before the DMA | -2 to -8% |

Measured dead ends: GM rasterization, L2 touch-prefetch (hits the register cap and spills), DMA issue interleaved into the MFMA phase, deeper stage-2 rings, and stage-2 mainloop changes. Stage 2 is bound by its y-row store, at about 90% of that store's bandwidth floor.

**Stage-1 ceiling analysis** (thread trace, I=1536):
- The compute phase takes 556 cycles per K step, against an ideal of 512.
- The memory phase is still about 1.1–1.2 k cycles, so each SIMD's MFMA duty is about 30–35%.
- About 400 cycles of that is texture-address (TA) serialization of DMA instructions. Gathered A rows cost about 32 cycles/KB and contiguous B about 20 cycles/KB, per the DMA benchmark.
- The rest is LDS reads and barrier skew.

The next structural levers: pre-gather A into compact step-major rows (halves the A TA cost), and cut the DMA instruction count per step.


## Round 3 (v4, `configs/tiles_v4_I*.json`) vs v3 and v1

Measured with `bench/compare.py`: serial on GPU 0, round-robin arms, a null arm, prologue included.

- **Correctness:** `compare.py` compares against v3's *output*, not the torch reference. Under the old `SR="ceil"` rule, v4 matched v3 to `rel_diff` ≤ 1e-6 in every cell; the fused-combine cells differ only in summation order and all others are bit-identical. Correctness against the torch reference comes from `tests/test_tables.py`.
- **Default scale rule:** the default is now `SR="even"`, so outputs differ from v3 by the change of rule (see "Scale rule" below).
- **Curation:** the tables started from `bench/tune.py` picks, and 16 of 33 cells were then changed by hand; each carries a `note` field.
  - **12 cells (T ≤ 256, all widths):** the tuner's pick only matched v3 within noise while adding prologue work and launches, so they went back to v3 configs.
  - **3 cells (I=384, T = 1024, 2048, 4096):** the tuner's pick lost a serial A/B against v3, so they went back to v3 configs.
  - **1 cell (I=384, T=8192):** hand-set to the `wpe3` config.

  The tuner works from warm timings on uniform routing, which is not enough on its own.

Final table: final code with the shipped default (`SR="even"`), one process on GPU 0, node otherwise idle. The script is `bench/results/run_r3_timing.sh`; the commit is in `r3_timing_commit.txt`; raw output is `r3_final_vs_v3.log` plus per-width JSON. A cell counts as a win or loss when the change exceeds max(2×|ref − ref_null|, 2%).

| T | I=384 vs v3 | I=768 vs v3 | I=1536 vs v3 |
|---:|---:|---:|---:|
| 32–256 | noise (−1.5 to +1.3%) | noise (−1.0 to 0%) | noise (−0.9 to −0.4%) |
| 512 | noise (+1.5%) | noise (+0.8%) | +2.4% |
| 1024 | noise (−0.1%) | noise (+1.6%) | noise (+2.0%) |
| 2048 | noise (+0.9%) | +2.6% | +3.5% |
| 4096 | noise (−0.1%) | +4.5% | +4.2% |
| 8192 | noise (+0.8%) | +5.4% | +7.6% |
| 16384 | noise (+1.9%) | +10.3% | +2.6% |
| 32768 | noise (+0.6%) | +7.1% | noise (+1.0%) |

No cell loses to v3.

- **I=384:** v4 ties v3 everywhere. At T ≥ 16384 its faster stage 1 (288 → 247 µs and 470 → 450 µs) is mostly offset by a slower stage 2 (320 → 345 µs and 619 → 632 µs, the async + NT + HT pick against v3's `hybrid2`).
- **Against v1** (`r3_vs_v1.log`, same run):

  | T | I=384 | I=768 | I=1536 |
  |---:|---:|---:|---:|
  | 4096 | +8.9% | +10.2% | +13.0% |
  | 32768 | +11.6% | +15.4% | +14.8% |

### Stage-2 occupancy cliff

A regression at I=384 found and fixed: stage 2 on `hybrid2` with the old store path went from 166.5 µs (v3) to 187.6 µs at T=8192. The per-commit bisect is in `bench/results/r3_stage2_bisect.log`: v3 166.5, `7f2480433` 165.2, `5db00ad2b` 185.7, head 187.6, head + `wpe3` 166.7 µs. Register counts are in `r3_stage2_registers.log`.

- **Cause:** bisected to `5db00ad2b`. Its 64-bit per-tile descriptor math pushed the kernel from 168 to 178 registers. That crosses the 168-register limit for three waves per SIMD (512/3, rounded down to the 8-register granule), dropping occupancy from 3 to 2 waves.
- **Fix:** `diag=wpe3` (`--amdgpu-waves-per-eu=3`) compiles it at 164 registers in total (84 VGPR + 80 AGPR) with no spills, restoring 3 waves. It's used for I=384 T=8192.
- **Limit:** the same kernel's registers grow with K: 234 at I=768 (2 waves) and 316 at I=1536 (256 VGPR + 60 AGPR, 1 wave). There `wpe3` spills (364 and 766 registers) and stage 2 gets 3–9× slower (I=768: 8.4× at T=64 down to 3.2× at T=32768; I=1536: 8.3–8.8× at T = 64 and 256). Log: `bench/results/r3_wpe3_sweep.log`.
- **Next target:** a stage-2 K loop whose live state doesn't scale with K.

**Stage 1 at T=32768** (`r3_final_vs_v3.log`):

| Width | Time | Rate |
|---|---|---|
| I=384 | 450 µs | 3.4 PF |
| I=768 | 875 µs | 3.5 PF |
| I=1536 | 1709 µs | 3.6 PF |

That's roughly half of the 6.5–7.3 PF MFMA peak measured with `bench/mfma_peak.py`; that measurement isn't archived. For I=1536, v1 was 2457 µs in the same session (`r3_vs_v1.log`).

### Small T is MALL-inflated

A 512 MB flush between launches (`--flush`) shows serving-like small-T times are about 2× the warm numbers: I=384 at T=32 is 84 µs warm versus 179 µs flushed (`r3_final_vs_v3.log`, `r3_flush_vs_v3.log`).

- **Against v3, flushed:** 11 of 12 cells are within noise. The 12th (I=384 T=256, −3.7%) didn't reproduce in four re-runs of 11 repetitions each: −0.2% to −1.2% under both rules (`r3_flush_384_256_recheck.log`).
- **Consistent small cost:** the flushed prologue is 1.5–2.5 µs slower than v3's, which is about 1% of total at these sizes.

### What round 3 measured

**Kept:**

| Change | Effect | Notes |
|---|---|---|
| LDS reads interleaved with DMA issue in the ping-pong memory phase | stage 1 −2 to −7% | default |
| Raw `v_exp_f32` in the SwiGLU epilogue | stage 1 about −2% | |
| Row-block tail skipping (`diag=skip`) | stage 1 −5 to −10% at T=4k–8k (0 to +2% at 32k) | chosen per bucket |
| K-step-major stage-1 B scales, one DMA per step | −0.5 to −1.5% | |
| Stage-2 LDS-staged 16 B stores (+ non-temporal) | e.g. I=768 stage 2 942 -> 811 µs with `hybrid2`; I=384 615 -> 574 µs with async + NT | chosen per bucket |
| HT layout (`h_t`) and fused combine (FC) | wins at I=768 T ≥ 8k (FC) and some I=1536/384 cells (HT) | per-bucket global switches, chosen on total time |

**Measured and off by default:**
- A small-tile tail launch (`TB`): slower everywhere.
- Uniform per-wave scale DMAs: +4–8% at D=3.
- Persistent stage 1: +33–61%. Hardware dispatch already backfills the CUs.
- Quant-side step-major scale writes: 32k prologue 194 vs 170 µs.
- Single-launch small-R plan: 24.8 vs 18.6 µs.

**Measured, not built:** the 128 B A DMA granule. The microbenchmark gives +16% on the A path (36–39 vs 31–33 B/clk/CU), which is about 2–3% of stage 1.

**Infeasible:** `op_sel`-packed A scales. Tiles start at unaligned compact rows, so no global layout lines up with tile-relative row blocks.

### Scale rule (`SR`, default `"even"`)

Activations and `h` are quantized per 32-element group with an e8m0 scale. Up to round 3 the scale was `ceil_pow2(amax/6)` ("ceil").

- **What changed:** the checkpoint's quantization config (`scale_calculation_mode: even`) and AITER's runtime quantizer use a different rule. It rounds amax to a power of two with the rounding threshold at mantissa 1.75, then subtracts 2 from the exponent. For about a fifth of groups it picks a scale half the size.
- **Default:** `SR="even"` now applies that rule in the quant kernel and in the stage-1 epilogue.
- **Match with AITER** (`tests/test_aiter_quant.py`, log `r3_test_aiter_quant.log`): scales are byte-identical to AITER's `dynamic_mxfp4_quant` everywhere, including zero, tiny, near-bf16-max and inf groups. fp4 codes are byte-identical in every finite group with scale below 2^127. At scale 2^127 (e8m0 254), AITER multiplies by the subnormal reciprocal 2^-127, which gets flushed, so its codes there are not a reference.
- **Accuracy** (`bench/scale_rule_accuracy.py`, log `r3_scale_rule_accuracy.log`, synthetic data): the full MoE output's error against an unquantized-activation reference (fp32 x and h, same fp4 weights).

  | Activation scale | `even` | `ceil` |
  |---|---|---|
  | normal | 0.2170–0.2176 | 0.2260–0.2263 |
  | 0.05× | 0.1791–0.1794 | 0.1902–0.1907 |

  That's 3.8–4.0% and 5.8–6.0% less quantization error under `even`, at every width and at T = 1024 and 4096. It hasn't been checked on real checkpoint activations.
- **Cost:** the final table above is timed with `even`.

`SR="ceil"` remains available.

### Integration gaps (standalone package today)

- **No per-call engine API.** `MoERun` is built per (T, weights) and owns about 2.7 GB of workspace at T=32768, I=1536 (`y_rows` alone is R·H·2). `forward(x, topk_ids, topk_w)` can re-bind inputs of the same shape without allocating. Still missing: a workspace shared across layers and T, a `run(ws, x, ids, w, W, out, n_tokens)` entry point, and a `y_rows` sized to routed rows only when FC is on.
- **Expert-parallel `-1` ids are not supported.** `validate=True` rejects them at construction. Without validation, the plan kernels clamp out-of-range ids (so they never corrupt memory) rather than drop them.
- **FC requires the shared expert exactly once per token** (expert E−1). This is checked at construction when `validate=True`, and `select_cfg` drops FC for other (E, k).
- **Launch overhead:** 7–9 kernel launches per forward. At T ≤ 256 eager mode is roughly CPU-bound, so CUDA/HIP graphs are needed. Grids are capacity-based and `forward()` never syncs with the host, but graph capture and replay isn't tested yet.
- **Not validated:** no loader or end-to-end test for real checkpoint weights, and no AITER dispatcher naming, CSV rows or shape gates.
- **Thread safety and devices:** kernel runner caches are per process, and their keys don't include the device.

### Correctness and robustness fixes

- 64-bit per-tile and per-row descriptor bases for `y_rows` and the combine. The T=40000 test passes with R·H·2 > 2³¹.
- Clamp of dynamic descriptor sizes.
- `gcount` is re-zeroed inside the single-CTA prefix kernel.
- The global `amdgpu-mfma-vgpr-form` option is dropped.
- JIT cache keys now include each kernel's full name string. FlyDSL's disk cache ignores list- and set-typed closure values, which served stale kernels twice.

**Known small cost of the bounds fixes:** in I=384's HT cells (T = 512, 16384, 32768), stage 2 measured about 2% slower than the pre-fix code in an unarchived A/B, which is under 1% of total. The likely cause is the out-of-range-offset select on HT reads, but it isn't isolated yet.

**A regression found and fixed:** sizing the `y_rows` store descriptor to exactly the tile's rows made stage-2 stores about 30% slower. The record count now spans the remaining rows. It was found by bisecting across the round's commits.
