# Planning Service v0

This is the internal, provider-independent FastAPI boundary around the existing deterministic planner. The Backend sends canonical candidates; this service converts them into planner domain models and calls `plan_trip()`.

## Setup and run

Tested with Python 3.14. From the repository root:

```bash
python -m pip install -r ai-ml/service/requirements-dev.txt
cd ai-ml
python -m uvicorn service.app:app --host 127.0.0.1 --port 8001
```

Readiness is available at `http://127.0.0.1:8001/health`; generated API documentation is at `http://127.0.0.1:8001/docs`.

The service accepts and returns `X-Request-ID`. Values must contain 1–64 letters, digits, dots, underscores, colons, or hyphens. Missing or invalid values are replaced. Logs include this ID and concise outcome data, never full candidate payloads.

## Candidate guard

`PLANNING_MAX_CANDIDATES` controls the maximum accepted candidate count and defaults to 500. This is an integration safety guard rather than a product limit. It must be an integer from 1 to 10,000; invalid configuration makes readiness fail. The later Backend client must use the same or a smaller bound.

## Tests

From the repository root:

```bash
python -m pytest ai-ml/service/tests -q
python -m pytest ai-ml/planning/tests -q
python ai-ml/planning/run_example.py
```

## Internal errors

- Invalid HTTP schema or malformed JSON: `422` with `INVALID_REQUEST` and message `The planning request is invalid.`.
- Planner domain rejection: `422` with `INVALID_PLANNING_INPUT`.
- Candidate guard exceeded: `413` with `CANDIDATE_LIMIT_EXCEEDED`.
- Unexpected planning failure: `500` with `INTERNAL_PLANNING_ERROR`.

These are internal service errors. The Backend owns mapping dependency failures to public API error codes.

Both 422 paths use the documented `{code,message}` envelope. Validation details and request bodies are not returned or logged; `X-Request-ID` follows the same policy on validation failures as on successful requests.
