# V2 Provider Semantics and Mapping Guardrails

**Owner:** Asma Yahya Faris Bzoor ? AI/Data & Provider Semantics
**Baseline:** `main@edd5cab05a3c4c66b2cdcb68af9ea5d5fa589750`

## Metadata exposure guardrails

### Explicitly barred

V2 MUST NOT expose the following provider-derived claims:

- rating
- opening hours
- price / price level

The committed 20-record Fatih snapshot provides no reproducible source path for these fields.

Absence of these fields in this bounded snapshot is not a provider-wide impossibility claim. It is sufficient to reject them for the frozen V2 evidence contract because no reproducible truth source has been approved.

### Outside frozen MVP

The following remain outside the frozen MVP:

- website
- wiki links
- Wikimedia/media/image fields

Wiki/media data is observed in some raw records, but presence alone does not authorize public exposure.

No missing optional metadata may be fabricated.

## Public interest to canonical category mapping

Frozen public mapping:

- `history` -> `historic_site`
- `landmark` -> `monument`

No new interest or taxonomy value is introduced here.

A public interest may support an interest-match explanation only if the candidate actually contains the mapped canonical category and the planner factor definition confirms the match was used. Final `INTEREST_MATCH` wording remains pending Ahmad's factor definition.

## Provider category to canonical category predicates

| Provider evidence | Canonical result | Evidence state |
|---|---|---|
| `tourism.sights.archaeological_site` | `historic_site` | approved implementation predicate; not observed in current 20-record sample |
| `tourism.sights.memorial` | `historic_site` | observed and reproduced |
| `tourism.sights.ruines` | `historic_site` | observed and reproduced |
| `tourism.sights.memorial.monument` | `historic_site`, `monument` | observed and reproduced |
| `tourism.sights.building` + `building.historic` | `historic_site` | observed and reproduced |
| `tourism.sights.building` without `building.historic` | none | excluded |
| `tourism.sights.memorial.tumulus` | none | explicit exclusion |
| generic `tourism.sights` only | none | no automatic mapping |
| `tourism.sights.square` only | none | observed negative case |

No fallback category may be invented when the approved predicate produces zero canonical categories.

## Ambiguity and precedence

`tourism.sights.memorial.tumulus` is an explicit exclusion and therefore produces no canonical category even if other category strings are also present.

`tourism.sights.memorial.monument` supports both:

- `historic_site`
- `monument`

A generic parent category such as `tourism.sights` does not become a canonical category by itself.

A generic building is insufficient. Historic building evidence requires both:

- `tourism.sights.building`
- `building.historic`

## Fatih membership truth predicate

A candidate is eligible only when all structured membership values are present as strings and match:

- `country_code = tr`
- `city = Istanbul`
- `town = Fatih`

Comparison may ignore surrounding whitespace and case.

The following do not establish membership:

- formatted address text
- postcode
- suburb
- provider query inclusion
- place name

Missing or mismatching required structured membership excludes the candidate.

## Coordinate truth predicate

Latitude and longitude must both be:

- numeric
- finite
- latitude within `[-90, 90]`
- longitude within `[-180, 180]`

Invalid or non-finite coordinates exclude the candidate.

## Identity and duplicate guardrail

Canonical provider identity is:

`geoapify:<place_id>`

Deduplication is by canonical provider ID only.

Same-name or nearby records with distinct provider IDs are not automatically merged. The current snapshot includes a duplicate-like same-name case with distinct IDs and coordinates.

No fuzzy, name-based, or proximity-based physical-place identity claim is supported.

## Current snapshot negative evidence

The current 20-record sample contains:

- 0 membership failures
- 0 coordinate failures
- 1 zero-mapping exclusion: `Beyaz?t Meydan?`
- 0 raw-to-normalized mismatches

Therefore outside-Fatih and invalid-coordinate behavior is represented with sanitized synthetic fixtures rather than falsely claimed as observed failures in this snapshot.

## Fixture reference

Sanitized semantic cases:

`ai-ml/data/provider-spike/fixtures/v2-provider-semantics-cases.json`

These fixtures contain no credentials or raw provider payload.
