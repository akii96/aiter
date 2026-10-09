# FlyDSL A4W4 compact MoE findings: MiniMax-M3-MXFP4 prefill MoE on gfx950

Measurements behind `docs/moe_a4w4_compact.md` and the compact rows in
`aiter/configs/model_configs/minimax_m3_fp4_tuned_fmoe.csv`. Kernel numbers are from an
MI350X (gfx950, 256 CUs); the serving profile and the preliminary end-to-end runs are from an
MI355X. Software: image `vllm/vllm-openai-rocm:nightly-bb87d227d4b964abb2a966cdf9194f3d376d9bbe`
(vLLM 0.31.1rc1.dev1+gbb87d227d) with this branch on top of AITER main `e6ded2168`.

## 1. Where MoE time goes in serving

A live vLLM TP4 server with the OOB benchmark settings (`--max-num-batched-tokens 32768`,
`--max-num-seqs 128`, chunked prefill, fused shared experts) logged the token count of every
scheduler step. Time per row, split by tokens per MoE call (% of row wall time):

| Row | ≤16 | 33–64 | 65–128 | 1k–4k | 4k–16k | 16k–32k | ≥1024 total |
|---|---:|---:|---:|---:|---:|---:|---:|
| 8192/1024 c4 | 98.9 | 0 | 0 | 0.9 | 0.2 | 0 | 1.1 |
| 8192/1024 c16 | 94.8 | 0 | 0 | 0.1 | 1.0 | 4.2 | 5.2 |
| 8192/1024 c64 | 3.0 | 79.7 | 0 | 1.1 | 4.2 | 12.0 | 17.3 |
| 8192/1024 c128 | 3.2 | 5.6 | 63.3 | 1.0 | 5.6 | 21.2 | 27.9 |
| 60000/600 c4 | 62.3 | 0 | 0 | 1.4 | 4.5 | 31.8 | 37.7 |
| 60000/600 c16 | 39.0 | 0 | 0 | 1.9 | 7.8 | 51.4 | 61.0 |
| 60000/600 c64 | 0.7 | 21.2 | 0 | 1.7 | 6.7 | 69.8 | 77.8 |
| 128000/1024 c4 | 60.7 | 0 | 0 | 0.8 | 5.2 | 33.2 | 39.2 |
| 128000/1024 c16 | 32.5 | 0 | 0 | 0.8 | 4.7 | 62.0 | 67.5 |

- Prefill MoE work is almost entirely full 32k-token chunks plus a 1k–16k tail from each
  prompt's last chunk; that is the range this family targets.
- 8192/1024 at c4 and c16 is decode-bound and out of scope.

## 2. Existing MXFP4 MoE coverage for MiniMax-M3

- **TP2 (`inter_dim=1536`)** has no tuned rows on main, so it runs the default heuristic.
  That kernel is also about 0.16 relative L2 from a reference that requantizes the
  intermediate in fp32 (it rounds the intermediate to bf16 first); the compact family is
  2.4e-3.
- **TP8 (`inter_dim=384`).** Main's 384 rows run and are accurate when called through
  `fused_moe` at prefill sizes, eager and under CUDA graph capture (256–32768 tokens,
  2.4e-3 to 3.3e-3). Below 256 tokens main has no 384 rows for the bf16-activation decode
  path and the default kernel is used. vLLM does not reach any 384 row today: it rounds the
  ROCm MXFP4 intermediate size up to 256, so the TP8 shard runs at 512, where there are no
  tuned rows. Reports of failures at 384 in serving have not been reproduced at kernel level.
- No upstream path has compact rows without `block_m` padding, a prefill-scale fused quant and
  sort on gfx950, a persistent 256x256 stage 1, or a combine folded into stage 2.

## 3. Kernel-level results (MI350X)

`fused_moe` as vLLM calls it for MiniMax-M3 (E=129 including the fused shared expert, topk 5,
expert `E-1` routed once per token, `AITER_MOE_A4W4_COMPACT_FUSED_SHARED_EXPERT=1`), same
inputs and weights, warm GPU time with host run-ahead, median of 5 round-robin repetitions.
"Main" is main's `minimax_m3_fp4_tuned_fmoe.csv` (its row, or the default heuristic); "this
branch" is the CSV shipped here. Relative L2 is against a torch reference with AITER's MX
quantization (computed up to 4096 tokens).

