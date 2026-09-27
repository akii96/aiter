#!/usr/bin/env python3
"""
QUEST PREFILTER -- PHASE 1 DATA CAPTURE (CPU-ONLY)

Computes REAL MiniMax-M3 layer-3 index_k / index_q vectors.

Why this is a real capture and not a synthetic stand-in
-------------------------------------------------------
The sparse indexer is DISABLED on layers 0,1,2 (moe_layer_freq / sparse_disable_index_value
both start [0,0,0,1,1,...]), and layer 3 is the FIRST sparse layer. So the input to
layer 3's index_{q,k}_proj is the output of exactly:

    embed_tokens -> L0(dense attn + dense MLP) -> L1 -> L2

Those three layers are plain BF16 (no MXFP4 experts -- verified: layers 0-2 have
mlp.{gate,up,down}_proj and NO block_sparse_moe). Total weight to touch:

    embed      200064 x 6144   (gathered rows only, memory-mapped)
    3 layers x (q 8192x6144, k 512x6144, v 512x6144, o 6144x8192,
                gate 12288x6144, up 12288x6144, down 6144x12288) ~ 2.6 GB total
    layer3     index_q_proj 512x6144, index_k_proj 128x6144

That is ~3 GB of bf16 -- trivially CPU-feasible. Everything downstream of layer 3
(the 128 MXFP4 experts) is NOT needed, because we only want layer 3's index branch.

Exact op semantics replicated (all verified against the running container's source):
  * Gemma RMSNorm:   out = x * rsqrt(mean(x^2)+eps) * (1 + w)        [fp32 accum]
                     (gemma_rmsnorm.py:_gemma_rmsnorm_kernel)
  * Decoder layer:   residual-carrying pre-norm, post_attention_layernorm is a
                     FUSED ADD+NORM whose residual_out is the PRE-norm sum.
                     (amd/model.py:1332-1354, _gemma_fused_add_rmsnorm_kernel)
  * Attention:       per-head q_norm/k_norm (Gemma), partial NeoX RoPE on the
                     FIRST rotary_dim=64 of each 128-dim head, GQA 64q/4kv, causal.
  * MLP:             swiglu-OAI: gate=min(gate,limit); up=clamp(up,-limit,limit);
                     out = gate*sigmoid(alpha*gate)*(up+beta)   alpha=1.702 beta=1.0
  * Index branch:    index_q: 4 heads x 128 ; index_k: 1 head x 128.
                     Gemma norm with index_{q,k}_norm.weight, then partial RoPE
                     -- do_rope stays TRUE for both index slots
                     (fused_qknorm_idxrqknorm.cu:321 do_rope=true, only is_v clears it).
                     THIS MATTERS ENORMOUSLY for the Quest bound; see report.
  * Cache store:     index_k -> e4m3 with UNIT SCALE (storeCacheElems(...,1.0f)).

Outputs  index_k [T,128] fp8-roundtripped fp32, index_q [T,4,128] fp8-roundtripped.
"""
import argparse, glob, json, math, os, re, sys, time, zipfile
import numpy as np
import torch
from safetensors import safe_open

torch.set_grad_enabled(False)
SNAP = sorted(glob.glob(
    "/mnt/dcgpuval/huggingface/hub/models--amd--MiniMax-M3-MXFP4/snapshots/*/"))[0]
CFG = json.load(open(SNAP + "config.json"))["text_config"]
WM = json.load(open(SNAP + "model.safetensors.index.json"))["weight_map"]

H          = CFG["hidden_size"]           # 6144
NQ         = CFG["num_attention_heads"]   # 64
NKV        = CFG["num_key_value_heads"]   # 4
HD         = CFG["head_dim"]              # 128
ROT        = CFG["rotary_dim"]            # 64
THETA      = float(CFG["rope_theta"])     # 5e6
EPS        = float(CFG["rms_norm_eps"])   # 1e-6
ALPHA      = float(CFG.get("swiglu_alpha", 1.702))
BETA       = float(CFG.get("swiglu_beta", 1.0))
LIMIT      = float(CFG.get("swiglu_limit", 7.0))
SPARSE     = CFG["sparse_attention_config"]
NIQ        = SPARSE["sparse_num_index_heads"]   # 4
IDX_DIM    = SPARSE["sparse_index_dim"]         # 128

_open_cache = {}
def _f(fn):
    if fn not in _open_cache:
        _open_cache[fn] = safe_open(SNAP + fn, framework="pt")
    return _open_cache[fn]

DEV = "cpu"
WDT = torch.float32
_w_cache = {}
def W(name, dtype=None):
    t = _w_cache.get(name)
    if t is None:
        t = _f(WM[name]).get_tensor(name).to(dtype or WDT).to(DEV)
        _w_cache[name] = t
    return t

def gemma_norm(x, w, eps=EPS):
    """out = x*rsqrt(mean(x^2)+eps)*(1+w), fp32 accumulation. Last dim is normed."""
    x32 = x.float()
    var = x32.pow(2).mean(-1, keepdim=True)
    return x32 * torch.rsqrt(var + eps) * (1.0 + w.float())

