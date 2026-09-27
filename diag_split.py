"""Isolate WHY the cap helps at short-context/large-batch and hurts at long.

Two independent effects are conflated in the sweep:
  (A) dead workgroups  -- chunks past cdiv(nblk, per_chunk) exit immediately
  (B) idle waves       -- per_chunk < kWaves leaves waves 1..W-1 with no block

Sweeping chunks directly (not via a policy) separates them: for a fixed live
context and batch, walk the chunk count and record time, dead-WG fraction and
per_chunk. Also sweeps live context at fixed batch to find the crossover.
"""

import argparse
import math

import torch

import aiter.ops.msa_block_select as mbs

BLOCK_SIZE = 128
HEAD_DIM = 128
TOPK = 16
NUM_IDX_HEADS = 1
MAX_MODEL_LEN = 133120
SCORE_WAVES = 4


def pow2_ceil(n):
    return 1 << (n - 1).bit_length() if n >= 1 else 1


def make_inputs(num_reqs, live_ctx, max_seq_len, device):
    nblk = math.ceil(live_ctx / BLOCK_SIZE)
    max_blk = math.ceil(max_seq_len / BLOCK_SIZE)
    total_pages = num_reqs * nblk + 1
    g = torch.Generator(device=device).manual_seed(0)
    q = torch.randn(num_reqs, NUM_IDX_HEADS, HEAD_DIM, generator=g,
                    device=device, dtype=torch.float32) * 4.0
    kv = torch.randn(total_pages, BLOCK_SIZE, HEAD_DIM, generator=g,
                     device=device, dtype=torch.float32) * 4.0
    bt = (torch.arange(num_reqs * max_blk, dtype=torch.int32, device=device)
          .view(num_reqs, max_blk) % total_pages).contiguous()
    width = pow2_ceil(math.ceil(max_blk / 64)) * 64
    return dict(
        q=q.to(torch.float8_e4m3fn).contiguous(),
        kv=kv.to(torch.float8_e4m3fn).contiguous(),
        bt=bt,
        sl=torch.full((num_reqs,), live_ctx, dtype=torch.int32, device=device),
        score=torch.empty((NUM_IDX_HEADS, num_reqs, width),
                          dtype=torch.float32, device=device),
        nblk=nblk, max_seq_len=max_seq_len,
    )


def time_us(fn, iters=200, warmup=20):
    for _ in range(warmup):
        fn()
    torch.cuda.synchronize()
    b, e = (torch.cuda.Event(enable_timing=True) for _ in range(2))
    b.record()
    for _ in range(iters):
        fn()
    e.record()
    torch.cuda.synchronize()
    return b.elapsed_time(e) * 1000.0 / iters


def bench_chunks(t, num_reqs, chunks, iters):
    mbs._score_split = lambda mb, nr, _c=chunks: (_c, SCORE_WAVES)
    from aiter.ops.msa_block_select import pa_sparse_block_score_decode as f
    return time_us(lambda: f(t["q"], t["kv"], t["score"], t["bt"], t["sl"],
                             init_blocks=0, local_blocks=1, query_len=1,
                             max_seq_len=t["max_seq_len"]), iters)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--iters", type=int, default=200)
    args = ap.parse_args()
    dev = torch.device("cuda")
    p = torch.cuda.get_device_properties(dev)
    print(f"device {p.gcnArchName} CUs={p.multi_processor_count}\n")

    print("=== chunk sweep: time vs grid, at fixed (ctx, reqs) ===")
    print(f"{'ctx':>7} {'reqs':>5} {'chunks':>7} {'WGs':>6} {'per_ch':>6} "
          f"{'liveWG%':>8} {'liveWv':>6} {'us':>8} {'vs best':>8}")
    for live_ctx, reqs in ((8192, 64), (8192, 128), (60000, 64), (131072, 64)):
        t = make_inputs(reqs, live_ctx, MAX_MODEL_LEN, dev)
        nblk = t["nblk"]
        rows = []
        for ch in (1, 2, 4, 8, 16, 32, 64, 128, 256):
            if ch > 16384 // reqs:
                continue
            us = bench_chunks(t, reqs, ch, args.iters)
            per_chunk = max(1, math.ceil(nblk / ch))
            live_ch = math.ceil(nblk / per_chunk)
            rows.append((ch, us, per_chunk, live_ch, min(SCORE_WAVES, per_chunk)))
        best = min(r[1] for r in rows)
        for ch, us, pc, lc, lw in rows:
            print(f"{live_ctx:>7} {reqs:>5} {ch:>7} {reqs*ch:>6} {pc:>6} "
                  f"{100.0*lc/ch:>7.0f}% {lw:>6} {us:>8.2f} {us/best:>7.2f}x")
        print()

    print("=== crossover: live context at fixed batch=64, legacy vs cap ===")
    print(f"{'ctx':>8} {'nblk':>6} {'legacyUS':>9} {'capUS':>8} {'speedup':>8}")
    for live_ctx in (2048, 4096, 8192, 16384, 32768, 65536, 131072):
        t = make_inputs(64, live_ctx, MAX_MODEL_LEN, dev)
        mb = math.ceil(MAX_MODEL_LEN / BLOCK_SIZE)
        leg_ch = max(1, min(mb // SCORE_WAVES, 16384 // 64))
        cap_ch = max(1, min(leg_ch, 8 * p.multi_processor_count // 64))
        lu = bench_chunks(t, 64, leg_ch, args.iters)
        cu = bench_chunks(t, 64, cap_ch, args.iters)
        print(f"{live_ctx:>8} {t['nblk']:>6} {lu:>9.2f} {cu:>8.2f} {lu/cu:>7.2f}x")


if __name__ == "__main__":
    main()
