from __future__ import annotations

import importlib

import pytest
from fastapi.testclient import TestClient

from planning.planner import PlannerInputError
from service.app import app
from service.schemas import ErrorResponse


client = TestClient(app, raise_server_exceptions=False)


def candidate(index: int, destination: str = "rome-it") -> dict:
    return {
        "id": f"place-{index}",
        "destinationId": destination,
        "name": f"Place {index}",
        "categoryIds": ["museum" if index % 2 else "park"],
        "latitude": 41.9 + index / 10_000,
        "longitude": 12.5 + index / 10_000,
    }


def request_body(days: int = 2, count: int = 4, interests=...) -> dict:
    body = {
        "destinationId": "rome-it",
        "days": days,
        "candidatePlaces": [candidate(index) for index in range(count)],
    }
    if interests is not ...:
        body["interests"] = interests
    return body


def test_health_is_ready_and_propagates_valid_request_id() -> None:
    response = client.get("/health", headers={"X-Request-ID": "backend-request-42"})
    assert response.status_code == 200
    assert response.json() == {"status": "ready"}
    assert response.headers["X-Request-ID"] == "backend-request-42"


def test_invalid_request_id_is_replaced() -> None:
    response = client.get("/health", headers={"X-Request-ID": "bad\nvalue"})
    assert response.status_code == 200
    assert response.headers["X-Request-ID"] != "bad\nvalue"
    assert len(response.headers["X-Request-ID"]) == 32


def test_valid_plan_has_camel_case_ids_only_and_balanced_days() -> None:
    response = client.post("/plan", json=request_body(days=2, count=8, interests=["museum"]))
    assert response.status_code == 200
    payload = response.json()
    assert payload["warnings"] == []
    assert [day["day"] for day in payload["days"]] == [1, 2]
    assert [len(day["placeIds"]) for day in payload["days"]] == [3, 3]
    selected = [place_id for day in payload["days"] for place_id in day["placeIds"]]
    assert len(selected) == len(set(selected)) == 6
    assert set(selected) <= {f"place-{index}" for index in range(8)}
    assert "place_ids" not in response.text
    assert "name" not in response.text


@pytest.mark.parametrize("interests", [..., None, []])
def test_omitted_null_and_empty_interests_are_equivalent(interests) -> None:
    response = client.post("/plan", json=request_body(interests=interests))
    assert response.status_code == 200
    assert response.json() == client.post("/plan", json=request_body(interests=[])).json()


def test_zero_candidates_returns_every_day_and_structured_warning() -> None:
    response = client.post("/plan", json=request_body(days=3, count=0, interests=[]))
    assert response.status_code == 200
    payload = response.json()
    assert payload["days"] == [
        {"day": 1, "placeIds": []},
        {"day": 2, "placeIds": []},
        {"day": 3, "placeIds": []},
    ]
    assert payload["warnings"] == [{
        "code": "NO_PLACES_AVAILABLE",
        "message": "No suitable places were found in the current candidate pool.",
    }]


def test_partial_itinerary_warning() -> None:
    response = client.post("/plan", json=request_body(days=4, count=2, interests=[]))
    assert response.status_code == 200
    assert response.json()["warnings"][0]["code"] == "PARTIAL_ITINERARY"
    assert len(response.json()["days"]) == 4


@pytest.mark.parametrize("days", [0, 15, True, 1.5, "3"])
def test_invalid_days_are_rejected(days) -> None:
    response = client.post("/plan", json=request_body(days=days))
    assert response.status_code == 422


@pytest.mark.parametrize(
    ("field", "value"),
    [("latitude", -90.1), ("latitude", 90.1), ("longitude", -180.1), ("longitude", 180.1)],
)
def test_out_of_range_coordinates_are_rejected(field: str, value: float) -> None:
    body = request_body()
    body["candidatePlaces"][0][field] = value
    assert client.post("/plan", json=body).status_code == 422


@pytest.mark.parametrize("value", ["NaN", "Infinity", "-Infinity"])
def test_non_finite_coordinates_are_rejected(value: str) -> None:
    body = request_body()
    body["candidatePlaces"][0]["latitude"] = value
    assert client.post("/plan", json=body).status_code == 422


def test_invalid_candidate_shape_and_extra_fields_are_rejected() -> None:
    body = request_body()
    del body["candidatePlaces"][0]["id"]
    assert client.post("/plan", json=body).status_code == 422

    top_extra = request_body()
    top_extra["provider"] = "geoapify"
    assert client.post("/plan", json=top_extra).status_code == 422

    candidate_extra = request_body()
    candidate_extra["candidatePlaces"][0]["rating"] = 5
    assert client.post("/plan", json=candidate_extra).status_code == 422


