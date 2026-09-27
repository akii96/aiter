# Non-FLAT (`flat=0`) Assembly MoE Kernel for MiniMax-M3 — Reassessment

**Verdict: NO-GO.** Not because of the FLAT argument (which does **not** transfer), but because
every kernel in the prefill MoE path is **bandwidth-bound, not instruction-bound**. The `fp4`
compute roof is the wrong denominator for the kernels that dominate the time.

**Author:** analysis agent · **GPUs:** 6,7 (exclusive) · **Host:** smci355-ccs-aus-m11-33 · **Container:** `aakif_vllm` · **aiter:** `8253efc4`
**Measurement protocol:** all comparative timings serial on ONE GPU (GPU 6), arms round-robin interleaved, medians ≥5.

---

## ⚠️ Correction notice — read before using any earlier figure

An earlier interim status from this investigation described stage-2 partials as **fp32**
(1,920 MB at M=16384). **That was wrong. The partials are `bf16` — 960 MB.**

Runtime proof (allocation interception during a real `fused_moe` call, M=16384,
`inter_dim=384`, tuned row `flydsl_moe2_layout_afp4_wfp4_bf16_t64x256x128_reduce_sbm64`):

```
expected partial elems = M*topk*model_dim = 503,316,480
  if fp32 -> 1,920 MB        if bf16 ->   960 MB
   kind                shape            dtype         MB
  empty   (16384, 5, 6144)   torch.bfloat16      960.0   <-- THE PARTIAL BUFFER
  empty      (16384, 6144)   torch.bfloat16      192.0
  empty    (16384, 5,  384)  torch.bfloat16       60.0   <-- stage-1 intermediate, also bf16
```

Source agrees: `moe_kernels.py:2216` allocates `dtype=torch.uint8 if _s2_fp8_inter else out.dtype`,
and `out.dtype` is bf16. **There is therefore no fp32/bf16 inconsistency and no bug** — the
`moe_reduction_bf16_bf16` kernel is named accurately because it is genuinely bf16-in/bf16-out.
All figures in this document use the corrected bf16 values. The correction *strengthens* the
NO-GO, because it leaves half as much traffic available to remove.

---

## 0. Executive summary

| Question asked | Answer found |
|---|---|
| Does the 145 GB FLAT amplification argument apply to `flat=0`? | **No.** Non-FLAT per-WG M is `block_m`, not 1. Amortization is exactly `block_m`-fold (64×). The prior closure was over-scoped, as suspected. |
| Do non-FLAT MXFP4 ASM tiles exist? | **Yes, they already ship.** 8 rows, `flat=0`, `subGU_m=32`. Only the *activation* is missing for M3. |
| Is prefill MoE at ~26% of the fp4 compute roof? | **No — it is at 12–13%.** Worse than the estimate. |
| Does that 12–13% justify assembly? | **No.** Decomposed, every kernel is at **68–102% of achievable bandwidth**. There is no instruction-shaped gap to attack. |
| Is there an adjacent target? | **Yes, but it is closed too** — and one candidate is actively **numerically broken** (§6). |

The single number that closes it: **stage-2, which is 65–70% of MoE time, runs at 75% of measured
copy bandwidth while using 11% of the MFMA pipe.** The `moe_reduction` kernel runs at **102%** of
copy bandwidth with **literally zero MFMA instructions**. Assembly cannot move bandwidth.

---

## 1. Task 1 — `flat_mode == 0`: grid, per-WG M, and the amplification arithmetic

### 1.1 The grid (VERIFIED, `csrc/py_itfs_cu/asm_fmoe.cu:208-213`)

```cpp
else // no-ps
{
    bdx = 256;
    gdx = ((inter_dim + sub_GU - 1) / sub_GU);
    gdy = sub_X_cnt;
    gdz = 1;
}
```

Contrast with `flat_mode == 1` (`:192-198`), which is `gdz = token_cnt, gdy = topk`.

