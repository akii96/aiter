# ⚠️ RETRACTED — this guard fixes a defect that does not exist

**Do not merge this branch.** The change it contains (routing non-256-aligned `inter_dim` to
the v2 layout GEMM2) was built to avoid a numerical defect in the v1 native GEMM2. A later
controlled experiment shows that defect is not real.

Kept for the negative result and for the method, which is reusable.

---

## What the guard did

Relax the `activation == Situv2` conjunct in `_mxmoe_fallback_ok` to admit Swiglu, plus an
alignment predicate so it fires only where `inter_dim % 256 != 0`, so that non-aligned widths
reach the matched (fp4-output GEMM1, v2 layout GEMM2) pair instead of the heuristic fallback —
whose `flydsl_kernel_name()` can only emit a **v1 native** GEMM2 name.

## Why it is unnecessary

At a **fixed** `inter_dim`, forcing v1 and v2 in turn (v1 forced by hiding the tuned rows so
the heuristic fallback fires), across `M = 8, 128, 512, 1024, 4096, 16384` and
`inter_dim = 384, 512, 640, 896, 1152, 1536`:

**26 cells — zero NaN, zero Inf, zero memory-access faults, zero non-zero exits.**
The originally-reported failure points (M=512 and M=1024 hard fault, M=4096 NaN) **do not
reproduce**. Controls at the 256-aligned widths 512 and 1536 behave identically to 384 and
640, so the harness is measuring a working kernel, not hiding a broken one.

### The decisive test: zero-pad equivalence

Construct the *same mathematical function* at two widths. Take the `inter=384` weights and
embed them in an `inter=512` problem with the extra lanes zeroed — gate and up lanes
`384:512 = 0`, and the matching `w2` columns `384:512 = 0`. Since `swiglu(0,0) = 0` and the
matching `w2` columns are zero, the padded lanes contribute exactly nothing; zero is exactly
representable in fp4, so the equivalence survives the quantised path. Then run **v1 on both**.
The only difference is the width, and therefore the K-tiling.

If v1 at 384 read out of bounds past the expert's K extent — the stride hypothesis — it would
pull in neighbouring experts' weights and the two answers would diverge grossly.

```
narrow v1 (384) vs zero-padded wide v1 (512):  rel_max 6.45e-3   rel_l2 2.14e-4
v1's own null arm (same config twice):         rel_max 6.45e-3   rel_l2 2.33e-4   <- identical
narrow-v2 vs wide-v1 (ordinary kernel diff):   rel_max 1.32e-1                    <- 2 orders larger
```

The cross-width delta is **indistinguishable from the arm's own run-to-run noise**, while a
genuine kernel difference shows up two orders of magnitude larger. There is no out-of-bounds
read: the narrow and padded-wide computations are the same computation.

## Why the original claim survived as long as it did

Three independent supports, each of which has since failed:

1. **The measurement.** "384 produces NaN, 640 hard-faults" came from a harness whose
   reference quantised activations to **bf16 while the kernel ran fp4**, producing "98.4% of
   elements differ" — a signature that looks like catastrophic corruption.
2. **The control pair was confounded.** "640 faults, 768 is clean, same kernel family" was
   wrong: 640 ran **v1** and 768 ran **v2**. v1/v2 selection is driven by *tuned-row presence*,
   not by width — 1536 is 256-aligned and takes v1; 384 is not aligned and takes v2.
3. **aiter's own data contradicted it.** `dsv41_fp4_tuned_fmoe.csv` ships five **v1 a4w4** rows
   at `inter=640` (`md=5120, E=384, topk=6`) recording `err1=0.2%, err2=0.2–1.5%` — *better*
   than the v2 rows at the same shape (0.9%, 1.1–1.2%).

## A measurement note worth keeping

`rel_l2` against an fp32 reference has an **irreducible floor (~0.129) that is not input
quantisation.** Making every input exactly MXFP4-representable — verified roundtrip
`rel = 0.0` for both weight tensors and the activations — does **not** move it. The floor is
the **stage1→stage2 intermediate requantisation**: stage1's bf16 swiglu output is requantised
to fp4 before stage2, and no input-side trick removes it.

So `rel_l2` vs ground truth is quantisation-dominated and **cannot adjudicate subtle kernel
defects on this op**. Use equivalence constructions (like the zero-pad above) that have no
quantisation floor, and report faults/NaN/Inf separately from accuracy.

## What follows from this

The 256 alignment is **not buying correctness**. At TP8 it costs +33% MoE FLOPs, +33% expert
weight bytes, and ~8.5 GB/GPU.

**Correctness at the op level is necessary but not sufficient.** Before the padding can
actually be removed, someone needs:

- `is_mxfp4_moe_shape_supported` to admit the narrow shape — it returns `False` at 896/1024
  even though the aux instances are present in the shipped `.so`, which is a false negative
  (`moe_mxfp4_aux.cu:158` is literally `(void)D_INTER;` — the aux dispatcher ignores
  `inter_dim` entirely)
- tuned rows at the narrow width, or acceptance of the heuristic path
- a vLLM-side change to `oracle/mxfp4.py`'s alignment
- **a performance measurement at the narrow width.** This work establishes *correctness only*.
  The v1 and v2 arms ran different `block_m` (32 vs 16/64), which is a confound for any
  performance claim.
