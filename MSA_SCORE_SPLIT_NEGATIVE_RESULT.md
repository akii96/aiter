# `_score_split` occupancy cap — measured negative result

**Verdict: do not change `_score_split`. The existing policy is correct.**

This documents an attempt to fix what looked like a severe grid-sizing defect in
`aiter/ops/msa_block_select.py:_score_split`, the measurements that refuted it,
and the controlled experiment that explains why. Recorded so the analysis is not
repeated.

- Hardware: MI355X, `gfx950`, 256 CUs, single GPU, machine otherwise idle.
- aiter: `8253efc4` (the deployed build). **The installed aiter was never
  modified** — candidate policies were injected by rebinding
  `mbs._score_split` from the benchmark; the module md5 was verified pristine
  before and after every run.
- Kernel under test: `pa_sparse_block_score_decode<128,128,1,4,1,8,false>`.
- Shapes: MiniMax-M3 decode contract (block 128, head dim 128, top-k 16,
  1 index head at TP=8, `init_blocks=0`, `local_blocks=1`).
- The launch bound `max_seq_len` is pinned at `max_model_len = 133120`
  throughout, because that is what cudagraph capture forces
  (`vllm/v1/worker/gpu_model_runner.py:2313`). The *live* context varies. That
  divergence is the whole subject.

---

## 1. The hypothesis

`_score_split` sizes the block axis from `max_blk`, derived from the
capture-time bound, while the kernel derives its own span from the live
`seq_lens`:

```
per_chunk = cdiv(nblk_max, num_chunks)        # kernels.cuh:507
c0        = blockIdx.z * per_chunk            # :508
if (c0 >= nblk_max) return;                   # :509  <-- early exit
b0        = c0 + wave;                        # :513
for (blk = b0; blk < b1; blk += kWaves)       # :595  <-- waves stride
```

At `max_model_len=133120` serving 8k over 64 requests, `_score_split` yields
`num_chunks = 256`, so the grid is `64 x 256 = 16384` workgroups while the live
rows hold only 64 blocks. Then `per_chunk = 1`, so:

- only 64 of 256 chunks clear the guard at `:509` — **12288 of 16384
  workgroups (75%) exit having done nothing**, and
- `per_chunk = 1 < kWaves = 4`, so within a live workgroup **only wave 0 has a
  block to score**.

Dispatched wave-slot utilization is therefore `4096 / (16384 x 4) = 6.25%`.
The predicted win from fixing this was **2-4x**.

---

## 2. The measurement: 1.00-1.02x geomean

Score kernel only, 200 iterations, candidate = cap `num_chunks` at
`per_cu x 256 / num_reqs`.

| live ctx | reqs | legacy µs | per_cu=2 | 4 | 8 | 16 |
|---|---|---|---|---|---|---|
| 8192 | 4 | 11.36 | 1.02x | 1.00x | 1.00x | 0.98x |
| 8192 | 16 | 11.11 | 0.97x | 0.97x | 0.97x | 0.97x |
| **8192** | **64** | **15.54** | **1.28x** | **1.29x** | **1.26x** | **1.30x** |
| 8192 | 128 | 22.31 | 1.05x | 1.03x | 1.03x | 1.06x |
| 60000 | 4 | 11.03 | 1.00x | 0.99x | 0.98x | 0.98x |
| 60000 | 16 | 20.53 | 1.06x | 0.98x | 0.91x | 1.00x |
| 60000 | 64 | 70.65 | 0.97x | 0.98x | 1.00x | 1.01x |
| 60000 | 128 | 158.38 | 0.98x | 0.97x | 0.97x | 0.97x |
| 131072 | 4 | 11.69 | 0.97x | 1.00x | 1.00x | 1.00x |
| 131072 | 16 | 40.52 | 1.02x | 1.02x | 1.04x | 1.00x |
| 131072 | 64 | 169.64 | 0.96x | 0.95x | 0.95x | 0.97x |
| 131072 | 128 | 341.12 | 0.96x | 0.96x | 0.96x | 0.97x |

**Geomean 1.00-1.02x. Best 1.30x at exactly one shape. Worst 0.91x.**

Correctness was never at risk and was confirmed: `topk_idx`, `sparse_bt` and
`sparse_ctx` are bit-identical across every policy and shape. The split is pure
launch geometry.

Harness validation: legacy at 8192/64 measures **15.54 µs** standalone against
**17.83 µs** in the production kineto trace — the same kernel at the same shape,
so the harness is representative.

---

## 3. The controlled experiment: what actually costs

Sweeping `num_chunks` directly at fixed (context, batch) separates the two
conflated effects. At **ctx=8192, reqs=64** (`nblk = 64`):