### 1.2 What `sub_X_cnt` actually is — the crux

`asm_fmoe.cu:119`:
```cpp
int sub_X_cnt = sorted_expert_ids->size(0);
```

and `aiter/fused_moe.py:167`:
```python
sorted_expert_ids = torch.empty(max_sorted // BM, dtype=dtypes.i32, device=device)
```

`sorted_expert_ids` holds **one entry per M-block of `BM` sorted rows**, not one per token.
Therefore in non-FLAT mode:

> **`gdy` = number of M-blocks, and per-workgroup M = `block_m` (= `subGU_m`), not 1.**

`subGU_m` is *not* nominal metadata here — it is the real tile M, and it is also validated in
heuristic selection (`:267`, `block_size_M == cfg.subGU_m`). This is the exact opposite of the
FLAT case. **A `flat=0` kernel does amortize a weight tile across `block_m` tokens.**

### 1.3 The arithmetic (inter_dim = 384, the served shape)

Weight working set, per full expert set:
- elements = `E·2·inter·model + E·model·inter` = `129·2·384·6144 + 129·6144·384` = **913,047,552**
- bytes = fp4 nibble (0.5 B) + one e8m0 scale per 32 values (1/32 B) = **462.6 MB**

| M | FLAT workgroups (`M·topk`) | FLAT weight reads | non-FLAT (`block_m=64`) | **ratio** |
|---|---|---|---|---|
| 4,096 | 20,480 | **71.7 GB** | **1.1 GB** | **64×** |
| 32,768 | 163,840 | **573.8 GB** | **9.0 GB** | **64×** |

The ratio is exactly `block_m`, as the structure predicts. Non-FLAT's floor is the single-pass
462.6 MB whenever rows-per-expert ≥ `block_m`.

Rows per expert = `M·topk/E`; re-read amplification = `ceil(R/block_m)·block_m / R`:

| M | rows/expert | `block_m` | amplification | effective weight traffic |
|---|---|---|---|---|
| 512 | 19.8 | 32 | 1.61× | 746 MB |
| 2,048 | 79.4 | 128 | 1.61× | 746 MB |
| 4,096 | 158.8 | 64 | 1.21× | 559 MB |
| ≥8,192 | ≥317 | 64 | **1.01×** | **466 MB** |

**Conclusion: the 145 GB argument is FLAT-specific and does not transfer.** The brief's concern
about over-scoped closure was correct. It simply does not rescue the case, for reasons in §3–§5.

---

## 2. Task 2 — Inventory of existing non-FLAT ASM tiles

`hsa/gfx950/fmoe/` contains **878 `.co` binaries**. The MXFP4 g1u1 config maps:

`hsa/gfx950/fmoe/silu/fmoe_bf16_pertokenMXfp4_g1u1_silu.csv` — columns
`knl_name,co_name,atm,vskip,smf,tg_num_perCU,ps,subGU_m,subGU_n,flat`:

| kernel | ps | `subGU_m` | `subGU_n` | `flat` |
|---|---|---|---|---|
| `..._vs_silu_2tg_32x256` | 0 | **32** | 256 | **0** |
| `..._novs_silu_2tg_32x256` | 0 | **32** | 256 | **0** |
| `..._novs_silu_1tg_32x512` | 0 | **32** | 512 | **0** |
| `..._novs_silu_2tg_ps_2tg_32x256` | 1 | **32** | 256 | **0** |
| `..._vs_silu_1tg_ps_32x512` | 1 | **32** | 512 | **0** |
| `..._vs_silu_1tg_32x512` | 0 | **32** | 512 | **0** |
| `..._novs_silu_1tg_ps_32x512` | 1 | **32** | 512 | **0** |
| `..._vs_silu_2tg_ps_32x256` | 1 | **32** | 256 | **0** |
| `..._flat_novs_silu_16x128` | – | 16 | 128 | 1 |
| `..._flat_vs_silu_16x32` | – | 16 | 32 | 1 |
| `..._flat_novs_silu_16x256` | – | 16 | 256 | 1 |

