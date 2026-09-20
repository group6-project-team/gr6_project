# Stage 3 Real-Data Validation Matrix

**Owner:** Asma Bzoor — AI/Data
**Scope:** Card 10 preparation
**Status:** Prepared — execution waits for real provider/normalized outputs from Backend

Do not mark a row Pass until the check is run against the actual Stage 3 output. Add the command, sample/output reference, and commit SHA when executing.

| ID | Check | Expected result | Actual result | Evidence reference | Status |
| --- | --- | --- | --- | --- | --- |
| V01 | Public Interest → canonical mapping | Apply the accepted `history` → `historic_site` and `landmark` → `monument` mapping before `/plan`; no blind pass-through | Pending real output | Pending | Not run |
| V02 | Geoapify → canonical mapping | Only accepted evidence-backed mapping rules are applied; raw categories are not copied into `categoryIds` | Pending real output | Pending | Not run |
| V03 | Accepted Fatih membership | A record comes from the approved Fatih boundary request and matches normalized `tr` / `Istanbul` / `Fatih` signals | Pending real Stage 3 provider/normalized output | Pending | Not run |
| V04 | Fatih membership mismatch | Any `country_code`, `city`, or `town` mismatch is excluded and traceable | Pending real output | Pending | Not run |
| V05 | Missing/conflicting Fatih signal | Missing required signal is unknown; conflicts are excluded; supporting address text does not override | Pending real output | Pending | Not run |
| V06 | Coordinates | Latitude/longitude are numeric, finite, not booleans, and within valid ranges | Pending real output | Pending | Not run |
| V07 | Canonical object shape | Each candidate contains exactly the six fields required by the latest contract with correct types | Pending actual Stage 3 output and tested contract/SHA | Pending | Not run |
| V08 | Identity and provenance | Candidate IDs are unique within the pool and every accepted record remains traceable to source evidence | Pending real output | Pending | Not run |
| V09 | Unmapped category | No canonical value is invented; source evidence is preserved | Pending real output | Pending | Not run |
| V10 | Zero-category record | Record is excluded from the production candidate pool under the accepted policy | Pending real output | Pending | Not run |
| V11 | Duplicate-like records | No physical-place merge occurs from name similarity or proximity alone | Pending real output | Pending | Not run |
| V12 | Optional metadata | Missing description/image/site/rating/price does not become fabricated data | Pending real output | Pending | Not run |
| V13 | Budget and price | Budget remains disabled and UNKNOWN price never becomes FREE or zero | Pending integrated flow | Pending | Not run |
| V14 | Filtering counts | Input, accepted, excluded, and unresolved counts reconcile without accidental double-counting | Pending real output | Pending | Not run |
| V15 | Provider/service failure | Failure is surfaced through the agreed behavior; no silent successful fixture fallback occurs | Pending integrated flow | Pending | Not run |
| V16 | Planner request boundary | `/plan.interests` contains canonical IDs only and no raw provider/public-only IDs | Pending integrated request evidence | Pending | Not run |

## Execution Record

Record one row for each tested destination/sample.

| Run date | Branch / SHA | Destination | Input/output artifact | Checks executed | Result | Notes / issue link |
| --- | --- | --- | --- | --- | --- | --- |
| Pending | Pending | Pending | Pending | Pending | Not run | Waiting for testable Stage 3 output |

## Known Preconditions

**Confirmed decisions and recorded evidence**

- Minimum public options are confirmed as `history` and `landmark`.
- The accepted public mapping is `history` → `historic_site` and `landmark` → `monument`.
- Public destination is `istanbul`, routed to the Fatih-only candidate pool; `istanbul-tr` remains development/fixture-only.
- The minimum Fatih membership rules are agreed, as recorded in Sections 5 and 15 of `stage-3-semantics-package.md`.
- The exact Fatih boundary `place_id`, retrieval dates, and sanitized geocoding/bounded-request evidence are recorded in Sections 15–16.2 and their existing source JSON files.

**Outstanding confirmation and execution evidence**

- Mohammad’s separate final confirmation that mapping, membership, and eligibility are implementation-ready remains required before Stage 3 starts. This cleanup does not supply that confirmation.
- Actual Stage 3 provider responses and corresponding normalized outputs must be exposed by Backend before executing this matrix; record the actual tested commit SHA and evidence.
- All 16 validation rows remain **Not run**. Confirmed decisions and historical provider samples are reference material, not Pass results for the Backend implementation.
