"""TP=8 DECODE-GATE TEST (the real question).

vLLM's _QR_MIN_SIZE[(fp16,8)][INT4] = 2 MB floor keeps HIP QuickReduce OFF for
MiniMax-M3's decode payload (64 tok x 6144 x 2B = 0.75 MB), so decode falls
through to the uncompressed aiter custom AR. Measure, at TP=8 and at the real
decode sizes, what each available path actually costs.
"""
import os,statistics,json,sys,math
import torch, torch.distributed as dist
MB=1024*1024
rank=int(os.environ['RANK']);world=int(os.environ['WORLD_SIZE'])
local=int(os.environ.get('LOCAL_RANK',rank))
torch.cuda.set_device(local);dev=torch.device(f'cuda:{local}')
dist.init_process_group(backend='nccl',world_size=world,rank=rank,device_id=dev)
gloo=dist.new_group(backend='gloo')
def p(*a):
    if rank==0: print(*a,flush=True)
runners={};
# FlyDSL QRInt4 ST=1 and ST=8
from aiter.ops.flydsl import QuickAllReduceInt4
flys={}
for st in (1,8):
    o=QuickAllReduceInt4(group=gloo,device=dev,rank=rank,world_size=world,super_tile=st)
    ci=torch.zeros((512,6144),device=dev,dtype=torch.bfloat16);co=torch.empty_like(ci)
    dist.barrier();o.compile(ci,co);dist.barrier();del ci,co
    flys[st]=o
p(f"# fly ST1 grid={flys[1]._by_st[1].grid} ST8 grids={{k:v.grid for k,v in flys[8]._by_st.items()}}")
# HIP QuickReduce, all regimes, cast on/off
from vllm import _custom_ops as ops
hip={}
for nm,rg in (('hip_int4',3),('hip_int6',2),('hip_int8',1),('hip_fp',0)):
    ptr=ops.init_custom_qr(rank,world,None);h=ops.qr_get_handle(ptr)
    hs=[None]*world;dist.all_gather_object(hs,h,group=gloo);ops.qr_open_handles(ptr,hs)
    hip[nm]=(ptr,rg)
ptr_nc=ops.init_custom_qr(rank,world,None);h=ops.qr_get_handle(ptr_nc)
hs=[None]*world;dist.all_gather_object(hs,h,group=gloo);ops.qr_open_handles(ptr_nc,hs)
from vllm.distributed.device_communicators.aiter_custom_all_reduce import AiterCustomAllreduce

import os as _os
QR_OUT_DIR   = _os.environ.get("QR_OUT_DIR", _os.getcwd())
QR_BUILD_DIR = _os.environ.get("QR_BUILD_DIR", _os.path.join(QR_OUT_DIR, "build"))
_os.makedirs(QR_BUILD_DIR, exist_ok=True)

ac=AiterCustomAllreduce(group=gloo,device=dev); assert not ac.disabled
def trim(ts):
    s=sorted(ts);k=len(s)//4
    s2=s[k:len(s)-k] if len(s)-2*k>=3 else s
    m=statistics.median(s2);return m,(s2[-1]-s2[0])/m*100
names=['aiter_ar(DECODE TODAY)','hip_int4','fly_st1','fly_st8','hip_int6','hip_int8','hip_fp','hip_int4_nocast','rccl']
p(f"\nTP={world}. Arms SERIAL + ROUND-ROBIN INTERLEAVED, batch-timed, trimmed median.")
p(f"{'payload':>9} " + " ".join(f"{n:>22}" for n in names))
rows=[]
for ntok in [16,32,64,128,171,256,341,512]:
    nb=ntok*6144*2
    inp=(torch.randn((ntok,6144),device=dev,dtype=torch.bfloat16)/8);out=torch.empty_like(inp)
    fns={
      'aiter_ar(DECODE TODAY)':lambda: ac.custom_all_reduce(inp),
      'hip_int4':lambda: ops.qr_all_reduce(hip['hip_int4'][0],inp,out,3,True),
      'fly_st1':lambda: flys[1].allreduce(inp,out),
      'fly_st8':lambda: flys[8].allreduce(inp,out),
      'hip_int6':lambda: ops.qr_all_reduce(hip['hip_int6'][0],inp,out,2,True),
      'hip_int8':lambda: ops.qr_all_reduce(hip['hip_int8'][0],inp,out,1,True),
      'hip_fp':lambda: ops.qr_all_reduce(hip['hip_fp'][0],inp,out,0,True),
      'hip_int4_nocast':lambda: ops.qr_all_reduce(ptr_nc,inp,out,3,False),
      'rccl':lambda: dist.all_reduce(out.copy_(inp)),
    }
    B=400
    for k in fns:
        for _ in range(15): fns[k]()
    torch.cuda.synchronize();dist.barrier()
    samp={k:[] for k in fns}
    for rd in range(13):
        for k in names:
            dist.barrier();torch.cuda.synchronize()
            e0=torch.cuda.Event(enable_timing=True);e1=torch.cuda.Event(enable_timing=True)
            e0.record()
            for _ in range(B): fns[k]()
            e1.record();torch.cuda.synchronize()
            samp[k].append(e0.elapsed_time(e1)*1000.0/B)
    r={};s={}
    for k in names: r[k],s[k]=trim(samp[k])
    # numerics
    ref=inp.to(torch.float32).clone();dist.all_reduce(ref)
    sq={}
    for k in names:
        o=fns[k]()
        g=(o if isinstance(o,torch.Tensor) else out).to(torch.float32)
        e=g-ref;mse=(e*e).mean().item();pw=(ref*ref).mean().item()
        sq[k]=10*math.log10(pw/mse) if mse>0 else 999.0
    p(f"{nb/MB:8.3f}M " + " ".join(f"{r[k]:9.2f}/{s[k]:4.1f}%/{sq[k]:5.1f}dB" for k in names))
    rows.append(dict(mb=nb/MB,tok=ntok,t={k:r[k] for k in names},spr={k:s[k] for k in names},sqnr=sq))
    del inp,out,ref;torch.cuda.empty_cache()
p("\n=== VERDICT AT DECODE PAYLOAD (0.75MB / 64 tok) ===")
for row in rows:
    if row['tok']==64:
        base=row['t']['aiter_ar(DECODE TODAY)']
        for k in names:
            p(f"   {k:24s} {row['t'][k]:8.2f}us  x{row['t'][k]/base:5.3f} vs today  spr={row['spr'][k]:4.1f}%  sqnr={row['sqnr'][k]:5.1f}dB")
if rank==0: json.dump(rows,open(f"{QR_OUT_DIR}/gate8.json",'w'),indent=1)
dist.barrier();dist.destroy_process_group()
