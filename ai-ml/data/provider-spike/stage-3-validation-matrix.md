# Stage 3 Real-Data Validation Matrix

**Owner:** Asma Bzoor — AI/Data

**Scope:** Card 10 real-data semantic validation

**Status:** **COMPLETE — fresh latest-main live-provider validation complete; no unresolved Stage 3 semantic/data blocker**

## Validation target and provenance

- PR #23 final implementation SHA: `3a3683f9677b95ca3e1c67669639e1f4a936cbe5`
- PR #23 merge SHA: `2d2e1f7019fa0db97a5274c9c632eef67c54ed0c`
- Current deployed latest-main SHA: `664dfa726629c47fbd12c5ca6e7c43f54b95291f`
- Public destination: `istanbul`
- Real-provider scope: bounded Fatih Geoapify path
- Runtime candidate source mode: `CANDIDATE_SOURCE_MODE=Geoapify`
- Fresh public endpoint: `POST /trip-plans/preview`
- Fresh public E2E result: `200 OK`
- Fresh request ID: `b4aabdb8ded8425ba26429c1ed102d56`
- Fresh provider retrieval timestamp: `2026-09-21T16:53:42+03:00`
- Historical recorded real-provider package SHA: `4c958a11ddb129c4c1c7b9154950df00412314e2`

The original checked-in real-provider artifacts were captured for the earlier PR #23 head `4c958a11...`. They remain useful historical provenance, but they are not used as current proof for the final live-provider validation.

A fresh bounded Fatih Geoapify validation has now been completed through the authorized deployed Stage 3 Backend against deployed latest-main SHA:

`664dfa726629c47fbd12c5ca6e7c43f54b95291f`

The fresh public request completed successfully with:

- `200 OK`
- request ID `b4aabdb8ded8425ba26429c1ed102d56`
- canonical `geoapify:` candidate IDs
- `warnings: []`

The fresh provider package contains:

- 20 raw Geoapify features
- 19 accepted normalized candidates
- 1 excluded record
- excluded record: `Beyazıt Meydanı`
- exclusion reason: no approved canonical category mapping
- `tourism.sights.square` remains intentionally unmapped

The `GEOAPIFY_API_KEY` remained server-side/local only and was not stored in Git, evidence files, screenshots, or repository artifacts.

## Backend regression evidence

The full Backend suite was executed at the current implementation state with the local FastAPI service running:

`dotnet test Backend/Backend.slnx --configuration Release --no-restore --nologo`

Result:

**57 passed, 0 failed, 0 skipped**

The suite includes three real Backend-to-FastAPI integration tests. These tests validate the Backend/FastAPI boundary but do not themselves make a live Geoapify request.

The Backend regression result was also confirmed for the fresh latest-main validation state as:

**57/57 PASS**

Formatting verification also passed:

`dotnet format Backend/Backend.slnx --verify-no-changes --no-restore --verbosity minimal`

## V01–V16 current evidence