@pytest.mark.parametrize(
    "mutate",
    [
        lambda body: body["candidatePlaces"].append(body["candidatePlaces"][0].copy()),
        lambda body: body["candidatePlaces"][0].update(destinationId="paris-fr"),
        lambda body: body.update(interests=["museum", "museum"]),
    ],
)
def test_planner_domain_rejections_are_controlled(mutate) -> None:
    body = request_body(interests=[])
    mutate(body)
    response = client.post("/plan", json=body)
    assert response.status_code == 422
    assert ErrorResponse.model_validate(response.json()).code == "INVALID_PLANNING_INPUT"
    assert response.json() == {
        "code": "INVALID_PLANNING_INPUT",
        "message": "The planning request violates planner constraints.",
    }


def test_candidate_limit_is_configurable_and_checked(monkeypatch) -> None:
    monkeypatch.setenv("PLANNING_MAX_CANDIDATES", "2")
    response = client.post("/plan", json=request_body(count=3))
    assert response.status_code == 413
    assert response.json()["code"] == "CANDIDATE_LIMIT_EXCEEDED"


def test_known_and_unexpected_planner_failures_do_not_leak(monkeypatch) -> None:
    app_module = importlib.import_module("service.app")

    def known_failure(*args, **kwargs):
        raise PlannerInputError("secret domain detail at C:/private/path")

    monkeypatch.setattr(app_module, "plan_trip", known_failure)
    known = client.post("/plan", json=request_body())
    assert known.status_code == 422
    assert "secret" not in known.text
    assert "private" not in known.text

    def unexpected_failure(*args, **kwargs):
        raise RuntimeError("token=secret at C:/private/path")

    monkeypatch.setattr(app_module, "plan_trip", unexpected_failure)
    unexpected = client.post("/plan", json=request_body())
    assert unexpected.status_code == 500
    assert unexpected.json()["code"] == "INTERNAL_PLANNING_ERROR"
    assert "secret" not in unexpected.text
    assert "private" not in unexpected.text


def test_openapi_contract_has_only_canonical_fields() -> None:
    schema = client.get("/openapi.json").json()
    assert "/health" in schema["paths"]
    assert "/plan" in schema["paths"]
    request_schema = schema["components"]["schemas"]["PlanRequest"]
    assert set(request_schema["properties"]) == {
        "destinationId", "days", "interests", "candidatePlaces"
    }
    candidate_schema = schema["components"]["schemas"]["PlaceCandidateRequest"]
    assert set(candidate_schema["properties"]) == {
        "id", "destinationId", "name", "categoryIds", "latitude", "longitude"
    }
    schema_text = str(schema).lower()
    for provider_field in ("geoapify", "rating", "price", "website", "opening hours"):
        assert provider_field not in schema_text


@pytest.mark.parametrize("malformed_json", [False, True])
def test_transport_validation_uses_generic_error_envelope(malformed_json, caplog) -> None:
    marker = "PRIVATE_PAYLOAD_C:/private/path"
    if malformed_json:
        response = client.post(
            "/plan", content='{"days": "' + marker,
            headers={"Content-Type": "application/json"},
        )
    else:
        response = client.post("/plan", json=request_body(days=marker))
    assert response.status_code == 422
    error = ErrorResponse.model_validate(response.json())
    assert error.code == "INVALID_REQUEST"
    assert error.message == "The planning request is invalid."
    assert set(response.json()) == {"code", "message"}
    for forbidden in ("detail", "traceback", "loc", "input", marker):
        assert forbidden not in response.text
    assert marker not in caplog.text
    assert response.headers["X-Request-ID"] in caplog.text


def test_openapi_422_matches_runtime_error_model() -> None:
    schema = client.get("/openapi.json").json()
    documented = schema["paths"]["/plan"]["post"]["responses"]["422"]
    assert documented["content"]["application/json"]["schema"] == {
        "$ref": "#/components/schemas/ErrorResponse"
    }
    assert schema["components"]["schemas"]["ErrorResponse"] == ErrorResponse.model_json_schema()
    response = client.post("/plan", json=request_body(days=0))
    assert response.status_code == 422
    assert ErrorResponse.model_validate(response.json()).code == "INVALID_REQUEST"


@pytest.mark.parametrize("request_id", ["backend-validation-42", None, "invalid value"])
def test_validation_failure_preserves_request_id_policy(request_id) -> None:
    headers = {"X-Request-ID": request_id} if request_id is not None else {}
    response = client.post("/plan", json=request_body(days=0), headers=headers)
    assert response.status_code == 422
    returned = response.headers["X-Request-ID"]
    if request_id == "backend-validation-42":
        assert returned == request_id
    else:
        assert len(returned) == 32
        assert all(character in "0123456789abcdef" for character in returned)
