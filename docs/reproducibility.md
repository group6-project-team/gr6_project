# Final-sprint architecture and reproducibility

This document describes the behavior present on merged `main` at
`2d2e1f7019fa0db97a5274c9c632eef67c54ed0c`. It separates merged behavior
from release evidence that is still pending. Stage 2B is closed. Stage 3 and
final release verification are **WAITING**, not GREEN.

## Runtime path and ownership

The public planning path is:

1. Flutter sends a request to `POST /trip-plans/preview` on the ASP.NET
   Backend.
2. The Backend selects an explicit `ICandidateSource`:
   `FixtureCandidateSource` for the closed Stage 2B fixture flow, or
   `GeoapifyCandidateSource` for Stage 3.
3. The selected source produces canonical `PlaceCandidate` values. For the
   provider flow, the Backend owns the Geoapify request, Fatih membership
   checks, provider-to-canonical category mapping, candidate IDs, filtering,
   and provider credentials.
4. The Backend maps public interests to canonical category IDs and sends the
   canonical candidate array to FastAPI `POST /plan`.
5. FastAPI validates the provider-independent transport contract and calls
   the deterministic `plan_trip()` implementation.
6. The Backend validates the planning result, enriches selected IDs from its
   candidate lookup, and returns the public response to Flutter.

FastAPI and the planner do not know about Geoapify DTOs, membership rules,
API keys, or provider category strings. Provider behavior must stay in the
Backend. `/plan.interests` contains canonical category IDs only.

## Current release scope

The minimum real-provider Stage 3 scope is:

- public destination ID: `istanbul`;
- provider candidate area: Fatih, Istanbul, Turkey;
- public interests: `history` and `landmark`;
- public-to-canonical mapping: `history` -> `historic_site`, and `landmark`
  -> `monument`.

The development fixture catalog contains additional destinations and
interests. Their presence does not extend the minimum real-provider release
scope. The current Geoapify client rejects destinations other than public
`istanbul`.

Budget is disabled for this release. The candidate and response contracts do
not provide price semantics. Missing or unknown price information must not be
treated as zero cost or `FREE`.

## Explicit candidate-source policy

`CANDIDATE_SOURCE_MODE` must explicitly select `Fixture` or `Geoapify`.
The development settings select `Fixture`; Stage 3 must explicitly select
`Geoapify`. Missing or unsupported values stop Backend startup. Provider
errors do not silently fall back to fixture candidates or mock success.

The provider key is read server-side from `GEOAPIFY_API_KEY`. Never put a
real key in source control, client configuration, logs, screenshots, or saved
request evidence. The provider request is server-owned, Fatih-bounded, and
currently limited to 20 returned records.

## Configuration

| Setting | Owner | Purpose |
| --- | --- | --- |
| `CANDIDATE_SOURCE_MODE` | Backend | Required source selection: `Fixture` or `Geoapify`. |
| `AI_SERVICE_BASE_URL` | Backend | FastAPI base URL; development fallback key is `AIService:BaseUrl`. |
| `AI_SERVICE_TIMEOUT` | Backend | FastAPI timeout in seconds; development fallback key is `AIService:TimeoutSeconds`. |
| `GEOAPIFY_API_KEY` | Backend | Server-side provider credential. Required in Geoapify mode. |
| `GEOAPIFY_BASE_URL` | Backend | Provider base URL; development fallback key is `Geoapify:BaseUrl`. |
| `GEOAPIFY_TIMEOUT` | Backend | Provider timeout in seconds; development fallback key is `Geoapify:TimeoutSeconds`. |
| `PLANNING_MAX_CANDIDATES` | FastAPI | Maximum accepted candidate count. Defaults to 500; valid range is 1-10,000. |

No provider-boundary environment setting is present on this SHA. The Fatih
boundary identifier and provider result limit are Backend implementation
constants.

## Planner behavior

For `D` requested days and `E` eligible candidates, the planner selects
`N = min(E, 3D)`. It always returns exactly `D` day objects, distributes the
selected places with quotient/remainder balance, and puts at most three
places on a day. Selected IDs are unique and are a subset of the supplied
candidate IDs.

Coverage warnings are deterministic:

- `N = 0`: `NO_PLACES_AVAILABLE`;
- `0 < N < D`: `PARTIAL_ITINERARY`;
- `N >= D`: no coverage warning.

FastAPI exposes readiness at `GET /health`. It accepts and returns a sanitized
`X-Request-ID`; missing or invalid IDs are replaced. Schema errors return a
controlled `422 INVALID_REQUEST` response. Planner-domain errors, candidate
limit errors, and unexpected failures also use controlled error envelopes.

## Reproduce the verified planner/service checks

Use Python 3.14 and install the development requirements from the repository
root:

```text
python -m pip install -r ai-ml/service/requirements-dev.txt
python -m pytest ai-ml/service/tests ai-ml/planning/tests -q
```

Start the service from `ai-ml/`:

```text
python -m uvicorn service.app:app --host 127.0.0.1 --port 8001
```

On the SHA recorded above, the combined test command completed with `117
passed` on Python 3.14.4. Local smoke checks returned `200 {"status":"ready"}`
from `/health`, returned a balanced two-day plan from a valid canonical
request, and returned `422 INVALID_REQUEST` for an invalid `days=0` request.
All three responses propagated the supplied valid `X-Request-ID`. These are
planner/service results only; they do not substitute for live-provider,
Flutter-device, independent QA, or security evidence.

## Known limitations

- Real-provider release scope is limited to public `istanbul` backed by a
  Fatih-only candidate pool and the two minimum interests above.
- Geoapify metadata is optional and incomplete; the strict planner candidate
  contains only ID, destination ID, name, canonical category IDs, latitude,
  and longitude.
- Duplicate provider records with the same provider ID collapse to one
  canonical ID. Physical-place deduplication across different provider IDs is
  not solved; name or proximity alone is not used to merge places.
- Unmapped provider categories and records without required Fatih membership
  evidence are excluded.
- Provider results can contain multilingual names despite requesting English;
  the implementation preserves the supplied name rather than inventing a
  translation.
- Budget and price behavior are outside the current release scope.

## Gate status at this SHA

Merged code and the planner/service checks above do not make Stage 3 GREEN.
The release remains waiting for all of the following evidence on the final
integrated SHA:

- Asma: fresh bounded live-Geoapify validation and completion of PR #24,
  including V03, V07, V11, and V14;
- Heba: real Geoapify-backed Flutter end-to-end and final build/device
  evidence;
- Balsam: independent Stage 3/release-candidate QA with no open Blocker or
  Critical issue;
- Sami: final Stage 3 security, configuration, and secret-handling sign-off
  with no open security Blocker or Critical issue;
- Ahmad: synchronize this documentation and final regressions to the final
  tested SHA, then perform technical release sign-off.

Historical provider artifacts and prior test reports remain useful
provenance, but they do not replace a fresh final-SHA live-provider run.
