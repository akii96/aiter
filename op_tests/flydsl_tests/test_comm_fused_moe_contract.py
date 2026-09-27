# SPDX-License-Identifier: MIT
# Copyright (C) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""CPU-only contract tests for the comm-fused MoE Stage2 configuration.

The load-bearing property here is invisible to a GPU numerics run:
**compile-cache stability**. ``MegakernelConfig`` is rendered through
``repr(config)`` into the compile-cache key and into the launcher symbol name,
and ``compile_megakernel`` is ``@functools.cache``'d on the config. Adding a
field therefore moves every cache key unless its default is elided from the
repr. The five shipped DSV4 cache keys are frozen here as goldens captured
before ``fold_shared`` existed.

Everything here is pure Python dataclass/string work: no GPU, no compiler, no
symmetric memory. ``config.py`` imports only ``dataclasses``, so it loads
standalone via importlib without flydsl or a ROCm toolchain. Run:

    pytest op_tests/flydsl_tests/test_comm_fused_moe_contract.py -q
"""

import csv
import hashlib
import importlib.util
import re
import sys
from pathlib import Path

_REPO_ROOT = Path(__file__).resolve().parents[2]
_A8W4 = _REPO_ROOT / "aiter/ops/flydsl/kernels/comm_fused_moe/gfx950/a8w4"
_HOST_PY = _REPO_ROOT / "aiter/ops/flydsl/comm_fused_moe_host.py"
_DSV4_CSV = (
    _REPO_ROOT / "aiter/configs/model_configs/dsv4_fp8fp4_tuned_comm_fused_moe.csv"
)

# The historical kernelName prefix, frozen here as an independent copy. If this
# constant ever has to change, existing tuned CSVs have been invalidated.
_HISTORICAL_PREFIX = "flydsl_comm_moe2_afp8_wfp4_bf16_"

# Compile-cache keys for the five non-fallback DSV4 rows, captured from the
# shipped code at ROCm/aiter 8253efc4 before ``fold_shared`` existed.
_GOLDEN_CACHE_KEYS = {
    1: "b0bac8de1f177285",
    2: "e7ce0abe99cb9967",
    4: "0c89042246bbcf84",
    8: "a7b47ba8fac0f9b5",
    16: "827e32cd1a146e0c",
}


def _load_config_module():
    spec = importlib.util.spec_from_file_location(
        "_a8w4_config_under_test", _A8W4 / "config.py"
    )
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


config_module = _load_config_module()
Shape = config_module.Shape
MegakernelConfig = config_module.MegakernelConfig
DEFAULT_FOLD_SHARED = config_module.DEFAULT_FOLD_SHARED

DSV4_SHAPE = Shape(7168, 384, 384, 6, 8)
# A geometry whose shared expert is fused into the routing as slot 128:
# 128 routed experts + 1 shared == 129 slots, topk 5.
FOLDED_SHARED_SHAPE = Shape(6144, 768, 129, 5, 8)


def _legacy_config_repr(config):
    """Mirror of ``megakernel._legacy_config_repr``.

    Duplicated rather than imported because ``megakernel.py`` pulls in flydsl.
    ``test_legacy_repr_mirrors_megakernel`` asserts the two stay in sync by
    reading the real source.
    """

    text = (
        repr(config)
        .replace("MegakernelConfig(", "Gemm2TPMegakernelConfig(", 1)
        .replace("shape=Shape(", "shape=Gemm2TPShape(", 1)
    )
    default_token = f", fold_shared={DEFAULT_FOLD_SHARED!r})"
    if text.endswith(default_token):
        text = text[: -len(default_token)] + ")"
    return text


def _cache_key(config):
    """Mirror of the ``cache_config`` hash in ``megakernel.compile_megakernel``."""

    return hashlib.sha256(
        f"mxmoe_bf16_route_dynamic_scale_v5:{_legacy_config_repr(config)}".encode()
    ).hexdigest()[:16]


_NUMERIC_TAGS = (
    ("sort_block_m", "sbm"),
    ("compute_groups", "cg"),
    ("block_threads", "bt"),
    ("vector_width", "v"),
    ("waves_per_eu", "w"),
    ("b_cache_modifier", "bnt"),
    ("local_load_cache_modifier", "ll"),
    ("remote_load_cache_modifier", "rl"),
    ("gather_load_cache_modifier", "gl"),
    ("remote_store_cache_modifier", "rs"),
    ("n_tile_cohort", "ntc"),
)

_MEGA_DEFAULTS = {
    "sort_block_m": 32,
    "compute_groups": 96,
    "block_threads": 256,
    "vector_width": 16,
    "waves_per_eu": 0,
    "b_cache_modifier": 0,
    "local_load_cache_modifier": 1,
    "remote_load_cache_modifier": 1,
    "gather_load_cache_modifier": -1,
    "remote_store_cache_modifier": 0,
    "n_tile_cohort": 0,
}


def _config_name(config):
    """Mirror of the megakernel branch of ``comm_fused_moe_host.config_name``."""

    parts = [
        f"{_HISTORICAL_PREFIX}t{config.tile_m}x{config.tile_n}x{config.tile_k}",
    ]
    for field_name, tag in _NUMERIC_TAGS:
        value = getattr(config, field_name)
        if value != _MEGA_DEFAULTS[field_name]:
            parts.append(f"{tag}{value}")
    if config.collective != "direct":
        parts.append({"rs_broadcast": "rsbcast", "rsag": "rsag"}[config.collective])
    if config.service_groups != 1:
        parts.append(f"sg{config.service_groups}")
    if config.service_tile_group != 1:
        parts.append(f"stg{config.service_tile_group}")
    if config.producer_mode != "routes":
        parts.append("patomic")
    if config.flat_producer_grid:
        parts.append("flat")
    if not config.fold_shared:
        parts.append("noshared")
    return "_".join(parts)


def _parse_megakernel_name(name, shape, m):
    """Mirror of ``comm_fused_moe_host._parse_megakernel_name``."""

    if not name.startswith(_HISTORICAL_PREFIX):
        return None
    parts = name[len(_HISTORICAL_PREFIX) :].split("_")
    tile = re.fullmatch(r"t(\d+)x(\d+)x(\d+)", parts.pop(0))
    if tile is None:
        raise ValueError(f"invalid megakernel tile in {name!r}")
    values = dict(_MEGA_DEFAULTS)
    values.update(
        collective="direct",
        service_groups=1,
        service_tile_group=1,
        producer_mode="routes",
        flat_producer_grid=False,
        sorted_input=False,
        fold_shared=True,
        tile_m=int(tile.group(1)),
        tile_n=int(tile.group(2)),
        tile_k=int(tile.group(3)),
    )
    numeric = {tag: field_name for field_name, tag in _NUMERIC_TAGS}
    numeric.update(sg="service_groups", stg="service_tile_group")
    collective = values["collective"]
    for part in parts:
        if part in ("direct", "rsbcast", "rsag"):
            collective = {
                "direct": "direct",
                "rsbcast": "rs_broadcast",
                "rsag": "rsag",
            }[part]
        elif part == "patomic":
            values["producer_mode"] = "atomic_shared"
        elif part == "flat":
            values["flat_producer_grid"] = True
        elif part == "noshared":
            values["fold_shared"] = False
        else:
            for tag, field_name in sorted(
                numeric.items(), key=lambda item: -len(item[0])
            ):
                if part.startswith(tag):
                    values[field_name] = int(part[len(tag) :])
                    break
            else:
                raise ValueError(f"unknown megakernel option {part!r} in {name!r}")
    values["collective"] = collective
    return MegakernelConfig(shape=shape, m=m, **values)


def _dsv4_megakernel_rows():
    with _DSV4_CSV.open(newline="") as handle:
        for row in csv.DictReader(handle):
            if row["kernelName"].strip().lower() != "fallback":
                yield row


def _megakernel_from_row(row):
    shape = Shape(
        int(row["model_dim"]),
        int(row["inter_dim"]),
        int(row["expert"]),
        int(row["topk"]),
        int(row["tp"]),
    )
    config = _parse_megakernel_name(row["kernelName"], shape, int(row["token"]))
    assert config is not None, f"row failed to parse: {row['kernelName']!r}"
    return config


# --------------------------------------------------------------------------
# Compile-cache identity
# --------------------------------------------------------------------------


def test_production_dsv4_cache_keys_are_unchanged():
    """Regression gate: the 5 shipped rows keep their exact cache keys."""

    seen = {}
    for row in _dsv4_megakernel_rows():
        config = _megakernel_from_row(row)
        seen[config.m] = _cache_key(config)
    assert seen == _GOLDEN_CACHE_KEYS


def test_legacy_repr_mirrors_megakernel():
    """The default-eliding rule must match what megakernel.py actually does."""

    source = (_A8W4 / "megakernel.py").read_text(encoding="utf-8")
    assert "def _legacy_config_repr" in source
    assert 'default_token = f", fold_shared={DEFAULT_FOLD_SHARED!r})"' in source
    assert "legacy_config_repr = _legacy_config_repr(config)" in source
    # The repr must still feed the cache key and the launcher name.
    assert "mxmoe_bf16_route_dynamic_scale_v5:{legacy_config_repr}" in source


def test_host_prefix_is_byte_identical_to_the_historical_literal():
    source = _HOST_PY.read_text(encoding="utf-8")
    assert f'_CONFIG_NAME_PREFIX = "{_HISTORICAL_PREFIX}"' in source


# --------------------------------------------------------------------------
# fold_shared: the shared-expert double-count guard
# --------------------------------------------------------------------------


def test_fold_shared_defaults_to_true():
    """The historical behaviour -- shared_partial is always folded in."""

    config = MegakernelConfig(shape=DSV4_SHAPE, m=1, tile_m=32, compute_groups=6)
    assert config.fold_shared is True
    assert DEFAULT_FOLD_SHARED is True


def test_fold_shared_default_is_elided_from_the_repr():
    """Turning the field on must not move a single existing cache key."""

    config = MegakernelConfig(shape=DSV4_SHAPE, m=1, tile_m=32, compute_groups=6)
    text = _legacy_config_repr(config)
    assert "fold_shared" not in text
    assert text.endswith("sorted_input=False)")


def test_explicit_default_is_indistinguishable_from_the_implicit_default():
    implicit = MegakernelConfig(shape=DSV4_SHAPE, m=1, tile_m=32, compute_groups=6)
    explicit = MegakernelConfig(
        shape=DSV4_SHAPE, m=1, tile_m=32, compute_groups=6, fold_shared=True
    )
    assert _legacy_config_repr(implicit) == _legacy_config_repr(explicit)
    assert _cache_key(implicit) == _cache_key(explicit)


def test_fold_shared_false_is_carried_in_the_repr_and_cache_key():
    """A no-fold config must never reuse a folding config's compiled kernel."""

    folded = MegakernelConfig(
        shape=FOLDED_SHARED_SHAPE, m=16, tile_m=32, compute_groups=80
    )
    unfolded = MegakernelConfig(
        shape=FOLDED_SHARED_SHAPE,
        m=16,
        tile_m=32,
        compute_groups=80,
        fold_shared=False,
    )
    assert _legacy_config_repr(unfolded).endswith("fold_shared=False)")
    assert _cache_key(folded) != _cache_key(unfolded)
    assert len({folded, unfolded}) == 2
    assert folded != unfolded


