from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


STAGE2B_DIR = Path(__file__).resolve().parent
EVALUATION_DIR = STAGE2B_DIR.parent

if str(EVALUATION_DIR) not in sys.path:
    sys.path.insert(0, str(EVALUATION_DIR))

from validate import validate_fixture  # noqa: E402
from integrated_adapter import normalize_integrated_response  # noqa: E402


def load_json(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def build_checker_case(
    request: dict[str, Any],
    candidate_places: list[dict[str, Any]],
    integrated_response: dict[str, Any],
) -> dict[str, Any]:
    """
    Build the minimal fixture shape required by the existing
    independent validator.

    No planner logic is reproduced here.
    """

    normalized_response = normalize_integrated_response(
        integrated_response
    )

    return {
        "_case": "Stage 2B integrated output",
        "request": {
            "destinationId": request.get("destinationId"),
            "days": request.get("days"),
            "interests": request.get("interests", []),
            "candidatePlaces": candidate_places,
        },
        "response": normalized_response,
    }


def check_integrated_output(
    request_path: Path,
    candidates_path: Path,
    response_path: Path,
) -> bool:
    request = load_json(request_path)
    candidate_source = load_json(candidates_path)
    response = load_json(response_path)

    if isinstance(candidate_source, dict):
        candidate_places = candidate_source.get(
            "candidatePlaces",
            []
        )
    elif isinstance(candidate_source, list):
        candidate_places = candidate_source
    else:
        raise ValueError(
            "Candidate source must be a JSON object or list."
        )

    case = build_checker_case(
        request=request,
        candidate_places=candidate_places,
        integrated_response=response,
    )

    violations = validate_fixture(case)

    if violations:
        print("RESULT: FAIL")
        for violation in violations:
            print(f"- {violation}")
        return False

    print("RESULT: PASS")
    print("All independent Stage 2B invariants satisfied.")
    return True


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Validate one actual integrated Stage 2B output "
            "using the existing independent invariant checker."
        )
    )

    parser.add_argument(
        "--request",
        required=True,
        type=Path,
        help="JSON file containing the exact integrated request.",
    )

    parser.add_argument(
        "--candidates",
        required=True,
        type=Path,
        help=(
            "JSON file containing the exact candidate source "
            "used for the integrated run."
        ),
    )

    parser.add_argument(
        "--response",
        required=True,
        type=Path,
        help="JSON file containing the actual integrated response.",
    )

    args = parser.parse_args()

    passed = check_integrated_output(
        request_path=args.request,
        candidates_path=args.candidates,
        response_path=args.response,
    )

    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())