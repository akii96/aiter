"""Plan kernels (3-launch parallel plan) vs the frozen flymoe-v4 plan: bit-exact outputs.

Covers every tile-spec kind (plain BM, full-only -1, routed-only -2, shared-only -3, remainder
after P-row tiles), both shared_last settings, uniform and one-hot-skewed routing, and T from 1 to
32768, E from 2 to 256. Checks the expert offsets exactly (parallel path), ties every row to its
expert and its (token, slot) via inv, and compares every spec's tile list and tile count exactly.
Outputs are re-poisoned before the second call, so it cannot pass on the first call's results.

usage: python tests/test_plan.py   (needs /workspace/flymoe_v4_pkg or FLYMOE_V4_PATH)
"""
import importlib
import os
import sys

import torch

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, os.environ.get("FLYMOE_V4_PATH", "/workspace/flymoe_v4_pkg"))

from flymoe import prologue  # noqa: E402

old = importlib.import_module("flymoe_v4.prologue")

SPECS = [
    (256, 128),
    (128,),
    (256, (64, 256)),
    (128, (128, -1), (16, 128)),
    ((128, -2), (128, -3)),
    (16,),
]


def run(mod, ids, w, E, k, bms, shared_last):
    dev = ids.device
    R = ids.numel()
    mts = [mod.spec_max_tiles(b, R, E) for b in bms]
    MAXT = max(mts)
    out = dict(
        row_tok=torch.full((R,), -7, dtype=torch.int32, device=dev),
        row_w=torch.full((R,), -7.0, dtype=torch.float32, device=dev),
        inv=torch.full((R,), -7, dtype=torch.int32, device=dev),
        tiles=torch.full((len(bms) * MAXT, 4), -7, dtype=torch.int32, device=dev),
        ntiles=torch.full((len(bms),), -7, dtype=torch.int32, device=dev),
    )
    scratch = mod.plan_scratch(R, E, dev)
    for _ in range(2):  # second call checks the counters were re-zeroed
        for v in out.values():
            v.fill_(-7)
        mod.run_plan(ids, w, out["row_tok"], out["row_w"], out["inv"], out["tiles"], out["ntiles"],
                     E, k, bms, MAXT, scratch=scratch, shared_last=shared_last)
    torch.cuda.synchronize()
    out["offs"] = scratch[1].clone() if R > mod.SMALL_PLAN_MAX_ROWS else None
    nt = out["ntiles"].tolist()
    out["tiles_used"] = [out["tiles"][b * MAXT: b * MAXT + nt[b]].clone() for b in range(len(bms))]
    return out


def rows_equivalent(a, b, ids, w, E, k):
    """Row order inside an expert comes from LDS atomics (nondeterministic across waves), so
    rows are compared as a set per expert segment; inv must map each (token, slot) to a row of
    that slot's expert holding its token and weight, and the offsets must be the exact prefix sum."""
    cnt = torch.bincount(ids.long(), minlength=E)
    counts = cnt.tolist()
    seg = torch.repeat_interleave(torch.arange(E, device=ids.device, dtype=torch.int32), cnt)
    tok = torch.arange(ids.numel(), device=ids.device, dtype=torch.int32) // k
    for o in (a, b):
        iv = o["inv"].long()
        if not (torch.equal(o["row_tok"][iv], tok) and torch.equal(o["row_w"][iv], w) and torch.equal(seg[iv], ids)):
            return False
        if o["offs"] is not None and not torch.equal(o["offs"], (torch.cumsum(cnt, 0) - cnt).to(torch.int32)):
            return False
    s = 0
    for c in counts:
        ka = torch.sort(a["row_tok"][s:s + c])[0]
        kb = torch.sort(b["row_tok"][s:s + c])[0]
        if not torch.equal(ka, kb):
            return False
        s += c
    return True


def check_scale_t():
    """K-step-major scale transpose vs v4, bit-exact (random token map incl. repeats)."""
    ok = True
    for T, R in ((1, 5), (37, 185), (4097, 20485), (32768, 163840)):
        g = torch.Generator(device="cuda").manual_seed(R)
        a_s = torch.randint(0, 255, (T, 192), dtype=torch.uint8, device="cuda", generator=g)
        row_tok = torch.randint(0, T, (R,), dtype=torch.int32, device="cuda", generator=g)
        outs = []
        for mod in (prologue, old):
            o = torch.full((192 // 4, R, 4), 7, dtype=torch.uint8, device="cuda")
            mod.run_scale_t(a_s, row_tok, o)
            outs.append(o)
        torch.cuda.synchronize()
        if not torch.equal(outs[0], outs[1]):
            ok = False
            print(f"MISMATCH scale_t T={T} R={R}", flush=True)
    print(f"scale_t: {'OK' if ok else 'FAIL'}")
    return ok


def main():
    import argparse

    ap = argparse.ArgumentParser()
    ap.add_argument("--E", type=int, nargs="+", default=[129, 9, 256, 2], help="k: 129 -> 5, 256 -> 8, else 2")
    ap.add_argument("--T", type=int, nargs="+", default=[1, 5, 32, 300, 4097, 32768])
    ap.add_argument("--scale-t-only", action="store_true")
    a_ = ap.parse_args()
    ok = check_scale_t()
    if a_.scale_t_only:
        sys.exit(0 if ok else 1)
    n = 0
    for E, k in [(E, {129: 5, 256: 8}.get(E, 2)) for E in a_.E]:
        for T in a_.T:
            for skew in (False, True):
                g = torch.Generator(device="cuda").manual_seed(T * 7 + E)
                if skew:
                    routed = torch.zeros(T, k - 1, dtype=torch.int64, device="cuda")
                    routed[:, 1:] = torch.arange(1, k - 1, device="cuda")
                else:
                    routed = torch.rand(T, E - 1, device="cuda", generator=g).topk(k - 1, dim=-1).indices
                ids = torch.cat([routed, torch.full((T, 1), E - 1, device="cuda")], 1).to(torch.int32).reshape(-1)
                w = torch.rand(T * k, device="cuda", generator=g)
                for bms in SPECS:
                    for sl in (False, True):
                        a = run(prologue, ids, w, E, k, bms, sl)
                        b = run(old, ids, w, E, k, bms, sl)
                        bad = []
                        if not torch.equal(a["ntiles"], b["ntiles"]):
                            bad.append("ntiles")
                        if not all(torch.equal(x, y) for x, y in zip(a["tiles_used"], b["tiles_used"])):
                            bad.append("tiles")
                        if not rows_equivalent(a, b, ids, w, E, k):
                            bad.append("rows")
                        n += 1
                        if bad:
                            ok = False
                            print(f"MISMATCH {bad} E={E} k={k} T={T} skew={skew} bms={bms} shared_last={sl}",
                                  flush=True)
    print(f"{n} plan cases: {'OK' if ok else 'FAIL'}")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
