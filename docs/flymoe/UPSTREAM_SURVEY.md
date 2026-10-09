# AITER upstream survey: MXFP4 (A4W4, per_1x32) MoE prefill on gfx950, focused on MiniMax-M3
Snapshot date: 2026-10-08. Upstream main = `e6ded2168` (2026-10-08, #5002). Fresh clone: `~/aiter_upstream_survey`.

## 1. Which commit the image uses
- In `vllm/vllm-openai-rocm:nightly-bb87d227…`, the wheel is `amd_aiter-0.1.24.post1` (built from `file:///install/…whl`). It has no git SHA file.
- I extracted every `aiter/**/*.py` and `*.csv` file (~1000) and compared their blob hashes with each upstream commit. **All 1002 files match `c8325e00c` exactly** ("[Triton/Gluon] Add Triton-based Conv3D kernels (#5952)", 2026-09-29 17:23 -0300). The next commit, `6f6d66a03`, differs in 1 file, so the image is pinned to `c8325e00c`.
- **The image is 119 commits behind main.** The MoE-relevant files in the image were last changed by these commits:
  - `fused_moe.py` = #5852 (`569ae9881`, 09-26)
  - `minimax_m3_fp4_tuned_fmoe.csv` = #5482 (`e0f81c8d5`, 09-25)
  - `mxfp4_kname.py` = #4526
  - `moe_kernels.py` = #5583

## 2. MXFP4 A4W4 MoE paths in main (gfx950)
- **CK / CK-Tile 2-stage** (`cktile_moe_stage2`, `ck_gemm_moe_2stages_codegen`). It is not used when `inter_dim % 256 != 0` (#5232, `224dceec2`, 09-21): there, CK-Tile stage2 silently produced wrong output at 384, 640, and similar widths. `fused_moe.py` raises `NotImplementedError` if CK-Tile stage2 would still be selected for such a shape.
- **ASM 1-stage FLAT** (`fmoe_g1u1`, per_1x32, xbf16). This includes the SiTUv2 16x192/16x128/16x32 kernels (#5763, `b1a81bf2b`, 09-30, Kimi-K3 a16w4). Open PR #5794 adds SwiGLU-OAI FLAT kernels for MiniMax M3 (I=768, decode).
- **FlyDSL "flydsl_moe1_/flydsl_moe2_"** (legacy mixed_moe, `moe_kernels.py`). `resolve_flydsl_stage1_tile_n` / `pick_flydsl_stage1_tile_n` force tile 128 when `inter_dim % 256 != 0`; the code comment cites "MiniMax TP4 inter=384".
- **FlyDSL MXMOE (native)**: `flydsl_mxmoe_g1_a4w4_<BMxBNxBK>_[f16in][hpf][nt]_swiglu[_xcdN]` (`kernels/mxfp4_gemm1.py`) plus `flydsl_mxmoe_g2_…` (`mxfp4_gemm2.py`).
  - `F16IN` means bf16 input is quantized to fp4 inside stage1.
  - Stage1 writes fp4 (or fp8) intermediate output, requantized in the epilogue.
  - The BM16 F16IN g1 with a layout-v2 g2 is the "inline-sort" path, which uses the fused aux sort (`moe_mxfp4_aux`).
  - Native g2 requires `D_INTER % BK == 0` with BK=256 only. That rules out 384 until open PR #6264 / #6209 add BK=128.
- **Layout-v2 GEMM2** ("flydsl_v2", `kernels/mxmoe_dispatcher.py` + `mxmoe_gemm_v2.py`). Kernel names follow `flydsl_moe2_layout_afp4_wfp4_bf16_t{M}x{N}x{K}_{atomic|reduce|scatter}[_persist][_nt][_sbmN]`.
  - BK=128 tiles exist, so I=384 runs natively.
  - The `scatter` epilogue (persist-flat non-atomic store + `mxfp4_moe_scatter_reduce`) is new in #5812 (`7be37e87a`, 10-08).
- **Other:**
  - `fhmoe.py`: FlyDSL whole-graph path, keyed with extra shared_expert_id/hidden_pad/intermediate_pad/gate_mode columns. It rejects hidden/intermediate padding.
  - `grouped_gemm_mxfp4.py` / `grouped_moe_gfx1250.py`: gfx1250 grouped path (#5934 prefill v2).
  - `kernels/mega_moe/*`: MegaMoEV2, the EP dispatch + combine megakernel (#6127).
  - `moe_fused_route_quant_scatter.py`: gfx1250 grouped prep, route+quant+scatter fused.

**How dispatch works** (`aiter/fused_moe.py` at main):
1. **Activation dtype.** `resolve_activation_dtype`: per_1x32 + fp4 weights + Swiglu + SEPARATED gives `q_dtype_a = bf16 if M < GPTOSS_SWIGLU_MXFP4_BF16_BOUND (default 256) else fp4x2` (`_bound_split`, L106/L799).
   - So for M < 256 MiniMax goes to an a16w4 (bf16-activation) table key, not this A4W4 CSV. That is why the A4W4 rows below 256 are effectively unused unless forced.
   - INTERLEAVE + Swiglu on gfx950 uses fp8 instead (`AITER_BF16_FP8_MOE_BOUND`).
2. **Shape key.** `inter_dim` comes from the **weight shape** (`get_inter_dim`, `w2.shape[-1]*2`), so it is the padded width.
3. **Tuned-config lookup.** `get_2stage_cfgs(get_padded_M(M), …)` looks up on (gfx, cu_num, token, model_dim, inter_dim, expert, topk, act_type, dtype, q_dtype_a, q_dtype_w, q_type, use_g1u1, doweight_stage1) over all merged `*tuned_fmoe*.csv` (`AITER_CONFIG_FMOE`).
   - `get_padded_M` takes nextPow2 below 32768 and uses tiers [32768, 131072] above.
   - If the token tier misses, it falls back to smaller tiers.
4. **Routing by kernel name.** `flydsl_mxmoe_g1*` goes to `_make_mxfp4_metadata`. `flydsl_moe1_`/`flydsl_moe2_layout_` go to `_flydsl_stage1_wrapper` / `_flydsl_v2_stage2_wrapper`. `opus_` names go to Opus.
   - The inline-sort cfg is validated by `_is_mxfp4_inline_sort` and `_mxfp4_inline_sort_unsupported`, which rejects any `hidden_pad/intermediate_pad`, uses a padded-scale-stride check, and requires the shape to be in `MXFP4_MOE_SUPPORTED_SHAPES`.
   - That shape list contains `(129,6144,512,5)` and `(129,6144,768,5)` and does the lookup on `inter` rounded up to 256 (`moe_mxfp4_aux.py:67`).
5. **No tuned row.** The heuristic default runs 2-stage with `get_block_size_M`/`get_ksplit`. `_can_reroute_mxfp4_to_flydsl` sends bf16 Swiglu with `inter%128==0` to FlyDSL a16w4.
6. **Padding.** `_get_padding_for_flydsl(inter_dim_pad, model_dim_pad, bias)` returns 0/0 when bias is present and otherwise passes the pads through ("TODO: remove once kernel handles padding in runtime"). The legacy path pads K with `k_pad_zeros=intermediate_pad//128*128` and N with `n_pad_zeros=intermediate_pad//64*64*2`. 256-alignment applies only to CK-Tile, native g2 BK=256, and the aux shape lookup.
   - **vLLM in the image** (`oracle/mxfp4.py`) rounds ROCm MXFP4 `intermediate_size` up to 256, using 128 only for the AITER_MXFP4_BF16 SiTU/SiLU backend. So TP8 384 becomes **512** in the weights, the key is `inter_dim=512`, and `rocm_aiter_moe.py` passes `intermediate_pad = pad//64*64`.
   - ⚠ **Upstream main has no `inter_dim=512` E=129 rows in any CSV**, only 384 and 768. A padded TP8 run therefore misses the table and uses the heuristic default.
7. **Image vs main differences in this path:**
   - #5812: scatter epilogue for layout-v2 GEMM2, masked aux sort under EP, `reverse_sorted` plumbing, removal of the `MXFP4_G2_KSTATIC` env, plus MiniMax CSV changes.
   - #5987 (`a3f18d9a4`): gfx950 large-expert decode uses multi-phase Opus sorting.
   - #5763: ASM SiTUv2.
   - No change to `_SWIGLU_MXFP4_BF16_BOUND` or `_get_padding_for_flydsl`.

## 3. Relevant PRs and commits
**Merged between the image (`c8325e00c`) and main:**

| SHA | Date | PR | What changed |
|---|---|---|---|
| `7be37e87a` | 10-08 | #5812 | Scatter epilogue for layout-v2 GEMM2. **MiniMax M3 CSV:** 4 rows changed (T=16384/32768 for I=768 and I=384) |
| `a3f18d9a4` | 10-08 | #5987 | Opus multi-phase sort routing for large expert counts (decode) |
| `f4be7f1c5` | 10-05 | #6127 | MegaMoEV2 prefill/decode optimizations (EP) |
| `332b34fba` | 10-02 | #5934 | gfx1250 A4W4 prefill v2 (grouped) |
| `356c53dac` | 10-06 | #5967 | DSV4.1 MoE configs: E129 topk4 rows, plus a tuner change |
| `b1a81bf2b` | 09-30 | #5763 | ASM SiTUv2 FLAT; relaxes asm MXFP4 model_dim to multiples of 512 |
| `45c5795a8` / `11e8354c2` | — | #5708, then revert #6142 | relu2 activation for CK-Tile fused MoE, added and then reverted |

**Earlier history** (already in the image):
- #3755 `2da35ecc4`: created the M3 fp4 CSV.
- #4789 `e471f2c35`: v2 gemm2 retune.
- #5482 `e0f81c8d5`: mxfp4 MoE kernel perf + M3 CSV.
- #5232: no CK-Tile when inter%256 != 0.
- #5573 `22d2c7c91`: pad the sort extent to a block multiple.
- #4994 `83571d9b1`: fuse stage-1 fp8 quant in the heuristic path.
- #5395: SwiGLU + MiniMax-M3 A16W4 tune.

**Open PRs (GitHub API, 2026-10-08):**
- **MiniMax-M3 specific:**
  - #6085: TP2 `inter_dim=1536` FlyDSL configs + aux shape guard. It replaces #6232, which was closed.
  - #5404: BM16 SwiGLU path + A16W4/A4W4 M3 configs.
  - #5794: ASM SwiGLU-OAI FLAT kernels for M3.
  - #5822: Triton tiled MoE sort for M3 prefill (T≥8192, E129, k5, I=768, block 64), consumed by ATOM#2364.
  - #6047: M3 fused sparse-layer decode.
  - #5462 / #5817 / #6060: MXFP8 M3.
- **inter_dim 384 / padding:**
  - **#6264** (10-08): native MXMOE gemm2 BK=128 for non-256 inter, strided gemm1 input, scale-stride fixes. Motivated by Kimi-K3 I=384.
  - #6209: same topic, Kimi-K3 slice.
  - #6184: block the inline-sort path when `inter%256 != 0`. It documents an aux-shape lookup that rounds up to the wrong shape.
  - #6170: `AITER_MOE_SKIP_INTER_PAD` + LDS-DMA race fix.
  - #5744: avoid over-padded tiles under EP.
  - #3538: pre-zero stage1 output when `inter_dim_pad > 0`.
- **Fused sort/quant:**
  - #6165 / #6208 / #6263: fused route-sort + MXFP4/MXFP8 activation quant, **decode/small-M only**.
  - #6036: single-launch bitmask sort (decode).
  - #6225: aux-sort crossover.
  - #6136: gfx1250 fused GEMM1 quantization.
- **Prefill pipelines:**
  - #5988: gfx950 Q256 fused MXFP4 prefill. It is ASM (gate/up + SiLU + quant + down in one producer) plus a Triton route-reduce, for I=256, E=513, k=11 only.
  - #6269: "Dev/yadai moe v1".

## 4. Overlap with flymoe
| flymoe feature | Closest upstream work | Overlap |
|---|---|---|
| Compact rows (no block_m padding) | All upstream paths sort into block_m-padded tiles (`max_num_tokens_padded`, `sbm`; #5573 even enforces padding). #5822 is still a padded sort. | **None** |
| Native I=384 without padding | Layout-v2 GEMM2 BK=128 and mxmoe g1 BN=256 over 2×384 already run 384 in the main CSV. #6264/#6209 add BK=128 to native g2. But vLLM pads to 512, and there are no 512 rows. | **Partial.** Kernels exist upstream; the integration doesn't use them. |
| Fused quant + sort prologue | `F16IN` inline quant in stage1 (the BM16 tiles 16x128x256 and 16x256x256, used only at small M). Fused route-sort+quant HIP kernels in #6165/#6263 (decode). #6136 / `moe_fused_route_quant_scatter` on gfx1250. | **Partial; nothing at prefill scale on gfx950** |
| Persistent stage1 with SwiGLU + fp4 requant in registers | MXMOE g1 already does SwiGLU + fp4 requant in the epilogue (out_dtype fp4), with xcd swizzle. **Persistence exists only on stage2** (`_persist`). No 2×2-wave 256×256 il4 tile. | **Partial** (requant: yes; persistent 256×256: no) |
| Stage2 with fused combine | `atomic` epilogue (atomic-add into the output) and `scatter`+`scatter_reduce` (#5812, separate reduce kernel). The ASM FLAT path uses atomic pk_add_bf16. | **Partial** (atomic-combine concept exists; at prefill main uses reduce/scatter plus a separate kernel) |

**Verdict:** flymoe is still a meaningfully new family. Its main differentiators are:
- zero-padding compact rows end to end;
- a prefill-scale fused quant+sort prologue on gfx950;
- a persistent large-tile stage1;
- direct I=384 without the vLLM 512 pad.

The integration gap flymoe can fill: today's vLLM 384→512 padding misses every M3 tuned row. The closest competitors are #5988 (ASM, different shape) and #6264 (384 alignment, Kimi).

## 5. MiniMax-M3 fp4 tuned CSV (E=129, topk=5, model_dim=6144, Swiglu, fp4/fp4, per_1x32, gfx950, cu=256), rows with T≥256
Main and the image are identical except the 4 rows marked † (main) / image value in brackets. **There are no I=512 or I=1536 rows.**

**I=768 (TP4):**

| T | bm | kernelName1 | us1 | kernelName2 | us2 | total us |
|---|---|---|---|---|---|---|
| 256 | 16 | mxmoe_g1_a4w4_16x128x256_f16in_hpf_nt_swiglu_xcd2 | 104.9 | moe2_layout_t16x256x256_atomic_persist_nt_sbm16 | 53.3 | 158.3 |
| 512 | 32 | moe1_afp4_wfp4_bf16_t32x64x256_w4_kw2_fp4 | 108.5 | layout_t32x128x256_atomic_nt_sbm32 | 66.2 | 174.7 |
| 1024 | 64 | moe1_…_t64x128x256_w3_fp4 | 118.1 | layout_t64x128x256_atomic_nt_sbm64 | 78.1 | 196.2 |
| 2048 | 128 | mxmoe_g1_a4w4_128x256x256_swiglu_xcd2 | 138.6 | layout_t128x128x128_reduce_sbm128 | 119.4 | 258.0 |
| 4096 | 64 | mxmoe_g1_a4w4_64x256x256_swiglu_xcd2 | 195.9 | layout_t64x256x128_reduce_persist_sbm64 | 206.2 | 402.2 |
| 8192 | 64 | same as above | 280.2 | same as above | 405.1 | 685.3 |
| 16384† | 128 | mxmoe_g1_a4w4_128x256x256_swiglu_xcd2 | 439.5 [447.0] | layout_t128x256x256_scatter_sbm128 [t128x128x128_reduce] | 577.2 [756.2] | **1016.7** [1203.2] |
| 32768† | 128 | same as above | 798.6 [786.5] | same as above [t128x128x128_reduce] | 1151.2 [1401.3] | **1949.8** [2187.8] |

**I=384 (TP8):**

| T | bm | kernelName1 | us1 | kernelName2 | us2 | total us |
|---|---|---|---|---|---|---|
| 256 | 16 | mxmoe_g1_a4w4_16x256x256_f16in_hpf_nt_swiglu_xcd2 | 53.6 | layout_t16x128x128_atomic_sbm16 | 29.0 | 82.7 |
| 512 | 32 | moe1_…_t32x128x256_w3_fp4 | 57.2 | layout_t32x128x128_atomic_nt_sbm32 | 41.8 | 99.0 |
| 1024 | 64 | mxmoe_g1_a4w4_64x256x256_nt_swiglu_xcd4 | 61.3 | layout_t64x128x128_reduce_nt_sbm64 | 57.7 | 119.0 |
| 2048 | 128 | moe1_…_t128x128x256_w4_fp4 | 78.1 | layout_t128x128x128_reduce_nt_sbm128 | 95.3 | 173.4 |
| 4096 | 64 | mxmoe_g1_a4w4_64x256x256_swiglu_xcd4 | 107.0 | layout_t64x256x128_reduce_sbm64 | 164.7 | 271.7 |
| 8192 | 64 | same as above | 169.3 | same as above | 331.4 | 500.7 |
| 16384† | 128 [64] | mxmoe_g1_a4w4_128x256x256_swiglu_xcd2 [64x256x256_xcd4] | 242.9 [273.0] | layout_t128x256x128_scatter_sbm128 [t64x256x128_reduce_sbm64] | 507.5 [618.8] | **750.4** [891.8] |
| 32768† | 128 [64] | mxmoe_g1_a4w4_128x256x256_swiglu_xcd2 [moe1_t64x128x256_w3_bnt0_xcd4_fp4] | 455.5 [475.3] | layout_t128x256x128_scatter_sbm128 [t64x256x128_reduce_sbm64] | 1026.3 [1216.9] | **1481.8** [1692.2] |

Short names: `mxmoe_g1…` = `flydsl_mxmoe_g1_a4w4_…`; `moe1_…` = `flydsl_moe1_afp4_wfp4_bf16_…`; `layout_…` = `flydsl_moe2_layout_afp4_wfp4_bf16_…`. The us values are tuner-reported times.

**Notes:**
- The global `aiter/configs/tuned_fmoe.csv` has no E129/k5 rows.
- Stage2 dominates at T≥4096: 50–70% of the total.
- From the image to main, T≥16k gets 12–16% faster from #5812.
