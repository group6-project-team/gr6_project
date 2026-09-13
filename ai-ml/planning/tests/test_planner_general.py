from __future__ import annotations

import random

import pytest

from planning.models import PlaceCandidate
from planning.planner import PlannerInputError, _haversine_km, plan_trip


def make_candidates(count: int, *, destination: str = "dest") -> list[PlaceCandidate]:
    categories = ("museum", "history", "park", "food", "nature")
    return [
        PlaceCandidate(
            id=f"p-{index:03d}",
            destination_id=destination,
            name=f"Place {index}",
            category_ids=(categories[index % len(categories)],),
            latitude=31.0 + (index % 20) * 0.01,
            longitude=35.0 + (index % 17) * 0.01,
        )
        for index in range(count)
    ]


def flatten_ids(result) -> list[str]:
    return [place_id for day in result.days for place_id in day.place_ids]


def assert_invariants(days: int, candidates: list[PlaceCandidate], result) -> None:
    selected_count = min(len(candidates), 3 * days)
    expected_days = list(range(1, days + 1))
    counts = [len(day.place_ids) for day in result.days]
    ids = flatten_ids(result)
    input_ids = {place.id for place in candidates}

    q, r = divmod(selected_count, days)
    expected_counts = [q + (1 if index < r else 0) for index in range(days)]

    assert [day.day for day in result.days] == expected_days
    assert counts == expected_counts
    assert all(count <= 3 for count in counts)
    assert len(ids) == selected_count
    assert len(ids) == len(set(ids))
    assert set(ids).issubset(input_ids)

    warning_codes = [warning.code for warning in result.warnings]
    if selected_count == 0:
        assert warning_codes == ["NO_PLACES_AVAILABLE"]
    elif selected_count < days:
        assert warning_codes == ["PARTIAL_ITINERARY"]
    else:
        assert warning_codes == []


def test_capacity_and_warning_matrix() -> None:
    for days in range(1, 15):
        for candidate_count in range(0, 51):
            candidates = make_candidates(candidate_count)
            result = plan_trip("dest", days, ["museum"], candidates)
            assert_invariants(days, candidates, result)


def test_randomized_invariants_are_stable() -> None:
    rng = random.Random(20260913)
    category_pool = [f"c-{index}" for index in range(8)]

    for case_index in range(300):
        days = rng.randint(1, 14)
        candidate_count = rng.randint(0, 60)
        interests = rng.sample(category_pool, rng.randint(0, 4))

        candidates = []
        for place_index in range(candidate_count):
            category_count = rng.randint(0, 3)
            categories = tuple(rng.sample(category_pool, category_count))
            candidates.append(
                PlaceCandidate(
                    id=f"case-{case_index:03d}-p-{place_index:03d}",
                    destination_id="dest",
                    name=f"Place {place_index}",
                    category_ids=categories,
                    latitude=rng.uniform(-90.0, 90.0),
                    longitude=rng.uniform(-180.0, 180.0),
                )
            )

        result = plan_trip("dest", days, interests, candidates)
        repeated = plan_trip("dest", days, interests, candidates)

        assert_invariants(days, candidates, result)
        assert result == repeated


def test_candidate_input_order_does_not_change_result() -> None:
    candidates = [
        PlaceCandidate("a", "dest", "A", ("museum",), 31.00, 35.00),
        PlaceCandidate("b", "dest", "B", ("history",), 31.01, 35.01),
        PlaceCandidate("c", "dest", "C", ("park",), 31.02, 35.02),
        PlaceCandidate("d", "dest", "D", ("museum", "history"), 31.03, 35.03),
        PlaceCandidate("e", "dest", "E", ("food",), 31.04, 35.04),
    ]

    original = plan_trip("dest", 2, ["museum", "history"], candidates)
    reversed_input = plan_trip("dest", 2, ["history", "museum"], list(reversed(candidates)))

    assert original == reversed_input


def test_planner_does_not_mutate_input_list() -> None:
    candidates = make_candidates(8)
    snapshot = list(candidates)

    plan_trip("dest", 3, ["museum"], candidates)

    assert candidates == snapshot


