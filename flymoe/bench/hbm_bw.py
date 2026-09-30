"""HBM / MALL bandwidth floors for the roofline model (round 4, Phase 0).

  stream : read, write, copy of a large buffer (16 B/lane, grid-stride)
  epi    : a stage-2-shaped epilogue. Each CTA plays one 128-row x 256-col tile of a
           [R = T*k, H] expert-row matrix (R rows ordered like the plan: expert-major,
           token-sorted within an expert) and either
             rows    : stores its bf16 tile into y_rows[R, H]        (current dataflow)
             f32     : atomically adds it into out_f32[T, H]         (fp32 accumulate)
             bf16    : atomically adds it into out_bf16[T, H]        (pk_add_bf16)
           Tile order: "expert" (plan order) or "winN" (token-window-major: rows sorted by
           (token // (T/N), expert, token), so concurrently running tiles touch 1/N of out).

Reports achieved bytes/s of the *logical* traffic (bytes the dataflow must move) and
wall time; the rows variant excludes the combine pass that re-reads y_rows.
"""

import argparse
import json
import os
import sys

import torch

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

import flydsl.compiler as flyc  # noqa: E402
import flydsl.expr as fx  # noqa: E402
from flydsl.expr import const_expr, gpu, range_constexpr  # noqa: E402
from flydsl.expr.typing import T  # noqa: E402

from flymoe import hw  # noqa: E402

H = 6144
BM, BN = 128, 256
NB = H // BN
UNR = 8  # 16 B accesses per thread per chunk


def build_stream(mode):
    CH = 256 * 16 * UNR

    @flyc.kernel(name=f"hbmbw_stream_{mode}", known_block_size=[256, 1, 1])
    def k(src: fx.Int64, dst: fx.Int64, nchunk: fx.Int32):
        tid = fx.Int32(gpu.thread_id("x"))
        bid = fx.Int32(gpu.block_id("x"))
        grid = fx.Int32(gpu.grid_dim.x)
        rs = hw.rsrc(src)
        rd = hw.rsrc(dst)
        for c in range(bid, nchunk, grid):
            base = c * CH + tid * 16
            vals = []
            if const_expr(mode != "write"):
                vals = [hw.bload(rs, base + j * 4096, T.i32x4) for j in range_constexpr(UNR)]
            for j in range_constexpr(UNR):
                if const_expr(mode == "read"):
                    if fx.Int32(fx.Vector(vals[j])[0]) == fx.Int32(0x7F7F7F7F):
                        hw.bstore(fx.Int32(1), rd, tid * 4)
                elif const_expr(mode == "write"):
                    hw.bstore(hw.raw(fx.Vector.filled(4, 0, fx.Int32)), rd, base + j * 4096)
                else:
                    hw.bstore(vals[j], rd, base + j * 4096)

    @flyc.jit
    def launch(src: fx.Int64, dst: fx.Int64, nchunk: fx.Int32, grid: fx.Int32,
               stream: fx.Stream = fx.Stream(None)):
        k(src, dst, nchunk).launch(grid=(grid, 1, 1), block=(256, 1, 1), stream=stream)

    return launch, CH


