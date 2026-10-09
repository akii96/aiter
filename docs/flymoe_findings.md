# FlyMoE findings: MiniMax-M3-MXFP4 prefill MoE on MI355X

Measurements behind `docs/flymoe.md` and the tuned rows in
`aiter/configs/model_configs/minimax_m3_fp4_tuned_fmoe.csv`. All runs were on one MI355X node
(8x gfx950, 256 CUs each) with image `vllm/vllm-openai-rocm:nightly-bb87d227d4b964abb2a966cdf9194f3d376d9bbe`
(vLLM 0.31.1rc1.dev1+gbb87d227d, AITER 0.1.24.post1 = upstream `c8325e00c`) and upstream AITER
main `e6ded2168`.

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
  prompt's last chunk.
- 8192/1024 at c4 and c16 is decode-bound (≥ 94% of time at ≤ 16 tokens per call). Those rows
  are out of scope here; small-batch decode is handled by the ASM / monolithic decode kernels.
- Decode at c64/c128 runs 33–128 tokens per call, which falls between the decode kernels' range
  and the 256-token fp4-activation threshold. It is noted, not addressed here.

Representative serving points, chosen so their MoE token mix covers the prefill and
mixed-batch time of the whole table:

1. **60000/600 c64**: 78% of time in ≥ 1k-token calls; proxy for 60k c16 and 128k c16.
2. **128000/1024 c4**: long-context TTFT with a real decode share.
3. **8192/1024 c128**: mixed batches; proxy for the high-concurrency 8k rows.

## 2. Existing MXFP4 MoE coverage for MiniMax-M3

- vLLM rounds the ROCm MXFP4 intermediate size up to 256 (`fused_moe/oracle/mxfp4.py`), so the
  TP8 shard (384) is served as 512. No tuned CSV on main or in the image has rows for
  `inter_dim=512` with 129 experts, so TP8 prefill runs on the default heuristic
  (`flydsl_moe1_*` + `flydsl_moe2_*_atomic`).
- There are no merged tuned rows for `inter_dim=1536` (TP2), so TP2 prefill also runs on the
  default heuristic. Open PR #6085 adds TP2 rows.
