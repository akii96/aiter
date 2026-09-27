"""Latency-floor decomposition for a small all-reduce at TP=2.
Measures: empty-kernel launch, IPC flag round-trip, peer-read latency,
then the QRInt4 fixed+marginal cost model."""
import os, time, statistics, math, json
import torch, torch.distributed as dist
from torch.utils.cpp_extension import load_inline

import os as _os
QR_OUT_DIR   = _os.environ.get("QR_OUT_DIR", _os.getcwd())
QR_BUILD_DIR = _os.environ.get("QR_BUILD_DIR", _os.path.join(QR_OUT_DIR, "build"))
_os.makedirs(QR_BUILD_DIR, exist_ok=True)


MB=1024*1024
rank=int(os.environ['RANK']); world=int(os.environ['WORLD_SIZE'])
local=int(os.environ.get('LOCAL_RANK',rank))
torch.cuda.set_device(local); dev=torch.device(f'cuda:{local}')
dist.init_process_group(backend='nccl',world_size=world,rank=rank,device_id=dev)
gloo=dist.new_group(backend='gloo')
def p(*a):
    if rank==0: print(*a,flush=True)

cpp_src=r'''
void empty_k(long grid,long block);
void spin_k(long flag_ptr,long target,long grid,long block);
void set_flag(long flag_ptr,long val);
void pingpong(long my_flag,long peer_flag,long iters,long rank_);
long enable_peer(long p);
'''
src=r'''
#include <torch/extension.h>
#include <hip/hip_runtime.h>
__global__ void empty_kk(){}
__global__ void set_flag_k(int* f,int v){ if(threadIdx.x==0) __atomic_store_n(f,v,__ATOMIC_RELEASE); }
// rank0: write my_flag=i, wait peer_flag==i.  rank1: wait my_flag... symmetric ping-pong
__global__ void pingpong_k(int* mine,int* peer,int iters,int rank_){
  if(threadIdx.x!=0||blockIdx.x!=0) return;
  for(int i=1;i<=iters;i++){
    if(rank_==0){
      __atomic_store_n(peer,i,__ATOMIC_RELEASE);
      while(__atomic_load_n(mine,__ATOMIC_ACQUIRE)<i){ __builtin_amdgcn_s_sleep(1); }
    } else {
      while(__atomic_load_n(mine,__ATOMIC_ACQUIRE)<i){ __builtin_amdgcn_s_sleep(1); }
      __atomic_store_n(peer,i,__ATOMIC_RELEASE);
    }
  }
}
void empty_k(long g,long b){ empty_kk<<<(int)g,(int)b>>>(); }
void spin_k(long f,long t,long g,long b){}
void set_flag(long f,long v){ set_flag_k<<<1,64>>>((int*)f,(int)v); }
void pingpong(long mine,long peer,long iters,long r){ pingpong_k<<<1,64>>>((int*)mine,(int*)peer,(int)iters,(int)r); }
long enable_peer(long p){ return (long)hipDeviceEnablePeerAccess((int)p,0); }
'''
mod=load_inline(name='floorx',cpp_sources=cpp_src,cuda_sources=src,
    functions=['empty_k','spin_k','set_flag','pingpong','enable_peer'],
    with_cuda=True,verbose=False,build_directory=QR_BUILD_DIR,
    extra_cuda_cflags=['-O3','--offload-arch=gfx950'])
mod.enable_peer(1-local if world==2 else (local+1)%world)

# ---- 1. empty kernel launch + sync floor ----
def batched(fn,B,rounds=9):
    for _ in range(5): fn()
    torch.cuda.synchronize(); ts=[]
    for _ in range(rounds):
        dist.barrier(); torch.cuda.synchronize()
        e0=torch.cuda.Event(enable_timing=True); e1=torch.cuda.Event(enable_timing=True)
        e0.record()
        for _ in range(B): fn()
        e1.record(); torch.cuda.synchronize()
        ts.append(e0.elapsed_time(e1)*1000.0/B)
    s=sorted(ts); return statistics.median(s), (s[-1]-s[0])/statistics.median(s)*100

p("\n=== 1. EMPTY KERNEL: device-side cost of just launching ===")
for g in [1,6,24,64,256,768,1024]:
    m,sp=batched(lambda: mod.empty_k(g,256), 500)
    p(f"   grid={g:5d} block=256 : {m:7.3f} us  (spread {sp:.2f}%)")

p("\n=== 2. HOST->DEVICE LAUNCH + SYNC round trip (what a python-side AR pays) ===")
ev0=torch.cuda.Event(enable_timing=True); ev1=torch.cuda.Event(enable_timing=True)
ts=[]
for _ in range(200):
    torch.cuda.synchronize(); t0=time.perf_counter()
    mod.empty_k(1,256); torch.cuda.synchronize()
    ts.append((time.perf_counter()-t0)*1e6)
p(f"   launch+sync wall: {statistics.median(ts):.2f} us")

