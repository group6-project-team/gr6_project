from __future__ import annotations

from typing import Any, Mapping


def normalize_integrated_response(
    response: Mapping[str, Any],
) -> dict[str, Any]:
    """
    Normalize the mobile/backend integrated response into the shape
    expected by the existing independent evaluation checker.

    This function performs contract-shape normalization only.
    It does not implement planner selection, capacity distribution,
    ranking, or warning logic.
    """

    normalized_days: list[dict[str, Any]] = []

    for day in response.get("days", []):
        normalized_days.append(
            {
                "day": day.get("dayNumber"),
                "placeIds": [
                    place.get("id")
                    for place in day.get("places", [])
                ],
            }
        )

    normalized_warnings = [
        warning.get("code")
        for warning in response.get("warnings", [])
    ]

    return {
        "days": normalized_days,
        "warnings": normalized_warnings,
    }