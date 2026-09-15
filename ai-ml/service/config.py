from __future__ import annotations

import os


DEFAULT_MAX_CANDIDATES = 500
MAX_CONFIGURED_CANDIDATES = 10_000


def get_max_candidates() -> int:
    raw_value = os.getenv("PLANNING_MAX_CANDIDATES", str(DEFAULT_MAX_CANDIDATES))
    try:
        value = int(raw_value)
    except ValueError as exc:
        raise RuntimeError("PLANNING_MAX_CANDIDATES must be an integer") from exc
    if not 1 <= value <= MAX_CONFIGURED_CANDIDATES:
        raise RuntimeError(
            f"PLANNING_MAX_CANDIDATES must be from 1 to {MAX_CONFIGURED_CANDIDATES}"
        )
    return value