| ID | Check | Current evidence | Status |
| --- | --- | --- | --- |
| V01 | Public interest → canonical mapping | `RealTripPreviewServiceTests` verifies `history` → `historic_site` and `landmark` → `monument`; the current full suite passed. | **Pass — current code/test** |
| V02 | Geoapify → canonical mapping | Current normalization tests cover the approved archaeology, memorial, monument, ruins, and exact historic-building rules and reject broader categories. | **Pass — current code/test** |
| V03 | Accepted Fatih membership | Fresh bounded-Fatih evidence on deployed SHA `664dfa726629c47fbd12c5ca6e7c43f54b95291f` / request ID `b4aabdb8ded8425ba26429c1ed102d56` contains 20 raw features. All 20 have structured `country_code=tr`, `city=Istanbul`, and `town=Fatih`; no membership mismatch is present in the fresh sample. Evidence: `geoapify-raw-response-latest-main.json`, `retrieval-date.txt`. | **Pass — fresh live-provider evidence** |
| V04 | Fatih membership mismatch | `GetCandidatesAsync_RejectsWrongTown` passes at the final implementation; mismatched structured membership is excluded and traceable through the focused rejection test. | **Pass — current code/test** |
| V05 | Missing/conflicting Fatih signal | `GetCandidatesAsync_RejectsMissingMembershipSignal` passes; supporting text cannot replace required structured membership. | **Pass — current code/test** |
| V06 | Coordinates | Current tests reject invalid coordinates. Fresh artifact inspection found 0 invalid coordinates across the 20 raw features; all inspected latitude/longitude values are numeric, finite, and within valid ranges. | **Pass — current code/test + fresh evidence** |
| V07 | Canonical object shape | Fresh normalized output from the same latest-main provider run contains 19 accepted candidates in canonical `PlaceCandidate` form. The public E2E response returned canonical `geoapify:` IDs. Evidence: `geoapify-normalized-candidates-latest-main.json`, deployed SHA `664dfa726629c47fbd12c5ca6e7c43f54b95291f`, request ID `b4aabdb8ded8425ba26429c1ed102d56`. | **Pass — fresh live-provider evidence** |
| V08 | Canonical identity and deterministic deduplication | `GetCandidatesAsync_DeduplicatesCanonicalIdsAndKeepsFirstEligibleRecord` supplies two eligible records with the same `place_id`, produces one `geoapify:<place_id>` candidate, and proves deterministic first-record retention. The test passed in the 57-test run. | **Pass — current focused runtime test** |
| V09 | Unmapped category | Current tests prove broad/unmapped categories do not receive invented canonical values. The fresh live package also contains one intentionally excluded `tourism.sights.square` record. | **Pass — current code/test + fresh evidence** |
| V10 | Zero-category record | `GetCandidatesAsync_RejectsUnmappedCategories` passes and the production path excludes zero-mapped candidates. The fresh excluded `Beyazıt Meydanı` record confirms that no fallback canonical category is fabricated. | **Pass — current code/test + fresh evidence** |
| V11 | Duplicate-like records with different provider IDs | Fresh artifact inspection found two accepted records named `Fatih Sultan Mehmet Anıtı` with different `geoapify:` IDs and different coordinates (`41.0155727, 28.9542189` and `41.0303472, 28.9370228`). Both remain separate canonical candidates. This confirms that distinct provider IDs are not physically merged by name/proximity; deterministic same-canonical-ID dedup remains covered by V08. | **Pass — fresh duplicate-pattern evidence** |
| V12 | Optional metadata | Fresh raw inspection confirms optional provider metadata is genuinely incomplete: `quarter` is absent in 14/20 records, `name_international` in 7/20, `wiki_and_media` in 10/20, `historic` in 1/20, and `building` in 17/20. The canonical contract remains limited to the six established fields and no missing provider metadata is fabricated. | **Pass — fresh metadata inspection + current contract review** |
| V13 | Budget and price | Budget/price remain outside the active request and candidate contracts; no UNKNOWN-to-FREE/zero conversion exists in this flow. | **Pass — current code review** |
| V14 | Filtering counts | Fresh latest-main evidence reconciles exactly: 20 raw features = 19 accepted normalized candidates + 1 excluded record. The excluded record is `Beyazıt Meydanı`, excluded because `tourism.sights.square` intentionally has no approved canonical mapping. Evidence: `filtering-accepted-excluded-summary-latest-main.txt`, `geoapify-raw-response-latest-main.json`, `geoapify-normalized-candidates-latest-main.json`. | **Pass — fresh live-provider evidence** |
| V15 | Provider/service failure and no fallback | Current tests cover missing key, unsupported destination, non-success HTTP, malformed JSON, invalid provider payload, and API-key log protection. `InvokeAsync_ReturnsControlled503_ForGeoapifyHttpFailure` proves the middleware emits `PLANNING_SERVICE_UNAVAILABLE` with HTTP 503. Explicit source selection still fails startup for missing/unsupported modes; there is no provider-to-fixture fallback. | **Pass — current public-error test** |
| V16 | Planner request boundary | Current service tests prove canonical interests. The final 57-test run exercised the real local FastAPI `/plan` boundary successfully for normal, partial, and empty cases. The fresh public Stage 3 request also completed with `200 OK`, canonical `geoapify:` IDs, and `warnings: []`. | **Pass — current Backend/FastAPI integration + fresh public E2E** |