def test_megakernel_guards_every_shared_load_but_not_the_store():
    """Both shared_resource *reads* sit under ``const_expr(config.fold_shared)``.

    The hazard this field exists for is silent: with the shared expert fused
    into the routed topk, an unguarded load yields ``2*shared + sum(routes)``
    per rank with no shape change and no exception. So assert structurally
    that no unguarded read survives.

    The single remaining *write* is deliberately untouched: the rs_broadcast
    producer reuses that allocation as BF16 scratch for its own result, which
    this flag does not govern. Gating it would break rs_broadcast outright.
    """

    source = (_A8W4 / "megakernel.py").read_text(encoding="utf-8")

    loads = re.findall(r"load_bf16\(\s*shared_resource,", source)
    stores = re.findall(r"store_bf16\(\s*shared_resource,", source)
    assert len(loads) == 2, f"expected 2 shared_resource loads, found {len(loads)}"
    assert len(stores) == 1, f"expected 1 shared_resource store, found {len(stores)}"
    assert source.count("const_expr(config.fold_shared)") == 2

    # The pre-change code bound the load to a name and added it
    # unconditionally; if that name reappears, an unguarded fold is back.
    assert "shared_values" not in source


def test_runtime_only_requires_shared_partial_when_the_runner_folds():
    """Drift guard on the runtime's None check."""

    source = (_REPO_ROOT / "aiter/ops/comm_fused_moe_runtime.py").read_text(
        encoding="utf-8"
    )
    assert "def _runner_folds_shared" in source
    assert "if _runner_folds_shared(runner):" in source
    # An unrecognised runner keeps the strict behaviour.
    assert 'getattr(config, "fold_shared", True)' in source


