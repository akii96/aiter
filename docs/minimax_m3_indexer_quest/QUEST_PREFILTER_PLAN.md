# Quest-style exact prefilter for the MiniMax-M3 block-sparse indexer — **NEGATIVE RESULT**

**Verdict: DO NOT BUILD. Phase 1 gate failed by a wide margin, on real data at the real shape.**

| | |
|---|---|
| **Target** | read ~7.8% of blocks (≈12× traffic reduction), bit-identical output |
| **Measured** | **99.9% of blocks must still be read** (1023.0 of 1024) |
| **Traffic** | **0.99×** — i.e. no gain; several tuned variants are **worse than baseline** (0.76–0.94×) |
| **Data** | **real** layer-3 `index_k`/`index_q`, 131,072 tokens = 1024 blocks, LongBench `gov_report` |
| **Decision** | Stop at Phase 1. Phases 2 (design) and 3 (prototype) not pursued — the gate is unambiguous |
| **Cost** | ~3.5 h, one 52-second GPU capture. Saves an estimated 3–4 weeks of kernel work |

The idea is mathematically sound and I implemented it faithfully. It fails for a
structural reason specific to this configuration, and the reason is **not** the one I
predicted at the outset. Both my initial hypotheses were wrong, and the measurement
says so plainly; that correction is recorded in §4 and §5 rather than quietly dropped.

---

## 1. What was proposed, and what "exact" required

The lightning indexer scores every 128-token block as

```
score_b = max over the block's tokens of (q · k)          # kernels.cuh:643, fmaxf reduction
```

and keeps the top-16. At 128k that reads 1024 blocks × 16,384 B = 16.8 MB per
(query, layer) to keep 16 — 98.4% of streamed bytes discarded.

Quest (ICML 2024) stores per-block elementwise min/max of the keys and bounds

```
max_k (q · k)  ≤  Σ_d max(q_d·min_d , q_d·max_d)                              (1)
```

computable from 256 B instead of 16,384 B. Branch-and-bound on `T` = the 16th-best
exact score found so far makes the *output* exact: any block with `bound ≤ T` provably
cannot enter the top-16.

### 1.1 The key number is exact and order-independent — no simulation needed

The brief asked what visit order to use and how many blocks would be read. That
question has a closed-form answer, which is worth stating because it removes all
heuristic freedom from the result:

> Let `T*` be the **true** 16th-best block score. Then the set of blocks whose full
> keys must be read is exactly
> ```
> N* = |{ j : bound_j > T* }|
> ```
> regardless of visit order.

*Proof.* Visit in descending `bound`. Every true top-16 block `j` satisfies
`bound_j ≥ true_j ≥ T*`, so all 16 winners lie inside the prefix `{bound > T*}`. Once
that prefix is consumed, the running threshold equals `T*`; the next block has
`bound ≤ T*` and the scan terminates. No order can do better, because any block with
`bound_j > T*` cannot be excluded without reading it — its bound alone does not
certify `true_j ≤ T*`. ∎

So "expected fraction of blocks fully read" is **a property of the data**, not of the
search strategy. That is what is measured below. It also means a fixed-cap kernel
design (§7) is characterised entirely by the distribution of `N*`.

---

## 2. Method: a real capture, not synthetic data

The brief allowed well-justified synthetic data. That was not necessary — **real
layer-3 index vectors are obtainable without serving and without the full model.**

**The enabling observation:** the indexer is disabled on layers 0–2
(`moe_layer_freq` and `sparse_disable_index_value` both begin `[0,0,0,1,1,...]`), so
**layer 3 is the first sparse layer**, and the input to its index branch is exactly

```
embed_tokens → L0 → L1 → L2          (all three are plain BF16 dense — no MXFP4 experts)
```

≈3 GB of weights. Everything downstream (the 128 MXFP4 experts per layer) is
irrelevant to the index branch. **128k tokens captured in 52 s on one MI355X.**

Ops replicated exactly against the running container's source:

