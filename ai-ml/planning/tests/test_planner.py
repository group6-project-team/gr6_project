from __future__ import annotations

import json
import sys
from pathlib import Path

import pytest

AI_ML_ROOT = Path(__file__).resolve().parents[2]
if str(AI_ML_ROOT) not in sys.path:
    sys.path.insert(0, str(AI_ML_ROOT))

from planning.models import PlaceCandidate
from planning.planner import PlannerInputError, plan_trip

FIXTURES = Path(__file__).resolve().parents[1] / "fixtures"


def load_fixture(name: str):
    data = json.loads((FIXTURES / name).read_text(encoding="utf-8"))
    candidates = [PlaceCandidate.from_dict(item) for item in data["candidatePlaces"]]
    return data, candidates


def output_ids(result) -> list[str]:
    return [place_id for day in result.days for place_id in day.place_ids]


def assert_common_invariants(data, candidates, result) -> None:
    expected_days = list(range(1, data["days"] + 1))
    assert [day.day for day in result.days] == expected_days

    ids = output_ids(result)
    input_ids = {place.id for place in candidates}
    expected_n = min(len(candidates), 3 * data["days"])

    assert len(ids) == expected_n
    assert len(ids) == len(set(ids))
    assert set(ids).issubset(input_ids)
    assert all(len(day.place_ids) <= 3 for day in result.days)

    counts = [len(day.place_ids) for day in result.days]
    assert max(counts) - min(counts) <= 1


def test_normal_case_has_balanced_counts_and_no_warning() -> None:
    data, candidates = load_fixture("normal.json")
    result = plan_trip(data["destinationId"], data["days"], data["interests"], candidates)

    assert_common_invariants(data, candidates, result)
    assert [len(day.place_ids) for day in result.days] == [3, 3, 2]
    assert result.warnings == ()


def test_selection_limit_selects_exactly_nine() -> None:
    data, candidates = load_fixture("selection_limit.json")
    result = plan_trip(data["destinationId"], data["days"], data["interests"], candidates)

    assert_common_invariants(data, candidates, result)
    assert [len(day.place_ids) for day in result.days] == [3, 3, 3]
    assert len(output_ids(result)) == 9
    assert result.warnings == ()


def test_partial_case_keeps_empty_day_and_warning() -> None:
    data, candidates = load_fixture("partial.json")
    result = plan_trip(data["destinationId"], data["days"], data["interests"], candidates)

    assert_common_invariants(data, candidates, result)
    assert [len(day.place_ids) for day in result.days] == [1, 1, 0]
    assert [warning.code for warning in result.warnings] == ["PARTIAL_ITINERARY"]


def test_empty_case_returns_all_days_and_no_places_warning() -> None:
    data, candidates = load_fixture("empty.json")
    result = plan_trip(data["destinationId"], data["days"], data["interests"], candidates)

    assert_common_invariants(data, candidates, result)
    assert [len(day.place_ids) for day in result.days] == [0, 0, 0]
    assert [warning.code for warning in result.warnings] == ["NO_PLACES_AVAILABLE"]


def test_no_interests_case_is_valid_and_deterministic() -> None:
    data, candidates = load_fixture("no_interests.json")

    first = plan_trip(data["destinationId"], data["days"], data["interests"], candidates)
    second = plan_trip(data["destinationId"], data["days"], data["interests"], candidates)

    assert_common_invariants(data, candidates, first)
    assert first == second
    assert [len(day.place_ids) for day in first.days] == [3, 3, 2]
    assert first.warnings == ()


def test_interest_matches_are_selected_before_general_candidates() -> None:
    candidates = [
        PlaceCandidate("general-a", "istanbul-tr", "General A", ("park",), 41.0, 29.0),
        PlaceCandidate("museum-a", "istanbul-tr", "Museum A", ("museum",), 41.001, 29.001),
        PlaceCandidate("history-a", "istanbul-tr", "History A", ("history",), 41.002, 29.002),
        PlaceCandidate("general-b", "istanbul-tr", "General B", ("shopping",), 41.003, 29.003),
    ]

    result = plan_trip("istanbul-tr", 1, ["museum", "history"], candidates)
    ids = set(output_ids(result))

    assert "museum-a" in ids
    assert "history-a" in ids
    assert len(ids) == 3


def test_tie_breaking_is_deterministic() -> None:
    candidates = [
        PlaceCandidate("p-b", "istanbul-tr", "B", ("museum",), 41.0, 29.0),
        PlaceCandidate("p-a", "istanbul-tr", "A", ("museum",), 41.0, 29.0),
    ]

    result = plan_trip("istanbul-tr", 1, ["museum"], candidates)

    assert result.days[0].place_ids[0] == "p-a"


def test_rejects_invalid_days() -> None:
    with pytest.raises(PlannerInputError, match="days"):
        plan_trip("istanbul-tr", 0, [], [])

    with pytest.raises(PlannerInputError, match="days"):
        plan_trip("istanbul-tr", 15, [], [])

    with pytest.raises(PlannerInputError, match="days"):
        plan_trip("istanbul-tr", True, [], [])


def test_rejects_duplicate_candidate_ids() -> None:
    place = PlaceCandidate("p-1", "istanbul-tr", "A", ("museum",), 41.0, 29.0)

    with pytest.raises(PlannerInputError, match="unique"):
        plan_trip("istanbul-tr", 1, [], [place, place])


def test_rejects_candidate_from_other_destination() -> None:
    place = PlaceCandidate("p-1", "ankara-tr", "A", ("museum",), 39.9, 32.8)

    with pytest.raises(PlannerInputError, match="belongs"):
        plan_trip("istanbul-tr", 1, [], [place])


def test_rejects_duplicate_interests() -> None:
    with pytest.raises(PlannerInputError, match="duplicates"):
        plan_trip("istanbul-tr", 1, ["museum", "museum"], [])


def test_rejects_string_instead_of_interest_list() -> None:
    with pytest.raises(PlannerInputError, match="sequence"):
        plan_trip("istanbul-tr", 1, "museum", [])


def test_fixture_loader_rejects_non_string_id() -> None:
    with pytest.raises(ValueError, match="id must be a string"):
        PlaceCandidate.from_dict({
            "id": 10,
            "destinationId": "istanbul-tr",
            "name": "A",
            "categoryIds": ["museum"],
            "latitude": 41.0,
            "longitude": 29.0,
        })