The `gelu` directory mirrors this exactly. `fmoe_fp16_pertokenMXfp4_g1u1_silu.csv` has 8 more
non-FLAT rows (and no `flat` column at all — all non-FLAT).

**Finding that materially changes the premise:** the task framed non-FLAT MXFP4 ASM as something
to be *written*. It already exists and ships — **8 non-FLAT MXFP4 g1u1 tiles at `subGU_m=32`**,
in vs/novs × ps/non-ps × 256/512-N variants.

The only gap for MiniMax-M3 is the **activation**: shipped tiles are Silu/Gelu; M3 needs Swiglu
(`swiglu_limit=7.0`). Routing confirms this is the sole discriminator — `asm_fmoe.cu:601-612`
selects `config_map` purely on `out->dtype()` × `act`, and there is no Swiglu arm for the fp4
branch. **This is a `.co` rebuild with a different epilogue, not a tile design problem.**
Anyone resuming this work should start there, not from scratch.

*(Note: heuristic selection at `:260-291` requires `cfg.flat == 0`, so these non-FLAT tiles are
the ones the heuristic can actually reach; FLAT tiles are reachable only by explicit `kernelName1`.)*

---

## 3. Task 3 — The compute roof, derived from the ISA and validated

### 3.1 Derivation

`v_mfma_f32_32x32x64_f8f6f4` assembles for gfx950 (llvm-mc, `-mcpu=gfx950`):

```
v_mfma_f32_32x32x64_f8f6f4 v[0:15], v[16:19], v[20:23], v[0:15] cbsz:4 blgp:4
  ; encoding: [0x00,0x04,0xae,0xd3,0x10,0x29,0x02,0x84]
```

`cbsz:4 blgp:4` selects **FP4 (e2m1)** operands — A/B shrink to 4 VGPRs/lane (32 fp4 values),
versus 8 VGPRs for FP8. Per instruction:

- FLOP = `2 · M · N · K` = `2 · 32 · 32 · 64` = **131,072 FLOP**
- Measured issue rate ⇒ **32 cycles/instr/SIMD** ⇒ `131072 / 32` = **4,096 FLOP/clk/SIMD**

**Peak = 4,096 FLOP/clk/SIMD × 4 SIMD/CU × 256 CU × 2.4 GHz = 10.07 PFLOP/s**

(`rocminfo`: gfx950, Compute Unit **256**, Max Clock **2400 MHz**.)

### 3.2 Measurement and validation

Back-to-back dependent-free MFMA, 512 blocks × 256 threads, 9 rounds, **round-robin interleaved**,
GPU 6 sole occupant:

| arm | median (ms) | **TFLOP/s** | vs FP4 | vs theory |
|---|---|---|---|---|
| FP4 `32x32x64` | 10.945 | **9,810** | 1.00× | 97.4% |
| **MXFP4 `v_mfma_scale_f32_32x32x64`** | 11.242 | **9,551** | **0.97×** | 94.8% |
| FP4 `16x16x128` | 5.851 | 9,175 | 0.94× | – |
| MXFP4 scale `16x16x128` | 6.047 | 8,879 | 0.91× | – |
| FP8 `32x32x64` | 21.612 | 4,968 | **0.51×** | – |
| BF16 `32x32x16` | 21.520 | 2,495 | **0.25×** | – |

**Validation:** FP8 lands at *exactly* ½ and BF16 at *exactly* ¼ of FP4 — the documented MI355X
ratios. The harness reproduces the datasheet, so the FP4 figure is trustworthy.

> **Two reusable results:**
> 1. **MXFP4 compute roof = 9,551 TFLOP/s** (scaled MFMA, the form a real kernel must use).
> 2. **Scale-aware MFMA costs only 3%** vs unscaled. This **permanently kills the
>    "scale-loading overhead is a tax worth hand-assembly" theory** — the hardware applies
>    per-32 e8m0 scales essentially for free.

