# Stage 3 Real-Data Validation Matrix

**Owner:** Asma Bzoor — AI/Data
**Scope:** Card 10 preparation
**Status:** Prepared — execution waits for real provider/normalized outputs from Backend

Do not mark a row Pass until the check is run against the actual Stage 3 output. Add the command, sample/output reference, and commit SHA when executing.

| ID | Check | Expected result | Actual result | Evidence reference | Status |
| --- | --- | --- | --- | --- | --- |
| V01 | Public Interest → canonical mapping | Each supported public ID is explicitly mapped before `/plan`; no blind pass-through | Pending real output | Pending | Not run |
| V02 | Geoapify → canonical mapping | Only accepted evidence-backed mapping rules are applied; raw categories are not copied into `categoryIds` | Pending real output | Pending | Not run |
| V03 | Accepted Fatih membership | A record comes from the approved Fatih boundary request and matches normalized `tr` / `Istanbul` / `Fatih` signals | Pending exact boundary ID and real output | Pending | Blocked |
| V04 | Fatih membership mismatch | Any `country_code`, `city`, or `town` mismatch is excluded and traceable | Pending real output | Pending | Not run |
| V05 | Missing/conflicting Fatih signal | Missing required signal is unknown; conflicts are excluded; supporting address text does not override | Pending real output | Pending | Not run |
| V06 | Coordinates | Latitude/longitude are numeric, finite, not booleans, and within valid ranges | Pending real output | Pending | Not run |
| V07 | Canonical object shape | Each candidate contains exactly the six fields required by the latest contract with correct types | Pending latest contract/output | Pending | Not run |
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

- The proposed `history` → `historic_site` and `landmark` → `monument` mapping must be approved by Ahmad/Mohammad.
- Minimum public options are confirmed as `history` and `landmark`.
- The proposed executable Fatih rule must be reviewed and the exact boundary/destination IDs recorded.
- Actual provider/normalized outputs must be exposed by Backend.
