# FlyDSL A4W4 compact MoE: MXFP4 prefill MoE for gfx950

The FlyDSL A4W4 compact MoE is a kernel family for MXFP4 weights and activations (fp4 e2m1,
e8m0 scales per 1x32 group) with the SwiGLU-OAI activation, built for prefill-sized
batches (512 to 32768 tokens per call) on gfx950 (MI350X / MI355X). It is reached through
`fused_moe` like every other backend: a tuned row whose `kernelName1` is
`impl__flydsl_a4w4_compact__<config>` dispatches the whole MoE to it through
`aiter.fused_moe_registry`.

## What is different

- **No `block_m` padding.** Rows are sorted into exactly `tokens * topk` compact,
  expert-ordered rows. Tail tiles neither load nor store rows past the expert's count.
- **No `inter_dim` padding.** Any `inter_dim` that is a multiple of 128 runs at its
  true width. MiniMax-M3 at TP8 (`inter_dim=384`) does not need to be padded to 512.
- **Fused prologue.** The activation quant and a three-launch parallel counting sort
  run on device without host syncs.
- **Stage 1** gathers token rows, runs the gate/up GEMM, applies SwiGLU-OAI and
  requantizes `h` to MXFP4 in registers. Large batches use a persistent 2x2-wave
  256x256 tile that keeps the accumulators in AGPRs.
- **Stage 2** runs the down GEMM and applies the router weight in the epilogue. With
  fused shared experts the combine is folded into the shared expert's epilogue (FC).

## Using it

Weights are prepared exactly as for the other `per_1x32` fp4 paths:
`shuffle_weight(w, layout=(16, 16))`, `e8m0_shuffle(scale)`, gate/up
`GateMode.SEPARATED`. The kernels read the fp4 weights in place; only the e8m0 scales
(about 6% of the weight bytes) are repacked, once per weight tensor.

The family never runs on padded weights. Rows are written at the true `inter_dim` only,
and a call with `hidden_pad` or `intermediate_pad` falls back to the existing kernels.
Other unsupported calls (other activations, bias, expert parallelism, prequantized
activations, `doweight_stage1`) also fall back: `unsupported_reason` lists them.

Environment:

| Variable | Default | Meaning |
|---|---|---|
| `AITER_MOE_A4W4_COMPACT_FUSED_SHARED_EXPERT` | `0` | `1` when expert `E-1` is a shared expert routed exactly once per token (vLLM `VLLM_ROCM_USE_AITER_FUSION_SHARED_EXPERTS=1`). Enables the fused combine; without it those rows run the separate combine. |
| `AITER_MOE_A4W4_COMPACT_SCALE_RULE` | `ceil` | e8m0 rule for the runtime activation quant. `ceil` matches AITER's MX quant; `even` matches checkpoints calibrated with `scale_calculation_mode="even"` (Quark). |

## Config strings

`<config>` is a `-`-joined list of `key=value` tile settings (`s1`/`s2` prefixes for
stage 1/2, `F` suffix for the fused combine). Kernel options in `s1diag`, `s2diag`
and `diagF` are `+`-joined:

| Option | Meaning |
|---|---|
| `barrier_slot_N` | il4 stage 1: issue the DMA wait and barrier after MFMA slot `N` |
| `s1_transposed_epilogue` | il4 stage 1: swapped-operand MFMAs, per-lane row epilogue |
| `epilogue_batch_N` | `N` row blocks per epilogue batch |
| `s2_nontemporal_store` | stage 2: non-temporal output stores |
| `s2_transposed_store` | il4 stage 2: swapped-operand MFMAs, LDS-transposed row stores |
| `s2_double_buffer` | il4 stage 2: two LDS row-block buffers per wave |
| `no_s2_lds_store` | stage 2: direct stores instead of LDS-staged wide stores |
| `waves_per_eu_N` | register cap so `N` waves fit per SIMD |
| `agpr_N` | AGPR share of the register budget |
| `fused_agpr_N` | `agpr_N` for the fused-combine kernel only |
| `fused_skip_own_slot` | fused combine: skip the shared expert's own slot |

## Tuning

```bash
python csrc/ck_gemm_moe_2stages_codegen/gemm_moe_tune.py \
    -i aiter/configs/model_configs/minimax_m3_fp4_untuned_fmoe.csv \
    -o aiter/configs/model_configs/minimax_m3_fp4_tuned_fmoe.csv \
    --e2e_tune --fused-shared-expert
```

On gfx950 `--e2e_tune` times every compact candidate from
`aiter/ops/flydsl/moe_a4w4_compact/configs/` against the existing row and keeps the faster
one. `--fused-shared-expert` routes expert `E-1` once per token, as vLLM does with fused
shared experts, so fused-combine candidates are timed under the routing they need.

## Tests

```bash
python -m pytest op_tests/test_moe_a4w4_compact.py
AITER_MINIMAX_M3_MXFP4_PATH=/path/to/MiniMax-M3-MXFP4 \
    python -m pytest op_tests/test_moe_a4w4_compact.py -k checkpoint
```

Measurements and open items: [moe_a4w4_compact_findings.md](moe_a4w4_compact_findings.md).
