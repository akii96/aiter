# QuickReduce small-payload investigation: findings

**Environment:** `amd/MiniMax-M3-MXFP4`, 8x MI355X gfx950 (256 CU), TP=8, vLLM 0.30.1rc1,
aiter main @ 8253efc4, ROCm 7.2.3. Fully-connected 1-hop xGMI.

**Question:** `quickreduce::allreduce_prototype_twoshot<AllReduceTwoshot<__half, CodecQ4<__half,8>, true>, __half>`
is 11.54% of the rank-0 trace and 33.6% of prefill wall time. Is it inefficient, or near the fabric limit?

**Answer:** near the limit. It is fabric-bound, INT4 is the right codec, two-shot is the
right algorithm, and there is no cheaper configuration reachable by flags. **This path is closed.**

The three results below are worth more than that negative.

---

## 1. The one-shot falsification

**I built a one-shot all-reduce, measured it 1.54x FASTER at TP=2, and it LOSES at 0.87x at TP=8.**

Two-shot uses two handshake rounds. At small payloads the collective is ~92% fixed cost
(§6), so collapsing to one handshake looks obviously right. I wrote a minimal one-shot IPC
all-reduce (fan out the full payload, one handshake, reduce locally) to test it.

### The wire math predicts the reversal

Per rank, per link, for payload `N` and world size `P`:

| algorithm | per-link bytes | derivation |
|---|---|---|
| **one-shot** | `N` | each rank pushes its full `N` to each of `P-1` peers |
| **two-shot** | `2N/P` | reduce-scatter `N/P`, then all-gather `N/P` |

**Ratio one-shot : two-shot = `P/2`.**

At `P=2` that ratio is **1.0 — the two algorithms move identical bytes per link.** At `P=8`
one-shot pushes **4x** as much. So a TP=2 comparison measures only the handshake difference,
with the bandwidth difference *exactly cancelled*. It cannot see the term that dominates at
production scale.

### Measured (my one-shot vs FlyDSL QRInt4, serial + interleaved, trimmed median)

Ratio = QRInt4 time / one-shot time. **Above 1.0 means one-shot wins.**

| payload | TP=2 | TP=4 | **TP=8** |
|---|---|---|---|
| 0.047 MB | **2.14x** | 1.78x | 1.34x |
| 0.094 MB | **1.87x** | 1.52x | 1.16x |
| 0.188 MB | **1.54x** | 1.20x | **0.87x — loses** |
| 0.375 MB | 1.13x | 0.76x | 0.59x |
| **0.750 MB (M3 decode)** | — | 0.43x | **0.30x — 3.3x slower** |
| 1.500 MB | — | 0.30x | 0.18x |
| 3.000 MB | — | 0.23x | 0.14x |

Spreads ≤0.85% at TP=8 for both arms. Correctness: **2000 iterations at each of TP=2/4/8,
sizes cycled back-to-back, 0 failures, worst relative error 3.9e-3** (bf16 rounding only).

### Why this matters beyond this kernel

> **Had I extrapolated from TP=2 as originally scoped, I would have reported a 1.5-2x
> small-payload win that does not exist at the production topology.**

This is a property of the *comparison*, not of this implementation. Any one-shot-vs-two-shot,
ring-vs-direct, or broadcast-vs-scatter collective comparison has a per-link byte ratio that
is a function of `P`. **Measuring such a comparison at TP=2 and extrapolating is not
conservative — it is systematically biased toward whichever algorithm replicates more data**,
because TP=2 is precisely the point where replication is free.

If you cannot get the target `P`, at minimum measure two values of `P` and check the trend
against the wire math before extrapolating. The TP=2→4→8 trend above is monotone and tracks
`P/2`; a single point would have looked like a clean win.

**The one-shot kernel in `bench/oneshot_kernel.py` is a measurement instrument, not a
proposal.** It is bf16-exact rather than INT4, so it isolates algorithm shape from codec.

---

## 2. The sub-2 MB floor is correct — the hypothesis was backwards

MiniMax-M3 decode at concurrency 64 is `64 x 6144 x 2 B` = **0.75 MB**, below vLLM's
`_QR_MIN_SIZE` floor of 2 MB. Decode therefore falls through to the uncompressed
`aiter::cross_device_reduce_2stage` — **123,602 invocations, 6.99% of the trace.**

The natural hypothesis, which I was explicitly asked to test: *at 0.75 MB the codec cost is
trivial and handshake latency dominates, so if INT4 wins below 2 MB, the floor itself is the bug.*

