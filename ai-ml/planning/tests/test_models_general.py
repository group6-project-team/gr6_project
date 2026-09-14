from __future__ import annotations

import math

import pytest

from planning.models import PlaceCandidate


def test_direct_constructor_normalizes_categories_and_coordinates() -> None:
    place = PlaceCandidate(
        id="p-1",
        destination_id="dest",
        name="Place",
        category_ids=["museum", "history"],
        latitude=41,
        longitude=29,
    )

    assert place.category_ids == ("museum", "history")
    assert isinstance(place.latitude, float)
    assert isinstance(place.longitude, float)


@pytest.mark.parametrize(
    ("field", "value"),
    [
        ("id", 10),
        ("destination_id", 10),
        ("name", 10),
        ("id", ""),
        ("destination_id", "   "),
        ("name", ""),
    ],
)
def test_direct_constructor_rejects_invalid_text_fields(field: str, value: object) -> None:
    values = {
        "id": "p-1",
        "destination_id": "dest",
        "name": "Place",
        "category_ids": ("museum",),
        "latitude": 41.0,
        "longitude": 29.0,
    }
    values[field] = value

    with pytest.raises(ValueError):
        PlaceCandidate(**values)


@pytest.mark.parametrize("category_ids", ["museum", b"museum", ("museum", ""), ("museum", "museum")])
def test_direct_constructor_rejects_invalid_categories(category_ids: object) -> None:
    with pytest.raises(ValueError):
        PlaceCandidate("p-1", "dest", "Place", category_ids, 41.0, 29.0)


@pytest.mark.parametrize(
    ("latitude", "longitude"),
    [
        (True, 29.0),
        (41.0, False),
        (91.0, 29.0),
        (-91.0, 29.0),
        (41.0, 181.0),
        (41.0, -181.0),
        (math.nan, 29.0),
        (41.0, math.inf),
        (41.0, -math.inf),
    ],
)
def test_direct_constructor_rejects_invalid_coordinates(latitude: object, longitude: object) -> None:
    with pytest.raises(ValueError):
        PlaceCandidate("p-1", "dest", "Place", ("museum",), latitude, longitude)


def test_from_dict_rejects_missing_required_field() -> None:
    with pytest.raises(ValueError, match="Missing"):
        PlaceCandidate.from_dict(
            {
                "id": "p-1",
                "destinationId": "dest",
                "name": "Place",
                "categoryIds": ["museum"],
                "latitude": 41.0,
            }
        )


@pytest.mark.parametrize(
    "category_ids",
    ["museum", [1], None, {"museum"}],
)
def test_from_dict_rejects_invalid_category_shape(category_ids: object) -> None:
    with pytest.raises(ValueError, match="categoryIds"):
        PlaceCandidate.from_dict(
            {
                "id": "p-1",
                "destinationId": "dest",
                "name": "Place",
                "categoryIds": category_ids,
                "latitude": 41.0,
                "longitude": 29.0,
            }
        )


@pytest.mark.parametrize(
    ("latitude", "longitude"),
    [(True, 29.0), (41.0, False), ("41.0", 29.0), (41.0, "29.0")],
)
def test_from_dict_rejects_non_numeric_coordinates(latitude: object, longitude: object) -> None:
    with pytest.raises(ValueError):
        PlaceCandidate.from_dict(
            {
                "id": "p-1",
                "destinationId": "dest",
                "name": "Place",
                "categoryIds": ["museum"],
                "latitude": latitude,
                "longitude": longitude,
            }
        )
