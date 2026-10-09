# FlyMoE: A4W4 MXFP4 prefill MoE for gfx950

FlyMoE is a FlyDSL MoE kernel family for MXFP4 weights and activations (fp4 e2m1,
e8m0 scales per 1x32 group) with the SwiGLU-OAI activation, built for prefill-sized
batches (512 to 32768 tokens per call) on MI355X. It is reached through `fused_moe`
like every other backend: a tuned row whose `kernelName1` is `impl__flymoe__<config>`
dispatches the whole MoE to it through `aiter.fused_moe_registry`.

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
`GateMode.SEPARATED`. FlyMoE repacks them into its own layout once per weight tensor
on first use and keeps that copy for the tensor's lifetime.

Unsupported calls (other activations, bias, expert parallelism, padding, prequantized
activations, `doweight_stage1`) never reach FlyMoE: `unsupported_reason` lists them.

Environment:

| Variable | Default | Meaning |
|---|---|---|
| `AITER_FLYMOE_FUSED_SHARED_EXPERT` | `0` | `1` when expert `E-1` is a shared expert routed exactly once per token (vLLM `VLLM_ROCM_USE_AITER_FUSION_SHARED_EXPERTS=1`). Enables the fused combine; without it those rows run the separate combine. |
| `AITER_FLYMOE_SCALE_RULE` | `ceil` | e8m0 rule for the runtime activation quant. `ceil` matches AITER's MX quant; `even` matches checkpoints calibrated with `scale_calculation_mode="even"` (Quark). |

## Tuning

```bash
python csrc/ck_gemm_moe_2stages_codegen/gemm_moe_tune.py \
    -i aiter/configs/model_configs/minimax_m3_fp4_untuned_fmoe.csv \
    -o aiter/configs/model_configs/minimax_m3_fp4_tuned_fmoe.csv --e2e_tune
```

On gfx950 `--e2e_tune` times every FlyMoE candidate from
`aiter/ops/flydsl/flymoe/configs/` against the existing row and keeps the faster one.

## Tests

```bash
python -m pytest op_tests/test_flymoe.py
```

Measurements, end-to-end results and open items: [flymoe_findings.md](flymoe_findings.md).