**Measured at real TP=8. It is backwards.**

| arm @ 0.75 MB, TP=8 | time | vs today | spread | SQNR |
|---|---|---|---|---|
| `aiter_ar` — **what decode uses today** | 13.29 us | 1.00x | 14.5% ⚠ | 55.6 dB |
| `fly_st1` (FlyDSL QRInt4) | 12.89 us | 0.97x | 4.2% ⚠ | 19.2 dB |
| `fly_st8` | 13.02 us | 0.98x | 0.1% | 19.2 dB |
| `hip_fp` (QuickReduce, no compression) | 18.93 us | 1.42x | 0.2% | 55.2 dB |
| `hip_int8` | 31.64 us | 2.38x | 0.1% | 42.2 dB |
| `hip_int6` | 33.43 us | 2.52x | 0.1% | 30.4 dB |
| **`hip_int4` — what lowering the gate would select** | **33.90 us** | **2.55x SLOWER** | 7.8% ⚠ | 18.3 dB |
| `hip_int4_nocast` | 47.11 us | 3.54x | 0.0% | 18.3 dB |
| `rccl` | 42.09 us | 3.17x | 0.3% | 48.7 dB |

**Lowering `_QR_MIN_SIZE` to reach decode would be a 2.55x regression and cost 37 dB of
SQNR.** No HIP QuickReduce regime beats the incumbent at 0.75 MB — not even the uncompressed
one. **The floor is protecting decode, not obstructing it.**

The FlyDSL arms are within 3% of the incumbent, and the incumbent arm would not settle below
14.5% spread at that size, so **I do not claim that as a win** (see §7).

At 0.75 MB every path is pinned at a ~12-13 us latency floor regardless of algorithm or
compression. **There is nothing on the table at the decode payload.**

### The bounded exception, stated precisely so it is not misread

FlyDSL QRInt4 *does* beat the incumbent in a window **above** the current gate:

| payload | `aiter_ar` | `fly_st1` | speedup | spread |
|---|---|---|---|---|
| 1.500 MB | 15.06 us | 13.93 us | 1.08x | ≤0.9% |
| 2.004 MB | 18.14 us | 14.66 us | **1.24x** | ≤0.3% |
| 3.000 MB | 21.69 us | 16.04 us | **1.35x** | ≤0.2% |
| 6.000 MB | 36.00 us | 22.27 us | **1.62x** | ≤0.3% |

**My ranking: low priority.** MiniMax-M3 at concurrency 64 never reaches this window —
0.75 MB is 2.7x below it. It becomes interesting only at higher concurrency (171 tok = 2 MB,
512 tok = 6 MB).

**The actionable condition is "lower the gate to ~1.5 MB AND route to FlyDSL", not "lower the
gate".** Lowering the gate alone selects `hip_int4`, which is the 2.55x regression above.
Those are two different changes and only the pair is safe.

---

## 3. BUG: `CAST_BF16_TO_FP16=0` silently disables QuickReduce for bf16 models

`VLLM_ROCM_QUICK_REDUCE_CAST_BF16_TO_FP16` defaults to True and is documented as a
performance option — "BF16 inputs will be converted to FP16 to improve performance".

**It does two independent things, and the second is undocumented and load-bearing.**

### (a) Performance: worth 1.09-1.9x

| payload, TP=2 | cast on | cast off | ratio |
|---|---|---|---|
| 0.75 MB | 22.43 us | 42.55 us | **1.90x** |
| 4 MB | 37.18 us | 48.66 us | 1.31x |
| 24 MB | 146.69 us | 159.24 us | 1.09x |
| 96 MB | 564.60 us | 624.14 us | 1.11x |
| 384 MB | 2245.83 us | 2488.13 us ⚠ 9.2% spread | 1.11x |

SQNR is identical either way (18.32 dB) — the cast is not an accuracy trade.

### (b) It is what lets QuickReduce run at all

From `vllm/distributed/device_communicators/quick_all_reduce.py`:

```python
_QR_MIN_SIZE = {
    (torch.float16, 8): [16*MB,    4*MB,    4*MB,    2*MB,    2*MB],
    (torch.bfloat16, 8): [16*MB, 2048*MB, 2048*MB, 2048*MB, 2048*MB],
}                        #  FP     INT8     INT6     INT4     INT3
```

`should_quick_allreduce` picks the dtype key **after** applying the cast:

```python
dtype = inp.dtype
if self.use_fp16_kernels:
    dtype = torch.float16
min_size = self._QR_MIN_SIZE[(dtype, self.world_size)][self.qr_quant_level.value]
```

