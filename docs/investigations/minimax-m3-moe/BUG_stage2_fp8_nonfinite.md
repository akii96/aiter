# BUG: `AITER_FLYDSL_STAGE2_FP8=1` reads uninitialised memory — corrupts under allocator pressure

**Severity:** silent numerical corruption (no exception, no warning). **Invisible on an idle GPU**;
appears under memory pressure — i.e. it passes CI and fails in production.
**Component:** stage-2 fp8 route-out ("fp8 partials"), `aiter/ops/flydsl/moe_kernels.py`
**Arch:** gfx950 (MI355X, 256 CU) · **ROCm:** 7.2.3 · **aiter:** `8253efc4`
**Scope:** only when the flag is set **and** the stage-2 epilogue is `reduce`. The default
(flag unset) path is **unaffected** — verified, §3.
**Status:** mechanism demonstrated causally. No fix submitted (§7).

---

## 1. Summary

With `AITER_FLYDSL_STAGE2_FP8=1`, stage-2 writes topk partials as fp8 (uint8 values + e8m0 scale
bytes) into a buffer allocated by `torch.empty` with a padded row pitch. **Part of that buffer is
read without ever being written.** Whether that produces garbage depends on what the caching
allocator hands back:

- fresh/zeroed pages → benign, output looks correct
- recycled pages with non-zero bytes → an **e8m0 exponent byte** decodes to ~2^127, multiplying
  its block by ~10^38 → ~10⁴–10⁶ non-finite elements, absmax ~2e38

Demonstrated causally: **holding shape, seed, flag and kernel fixed, and varying only resident
memory, flips the result between clean and corrupt** (§2).

> ⚠️ **This is not shape-dependent.** An earlier draft of this report claimed specific
> `inter_dim` values were broken. That was wrong — see §6, which documents the two confounds that
> produced it, because both are easy traps to fall into.

---

## 2. The causal experiment

Identical config throughout: `model_dim=6144, inter_dim=384, M=4096, E=129, topk=5, Swiglu,
per_1x32 a4w4, seed 0, preshuffled weights, flag ON`. The only variable is how many extra live
weight sets are resident.

| arm | free VRAM | non-finite | absmax | verdict |
|---|---|---|---|---|
| isolated (build, run, free) | 270.3 GB | 0 | 5.438e+00 | OK |
| pressure ×1 | 268.0 GB | 0 | 5.438e+00 | OK |
| **pressure ×2** | 268.0 GB | **43,731** | **2.127e+38** | **CORRUPT** |
| pressure ×4 | 268.0 GB | 0 | 2.305e-01 | OK |
| repeated calls on one set (×4) | 270.3 GB | 0 | – | OK |

268 GB free at the failure — **not OOM**. It is *which* block the allocator reuses. The
non-monotonicity (×2 fails, ×4 passes) is expected: what matters is whether the recycled block
happens to contain non-zero bytes at the unwritten offsets.

**Reproducer:** `nf_root.py` (this branch) reproduces the table above directly.

---

## 3. The default path is NOT affected

Isolated builds, 2 seeds, flag OFF and ON. `fp8 buf` is ground truth — a `torch.empty`
interception recording whether the fp8 route-out buffer was actually allocated.

| inter_dim | flag | fp8 buf allocated | non-finite | verdict |
|---|---|---|---|---|
| 384 | OFF | ✗ | 0 | OK |
| **384** | **ON** | **✓** | **0** | **OK (isolated)** |
| 512 | OFF / ON | ✗ / **✗** | 0 | OK |
| 640 | OFF / ON | ✗ / **✗** | 0 | OK |
| 704 | OFF / ON | ✗ / **✗** | 0 | OK |
| 896 | OFF / ON | ✗ / **✗** | 0 | OK |

All 16 runs clean. **No corruption in the default path.**

---

## 4. Mechanism

`moe_kernels.py:2202-2217`:
```python
target = torch.empty(
    (token_num * topk,
     fp8out_row_bytes(model_dim, scale_blk=..., pitch_align=FP8OUT_PITCH_ALIGN)),
    device=out.device,
    dtype=torch.uint8,          # NOT zeroed
)
```
`mxfp4_gemm_common.py:375-400`:
```python
FP8OUT_SCALE_BLK_MIN = 8 ; FP8OUT_PITCH_ALIGN = 64
pitch = model_dim + model_dim // scale_blk   # values + e8m0 scale bytes
return ceil(pitch / align) * align           # padded -> bytes nothing writes
```

Each row interleaves value bytes with **e8m0 exponent bytes**. An e8m0 byte is a raw
power-of-two exponent, so an uninitialised byte can decode to ~2^127 — matching the observed
~2e38 exactly. Likely unwritten regions: (i) pitch padding from `pitch_align=64`; (ii) sorted
slots beyond `num_valid_ids`; (iii) an uncovered K-tail.

The bf16 path is immune: a garbage bf16 value is bounded by its dtype and carries no separate
exponent byte.

---

## 5. The flag is inert wherever the epilogue is `atomic`

**This is the most important practical note in this report.** The fp8 route-out is gated on the
epilogue:

