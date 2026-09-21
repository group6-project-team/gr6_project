# Stage 3 Real-Data Validation Matrix

**Owner:** Asma Bzoor — AI/Data

**Scope:** Card 10 real-data semantic validation
**Status:** **WAITING — current implementation checks pass, but the real Geoapify run has not been repeated against the final provider implementation**

## Validation target and provenance

- PR #23 final implementation SHA: `3a3683f9677b95ca3e1c67669639e1f4a936cbe5`
- PR #23 merge SHA: `2d2e1f7019fa0db97a5274c9c632eef67c54ed0c`
- Public destination: `istanbul`
- Real-provider scope: bounded Fatih Geoapify path
- Candidate source mode required for the rerun: `Geoapify`
- Historical recorded real-provider package SHA: `4c958a11ddb129c4c1c7b9154950df00412314e2`

The checked-in real-provider artifacts were captured for the earlier PR #23 head `4c958a11...`. They remain useful provenance, but they are not a fresh live-provider run against `3a3683f...`. Work had no `GEOAPIFY_API_KEY` in its authorized environment, so no new Geoapify response or end-to-end provider run is claimed here.

Work executed the full Backend suite at the final implementation with the local FastAPI service running:

`dotnet test Backend/Backend.slnx --configuration Release --no-restore --nologo`

Result: **57 passed, 0 failed, 0 skipped**. The suite includes three real Backend-to-FastAPI integration tests. It does not make a live Geoapify request.

Formatting verification also passed:

`dotnet format Backend/Backend.slnx --verify-no-changes --no-restore --verbosity minimal`

## V01–V16 current evidence

| ID | Check | Current evidence at `3a3683f...` / `2d2e1f...` | Status |
| --- | --- | --- | --- |
| V01 | Public interest → canonical mapping | `RealTripPreviewServiceTests` verifies `history` → `historic_site` and `landmark` → `monument`; the current full suite passed. | **Pass — current code/test** |
| V02 | Geoapify → canonical mapping | Current normalization tests cover the approved archaeology, memorial, monument, ruins, and exact historic-building rules and reject broader categories. | **Pass — current code/test** |
| V03 | Accepted Fatih membership in live provider output | Current code uses the approved bounded Fatih `place_id` and strict structured membership. The recorded 20-feature sample belongs to the earlier SHA; no live response was captured at the final SHA. | **Waiting — provider rerun** |
| V04 | Fatih membership mismatch | `GetCandidatesAsync_RejectsWrongTown` passes at the final implementation; mismatched structured membership is excluded. | **Pass — current code/test** |
| V05 | Missing/conflicting Fatih signal | `GetCandidatesAsync_RejectsMissingMembershipSignal` passes; supporting text cannot replace required structured membership. | **Pass — current code/test** |
| V06 | Coordinates | Current tests reject invalid coordinates and the implementation requires numeric, finite, in-range latitude/longitude. | **Pass — current code/test** |
| V07 | Canonical object shape in current live output | The contract and current normalization tests pass, but the 19 checked-in normalized candidates were generated for the earlier SHA. | **Waiting — provider rerun** |
| V08 | Canonical identity and deterministic deduplication | `GetCandidatesAsync_DeduplicatesCanonicalIdsAndKeepsFirstEligibleRecord` supplies two eligible records with the same `place_id`, produces one `geoapify:<place_id>` candidate, and proves deterministic first-record retention. The test passed in the 57-test run. | **Pass — current focused runtime test** |
| V09 | Unmapped category | Current tests prove broad/unmapped categories do not receive invented canonical values. The historical sample retains the excluded square record for provenance. | **Pass — current code/test** |
| V10 | Zero-category record | `GetCandidatesAsync_RejectsUnmappedCategories` passes and the production path excludes zero-mapped candidates. | **Pass — current code/test** |
| V11 | Duplicate-like records with different provider IDs | The historical package contains two similarly named records with different IDs and preserves both. This observation was not repeated with a final-SHA live response. No fuzzy physical-place merge was added. | **Waiting — provider rerun** |
| V12 | Optional metadata | The canonical request contract remains limited to the six established fields; current code does not fabricate missing optional metadata. | **Pass — current code review/test** |
| V13 | Budget and price | Budget/price remain outside the active request and candidate contracts; no UNKNOWN-to-FREE/zero conversion exists in this flow. | **Pass — current code review** |
| V14 | Filtering counts | Historical evidence reconciles 20 raw = 19 accepted + 1 excluded. Those counts must be regenerated from the final-SHA live response before Card 10 closes. | **Waiting — provider rerun** |
| V15 | Provider/service failure and no fallback | Current tests cover missing key, unsupported destination, non-success HTTP, malformed JSON, invalid provider payload, and API-key log protection. `InvokeAsync_ReturnsControlled503_ForGeoapifyHttpFailure` proves the middleware emits `PLANNING_SERVICE_UNAVAILABLE` with HTTP 503. Explicit source selection still fails startup for missing/unsupported modes; there is no provider-to-fixture fallback. | **Pass — current public-error test** |
| V16 | Planner request boundary | Current service tests prove canonical interests. The final 57-test run exercised the real local FastAPI `/plan` boundary successfully for normal, partial, and empty cases. | **Pass — current Backend/FastAPI integration** |

## Historical real-provider artifacts

These files are retained as the prior bounded Fatih evidence package. They must not be described as newly generated at the final implementation SHA:

- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/geoapify-raw-response.json`
- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/geoapify-normalized-candidates.json`
- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/geoapify-filtering-summary.txt`
- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/fastapi-plan-request.json`
- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/runtime-configuration.txt`

Historical package result at `4c958a11...`:

- Raw Geoapify features: 20
- Normalized candidates: 19
- Excluded records: 1 (`Beyazıt Meydanı`, unmapped `tourism.sights.square`)
- Canonical categories observed: `historic_site`, `monument`
- Runtime mode recorded: `CANDIDATE_SOURCE_MODE=Geoapify`

## Required final rerun

Asma or another teammate with an authorized Geoapify key must rerun the bounded Fatih flow from main at or after `2d2e1f7019fa0db97a5274c9c632eef67c54ed0c`:

1. Set `CANDIDATE_SOURCE_MODE=Geoapify`, the authorized `GEOAPIFY_API_KEY`, the Geoapify base URL/timeout, and the FastAPI base URL/timeout without recording the secret.
2. Start FastAPI and the Backend, then call public `POST /trip-plans/preview` for `istanbul` with the supported interests.
3. Capture a sanitized raw provider response, normalized candidates, filtering summary, planner request, runtime configuration, public response, implementation SHA, and request-ID correlation.
4. Reconcile raw = accepted + excluded and verify every accepted canonical ID traces to a raw `place_id`.
5. Confirm V03, V07, V11, and V14 against the new artifacts. Reconfirm V08 and V15 using the final focused tests; do not replace them with weaker uniqueness-only or thrown-exception evidence.
6. Record the exact Backend test result. The current verified count is **57/57**, not 51 or 53.

Card 10 remains **WAITING** until those four real-provider rows are rerun and linked to the final implementation/main SHA. Final RC emulator/device E2E is outside this matrix and is not claimed complete.