| Component | Source of truth |
|---|---|
| Gemma RMSNorm `x·rsqrt(mean(x²)+ε)·(1+w)`, fp32 accum | `amd/ops/gemma_rmsnorm.py` |
| Residual-carrying pre-norm; `post_attention_layernorm` fused add+norm, residual_out = **pre**-norm sum | `amd/model.py:1332-1354` |
| Per-head q/k Gemma norm, partial NeoX RoPE (`rotary_dim=64` of 128), GQA 64q/4kv, causal | `amd/model.py`, `_build_rotary_emb` |
| SwiGLU-OAI `min(gate,7)·σ(1.702·gate)·(clamp(up,±7)+1)` | `amd/ops/swiglu_oai.py` |
| index_q (4 heads) / index_k (1 head) Gemma norm **then RoPE** | `fused_qknorm_idxrqknorm.cu` — `do_rope` init `true`, only `is_v` clears it |
| index_k stored e4m3 **unit scale** | `storeCacheElems(..., 1.0f)` |
| Sentinels: own last block `1e29f`, init `1e30f` | `kernels.cuh:544-548` |
| Tie-break: block index in **low** 32 bits ⇒ larger index wins ties | `kernels.cuh:706-711` |

**Capture sanity (V1), all healthy:**
`|k|max = 7.50` (e4m3 saturates at 448 — not clipping) · 159 of 256 fp8 codes used ·
zero all-zero rows · per-dim std 1.451 (rotated) / 0.550 (unrotated).

---

## 3. THE RESULT

Real data, 1024 blocks, three bound families, sub-box sweep. `σ` = std of `q·k` over
tokens (the natural scale; see §6 for why ratios are the wrong metric).

**The budget:** a bound can only prune if its slack fits inside the gap between the
cutoff and the bulk of blocks:

```
T* − median(true)  =  2.38 σ          ← the entire budget available
```

**The achieved slack:**

