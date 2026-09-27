import torch, time, statistics, os
os.environ['PYTORCH_ROCM_ARCH']='gfx950'
from torch.utils.cpp_extension import load_inline

import os as _os
QR_OUT_DIR   = _os.environ.get("QR_OUT_DIR", _os.getcwd())
QR_BUILD_DIR = _os.environ.get("QR_BUILD_DIR", _os.path.join(QR_OUT_DIR, "build"))
_os.makedirs(QR_BUILD_DIR, exist_ok=True)


cpp_src = r'''
void peer_read(long src_ptr, long sink_ptr, long nbytes, long grid, long block);
void peer_write(long dst_ptr, long nbytes, long grid, long block, bool nt);
long enable_peer(long dev, long peer);
'''

src = r'''
#include <torch/extension.h>
#include <hip/hip_runtime.h>
typedef int __attribute__((ext_vector_type(4))) i32x4;

__global__ void peer_read_k(const i32x4* __restrict__ src, i32x4* __restrict__ sink, long n) {
  long i = (long)blockIdx.x * blockDim.x + threadIdx.x;
  long stride = (long)gridDim.x * blockDim.x;
  i32x4 acc = {0,0,0,0};
  for (long j = i; j < n; j += stride) { i32x4 v = src[j]; acc += v; }
  if (acc.x == 123456789) sink[0] = acc;
}
__global__ void peer_write_k(i32x4* __restrict__ dst, long n) {
  long i = (long)blockIdx.x * blockDim.x + threadIdx.x;
  long stride = (long)gridDim.x * blockDim.x;
  i32x4 v = {1,2,3,4};
  for (long j = i; j < n; j += stride) dst[j] = v;
}
__global__ void peer_write_nt_k(i32x4* __restrict__ dst, long n) {
  long i = (long)blockIdx.x * blockDim.x + threadIdx.x;
  long stride = (long)gridDim.x * blockDim.x;
  i32x4 v = {1,2,3,4};
  for (long j = i; j < n; j += stride) __builtin_nontemporal_store(v, &dst[j]);
}
void peer_read(long src_ptr, long sink_ptr, long nbytes, long grid, long block) {
  peer_read_k<<<(int)grid,(int)block>>>((const i32x4*)src_ptr,(i32x4*)sink_ptr, nbytes/16);
}
void peer_write(long dst_ptr, long nbytes, long grid, long block, bool nt) {
  if (nt) peer_write_nt_k<<<(int)grid,(int)block>>>((i32x4*)dst_ptr, nbytes/16);
  else    peer_write_k<<<(int)grid,(int)block>>>((i32x4*)dst_ptr, nbytes/16);
}
long enable_peer(long dev, long peer) { return (long)hipDeviceEnablePeerAccess((int)peer, 0); }
'''
mod = load_inline(name='peerbw2', cpp_sources=cpp_src, cuda_sources=src,
                  functions=['peer_read','peer_write','enable_peer'],
                  with_cuda=True, verbose=False,
                  build_directory=QR_BUILD_DIR,
                  extra_cuda_cflags=['-O3','--offload-arch=gfx950'])

n = torch.cuda.device_count()
print("devices:", n, flush=True)
for d in range(n):
    torch.cuda.set_device(d)
    for pp in range(n):
        if pp!=d: mod.enable_peer(d,pp)

SZ = 256*1024*1024
bufs = {d: torch.empty(SZ, dtype=torch.uint8, device=f'cuda:{d}') for d in range(n)}
sink = {d: torch.empty(4096, dtype=torch.uint8, device=f'cuda:{d}') for d in range(n)}
for d in range(n): bufs[d].fill_(1)
CU = torch.cuda.get_device_properties(0).multi_processor_count

def bench(fn, dev, iters=11):
    torch.cuda.set_device(dev)
    for _ in range(3): fn()
    torch.cuda.synchronize(dev)
    ts=[]
    for _ in range(iters):
        torch.cuda.synchronize(dev)
        t0=time.perf_counter(); fn(); torch.cuda.synchronize(dev)
        ts.append(time.perf_counter()-t0)
    return statistics.median(ts)

print("\n=== KERNEL PEER READ (256MB) : GPU d pulls from GPU p ===", flush=True)
best_uni=0
for gm in [1,2,4,8]:
    g=CU*gm
    for (d,pp) in [(0,1),(0,2),(1,2)]:
        t=bench(lambda: mod.peer_read(bufs[pp].data_ptr(), sink[d].data_ptr(), SZ, g, 256), d)
        bw=SZ/t/1e9; best_uni=max(best_uni,bw)
        print(f"  grid={g:5d} dev{d}<-dev{pp}: {bw:8.1f} GB/s", flush=True)
print(f"  BEST unidirectional kernel read: {best_uni:.1f} GB/s", flush=True)

print("\n=== KERNEL PEER WRITE (256MB) ===", flush=True)
best_w=0
for nt in [False,True]:
    for gm in [2,4]:
        g=CU*gm
        t=bench(lambda: mod.peer_write(bufs[1].data_ptr(), SZ, g, 256, nt), 0)
        bw=SZ/t/1e9; best_w=max(best_w,bw)
        print(f"  nt={int(nt)} grid={g:5d} dev0->dev1: {bw:8.1f} GB/s", flush=True)
print(f"  BEST write: {best_w:.1f} GB/s", flush=True)

print("\n=== LOCAL HBM read ===", flush=True)
for gm in [2,4]:
    g=CU*gm
    t=bench(lambda: mod.peer_read(bufs[0].data_ptr(), sink[0].data_ptr(), SZ, g, 256), 0)
    print(f"  grid={g}: {SZ/t/1e9:8.1f} GB/s", flush=True)

print("\n=== CONCURRENT: each GPU pulls from both others at once (what an AR does) ===", flush=True)
streams={d:[torch.cuda.Stream(device=d) for _ in range(n)] for d in range(n)}
for gm in [1,2,4]:
    g=CU*gm
    CH=SZ//2
    ts=[]
    for it in range(13):
        for d in range(n): torch.cuda.synchronize(d)
        t0=time.perf_counter()
        for d in range(n):
            torch.cuda.set_device(d); k=0
            for pp in range(n):
                if pp==d: continue
                with torch.cuda.stream(streams[d][k]):
                    mod.peer_read(bufs[pp].data_ptr()+k*CH, sink[d].data_ptr(), CH, g, 256)
                k+=1
        for d in range(n): torch.cuda.synchronize(d)
        if it>=3: ts.append(time.perf_counter()-t0)
    t=statistics.median(ts); moved=n*(n-1)*CH
    print(f"  grid={g:5d}: {moved/2**20:.0f}MB in {t*1e6:8.1f}us => {moved/t/1e9:7.1f} GB/s aggregate, {moved/t/1e9/n:6.1f} GB/s per-GPU ingress", flush=True)
