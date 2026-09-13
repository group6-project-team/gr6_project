from __future__ import annotations

from math import asin, cos, radians, sin, sqrt
from typing import Sequence

from .models import PlaceCandidate, PlanningDay, PlanningResult, PlanningWarning


class PlannerInputError(ValueError):
    pass


def _validate_request(
    destination_id: str,
    days: int,
    interests: Sequence[str],
    candidate_places: Sequence[PlaceCandidate],
) -> None:
    if not isinstance(destination_id, str) or not destination_id.strip():
        raise PlannerInputError("destination_id must not be empty")
    if isinstance(days, bool) or not isinstance(days, int) or not 1 <= days <= 14:
        raise PlannerInputError("days must be an integer from 1 to 14")

    if any(not isinstance(interest, str) or not interest.strip() for interest in interests):
        raise PlannerInputError("interests must contain non-empty string IDs")
    if len(set(interests)) != len(interests):
        raise PlannerInputError("interests must not contain duplicates")

    if any(not isinstance(place, PlaceCandidate) for place in candidate_places):
        raise PlannerInputError("candidate_places must contain PlaceCandidate values")

    place_ids = [place.id for place in candidate_places]
    if len(set(place_ids)) != len(place_ids):
        raise PlannerInputError("candidate place IDs must be unique")

    for place in candidate_places:
        if place.destination_id != destination_id:
            raise PlannerInputError(
                f"candidate {place.id} belongs to {place.destination_id}, not {destination_id}"
            )


def _interest_match_count(place: PlaceCandidate, interests: frozenset[str]) -> int:
    return len(interests.intersection(place.category_ids))


def _rank_places(
    candidate_places: Sequence[PlaceCandidate],
    interests: Sequence[str],
) -> list[PlaceCandidate]:
    interest_set = frozenset(interests)
    if interest_set:
        return sorted(
            candidate_places,
            key=lambda place: (-_interest_match_count(place, interest_set), place.id),
        )

    covered_categories: set[str] = set()
    remaining = sorted(candidate_places, key=lambda place: place.id)
    ranked: list[PlaceCandidate] = []

    while remaining:
        best = min(
            remaining,
            key=lambda place: (
                -len(set(place.category_ids).difference(covered_categories)),
                place.id,
            ),
        )
        ranked.append(best)
        covered_categories.update(best.category_ids)
        remaining.remove(best)

    return ranked


def _haversine_km(a: PlaceCandidate, b: PlaceCandidate) -> float:
    earth_radius_km = 6371.0088
    lat1 = radians(a.latitude)
    lon1 = radians(a.longitude)
    lat2 = radians(b.latitude)
    lon2 = radians(b.longitude)
    dlat = lat2 - lat1
    dlon = lon2 - lon1

    value = sin(dlat / 2.0) ** 2 + cos(lat1) * cos(lat2) * sin(dlon / 2.0) ** 2
    value = min(1.0, max(0.0, value))
    return 2.0 * earth_radius_km * asin(sqrt(value))


def _balanced_capacities(selected_count: int, days: int) -> list[int]:
    base, extra = divmod(selected_count, days)
    return [base + (1 if index < extra else 0) for index in range(days)]


def _group_by_geography(
    selected: Sequence[PlaceCandidate],
    capacities: Sequence[int],
    rank_index: dict[str, int],
) -> list[list[PlaceCandidate]]:
    remaining = list(selected)
    groups: list[list[PlaceCandidate]] = []

    for capacity in capacities:
        if capacity == 0:
            groups.append([])
            continue

        seed = min(remaining, key=lambda place: (rank_index[place.id], place.id))
        group = [seed]
        remaining.remove(seed)

        while len(group) < capacity:
            next_place = min(
                remaining,
                key=lambda place: (
                    min(_haversine_km(place, chosen) for chosen in group),
                    rank_index[place.id],
                    place.id,
                ),
            )
            group.append(next_place)
            remaining.remove(next_place)

        groups.append(group)

    return groups


def _order_within_day(
    group: Sequence[PlaceCandidate],
    rank_index: dict[str, int],
) -> list[PlaceCandidate]:
    if len(group) <= 1:
        return list(group)

    remaining = list(group)
    current = min(remaining, key=lambda place: (rank_index[place.id], place.id))
    ordered = [current]
    remaining.remove(current)

    while remaining:
        current = min(
            remaining,
            key=lambda place: (
                _haversine_km(ordered[-1], place),
                rank_index[place.id],
                place.id,
            ),
        )
        ordered.append(current)
        remaining.remove(current)

    return ordered


def _coverage_warnings(selected_count: int, days: int) -> tuple[PlanningWarning, ...]:
    if selected_count == 0:
        return (
            PlanningWarning(
                code="NO_PLACES_AVAILABLE",
                message="No suitable places were found in the current candidate pool.",
            ),
        )
    if selected_count < days:
        return (
            PlanningWarning(
                code="PARTIAL_ITINERARY",
                message="The current candidate pool does not contain enough places to cover every requested day.",
            ),
        )
    return ()


def _normalize_interests(interests: Sequence[str] | None) -> tuple[str, ...]:
    if interests is None:
        return ()
    if isinstance(interests, (str, bytes)):
        raise PlannerInputError("interests must be a sequence of string IDs")
    try:
        return tuple(interests)
    except TypeError as exc:
        raise PlannerInputError("interests must be a sequence of string IDs") from exc


def _normalize_candidates(candidate_places: Sequence[PlaceCandidate]) -> tuple[PlaceCandidate, ...]:
    if candidate_places is None or isinstance(candidate_places, (str, bytes)):
        raise PlannerInputError("candidate_places must be a sequence of PlaceCandidate values")
    try:
        return tuple(candidate_places)
    except TypeError as exc:
        raise PlannerInputError("candidate_places must be a sequence of PlaceCandidate values") from exc


def plan_trip(
    destination_id: str,
    days: int,
    interests: Sequence[str] | None,
    candidate_places: Sequence[PlaceCandidate],
) -> PlanningResult:
    normalized_interests = _normalize_interests(interests)
    candidates = _normalize_candidates(candidate_places)

    _validate_request(destination_id, days, normalized_interests, candidates)

    ranked = _rank_places(candidates, normalized_interests)
    selected_count = min(len(ranked), 3 * days)
    selected = ranked[:selected_count]
    capacities = _balanced_capacities(selected_count, days)
    rank_index = {place.id: index for index, place in enumerate(ranked)}
    groups = _group_by_geography(selected, capacities, rank_index)

    planning_days = tuple(
        PlanningDay(
            day=day_number,
            place_ids=tuple(place.id for place in _order_within_day(group, rank_index)),
        )
        for day_number, group in enumerate(groups, start=1)
    )

    return PlanningResult(
        days=planning_days,
        warnings=_coverage_warnings(selected_count, days),
    )
