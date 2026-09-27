import torch, time, statistics, os
from torch.utils.cpp_extension import load_inline

import os as _os
QR_OUT_DIR   = _os.environ.get("QR_OUT_DIR", _os.getcwd())
QR_BUILD_DIR = _os.environ.get("QR_BUILD_DIR", _os.path.join(QR_OUT_DIR, "build"))
_os.makedirs(QR_BUILD_DIR, exist_ok=True)

cpp_src = r'''
void dual_read(long a_ptr, long b_ptr, long sink_ptr, long nbytes_each, long grid, long block);
void one_read(long a_ptr, long sink_ptr, long nbytes, long grid, long block);
long enable_peer(long dev, long peer);
'''
src = r'''
#include <torch/extension.h>
#include <hip/hip_runtime.h>
typedef int __attribute__((ext_vector_type(4))) i32x4;
// Half the blocks read peer A, half read peer B -> both links loaded by ONE kernel.
__global__ void dual_read_k(const i32x4* __restrict__ A, const i32x4* __restrict__ B,
                            i32x4* __restrict__ sink, long n) {
  long half = (long)gridDim.x / 2;
  const i32x4* src = (blockIdx.x < half) ? A : B;
  long bid = (blockIdx.x < half) ? (long)blockIdx.x : (long)blockIdx.x - half;
  long nb = half;
  long i = bid * blockDim.x + threadIdx.x;
  long stride = nb * blockDim.x;
  i32x4 acc = {0,0,0,0};
  for (long j = i; j < n; j += stride) { i32x4 v = src[j]; acc += v; }
  if (acc.x == 123456789) sink[0] = acc;
}
__global__ void one_read_k(const i32x4* __restrict__ A, i32x4* __restrict__ sink, long n) {
  long i = (long)blockIdx.x*blockDim.x + threadIdx.x;
  long stride = (long)gridDim.x*blockDim.x;
  i32x4 acc = {0,0,0,0};
  for (long j=i;j<n;j+=stride){ i32x4 v=A[j]; acc+=v; }
  if (acc.x==123456789) sink[0]=acc;
}
void dual_read(long a,long b,long s,long ne,long g,long bl){
  dual_read_k<<<(int)g,(int)bl>>>((const i32x4*)a,(const i32x4*)b,(i32x4*)s, ne/16);
}
void one_read(long a,long s,long nb,long g,long bl){
  one_read_k<<<(int)g,(int)bl>>>((const i32x4*)a,(i32x4*)s, nb/16);
}
long enable_peer(long d,long p){ return (long)hipDeviceEnablePeerAccess((int)p,0); }
'''
mod = load_inline(name='aggbw', cpp_sources=cpp_src, cuda_sources=src,
                  functions=['dual_read','one_read','enable_peer'], with_cuda=True,
                  verbose=False, build_directory=QR_BUILD_DIR,
                  extra_cuda_cflags=['-O3','--offload-arch=gfx950'])
n=torch.cuda.device_count()
for d in range(n):
    torch.cuda.set_device(d)
    for p in range(n):
        if p!=d: mod.enable_peer(d,p)
SZ=256*1024*1024
bufs={d: torch.empty(SZ,dtype=torch.uint8,device=f'cuda:{d}') for d in range(n)}
sink={d: torch.empty(4096,dtype=torch.uint8,device=f'cuda:{d}') for d in range(n)}
for d in range(n): bufs[d].fill_(1)
CU=torch.cuda.get_device_properties(0).multi_processor_count
def bench(fn,dev,iters=11):
    torch.cuda.set_device(dev)
    for _ in range(3): fn()
    torch.cuda.synchronize(dev); ts=[]
    for _ in range(iters):
        torch.cuda.synchronize(dev); t0=time.perf_counter(); fn(); torch.cuda.synchronize(dev)
        ts.append(time.perf_counter()-t0)
    return statistics.median(ts)
print("=== AGGREGATE INGRESS: ONE kernel on dev0 reading BOTH peers concurrently ===",flush=True)
print("  (if per-GPU ingress scales with links, dual should ~2x the single-link rate)",flush=True)
for gm in [1,2,4]:
    g=CU*gm
    t1=bench(lambda: mod.one_read(bufs[1].data_ptr(), sink[0].data_ptr(), SZ, g, 256), 0)
    EACH=SZ//2
    t2=bench(lambda: mod.dual_read(bufs[1].data_ptr(), bufs[2].data_ptr(), sink[0].data_ptr(), EACH, g, 256), 0)
    moved2=2*EACH
    print(f"  grid={g:5d}  single-link: {SZ/t1/1e9:7.1f} GB/s   |  dual-link aggregate: {moved2/t2/1e9:7.1f} GB/s  (per link {moved2/2/t2/1e9:6.1f})",flush=True)
print("\n=== same, larger per-link payload ===",flush=True)
g=CU*2
t2=bench(lambda: mod.dual_read(bufs[1].data_ptr(), bufs[2].data_ptr(), sink[0].data_ptr(), SZ, g, 256), 0)
print(f"  dual 256MB each = 512MB ingress: {2*SZ/t2/1e9:7.1f} GB/s aggregate",flush=True)