With the cast **on**, the key is `(fp16, 8)` and INT4's floor is **2 MB**.
With the cast **off**, the key is `(bf16, 8)` and INT4's floor is **2048 MB** —
above `qr_max_size()` itself (2048 MB) and above every payload in this workload.
M3's largest all-reduce is 384 MB.

**Setting this flag to 0 on a bf16 model does not slow QuickReduce down by ~10%. It disables
QuickReduce completely and silently**, sending all 2057 prefill collectives to a fallback,
with no warning logged. The user sees a large regression and nothing pointing at the cause.

**This is file-able on its own** and is the most actionable thing in this investigation.
Suggested minimum fix: log a warning when the bf16 min-size table makes QR unreachable, or
decouple "which kernel to run" from "which min-size row to consult".

---

## 4. Two sync bugs I hit: why `_RESIDENT_WGS_PER_CU` is a liveness requirement

Both of these are bugs **I wrote** while building `bench/oneshot_kernel.py`. **Both passed a
10-iteration test.** They are recorded because they are the concrete case for a bar we
otherwise assert abstractly.

### (a) Over-subscribed grid on a spinning kernel → deadlock

My first version launched one workgroup per tile with no residency cap. Each workgroup
publishes a flag to its peers and then spins waiting for the peers' flags.

**If more workgroups are launched than can be simultaneously resident, the non-resident ones
have not started, so they never publish their flags. The resident ones spin forever waiting
for them. The scheduler cannot preempt the spinners to make room.** Deadlock.

This wedged two GPUs for ~30 minutes until I killed it.

This is exactly what `clamp_grid_cap` and `_RESIDENT_WGS_PER_CU` in
`aiter/ops/flydsl/kernels/quick_allreduce_int4.py` exist to prevent:

```python
_RESIDENT_WGS_PER_CU = {
    (2, 1): 3, (2, 8): 4,
    (4, 1): 4, (4, 8): 5,
    (8, 1): 4, (8, 8): 6,
}
```

**That table looks like a tuning heuristic. It is not — it is a correctness/liveness
requirement.** VGPR-limited occupancy bounds how many workgroups can be co-resident, and a
handshaking kernel that exceeds it hangs. Anyone "tuning" those numbers upward for occupancy
is introducing a deadlock, and it will not reproduce on a short test because a small payload
launches few workgroups.

Worth a comment upstream saying so.

### (b) Grid-dependent flag region aliasing a later run's handshake

I sized the shared IPC buffer's flag region as `grid * world * 4` bytes, with the payload
inboxes immediately after. `grid` varies with payload size.

A small-payload run (small `grid`, short flag region) placed its **inboxes** at offsets that a
later large-payload run (large `grid`, long flag region) treats as its **flag** area. Stale
payload bytes were then read as handshake colours — a false handshake, or a hang, depending on
the byte values.

It only manifests when payload sizes vary back-to-back, which a fixed-size benchmark loop
never does. Fixed by making the flag region a constant size independent of `grid`.

Note that aiter gets this right and documents why the prefix must be sector-aligned:

```python
# flags_i32 is also the i32 offset of the wire area, so the flag prefix has
# to be a whole number of 64 B sectors (16 i32s). At a smaller multiple every
# rank-tile and release sector straddles two hardware sectors ...
grid_multiple = 16 // (PHASES * world_size)
```

### The conclusion I draw

Both bugs are invisible to a short test and to a fixed-shape benchmark. A collective that
passes 10 iterations and corrupts at 10,000 is worse than no change at all.

**This is why I am not proposing any handshake, fencing, or sync-structure change on the
strength of a benchmark.** §1 shows the one structural change I did test and it loses at TP=8
anyway. Where a change touches synchronisation, the bar is an explicit argument about which
invariant holds and why — not a faster number.

---

## 5. Prefill roofline: fabric-bound, closed

### Fabric, measured directly

`rocm-bandwidth-test` is not installed, so I measured with a HIP kernel (`i32x4` accesses,
grid swept 256-2048 blocks). Topology from `rocm-smi --showtopo`: all 8 GPUs **1 hop, XGMI,
uniform weight 15** — no near/far asymmetry.

| | measured |
|---|---|
| **Kernel-driven peer read, one link** | **65.8 GB/s** |
| Kernel-driven peer write, one link | 59.5 GB/s (NT store 57.4) |
| SDMA `copy_` peer-to-peer | 61.0 GB/s |
| **Two links concurrently, one GPU** | **130.9 GB/s (65.4/link)** |
| Local HBM read | 5589 GB/s |