| inter_dim | Tokens | Main (µs) | This branch (µs) | Speedup | Null | Main L2 | Branch L2 |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 384 | 512 | 129.5 | 129.0 | 1.00x (main row) | 0.2% | 3.3e-03 | 3.3e-03 |
| 384 | 1024 | 155.0 | 155.1 | 1.00x (main row) | 0.2% | 2.4e-03 | 2.4e-03 |
| 384 | 2048 | 234.4 | 228.3 | 1.03x | 0.4% | 2.4e-03 | 2.4e-03 |
| 384 | 4096 | 348.3 | 318.0 | 1.10x | 0.3% | 2.4e-03 | 2.4e-03 |
| 384 | 8192 | 624.2 | 542.9 | 1.15x | 0.9% | | |
| 384 | 16384 | 1135.3 | 1060.4 | 1.07x | 2.0% | | |
| 384 | 32768 | 2177.5 | 2019.2 | 1.08x | 0.3% | | |
| 768 | 512 | 215.3 | 216.2 | 1.00x (main row) | 0.2% | 3.3e-03 | 3.3e-03 |
| 768 | 1024 | 243.2 | 243.6 | 1.00x (main row) | 0.1% | 3.3e-03 | 3.3e-03 |
| 768 | 2048 | 364.7 | 348.5 | 1.05x | 0.1% | 2.4e-03 | 2.4e-03 |
| 768 | 4096 | 486.2 | 489.6 | 0.99x (main row) | 0.0% | 2.4e-03 | 2.4e-03 |
| 768 | 8192 | 877.6 | 788.3 | 1.11x | 0.1% | | |
| 768 | 16384 | 1503.5 | 1409.3 | 1.07x | 0.2% | | |
| 768 | 32768 | 2869.9 | 2516.9 | 1.14x | 0.1% | | |
| 1536 | 512 | 436.0 | 435.6 | 1.00x (default) | 0.2% | 1.6e-01 | 1.6e-01 |
| 1536 | 1024 | 593.0 | 491.8 | 1.21x | 0.5% | 1.6e-01 | 2.4e-03 |
| 1536 | 2048 | 654.7 | 615.4 | 1.06x | 0.0% | 1.6e-01 | 2.4e-03 |
| 1536 | 4096 | 976.7 | 838.6 | 1.16x | 2.3% | 1.6e-01 | 2.4e-03 |
| 1536 | 8192 | 1623.4 | 1396.9 | 1.16x | 0.7% | | |
| 1536 | 16384 | 2936.2 | 2298.2 | 1.28x | 0.4% | | |
| 1536 | 32768 | 5581.6 | 4036.3 | 1.38x | 0.0% | | |

Cells where the compact family was not at least 1.02x faster stay on main's row.

**How the rows were chosen.** Every cell was timed in one harness four ways: the family's
own tile-table config through `fused_moe`, the tuner's pick through `fused_moe`, main, and the
family called directly without the registry. The registry path is within noise of the direct
call; the tuner's picks were within 1.5% of the table configs except 384 @ 8192 (5.8% slower),
so every shipped row uses the table config. Two exceptions: with weights read in place, the
1536 @ 2048 and 1536 @ 4096 table configs regress because a stage-2 kernel spills, so those
rows use the next-best configs (see Not done).

**In-place weights.** The kernels read `shuffle_weight(16, 16)` fp4 bytes directly. Output is
bit-identical to the earlier repacking path; the second copy of the expert weights is gone
(435 / 871 / 1742 MiB per MiniMax-M3 layer at 384 / 768 / 1536).

## 4. Accuracy

- Every shipped config: 2.4e-3 relative L2 against the AITER-quantization torch reference.
- Real checkpoint (layer 30, TP shards at 384 / 768 / 1536, real router, shared expert as
  128): 2.34e-3 to 2.38e-3 for every config (`test_moe_a4w4_compact_checkpoint_weights`).
- AITER's runtime MX quant uses the round-up e8m0 rule; MiniMax-M3 was calibrated with Quark's
  `even` rule, which gives about 6% less activation quantization error on real layer-30
  weights. The family defaults to round-up to match AITER; `AITER_MOE_A4W4_COMPACT_SCALE_RULE=even`
  selects the checkpoint rule.

## 5. End to end (preliminary, MI355X)

vLLM with the OOB serving flags, measured before the in-place weight change (the family then
kept a repacked weight copy, so it ran with 54 GiB less KV cache per GPU at TP4). To be
re-measured with this branch.

| TP | Row | Output tok/s | Mean TTFT (ms) | Mean TPOT (ms) |
|---|---|---|---|---|
| 4 | 60000/600 c64 | 438.7 → 467.8 | 15153 → 13917 | 122.1 → 114.1 |
| 4 | 128000/1024 c4 | 282.6 → 302.0 | 3265 → 2887 | 10.09 → 9.58 |
| 4 | 8192/1024 c128 | 2939.0 → 3055.3 | 3254 → 3059 | 37.20 → 35.88 |
| 8 | 60000/600 c64 | 504.6 → 613.2 | 13623 → 10963 | 104.9 → 85.0 |
| 8 | 128000/1024 c4 | 309.3 → 297.6 | 2769 → 2487 | 9.36 → 10.11 |
| 8 | 8192/1024 c128 | 3516.6 → 3910.5 | 2761 → 2231 | 31.05 → 27.57 |

TP8 baseline: stock vLLM (384 padded to 512, default kernels). TP8 with this family: a
prototype vLLM change that keeps the shard at 384 (see below). The TP8 c4 TPOT regression is
decode at 384, which has no tuned bf16-activation rows.

## 6. vLLM companion change

`vllm/model_executor/layers/fused_moe/oracle/mxfp4.py` rounds the ROCm MXFP4 intermediate size
up to 256. Allowing 128 for the AITER A4W4 backend keeps the MiniMax-M3 TP8 shard at 384 so
it reaches these rows. It should land together with `minimax_m3_a16w4` decode rows at
`inter_dim=384`.

## 7. Not done

- 1536 @ 2048 / 4096: with in-place weights, the stage-2 BM=128 `waves_per_eu_2` kernel spills
  (32 VGPRs vs 3 before). Those rows currently use other configs.
- `minimax_m3_a16w4` decode rows at `inter_dim=384`.
- End-to-end numbers on this branch.