def build_epi(mode, xcd_local=False):
    """xcd_local: remap each token into a range private to the issuing CTA's XCD (bid % 8),
    so no output line is touched by two XCDs (throughput probe only; sums are not checked)."""
    @flyc.kernel(name=f"hbmbw_epi_{mode}{'_xl' if xcd_local else ''}", known_block_size=[256, 1, 1])
    def k(tok_ptr: fx.Int64, out_ptr: fx.Int64, n_out: fx.Int32):
        tid = fx.Int32(gpu.thread_id("x"))
        w = fx.Int32(gpu.block_id("x"))
        mt = w // NB
        nb = w % NB
        rt = hw.rsrc(tok_ptr)
        if const_expr(mode == "rows"):
            ro = hw.rsrc(out_ptr)
            # 128 rows x 512 B: 32 lanes x 16 B per row, 8 rows per pass
            for i in range_constexpr(BM // 8):
                r = mt * BM + i * 8 + tid // 32
                off = fx.Int64(r) * fx.Int64(H * 2) + fx.Int64(nb * BN * 2 + (tid % 32) * 16)
                hw.gstore(hw.raw(fx.Vector.filled(4, 0x3F803F80, fx.Int32)), fx.Int64(out_ptr) + off)
        else:
            esz = 4 if mode == "f32" else 2
            ro = hw.rsrc(out_ptr, fx.Int64(n_out) * fx.Int64(H * esz))
            # 128 rows x 256 cols: 128 lanes x 2 cols per row, 2 rows per pass
            for i in range_constexpr(BM // 2):
                r = mt * BM + i * 2 + tid // 128
                t = fx.Int32(hw.bload(rt, r * 4, T.i32))
                if const_expr(xcd_local):
                    t = (w % 8) * (n_out // 8) + t % (n_out // 8)
                col = nb * BN + (tid % 128) * 2
                if const_expr(mode == "f32"):
                    off = (t * H + col) * 4
                    hw.batomic_fadd(fx.Float32(1.0), ro, off)
                    hw.batomic_fadd(fx.Float32(1.0), ro, off + 4)
                else:
                    one = fx.Vector.filled(2, 1.0, fx.Float32).to(fx.BFloat16)
                    hw.batomic_fadd(one, ro, (t * H + col) * 2)

    @flyc.jit
    def launch(tok_ptr: fx.Int64, out_ptr: fx.Int64, n_out: fx.Int32, grid: fx.Int32,
               stream: fx.Stream = fx.Stream(None)):
        k(tok_ptr, out_ptr, n_out).launch(grid=(grid, 1, 1), block=(256, 1, 1), stream=stream)

    return launch


def timeit(fn, reps=10):
    fn()
    torch.cuda.synchronize()
    s, e = torch.cuda.Event(enable_timing=True), torch.cuda.Event(enable_timing=True)
    ts = []
    for _ in range(reps):
        s.record()
        fn()
        e.record()
        torch.cuda.synchronize()
        ts.append(s.elapsed_time(e) * 1e3)
    ts.sort()
    return ts[len(ts) // 2]


def routing_rows(T_, k=5, E=129, seed=0, order="expert"):
    """Token id per plan row: k-1 random routed experts + the shared expert per token."""
    g = torch.Generator(device="cpu").manual_seed(seed)
    routed = torch.rand(T_, E - 1, generator=g).argsort(dim=1)[:, : k - 1]
    ids = torch.cat([routed, torch.full((T_, 1), E - 1)], dim=1).reshape(-1)
    tok = torch.arange(T_).repeat_interleave(k)
    if order == "expert":
        key = ids * T_ + tok
    else:
        nwin = int(order[3:])
        win = tok * nwin // T_
        key = (win * E + ids) * T_ + tok
    tok = tok[key.argsort()]
    R = tok.numel()
    Rp = (R + BM - 1) // BM * BM
    tok = torch.cat([tok, tok[-1:].repeat(Rp - R)])  # pad rows repeat the last token (tiny)
    return tok.to(torch.int32).cuda(), R, Rp


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--T", type=int, nargs="+", default=[4096, 32768])
    ap.add_argument("--orders", nargs="+", default=["expert", "win2", "win4", "win8", "win16"])
    ap.add_argument("--stream-gb", type=float, default=2.0)
    ap.add_argument("--out", default="")
    a = ap.parse_args()
    st = torch.cuda.current_stream()
    res = {"stream": {}, "epi": []}

    nbytes = int(a.stream_gb * 2**30)
    src = torch.randint(0, 100, (nbytes // 4,), dtype=torch.int32, device="cuda")
    dst = torch.empty_like(src)
    for mode in ("read", "write", "copy"):
        launch, CH = build_stream(mode)
        nchunk = nbytes // CH
        grid = 256 * 8
        f = flyc.compile(launch, src.data_ptr(), dst.data_ptr(), nchunk, grid, st)
        us = timeit(lambda: f(src.data_ptr(), dst.data_ptr(), nchunk, grid, st))
        moved = nchunk * CH * (2 if mode == "copy" else 1)
        res["stream"][mode] = moved / us / 1e6
        print(f"stream {mode:5s}: {moved / us / 1e6:6.2f} TB/s ({us:8.1f} us for {moved / 1e9:.2f} GB)", flush=True)
    del src, dst

    for T_ in a.T:
        for order in a.orders:
            tok, R, Rp = routing_rows(T_, order=order)
            grid = (Rp // BM) * NB
            for mode in ("rows", "f32", "bf16", "bf16xl"):
                if mode in ("rows", "bf16xl") and order != "expert":
                    continue
                xl = mode.endswith("xl")
                mode = mode[:-2] if xl else mode
                if mode == "rows":
                    out = torch.empty(Rp * H, dtype=torch.bfloat16, device="cuda")
                    logical = R * H * 2
                else:
                    out = torch.zeros(T_ * H, dtype=torch.float32 if mode == "f32" else torch.bfloat16, device="cuda")
                    logical = R * H * 2  # bf16 contribution bytes, same as rows
                launch = build_epi(mode, xl)
                f = flyc.compile(launch, tok.data_ptr(), out.data_ptr(), T_, grid, st)
                us = timeit(lambda: f(tok.data_ptr(), out.data_ptr(), T_, grid, st))
                mode = mode + ("xl" if xl else "")
                if mode in ("f32", "bf16"):
                    out.zero_()
                    f(tok.data_ptr(), out.data_ptr(), T_, grid, st)
                    torch.cuda.synchronize()
                    ok = bool((out.float().view(T_, H) == 5.0).all().item())
                else:
                    ok = True
                row = dict(T=T_, order=order, mode=mode, us=us, logical_TBs=logical / us / 1e6, ok=ok)
                res["epi"].append(row)
                print(f"epi T={T_:6d} {order:6s} {mode:4s}: {us:8.1f} us  {logical / us / 1e6:5.2f} TB/s(bf16-row equiv)"
                      f"  sum_ok={ok}", flush=True)
                del out
    if a.out:
        with open(a.out, "w") as fh:
            json.dump(res, fh, indent=1)


if __name__ == "__main__":
    main()