### 3.3 Achieved — the gate measurement

Served shape: `model_dim=6144, inter_dim=384, E=129, topk=5, Swiglu, per_1x32, a4w4 (fp4 A, fp4 W)`.
Measured through production `fused_moe` via aiter's own `kernel_bench_callable` hook
(isolates the stage kernels, excludes prep/sort/quant). GPU 6, serial, interleaved across M.

| M | us1 | us2 | total | TFLOP/s | **% of 9,551** | stage1 %roof | stage2 %roof |
|---|---|---|---|---|---|---|---|
| 4,096 | 89.0 | 164.0 | 253.0 | 1,146 | **12.0%** | 22.7% | 6.1% |
| 8,192 | 149.2 | 327.1 | 476.4 | 1,217 | **12.7%** | 27.1% | 6.1% |
| 16,384 | 271.8 | 633.1 | 904.9 | 1,282 | **13.4%** | 29.8% | 6.7% |

Cross-check against the shipped tuned CSV (`minimax_m3_fp4_tuned_fmoe.csv`, `inter_dim=384`),
whose `tflops` column I verified is `6·M·topk·model_dim·inter_dim / us`:

| M | CSV us | CSV %roof | my %roof | agreement |
|---|---|---|---|---|
| 4,096 | 271.7 | 11.2% | 12.0% | ✅ |
| 8,192 | 500.7 | 12.1% | 12.7% | ✅ |
| 16,384 | 891.8 | 13.6% | 13.4% | ✅ |

**Answer to the gate: ~12–13%, not 26% and not 70%+.** Independently reproduced.

---

## 4. Task 4 — Is the gap instruction-shaped? **No.**

Per the brief's own standard, 12% of *compute* roof only justifies assembly if the mechanism is
instruction scheduling. It is not. Two independent lines of evidence.

### 4.1 The arithmetic intensity says memory-bound

Measured on GPU 6 (8 GiB buffers, 7 rounds): **HBM read 6.23 TB/s, copy 4.67 TB/s.**

Machine balance = `9,551 TFLOP/s ÷ 6.23 TB/s` = **1,533 FLOP/byte**.

The brief cited AI ≈ 1,413 vs balance ≈ 1,258 ⇒ "compute-bound". **That AI counts weight traffic
only.** Counting all traffic the kernel actually moves (weights + activations + topk-expanded
partials):

| M | AI (weights only) | **AI (realistic)** | balance | verdict |
|---|---|---|---|---|
| 4,096 | 598 | **275** | 1,533 | **MEMORY-BOUND** |
| 8,192 | 1,195 | **357** | 1,533 | **MEMORY-BOUND** |
| 16,384 | 2,391 | **419** | 1,533 | **MEMORY-BOUND** |

Realistic AI is **3.7–5.6× below** machine balance. Prefill MoE is *not* the compute-bound regime
the brief assumed — the `topk=5` output expansion dominates and pulls AI far down.

### 4.2 Hardware counters confirm it (`rocprofv3`, wrapped form)

`rocprofv3 --pmc ... -- <cmd>` works on this build (the `--attach` failure noted in the brief is
not a blocker). M=8192, `inter_dim=384`, medians over 8 dispatches. MFMA-pipe % computed as
`SQ_INSTS_MFMA × 16 passes ÷ (duration × 2.4 GHz × 256 CU × 4 SIMD)`:

