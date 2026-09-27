"""Small-payload all-reduce: minimal one-shot vs QRInt4 vs aiter custom AR.

WIRE MATH (per rank, per link):
  one-shot: rank pushes full N to each of P-1 peers -> per-link N ; egress N*(P-1)
  two-shot: reduce-scatter N/P + all-gather N/P     -> per-link 2N/P ; egress 2N(P-1)/P
  per-link ratio one-shot:two-shot = P/2  (equal at TP=2, 4x at TP=8)
So a TP=2 one-shot win must be re-measured at higher TP before extrapolating.

SAFETY: grid <= CU so every spinning block is co-resident (non-resident blocks
can never publish their flag -> deadlock; this is why aiter clamps grid).
Flag region is a FIXED size independent of grid, so a small-grid run's inbox
cannot alias a later large-grid run's flags.
"""
import os,statistics,ctypes,json,sys,importlib.util
import torch, torch.distributed as dist
MB=1024*1024
rank=int(os.environ['RANK']);world=int(os.environ['WORLD_SIZE'])
local=int(os.environ.get('LOCAL_RANK',rank))
torch.cuda.set_device(local);dev=torch.device(f'cuda:{local}')
dist.init_process_group(backend='nccl',world_size=world,rank=rank,device_id=dev)
gloo=dist.new_group(backend='gloo')
def p(*a):
    if rank==0: print(*a,flush=True)
spec=importlib.util.spec_from_file_location("k2mod",f"{QR_BUILD_DIR}/k2mod.so")
mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
for z in range(world):
    if z!=local:
        try: mod.enable_peer(z)
        except Exception: pass
sys.path.insert(0,'/app/aiter')
from aiter.ops.flydsl.quick_allreduce_int4_ipc import UncachedIpcHeap
from aiter.ops.flydsl import QuickAllReduceInt4

import os as _os
QR_OUT_DIR   = _os.environ.get("QR_OUT_DIR", _os.getcwd())
QR_BUILD_DIR = _os.environ.get("QR_BUILD_DIR", _os.path.join(QR_OUT_DIR, "build"))
_os.makedirs(QR_BUILD_DIR, exist_ok=True)

