from __future__ import annotations

import json
import sys
from pathlib import Path

AI_ML_ROOT = Path(__file__).resolve().parents[1]
if str(AI_ML_ROOT) not in sys.path:
    sys.path.insert(0, str(AI_ML_ROOT))

from planning.models import PlaceCandidate
from planning.planner import plan_trip


def load_fixture(path: Path) -> tuple[str, int, list[str], list[PlaceCandidate]]:
    data = json.loads(path.read_text(encoding="utf-8"))
    candidates = [PlaceCandidate.from_dict(item) for item in data["candidatePlaces"]]
    return data["destinationId"], data["days"], data["interests"], candidates


def main() -> None:
    fixture_name = sys.argv[1] if len(sys.argv) > 1 else "normal.json"
    fixture_path = Path(__file__).resolve().parent / "fixtures" / fixture_name
    destination_id, days, interests, candidates = load_fixture(fixture_path)
    result = plan_trip(destination_id, days, interests, candidates)
    print(json.dumps(result.to_dict(), indent=2))


if __name__ == "__main__":
    main()
