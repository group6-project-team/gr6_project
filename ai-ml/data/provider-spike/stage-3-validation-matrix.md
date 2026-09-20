# Stage 3 Real-Data Validation Matrix

**Owner:** Asma Bzoor — AI/Data
**Scope:** Card 10 real-data semantic validation
**Status:** Completed — Card 10 semantic validation passed for the tested Stage 3 evidence package

## Validation Target

* **Backend branch:** `feature/stage3-geoapify-candidate-source`
* **Tested SHA:** `4c958a11ddb129c4c1c7b9154950df00412314e2`
* **PR:** `#23`
* **Public destination:** `istanbul`
* **Real-provider scope:** bounded Fatih Geoapify path
* **Candidate source mode:** `Geoapify`

Validation was performed against the tested implementation and the Stage 3 evidence package provided for Card 10. Results below apply to this bounded Fatih sample and tested SHA; they do not imply complete Istanbul/Fatih provider coverage.

| ID  | Check                               | Expected result                                                                                                    | Actual result                                                                                                                                                                                                                                                                           | Evidence reference                                                                                                                   | Status   |
| --- | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| V01 | Public Interest → canonical mapping | Apply `history` → `historic_site` and `landmark` → `monument` before `/plan`; no blind pass-through                | `RealTripPreviewService` performs both mappings before building `FastApiPlanRequest`. Dedicated tests verify both mappings. Actual planner evidence contains canonical `monument`.                                                                                                      | `RealTripPreviewService.cs`; `RealTripPreviewServiceTests.cs`; `fastapi-plan-request.json`                                           | **Pass** |
| V02 | Geoapify → canonical mapping        | Only accepted evidence-backed mapping rules are applied; raw provider categories are not copied into `categoryIds` | Raw records map only through the approved rules. Normalized output contains only `historic_site` and `monument`; raw Geoapify category strings are not copied into canonical `categoryIds`.                                                                                             | `GeoapifyCandidateSource.cs`; `GeoapifyCandidateSourceTests.cs`; `geoapify-raw-response.json`; `geoapify-normalized-candidates.json` | **Pass** |
| V03 | Accepted Fatih membership           | Record comes from approved Fatih bounded request and matches normalized `tr` / `Istanbul` / `Fatih` signals        | Geoapify request uses the approved exact Fatih `place_id`, `categories=tourism.sights`, `limit=20`, and `lang=en`. All 20 raw records in the recorded sample have `country_code=tr`, `city=Istanbul`, `town=Fatih`, with valid coordinates.                                             | `GeoapifyClient.cs`; `GeoapifyClientTests.cs`; `geoapify-raw-response.json`                                                          | **Pass** |
| V04 | Fatih membership mismatch | Any `country_code`, `city`, or `town` mismatch is excluded and traceable | Membership implementation requires the structured Fatih signals and rejects mismatches. The dedicated wrong-town test provides a traceable mismatch case; no membership mismatch occurred in the recorded 20-record real sample. | `GeoapifyCandidateSource.cs`; `GetCandidatesAsync_RejectsWrongTown()` | **Pass** |                                                                                                                                                            | `GeoapifyCandidateSource.cs`; `GetCandidatesAsync_RejectsWrongTown()`                                                                | **Pass** |
| V05 | Missing/conflicting Fatih signal    | Missing required signal is unknown; conflicts are excluded; supporting address text does not override              | Required `country_code`, `city`, and `town` fields must exist and match. Missing required membership evidence is rejected; structured fields, not formatted/supporting text, control membership.                                                                                        | `GeoapifyCandidateSource.cs`; `GetCandidatesAsync_RejectsMissingMembershipSignal()`                                                  | **Pass** |
| V06 | Coordinates                         | Latitude/longitude are numeric, finite, not booleans, and within valid ranges                                      | Implementation rejects non-numeric, non-finite, and out-of-range coordinates. All 20 recorded raw coordinates are valid, and accepted values are preserved in normalized output.                                                                                                        | `GeoapifyCandidateSource.cs`; `GetCandidatesAsync_RejectsInvalidCoordinates()`; raw and normalized evidence                          | **Pass** |
| V07 | Canonical object shape              | Each candidate contains exactly the six canonical fields with correct structure                                    | 19 normalized candidates were inspected. Every candidate contains exactly: `Id`, `DestinationId`, `Name`, `CategoryIds`, `Latitude`, `Longitude`.                                                                                                                                       | `geoapify-normalized-candidates.json`; `PlaceCandidateRequest` contract                                                              | **Pass** |
| V08 | Identity and provenance             | Candidate IDs are unique and accepted records remain traceable to provider evidence                                | 19 normalized candidates contain 19 unique IDs. All IDs use `geoapify:<place_id>`. All 19 normalized provider IDs match a raw Geoapify `place_id`; no normalized ID is missing from the raw evidence.                                                                                   | `geoapify-raw-response.json`; `geoapify-normalized-candidates.json`; ID reconciliation check                                         | **Pass** |
| V09 | Unmapped category                   | No canonical value is invented; source evidence is preserved                                                       | `Beyazıt Meydanı` contains `tourism.sights.square`, which has no approved canonical mapping. No fallback category was invented, and the raw record/reason remain documented.                                                                                                            | `geoapify-filtering-summary.txt`; `geoapify-raw-response.json`                                                                       | **Pass** |
| V10 | Zero-category record                | A record producing no accepted canonical category is excluded                                                      | The only zero-mapped record, `Beyazıt Meydanı`, was excluded from the production candidate pool. Implementation explicitly excludes `categoryIds.Count == 0`.                                                                                                                           | `GeoapifyCandidateSource.cs`; `geoapify-filtering-summary.txt`; `GetCandidatesAsync_RejectsUnmappedCategories()`                     | **Pass** |
| V11 | Duplicate-like records              | No physical-place merge occurs from name similarity or proximity alone                                             | The real sample contains two `Fatih Sultan Mehmet Anıtı` records with different provider IDs and coordinates. Both remain distinct canonical candidates. No physical identity was inferred from name similarity alone.                                                                  | `geoapify-raw-response.json`; `geoapify-normalized-candidates.json`                                                                  | **Pass** |
| V12 | Optional metadata                   | Missing description/image/site/rating/price does not become fabricated data                                        | Raw provider records contain provider metadata such as `formatted`, `details`, `datasource`, and `historic`, but the canonical output remains limited to the six contract fields. Missing optional fields are not fabricated.                                                           | `geoapify-raw-response.json`; `geoapify-normalized-candidates.json`                                                                  | **Pass** |
| V13 | Budget and price                    | Budget remains disabled and UNKNOWN price never becomes FREE or zero                                               | `TripPlanPreviewRequest` contains only `DestinationId`, `Days`, and `Interests`. The tested Backend contains no active `budget`, `price`, or `free` handling in this flow, and the actual `/plan` request contains no price/budget data. No UNKNOWN price is converted to zero or FREE. | `TripPlanPreviewRequest.cs`; `fastapi-plan-request.json`; Backend search on tested SHA                                               | **Pass** |
| V14 | Filtering counts                    | Input, accepted, excluded, and unresolved counts reconcile without double-counting                                 | Raw provider features = 20; normalized candidates = 19; excluded = 1. `20 = 19 + 1`. The excluded ID is the unmapped `Beyazıt Meydanı` record, and all 19 accepted IDs trace to raw input.                                                                                              | `geoapify-filtering-summary.txt`; raw/normalized ID reconciliation                                                                   | **Pass** |
| V15 | Provider/service failure            | Failure is surfaced; no silent successful fixture fallback occurs                                                  | Candidate source selection is explicit. Runtime evidence shows `CANDIDATE_SOURCE_MODE=Geoapify`. Missing/unsupported mode does not silently fall back. Provider tests cover missing API key, unsupported destination, provider HTTP error, and malformed JSON.                          | `Program.cs`; `runtime-configuration.txt`; `GeoapifyClientTests.cs`                                                                  | **Pass** |
| V16 | Planner request boundary            | `/plan.interests` contains canonical IDs only, not public/raw provider IDs                                         | `RealTripPreviewService` canonicalizes interests before creating the planner request. Actual Stage 3 request evidence contains `Interests: ["monument"]`, not public `landmark` or raw Geoapify categories.                                                                             | `RealTripPreviewService.cs`; `RealTripPreviewServiceTests.cs`; `fastapi-plan-request.json`                                           | **Pass** |