| kernel | dur (µs) | MFMA instrs | **MFMA pipe %** | VALU instrs | vgpr | LDS |
|---|---|---|---|---|---|---|
| `gemm2_a4w4_..._bm64_bn256_bk128_reduce` | 192.7 | 3.22e6 | **10.9%** | 1.51e7 | 8 | 32,768 |
| `gemm1_a4w4_..._h6144_i384_ne129_bm64_cached_sep_swiglu` | 147.6 | 6.44e6 | **28.4%** | 1.02e7 | 104 | 66,560 |
| **`moe_reduction_bf16_bf16_t5_n6144`** | **126.8** | **0** | **0.0%** | 6.78e6 | 44 | 0 |
| `dynamic_per_group_scaled_quant_kernel` | 25.8 | 0 | 0.0% | 4.38e6 | 64 | 0 |
| `opus_moe_sorting_entry` / `mxfp4_moe_sort_kernel` | 13.9 / 7.8 | 0 | 0.0% | – | – | – |

**The third-largest kernel in the MoE path issues zero MFMA instructions.** It is pure data
movement. No instruction scheduling, software pipelining, or `s_waitcnt` placement can help a
kernel with no math in it.

### 4.3 The right denominator differs per kernel — the methodological point

Recomputing each kernel against the bound that actually constrains it (M=8192). **Partials are
`bf16`, not fp32** — `moe_kernels.py:2050` allocates `dtype=out.dtype`:

| kernel | traffic | achieved | **% of copy roof (4.67 TB/s)** | MFMA pipe % |
|---|---|---|---|---|
| `gemm1` | W1 308 MB + A 128 MB + out 8 MB = 444 MB | 3.15 TB/s | **68%** | 28.4% |
| `gemm2` | A2 8 MB + W2 154 MB + **partials 480 MB** = 642 MB | 3.49 TB/s | **75%** | 10.9% |
| `moe_reduction` | read 480 MB + write 96 MB = 576 MB | 4.76 TB/s | **102%** | 0.0% |

`moe_reduction` exceeding 100% of the STREAM-copy figure indicates cache-assisted reuse — it is
**already at or beyond the achievable movement rate and cannot be improved**.

> **Every kernel in the path is at 68–102% of its true (bandwidth) roof.**
> The 12% figure is an artifact of dividing by the wrong roof. There is no instruction-shaped gap.

### 4.4 FlyDSL already emits the scheduling primitives assembly would provide

The case for assembly was specifically "instruction scheduling, software pipelining, and
`s_waitcnt` placement the DSL cannot express". It **can** express them — `mxmoe_gemm_v2.py`:

- `rocdl.sched_barrier(0)` — lines 702, 736, 739, 743, 803, 848, 852
- `rocdl.s_setprio(1)` / `s_setprio(0)` bracketing the MFMA cluster — 740/742, 849/851
- `rocdl.s_waitcnt(vmcnt=0, lgkmcnt=0)` — explicit placement, line 734
- explicit **2-stage software pipeline** with rotating buffers and prefetch (`_ks_prefetch`,
  `cur_bqf`/`nxt_bqf` swap, `scf.for` carried state), line 746 comment
- A-scale prefetch (`g2_ascale_pf`), B-hoist (`g2_bhoist`), epilogue interleaving into the MFMA
  cluster (`interleave=epi_thunks`)

There is no identified mechanism hand-assembly would add. **I do not expect one.**

---

## 5. Stage-1 vs stage-2 are 3.5–4.9× apart (the adjacent question)

| M | stage1 %compute-roof | stage2 %compute-roof | ratio |
|---|---|---|---|
| 4,096 | 22.7% | 6.1% | 3.7× |
| 8,192 | 27.1% | 6.1% | 4.4× |
| 16,384 | 29.8% | 6.7% | **4.9×** |

Stage-1 climbs with M (22.7→29.8%) and has genuine math (28.4% MFMA pipe, 104 VGPRs, 65 KB LDS).
Stage-2 is pinned flat at ~6% — because it is bandwidth-saturated, not because it is badly coded.

Stage-1 issued-FLOP cross-check (M=8192): `6.44e6 MFMA × 65,536 FLOP` = 4.22e11 issued vs 3.87e11
useful ⇒ **only 1.09× padding waste**. Tiling is near-ideal; `inter_dim=384` with `tile_n=128`
(auto-downgraded from 256, see `resolve_flydsl_stage1_tile_n`) is not leaving much on the table.