Two links scale perfectly, so per-link 65.8 GB/s is the correct unit and a rank with 7 peers
is not limited by a shared ingress port.

### Two-shot wire cost

INT4 is 0.5 B/elem vs 2.0 B bf16 (**4x**), plus group-16 E4M3 scales. Per link:
`N/(4P)` for reduce-scatter + `N/(4P)` for all-gather = **`N/(2P)`**.

At `N` = 384 MB, `P` = 8: **24 MB per link**, floor **382 us** at 65.8 GB/s.
Traced production time is **~1220 us**.

That gap is real but it is *not* codec overhead — it is the compulsory HBM round trip
(read 384 + write 384 MB ≈ 137 us at 5.6 TB/s), the wire-buffer traffic, and the fact that
the two phases are serialised by a handshake and cannot overlap.

### The decisive test: lighter codecs are monotonically slower

Held-everything-else-fixed A/B at TP=2 (the controlled comparison — see §1 for why TP=2 is
fine *here*: all arms are two-shot, so no `P`-dependent byte ratio is being hidden):

| arm @ 384 MB, TP=2 | time | algo BW | SQNR | bytes vs INT4 |
|---|---|---|---|---|
| **FlyDSL QRInt4 ST=1** | **2052 us** | **196.2 GB/s** | 19.18 dB | 1.0x |
| FlyDSL QRInt4 ST=8 | 2094 us | 192.3 GB/s | 19.18 dB | 1.0x |
| HIP QR INT4 (production) | 2240 us | 179.7 GB/s | 18.32 dB | 1.0x |
| HIP QR INT4, no cast | 2488 us ⚠ | 161.8 GB/s | 18.32 dB | 1.0x |
| HIP QR INT6 | 3102 us | 129.8 GB/s | 30.42 dB | 1.5x |
| HIP QR INT8 | 3959 us | 101.7 GB/s | 42.25 dB | 2.0x |
| HIP QR FP | 7126 us | 56.5 GB/s | 54.85 dB | 4.0x |
| RCCL | 6986 us | 57.6 GB/s | 54.89 dB | 4.0x |

> **INT6 is 1.5x slower for 1.5x bytes. INT8 is 1.9x for 2x. FP is 3.5x for 4x.**
> **A compute-bound kernel gets faster with a cheaper codec. This one does not, at any
> size ≥4 MB. It is bandwidth-bound, and INT4 — the most aggressive compression — is correct.**

HIP QR INT4 achieves 65% of raw per-link peak (1459 us floor / 2240 us at TP=2); FlyDSL 71%.
Accounting for the compulsory HBM round trip that cannot be overlapped with itself, the INT4
path is at roughly **91% of what the memory system and one link can jointly sustain**.

**Conclusion: prefill QuickReduce is not inefficient. It is close to the fabric limit, on the
right algorithm, with the right codec. Closed.**

---

## 6. Instance census and the latency floor

### Census (rank-0 kineto trace, CPU-only mining)

75.5M events, 1.47M kernels, 21.62 s GPU span. **2057 QuickReduce instances, 2494.4 ms =
11.61% of kernel time** (brief said 1994 instances; true count is 2057).

Joining kernels to `cpu_op` via `External id` recovers **exactly three shapes**:

| shape | n | p50 | total | share of QR |
|---|---|---|---|---|
| `[32768, 6144]` = **384 MB** | 1815 | 1269.3 us | 2309.9 ms | **92.6%** |
| `[25057, 6144]` = 293 MB | 121 | 974.6 us | 118.1 ms | 4.7% |
| `[8192, 6144]` = 96 MB | 121 | 474.0 us | 66.4 ms | 2.7% |

Distribution: min 320, p25 1252, **p50 1265.8**, p75 1283, p95 1303, max 2922 us. The p25-p95
band is ±2% — the 384 MB population is very tight.

**Time per MB: 3.30 / 3.33 / 3.31 us across the three shapes.** Perfectly linear —
**bandwidth-bound with no fixed-cost component worth attacking at these sizes.** Independent
confirmation of §5.

All 2057 are the same kernel (`CodecQ4<__half,8>` — INT4 with the fp16 cast, as §3 predicts),
all on stream 4.

### Latency floor at small payloads (TP=2)

