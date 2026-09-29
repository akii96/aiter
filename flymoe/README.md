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
- **Tail tiles waste MFMA lanes.** Less than one 16-row granule per active expert is wasted. That is at most about 1.3–10% in the 4096–32768 token band. In the streaming band (32–256 tokens) the MFMA waste is large, but the units are idle there anyway: the band is limited by HBM, and the zero-padding claim applies to bytes, not MFMA lanes.

## Pipeline (all FlyDSL kernels, no host sync)

| Kernel | File | What it does |
|---|---|---|
| K0 quant | `prologue.py` | bf16 to MX fp4. Bit-exact with `mx.quant`. |
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

`configs/tiles_I{384,768,1536}.json` holds the per-bucket choices from `bench/tune.py`.

## Correctness

- `tests/test_moe.py` checks against our own torch reference (`ref.py`).
  - With the fp32-atomic epilogue, `rel_l2` is about 1e-8. The bf16 output paths give 2.3e-3, which is bf16 rounding alone.
  - Shapes covered: I = 384 / 768 / 1536; T = 1, 7, 33, 256, 1000, 5000; and all tokens routed to one expert.
- `tests/test_variants.py` covers every BM / NW / pipe variant, including mixed BM between the two stages.
- `tests/probe_mfma.py` pins down the scaled fp4 MFMA lane, scale and opsel layout.

## Performance (MI355X, one GPU, median of 7 x 10 launches)

Times are in µs and exclude the prologue, which is reported separately. They cover K1 + K2 + combine. AITER numbers come from AITER's own tuned CSV (`minimax_m3_fp4_tuned_fmoe.csv`) for 384/768 and from `FLYDSL_MOE_REQUIREMENTS.md` for 512 and 1536. They were not re-timed in this session.

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

## Where it stands, and what is next

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