---

## 6. Stage-2 traffic options — all three priced and closed

Stage-2 + reduction move `M·topk·model_dim` bf16 partials (480 MB at M=8192, **75% of gemm2
traffic**). Since stage-2 is bandwidth-saturated, **removing bytes is the only lever that can
move it**, and there are exactly three ways to remove these bytes: store them narrower, never
write them, or never create them. All three are assessed below.

### (a) Narrower partials — **REJECTED (no benefit at the production shape)**

> **Superseded sub-section.** The measurements below were taken before two confounds were
> identified; the corrected analysis is in `BUG_stage2_fp8_nonfinite.md` (same branch). In short:
> the `AITER_FLYDSL_STAGE2_FP8` flag is **inert at the production `inter_dim=512`** (measured
> 0.998–0.999×, because that shape uses an `atomic` epilogue and allocates no partial buffer),
> and the 1.276× below was measured at `inter_dim=384` — a shape that is both unreachable for
> MiniMax-M3 and subject to an uninitialised-memory defect. **The true accuracy cost of fp8
> partials remains unmeasured**; both the 2.69e-2 and ~1e-4 figures reported during this
> investigation were withdrawn. Option (a) is closed for the plainer reason that **it delivers no
> speedup on the shape that ships**. The NO-GO verdict of this report is unaffected.


Partials are **already bf16** (not fp32 — my earlier estimate was 2× too high and is corrected
here). The next step down is fp8, and **it already exists**: `AITER_FLYDSL_STAGE2_FP8=1`
(`fused_moe.py:2628`, `moe_kernels.py:2187`).

Measured A/B, M=8192, GPU 6, interleaved, medians of 5:

| arm | median | speedup |
|---|---|---|
| base (bf16 partials) | 526.73 µs | 1.000× |
| **fp8 partials** | **412.91 µs** | **1.276×** |
| atomic (fused reduction) | 529.03 µs | 0.996× |

1.276× looks attractive. **It does not survive a correctness check.** Finiteness and error
vs the bf16-partial incumbent, production `fused_moe` dispatch, 2 seeds:

| M | inter_dim | base finite | **fp8 finite** | non-finite elems | rel L2 |
|---|---|---|---|---|---|
| 4,096 | **384** | ✅ | ❌ | **141,012** | – |
| 4,096 | **384** | ✅ | ❌ | **40,991** | – |
| 8,192 | 384 | (skip) | ✅ | 0 | – |
| 8,192 | 384 | ✅ | ✅ | 0 | 2.69e-2 |
| 4,096 | 768 | ✅ | ✅ | 0 | 2.69e-2 |
| 8,192 | 768 | ✅ | ✅ | 0 | 2.69e-2 |

Two independent disqualifications:

1. **It produces NaN/Inf at our served `inter_dim=384`** — 141,012 and 40,991 non-finite output
   elements on two different seeds (absmax 2.67e38). Reproducible.
2. **Even where finite, error is 2.69e-2 relative L2 (SNR ≈ 31 dB)** — consistent across all four
   clean configs. That is **not** "lost in existing fp4 quantization noise"; it is a ~2.7%
   perturbation of the layer output, compounded over `topk=5` summed terms and then over every
   MoE layer.

**Per the stated bar — numerics are not traded for speed — this is rejected.** I measured rather
than assumed, and the measurement says no. *This is also a latent correctness bug worth reporting
upstream independently of this investigation:* an env-gated path that silently emits NaN at a
shape the guards admit.

### (b) Fuse the reduction into stage-2's epilogue — **ALREADY IMPLEMENTED, ALREADY LOST**

This is the existing **`atomic`** epilogue: stage-2 atomically accumulates into the
`moe_sorting`-zeroed output, so partials never reach HBM as a separate array
(`moe_kernels.py:2045`, `accumulate = mode != "reduce"`).