CU=torch.cuda.get_device_properties(local).multi_processor_count
GRID=CU
FIXED_FB=1024*8*4
MAXSLICE=4*MB//64+8192
BUF=FIXED_FB+GRID*world*MAXSLICE+32*MB
buf=UncachedIpcHeap.alloc_uncached(BUF)
UncachedIpcHeap.copy_host_to_device(buf,(ctypes.c_int32*(FIXED_FB//4))(*([0]*(FIXED_FB//4))),FIXED_FB)
h=UncachedIpcHeap.get_mem_handle_bytes(buf)
meta=UncachedIpcHeap.gather_object_list_via_broadcast(gloo,(h,0))
pp=[buf if r_==rank else int(UncachedIpcHeap.open_mem_handle(bytes(meta[r_][0]))) for r_ in range(world)]
ptab=UncachedIpcHeap.alloc_uncached(world*8)
UncachedIpcHeap.copy_host_to_device(ptab,(ctypes.c_int64*world)(*pp),world*8)
p(f"# TP={world} CU={CU} GRID={GRID} buf={BUF/MB:.0f}MB")
fly=QuickAllReduceInt4(group=gloo,device=dev,rank=rank,world_size=world,super_tile=1)
ci=torch.zeros((512,6144),device=dev,dtype=torch.bfloat16);co=torch.empty_like(ci)
dist.barrier();fly.compile(ci,co);dist.barrier();del ci,co
try:
    from vllm.distributed.device_communicators.aiter_custom_all_reduce import AiterCustomAllreduce
    ac=AiterCustomAllreduce(group=gloo,device=dev); assert not ac.disabled
except Exception as e:
    ac=None;p(f"# aiter unavailable {str(e)[:80]}")
col=[1]
def trim(ts):
    s=sorted(ts);k=len(s)//4
    s2=s[k:len(s)-k] if len(s)-2*k>=3 else s
    m=statistics.median(s2);return m,(s2[-1]-s2[0])/m*100
def geom(nb):
    g=min(GRID,max(1,nb//4096));sb=((nb+g-1)//g+15)//16*16
    g=int((nb+sb-1)//sb)
    if g>GRID: g=GRID;sb=((nb+g-1)//g+15)//16*16
    return g,sb
p(f"\n{'payload':>9} {'grid':>5} {'CU%':>6} | {'1shot':>9}{'spr':>6} | {'QRInt4':>9}{'spr':>6} | {'aiter':>9}{'spr':>6} | {'QR/1s':>6}")
rows=[]
for smb in [0.047,0.094,0.188,0.375,0.750,1.500,3.000]:
    nb=int(smb*MB)//16*16;ntok=max(1,nb//(6144*2));nb=ntok*6144*2
    g,sb=geom(nb)
    inp=(torch.randn(nb//2,device=dev,dtype=torch.bfloat16)/8);out=torch.empty_like(inp)
    i2=inp.view(ntok,6144);o2=out.view(ntok,6144)
    def one():
        col[0]+=1
        if col[0]>900_000_000: col[0]=1
        mod.oneshot(inp.data_ptr(),out.data_ptr(),ptab,buf,nb,rank,world,sb,col[0],g,0,1)
    fns={'1shot':one,'qr':lambda: fly.allreduce(i2,o2)}
    if ac is not None: fns['aiter']=lambda: ac.custom_all_reduce(i2)
    B=500
    for k in fns:
        for _ in range(20): fns[k]()
    torch.cuda.synchronize();dist.barrier()
    samp={k:[] for k in fns}
    for rd in range(15):
        for k in fns:
            dist.barrier();torch.cuda.synchronize()
            e0=torch.cuda.Event(enable_timing=True);e1=torch.cuda.Event(enable_timing=True)
            e0.record()
            for _ in range(B): fns[k]()
            e1.record();torch.cuda.synchronize()
            samp[k].append(e0.elapsed_time(e1)*1000.0/B)
    r={};s={}
    for k in fns: r[k],s[k]=trim(samp[k])
    at=r.get('aiter',float('nan'));ast=s.get('aiter',0.0)
    p(f"{nb/MB:8.3f}M {g:5d} {100*g/CU:5.1f}% | {r['1shot']:9.3f}{s['1shot']:6.2f} | {r['qr']:9.3f}{s['qr']:6.2f} | {at:9.3f}{ast:6.2f} | {r['qr']/r['1shot']:6.3f}")
    rows.append(dict(mb=nb/MB,tp=world,grid=g,oneshot=r['1shot'],qr=r['qr'],aiter=at,
                     spr1=s['1shot'],sprqr=s['qr'],spra=ast))
    del inp,out;torch.cuda.empty_cache()
p("\n=== CORRECTNESS: 2000 iters, sizes cycled back-to-back, vs fp32 ref ===")
bad=0;worst=0.0
szs=[0.047,0.094,0.188,0.375,0.750,1.500,3.000]
for it in range(2000):
    smb=szs[it%len(szs)]
    nb=int(smb*MB)//16*16;ntok=max(1,nb//(6144*2));nb=ntok*6144*2
    g,sb=geom(nb)
    inp=(torch.randn(nb//2,device=dev,dtype=torch.bfloat16)/8);out=torch.zeros_like(inp)
    ref=inp.to(torch.float32).clone();dist.all_reduce(ref)
    col[0]+=1
    mod.oneshot(inp.data_ptr(),out.data_ptr(),ptab,buf,nb,rank,world,sb,col[0],g,0,1)
    torch.cuda.synchronize()
    rel=(out.to(torch.float32)-ref).abs().max().item()/(ref.abs().max().item()+1e-9)
    worst=max(worst,rel)
    if rel>0.02: bad+=1
    del inp,out,ref
    if it%400==0: p(f"   it {it}: worst={worst:.3e} bad={bad}")
p(f"   FINAL TP={world}: 2000 iters bad={bad} worst_rel={worst:.3e}")
if rank==0: json.dump(rows,open(f"{QR_OUT_DIR}/tps{world}.json",'w'),indent=1)
dist.barrier();dist.destroy_process_group()
