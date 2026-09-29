"""Thin hardware helpers over FlyDSL rocdl intrinsics (gfx950).

Everything here is plumbing: buffer descriptors, raw buffer loads/stores,
LDS pointers and the scaled fp4 MFMA. No MoE logic lives in this file.
"""

import inspect

import flydsl.expr as fx
from flydsl._mlir import ir
from flydsl._mlir.dialects import llvm
from flydsl._mlir.dialects import rocdl as _mrocdl
from flydsl.expr import rocdl
from flydsl.expr.typing import T

_CDNA_BUF_FLAGS = (7 << 12) | (4 << 15)
_AUX_IS_ATTR = (
    inspect.signature(_mrocdl.RawPtrBufferLoadOp).parameters["aux"].kind
    is inspect.Parameter.KEYWORD_ONLY
)

NT = 2  # non-temporal cache modifier


def raw(v):
    if not isinstance(v, ir.Value) and hasattr(v, "ir_value"):
        return v.ir_value()
    while not isinstance(v, ir.Value) and hasattr(v, "_value"):
        v = v._value
    return v


def rsrc(addr_i64, num_bytes=None):
    """Buffer resource over a raw device address. OOB loads return 0 when num_bytes is set."""
    base = llvm.IntToPtrOp(ir.Type.parse("!llvm.ptr"), raw(fx.Int64(addr_i64))).result
    if num_bytes is None:
        n = fx.Int64(0xFFFFFFFF)
    elif isinstance(num_bytes, int):
        n = fx.Int64(max(0, min(num_bytes, 0xFFFFFFFF)))
    else:
        n = fx.Int64(num_bytes)
    return _mrocdl.MakeBufferRsrcOp(
        ir.Type.parse("!llvm.ptr<8>"),
        base,
        raw(fx.Int16(0)),
        raw(n),
        raw(fx.Int32(_CDNA_BUF_FLAGS)),
    ).result


def _aux(cm):
    if _AUX_IS_ATTR:
        return ir.IntegerAttr.get(ir.IntegerType.get_signless(32), cm)
    return raw(fx.Int32(cm))


def bload(rs, byte_off, ty, soff=0, cm=0):
    """Raw buffer load at a byte offset. `ty` is an MLIR type (e.g. T.i32x4)."""
    return _mrocdl.RawPtrBufferLoadOp(
        ty, rs, raw(fx.Int32(byte_off)), raw(fx.Int32(soff)), aux=_aux(cm)
    ).result


def bstore(val, rs, byte_off, soff=0, cm=0):
    _mrocdl.RawPtrBufferStoreOp(
        raw(val), rs, raw(fx.Int32(byte_off)), raw(fx.Int32(soff)), aux=_aux(cm)
    )


def batomic_fadd(val, rs, byte_off, soff=0):
    """Buffer atomic fadd (f32 or v2bf16), no return."""
    return rocdl.raw_ptr_buffer_atomic_fadd(
        raw(val), rs, raw(fx.Int32(byte_off)), raw(fx.Int32(soff))
    )


def lds_ptr(base_i32, byte_off, elem_ty, align=16):
    ptr_ty = fx.PointerType.get(T.i8, fx.AddressSpace.Shared, align)
    base = fx.inttoptr(ptr_ty, fx.Int32(base_i32))
    tptr = fx.PointerType.get(elem_ty, fx.AddressSpace.Shared, align)
    return fx.recast_iter(tptr, fx.add_offset(base, fx.Int32(byte_off)))


def lds_llvm_ptr(base_i32, byte_off):
    ptr_ty = fx.PointerType.get(T.i8, fx.AddressSpace.Shared)
    return fx.to_llvm_ptr(fx.inttoptr(ptr_ty, fx.Int64(fx.Int32(base_i32) + fx.Int32(byte_off))))


def lds_load(base_i32, byte_off, res_ty, elem_ty=None, align=16):
    return llvm.LoadOp(res_ty, lds_llvm_ptr(base_i32, byte_off), alignment=align).result


def lds_store(val, base_i32, byte_off, elem_ty=None, align=16):
    llvm.StoreOp(raw(val), lds_llvm_ptr(base_i32, byte_off), alignment=align)


def dma_to_lds(rs, lds_base_i32, lds_off, voff, soff=0, nbytes=16, cm=0):
    """Global->LDS DMA. Lane i lands at lds_base + lds_off + i*nbytes (per wave)."""
    rocdl.raw_ptr_buffer_load_lds(
        rs,
        lds_llvm_ptr(lds_base_i32, lds_off),
        raw(fx.Int32(nbytes)),
        raw(fx.Int32(voff)),
        raw(fx.Int32(soff)),
        raw(fx.Int32(0)),
        raw(fx.Int32(cm)),
    )


def dma_async(rs, lds_base_i32, lds_off, voff, soff=0, nbytes=16, cm=0):
    """Async global->LDS DMA (completion tracked by rocdl.asyncmark/wait_asyncmark).

    lds_off must be wave-uniform; lane i lands at lds_base + lds_off + i*nbytes.
    """
    lptr = lds_llvm_ptr(lds_base_i32, fx.Int32(rocdl.readfirstlane(T.i32, raw(fx.Int32(lds_off)))))
    _mrocdl.raw_ptr_buffer_load_async_lds(
        rs,
        lptr,
        raw(fx.Int32(nbytes)),
        raw(fx.Int32(voff)),
        raw(fx.Int32(soff)),
        raw(fx.Int32(0)),
        aux=ir.IntegerAttr.get(ir.IntegerType.get_signless(32), cm),
    )


def mfma_fp4(acc, a, b, sa, sb, opsel_a=0, opsel_b=0):
    """v_mfma_scale_f32_16x16x128_f8f6f4 with fp4 (e2m1) A and B and e8m0 scales.

    a, b: i32x4 per lane (32 fp4 values). sa, sb: i32 holding 4 e8m0 bytes;
    opsel picks the byte. acc: f32x4.
    """
    return rocdl.mfma_scale_f32_16x16x128_f8f6f4(
        T.f32x4, [a, b, acc, 4, 4, opsel_a, raw(fx.Int32(sa)), opsel_b, raw(fx.Int32(sb))]
    )


def dpp_i32(src, ctrl, row_mask=0xF, bank_mask=0xF, bound_ctrl=True):
    """llvm.amdgcn.update.dpp.i32 with old = src (lanes outside the pattern keep src)."""
    v = raw(fx.Int32(src))
    return fx.Int32(llvm.call_intrinsic(
        T.i32, "llvm.amdgcn.update.dpp.i32",
        [v, v, raw(fx.Int32(ctrl)), raw(fx.Int32(row_mask)), raw(fx.Int32(bank_mask)),
         raw(fx.Boolean(bound_ctrl))], [], []))


def row16_max_nonneg_f32(x):
    """Max over each 16-lane DPP row for non-negative floats (int order == float order).

    quad_perm xor1, quad_perm xor2, row_half_mirror, row_mirror: after each step every
    lane holds the max of the lanes combined so far, so the mirrors act like xor4/xor8.
    """
    v = fx.Float32(x).bitcast(fx.Int32)
    for ctrl in (0xB1, 0x4E, 0x141, 0x140):
        o = dpp_i32(v, ctrl)
        v = (fx.Uint32(o) > fx.Uint32(v)).select(o, v)
    return v.bitcast(fx.Float32)


def fast_rcp(x):
    return fx.Float32(rocdl.rcp(T.f32, raw(fx.Float32(x))))