## Fresh latest-main evidence for V03 / V07 / V11 / V14

The following evidence package was generated from the fresh latest-main live-provider validation against deployed SHA:

`664dfa726629c47fbd12c5ca6e7c43f54b95291f`

Evidence files:

- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/geoapify-raw-response-latest-main.json`
- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/geoapify-normalized-candidates-latest-main.json`
- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/filtering-accepted-excluded-summary-latest-main.txt`
- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/retrieval-date.txt`

Fresh request correlation:

- Request ID: `b4aabdb8ded8425ba26429c1ed102d56`
- Result: `200 OK`
- Runtime mode: `CANDIDATE_SOURCE_MODE=Geoapify`
- Returned candidate identity format: `geoapify:<place_id>`
- Response warnings: `[]`
- Backend regression suite: **57/57 PASS**

### V03 fresh validation

The fresh live-provider run used the bounded Fatih provider path on deployed latest-main SHA:

`664dfa726629c47fbd12c5ca6e7c43f54b95291f`

The fresh raw provider artifact contains 20 features and is the direct provenance source for the corresponding normalized latest-main candidate artifact.

The current provider implementation continues to require the approved structured Fatih membership signals for accepted records.

**Fresh V03 result: PASS — live-provider evidence refreshed.**

### V07 fresh validation

The fresh normalized artifact contains 19 accepted candidates produced from the same fresh raw provider response.

The public E2E response returned canonical `geoapify:` candidate IDs and completed with:

`warnings: []`

The refreshed candidate output remains within the established canonical `PlaceCandidate` contract and does not add raw provider-specific metadata to the planner-facing object.

**Fresh V07 result: PASS — live-provider evidence refreshed.**

### V11 fresh validation

The fresh provider rerun is complete and the latest raw and normalized artifacts are available for duplicate/near-duplicate inspection.

The supported deterministic deduplication behavior remains unchanged:

- canonical identity is derived from `geoapify:<place_id>`;
- duplicate eligible records sharing the same canonical provider ID are deterministically collapsed;
- first eligible record retention remains deterministic for duplicate canonical IDs;
- similarly named records are not automatically asserted to represent one physical place;
- geographically close records with different provider IDs are not automatically merged;
- no arbitrary distance threshold is used;
- no fuzzy physical-place deduplication is claimed.

The historical package previously demonstrated similarly named records with distinct provider IDs. That historical observation remains useful provenance but must not be substituted for inspection of the fresh latest-main sample.

**Fresh V11 result: PASS — the fresh sample contains two `Fatih Sultan Mehmet Anıtı` records with different provider IDs and coordinates, and both are preserved as separate canonical candidates. Deterministic same-canonical-ID dedup remains unchanged and no arbitrary physical-place merge is claimed.**

### V14 fresh validation

The fresh latest-main evidence reconciles:

- Raw provider features: `20`
- Accepted normalized candidates: `19`
- Excluded records: `1`

Reconciliation:

`20 raw = 19 accepted + 1 excluded`

Excluded record:

- Name: `Beyazıt Meydanı`
- Reason: no approved canonical mapping
- Provider category involved: `tourism.sights.square`
- Semantics: intentionally unmapped
- No fallback category was fabricated

**Fresh V14 result: PASS — counts reconcile exactly with no double-counting.**

## Historical real-provider artifacts

These files are retained as the prior bounded Fatih evidence package and must not be described as current latest-main proof:

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

The historical evidence remains in the repository for traceability only.

## Fresh latest-main real-provider artifacts

The following artifacts are the current live-provider package and replace the historical `4c958a11...` package as current Card 10 provider evidence:

### `geoapify-raw-response-latest-main.json`

- fresh raw Geoapify provider response
- 20 raw features

### `geoapify-normalized-candidates-latest-main.json`

- normalized candidate output derived from the same fresh raw provider response
- 19 accepted candidates

### `filtering-accepted-excluded-summary-latest-main.txt`

- 20 raw
- 19 accepted
- 1 excluded
- excluded record: `Beyazıt Meydanı`
- exclusion reason: no approved canonical category mapping
- `tourism.sights.square` remains intentionally unmapped

### `retrieval-date.txt`

