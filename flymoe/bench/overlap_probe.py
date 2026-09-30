"""Upper-bound probe for single-launch FC stage 2: the routed (rows) and shared (fused)
launches run concurrently on two streams (results invalid) vs back to back.

python bench/overlap_probe.py --I 1536 --T 32768 [--arm "..."]
"""

import argparse
import os
import sys

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, HERE)

from compare import table_cfg  # noqa: E402
from s2_sweep import arm_cfg  # noqa: E402
from flymoe import gemm, moe  # noqa: E402
from tests.test_moe import make_problem  # noqa: E402


def launch(r, b, c, stream):
    W = r.W
    tp, ntp = r._tl(b)
    gemm.run_gemm(
        2, r.I, r.H, c["BM"],
        (r.h_q.data_ptr(), r.h_s.data_ptr(), W.b2.data_ptr(), W.bs2.data_ptr(),
         tp, ntp, r.row_tok.data_ptr(), r.row_w.data_ptr(),
         r.y_rows.data_ptr(), r.out.data_ptr(), r.inv.data_ptr(), r.R, r.R, r.T),
        r.spec_mt[b], D=c["D"], epi=c.get("epi", r.epi), KTOP=r.k, pipe=c["pipe"], NW=c["NW"], GM=c["GM"],
        diag=c["diag"], WM=c["WM"], EF=c["EF"], MV=c["MV"], AST=r.HT, HT=r.HT, stream=stream)


def timed(fn, reps=10):
    ts = []
    for _ in range(reps):
        a, b = torch.cuda.Event(enable_timing=True), torch.cuda.Event(enable_timing=True)
        torch.cuda.synchronize()
        a.record()
        fn()
        b.record()
        torch.cuda.synchronize()
        ts.append(a.elapsed_time(b) * 1e3)
    return min(ts)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--I", type=int, required=True)
    ap.add_argument("--T", type=int, required=True)
    ap.add_argument("--arm", default="BM2=128,NW2=4,pipe2=hybrid2,D2=2,diag2=wpe2+s2nt,FC=1")
    a = ap.parse_args()
    x, ids, w, wts = make_problem(a.T, a.I)
    cfg = arm_cfg(table_cfg(os.path.join(HERE, "..", "configs", "tiles_v5_I{I}.json"), a.I, a.T), a.arm)
    r = moe.MoERun(x, ids, w, moe.MoEWeights(*wts), **cfg)
    assert r.FC
    for _ in range(2):
        r.forward()
    torch.cuda.synchronize()
    (b0, c0), (b1, c1) = r.launches2
    main = torch.cuda.current_stream()
    side = torch.cuda.Stream()

    def seq():
        launch(r, b0, c0, main)
        launch(r, b1, c1, main)

    def conc():
        side.wait_stream(main)
        launch(r, b1, c1, side)
        launch(r, b0, c0, main)
        main.wait_stream(side)

    def only(b, c):
        return lambda: launch(r, b, c, main)

    print(f"I={a.I} T={a.T} rows={timed(only(b0, c0)):.1f} fused={timed(only(b1, c1)):.1f} "
          f"seq={timed(seq):.1f} concurrent={timed(conc):.1f} us")

    # CU-masked streams: routed tiles on CUs [0, n), shared tiles on the rest (contiguous
    # ranges: a strided mask measured as ignored).
    import ctypes
    hip = ctypes.CDLL("libamdhip64.so")
    ncu = torch.cuda.get_device_properties(0).multi_processor_count

    def masked(cus):
        words = (ctypes.c_uint32 * ((ncu + 31) // 32))()
        for cu in cus:
            words[cu // 32] |= 1 << (cu % 32)
        s = ctypes.c_void_p()
        assert hip.hipExtStreamCreateWithCUMask(ctypes.byref(s), len(words), words) == 0
        return torch.cuda.ExternalStream(s.value)

    for frac in (0.5, 0.625, 0.75, 0.875):
        ra = list(range(round(frac * ncu)))
        sa, sb = masked(ra), masked([cu for cu in range(ncu) if cu not in ra])

        def split():
            sa.wait_stream(main)
            sb.wait_stream(main)
            launch(r, b0, c0, sa)
            launch(r, b1, c1, sb)
            main.wait_stream(sa)
            main.wait_stream(sb)

        ta = timed(lambda: (sa.wait_stream(main), launch(r, b0, c0, sa), main.wait_stream(sa)))
        tb = timed(lambda: (sb.wait_stream(main), launch(r, b1, c1, sb), main.wait_stream(sb)))
        print(f"  rows on {len(ra)} CUs alone={ta:.1f}  fused on {ncu - len(ra)} CUs alone={tb:.1f}  "
              f"both concurrently={timed(split):.1f} us")
