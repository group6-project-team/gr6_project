from __future__ import annotations

from dataclasses import dataclass
from math import isfinite
from typing import Any, Mapping


@dataclass(frozen=True, slots=True)
class PlaceCandidate:
    id: str
    destination_id: str
    name: str
    category_ids: tuple[str, ...]
    latitude: float
    longitude: float

    def __post_init__(self) -> None:
        for field_name in ("id", "destination_id", "name"):
            value = getattr(self, field_name)
            if not isinstance(value, str) or not value.strip():
                raise ValueError(f"PlaceCandidate.{field_name} must be a non-empty string")

        raw_categories = self.category_ids
        if isinstance(raw_categories, (str, bytes)) or not isinstance(raw_categories, (tuple, list)):
            raise ValueError("PlaceCandidate.category_ids must be a sequence of strings")
        if not all(isinstance(category_id, str) and category_id.strip() for category_id in raw_categories):
            raise ValueError(f"Invalid category ID for place {self.id}")

        normalized_categories = tuple(raw_categories)
        if len(set(normalized_categories)) != len(normalized_categories):
            raise ValueError(f"Duplicate category IDs are not allowed for place {self.id}")
        object.__setattr__(self, "category_ids", normalized_categories)

        for field_name, lower, upper in (
            ("latitude", -90.0, 90.0),
            ("longitude", -180.0, 180.0),
        ):
            value = getattr(self, field_name)
            if isinstance(value, bool) or not isinstance(value, (int, float)):
                raise ValueError(f"{field_name} must be numeric for place {self.id}")
            normalized_value = float(value)
            if not isfinite(normalized_value) or not lower <= normalized_value <= upper:
                raise ValueError(f"Invalid {field_name} for place {self.id}")
            object.__setattr__(self, field_name, normalized_value)

    @classmethod
    def from_dict(cls, data: Mapping[str, Any]) -> "PlaceCandidate":
        if not isinstance(data, Mapping):
            raise ValueError("PlaceCandidate data must be a mapping")

        required = {"id", "destinationId", "name", "categoryIds", "latitude", "longitude"}
        missing = required.difference(data)
        if missing:
            raise ValueError(f"Missing PlaceCandidate fields: {sorted(missing)}")

        for field_name in ("id", "destinationId", "name"):
            if not isinstance(data[field_name], str):
                raise ValueError(f"{field_name} must be a string")

        raw_categories = data["categoryIds"]
        if not isinstance(raw_categories, list) or not all(isinstance(item, str) for item in raw_categories):
            raise ValueError("categoryIds must be a list of strings")

        latitude = data["latitude"]
        longitude = data["longitude"]
        if isinstance(latitude, bool) or not isinstance(latitude, (int, float)):
            raise ValueError("latitude must be numeric")
        if isinstance(longitude, bool) or not isinstance(longitude, (int, float)):
            raise ValueError("longitude must be numeric")

        return cls(
            id=data["id"],
            destination_id=data["destinationId"],
            name=data["name"],
            category_ids=tuple(raw_categories),
            latitude=float(latitude),
            longitude=float(longitude),
        )


@dataclass(frozen=True, slots=True)
class PlanningDay:
    day: int
    place_ids: tuple[str, ...]

    def to_dict(self) -> dict[str, Any]:
        return {"day": self.day, "placeIds": list(self.place_ids)}


@dataclass(frozen=True, slots=True)
class PlanningWarning:
    code: str
    message: str

    def to_dict(self) -> dict[str, str]:
        return {"code": self.code, "message": self.message}


@dataclass(frozen=True, slots=True)
class PlanningResult:
    days: tuple[PlanningDay, ...]
    warnings: tuple[PlanningWarning, ...]

    def to_dict(self) -> dict[str, Any]:
        return {
            "days": [day.to_dict() for day in self.days],
            "warnings": [warning.to_dict() for warning in self.warnings],
        }