# --------------------------------------------------------------------------
# Name round-trip
# --------------------------------------------------------------------------


def test_every_shipped_dsv4_row_still_parses():
    rows = list(_dsv4_megakernel_rows())
    assert len(rows) == 5, "expected exactly 5 tuned DSV4 megakernel rows"
    for row in rows:
        config = _megakernel_from_row(row)
        assert config.sort_block_m == int(row["block_m"])


def test_folding_names_carry_no_noshared_tag():
    """Every pre-existing kernelName must be reproduced byte-for-byte."""

    for row in _dsv4_megakernel_rows():
        config = _megakernel_from_row(row)
        assert config.fold_shared is True
        assert "noshared" not in _config_name(config)
        assert _config_name(config) == row["kernelName"]


def test_noshared_tag_round_trips():
    """``noshared`` must survive name -> config -> name."""

    config = MegakernelConfig(
        shape=FOLDED_SHARED_SHAPE,
        m=16,
        tile_m=32,
        compute_groups=80,
        fold_shared=False,
    )
    name = _config_name(config)
    assert name.endswith("_noshared")
    parsed = _parse_megakernel_name(name, FOLDED_SHARED_SHAPE, 16)
    assert parsed is not None
    assert parsed.fold_shared is False
    assert parsed == config
    assert _config_name(parsed) == name


def test_host_emits_and_parses_the_noshared_tag():
    """Drift guard: the in-test mirror must match the real host implementation."""

    source = _HOST_PY.read_text(encoding="utf-8")
    assert "if not config.fold_shared:" in source
    assert 'parts.append("noshared")' in source
    assert 'elif part == "noshared":' in source
    assert 'values["fold_shared"] = False' in source
