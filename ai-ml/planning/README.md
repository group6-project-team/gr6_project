# Planning Baseline v0

This folder contains the first recommendation and itinerary-planning baseline for the trip planning project.

The planner does not fetch places and does not return Flutter display data. It receives normalized `PlaceCandidate` records from the Backend and returns only the internal planning result: day numbers, selected place IDs, and coverage warnings.

## Input

The planner receives:

- `destinationId`
- `days` from 1 to 14
- optional `interests[]`
- `candidatePlaces[]`

Each candidate contains:

- `id`
- `destinationId`
- `name`
- `categoryIds`
- `latitude`
- `longitude`

The Backend is expected to send candidates that are already normalized, eligible, unique, and part of the requested destination. The planner still rejects invalid day values, duplicate candidate IDs, duplicate interests, and destination mismatches instead of silently fixing them.

## Current planning logic

The first version is deterministic. It is a baseline, not a trained ML model.

1. Rank candidates using interest/category overlap when interests are provided.
2. If interests are empty, use a deterministic category-diversity fallback and stable ID ordering. This avoids inventing rating or popularity signals that are not part of the current contract.
3. Select exactly:

```text
N = min(E, 3 * D)
```

where `E` is the number of candidates and `D` is the number of requested days.

4. Build fixed daily capacities:

```text
q = N // D
r = N % D
```

The first `r` days receive `q + 1` places. The remaining days receive `q` places.

5. Group selected places geographically with Haversine distance while keeping the fixed capacities unchanged.
6. Order places inside each day with a deterministic nearest-neighbor heuristic.
7. Return coverage warnings when needed.

The geographic step is only a simple heuristic. It is not an optimal routing algorithm and does not claim travel-time optimization.

## Warning rules

```text
N = 0       -> NO_PLACES_AVAILABLE
0 < N < D   -> PARTIAL_ITINERARY
N >= D      -> no coverage warning
```

`NO_PLACES_AVAILABLE` means no suitable places were found in the candidate pool received by the planner. It does not mean the destination itself has no places.

## Files

```text
planning/
├── __init__.py
├── models.py
├── planner.py
├── run_example.py
├── fixtures/
│   ├── normal.json
│   ├── selection_limit.json
│   ├── partial.json
│   ├── empty.json
│   └── no_interests.json
└── tests/
    └── test_planner.py
```

## Run an example

From the repository root:

```bash
python ai-ml/planning/run_example.py
```

A different fixture can be passed by filename:

```bash
python ai-ml/planning/run_example.py partial.json
```

## Run the tests

`pytest` is only needed for the test suite.

```bash
python -m pytest ai-ml/planning/tests -q
```

The tests cover the fixture cases plus broader boundary, randomized, validation, determinism, ranking, geography, serialization, and capacity checks.

## Deferred work

This task intentionally does not include:

- FastAPI endpoints
- Places Provider integration
- Provider normalization
- embeddings
- model training
- budget logic
- database work
- Flutter integration
- deployment

FastAPI can later call `plan_trip()` without moving the planning rules into the API layer.

## Interest IDs in this baseline

`plan_trip()` expects the values in `interests` to use the same canonical category IDs used by `PlaceCandidate.categoryIds`.

The mobile app may expose higher-level interest IDs later. Those app interest IDs should be mapped through the shared taxonomy before the planner is called. That mapping does not belong inside this planning baseline, and Provider-specific category mapping remains a Backend responsibility.

This keeps the planner independent from Flutter options and Provider category codes.