def build_rope(max_pos, rot=ROT, theta=THETA):
    """vLLM get_rope default: inv_freq over rot/2, cache = [cos | sin], NeoX halves."""
    inv = 1.0 / (theta ** (torch.arange(0, rot, 2, dtype=torch.float64) / rot))
    t = torch.arange(max_pos, dtype=torch.float64)
    fr = torch.outer(t, inv)                      # [P, rot/2]
    return fr.cos().float(), fr.sin().float()

def apply_partial_neox_rope(x, cos, sin, pos, rot=ROT):
    """x [..., HD]; rotate only first `rot` dims, NeoX halving. pos [T] longs.
    Matches normAndRope: first_half -> e*c - partner*s ; second -> e*c + partner*s."""
    half = rot // 2
    c = cos[pos]                                   # [T, half]
    s = sin[pos]
    shape = [x.shape[0]] + [1] * (x.dim() - 2) + [half]
    c = c.view(shape); s = s.view(shape)
    x1 = x[..., :half]
    x2 = x[..., half:rot]
    out = x.clone()
    out[..., :half]    = x1 * c - x2 * s
    out[..., half:rot] = x2 * c + x1 * s
    return out

def swiglu_oai(gate, up):
    gate = torch.minimum(gate, torch.tensor(LIMIT, device=gate.device))
    up = torch.clamp(up, -LIMIT, LIMIT)
    return gate * torch.sigmoid(ALPHA * gate) * (up + BETA)

def MM(x, w):
    """x fp32 [..,K] @ w.T ; compute in the weight dtype, accumulate back to fp32."""
    if w.dtype == torch.float32:
        return x @ w.T
    return (x.to(w.dtype) @ w.T).float()


def dense_layer(hs, residual, L, cos, sin, pos):
    """One dense decoder layer (L in 0,1,2). Returns (hidden, residual)."""
    P = f"language_model.model.layers.{L}."
    if residual is None:
        residual = hs
        x = gemma_norm(hs, W(P + "input_layernorm.weight"))
    else:
        s = hs + residual
        residual = s
        x = gemma_norm(s, W(P + "input_layernorm.weight"))

    T = x.shape[0]
    q = MM(x, W(P + "self_attn.q_proj.weight")).view(T, NQ, HD)
    k = MM(x, W(P + "self_attn.k_proj.weight")).view(T, NKV, HD)
    v = MM(x, W(P + "self_attn.v_proj.weight")).view(T, NKV, HD)

    q = gemma_norm(q, W(P + "self_attn.q_norm.weight"))
    k = gemma_norm(k, W(P + "self_attn.k_norm.weight"))
    q = apply_partial_neox_rope(q, cos, sin, pos)
    k = apply_partial_neox_rope(k, cos, sin, pos)

    # GQA causal attention. Chunked over the QUERY axis so the attention matrix
    # is never materialised whole: at T=128k a single [64, T, T] fp32 tensor
    # would be 4 TB. SDPA per chunk keeps peak at [NQ, CH, T].
    rep = NQ // NKV
    qh = q.permute(1, 0, 2).unsqueeze(0)                          # [1, NQ, T, HD]
    kh = k.repeat_interleave(rep, dim=1).permute(1, 0, 2).unsqueeze(0)
    vh = v.repeat_interleave(rep, dim=1).permute(1, 0, 2).unsqueeze(0)
    dt = torch.bfloat16 if qh.device.type == "cuda" else torch.float32
    qh, kh, vh = qh.to(dt), kh.to(dt), vh.to(dt)
    CH = 512 if DEV == "cpu" else 4096
    o = torch.empty_like(qh)
    for i0 in range(0, T, CH):
        i1 = min(i0 + CH, T)
        # causal mask for this query slice: query i attends keys j<=i
        qi = torch.arange(i0, i1, device=qh.device).view(-1, 1)
        kj = torch.arange(0, i1, device=qh.device).view(1, -1)
        mask = (kj <= qi)
        o[:, :, i0:i1] = torch.nn.functional.scaled_dot_product_attention(
            qh[:, :, i0:i1], kh[:, :, :i1], vh[:, :, :i1],
            attn_mask=mask, scale=HD ** -0.5)
    attn = o[0].float().permute(1, 0, 2).reshape(T, NQ * HD)
    hs = MM(attn, W(P + "self_attn.o_proj.weight"))

    # fused add + post_attention_layernorm; residual_out is the PRE-norm sum
    s = hs + residual
    residual = s
    x = gemma_norm(s, W(P + "post_attention_layernorm.weight"))

    g = MM(x, W(P + "mlp.gate_proj.weight"))
    u = MM(x, W(P + "mlp.up_proj.weight"))
    hs = MM(swiglu_oai(g, u), W(P + "mlp.down_proj.weight"))
    return hs, residual

