import sys; sys.path.insert(0,'.')
from bench.bench_moe import bench
for T in (4096, 32768):
    for D1 in (3,4,6):
        t1,_,_ = bench(T,384,D1=D1,D2=3,quiet=True)
        print(f"s1 T={T} async D={D1}: {t1:.1f}us", flush=True)
    for pipe,D2 in (("async",2),("async",4),("regs",3),("regs",2)):
        _,t2,_ = bench(T,384,D1=4,D2=D2,pipe=pipe,quiet=True)
        print(f"s2 T={T} {pipe} D={D2}: {t2:.1f}us", flush=True)