- Since the image, main changed four MiniMax-M3 rows at 16k/32k tokens to a scatter stage 2
  (#5812), 10–12% faster at TP4. Everything else matches the image within ±1%.
- No upstream path has compact rows without block_m padding, a prefill-scale fused quant and
  sort on gfx950, a persistent 256x256 stage 1, or a combine folded into stage 2. Native-384
  kernels exist, but vLLM pads to 512 before they are reached.

## 3. Kernel-level A/B through `fused_moe`

Same inputs and weights, fused shared expert routing (E-1 once per token), warm GPU time with
host run-ahead, median of 7 round-robin repetitions, null arm within 1%. "Main" is main's tuned
row, or the default heuristic where it has none.

| inter_dim | Tokens | Main (µs) | FlyMoE (µs) | Main / FlyMoE | Main row |
|---:|---:|---:|---:|---:|---|
| 384 | 512 | 115.7 | 132.8 | 0.87 | tuned (kept) |
| 384 | 1024 | 140.6 | 156.4 | 0.90 | tuned (kept) |
| 384 | 2048 | 214.1 | 203.9 | 1.05 | tuned |
| 384 | 4096 | 312.6 | 283.8 | 1.10 | tuned |
| 384 | 8192 | 558.7 | 512.3 | 1.09 | tuned |
| 384 | 16384 | 968.3 | 893.7 | 1.08 | tuned |
| 384 | 32768 | 1812.7 | 1733.2 | 1.05 | tuned |
| 768 | 512 | 189.6 | 210.3 | 0.90 | tuned (kept) |
| 768 | 1024 | 215.0 | 247.6 | 0.87 | tuned (kept) |
| 768 | 2048 | 315.6 | 303.5 | 1.04 | tuned |
| 768 | 4096 | 425.5 | 423.5 | 1.00 | tuned (kept) |
| 768 | 8192 | 756.3 | 668.4 | 1.13 | tuned |
| 768 | 16384 | 1271.8 | 1149.2 | 1.11 | tuned |
| 768 | 32768 | 2396.9 | 2141.9 | 1.12 | tuned |
| 1536 | 512 | 374.7 | 380.8 | 0.98 | default (kept) |
| 1536 | 1024 | 515.4 | 426.1 | 1.21 | default |
| 1536 | 2048 | 555.3 | 490.0 | 1.13 | default |
| 1536 | 4096 | 816.3 | 695.9 | 1.17 | default |
| 1536 | 8192 | 1356.8 | 1090.5 | 1.24 | default |
| 1536 | 16384 | 2361.7 | 1842.8 | 1.28 | default |
| 1536 | 32768 | 4479.0 | 3292.1 | 1.36 | default |

Rows marked "kept" stay on the existing kernels; FlyMoE rows were adopted only at ≥ 1.02x.
The 768 and 1536 rows at 8192–32768 tokens use the fused combine; with
`AITER_FLYMOE_FUSED_SHARED_EXPERT=0` the same rows measure 1.05–1.11x (768) and 1.23–1.32x
(1536).

Against the 512-padded default path vLLM uses at TP8 today (image AITER), FlyMoE at 384 is
0.65–0.80x the time at 2k–32k tokens (2545 → 1655 µs at 32768).

**Integration overhead.** The registry path costs between −0.8% and +3.4% of GPU time versus
the standalone FlyMoE package on the same configs (host time about 100 µs per call versus 50 µs
standalone).

## 4. End to end

vLLM with the OOB serving flags, MiniMax-M3-MXFP4, `VLLM_ROCM_USE_AITER_FUSION_SHARED_EXPERTS=1`,
`AITER_FLYMOE_FUSED_SHARED_EXPERT=1`. Only the AITER install differs between arms.

**TP4** (inter_dim 768):

| Row | Output tok/s | Mean TTFT (ms) | Mean TPOT (ms) |
|---|---|---|---|
| 60000/600 c64 | 438.7 → 467.8 | 15153 → 13917 | 122.1 → 114.1 |
| 128000/1024 c4 | 282.6 → 302.0 | 3265 → 2887 | 10.09 → 9.58 |
| 8192/1024 c128 | 2939.0 → 3055.3 | 3254 → 3059 | 37.20 → 35.88 |

**TP8** (stock: 384 padded to 512, image AITER; FlyMoE: native 384 with the vLLM change below):

| Row | Output tok/s | Mean TTFT (ms) | Mean TPOT (ms) |
|---|---|---|---|
| 60000/600 c64 | 504.6 → 613.2 | 13623 → 10963 | 104.9 → 85.0 |
| 128000/1024 c4 | 309.3 → 297.6 | 2769 → 2487 | 9.36 → 10.11 |
| 8192/1024 c128 | 3516.6 → 3910.5 | 2761 → 2231 | 31.05 → 27.57 |

At 128000/1024 c4, six of sixteen prompts exceed the 133120-token context in both arms and are
rejected; the numbers cover the ten that ran. The TP8 c4 TPOT regression is decode: at 384,
bf16-activation decode (< 256 tokens) has no `minimax_m3_a16w4` rows and runs the default
kernel. Tuning those rows at 384 is required before vLLM drops the padding.

The FlyMoE arm had 148 GiB of KV cache per GPU at TP4 against 202 GiB for stock, because the
repacked weights are kept alongside the originals.

## 5. Accuracy

- Every shipped FlyMoE config: relative L2 2.4e-3 against a torch reference using AITER's MX
  quantization, the bf16 output floor and equal to the existing tuned rows.
- Real checkpoint (layer 30, TP rank-0 shards at 384 / 768 / 1536, real router, shared expert
  as 128): 2.34e-3 to 2.38e-3 for every config (`test_flymoe_checkpoint_weights`).
- AITER's runtime MX quant, in both the image and main, uses the round-up e8m0 rule
  (`kDefaultMxScaleRoundMode = RoundUp`); the checkpoint was calibrated with Quark's `even`
  rule. On real layer-30 weights, `even` gives about 6% less activation quantization error
  (relative L2 against unquantized activations 0.204–0.210 vs 0.218–0.224). FlyMoE defaults
  to round-up to match AITER; `AITER_FLYMOE_SCALE_RULE=even` selects the checkpoint rule.
- AITER's default-heuristic path (512, 1536) shows 0.15–0.19 against a fp32-intermediate
  reference. That is the reference, not a bug: those kernels round the intermediate to bf16
  before requantizing. A matching reference gives 3e-3.

## 6. vLLM companion change

`vllm/model_executor/layers/fused_moe/oracle/mxfp4.py`, ROCm branch of the size round-up: allow
an alignment of 128 for the AITER A4W4 backend instead of 256, so the TP8 shard stays at 384.
The prototype used for the TP8 numbers gated it on an environment variable:

```diff
-            128 if is_situ_or_silu and (aiter_uses_128 or triton_uses_128) else 256
+            128
+            if (is_situ_or_silu and (aiter_uses_128 or triton_uses_128))
+            or envs_flymoe
+            else 256
```

## 7. Not done

- FlyMoE kernels still read their own weight layout, so the backend keeps a repacked copy of
  the expert weights (about 51 GiB per GPU at TP4 for MiniMax-M3). The fp4 weight bytes already
  match `shuffle_weight(16, 16)`; reading the `e8m0_shuffle` scale layout and the natural
  gate/up and output row order directly removes the copy.
- `minimax_m3_a16w4` decode rows at `inter_dim=384`.
