from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from integrated_adapter import normalize_integrated_response


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def check_determinism(
    first_path: Path,
    second_path: Path,
) -> bool:
    """
    Compare two actual integrated responses produced from the
    same request and candidate source.

    The comparison uses only QA contract normalization.
    It does not call or reproduce planner logic.
    """

    first_response = load_json(first_path)
    second_response = load_json(second_path)

    first_normalized = normalize_integrated_response(
        first_response
    )
    second_normalized = normalize_integrated_response(
        second_response
    )

    if first_normalized == second_normalized:
        print("RESULT: PASS")
        print(
            "Determinism confirmed: normalized integrated "
            "outputs are identical."
        )
        return True

    print("RESULT: FAIL")
    print(
        "Determinism violation: normalized integrated "
        "outputs differ."
    )

    print("\nFIRST OUTPUT:")
    print(
        json.dumps(
            first_normalized,
            indent=2,
            ensure_ascii=False,
        )
    )

    print("\nSECOND OUTPUT:")
    print(
        json.dumps(
            second_normalized,
            indent=2,
            ensure_ascii=False,
        )
    )

    return False


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Compare two actual Stage 2B integrated responses "
            "from repeated identical requests."
        )
    )

    parser.add_argument(
        "--first",
        required=True,
        type=Path,
        help="First actual integrated response JSON.",
    )

    parser.add_argument(
        "--second",
        required=True,
        type=Path,
        help="Second actual integrated response JSON.",
    )

    args = parser.parse_args()

    passed = check_determinism(
        first_path=args.first,
        second_path=args.second,
    )

    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())