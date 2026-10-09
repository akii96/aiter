# kab2: upstream AITER main vs image AITER vs flymoe — MiniMax-M3 MXFP4 MoE (MI355X, GPUs 4/5)

Setup:
- **Containers.** `aaknawaz_aitermain_ab` runs AITER main e6ded2168 (0.1.25.dev148), editable install from `~/workspace/aitermain_src`, `PREBUILD_KERNELS=0 GPU_ARCHS=gfx950`. Upstream still pins flydsl==0.3.4.1, so no flydsl change was needed. `aaknawaz_imgaiter_ab` is a pristine copy of the same image (aiter 0.1.24.post1).
- **Problem.** H=6144, E=129 with shared id 128 in every token's topk, k=5, uniform routing (flymoe `make_problem`). Same harness as `~/workspace/kab` (vLLM-exact `fused_moe` call). Times are µs: warm median of 20, with the flushed median in parentheses for T≤4096.
- **GPUs.** The main arm ran on GPU4, the image re-run on GPU5.

## Timing
### I=768 (TP4): every T hits the tuned CSV on both builds
| T | image (old kab) | image re-run | **main** | flymoe | fly/main | main kernels (CSV hit) |
|---|---|---|---|---|---|---|
| 1024 | 224.3 (262) | 225.2 | 225.9 (260) | 253.1 (303) | 1.12 | moe1_t64x128x256_w3_fp4 / moe2_layout_t64x128x256_atomic_nt_sbm64 |
| 2048 | 336.3 (370) | - | 341.7 (368) | 319.8 (358) | 0.94 | mxmoe_g1_a4w4_128x256x256_swiglu_xcd2 / moe2_layout_t128x128x128_reduce_sbm128 |
| 4096 | 465.3 (481) | - | 456.4 (473) | 453.1 (466) | 0.99 | mxmoe_g1 64x256x256_xcd2 / t64x256x128_reduce_persist_sbm64 |
| 8192 | 751.3 | 756.3 | 751.2 | 665.0 | 0.89 | same as 4096 |
| 16384 | 1317.1 | - | **1183.0** | 1082.6 | 0.92 | mxmoe_g1 128x256x256_xcd2 / **moe2_layout_t128x256x256_scatter_sbm128** (new) |
| 32768 | 2506.0 | 2495.5 | **2210.9** | 1961.5 | 0.89 | same as 16384 |

### I=384 (TP8). vLLM pads to 512, and 512 has no CSV rows on main either
| T | image @512 | re-run | **main @512** | main raw384 (CSV) | flymoe | fly/main@512 | main @512 kernels (default heuristic) |
|---|---|---|---|---|---|---|---|
| 1024 | 213.7 (258) | 213.9 | 212.6 (257) | 145.4 | 165.1 (201) | 0.78 | moe1_t32x128x256_w2 / moe2_t32x128x256_atomic_bnt2 |
| 2048 | 269.1 (304) | - | 267.8 (306) | 223.0 | 213.0 (245) | 0.80 | moe1_t64x128x256_w3_bnt0 / moe2_t64 atomic |
| 4096 | 420.8 (449) | - | 421.5 (447) | 327.8 | 306.3 (331) | 0.73 | moe1_t128x128x256_w2_bnt0 / moe2_t128 atomic |
| 8192 | 720.9 | 719.8 | 715.1 | 556.3 | 488.4 | 0.68 | same as 4096 |
| 16384 | 1285.2 | - | 1289.3 | **931.6** (old 1005) | 874.3 | 0.68 | moe1_t64x128x256_w4_bnt0 / moe2_t64 atomic |
| 32768 | 2544.6 | 2526.6 | 2542.7 | **1710.8** (old 1899) | 1656.6 | 0.65 | same as 16384 |

On main, raw384 at T≥16384 now uses `mxmoe_g1 128x256x256_xcd2 / moe2_layout_t128x256x128_scatter_sbm128`.