- `fused_moe.py:2685` — `_s2_fp8_inter = epilog == "reduce" and _flydsl_stage2_fp8_enabled()`
- `moe_kernels.py:2187` — `_s2_fp8_inter = (not accumulate) and ...`; `accumulate=True` for atomic

With an `atomic` epilogue, stage-2 accumulates directly into the output and **no partial buffer
exists**, so the flag does nothing at all. Verified by allocation interception (§3): only 384 and
768 allocate the fp8 buffer; 512, 640, 704, 896 allocate nothing.

Consequences:
- At the **production shape `inter_dim=512`** the flag is a **silent no-op**. Measured
  speedup 0.998× / 0.999× / 0.999× at M = 4096 / 8192 / 16384 — noise.
- **Any cross-shape accuracy or performance comparison that does not control for the epilogue is
  meaningless.** Shapes on the atomic path are measuring nothing.

---

## 6. Confounds that produced earlier wrong conclusions

Recorded deliberately — both are easy to fall into and one of them produced a plausible,
internally consistent, entirely false result.

**Confound A — the epilogue (§5).** Comparing rel L2 across `inter_dim` looked like a clean
severity gradient. Most of those shapes were not running fp8 at all; their ~1e-4 differences were
run-to-run nondeterminism of **atomic accumulation order**.

**Confound B — allocator state.** Sweeping shapes in one process accumulates allocator state, so
later iterations are more likely to receive dirty blocks. That makes an allocator-dependent bug
look **shape-dependent**, and the apparent severity ordering was an artifact of sweep order.

**Confound C — unshuffled weights.** Passing unshuffled weights to tuned kernels is outside
aiter's contract (it logs `is_shuffled=False ... may produce incorrect results`) and corrupts the
**bf16 baseline** too. Any repro must call `shuffle_weight(..., layout=(16,16))`.

Falsified along the way, each by explicit counterexample: `inter_dim % 256 != 0`
(128 and 896 are clean); ragged K-tile at `tile_k=256`; "one broken kernel variant"
(two families implicated); non-persist vs persist reducer; "the failure is non-deterministic in
the sense of being random" (it is deterministic *given allocator state*); and both accuracy
claims below.

**Unmeasured: the true accuracy cost of fp8 partials.** Earlier figures of ~1e-4 (no-op shapes)
and 2.69e-2 (measured under a polluted allocator) are both withdrawn. A trustworthy number needs
isolated runs on a `reduce`-epilogue shape, which this report does not yet have.

---

## 6b. Methodology failure — the transferable lesson

**I swept `inter_dim` across 13 points while allocator state accumulated across iterations, and
that manufactured a clean-looking severity gradient out of allocator noise. Holding the shape
fixed and varying only memory pressure took minutes and gave the true answer. Sweep last, not
first.**

The false result was not obviously false. It was monotonic
(garbage → 2.7e-2 → 3.4e-3 → 1.3e-4), reproducible in the sense that re-running the same sweep
gave the same ordering, and stable to four significant figures at individual points. It supported
a confident mechanism story and a specific predicate hunt. It was entirely an artifact of two
confounds — sweep order and epilogue selection — neither of which is visible in the output table.

Three rules this argues for, in this codebase specifically:

1. **Vary one thing, controlled, before sweeping many things.** A controlled A/B on a single
   configuration (§2) beat a 13-point sweep and cost less time.
2. **Verify the feature under test is actually engaged.** Five of the shapes I "measured" never
   allocated the fp8 buffer (§5). Assert engagement — do not infer it from a kernel name.
3. **Determinism is not evidence of correctness.** `2.690e-02` reproduced to four significant
   figures across six runs and looked exactly like a quantisation floor. A deterministic defect
   is equally stable. Determinism distinguishes *systematic from random*, not *defect from
   inherent*.

A corollary for reviewers: a fresh-process, idle-GPU benchmark is the **best case** for this class
of bug. If a result must hold in production, it has to be measured under production-like memory
pressure.

---

## 7. Recommended actions

1. **Do not enable `AITER_FLYDSL_STAGE2_FP8=1`.** It is inert at atomic-epilogue shapes and
   unsafe at `reduce` ones. There is no measured performance benefit at the production shape.
2. **Fix direction:** bound the reducer so it never reads bytes the GEMM did not write —
   respecting `num_valid_ids` and the padded row pitch (`pitch_align=64`).
3. **Do NOT "fix" with `torch.empty` → `torch.zeros`.** It masks an out-of-bounds read while
   adding a ~960 MB zero-fill (M=16384) to the one path whose purpose is saving bandwidth.
   Deliberately not done here.
4. **CI must run under memory pressure.** An idle-GPU test passes (§2, "isolated"). Allocate and
   free several large tensors first, assert `torch.isfinite(out).all()`, and repeat — otherwise
   this class of bug is invisible.
5. Before any future perf/accuracy claim about this flag, **assert the fp8 buffer was actually
   allocated** (§3's interception is three lines), or the measurement may be of nothing.

---

## 8. Provenance

Found while assessing whether narrowing stage-2 partial precision could reduce MoE bandwidth
(`ASM_NONFLAT_REASSESS.md` §6a, this branch). That performance question closed NO-GO
independently. All measurements: single gfx950 (GPU 6), serial, no co-tenant work, production
`fused_moe` dispatch, preshuffled weights, bf16 baseline verified finite throughout.
