from __future__ import annotations

import logging
import re
from uuid import uuid4

from fastapi import FastAPI, Header, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from planning.planner import PlannerInputError, plan_trip
from service.config import get_max_candidates
from service.schemas import ErrorResponse, HealthResponse, PlanRequest, PlanResponse


LOGGER = logging.getLogger("uvicorn.error.planning_service")
LOGGER.setLevel(logging.INFO)
REQUEST_ID_HEADER = "X-Request-ID"
REQUEST_ID_PATTERN = re.compile(r"^[A-Za-z0-9._:-]{1,64}$")

app = FastAPI(
    title="Planning Service",
    version="0.1.0",
    description="Provider-independent HTTP boundary for the deterministic planner.",
)


def _request_id(value: str | None) -> str:
    if value and REQUEST_ID_PATTERN.fullmatch(value):
        return value
    return uuid4().hex


@app.middleware("http")
async def add_request_id(request: Request, call_next):
    request_id = _request_id(request.headers.get(REQUEST_ID_HEADER))
    request.state.request_id = request_id
    response = await call_next(request)
    response.headers[REQUEST_ID_HEADER] = request_id
    return response


@app.exception_handler(RequestValidationError)
async def request_validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    LOGGER.warning(
        "planning rejected request_id=%s reason=request_validation",
        request.state.request_id,
    )
    return JSONResponse(
        status_code=422,
        content=ErrorResponse(
            code="INVALID_REQUEST",
            message="The planning request is invalid.",
        ).model_dump(),
    )


@app.get("/health", response_model=HealthResponse, tags=["readiness"])
def health() -> HealthResponse:
    get_max_candidates()
    if not callable(plan_trip):
        raise RuntimeError("planner unavailable")
    return HealthResponse(status="ready")


@app.post(
    "/plan",
    response_model=PlanResponse,
    responses={
        413: {"model": ErrorResponse},
        422: {"model": ErrorResponse},
        500: {"model": ErrorResponse},
    },
    tags=["planning"],
)
def plan(
    payload: PlanRequest,
    request: Request,
    x_request_id: str | None = Header(default=None, alias=REQUEST_ID_HEADER),
) -> PlanResponse | JSONResponse:
    del x_request_id  # Middleware owns sanitization and propagation.
    request_id = request.state.request_id
    maximum = get_max_candidates()
    if len(payload.candidate_places) > maximum:
        LOGGER.warning("planning rejected request_id=%s reason=candidate_limit", request_id)
        return JSONResponse(
            status_code=413,
            content={
                "code": "CANDIDATE_LIMIT_EXCEEDED",
                "message": f"candidatePlaces must contain at most {maximum} items.",
            },
        )

    try:
        candidates = [candidate.to_domain() for candidate in payload.candidate_places]
        result = plan_trip(
            payload.destination_id,
            payload.days,
            payload.interests or (),
            candidates,
        )
    except PlannerInputError:
        LOGGER.warning("planning rejected request_id=%s reason=domain_input", request_id)
        return JSONResponse(
            status_code=422,
            content={
                "code": "INVALID_PLANNING_INPUT",
                "message": "The planning request violates planner constraints.",
            },
        )
    except Exception:
        LOGGER.error("planning failed request_id=%s reason=unexpected", request_id)
        return JSONResponse(
            status_code=500,
            content={
                "code": "INTERNAL_PLANNING_ERROR",
                "message": "The planning service could not complete the request.",
            },
        )

    LOGGER.info(
        "planning completed request_id=%s candidates=%d days=%d warnings=%d",
        request_id,
        len(candidates),
        payload.days,
        len(result.warnings),
    )
    return PlanResponse.from_domain(result)