def test_max_day_boundary_with_more_than_capacity() -> None:
    candidates = make_candidates(50)
    result = plan_trip("dest", 14, ["museum"], candidates)

    assert_invariants(14, candidates, result)
    assert len(flatten_ids(result)) == 42
    assert [len(day.place_ids) for day in result.days] == [3] * 14


def test_single_day_caps_selection_at_three() -> None:
    candidates = make_candidates(10)
    result = plan_trip("dest", 1, [], candidates)

    assert len(result.days) == 1
    assert len(result.days[0].place_ids) == 3
    assert result.warnings == ()


def test_partial_warning_boundary() -> None:
    partial_candidates = make_candidates(4)
    full_candidates = make_candidates(5)

    partial = plan_trip("dest", 5, [], partial_candidates)
    full = plan_trip("dest", 5, [], full_candidates)

    assert [warning.code for warning in partial.warnings] == ["PARTIAL_ITINERARY"]
    assert full.warnings == ()


def test_no_places_and_partial_warnings_never_coexist() -> None:
    empty = plan_trip("dest", 3, [], [])
    partial = plan_trip("dest", 3, [], make_candidates(2))

    assert [warning.code for warning in empty.warnings] == ["NO_PLACES_AVAILABLE"]
    assert [warning.code for warning in partial.warnings] == ["PARTIAL_ITINERARY"]


def test_multi_interest_match_count_controls_selection() -> None:
    candidates = [
        PlaceCandidate("z-double", "dest", "Double", ("museum", "history"), 31.0, 35.0),
        PlaceCandidate("a-single", "dest", "Single", ("museum",), 31.0, 35.0),
        PlaceCandidate("b-general", "dest", "General", ("park",), 31.0, 35.0),
        PlaceCandidate("c-general", "dest", "General 2", ("food",), 31.0, 35.0),
    ]

    result = plan_trip("dest", 1, ["museum", "history"], candidates)
    ids = flatten_ids(result)

    assert "z-double" in ids
    assert "a-single" in ids
    assert "c-general" not in ids


def test_relevance_selection_is_not_replaced_by_geographic_closeness() -> None:
    candidates = [
        PlaceCandidate("match-1", "dest", "M1", ("museum",), 0.0, 0.0),
        PlaceCandidate("match-2", "dest", "M2", ("museum",), 40.0, 40.0),
        PlaceCandidate("match-3", "dest", "M3", ("museum",), -40.0, -40.0),
        PlaceCandidate("general-near", "dest", "General", ("park",), 0.0001, 0.0001),
    ]

    result = plan_trip("dest", 1, ["museum"], candidates)

    assert set(flatten_ids(result)) == {"match-1", "match-2", "match-3"}


def test_no_interest_fallback_prefers_category_coverage_before_duplicate_category() -> None:
    candidates = [
        PlaceCandidate("a-museum", "dest", "Museum A", ("museum",), 31.0, 35.0),
        PlaceCandidate("b-museum", "dest", "Museum B", ("museum",), 31.0, 35.0),
        PlaceCandidate("c-park", "dest", "Park", ("park",), 31.0, 35.0),
        PlaceCandidate("d-history", "dest", "History", ("history",), 31.0, 35.0),
    ]

    result = plan_trip("dest", 1, [], candidates)

    assert set(flatten_ids(result)) == {"a-museum", "c-park", "d-history"}


def test_empty_categories_do_not_crash_planner() -> None:
    candidates = [
        PlaceCandidate("a", "dest", "A", (), 31.0, 35.0),
        PlaceCandidate("b", "dest", "B", ("museum",), 31.01, 35.01),
    ]

    result = plan_trip("dest", 2, [], candidates)

    assert_invariants(2, candidates, result)


def test_identical_coordinates_remain_deterministic() -> None:
    candidates = [
        PlaceCandidate("c", "dest", "C", ("museum",), 31.0, 35.0),
        PlaceCandidate("a", "dest", "A", ("museum",), 31.0, 35.0),
        PlaceCandidate("b", "dest", "B", ("museum",), 31.0, 35.0),
    ]

    first = plan_trip("dest", 1, ["museum"], candidates)
    second = plan_trip("dest", 1, ["museum"], list(reversed(candidates)))

    assert first == second
    assert first.days[0].place_ids == ("a", "b", "c")


