# Planning Service Contract v0

This contract defines the internal Backend-to-FastAPI boundary. FastAPI is not a public or Flutter-facing API. JSON field names use camelCase; Python implementation names use snake_case.

## `GET /health`

Returns `200 {"status":"ready"}` when the configured candidate guard is valid and the planner entry point is available. It does not call or depend on a Places Provider.

## `POST /plan`

Example request:

```json
{
  "destinationId": "rome-it",
  "days": 3,
  "interests": ["museum"],
  "candidatePlaces": [
    {
      "id": "place-1",
      "destinationId": "rome-it",
      "name": "Example Museum",
      "categoryIds": ["museum"],
      "latitude": 41.9,
      "longitude": 12.5
    }
  ]
}
```

`days` is a strict integer from 1 through 14. IDs and names are non-blank strings. Coordinates must be finite and within latitude `[-90,90]` and longitude `[-180,180]`. Extra fields are rejected at the request and candidate levels. Candidate IDs must be unique and every candidate must match `destinationId`.

`interests` contains canonical category IDs, treated as opaque identifiers. It never contains public app-interest IDs or raw Provider categories. Omitted, `null`, and `[]` all mean no explicit interests. Duplicate interests remain invalid according to the planner domain contract.

The only permitted candidate fields are `id`, `destinationId`, `name`, `categoryIds`, `latitude`, and `longitude`. Display metadata, raw Provider data, and credentials are excluded.

Example response:

```json
{
  "days": [
    {"day": 1, "placeIds": ["place-1"]},
    {"day": 2, "placeIds": []},
    {"day": 3, "placeIds": []}
  ],
  "warnings": [
    {
      "code": "PARTIAL_ITINERARY",
      "message": "The current candidate pool does not contain enough places to cover every requested day."
    }
  ]
}
```

All requested days are returned. Responses contain selected IDs rather than place metadata. Selection, ranking, allocation, geography, ordering, and warning semantics come solely from the existing `plan_trip()` implementation.

## Operational guard and correlation

The service rejects more than `PLANNING_MAX_CANDIDATES` candidates with HTTP 413. The development default is 500 and deployments may configure an integer from 1 to 10,000. Backend and FastAPI configuration must be coordinated before Stage 2A.

`X-Request-ID` is accepted and returned. It permits 1–64 letters, digits, dots, underscores, colons, or hyphens. The service replaces a missing or invalid value and does not log request payloads.

## Error mapping

Controlled service errors have `{ "code": "...", "message": "..." }`:

- `413 CANDIDATE_LIMIT_EXCEEDED`
- `422 INVALID_REQUEST` for transport/schema validation or malformed JSON, with message `The planning request is invalid.`
- `422 INVALID_PLANNING_INPUT` for a known planner-domain rejection
- `500 INTERNAL_PLANNING_ERROR` for an unexpected planning failure

Both 422 paths use the same `ErrorResponse` envelope documented by OpenAPI, with distinct codes for transport and domain failures. Raw validation details, request bodies, and internal exception information are never returned. The existing `X-Request-ID` policy applies to validation failures too. Public Backend codes and timeout/unavailable mapping remain Backend responsibilities.
