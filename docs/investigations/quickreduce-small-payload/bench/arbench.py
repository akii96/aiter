"""All-reduce arm comparison. SERIAL, ROUND-ROBIN INTERLEAVED, batched steady-state."""
import os, sys, time, json, statistics, argparse, math
import torch
import torch.distributed as dist

import os as _os
QR_OUT_DIR   = _os.environ.get("QR_OUT_DIR", _os.getcwd())
QR_BUILD_DIR = _os.environ.get("QR_BUILD_DIR", _os.path.join(QR_OUT_DIR, "build"))
_os.makedirs(QR_BUILD_DIR, exist_ok=True)


MB = 1024*1024
def p(*a):
    if int(os.environ.get('RANK','0'))==0: print(*a, flush=True)

def build(args, rank, world, dev, gloo):
    runners = {}; info = {}
    arms = args.arms.split(',')
    for st in (8,1):
        key=f'fly{st}'
        if key not in arms: continue
        try:
            from aiter.ops.flydsl import QuickAllReduceInt4
            kw=dict(group=gloo,device=dev,rank=rank,world_size=world,super_tile=st)
            if args.grid_cap>0: kw['grid_cap']=args.grid_cap
            o=QuickAllReduceInt4(**kw)
            ci=torch.zeros((512,args.hidden),device=dev,dtype=torch.bfloat16); co=torch.empty_like(ci)
            dist.barrier(); o.compile(ci,co); dist.barrier(); del ci,co
            runners[key]=(lambda oo:(lambda i,o_: oo.allreduce(i,o_)))(o)
            info[key]=dict(grids={s:e.grid for s,e in o._by_st.items()}, tile_bytes=o.tile_bytes,
                           buf_mb=round(o.buf_bytes/MB,1), wire_tile=o.wire_tile_bytes)
            p(f"# {key}: {info[key]}")
        except Exception as e:
            p(f"# {key} FAILED: {type(e).__name__}: {str(e)[:200]}")
    qrmap={'hipqr_int4':3,'hipqr_int6':2,'hipqr_int8':1,'hipqr_fp':0}
    for nm,rg in qrmap.items():
        if nm not in arms: continue
        try:
            from vllm import _custom_ops as ops
            ptr=ops.init_custom_qr(rank,world,None); h=ops.qr_get_handle(ptr)
            hs=[None]*world; dist.all_gather_object(hs,h,group=gloo); ops.qr_open_handles(ptr,hs)
            runners[nm]=(lambda _p,_r:(lambda i,o_: ops.qr_all_reduce(_p,i,o_,_r,True)))(ptr,rg)
            p(f"# {nm} ready (regime={rg}, cast_bf16_to_fp16=True)")
        except Exception as e: p(f"# {nm} FAILED: {type(e).__name__}: {str(e)[:150]}")
    if 'hipqr_int4_nocast' in arms:
        try:
            from vllm import _custom_ops as ops
            ptr=ops.init_custom_qr(rank,world,None); h=ops.qr_get_handle(ptr)
            hs=[None]*world; dist.all_gather_object(hs,h,group=gloo); ops.qr_open_handles(ptr,hs)
            runners['hipqr_int4_nocast']=(lambda _p:(lambda i,o_: ops.qr_all_reduce(_p,i,o_,3,False)))(ptr)
            p("# hipqr_int4_nocast ready (cast=False)")
        except Exception as e: p(f"# nocast FAILED: {e}")
    if 'aiter_ar' in arms:
        try:
            from vllm.distributed.device_communicators.aiter_custom_all_reduce import AiterCustomAllreduce
            ac=AiterCustomAllreduce(group=gloo,device=dev)
            assert not ac.disabled
            runners['aiter_ar']=(lambda a:(lambda i,o_: o_.copy_(a.custom_all_reduce(i))))(ac)
            p("# aiter_ar ready (uncompressed bf16, cross_device_reduce_2stage)")
        except Exception as e: p(f"# aiter_ar FAILED: {type(e).__name__}: {str(e)[:150]}")
    if 'vllm_ca' in arms:
        try:
            from vllm.distributed.device_communicators.custom_all_reduce import CustomAllreduce
            ca=CustomAllreduce(group=gloo,device=dev)
            assert not ca.disabled
            runners['vllm_ca']=(lambda a:(lambda i,o_: o_.copy_(a.custom_all_reduce(i))))(ca)
            p(f"# vllm_ca ready max_size={ca.max_size}")
        except Exception as e: p(f"# vllm_ca FAILED: {type(e).__name__}: {str(e)[:150]}")
    if 'rccl' in arms:
        def rccl(i,o_):
            o_.copy_(i); dist.all_reduce(o_)
        runners['rccl']=rccl; p("# rccl ready")
    return runners, [a for a in arms if a in runners]

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--sizes-mb',type=str,required=True)
    ap.add_argument('--hidden',type=int,default=6144)
    ap.add_argument('--rounds',type=int,default=9)
    ap.add_argument('--batch',type=int,default=0, help='reps per timed batch; 0=auto')
    ap.add_argument('--arms',type=str,default='fly8,fly1,hipqr_int4,aiter_ar,rccl')
    ap.add_argument('--grid-cap',type=int,default=0)
    ap.add_argument('--out',type=str,default=f"{QR_OUT_DIR}/res.json")
    ap.add_argument('--numerics',type=int,default=1)
    args=ap.parse_args()

    rank=int(os.environ['RANK']); world=int(os.environ['WORLD_SIZE'])
    local=int(os.environ.get('LOCAL_RANK',rank))
    torch.cuda.set_device(local); dev=torch.device(f'cuda:{local}')
    dist.init_process_group(backend='nccl',world_size=world,rank=rank,device_id=dev)
    gloo=dist.new_group(backend='gloo')
    pr=torch.cuda.get_device_properties(local)
    p(f"# arch={pr.gcnArchName} CUs={pr.multi_processor_count} world={world} hidden={args.hidden}")

    runners, active = build(args, rank, world, dev, gloo)
    p(f"# ACTIVE: {active}")
    if not active: return

    shapes=[]
    for smb in [float(x) for x in args.sizes_mb.split(',')]:
        nb=int(smb*MB); ntok=max(1,round(nb/(args.hidden*2)))
        shapes.append((ntok,args.hidden,ntok*args.hidden*2))

    results={}
    for (ntok,hid,nbytes) in shapes:
        key=f"{nbytes/MB:.3f}MB"
        inp=(torch.randn((ntok,hid),device=dev,dtype=torch.bfloat16)/8)
        out=torch.empty_like(inp)
        # auto batch: aim ~2ms per timed batch to swamp launch/event noise
        if args.batch>0: B=args.batch
        else: B=max(1, min(200, int(2000.0/max(0.02, nbytes/MB*0.35))))
        live=[]
        for a in active:
            try:
                for _ in range(5): runners[a](inp,out)
                torch.cuda.synchronize(); dist.barrier(); live.append(a)
            except Exception as e:
                p(f"#   {key} {a} SKIP: {type(e).__name__}: {str(e)[:120]}")
        samples={a:[] for a in live}
        # ROUND-ROBIN INTERLEAVED, one batch per arm per round
        for rd in range(args.rounds):
            for a in live:
                dist.barrier(); torch.cuda.synchronize()
                e0=torch.cuda.Event(enable_timing=True); e1=torch.cuda.Event(enable_timing=True)
                e0.record()
                for _ in range(B): runners[a](inp,out)
                e1.record(); torch.cuda.synchronize()
                samples[a].append(e0.elapsed_time(e1)*1000.0/B)
        row={}
        for a in live:
            s=sorted(samples[a]); med=statistics.median(s)
            row[a]=dict(median_us=round(med,3), min=round(s[0],3), max=round(s[-1],3),
                        spread_pct=round((s[-1]-s[0])/med*100,2), n=len(s), batch=B)
        if args.numerics:
            ref=inp.to(torch.float32).clone(); dist.all_reduce(ref)
            for a in live:
                runners[a](inp,out); torch.cuda.synchronize()
                g=out.to(torch.float32); err=g-ref
                mse=(err*err).mean().item(); pw=(ref*ref).mean().item()
                row[a]['sqnr_db']=round(10*math.log10(pw/mse),2) if mse>0 else 999
                row[a]['rel_mae']=round((err.abs().mean()/(ref.abs().mean()+1e-12)).item(),5)
                row[a]['max_abs_err']=round(err.abs().max().item(),4)
            del ref
        results[key]=dict(nbytes=nbytes,tokens=ntok,hidden=hid,batch=B,arms=row)
        if rank==0:
            base=min(row[a]['median_us'] for a in live)
            p(f"\n## {key}  ({ntok} tok x {hid})  batch={B}")
            for a in sorted(live,key=lambda x:row[x]['median_us']):
                r=row[a]; bw=nbytes/(r['median_us']*1e-6)/1e9
                flag='' if r['spread_pct']<3 else ('  <<SPREAD>>' if r['spread_pct']>8 else '  <spread>')
                p(f"   {a:20s} {r['median_us']:9.2f}us  x{r['median_us']/base:5.2f}  spr={r['spread_pct']:5.2f}%  algoBW={bw:7.1f}GB/s  sqnr={r.get('sqnr_db')}dB{flag}")
        del inp,out; torch.cuda.empty_cache()
    if rank==0:
        with open(args.out,'w') as f: json.dump(results,f,indent=1)
        p(f"\n# wrote {args.out}")
    dist.barrier(); dist.destroy_process_group()
main()
