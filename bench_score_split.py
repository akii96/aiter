"""Isolated benchmark of pa_sparse_block_score_decode across split policies.

Measures the score kernel alone (and top-k, for reference) at MiniMax-M3's
decode shapes, sweeping the block-axis split policy. The launch bound
(max_seq_len) is held at max_model_len the way cudagraph capture forces, while
the live context varies -- which is the whole point: the two disagree.

Run:  HIP_VISIBLE_DEVICES=0 python bench_score_split.py
"""

import argparse
import json
import math
import os
import sys

import torch

import aiter.ops.msa_block_select as mbs
from aiter.ops.msa_block_select import (
    pa_sparse_block_score_decode,
    pa_sparse_block_topk,
)

# ---------------------------------------------------------------------------
# Policy injection.
#
# The installed aiter is left completely untouched: rather than overwriting
# aiter/ops/msa_block_select.py, the candidate policy is monkeypatched over
# `mbs._score_split` for the duration of the run. `_score_split` is called by
# `pa_sparse_block_score_decode` in the same module, so rebinding the module
# attribute is enough to redirect it.
# ---------------------------------------------------------------------------
_LEGACY_SCORE_SPLIT = mbs._score_split


def _split_legacy(max_blk, num_reqs):
    waves = min(mbs.SCORE_WAVES, mbs._pow2_floor(max(1, max_blk)))
    chunks = max(1, max_blk // waves)
    return max(1, min(chunks, mbs.SCORE_MAX_WORKGROUPS // max(1, num_reqs))), waves


def _make_split_capped(per_cu, cu_num):
    """The Phase A' policy: cap the chunk count at what stays resident."""

    def _split(max_blk, num_reqs):
        waves = min(mbs.SCORE_WAVES, mbs._pow2_floor(max(1, max_blk)))
        chunks = max(1, max_blk // waves)
        chunks = min(chunks, max(1, per_cu * cu_num // max(1, num_reqs)))
        return (
            max(1, min(chunks, mbs.SCORE_MAX_WORKGROUPS // max(1, num_reqs))),
            waves,
        )

    return _split


def install_policy(pol, cu_num):
    """Point mbs._score_split at `pol` and return its (chunks, waves) fn."""
    fn = _split_legacy if pol == "legacy" else _make_split_capped(int(pol), cu_num)
    mbs._score_split = fn
    return fn

# MiniMax-M3 verified contract (config.json of amd/MiniMax-M3-MXFP4).
BLOCK_SIZE = 128
HEAD_DIM = 128
TOPK = 16
PAGES_PER_BLOCK = 8
INIT_BLOCKS = 0
LOCAL_BLOCKS = 1
# 4 index heads // TP=8 -> 1 per rank.
NUM_IDX_HEADS = 1
NUM_KV_HEADS = 1
MAX_MODEL_LEN = 133120


def pow2_ceil(n):
    return 1 << (n - 1).bit_length() if n >= 1 else 1


def score_width(max_seq_len, block_size):
    max_blk = math.ceil(max(max_seq_len, 1) / block_size)
    return pow2_ceil(math.ceil(max_blk / 64)) * 64


def make_inputs(num_reqs, live_ctx, max_seq_len, device):
    """Build one decode batch. Pages are unique per (req, block) so the KV
    stream is as wide as the real thing rather than hitting one cached page."""
    nblk = math.ceil(live_ctx / BLOCK_SIZE)
    max_blk = math.ceil(max_seq_len / BLOCK_SIZE)
    total_pages = num_reqs * nblk + 1

    g = torch.Generator(device=device).manual_seed(0)
    q = (torch.randn(num_reqs, NUM_IDX_HEADS, HEAD_DIM, generator=g,
                     device=device, dtype=torch.float32) * 4.0)
    kv = (torch.randn(total_pages, BLOCK_SIZE, HEAD_DIM, generator=g,
                      device=device, dtype=torch.float32) * 4.0)
    q_idx = q.to(torch.float8_e4m3fn).contiguous()
    kv_idx = kv.to(torch.float8_e4m3fn).contiguous()

    block_table = torch.arange(
        num_reqs * max_blk, dtype=torch.int32, device=device
    ).view(num_reqs, max_blk) % total_pages
    block_table = block_table.contiguous()
    seq_lens = torch.full((num_reqs,), live_ctx, dtype=torch.int32, device=device)

    score = torch.empty(
        (NUM_IDX_HEADS, num_reqs, score_width(max_seq_len, BLOCK_SIZE)),
        dtype=torch.float32, device=device,
    )
    topk_idx = torch.empty(
        (NUM_IDX_HEADS, num_reqs, TOPK), dtype=torch.int32, device=device
    )
    rows = num_reqs * NUM_KV_HEADS
    sparse_bt = torch.empty((rows, TOPK * PAGES_PER_BLOCK),
                            dtype=torch.int32, device=device)
    sparse_ctx = torch.empty(rows, dtype=torch.int32, device=device)
    return dict(q_idx=q_idx, kv_idx=kv_idx, score=score, block_table=block_table,
                seq_lens=seq_lens, topk_idx=topk_idx, sparse_bt=sparse_bt,
                sparse_ctx=sparse_ctx, max_seq_len=max_seq_len, nblk=nblk)


def time_us(fn, iters, warmup=20):
    for _ in range(warmup):
        fn()
    torch.cuda.synchronize()
    beg = torch.cuda.Event(enable_timing=True)
    end = torch.cuda.Event(enable_timing=True)
    beg.record()
    for _ in range(iters):
        fn()
    end.record()
    torch.cuda.synchronize()
    return beg.elapsed_time(end) * 1000.0 / iters


def run_case(t, iters):
    def score():
        pa_sparse_block_score_decode(
            t["q_idx"], t["kv_idx"], t["score"], t["block_table"], t["seq_lens"],
            init_blocks=INIT_BLOCKS, local_blocks=LOCAL_BLOCKS, query_len=1,
            max_seq_len=t["max_seq_len"],
        )

    def topk():
        pa_sparse_block_topk(
            t["score"], t["topk_idx"], t["block_table"], t["seq_lens"],
            max_seq_len=t["max_seq_len"], block_size=BLOCK_SIZE, query_len=1,
            sparse_bt=t["sparse_bt"], sparse_ctx=t["sparse_ctx"],
            num_kv_heads=NUM_KV_HEADS, pages_per_block=PAGES_PER_BLOCK,
        )

    return time_us(score, iters), time_us(topk, iters)


def selection_of(t):
    """Run score+topk once and return the selection, for cross-policy equality."""
    pa_sparse_block_score_decode(
        t["q_idx"], t["kv_idx"], t["score"], t["block_table"], t["seq_lens"],
        init_blocks=INIT_BLOCKS, local_blocks=LOCAL_BLOCKS, query_len=1,
        max_seq_len=t["max_seq_len"],
    )
    pa_sparse_block_topk(
        t["score"], t["topk_idx"], t["block_table"], t["seq_lens"],
        max_seq_len=t["max_seq_len"], block_size=BLOCK_SIZE, query_len=1,
        sparse_bt=t["sparse_bt"], sparse_ctx=t["sparse_ctx"],
        num_kv_heads=NUM_KV_HEADS, pages_per_block=PAGES_PER_BLOCK,
    )
    torch.cuda.synchronize()
    return (t["topk_idx"].clone(), t["sparse_bt"].clone(), t["sparse_ctx"].clone())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--iters", type=int, default=200)
    ap.add_argument("--max-model-len", type=int, default=MAX_MODEL_LEN)
    ap.add_argument("--json", type=str, default="")
    ap.add_argument("--policies", type=str, default="legacy,2,4,8,16")
    args = ap.parse_args()

    dev = torch.device("cuda")
    props = torch.cuda.get_device_properties(dev)
    print(f"device: {props.name} {props.gcnArchName} CUs={props.multi_processor_count}")
    print(f"launch bound (max_seq_len) held at {args.max_model_len} "
          f"= {math.ceil(args.max_model_len / BLOCK_SIZE)} blocks\n")

    contexts = (8192, 60000, 131072)
    batches = (4, 16, 64, 128)
    policies = [p.strip() for p in args.policies.split(",") if p.strip()]
    results = []
    ref_sel = {}

    for live_ctx in contexts:
        for num_reqs in batches:
            t = make_inputs(num_reqs, live_ctx, args.max_model_len, dev)
            row = {"ctx": live_ctx, "reqs": num_reqs, "nblk": t["nblk"]}
            for pol in policies:
                split = install_policy(pol, props.multi_processor_count)
                chunks, waves = split(
                    math.ceil(args.max_model_len / BLOCK_SIZE), num_reqs
                )
                sel = selection_of(t)
                key = (live_ctx, num_reqs)
                if key not in ref_sel:
                    ref_sel[key] = sel
                else:
                    same = all(torch.equal(a, b) for a, b in zip(sel, ref_sel[key]))
                    row[f"match_{pol}"] = bool(same)
                s_us, t_us = run_case(t, args.iters)
                row[f"score_{pol}"] = s_us
                row[f"topk_{pol}"] = t_us
                row[f"chunks_{pol}"] = chunks
                row[f"wgs_{pol}"] = num_reqs * chunks
            results.append(row)
            base = row.get("score_legacy")
            parts = []
            for pol in policies:
                if pol == "legacy":
                    continue
                sp = base / row[f"score_{pol}"] if row.get(f"score_{pol}") else 0
                ok = row.get(f"match_{pol}", True)
                parts.append(f"{pol}:{row[f'score_{pol}']:7.2f}us "
                             f"({sp:4.2f}x,wg={row[f'wgs_{pol}']:5d}"
                             f"{'' if ok else ',MISMATCH!'})")
            print(f"ctx={live_ctx:>6} reqs={num_reqs:>4} nblk={row['nblk']:>5} | "
                  f"legacy:{base:7.2f}us (wg={row['wgs_legacy']:5d}) | " + "  ".join(parts))
        print()

    mbs._score_split = _LEGACY_SCORE_SPLIT

    # Correctness gate: the split must never change the selection.
    bad = [r for r in results
           for p in policies if p != "legacy" and r.get(f"match_{p}") is False]
    print("=" * 78)
    if bad:
        print(f"FAIL: {len(bad)} shape(s) changed the selection across policies")
    else:
        print("PASS: selection (topk_idx, sparse_bt, sparse_ctx) identical "
              "across every policy and shape")

    print("\n=== score kernel speedup vs legacy ===")
    for pol in policies:
        if pol == "legacy":
            continue
        sp = [r["score_legacy"] / r[f"score_{pol}"] for r in results]
        print(f"  per_cu={pol:>6}: min={min(sp):.2f}x  median="
              f"{sorted(sp)[len(sp)//2]:.2f}x  max={max(sp):.2f}x  "
              f"geomean={math.exp(sum(math.log(x) for x in sp)/len(sp)):.2f}x")

    if args.json:
        with open(args.json, "w") as f:
            json.dump({"device": props.gcnArchName,
                       "cus": props.multi_processor_count,
                       "max_model_len": args.max_model_len,
                       "results": results}, f, indent=1)
        print(f"\nwrote {args.json}")
    return 0 if not bad else 1


if __name__ == "__main__":
    sys.exit(main())