## Execution Record

| Run date   | Branch / SHA                                                                            | Destination                             | Input/output artifact                                                                                           | Checks executed | Result   | Notes / issue link                                                                            |
| ---------- | --------------------------------------------------------------------------------------- | --------------------------------------- | --------------------------------------------------------------------------------------------------------------- | --------------- | -------- | --------------------------------------------------------------------------------------------- |
| 2026-09-20 | `feature/stage3-geoapify-candidate-source` / `4c958a11ddb129c4c1c7b9154950df00412314e2` | Public `istanbul` / bounded Fatih scope | Stage 3 raw Geoapify response, normalized candidates, filtering summary, planner request, runtime configuration | V01–V16         | **Pass** | PR `#23`; validation is limited to the recorded bounded Fatih evidence package and tested SHA |

## Evidence Package

Card 10 was validated against the following Stage 3 artifacts:

* `Backend/TripPlanning.Api.Tests/Evidence/Stage3/geoapify-raw-response.json`
* `Backend/TripPlanning.Api.Tests/Evidence/Stage3/geoapify-normalized-candidates.json`
* `Backend/TripPlanning.Api.Tests/Evidence/Stage3/geoapify-filtering-summary.txt`
* `Backend/TripPlanning.Api.Tests/Evidence/Stage3/fastapi-plan-request.json`
* `Backend/TripPlanning.Api.Tests/Evidence/Stage3/runtime-configuration.txt`

