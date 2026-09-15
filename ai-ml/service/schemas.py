from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field, StrictInt, StrictStr, field_validator

from planning.models import PlaceCandidate, PlanningResult


NonEmptyId = Annotated[StrictStr, Field(min_length=1, max_length=200)]


class StrictTransportModel(BaseModel):
    model_config = ConfigDict(extra="forbid", populate_by_name=False)


class PlaceCandidateRequest(StrictTransportModel):
    id: NonEmptyId
    destination_id: NonEmptyId = Field(alias="destinationId")
    name: Annotated[StrictStr, Field(min_length=1, max_length=500)]
    category_ids: list[NonEmptyId] = Field(alias="categoryIds", max_length=100)
    latitude: float = Field(ge=-90.0, le=90.0, allow_inf_nan=False)
    longitude: float = Field(ge=-180.0, le=180.0, allow_inf_nan=False)

    @field_validator("id", "destination_id", "name")
    @classmethod
    def reject_blank_strings(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("must not be blank")
        return value

    @field_validator("category_ids")
    @classmethod
    def validate_categories(cls, value: list[str]) -> list[str]:
        if any(not category_id.strip() for category_id in value):
            raise ValueError("category IDs must not be blank")
        if len(set(value)) != len(value):
            raise ValueError("category IDs must be unique per candidate")
        return value

    def to_domain(self) -> PlaceCandidate:
        return PlaceCandidate(
            id=self.id,
            destination_id=self.destination_id,
            name=self.name,
            category_ids=tuple(self.category_ids),
            latitude=self.latitude,
            longitude=self.longitude,
        )


class PlanRequest(StrictTransportModel):
    destination_id: NonEmptyId = Field(alias="destinationId")
    days: StrictInt = Field(ge=1, le=14)
    interests: list[NonEmptyId] | None = Field(default=None, max_length=100)
    candidate_places: list[PlaceCandidateRequest] = Field(alias="candidatePlaces")

    @field_validator("destination_id")
    @classmethod
    def reject_blank_destination(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("must not be blank")
        return value

    @field_validator("interests")
    @classmethod
    def validate_interests(cls, value: list[str] | None) -> list[str] | None:
        if value is None:
            return value
        if any(not interest.strip() for interest in value):
            raise ValueError("interest IDs must not be blank")
        return value


class PlanningDayResponse(StrictTransportModel):
    day: int
    place_ids: list[str] = Field(alias="placeIds")


class PlanningWarningResponse(StrictTransportModel):
    code: str
    message: str


class PlanResponse(StrictTransportModel):
    days: list[PlanningDayResponse]
    warnings: list[PlanningWarningResponse]

    @classmethod
    def from_domain(cls, result: PlanningResult) -> "PlanResponse":
        return cls.model_validate(result.to_dict())


class HealthResponse(StrictTransportModel):
    status: str


class ErrorResponse(StrictTransportModel):
    code: str
    message: str