| tokens/box | summary B/blk | slack (σ) | vs budget | N* / 1024 | % read | traffic |
|---:|---:|---:|---|---:|---:|---:|
| **128 (Quest as specified)** | **256** | **7.89** | **3.3× over** | **1023.0** | **99.9%** | **0.99×** |
| 64 | 512 | 7.09 | 3.0× over | 1023.0 | 99.9% | 0.97× |
| 32 | 1024 | 6.22 | 2.6× over | 1023.0 | 99.9% | 0.94× |
| 16 *(Quest's own page size)* | 2048 | 5.26 | 2.2× over | 1022.4 | 99.8% | **0.89×** |
| 8 | 4096 | 4.21 | 1.8× over | 1003.3 | 98.0% | **0.81×** |
| 4 | 8192 *(half the raw block!)* | 3.04 | 1.3× over | 781.8 | 76.4% | **0.80×** |

Every refinement that narrows the slack costs more summary bytes than it saves. The
traffic column **never exceeds 1.00×** and mostly falls. At 8k/64 blocks and
64k/512 blocks the picture is identical (98.4% and 99.8% read, 1.00× and 0.99×).

**This is not a near miss.** To reach even a 2× traffic win the slack would have to be
≤ 0.5σ — **16× tighter than measured**, and tighter than the 4-tokens-per-box point
where the "summary" is already half the size of the data it summarises.

### 3.1 The oracle ceiling — this bounds the *entire* approach

Independent of any particular bound, here is what *any* summary-based prefilter could
achieve on this data as a function of its slack:

| slack | blocks read | traffic |
|---:|---:|---:|
| **0 (unreachable oracle)** | 14.0 / 1024 (1.37%) | — |
| 0.25 σ | 26.9 (2.6%) | 23.9× |
| 0.50 σ | 47.8 (4.7%) | 16.1× |
| 1.00 σ | 121.5 (11.9%) | 7.5× |
| 2.00 σ | 384.3 (37.5%) | 2.6× |
| 3.00 σ | 774.9 (75.7%) | 1.3× |
| 5.00 σ | 1023.0 (99.9%) | 0.99× |
| **7.89 σ ← measured** | **1023.0 (99.9%)** | **0.99×** |

The headroom is genuinely enormous (a perfect oracle reads 1.4%), which is exactly why
this was worth testing. The measured bound lands in the flat dead zone past 5σ.

---

## 4. WHY it fails — and the correction to my own hypothesis

### 4.1 The cause: the slack grows like **D**, the signal like **√D**

The bound's slack term is `Σ_d |q_d|·halfwidth_d` — an **L1 sum over 128 dimensions**,
accumulating ~D positive terms. The true score `max_k q·k` is an inner product that
concentrates like **√D**. The ratio therefore grows like `D/√D = √D`, and no amount of
tightening the per-dimension boxes changes that exponent.

Measured directly by truncating the head dimension (V2):

| D | true max (σ) | slack (σ) | slack/√D | slack/D |
|---:|---:|---:|---:|---:|
| 8 | 3.48 | 1.68 | 0.593 | 0.2095 |
| 16 | 4.12 | 2.29 | 0.572 | 0.1429 |
| 32 | 3.78 | 3.60 | 0.637 | 0.1125 |
| 64 | 4.67 | 4.74 | 0.592 | 0.0740 |
| **128** | 4.37 | **7.89** | 0.698 | 0.0617 |

`slack/√D` is **flat at ≈0.6** across a 16× range of D — the √D law holds cleanly,
while the signal stays at ~4σ. This is structural, not a tuning artefact.

### 4.2 The correction: **post-RoPE storage is NOT the cause** — I was wrong

My initial hypothesis (and the one I flagged to the parent early) was that storing
`index_k` post-RoPE is fatal, because `inv_freq[0] = 1.0 rad/token` sweeps ~20
revolutions inside a 128-token block, degenerating that coordinate's min/max box to
`[-A, +A]`. **I tested this and it is largely wrong.** With `rope_theta = 5×10⁶`:

| pair *i* | dims | rad / 128-token block | revolutions | box degenerate? |
|---:|---|---:|---:|---|
| 0 | 0,32 | 128.0 | 20.4 | **yes** |
| 3 | 3,35 | 30.1 | 4.8 | **yes** |
| 6 | 6,38 | 7.1 | 1.13 | **yes** |
| 7 | 7,39 | 4.4 | 0.70 | no |
| 11 | 11,43 | 0.64 | 0.10 | no |
| 31 | 31,63 | ~0 | ~0 | no |

**Only 7 of 32 pairs (14 of 128 dims, 10.9%) wrap a full revolution.** θ=5×10⁶ is so
large that 17 of 32 pairs are essentially *static* over 128 tokens (median pair sweeps
1.2% of a revolution). Measured effect: post-RoPE box halfwidth on the rotated half is
**1.62×** the pre-RoPE value (dims 64–127, untouched by RoPE, are the control) —
real, but a ~20% worsening of total slack, not the mechanism.

**The controlled experiment settles it.** Identical pipeline, pre-RoPE vectors:

| variant | slack (σ) | budget (σ) | % read | traffic |
|---|---:|---:|---:|---:|
| post-RoPE (as shipped), 128 tok/box | 7.89 | 2.37 | 99.9% | 0.99× |
| post-RoPE, 16 tok/box | 5.27 | 2.37 | 99.9% | 0.89× |
| **pre-RoPE (hypothetical fix), 128 tok/box** | **24.29** | **0.76** | **99.9%** | **0.99×** |
| pre-RoPE, 16 tok/box | 17.98 | 0.76 | 99.9% | 0.89× |

**Pre-RoPE is dramatically *worse*** — slack 24.3σ against a budget of only 0.76σ.
RoPE *decorrelates* the key distribution and actually *helps* both the bound and the
score spread. So "store index_k pre-RoPE" is not a fix; it would make things worse.
**The √D argument is the whole story**, and it would sink the prefilter on a RoPE-free
cache too.

### 4.3 The crowding hypothesis was also wrong — and that matters

I flagged a second risk: that `max` over 128 tokens concentrates, crowding the true
scores so nothing can be pruned. **The data refutes this too.** At 1024 blocks the true
scores are well spread (`true/T*`: p50 = 0.098, p90 = 0.666, p99 = 1.054), and the
zero-slack oracle reads only 1.37% of blocks. **The selection is highly selective and
the headroom is real** — the failure is entirely on the bound side, not the data side.

The task is also confirmed genuinely query-dependent: the top-16 sets of *adjacent*
query rows overlap only **54%**, which independently re-confirms why caching selections
across steps cannot work (consistent with the prior `index_topk_freq` retrieval
failures) — while the min/max summaries, being query-independent, were the right thing
to try.

---

## 5. Salvageable contribution: a RoPE-aware bound (derived, correct, still insufficient)

Even though it does not rescue the prefilter, the derivation is sound, gives a
**smaller** summary than Quest, and is reusable for any future rotary-cache bound.

**Derivation.** Under NeoX RoPE the pair `(i, i+32)` at position *p* rotates by
`φ = inv_freq_i · p`. The contribution of that pair to `q·k` is

```
q_i(k_i cos φ − k_j sin φ) + q_j(k_j cos φ + k_i sin φ)
  = cos φ·(q_i k_i + q_j k_j) + sin φ·(q_j k_i − q_i k_j)
```

which is the inner product of the fixed vector `(q_i, q_j)` with a **rotated copy** of
`(k_i, k_j)`. By Cauchy–Schwarz, for **any** phase whatsoever,

```
|contribution|  ≤  √(q_i² + q_j²) · √(k_i² + k_j²)                             (2)
```

and `√(k_i² + k_j²)` is **rotation-invariant** — numerically identical pre- and
post-RoPE. So one amplitude per pair per block, `A_i = max over the block's tokens of
√(k_i²+k_j²)`, is computable once at insert time and valid at every position, for
every future query. Combining with an ordinary box on the 64 non-rotating dims:

```
bound = Σ_{i<32} √(q_i²+q_j²)·A_i  +  Σ_{d≥64} max(q_d·min_d, q_d·max_d)      (3)
```

**Summary cost: 32 amplitudes + 2×64 box = 160 B/block, vs Quest's 256 B** — 1.6×
cheaper *and* immune to the phase problem.

**Measured: it does not help here** (slack 11.55σ vs box's 7.89σ). Cauchy–Schwarz
discards the sign/alignment information the box retains, and that loss outweighs the
phase robustness at θ=5×10⁶ where only 7 pairs actually wrap. `min(box, polar)` — valid
since both are upper bounds — tracks the box exactly. **The derivation is correct; the
regime does not reward it.** It would pay at small θ or large block_size, where a much
larger fraction of pairs wrap.

---

## 6. Methodological note: `bound/true` is the wrong metric (a trap worth recording)

My first analysis reported `bound/true` percentiles. **That metric is meaningless
here** because `q·k` straddles zero: the ratio explodes near `true ≈ 0` and goes
**negative** for `true < 0`. It produced absurdities like "ratio p10 = −36" and
"min = −154744". Any conclusion drawn from it would have been noise.

The correct formulation is **absolute, in units of σ**:

```
block j is pruned  ⟺  slack_j  ≤  T* − true_j
```

so the decision compares an **absolute slack** against an **absolute budget**
(`T* − median = 2.38σ`). Every number in §3–§4 uses this form. Anyone repeating this
analysis on a signed score should do the same.

---

## 7. What the kernel design would have been (not built, recorded for completeness)

The Phase 2 design question — *data-dependent candidate counts vs HIP graph capture* —
has a clean answer that is worth keeping, since it applies to any future prefilter:

**Fixed-cap two-pass with an exact self-check.** Because `N* = |{bound > T*}|`, take
the top-`C` blocks by bound with `C` a **compile-time constant**, read exactly those
`C` blocks' keys, then test `bound_(C+1) ≤ T_C` (the 16th-best among the C read).
- If the test passes, the result is **provably bit-identical** — no approximation.
- If it fails, fall back to the existing full-scan kernel for that row.

This gives **fixed launch geometry**, no data-dependent grid, and graph-capture safety;
the only variable is a rare fallback whose rate is `P(N* > C)`. The design is sound —
but with `N*` = 1023 at p50, `C` would have to be ~1024 and the fallback rate ~100%.

Preserving the rest of the contract was also established as feasible:
`pa_sparse_block_topk` already fuses `sparse_bt`/`sparse_ctx` emission
(`msa_block_select.py:574-579`), and both that and the low-32-bit tie-break
(`kernels.cuh:706-711`) would be untouched by a prefilter that only *narrows the
candidate set* before the existing scoring path. Summary maintenance folds into the
existing fused QK-norm/index-insert kernel (`fused_qknorm_idxrqknorm.cu`), which
already has the post-norm `index_k` in registers at the moment of the cache store —
one warp-level min/max/amplitude reduction, no extra launch, +1.56% VRAM.

None of this was implemented, because Phase 1 is the gate and it failed.

---

## 8. What would have to be true for this to work

| Condition | Our value | Needed | Available to us? |
|---|---|---|---|
| `block_size` | 128 | ≈16 | **No** — model/cache-layout change; ×8 page table |
| `index_head_dim` | 128 | ≲16–32 | **No** — architectural; slack ∝ √D |
| `score_type` | `'max'` | `'sum'` | **No** — config-fixed; `sum` bounds far better |
| bound slack | 7.89 σ | ≤ 0.5 σ for 2× | **No** — 16× beyond any variant measured |

The dimension/box sweep shows precisely where the method *would* have paid:

| head_dim | tokens/box | % read | traffic |
|---:|---:|---:|---:|
| 16 | 16 | 24.7% | **4.29× ← would work** |
| 16 | 128 | 73.4% | 1.44× |
| 32 | 16 | 66.2% | 1.53× |
| 64 | 16 | 77.1% | 1.24× |
| **128** | **128 ← our config** | **99.9%** | **0.99×** |

Quest's published configuration sits near the top-left of that table. **Ours sits in
the corner where the method is worthless.** That is the honest summary: the technique
is fine, the configuration defeats it.

---

## 9. Recommendation

**Close this path.** Do not proceed to Phases 2–3.

The indexer remains the largest single lever at long context (~45% of the trace at
128k, 61.2 GB and 9.67 ms per decode step), and the oracle ceiling here — 1.37% of
blocks — shows the *opportunity* is real and very large. But summary-based exact
pruning of the `max`-over-128-tokens score in 128 dimensions cannot reach it, and the
measurement is not close enough to justify further engineering.

**Honest e2e arithmetic, had it worked** (per the calibration guidance): a 12× traffic
cut on a kernel at 45% of the 128k trace ⇒ ~41% of GPU time removed; at the measured
~30% conversion and with prefill dilution (the session's measured 1.147× TPOT → 1.086×
e2e at 128k), that is roughly **1.10–1.15× e2e at 128k and ~nothing at 8k**. Worth
3–4 weeks had Phase 1 passed — which is exactly why Phase 1 existed.

**Where the remaining indexer headroom actually is:** the oracle says 98.6% of the
bytes are provably unnecessary. Reaching them requires either (a) a *smaller index
head_dim* or *smaller block_size* — model-side changes, not kernel changes — or
(b) abandoning exactness, which the session has already shown causes nondeterministic
retrieval failures via `index_topk_freq`. Neither is a kernel lead.

---

## 10. Artifacts

| File | Purpose |
|---|---|
| `qp_capture.py` | Real layer-3 `index_k`/`index_q` capture (CPU or GPU); 128k in 52 s |
| `qp_analyze.py` / `qp_analyze2.py` | Bound tightness + `N*`, box/ball, sub-boxes |
| `qp_analyze3.py` | Adds the RoPE-aware `polar` bound (§5) |
| `qp_crowd.py` | Crowding diagnostic: pruned fraction = CDF of true scores at `T*/r` |
| `qp_abs.py` | **Definitive** absolute-σ slack-vs-budget table (§3) |
| `qp_validate.py` | 4-way audit: capture realism, √D law, selectivity, oracle ceiling |
| `qp_rope.py` | RoPE wrap analysis that falsified my own hypothesis (§4.2) |
| `qp_final.py` | Controlled pre/post-RoPE + head_dim×block_size sweep (§4.2, §8) |
| `qp_data/*.json` | Raw measurement outputs |

**Reproduce the decisive number:**
```bash
python qp_capture.py --tokens 131072 --source longbench --device cuda --out idx.npz
python qp_abs.py --npz idx.npz --ctx 131072 --sub 1 2 4 8 16 32
```

**Environment hygiene:** `/app/aiter` and the vLLM dist-packages were **read only** —
no file under either was modified. All work ran from `/tmp` inside the container. Total
GPU usage: one 52-second capture on device 0; GPUs confirmed free afterwards
(`rocm-smi --showuse` 0% on all 8, `--showpids` showing only the ROCm daemon).

---

## 11. Summary for the record

Five things were established, four of which survive the negative verdict:

1. **`N*` is exact and order-independent** — `N* = |{bound > T*}|`. Pruning quality is
   a property of the data; no visit-order cleverness can improve it.
2. **The prefilter reads 99.9% of blocks at the real shape.** Target was 7.8%.
   Traffic 0.99×, and *negative* for every refinement. Unambiguous.
3. **The cause is `slack ∝ D` vs `signal ∝ √D`** — verified flat `slack/√D ≈ 0.6`
   across D = 8…128. Structural, not tunable.
4. **Two plausible hypotheses were tested and falsified** — post-RoPE degeneracy
   (only 7 of 32 pairs wrap; pre-RoPE is *4× worse*) and score crowding (scores are
   well spread; the oracle reads 1.37%). Recorded because they are the obvious next
   guesses and someone would otherwise re-run them.
5. **A correct, cheaper RoPE-aware bound was derived** (160 B/block vs 256 B, with a
   rotation-invariance argument) — insufficient here, reusable elsewhere.

A well-evidenced negative result at 3.5 hours, against 3–4 weeks of kernel work that
would have produced a 0.99× traffic "win".