| | measured |
|---|---|
| Empty kernel, device-side (grid 1→1024) | **1.89-1.95 us**, flat |
| Host launch + sync wall | 12.21 us |
| **IPC flag round trip, peer-visible** | **1.28 us** |

Fitted QRInt4 cost model over the CU-starved region (spreads ≤0.8%):

```
ST=1:  time = 11.20 us + 0.1561 us per 32 KiB tile
ST=8:  time = 11.23 us + 0.1560 us per 32 KiB tile    <- identical
```

**Fixed overhead 11.2 us = 92.3% of total at 0.188 MB.** Only ~1.9 us is launch and ~1.3 us a
flag round-trip. At the 0.75 MB decode payload, wire time is ~3 us of ~15 us.

**Grid occupancy is the structural cause** — `num_tiles = ceil(bytes / 32768)`, one workgroup
per tile:

| payload | WGs | CUs used (of 256) |
|---|---|---|
| 0.188 MB | 6 | **2.3%** |
| 0.75 MB (decode) | 24 | **9.4%** |
| 2.0 MB (the gate) | 64 | 25.0% |
| 8.0 MB | 256 | 100% |

The small-payload regime **is** genuinely latency-dominated and under-occupied. But every
lever I tested against it — one-shot (§1), super-tile (below), lighter codec (§5) — fails at
TP=8. 32 KiB per workgroup is a coarse granule at 0.75 MB, and that is the thing left
unaddressed; I did not find a restructuring that beats it.

### Super-tile: correctly selected, no win

`SUPER_TILES = (1, 8)` is a hard whitelist — ST=2/4/16 raise. `_pick_st` selects ST=1 when
`num_tiles <= st1.grid`, a pure grid-occupancy test.

- At **TP=8**, ST=1 and ST=8 are **within 1% at every size to 6 MB** (§2 table).
- At TP=2 the crossover is 768 tiles = 24 MB, and below it both objects route to their ST=1
  engine — fitted fixed costs differ by 0.25%.
- Above the crossover at TP=2, ST=8 is consistently *worse* (32 MB: 179.6 vs 192.4 us;
  96 MB: 519.4 vs 544.1) and costs a 144 MB IPC buffer vs 13.7 MB.

**No tuning win here. I checked and it is not there.**

---

## 7. Arms excluded as not-reportable

Per the protocol in `README.md`, deltas whose spread would not settle are not claimed:

| arm | condition | spread |
|---|---|---|
| `aiter_ar` @ 0.188 MB, TP=8 | — | 24.6% |
| `aiter_ar` @ 0.750 MB, TP=8 | — | 14.5% |
| `aiter_ar` @ 0.047 MB, TP=4 | — | 18.4% |
| `hip_int4_nocast` @ 384 MB, TP=2 | — | 9.2% |
| `hip_int4` @ 0.750 MB, TP=8 | — | 7.8% |
| various | first unbatched sweep | 25-205% |

The unbatched sweep was superseded by batch-timed runs and none of its numbers are quoted.
**The 3% `fly_st1`-over-`aiter_ar` result at the decode payload is specifically NOT claimed as
a win**, because the comparison arm sat at 14.5% spread — see §2.

---

## 8. Verdict

| question | answer |
|---|---|
| Is prefill QuickReduce inefficient? | **No.** Fabric-bound, linear in payload, ~91% of jointly-achievable memory+link throughput. |
| Is INT4 the right codec? | **Yes.** Every lighter codec is slower in exact proportion to bytes added. |
| Is two-shot right at 384 MB? | **Yes**, and also at 0.75 MB — one-shot loses 3.3x at TP=8 (§1). |
| Is the super-tile choice right? | **Yes.** ST=1 vs ST=8 within 1% at TP=8. |
| Should the 2 MB floor be lowered? | **No.** 2.55x regression and −37 dB SQNR at the decode payload (§2). |
| Any cheaper config via flags today? | **No.** |
| Anything actionable? | **Yes — the `CAST_BF16_TO_FP16` bug (§3).** |

### Caveats

- Trace census is rank 0 of one run; other `run-*` dirs have no profiler output.
- §5 codec A/B and §6 cost models are **TP=2**. §1, §2 and the decode-gate table are
  **measured at real TP=8**.
- The 384 MB TP=8 roofline mixes a traced production number with a synthetic bandwidth
  ceiling; the TP=2 A/B is the controlled comparison.
- `bench/oneshot_kernel.py` is bf16-exact, not INT4 — it isolates algorithm shape from codec,
  and is not offered as a production path.
- No end-to-end serving runs; all numbers are op/collective-level.