def test_haversine_same_point_is_zero() -> None:
    a = PlaceCandidate("a", "dest", "A", (), 0.0, 0.0)
    b = PlaceCandidate("b", "dest", "B", (), 0.0, 0.0)

    assert _haversine_km(a, b) == pytest.approx(0.0, abs=1e-12)


def test_haversine_one_degree_at_equator() -> None:
    a = PlaceCandidate("a", "dest", "A", (), 0.0, 0.0)
    b = PlaceCandidate("b", "dest", "B", (), 0.0, 1.0)

    assert _haversine_km(a, b) == pytest.approx(111.195, rel=0.001)


def test_haversine_handles_antimeridian() -> None:
    a = PlaceCandidate("a", "dest", "A", (), 0.0, 179.9)
    b = PlaceCandidate("b", "dest", "B", (), 0.0, -179.9)

    assert _haversine_km(a, b) == pytest.approx(22.239, rel=0.002)


def test_geographic_grouping_keeps_nearby_clusters_together() -> None:
    candidates = [
        PlaceCandidate("a-1", "dest", "A1", ("museum",), 31.000, 35.000),
        PlaceCandidate("a-2", "dest", "A2", ("museum",), 31.001, 35.001),
        PlaceCandidate("b-1", "dest", "B1", ("museum",), 40.000, 44.000),
        PlaceCandidate("b-2", "dest", "B2", ("museum",), 40.001, 44.001),
    ]

    result = plan_trip("dest", 2, ["museum"], candidates)
    day_sets = [set(day.place_ids) for day in result.days]

    assert day_sets == [{"a-1", "a-2"}, {"b-1", "b-2"}]


def test_result_serialization_uses_internal_contract_shape() -> None:
    candidates = make_candidates(2)
    result = plan_trip("dest", 3, [], candidates)
    payload = result.to_dict()

    assert set(payload) == {"days", "warnings"}
    assert [set(day) for day in payload["days"]] == [
        {"day", "placeIds"},
        {"day", "placeIds"},
        {"day", "placeIds"},
    ]
    assert payload["warnings"][0]["code"] == "PARTIAL_ITINERARY"


@pytest.mark.parametrize("days", [0, 15, -1, 1.5, True, "3"])
def test_rejects_invalid_day_values(days: object) -> None:
    with pytest.raises(PlannerInputError, match="days"):
        plan_trip("dest", days, [], [])


@pytest.mark.parametrize("destination_id", ["", "   ", None, 123])
def test_rejects_invalid_destination(destination_id: object) -> None:
    with pytest.raises(PlannerInputError, match="destination"):
        plan_trip(destination_id, 1, [], [])


@pytest.mark.parametrize("interests", ["museum", b"museum", 10])
def test_rejects_non_sequence_interest_inputs(interests: object) -> None:
    with pytest.raises(PlannerInputError, match="interests"):
        plan_trip("dest", 1, interests, [])


@pytest.mark.parametrize("interests", [[""], ["museum", ""], ["museum", 1]])
def test_rejects_invalid_interest_members(interests: object) -> None:
    with pytest.raises(PlannerInputError, match="interests"):
        plan_trip("dest", 1, interests, [])


def test_rejects_duplicate_interest_ids() -> None:
    with pytest.raises(PlannerInputError, match="duplicates"):
        plan_trip("dest", 1, ["museum", "museum"], [])


@pytest.mark.parametrize("candidate_places", [None, "places", b"places", 10])
def test_rejects_invalid_candidate_container(candidate_places: object) -> None:
    with pytest.raises(PlannerInputError, match="candidate_places"):
        plan_trip("dest", 1, [], candidate_places)


def test_rejects_non_candidate_member() -> None:
    with pytest.raises(PlannerInputError, match="PlaceCandidate"):
        plan_trip("dest", 1, [], [{"id": "p-1"}])


def test_large_bounded_pool_preserves_contract() -> None:
    candidates = make_candidates(200)
    result = plan_trip("dest", 14, ["museum", "history"], candidates)

    assert_invariants(14, candidates, result)
    assert len(flatten_ids(result)) == 42
