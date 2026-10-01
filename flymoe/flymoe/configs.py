"""Tuned tile configs: MoERun kwargs for any (I, T).

Tables (configs/tiles_v6_I{I}.json) hold one config per power-of-two T bucket, tuned
for MiniMax-M3 routing (E=129 incl. the shared expert, k=5). Any T uses the smallest
bucket >= T, clamped to the table's range; every config is correct for any T.
"""
import functools
import json
import os

TABLE_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "configs")
TABLE = "tiles_v6_I{I}.json"


@functools.lru_cache(maxsize=None)
def load_table(I: int, table: str = TABLE):
    with open(os.path.join(TABLE_DIR, table.format(I=I))) as f:
        raw = json.load(f)
    return {int(t): c for t, c in raw.items()}


def bucket(I: int, T: int, table: str = TABLE) -> int:
    ts = sorted(load_table(I, table))
    return next((t for t in ts if t >= T), ts[-1])


def cfg_kwargs(c: dict) -> dict:
    kw = {f"{k}1": v for k, v in c["s1"].items()}
    kw.update({f"{k}2": v for k, v in c["s2"].items()})
    kw.update(c.get("global", {}))
    return kw


def select_cfg(I: int, T: int, E: int = 129, k: int = 5, table: str = TABLE) -> dict:
    """MoERun kwargs for I, T. FC (fused combine) needs the shared expert once per token
    (E-1 in every row of topk_ids) and T*H*2 < 2^31; it is dropped otherwise."""
    kw = cfg_kwargs(load_table(I, table)[bucket(I, T, table)])
    if (E, k) != (129, 5) or T * 6144 * 2 >= 2**31:
        kw.pop("FC", None)
    return kw