### I=1536 (TP2): no CSV rows on main, so the default heuristic is used (same kernels as the image)
| T | image | re-run | **main** | flymoe | fly/main |
|---|---|---|---|---|---|
| 1024 | 531.2 (613) | 539.9 | 533.9 (612) | 435.3 (481) | 0.82 |
| 2048 | 567.6 (605) | - | 572.9 (599) | 520.9 (541) | 0.91 |
| 4096 | 791.7 (809) | - | 789.3 (803) | 707.6 (724) | 0.90 |
| 8192 | 1265.1 | 1265.3 | 1261.5 | 1036.6 | 0.82 |
| 16384 | 2197.8 | - | 2207.2 | 1701.6 | 0.77 |
| 32768 | 4258.6 | 4265.2 | 4242.6 | 2994.8 | 0.71 |

**Noise:** the image re-runs land within ±1.6% of the old kab numbers.

**Main vs image:**
- Main is identical (±1%) everywhere except where the tuned CSV changed: I=768 at T≥16384 is 10–12% faster (new `scatter` stage-2 kernels), and raw-384 at T≥16384 is 7–10% faster.
- I=512 (what vLLM TP8 actually runs) and I=1536 are still untuned on main.
- flymoe still wins at T≥2048 everywhere, with the narrowest margin at I=768 (0.89–0.99×).

## Accuracy: real checkpoint weights (layer 30, rank-0 TP shard, shared expert as id 128)
**Inputs:**
- **x:** rmsnorm(N(0,1) with 32 outlier channels ×8) × (1 + post_attention_layernorm.w), bf16.
- **Routing:** the real router (sigmoid + e_score_correction_bias top-4, renormalised, ×2.0) plus the shared expert with weight 1.
- **Weights:** fp32 dequantized checkpoint weights.

**References:**
- `fp`: x and h left unquantized.
- `even` / `ceil`: x and h MX-fp4 quantized with that scale rule.

The `even` reference sits 0.204–0.210 from fp, and `ceil` sits 0.218–0.224. So "even" has about 6% less quantization error on real weights.

rel_l2 for T=1024; the T=8192 figures agree to ±0.001:
| I | impl | vs fp | vs even | vs ceil |
|---|---|---|---|---|
| 768 | image/main aiter (CSV) | 0.2217 | 0.1729 | **0.0034** (T=8192: 0.0023) |
| 768 | flymoe SR=even | **0.2078** | **0.0023** | 0.1723 |
| 768 | flymoe SR=ceil | 0.2216 | 0.1729 | **0.0023** |
| 384 | image/main aiter @512 (default) | 0.2236 | 0.1744 | 0.0350* |
| 384 | image/main aiter raw384 (CSV) | 0.2238 | 0.1747 | **0.0024** |
| 384 | flymoe even / ceil | 0.2100 / 0.2238 | 0.0024 / 0.1747 | 0.1741 / 0.0024 |
| 1536 | image/main aiter (default) | 0.2175 | 0.1693 | 0.0339* |
| 1536 | flymoe even / ceil | 0.2039 / 0.2177 | 0.0023 / 0.1696 | 0.1690 / 0.0023 |

Image and main AITER give identical errors.

\* Default-heuristic path. Adding a bf16 round of h before the ceil requant brings this to **0.0034** (see (a)).

### (a) The 0.15–0.19 "error" on the default path is a reference artifact, not a kernel bug
- **Why.** The default fallback picks stage-1 kernels without the `_fp4` suffix (`moe1_afp4_wfp4_bf16_t32x128x256_w2`, …). For these, `_s1_fp4q=False`: stage 1 writes h as **bf16**, then `fused_dynamic_mxfp4_quant_moe_sort` quantizes it with the ceil rule. Tuned `*_fp4` / `mxmoe_g1` kernels instead quantize the fp32 accumulator in the epilogue.
- **Reference fix.** A ceil reference with `h.to(bf16)` before the requant gives:
  - random weights: 0.0031–0.0032 at I=384→512 and at 1536, norm ratio 1.0000;
  - real weights: 0.0034.
