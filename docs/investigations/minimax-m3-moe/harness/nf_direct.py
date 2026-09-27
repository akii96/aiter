"""Direct serial prefill-MoE measurement at the SERVED MiniMax-M3 shape.

Drives production fused_moe (a4w4 MXFP4 + Swiglu) and uses aiter's own
kernel_bench_callable hook to time stage1 / stage2 kernels in isolation.
Arms are ROUND-ROBIN INTERLEAVED across M; medians of >=5. ONE GPU, serial.
"""
import os, json, statistics
import torch
import aiter
from aiter import ActivationType, QuantType, dtypes
from aiter.fused_moe import fused_moe, fused_topk
from aiter.test_common import run_perftest

MD, E, TOPK = 6144, 129, 5
ID    = int(os.environ.get("NF_ID", "384"))
MS    = [int(x) for x in os.environ.get("NF_MS", "4096,8192,16384").split(",")]
ROUNDS= int(os.environ.get("NF_ROUNDS", "5"))
ROOF  = float(os.environ.get("NF_ROOF", "9551.0"))   # measured scaled-MXFP4 MFMA TFLOP/s

torch.manual_seed(0)

def build(M):
    inp = torch.randn((M, MD), dtype=dtypes.bf16, device="cuda")
    w1  = (torch.randn((E, ID*2, MD), dtype=dtypes.bf16, device="cuda")*0.02)
    w2  = (torch.randn((E, MD, ID),  dtype=dtypes.bf16, device="cuda")*0.02)
    score = torch.randn((M, E), dtype=dtypes.bf16, device="cuda")
    tw, tid = fused_topk(inp, score, TOPK, True)
    tq = aiter.get_torch_quant(QuantType.per_1x32)
    w1q, w1s = tq(w1, quant_dtype=dtypes.fp4x2)
    w2q, w2s = tq(w2, quant_dtype=dtypes.fp4x2)
    del w1, w2
    return dict(
        M=M, inp=inp, tw=tw, tid=tid,
        w1q=w1q.view(E, ID*2, MD//2), w2q=w2q.view(E, MD, ID//2),
        w1s=w1s.view(E, ID*2, MD//32), w2s=w2s.view(E, MD, ID//32),
    )

def capture(d):
    """One eager call populating the per-stage launch callables."""
    cb = []
    aiter.fused_moe.kernel_bench_callable = cb
    try:
        fused_moe(d["inp"], d["w1q"], d["w2q"], d["tw"], d["tid"],
                  quant_type=QuantType.per_1x32,
                  w1_scale=d["w1s"], w2_scale=d["w2s"],
                  activation=ActivationType.Swiglu,
                  doweight_stage1=False, swiglu_limit=7.0)
    finally:
        aiter.fused_moe.kernel_bench_callable = None
    return dict(cb)

def main():
    print(f"dev={torch.cuda.get_device_name(0)} HIP_VISIBLE_DEVICES={os.environ.get('HIP_VISIBLE_DEVICES')}")
    print(f"shape model_dim={MD} inter_dim={ID} E={E} topk={TOPK} Swiglu per_1x32 a4w4")
    print(f"compute roof = {ROOF} TFLOP/s (measured scaled MXFP4 MFMA)\n")
    stages, res = {}, {}
    for M in MS:
        try:
            d = build(M)
            stages[M] = capture(d)
            res[M] = {"d": d}
            print(f"[M={M}] captured: {list(stages[M])}")
        except Exception as ex:
            print(f"[M={M}] FAILED {type(ex).__name__}: {ex}")
    torch.cuda.synchronize()
    samples = {M: {k: [] for k in stages[M]} for M in stages}
    # ROUND-ROBIN INTERLEAVED across M and stage
    for r in range(ROUNDS):
        for M in stages:
            for name, call in stages[M].items():
                _, us = run_perftest(call, num_iters=20, num_warmup=3)
                samples[M][name].append(us)
    print(f"\n{'M':>7} {'us1':>9} {'us2':>9} {'tot':>9} {'TF1':>8} {'%r1':>7} {'TFtot':>8} {'%roof':>7}")
    out = {}
    for M in sorted(samples):
        s1 = statistics.median(samples[M].get("stage1", [float('nan')]))
        s2 = statistics.median(samples[M].get("stage2", [float('nan')]))
        tot = s1 + s2
        f1  = 4.0*M*TOPK*MD*ID; ft = 6.0*M*TOPK*MD*ID
        t1  = f1/(s1*1e-6)/1e12; tt = ft/(tot*1e-6)/1e12
        out[M] = dict(us1=s1, us2=s2, tot=tot, tf1=t1, tf_tot=tt,
                      pct1=100*t1/ROOF, pct=100*tt/ROOF,
                      raw={k: sorted(v) for k, v in samples[M].items()})
        print(f"{M:>7} {s1:>9.2f} {s2:>9.2f} {tot:>9.2f} {t1:>8.0f} {100*t1/ROOF:>6.1f}% {tt:>8.0f} {100*tt/ROOF:>6.1f}%")
    json.dump(out, open("/tmp/nf_direct.json","w"), indent=1)
    print("\nwrote /tmp/nf_direct.json")

main()