def fp8_e4m3_roundtrip(t):
    """UNIT-SCALE e4m3 store, exactly what storeCacheElems(...,1.0f) does."""
    return t.to(torch.float8_e4m3fn).float()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tokens", type=int, default=8192)
    ap.add_argument("--source", default="longbench")
    ap.add_argument("--doc", type=int, default=0)
    ap.add_argument("--out", required=True)
    ap.add_argument("--threads", type=int, default=64)
    ap.add_argument("--device", default="cpu")
    a = ap.parse_args()
    torch.set_num_threads(a.threads)
    global DEV, WDT
    DEV = a.device
    # bf16 weights on GPU (that is the serving dtype); fp32 on CPU
    WDT = torch.bfloat16 if DEV.startswith("cuda") else torch.float32

    ids = get_token_ids(a.source, a.doc, a.tokens)
    T = len(ids)
    print(f"[capture] source={a.source} doc={a.doc} tokens={T}", flush=True)

    cos, sin = build_rope(T + 8)
    cos = cos.to(DEV); sin = sin.to(DEV)
    pos = torch.arange(T, device=DEV)

    t0 = time.time()
    emb = _f(WM["language_model.model.embed_tokens.weight"])
    # gather only the rows we need
    hs = emb.get_tensor("language_model.model.embed_tokens.weight")[
        torch.as_tensor(ids)].float().to(DEV)
    print(f"[capture] embed {tuple(hs.shape)} {time.time()-t0:.1f}s", flush=True)

    residual = None
    for L in (0, 1, 2):
        t1 = time.time()
        hs, residual = dense_layer(hs, residual, L, cos, sin, pos)
        print(f"[capture] dense L{L} done {time.time()-t1:.1f}s "
              f"|h|={hs.norm().item():.2f}", flush=True)

    # ---- layer 3 input_layernorm, then the index branch ----
    P3 = "language_model.model.layers.3."
    s = hs + residual
    x = gemma_norm(s, W(P3 + "input_layernorm.weight"))

    iq = MM(x, W(P3 + "self_attn.index_q_proj.weight")).view(T, NIQ, IDX_DIM)
    ik = MM(x, W(P3 + "self_attn.index_k_proj.weight")).view(T, 1, IDX_DIM)

    iq = gemma_norm(iq, W(P3 + "self_attn.index_q_norm.weight"))
    ik = gemma_norm(ik, W(P3 + "self_attn.index_k_norm.weight"))

    # do_rope stays TRUE for index slots (fused_qknorm_idxrqknorm.cu)
    iq_r = apply_partial_neox_rope(iq, cos, sin, pos)
    ik_r = apply_partial_neox_rope(ik, cos, sin, pos)

    out = dict(
        index_k_fp8   = fp8_e4m3_roundtrip(ik_r[:, 0]).cpu().numpy(),
        index_q_fp8   = fp8_e4m3_roundtrip(iq_r).cpu().numpy(),
        index_k_norope= fp8_e4m3_roundtrip(ik[:, 0]).cpu().numpy(),
        index_q_norope= fp8_e4m3_roundtrip(iq).cpu().numpy(),
        token_ids     = np.asarray(ids, dtype=np.int32),
    )
    np.savez_compressed(a.out, **out)
    k = out["index_k_fp8"]
    print(f"[capture] index_k {k.shape} min={k.min():.3f} max={k.max():.3f} "
          f"mean={k.mean():.4f} std={k.std():.4f}")
    print(f"[capture] SAVED {a.out}  total {time.time()-t0:.1f}s")

def get_token_ids(source, doc, n):
    from transformers import AutoTokenizer
    tok = AutoTokenizer.from_pretrained(SNAP, trust_remote_code=True)
    text = ""
    if source == "longbench":
        z = ("/mnt/dcgpuval/huggingface/hub/datasets--zai-org--LongBench/"
             "snapshots/5e628be450b7e67fb7ae6e201bd6d8f7056f7672/data.zip")
        with zipfile.ZipFile(z) as zf:
            names = [x for x in zf.namelist() if x.endswith(".jsonl")]
            names.sort()
            # prefer long single-doc narrative/code sets
            pref = [x for x in names if any(t in x for t in
                    ("narrativeqa", "gov_report", "qmsum", "multifieldqa_en", "repobench"))]
            names = pref + [x for x in names if x not in pref]
            fn = names[doc % len(names)]
            print(f"[capture] longbench file={fn}")
            with zf.open(fn) as fh:
                for line in fh:
                    r = json.loads(line)
                    text += r.get("context", "") + "\n\n"
                    if len(text) > n * 12:
                        break
    elif source == "code":
        parts = []
        for root, _, files in os.walk("/usr/local/lib/python3.12/dist-packages/vllm"):
            for f in sorted(files):
                if f.endswith(".py"):
                    try: parts.append(open(os.path.join(root, f), encoding="utf8").read())
                    except Exception: pass
            if sum(len(p) for p in parts) > n * 12: break
        text = "\n".join(parts)
    else:
        raise SystemExit(f"unknown source {source}")
    ids = tok(text, add_special_tokens=False)["input_ids"]
    if len(ids) < n:
        raise SystemExit(f"only got {len(ids)} tokens, need {n}")
    return ids[:n]

if __name__ == "__main__":
    main()