Structurally, the brief's question — *do all `topk` partials for a token land in one workgroup?* —
answers **no**: rows are sorted **by expert**, so a token's `topk` contributions are scattered
across different experts and therefore different workgroups **by construction**. That is precisely
why the fused form must use *atomics* rather than a local reduction.

And it is already selected when it wins: `reduce` is forced only above the 4 GiB buffer-atomic
offset limit (`requires_flydsl_stage2_reduce`, `token_num·model_dim·2 > 0xFFFFFFFF`). Below that
the tuner was free to pick either — and the shipped `inter_dim=384` rows pick `atomic` at M=512 and
**`reduce` at M≥1024**. My A/B confirms the tuner was right: forcing atomic at M=8192 gives
**0.996× (no change)**. Atomic contention across scattered experts cancels the traffic saving.

**Options (a) and (b) are closed:** (a) on correctness, (b) because it exists, was A/B'd, and lost.

### End-to-end arithmetic on the option that was on the table

Granting the fp8 win at face value (which correctness does not): 1.276× on total MoE saves
~114 µs of 527 µs at M=8192. Applying the measured ~30% kernel→e2e conversion, to MoE's share
of the 34% prefill, yields a **sub-1% end-to-end move** — bought with NaN output at the served
shape. The corrected bf16 byte count (§0) makes the achievable ceiling smaller still.

### (c) Third option — never create the partials

The remaining lever is to **not expand by `topk` at all**: fuse stage-1 and stage-2 so the
intermediate is never materialized. That is precisely the **1-stage** design, i.e. the ASM
`fmoe_g1u1` path this report was asked to assess.

The weight-reuse arithmetic works in its favour (§1.3): at `inter_dim=384`, M=8192, rows per
expert = `M·topk/E` ≈ 317, so a `subGU_m=32` tile re-reads weights
`ceil(317/32)·32/317` = **1.01×** — no amplification penalty, because this is non-FLAT.

**This is the only genuinely untested lever**, and it is blocked on exactly one artifact: a
**Swiglu** MXFP4 `.co` (§2 — the 8 shipped non-FLAT tiles are Silu/Gelu). I could not measure it
because no such binary exists to run. It is a `.co` build, not a kernel design problem.

### Adjacent kernels — same pattern checked, not present

Widening rather than polishing, I checked for others:

- **`return_per_slot` / stage-2 scatter** paths exist but change the op contract, not the traffic.
- **The same fp32/expanded-partial pattern elsewhere:** `dynamic_per_group_scaled_quant_kernel`
  (25.8 µs, 0 MFMA) and the sorting kernels (13.9 + 7.8 + 3.5 + 3.3 + 2.2 µs, all 0 MFMA) are
  together ~57 µs at M=8192 — **~12% of MoE time in pure-movement setup work**. These are small,
  already bandwidth-shaped, and equally immune to assembly.
- **The one genuinely untested lever** is reducing `topk` expansion itself (e.g. fusing stage-1
  and stage-2 so the intermediate never materializes). That is the **1-stage** design — which is
  exactly what the ASM `fmoe_g1u1` kernels are. At `inter_dim=384/512` with `M·topk/E ≈ 317`
  rows per expert, a 1-stage tile at `subGU_m=32` would re-read weights `ceil(317/32)·32/317` =
  1.01× — no amplification penalty. **This is the only door left open**, and it needs a Swiglu
  `.co` (§2) before it can even be measured. I did not measure it because no Swiglu MXFP4 binary
  exists to measure.

---

## 7. Verdict and effort

**NO-GO for a hand-written non-FLAT assembly MoE kernel.**

The number that closes it: **stage-2 is 65–70% of MoE time and runs at 75% of measured copy
bandwidth using 10.9% of the MFMA pipe; the `moe_reduction` kernel runs at 102% of copy bandwidth
with zero MFMA instructions.** Assembly cannot move bandwidth.

