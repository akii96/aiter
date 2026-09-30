"""MX fp4 (e2m1 + e8m0 per 1x32) quantization helpers in torch.

These are the host/reference definitions. The device kernels implement the
same arithmetic so kernel output can be compared bit-for-bit where possible.

Scale rule (matches the device epilogue): e8m0 = ceil_pow2(amax / 6), i.e. the
smallest power of two such that amax / scale <= 6. Elements then round to the
nearest e2m1 value (ties to even) and never saturate.
"""

import torch

FP4_VALUES = torch.tensor(
    [0.0, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0, -0.0, -0.5, -1.0, -1.5, -2.0, -3.0, -4.0, -6.0]
)


def fp4_decode(codes: torch.Tensor) -> torch.Tensor:
    """codes: uint8 tensor of 4-bit codes (0..15) -> float32."""
    return FP4_VALUES.to(codes.device)[codes.long()]


def unpack_fp4(packed: torch.Tensor) -> torch.Tensor:
    """[..., K/2] uint8 -> [..., K] codes. Low nibble is the even element."""
    lo = packed & 0xF
    hi = packed >> 4
    return torch.stack([lo, hi], dim=-1).flatten(-2)


def pack_fp4(codes: torch.Tensor) -> torch.Tensor:
    """[..., K] codes -> [..., K/2] uint8."""
    c = codes.to(torch.uint8).unflatten(-1, (-1, 2))
    return c[..., 0] | (c[..., 1] << 4)


def e8m0_to_f32(s: torch.Tensor) -> torch.Tensor:
    return torch.exp2(s.float() - 127.0)


def dequant(packed: torch.Tensor, scales: torch.Tensor) -> torch.Tensor:
    """packed [..., K/2] uint8, scales [..., K/32] uint8 -> float32 [..., K]."""
    v = fp4_decode(unpack_fp4(packed))
    s = e8m0_to_f32(scales).repeat_interleave(32, dim=-1)
    return v * s


def _e8m0_roundup(amax: torch.Tensor) -> torch.Tensor:
    """Bit-exact mirror of the device rule: exponent of ceil_pow2(amax/6)."""
    x = (amax.float() * (1.0 / 6.0)).contiguous()
    bits = x.view(torch.int32)
    bexp = ((bits + 0x7FFFFF) >> 23) & 0xFF
    return torch.clamp(bexp, max=254).to(torch.uint8)


def _round_to_fp4_codes(x: torch.Tensor) -> torch.Tensor:
    """Round float32 (already divided by scale) to e2m1 codes, RNE, saturating at 6."""
    sign = (x < 0) | ((x == 0) & torch.signbit(x))
    a = x.abs().clamp(max=6.0)
    # e2m1 magnitudes and the midpoints between them; ties go to the even code.
    mags = torch.tensor([0.0, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0], device=x.device)
    idx = torch.bucketize(a, mags)  # first index with mags[idx] >= a
    idx = idx.clamp(1, 7)
    lo = mags[idx - 1]
    hi = mags[idx]
    d_lo = a - lo
    d_hi = hi - a
    pick_hi = (d_hi < d_lo) | ((d_hi == d_lo) & (idx % 2 == 0))
    code = torch.where(pick_hi, idx, idx - 1)
    code = torch.where(a == 0, torch.zeros_like(code), code)
    return (code | (sign.long() << 3)).to(torch.uint8)


def _e8m0_even(amax: torch.Tensor) -> torch.Tensor:
    """Bit-exact mirror of hw.e8m0_even (AITER runtime / checkpoint "even" rule)."""
    bits = amax.float().contiguous().view(torch.int32)
    e = (((bits + 0x200000) >> 23) & 0xFF) - 2
    return torch.clamp(e, 0, 254).to(torch.uint8)


def quant(x: torch.Tensor, even: bool = False):
    """x [..., K] float -> (packed [..., K/2] uint8, scales [..., K/32] uint8)."""
    xs = x.float().unflatten(-1, (-1, 32))
    amax = xs.abs().amax(dim=-1)
    e = _e8m0_even(amax) if even else _e8m0_roundup(amax)
    scale = e8m0_to_f32(e).unsqueeze(-1)
    codes = _round_to_fp4_codes(xs / scale).flatten(-2)
    return pack_fp4(codes), e


def random_fp4(shape, device, gen=None, scale_center=127, scale_spread=2):
    """Random packed fp4 tensor [..., K/2] and e8m0 scales [..., K/32]."""
    *lead, k = shape
    codes = torch.randint(0, 16, (*lead, k), device=device, dtype=torch.uint8, generator=gen)
    scales = torch.randint(
        scale_center - scale_spread,
        scale_center + scale_spread + 1,
        (*lead, k // 32),
        device=device,
        dtype=torch.uint8,
        generator=gen,
    )
    return pack_fp4(codes), scales