# ---- 3. IPC flag ping-pong: the irreducible peer-visibility latency ----
p("\n=== 3. IPC FLAG PING-PONG (peer-to-peer release/acquire round trip) ===")
try:
    import sys; sys.path.insert(0,'/app/aiter')
    from aiter.ops.flydsl.quick_allreduce_int4_ipc import UncachedIpcHeap
    myptr = UncachedIpcHeap.alloc_uncached(4096)
    import ctypes
    UncachedIpcHeap.copy_host_to_device(myptr,(ctypes.c_int32*16)(*([0]*16)),64)
    h = UncachedIpcHeap.get_mem_handle_bytes(myptr)
    meta = UncachedIpcHeap.gather_object_list_via_broadcast(gloo,(h,0))
    peer_rank = 1-rank if world==2 else (rank+1)%world
    peer_base = int(UncachedIpcHeap.open_mem_handle(bytes(meta[peer_rank][0])))
    for N in [100,500,2000]:
        dist.barrier(); torch.cuda.synchronize()
        t0=time.perf_counter()
        mod.pingpong(myptr, peer_base, N, rank)
        torch.cuda.synchronize()
        dt=(time.perf_counter()-t0)*1e6
        p(f"   {N} round trips: {dt:.1f} us total => {dt/N:.3f} us per one-way peer flag visibility")
        # reset
        UncachedIpcHeap.copy_host_to_device(myptr,(ctypes.c_int32*16)(*([0]*16)),64)
        dist.barrier()
except Exception as e:
    p(f"   IPC pingpong FAILED: {type(e).__name__}: {str(e)[:200]}")

# ---- 4. QRInt4 fixed + marginal cost model ----
p("\n=== 4. QRInt4 COST MODEL: time vs num_tiles (TILE=32KiB) ===")
from aiter.ops.flydsl import QuickAllReduceInt4
res={}
for st in (1,8):
    o=QuickAllReduceInt4(group=gloo,device=dev,rank=rank,world_size=world,super_tile=st)
    ci=torch.zeros((512,6144),device=dev,dtype=torch.bfloat16); co=torch.empty_like(ci)
    dist.barrier(); o.compile(ci,co); dist.barrier(); del ci,co
    grid1 = o._by_st[1].grid
    p(f"\n  --- ST={st} (engine grids={{s:e.grid for s,e in o._by_st.items()}}) crossover at num_tiles>{grid1} = {grid1*32768/MB:.1f} MB ---")
    rows=[]
    for ntiles in [1,2,4,6,8,12,16,24,32,48,64,96,128,192,256,384,512,768,1024,1536,2048,3072]:
        nb=ntiles*32768
        ntok=nb//(6144*2)
        if ntok<1: continue
        nb=ntok*6144*2
        actual_tiles=math.ceil(nb/32768)
        inp=torch.randn((ntok,6144),device=dev,dtype=torch.bfloat16)/8
        out=torch.empty_like(inp)
        B=max(3,min(400,int(3000/max(0.03,nb/MB*0.3))))
        try:
            m,sp=batched(lambda: o.allreduce(inp,out), B, rounds=7)
        except Exception as e:
            p(f"    tiles={actual_tiles} FAILED {e}"); continue
        wgs=min(actual_tiles, o._by_st[o._pick_st(actual_tiles)].grid)
        picked=o._pick_st(actual_tiles)
        rows.append((actual_tiles,nb,m,sp,wgs,picked))
        p(f"    tiles={actual_tiles:6d} {nb/MB:9.3f}MB  WGs={wgs:5d}/{256} CUs({100*min(wgs,256)/256:5.1f}%)  ST_used={picked}  {m:9.3f}us spr={sp:5.2f}%  {nb/(m*1e-6)/1e9:7.1f}GB/s")
        del inp,out; torch.cuda.empty_cache()
    res[st]=rows
    # linear fit on the CU-starved region (wgs < 256)
    starved=[(t,m) for t,nb_,m,sp,wgs,pk in rows if wgs<=256]
    if len(starved)>=3:
        n=len(starved); sx=sum(t for t,_ in starved); sy=sum(m for _,m in starved)
        sxx=sum(t*t for t,_ in starved); sxy=sum(t*m for t,m in starved)
        slope=(n*sxy-sx*sy)/(n*sxx-sx*sx); icept=(sy-slope*sx)/n
        p(f"    >> CU-starved fit (tiles<=256): time = {icept:.3f}us + {slope:.4f}us/tile")
        p(f"    >> FIXED OVERHEAD = {icept:.3f} us; at 6 tiles (0.188MB) fixed is {100*icept/(icept+6*slope):.1f}% of total")
    o.close(); del o
if rank==0:
    json.dump({str(k):v for k,v in res.items()},open(f"{QR_OUT_DIR}/floor.json",'w'),indent=1)
dist.barrier(); dist.destroy_process_group()