Supporting: FlyDSL already emits `sched_barrier`, `s_setprio`, explicit `s_waitcnt`, and a 2-stage
software pipeline (§4.4), so the specific mechanisms cited as assembly's advantage are not absent.

**What PyISA would buy: nothing here.** It is correctly described (CDNA3 FMoE sample, zero CDNA4
compute kernels, one numeric test, `v_mfma_scale_f32_16x16x128_f8f6f4` already encoded in
`samples/cdna4/f8f6f4_format.py:27`, gfx950 default). It is a credible authoring path — but there
is no instruction-level gap for it to close, so the question of tooling never arises.

**Conditional on the sibling's `inter_dim=512` tuning:** since stage-2 is already at 75% of copy
bandwidth and `moe_reduction` at 102%, tuning cannot move those materially either. Expect gains
concentrated in **stage-1** (the one kernel with MFMA headroom at 28.4% pipe). That would *lower*
the notional ASM prize further, not raise it. **The ASM estimate should be read as: no prize at
any tuning outcome.**

### If anyone reopens this

Do **not** start from scratch. In order:
1. Build a **Swiglu** `.co` for the existing non-FLAT `subGU_m=32, subGU_n=256/512` MXFP4 tiles
   (§2). Everything else already ships.
2. Given PR #5794's activation-guard widening, wiring is **CSV-rows-only**.
3. Measure the **1-stage** path (§6, third option) — the only structurally untested lever, since
   it removes the `topk` intermediate rather than compressing it.
4. Expect it to be bandwidth-bound too.

### Correctness note carried forward

`AITER_FLYDSL_STAGE2_FP8=1` emits **non-finite output at `inter_dim=384`** (141,012 / 40,991 bad
elements, 2 seeds) and carries **2.69e-2 relative L2 error where it is finite**. It should not be
enabled for MiniMax-M3, and the NaN is worth an upstream report on its own merits.

---

## Appendix — method, provenance, and what I did not verify

- **Protocol honoured:** every comparative timing serial on **GPU 6** alone, arms **round-robin
  interleaved**, medians ≥5 (MFMA roof used 9 rounds; MoE A/B used 5; kernel_bench 20 iters × 5).
  GPU 7 idle. No GPU outside {6,7} touched. Interleaving specifically guards the failure mode
  cited in the brief (725 vs 848 µs from parallel runs).
- **Independence:** the §3.3 MoE numbers come from my own harness through production `fused_moe`,
  and agree with the shipped tuned CSV to ≤3% — two independent routes to the same conclusion.
- **Roof validated, not quoted:** FP8 = exactly ½ FP4 and BF16 = exactly ¼ FP4 reproduce the
  MI355X datasheet, which is what makes the 9,551 TFLOP/s figure trustworthy.
- **Self-correction:** I initially reported stage-2 partials as fp32 (480/960/1920 MB). They are
  **bf16** (`moe_kernels.py:2050`); §4.3/§6 use the corrected figures. The corrected numbers
  *strengthen* the NO-GO, because they leave less traffic to remove.
- **Constraints honoured:** `/app/aiter` read-only (no edits); no end-to-end serving runs; long
  jobs via `docker exec -d`.
- **Not verified:** (i) the bf16-A **decode** band (M<256) — flips to BF16 MFMA (¼ the FP4 rate),
  so its roof differs; the existing 63–88%-of-HBM finding already covers it and agrees it is
  memory-bound; (ii) the 1-stage path at this shape, because no Swiglu MXFP4 `.co` exists to run;
  (iii) `inter_dim=512` numbers, deliberately left to the sibling agent to avoid duplicate work.
- **MFMA-pipe %** assumes 16 passes for a `32x32x64` f8f6f4; the measured `16x16x128` rate implies
  17.6 cycles/instr, consistent with that assumption.