Supporting implementation/test evidence includes:

* `GeoapifyCandidateSource.cs`
* `GeoapifyClient.cs`
* `RealTripPreviewService.cs`
* `Program.cs`
* `GeoapifyCandidateSourceTests.cs`
* `GeoapifyClientTests.cs`
* `RealTripPreviewServiceTests.cs`

Backend handoff reports **53/53 tests passing** on the tested Stage 3 evidence SHA. This validation independently inspected the relevant implementation, tests, and evidence artifacts required by Card 10; the 53/53 suite count itself is recorded from the Backend handoff.

## Validation Findings

### Real-provider sample reconciliation

The recorded bounded Fatih provider sample contains:

* **20** raw Geoapify features
* **19** normalized production candidates
* **1** excluded record

The excluded record is:

* **Name:** `Beyazıt Meydanı`
* **Reason:** no approved canonical category mapping
* **Observed category:** `tourism.sights.square`

No fallback category was fabricated.

### Canonical categories observed

The normalized candidate pool contains only:

* `historic_site`
* `monument`

Three candidates contain both `historic_site` and `monument`; the remaining accepted candidates contain `historic_site`.

### Identity and duplicate observations

All 19 normalized candidate IDs are unique and use the frozen production format:

`geoapify:<place_id>`

Every normalized ID maps back to an observed raw provider `place_id`.

The sample contains two records named `Fatih Sultan Mehmet Anıtı` with different Geoapify IDs and different coordinates. They remain separate candidates. This confirms that the tested flow does not merge records merely because names are similar.

This result does **not** claim that the two records represent different physical places. Physical-place deduplication beyond provider identity remains outside the current release semantics.

### Runtime configuration

The recorded Stage 3 run used:

`CANDIDATE_SOURCE_MODE=Geoapify`

The Geoapify API key was supplied through the environment and is intentionally not stored in the evidence package.

There is no silent fixture fallback in the validated Geoapify flow.

## Scope and Limitations

This Card 10 result applies to:

* the tested SHA `4c958a11ddb129c4c1c7b9154950df00412314e2`
* the recorded real Geoapify bounded Fatih sample
* the minimum Stage 3 `istanbul` flow
* the approved `history` / `landmark` → `historic_site` / `monument` semantics

It does **not** establish:

* complete Fatih or Istanbul provider coverage
* support for Rome
* physical-place deduplication across different provider IDs
* availability of optional descriptions/images/ratings/prices
* Budget behavior beyond the current disabled state
* correctness of future provider responses that differ from this tested evidence package

## Card 10 Result

**Card 10 semantic validation: PASS**

No mapping, membership, eligibility, canonical-shape, identity/provenance, zero-category, runtime-source, or planner-boundary blocker was found in the tested Stage 3 evidence package.

The result is tied to PR `#23` and tested SHA:

`4c958a11ddb129c4c1c7b9154950df00412314e2`