| chunks | WGs | per_chunk | live WG% | live waves | µs |
|---|---|---|---|---|---|
| 1 | 64 | 64 | 100% | 4 | 30.46 |
| 2 | 128 | 32 | 100% | 4 | 16.96 |
| 4 | 256 | 16 | 100% | 4 | **12.15** |
| 8 | 512 | 8 | 100% | 4 | 12.21 |
| 16 | 1024 | 4 | 100% | 4 | 12.16 |
| 32 | 2048 | 2 | 100% | 2 | 12.34 |
| **64** | **4096** | **1** | **100%** | **1** | **12.09** |
| 128 | 8192 | 1 | 50% | 1 | 12.12 |
| **256** | **16384** | **1** | **25%** | **1** | **15.42** |

Two conclusions, both clean:

**(a) The "1 block per workgroup / 1 live wave" effect costs nothing.**
`chunks=64` has `per_chunk=1` and only **1 of 4 waves live** — precisely the
condition the hypothesis blamed — and it is the **fastest row in the table**
(12.09 µs). A `per_chunk` floor, the principled fix that would have followed
from this hypothesis, is therefore not warranted: the condition it would
prevent is not harmful.

**(b) Dead workgroups cost something, but only ~69 ns of CU time each.**
`chunks=64` and `chunks=256` are a controlled pair: both have `per_chunk=1`,
both have exactly **4096 live workgroups** doing identical work. The only
difference is 0 dead workgroups versus 12288. The cost is
`15.42 - 12.09 = 3.33 µs`, i.e. `3.33 µs / (12288/256 per CU) ≈ 69 ns` per dead
workgroup per CU — roughly 1/50th of what a live workgroup costs.

So the original arithmetic was right (75% of the grid really does exit
immediately) and the inference from it was wrong. **A dispatched-and-exiting
workgroup is nearly free; utilization percentages are not latency.**

---

## 4. Why no capture-time rule can fix it

The dead-workgroup fraction is what costs, and it depends on the **live**
context. But the split must be fixed at cudagraph capture, when only the bound
is known. At `chunks=256` the dead fraction is:

| live ctx | nblk | per_chunk | dead WG% | legacy is |
|---|---|---|---|---|
| 8192 | 64 | 1 | **75%** | 1.28x off best |
| 60000 | 469 | 2 | 8% | ~optimal |
| 131072 | 1024 | 4 | 0% | **optimal** |

And the crossover, at batch 64, legacy versus a capped policy:

| live ctx | legacy µs | capped µs | speedup |
|---|---|---|---|
| 2048 | 11.31 | 11.13 | 1.02x |
| 4096 | 11.09 | 11.17 | 0.99x |
| **8192** | 15.51 | 12.54 | **1.24x** |
| 16384 | 22.60 | 21.09 | 1.07x |
| 32768 | 38.98 | 40.29 | 0.97x |
| 65536 | 86.78 | 89.44 | 0.97x |
| 131072 | 169.53 | 178.76 | 0.95x |

Large chunk counts are *wrong* at short live context and *right* at long. At
131072 the legacy `chunks=256` is the best setting measured (169.58 µs; every
smaller count is 2-5% slower). There is no single capture-time constant that is
>= legacy everywhere, because the quantity that decides it is unknown at
capture. A shape allowlist would be a heuristic guarding a heuristic, for
1.28x at one point and regressions either side of it.

---

## 5. The kernel is already near its bound

Time scales linearly with blocks streamed, across a 16x range:

| shape | blocks | µs | ns/block |
|---|---|---|---|
| 8k x 64 | 4 096 | 15.5 | 3.8 |
| 60k x 64 | 30 016 | 70.7 | 2.4 |
| 128k x 64 | 65 536 | 169.6 | 2.6 |

At 128k x 64 that is `65536 x 16 KiB = 1.07 GB` in 169.6 µs = **6.3 TB/s**,
about **79% of MI355X peak HBM bandwidth**. The score pass is a bandwidth-bound
stream already running close to the roof. The fp32 score buffer it writes is
0.5 MB per layer against 67 MB of KV read — **0.8% of its traffic** — so
eliminating that buffer cannot return more than ~1% of this kernel either.

---

## 6. Outcome

- `_score_split` is **unchanged**. Its docstring's claim to track "the measured
  optimum across the batch and context range" is **supported** by this sweep;
  the earlier static analysis that doubted it did not account for how cheap an
  exiting workgroup is.
- The one genuine inefficiency (8k live context at batch >= 64, where 75% of the
  grid is dead) is worth 1.28x on a 15.5 µs kernel ≈ 3.4 µs/layer. Across 57
  sparse layers that is ~195 µs/step, roughly 1.6% of GPU time and well under 1%
  end-to-end after the usual kernel-to-throughput conversion — while costing
  3-5% at the long-context shapes that must not regress.
- Reproduce with `bench_score_split.py` (policy sweep) and `diag_split.py`
  (chunk sweep + crossover), both in this branch.
