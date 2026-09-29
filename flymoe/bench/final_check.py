import sys; import os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from bench.bench_moe import bench
cases = [
    (32, 384, dict(BM1=16, NW1=1, pipe1="async", D1=4, BM2=16, NW2=1, pipe2="async", D2=2)),
    (4096, 384, dict(BM1=128, NW1=4, pipe1="hybrid", D1=4, BM2=64, NW2=4, pipe2="regs", D2=2)),
    (32768, 384, dict(BM1=128, NW1=4, pipe1="hybrid", D1=3, BM2=128, NW2=4, pipe2="regs", D2=2)),
    (16384, 1536, dict(BM1=128, NW1=4, pipe1="hybrid", D1=3, BM2=128, NW2=4, pipe2="async", D2=2)),
    (32768, 1536, dict(BM1=128, NW1=4, pipe1="hybrid", D1=3, BM2=128, NW2=4, pipe2="async", D2=2)),
]
for T, I, c in cases:
    bench(T, I, **c)
