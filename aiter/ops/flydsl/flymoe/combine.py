"""Deterministic top-k combine: out[t] = sum_s y_rows[inv[t*k + s]] (weights already applied).

y_rows: [R, H] bf16 in compact expert-sorted order. out: [T, H] bf16.
One CTA per token, 16 B (8 bf16) per thread per chunk, fp32 accumulation.
"""

import functools

import flydsl.compiler as flyc
import flydsl.expr as fx
from flydsl.expr import const_expr, gpu, range_constexpr, rocdl
from flydsl.expr.typing import T

from . import hw


@functools.cache
def build_combine(H: int, k: int, threads: int = 256):
    assert H % (8 * threads) == 0 or H % 8 == 0
    chunks = (H // 8 + threads - 1) // threads
    exact = (H // 8) % threads == 0

    kname = f"flymoe_combine_h{H}_k{k}_{hw.SRC_HASH}"

    @flyc.kernel(name=kname, known_block_size=[threads, 1, 1])
    def kern(
        y_ptr: fx.Int64,
        inv_ptr: fx.Int64,
        o_ptr: fx.Int64,
        n_rows: fx.Int32,
        n_tok: fx.Int32,
    ):
        if const_expr(kname == ""):  # name (incl. source hash) in the JIT cache key
            pass
        tid = fx.Int32(gpu.thread_id("x"))
        t = fx.Int32(gpu.block_id("x"))
        r_inv = hw.rsrc(inv_ptr)
        # 64-bit per-row / per-token descriptor bases: no 32-bit offset overflow at any R.
        r_o = hw.rsrc(fx.Int64(o_ptr) + fx.Int64(t) * fx.Int64(H * 2), H * 2)
        r_rows = []
        for s in range_constexpr(k):
            row = fx.Int32(
                rocdl.readfirstlane(T.i32, hw.bload(r_inv, (t * k + s) * 4, T.i32))
            )
            r_rows.append(
                hw.rsrc(fx.Int64(y_ptr) + fx.Int64(row) * fx.Int64(H * 2), H * 2)
            )
        for c in range_constexpr(chunks):
            col = (tid + c * threads) * 8
            ok = col < H if not exact else None
            vals = [
                fx.Vector(hw.bload(r_rows[s], col * 2, T.vec(8, T.bf16))).to(fx.Float32)
                for s in range_constexpr(k)
            ]
            acc = vals[0]
            for s in range_constexpr(1, k):
                acc = acc + vals[s]
            off = col * 2
            if ok is not None:
                off = ok.select(off, fx.Int32(0x7FFFFF00))
            hw.bstore(acc.to(fx.BFloat16), r_o, off)

    @flyc.jit
    def launch(
        y_ptr: fx.Int64,
        inv_ptr: fx.Int64,
        o_ptr: fx.Int64,
        n_rows: fx.Int32,
        n_tok: fx.Int32,
        stream: fx.Stream = fx.Stream(None),  # noqa: B008
    ):
        kern(y_ptr, inv_ptr, o_ptr, n_rows, n_tok).launch(
            grid=(n_tok, 1, 1), block=(threads, 1, 1), stream=stream
        )

    return launch


_cf = {}


def run_combine(y_rows, inv, out, k, stream=None):
    import torch

    T_, H = out.shape
    key = (H, k)
    args = (
        y_rows.data_ptr(),
        inv.data_ptr(),
        out.data_ptr(),
        y_rows.shape[0],
        T_,
        torch.cuda.current_stream() if stream is None else stream,
    )
    if key not in _cf:
        _cf[key] = flyc.compile(build_combine(H, k), *args)
    else:
        _cf[key](*args)
