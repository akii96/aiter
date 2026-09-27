# QuickReduce small-payload investigation (MiniMax-M3, gfx950, TP=8)

Docs and benchmark harness only. **No functional changes to aiter.**

This directory records a negative result — prefill QuickReduce is fabric-bound and
close to its limit — plus three findings that are worth more than the negative:

1. **[A one-shot all-reduce that wins at TP=2 and loses at TP=8.](findings.md#1-the-one-shot-falsification)**
   A warning about a whole class of collective benchmarking: per-link bytes scale
   as `P/2` between one-shot and two-shot, so **TP=2 measurements of collectives
   do not extrapolate**.
2. **[The sub-2MB QuickReduce floor is protective, not obstructive.](findings.md#2-the-sub-2-mb-floor-is-correct-the-hypothesis-was-backwards)**
   Lowering it would be a 2.55x regression at the decode payload.
3. **[`VLLM_ROCM_QUICK_REDUCE_CAST_BF16_TO_FP16=0` silently disables QuickReduce
   entirely for bf16 models.](findings.md#3-bug-cast_bf16_to_fp160-silently-disables-quickreduce-for-bf16-models)**
   Undocumented, load-bearing in two independent ways. File-able on its own.

Also recorded: **[two synchronisation bugs I wrote and hit myself](findings.md#4-two-sync-bugs-i-hit-why-_resident_wgs_per_cu-is-a-liveness-requirement)**,
both of which passed a 10-iteration test. They are the concrete case for why
`_RESIDENT_WGS_PER_CU` in `aiter/ops/flydsl/kernels/quick_allreduce_int4.py` is a
**liveness requirement, not a tuning table**.

## Contents

| file | what |
|---|---|
| `findings.md` | Full write-up: roofline, instance census, all measurements, verdict |
| `bench/arbench.py` | Multi-arm all-reduce comparison (FlyDSL QRInt4 / HIP QuickReduce all regimes / aiter custom AR / vLLM CA / RCCL) |
| `bench/tp_scaling.py` | One-shot vs two-shot across TP=2/4/8, with a 2000-iteration correctness check |
| `bench/decode_gate.py` | TP=8 test of every available path at MiniMax-M3 decode payloads |
| `bench/latency_floor.py` | Fixed-vs-marginal cost model; empty-kernel and IPC flag round-trip floors |
| `bench/fabric_bw.py` | Kernel-driven xGMI peer bandwidth, single- and multi-link |
| `bench/oneshot_kernel.py` | Minimal one-shot IPC all-reduce (measurement instrument, **not** a proposal) |
| `bench/mine_trace.py` | Kineto trace miner: per-instance durations joined to shapes via `External id` |
| `results/` | Raw JSON from every run quoted in `findings.md` |

## Measurement protocol

Eight MI355X share a power/thermal budget, so parallel arms contaminate each
other. Every comparative timing here is:

- **serial, with arms round-robin interleaved** (one batch per arm per round)
- **batch-timed** (300-500 reps inside one pair of CUDA events) so a ~12 us
  collective is not measured in launch noise
- **trimmed median** of 13-15 rounds, with per-arm spread reported

**Any arm whose spread would not settle below ~2% is flagged and its delta is not
claimed.** Arms excluded on those grounds are listed in `findings.md`.

## Reproducing

```bash
# fabric roofline
python bench/fabric_bw.py

# TP=8 decode gate (the headline table)
torchrun --nproc_per_node=8 bench/decode_gate.py

# one-shot vs two-shot across TP (run at 2, 4 and 8 to see the P/2 effect)
torchrun --nproc_per_node=2 bench/tp_scaling.py
torchrun --nproc_per_node=4 bench/tp_scaling.py
torchrun --nproc_per_node=8 bench/tp_scaling.py

# latency floor decomposition
torchrun --nproc_per_node=2 bench/latency_floor.py

# codec / cast A-B
torchrun --nproc_per_node=2 bench/arbench.py \
  --sizes-mb 0.75,4,24,96,384 --hidden 6144 \
  --arms fly1,fly8,hipqr_int4,hipqr_int4_nocast,hipqr_int6,hipqr_int8,hipqr_fp
```

`bench/oneshot_kernel.py` is imported by `tp_scaling.py`; build it once
single-process before launching multi-rank, or ranks race on the JIT directory.

Environment these numbers come from: 8x MI355X gfx950 (256 CU), ROCm 7.2.3,
vLLM 0.30.1rc1, aiter main @ 8253efc4, fully-connected 1-hop xGMI.
