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

`flymoe.configs.select_cfg(I, T)` returns `MoERun` kwargs for any T: the smallest tuned power-of-two bucket ≥ T, clamped to 32–32768. It reads `configs/tiles_v5_I{384,768,1536}.json`. These are the v4 tables (`bench/tune.py` picks curated by serial A/B) with round 4's stage-2 changes (see "Round 4"). `tests/test_tables.py` checks every cell. Older tables (`tiles_I*`, `tiles_v2_*` to `tiles_v4_*`) are kept for the frozen comparisons.

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

Measured dead ends: GM rasterization, L2 touch-prefetch (hits the register cap and spills), DMA issue interleaved into the MFMA phase, deeper stage-2 rings, and stage-2 mainloop changes. (Round 4 correction: the earlier claim that stage 2 runs at about 90% of its y-row store floor does not hold against measured bandwidth. With v4's configs at T=32768 it is at 64% of its current-dataflow floor at I=384 and 35% at I=1536; see "Round 4" and `bench/results/r4_roofline_v4.log`.)

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

## Round 4 (v5, `configs/tiles_v5_I*.json`): measured against the roofline

All times are from `bench/compare.py`: serial on GPU 0, one process, node otherwise idle, round-robin arms with a null arm, prologue included. A cell counts as a win or loss when the change exceeds max(2×|ref − ref_null|, 2%). Script: `bench/results/run_r4_timing.sh`. Commit: `r4_timing_commit.txt`. Kernel source hash and table checksums: `r4_timing_srchash.txt`. The reference is the frozen `flymoe-v4` tag (`7115cb33c`).

### Result: v5 vs v4 (`r4_final_vs_v4.log`, per-width JSON)

Total µs, warm:

| T | I=384 v4 -> v5 | I=768 v4 -> v5 | I=1536 v4 -> v5 |
|---:|---:|---:|---:|
| 32 | 87 -> 87 (-0.1%, noise) | 138 -> 134 (+2.7%) | 250 -> 251 (-0.2%, noise) |
| 64 | 101 -> 101 (+0.0%, noise) | 172 -> 170 (+1.0%, noise) | 329 -> 329 (+0.2%, noise) |
| 128 | 112 -> 113 (-0.9%, noise) | 200 -> 198 (+0.8%, noise) | 364 -> 362 (+0.7%, noise) |
| 256 | 119 -> 120 (-0.6%, noise) | 212 -> 212 (-0.0%, noise) | 374 -> 376 (-0.4%, noise) |
| 512 | 132 -> 126 (+4.9%) | 223 -> 224 (-0.1%, noise) | 395 -> 387 (+2.0%) |
| 1024 | 147 -> 146 (+0.3%, noise) | 245 -> 246 (-0.3%, noise) | 428 -> 426 (+0.4%, noise) |
| 2048 | 203 -> 183 (+9.8%) | 313 -> 304 (+3.0%) | 509 -> 474 (+6.9%) |
| 4096 | 296 -> 260 (+12.0%) | 429 -> 413 (+3.7%) | 674 -> 647 (+4.0%) |
| 8192 | 505 -> 441 (+12.7%) | 721 -> 689 (+4.4%) | 1156 -> 1079 (+6.7%) |
| 16384 | 925 -> 802 (+13.3%) | 1215 -> 1182 (+2.7%) | 2033 -> 1894 (+6.8%) |
| 32768 | 1728 -> 1539 (+11.0%) | 2294 -> 2237 (+2.5%) | 3746 -> 3473 (+7.3%) |

21 of 33 cells win, 12 are within noise, none lose.

- **Where the gains come from.**
  - At T ≥ 2048 on I=384 and I=1536, most of the gain is stage 2 (new table cells). For example, I=384 T=32768 stage 2 goes from 625 to 480 µs.
  - The rest, and almost all of the I=768 gain, is the rewritten plan prefix and scale transpose. The prologue at T=32768 goes from 170 to 127 µs; at T=2048–16384 it saves 10–32 µs.
- **Correctness.**
  - Output is bit-identical to v4's in 28 cells.
  - The other 5 differ by rel_diff ≤ 1e-6. All 5 are cells where the fused-combine (FC) switch changed, so the difference is summation order.
  - Against the torch reference, `tests/test_tables.py` passes all 129 cases with the v5 tables (`r4_test_tables_*.log`).
  - The explicit-config tests `test_options.py`, `test_large.py` (T=40000) and `test_moe.py` also pass, including the new stage-2 configs (`r4_test_*.log`).

**Flushed small T** (512 MB flush between launches, 7 reps, `r4_flush_vs_v4.log`):

| T | I=384 | I=768 | I=1536 |
|---:|---:|---:|---:|
| 32 | 178 -> 172 (+3.0%) | 269 -> 255 (+5.3%) | 385 -> 382 (+0.8%, noise) |
| 64 | 208 -> 203 (+2.2%) | 304 -> 299 (+1.8%, noise) | 457 -> 461 (-0.7%, noise) |
| 128 | 224 -> 217 (+2.8%) | 323 -> 320 (+1.0%, noise) | 506 -> 486 (+4.0%) |
| 256 | 230 -> 228 (+0.7%, noise) | 333 -> 330 (+0.9%, noise) | 508 -> 504 (+0.8%, noise) |

The flushed gains are the plan prefix: 7.8 -> 2.6 µs at T=32 (`r4_prologue_prof.log`, `r4_prologue_prof_after.log`).

**Against frozen v1** (`r4_vs_v1.log`):

| T | I=384 | I=768 | I=1536 |
|---:|---:|---:|---:|
| 4096 | 319 -> 258 (+18.9%) | 482 -> 416 (+13.6%) | 777 -> 636 (+18.1%) |
| 32768 | 1972 -> 1540 (+21.9%) | 2741 -> 2270 (+17.2%) | 4409 -> 3470 (+21.3%) |

v1 predates the `SR="even"` scale rule, so its output differs from v5 by rel_diff 0.12 (the same as in round 3). Each version is within its own reference's tolerance.

### Measured floors

| What | Rate | Source |
|---|---|---|
| HBM streaming read / write / copy | 5.87 / 5.14 / 5.12 TB/s | `r4_hbm_bw.log` |
| Stage-2-shaped bf16 row stores (BM=128 × BN=256 tiles, expert order) | 5.23 TB/s at T=32768; 5.50 TB/s at T=4096 (fits in MALL) | `r4_hbm_bw.log` |
| bf16 `pk_add` atomics, same rows | 1.25–1.32 TB/s-equivalent | `r4_hbm_bw.log` |
| fp32 atomics, same rows | 0.32 TB/s-equivalent | `r4_hbm_bw.log` |
| MFMA 16x16x128 f8f6f4 | 7.43 PF with constant scales, 7.20 PF with per-MFMA scales | `r4_mfma_peak.log` |

The atomic rates are the same with expert order or token-window order (4 or 16 windows). An XCD-local variant was measured for bf16 only (1.20–1.31 TB/s). The atomics look throughput-limited at the memory side, not by locality.

### Roofline (`bench/roofline.py`; `r4_roofline_v5.log` for v5, `r4_roofline_v4.log` for v4 from the same session)

Per kernel, the model counts the bytes and FLOPs each kernel must move and takes the maximum of memory time and MFMA time. Memory time uses the streaming read rate and the best measured write rate (5.50 TB/s); MFMA time uses 7.43 PF. There are two floors:

- **Current:** today's dataflow. Stage 1 gathers A per row. Stage 2 writes [R, H] bf16 expert rows and combine re-reads them, or the FC variant.
- **Minimal-unfused:** x, weights and the final output each cross HBM once, h is written and re-read once, and no expert rows are materialized. A fused stage 1 + stage 2 would also drop h.

Both are HBM floors. The 256 MB MALL can serve a re-read that fits, so combine runs at 102–109% of its floor at T=4096; the log flags these cells `mall`. At T ≤ 256, launch overhead of a few µs per kernel dominates the small kernels.

Total time as a % of each floor (higher is closer):

| Cell | v4 total, % current / % minimal | v5 total, % current / % minimal |
|---|---:|---:|
| I=384 T=256 | 119 µs, 76% / 71% | 120 µs, 75% / 70% |
| I=384 T=4096 | 296 µs, 69% / 36% | 260 µs, 78% / 41% |
| I=384 T=32768 | 1728 µs, 64% / 23% | 1539 µs, 72% / 26% |
| I=768 T=256 | 212 µs, 82% / 79% | 212 µs, 82% / 79% |
| I=768 T=4096 | 429 µs, 67% / 44% | 413 µs, 70% / 46% |
| I=768 T=32768 | 2294 µs, 53% / 31% | 2237 µs, 54% / 32% |
| I=1536 T=256 | 374 µs, 90% / 89% | 376 µs, 90% / 88% |
| I=1536 T=4096 | 674 µs, 65% / 53% | 647 µs, 71% / 56% |
| I=1536 T=32768 | 3746 µs, 49% / 36% | 3473 µs, 49% / 38% |

(The current floor depends on the dataflow. v5 I=1536 T=32768 uses FC, whose floor is lower, so its % current stays at 49% while its time drops 7%.)

**What the roofline says** (v5, T=32768):

- **Small T is at the weight-streaming floor.** At T=256, stage 1 runs at 93–101% of its floor and stage 2 at 83–96%. What's left there is launches and MALL effects, not kernels.
- **Stage 1 is at 46–49% of its MFMA floor at every width.** It is the largest single gap at I=768 and I=1536 (see "Stage 1" below).
- **Stage 2 is at 83% of its current floor at I=384** (v4: 64%). At I=1536 with FC it is at 47%, and at I=768 with FC at 56%.
- **The expert-row round trip is the structural gap.** At I=384, stage 2 + combine take 958 µs against a minimal-unfused floor of 106 µs. Nearly all of the difference is the [R, H] bf16 rows (2 GB at T=32768) written by stage 2 and re-read by combine.
- **Combine runs at 87% of its floor.** The prologue runs at 68–69%; its quant kernel is 92.8 µs against an 88 µs floor.

### Stage 2: register growth with K (A1–A3)

**Liveness** (`bench/s2_liveness.py`, `r4_s2_liveness.log`; backward liveness over the final ISA):

| Config | K=384 | K=768 | K=1536 |
|---|---|---|---|
| `hybrid2` D=4 (v4 default), live B steps / total registers | 3.2 / 178 | 4.2 / 234 | 5.3 / 316 |
| `hybrid2` BM=128 D=2 `wpe2+s2nt`, live B steps / total registers | 2.1 / 256 | 2.1 / 256 | 2.1 / 256 |
| `hybrid2` BM=64 D=2 `wpe3+s2nt`, live B steps / total registers | 2.1 / 166 | 2.1 / 168 | 2.1 / 168 |

- **Cause of the growth (A1).** Registers grew with K because the depth-4 B prefetch held more B steps in VGPRs as the unrolled K loop grew. Each B step is 16 VGPRs plus about 2 scale registers.
- **Fix: depth 2.** At D=2 the live B state is about 2.1 steps at every K. The remaining pressure is the 128 (BM=128) or 64 (BM=64) accumulators plus LDS operand registers.
- **Occupancy with BM=128.** `wpe2` holds it at 256 registers (2 waves per SIMD) at every K. It spills 3 VGPRs (16 B of scratch) at K=384, where it isn't shipped, and none at K ≥ 768.
- **Occupancy with BM=64.** `wpe3` fits 3 waves (≤ 168 registers) at every K, but spills 4 VGPRs at K ≥ 768, so it is shipped only at I=384.
- **The plan's gate is met only in part.** The gate was ≤ 168 registers with no spills at every width; only BM=64 at K=384 meets it. At K ≥ 768 the shipped configs run 2 waves with no spills.
- **Rolled K loop not built.** It was the fallback in the plan. The knock-outs below show occupancy isn't what limits stage 2.

**Where stage-2 time goes** (I=1536 T=32768, BM=128 D=2 `wpe2`, 1380 µs; `r4_s2_decomp_1536.log`, diagnostic knock-outs whose output is wrong):

| Knock-out | Stage 2 | Saving |
|---|---:|---:|
| no epilogue (no y-row stores) | 926 µs | −454 µs |
| no B loads | 1087 µs | −293 µs |
| no DMA | 1230 µs | −150 µs |
| no LDS reads | 1316 µs | −64 µs |
| no barriers | 1422 µs | 0 |
| all four removed | 487 µs | −893 µs |

The savings are not additive. The largest single component is the exposed epilogue store, which isn't overlapped with the next tile's MFMAs. Non-temporal wide stores (`s2nt`) combined with `wpe2`/`wpe3` are what the new table cells use (`r4_s2d_*.json`, `r4_s2d.log`).

**How the v5 cells were chosen.** `bench/make_tiles_v5.py` adopts a sweep arm only if it beat the v4 cell by more than 1.5% in the same process. It accepts only arms that passed the output gate and were timed on the current kernel sources; each arm records its `SRC_HASH`. The shipped cells:

| Width | Cells | Stage 2 |
|---|---|---|
| I=384 | T ≥ 2048 | BM=64 `wpe3+s2nt` (D=3 at T = 2048 and 16384, D=2 elsewhere) |
| I=768 | T=8192 | BM=128 `wpe2+s2nt` |
| I=1536 | T=2048 and 4096 | BM=128 `wpe2+s2nt` |
| I=1536 | T ≥ 8192 | BM=128 `wpe2+s2nt` with FC |

Stage 1 is unchanged from v4 everywhere. A first table built from sweeps that predated the prologue rewrite was superseded; its timing is kept as `r4_prelim_*`.

**Atomic epilogue: built, measured, off.** `epi=bf16atomic` and `epi=f32atomic` add each row straight into the [T, H] output and skip combine. A token-window tile order is available in the plan to go with them.

- **End to end at I=384 T=32768** (`r4_atomic_e2e_384.log`): stage 2 takes 1663 µs with bf16 atomics and 6198 µs with fp32, against 964 µs for rows + combine.
- **Why:** the atomics run at a quarter of the store rate or less (table above).
- The expert-row buffer (`y_rows`) is kept.

### Stage 1 (B1–B4), bounded before building (`r4_stage1_levers.log`, `r4_s1_decomp_1536.log`, `r4_s1_budget.log`)

At I=1536 T=32768, stage 1 takes 1697 µs against an 859 µs MFMA floor. Each knock-out, measured alone: no A DMA −147 µs, no B DMA −240 µs, no DMA −379 µs, no LDS reads 0, no epilogue −171 µs. These say where time is exposed, not how much a fix would recover.

- **B1, pre-gathered step-major A: rejected by measured bound.**
  - Best case ≈ 55 µs: all A-path time scaled from gathered to contiguous DMA cost (32 vs 20 cycles/KB, round-2 DMA benchmark).
  - Cost: the quant kernel writing R instead of T rows is +428 MB, about 83 µs.
- **B3, 128 B A granule: rejected by measured bound.** ≤ 20 µs (+16% on a ≤ 147 µs A path, about 1% of stage 1). This replaces round 3's 2–3% estimate.
- **B2, 3–4 phase groups: rejected by budget.** Stage 1 is 236 VGPRs with 128 accumulators and 136 KB of LDS. Three waves per SIMD allow ≤ 168 registers, which the accumulators plus operands exceed.
- **B4, K-step 256: rejected by budget.** About 284 registers, above 256, so 1 wave per SIMD. It would also double LDS per stage.
- **Next stage-1 target:** overlap the exposed epilogue with the next tile's main loop.

### Structural bets (D1–D3)

- **D1, shared-expert imbalance:** none. Shared-expert tiles and routed tiles at the same row count time within ±1% in both stages at every width (`bench/d1_shared.py`, `r4_d1_shared.log`).
- **D2, fused K1+K2 (correction to the premise):** fusing removes the h round trip (about 134 MB at I=1536 T=32768). It does not remove the 2 GB expert-row round trip, which is stage 2's output. Removing that needs atomics (measured slower, above) or a combine inside stage 2.
- **D3, token chunking (correction to the premise):**
  - A 4k-token chunk's rows ([4k·5, H] bf16) are 251 MB, the whole MALL.
  - Chunking the whole pipeline re-reads all touched weights per chunk. Break-even is a window of about 129·I/32 tokens (1.5k at I=384, 6.2k at I=1536), so it loses at I=1536.
  - The viable form was stage-2-only chunking with atomics, which the atomic rates rule out.

### Prologue (`bench/prof_prologue.py`, rocprofv3)

Prologue kernels at T=32768:

| Kernel | Before | After |
|---|---:|---:|
| Plan prefix (Hillis–Steele scan plus a binary search per tile entry, replacing one thread per expert) | 24.2 µs | 6.0 µs |
| Scale transpose (one thread per row with 16 B loads) | 37.7 µs | 10.8 µs |

The prefix also drops from 7.8 to 2.6 µs at T=32. The quant kernel (92.8 µs) is at its HBM floor (88 µs). Correctness: `tests/test_plan.py` compares against the frozen v4 plan in 576 cases (`r4_test_plan.log`):

- tile lists and tile counts exactly;
- expert offsets exactly;
- every row tied to its expert and its (token, slot);
- outputs re-poisoned between calls;
- E = 2, 9, 129 and 256.

### What round 4 does not claim

- No comparison against AITER.
- No end-to-end model numbers.
- `bench/tune.py` output was not used for v5.
- "Bit-identical" above means identical to v4's output in the named cells.

The superseded sweeps `r4_s2_sweep_*`, `r4_s2b_*` and `r4_s2c_*` predate the prologue rewrite and are not used by `make_tiles_v5.py`. The empty `r4_s2_sweep.log` was removed.
