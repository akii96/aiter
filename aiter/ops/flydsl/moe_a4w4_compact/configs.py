# SPDX-License-Identifier: MIT
# Copyright (C) 2024-2026, Advanced Micro Devices, Inc. All rights reserved.
"""Tile tables: one MoERun config per power-of-two token bucket and inter_dim.

``configs/I{inter_dim}.json`` maps a token bucket to stage-1 (``s1``),
stage-2 (``s2``) and global settings, tuned for MiniMax-M3 routing (129 experts
including the fused shared expert, topk 5). Every config is correct for any
token count; the tables are the candidate set the MoE tuner searches.
"""

import functools
import json
import os

TABLE_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "configs")


@functools.cache
def load_table(inter_dim: int) -> dict:
    path = os.path.join(TABLE_DIR, f"I{inter_dim}.json")
    if not os.path.exists(path):
        return {}
    with open(path) as f:
        return {int(t): c for t, c in json.load(f).items()}


def cfg_kwargs(cell: dict) -> dict:
    """MoERun keyword arguments for one table cell."""
    kwargs = {f"{k}1": v for k, v in cell["s1"].items()}
    kwargs.update({f"{k}2": v for k, v in cell["s2"].items()})
    kwargs.update(cell.get("global", {}))
    return kwargs
