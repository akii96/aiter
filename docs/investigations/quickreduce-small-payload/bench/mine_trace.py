import gzip, json, sys, os, collections

path = sys.argv[1]; out = sys.argv[2]
print("opening", path, flush=True)
with gzip.open(path, 'rt') as f:
    data = json.load(f)
ev = data.get('traceEvents', [])
print("events:", len(ev), flush=True)

kernels = []
cpuops = {}     # External id -> list of cpu op records
allk = collections.defaultdict(lambda: [0.0, 0])
gpu_span_min = None; gpu_span_max = None

for e in ev:
    cat = e.get('cat')
    args = e.get('args') or {}
    if cat == 'kernel':
        name = e.get('name',''); dur = e.get('dur',0) or 0; ts = e.get('ts',0)
        allk[name][0] += dur; allk[name][1] += 1
        if gpu_span_min is None or ts < gpu_span_min: gpu_span_min = ts
        if gpu_span_max is None or ts+dur > gpu_span_max: gpu_span_max = ts+dur
        kernels.append((name, ts, dur, args.get('External id'), args.get('grid'), args.get('block'), args.get('stream')))
    elif cat in ('cpu_op','user_annotation'):
        eid = args.get('External id')
        if eid is None: continue
        rec = (e.get('name',''), args.get('Input Dims'), args.get('Input type'), args.get('Concrete Inputs'), e.get('ts',0), e.get('dur',0))
        cpuops.setdefault(eid, []).append(rec)

print("kernels:", len(kernels), "cpuop-eids:", len(cpuops), flush=True)

res = {}
res['file'] = os.path.basename(path)
res['n_events'] = len(ev)
res['gpu_span_us'] = (gpu_span_max - gpu_span_min) if gpu_span_min is not None else 0
res['total_kernel_us'] = sum(v[0] for v in allk.values())
top = sorted(allk.items(), key=lambda kv: -kv[1][0])[:50]
res['top_kernels'] = [{'name': n[:180], 'total_us': round(v[0],1), 'count': v[1], 'avg_us': round(v[0]/max(v[1],1),2)} for n,v in top]

qr = [k for k in kernels if 'quickreduce' in k[0] or 'allreduce_prototype' in k[0]]
print("qr kernels:", len(qr), flush=True)
qr.sort(key=lambda k: k[1])

def stats(ds):
    ds = sorted(ds)
    if not ds: return {}
    def p(x):
        return ds[int(round(x/100.0*(len(ds)-1)))]
    return {'n':len(ds),'min':ds[0],'p1':p(1),'p5':p(5),'p10':p(10),'p25':p(25),'p50':p(50),
            'p75':p(75),'p90':p(90),'p95':p(95),'p99':p(99),'max':ds[-1],
            'mean':round(sum(ds)/len(ds),2),'sum':round(sum(ds),1)}

res['qr_stats'] = stats([k[2] for k in qr])
gh = collections.Counter(); nh = collections.Counter(); sh = collections.Counter()
for k in qr:
    gh[str(k[4])+'|'+str(k[5])] += 1
    nh[k[0][:200]] += 1
    sh[str(k[6])] += 1
res['qr_grid'] = dict(gh); res['qr_names'] = dict(nh); res['qr_stream'] = dict(sh)

# per-grid duration stats (grid likely encodes payload)
bygrid = collections.defaultdict(list)
for k in qr: bygrid[str(k[4])+'|'+str(k[5])].append(k[2])
res['qr_by_grid'] = {g: stats(v) for g,v in bygrid.items()}

# shapes via External id
shapes = collections.Counter()
shape_dur = collections.defaultdict(list)
matched = 0
for k in qr:
    eid = k[3]
    ops = cpuops.get(eid)
    if not ops: continue
    matched += 1
    # pick the deepest/most specific op mentioning reduce
    cand = [o for o in ops if 'reduce' in o[0].lower() or 'all_reduce' in o[0].lower()]
    o = cand[0] if cand else ops[0]
    key = o[0][:80] + ' dims=' + str(o[1])
    shapes[key] += 1
    shape_dur[key].append(k[2])
res['qr_eid_matched'] = matched
res['qr_shapes'] = dict(shapes.most_common(60))
res['qr_shape_dur'] = {s: stats(v) for s,v in list(shape_dur.items())[:60]}

# time-ordered sequence, plus gaps
res['qr_seq'] = [[round(k[1],1), k[2], str(k[4])] for k in qr]

# classify prefill vs decode by neighbouring big GEMM/attention kernels is hard;
# instead dump full kernel timeline coarse: bucket kernels into 1ms bins of qr density
with open(out,'w') as f: json.dump(res,f)
print("wrote", out, flush=True)