- **Ruled out.**
  - Gate/up layout and interleave are correct.
  - Swapping the activation formula makes the error much worse: silu·u gives 0.72; alpha=1 or silu·(u+1) gives 0.19.
  - Mixed rules are worse: x=even with h=ceil gives 0.167; x=ceil with h=even gives 0.070.
- **Why it looked big.** With random weights (huge h dynamic range), a bf16 round flips about 1/5 of the e8m0 scales against an fp32-based reference. On real weights the mismatch is only 0.034.
- **Script:** `kab_diag.py` / `kab_diag_rand.py`.

### (b) Which scale rule AITER actually uses
- **The rule.** Every runtime fp4 activation quant inside `fused_moe` uses **ceil_pow2(amax/6)**, i.e. `MxScaleRoundMode::RoundUp`/RCEIL. This holds in both the image (0.1.24.post1) and main.
  - x quant, and h quant on the default path: `fused_dynamic_mxfp4_quant_moe_sort` → `per_1x32_mx_quant_hip` / fused HIP kernel. Both call `fp_f32_to_e8m0_scale<kDefaultMxScaleRoundMode>`, and `csrc/include/mx_quant_utils.h` sets `constexpr kDefaultMxScaleRoundMode = MxScaleRoundMode::RoundUp`. `aiter/utility/mx_types.py` has `MX_DEFAULT_ROUND_MODE = RoundUp`.
  - Fused stage-1 fp4 epilogue (`mixed_moe_gemm_2stage_common.py`): `(bits(amax)+0x400000)&0xFF800000`, exponent −2. This is amax rounded to a power of two at mantissa 1.5, which equals ceil(amax/6) except exactly at 1.5·2^k.
  - There is an `Even` mode in the enum (add 0x200000, i.e. threshold 1.75, then −2). Only the python `dynamic_mxfp4_quant(scaling_mode="even")` defaults to it, and `fused_moe` does not call that.
- **Checkpoint.** `quantization_config.global_quant_config.{input_tensors,weight}.scale_calculation_mode = "even"` (Quark), with `round_method=half_even`. flymoe's `SR="even"` (`mx._e8m0_even`, `hw.e8m0_even`: +0x200000, −2) is bit-exact with Quark's EVEN.
- **Confirmed empirically on real weights:**
  - AITER matches the ceil reference (0.0023–0.0034) and is 0.17 off the even reference.
  - flymoe SR=even matches even at 0.0023; SR=ceil matches ceil at 0.0023.
- **Conclusion:** the flymoe README claim "SR=even matches AITER's runtime quant" is **wrong**. SR=even matches the **checkpoint**; SR=ceil matches **AITER**. SR=even is also 5–6% closer to the unquantized fp reference.
- **flymoe caveat:** the `s1tr` stage-1 epilogue (used by the T=8192 tables) asserts SR=even. The ceil arm drops `s1tr`.

## Files and commands (`~/workspace/kab2`)
- Scripts: `kab_bench.py` (copied from kab), `kab_acc.py` (real-weight accuracy), `kab_diag*.py`, `run_main.sh`, `run_img.sh`, `run_acc2.sh`, `summarize.py`.
- Results: `results/main_I*.json`, `img_I*.json`, `acc_{image,image_flyceil,main}_I*.json`, and `log_*.txt` (AITER_LOG_MORE=1 kernel names).

```
bash ~/workspace/kab2/run_main.sh   # main arm sweep, GPU4, container aaknawaz_aitermain_ab
bash ~/workspace/kab2/run_img.sh    # image arm accuracy + timing re-run, GPU5, aaknawaz_imgaiter_ab
bash ~/workspace/kab2/run_acc2.sh   # flymoe SR=ceil @T=8192 + main-aiter accuracy
docker exec aaknawaz_imgaiter_ab bash -lc 'cd /workspace/kab2 && I=1536 HIP_VISIBLE_DEVICES=5 python kab_diag.py'
python3 ~/workspace/kab2/summarize.py
```