- fresh provider retrieval timestamp

Fresh runtime/E2E facts:

- Deployed SHA: `664dfa726629c47fbd12c5ca6e7c43f54b95291f`
- Runtime mode: `CANDIDATE_SOURCE_MODE=Geoapify`
- Public E2E result: `200 OK`
- Request ID: `b4aabdb8ded8425ba26429c1ed102d56`
- Public response returned canonical `geoapify:` IDs
- Public response warnings: `[]`
- Backend regression suite: **57/57 PASS**
- `GEOAPIFY_API_KEY` remained server-side/local only and is not stored in the repository or evidence artifacts

## Completed final rerun

The final bounded Fatih rerun required for Card 10 has now been performed through the authorized deployed latest-main Backend.

The rerun used:

- `CANDIDATE_SOURCE_MODE=Geoapify`
- the authorized server-side `GEOAPIFY_API_KEY`
- the supported public destination `istanbul`
- the bounded Fatih provider path
- the deployed latest-main SHA `664dfa726629c47fbd12c5ca6e7c43f54b95291f`

The successful public Stage 3 request produced:

- `200 OK`
- request ID `b4aabdb8ded8425ba26429c1ed102d56`
- canonical `geoapify:` candidate IDs
- `warnings: []`

Fresh sanitized artifacts were captured for:

- raw provider response
- normalized candidates
- filtering accepted/excluded summary
- retrieval timestamp

Count reconciliation confirms:

`20 raw = 19 accepted + 1 excluded`

The Backend regression result is:

**57/57 PASS**

The fresh rerun therefore closes the previous Geoapify-access blocker and replaces the earlier `4c958a11...` package as current live-provider proof.

V03, V07, and V14 are now refreshed against current latest-main live evidence.

V11 fresh duplicate/near-duplicate inspection is complete. The fresh sample preserves two same-name `Fatih Sultan Mehmet Anıtı` records with distinct provider IDs and coordinates as separate canonical candidates; no arbitrary physical-place merge is claimed.

Final RC emulator/device E2E remains outside this matrix and is not claimed complete here.

## Current Card 10 closeout state

The final latest-main live-provider rerun has been completed and fresh sanitized evidence has been produced for the current deployed implementation.

Confirmed from the fresh run:

- bounded Fatih provider path executed successfully;
- canonical `geoapify:` identities reached the public E2E response;
- accepted/excluded counts reconcile exactly;
- intentionally unmapped `tourism.sights.square` remains excluded;
- no fallback category was invented;
- response warnings were empty;
- Backend regression result remains **57/57 PASS**;
- no Geoapify secret is stored in the repository or evidence files.

The fresh provider package replaces the historical `4c958a11...` artifacts as current live-provider proof while preserving the historical package for traceability.

No change to the frozen Stage 3 semantics is introduced by this refresh:

- public destination remains `istanbul`;
- minimum provider scope remains Fatih;
- `history` → `historic_site`;
- `landmark` → `monument`;
- `istanbul-tr` remains dev/fixture-only;
- unsupported/unmapped provider subtypes remain excluded according to the approved semantics;
- deterministic canonical-ID dedup remains in force;
- no arbitrary physical-place dedup is claimed.

### Card 10 completion

The fresh latest-main validation is complete.

Final fresh-sample checks confirm:

- all 20 raw records satisfy the structured Fatih membership signals;
- 0 invalid coordinates were found in the fresh raw sample;
- approved canonical categories are preserved;
- 20 raw = 19 accepted + 1 excluded;
- optional provider metadata is incomplete where expected and is not fabricated;
- the fresh duplicate-like pair `Fatih Sultan Mehmet Anıtı` is preserved as two separate candidates because the provider IDs differ;
- deterministic same-canonical-ID dedup remains unchanged;
- Backend regression remains **57/57 PASS**;
- retrieval timestamp is `2026-09-21T16:53:42+03:00`;
- the current evidence is tied to deployed SHA `664dfa726629c47fbd12c5ca6e7c43f54b95291f` and request ID `b4aabdb8ded8425ba26429c1ed102d56`.

**COMPLETE — fresh latest-main live-provider validation complete; no unresolved Stage 3 semantic/data blocker.**
