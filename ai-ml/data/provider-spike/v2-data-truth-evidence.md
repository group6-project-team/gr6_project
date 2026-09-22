# V2 Data-Truth Evidence ? P1

**Owner:** Asma Yahya Faris Bzoor ? AI/Data & Provider Semantics
**Baseline:** `main@edd5cab05a3c4c66b2cdcb68af9ea5d5fa589750`
**Provider:** Geoapify Places API
**Scope:** bounded Fatih, Istanbul real-provider sample
**Retrieval timestamp:** `2026-09-21T16:53:42+03:00`
**Raw evidence:** `Backend/TripPlanning.Api.Tests/Evidence/Stage3/geoapify-raw-response-latest-main.json`
**Normalized evidence:** `Backend/TripPlanning.Api.Tests/Evidence/Stage3/geoapify-normalized-candidates-latest-main.json`

## P1 status

This document records evidence only. It does not change Backend, planner, Flutter, taxonomy, destination scope, or any blocked global product decision.

The inspected snapshot contains:

- 20 raw provider records
- 19 accepted normalized candidates
- 1 excluded record
- 0 Fatih membership failures
- 0 invalid-coordinate failures
- 0 raw-to-normalized mapping mismatches

This is a bounded 20-record snapshot, not a provider-wide schema or prevalence claim. Provider results and optional metadata may change on later retrievals.

## Raw field prevalence

Nonblank observed values across the 20-record raw snapshot:

| Field | Observed |
|---|---:|
| address_line1 | 20/20 |
| address_line2 | 20/20 |
| categories | 20/20 |
| city | 20/20 |
| country | 20/20 |
| country_code | 20/20 |
| county | 20/20 |
| datasource | 20/20 |
| formatted | 20/20 |
| iso3166_2 | 20/20 |
| lat | 20/20 |
| lon | 20/20 |
| name | 20/20 |
| place_id | 20/20 |
| postcode | 20/20 |
| state | 20/20 |
| street | 20/20 |
| suburb | 20/20 |
| town | 20/20 |
| historic | 19/20 |
| details | 16/20 |
| name_international | 13/20 |
| wiki_and_media | 10/20 |
| quarter | 6/20 |
| building | 3/20 |
| color | 1/20 |
| facilities | 1/20 |
| housenumber | 1/20 |
| way | 1/20 |

## Optional metadata feasibility observations

### `formatted`

`properties.formatted` is present as a string in 20/20 records in this snapshot.

Observed audit:

- blank after trim: 0/20
- minimum trimmed length: 35
- maximum trimmed length: 107
- values over 256 characters: 0/20
- values over 512 characters: 0/20
- control-character cases: 0/20
- HTML/script-like cases: 0/20

These observations support feasibility analysis only. They do not prove that future provider values are always present, short, or safe.

### Wiki/media

Wiki/media metadata is optional and incomplete:

- `wiki_and_media`: 10/20
- `wiki_and_media.wikidata`: 8/20
- `wiki_and_media.wikimedia_commons`: 9/20
- `wiki_and_media.wikipedia`: 5/20
- `wiki_and_media.image`: 4/20

Nested raw datasource metadata also contains some wiki-related fields.

Website/wiki/media remain outside the frozen MVP unless explicitly approved later.

### Rating / opening hours / price / website

A recursive key-path audit of the complete 20-record snapshot found no observed path matching:

- rating
- opening / hours
- price
- website

Therefore this snapshot provides no reproducible source for exposing rating, opening-hours, price, or website semantics in V2.

This is an evidence limitation, not a claim that Geoapify can never provide such fields in other requests or products.

## Raw ? normalized category trace

Approved current canonical mapping behavior reproduced exactly against the committed normalized artifact:

| Provider predicate | Canonical categories | Count | Result |
|---|---|---:|---|
| `tourism.sights.ruines` | `historic_site` | 3 | accepted |
| `tourism.sights.memorial` | `historic_site` | 7 | accepted |
| `tourism.sights.building` + `building.historic` | `historic_site` | 6 | accepted |
| `tourism.sights.memorial.monument` | `historic_site`, `monument` | 3 | accepted |
| no approved mapping (`tourism.sights.square`) | none | 1 | excluded |

Exact reconciliation:

`20 raw = 19 accepted + 1 excluded`

Excluded record:

- `Beyaz?t Meydan?`
- observed category includes `tourism.sights.square`
- no approved canonical mapping
- no fallback category is invented

## Public interest ? canonical category evidence

Frozen public mappings remain:

- `history ? historic_site`
- `landmark ? monument`

This document does not add interests or taxonomy values.

A `landmark` match is therefore supportable only where the canonical candidate actually contains `monument`.

A `history` match is supportable only where the canonical candidate actually contains `historic_site`.

Recommendation-reason semantics such as `INTEREST_MATCH` are not finalized here. Final reason truth predicates remain pending Ahmad's factor definition.

## Membership and coordinates

All 20 inspected raw records satisfy the current bounded Fatih membership evidence:

- `country_code = tr`
- `city = Istanbul`
- `town = Fatih`

All 20 inspected raw records also contain finite numeric coordinates within valid latitude/longitude ranges.

This evidence is snapshot-specific and must not be generalized into a claim about all provider results.

## Identity / duplicate limitation

The snapshot includes duplicate-like same-name records with distinct provider IDs and coordinates.

Provider `place_id` is source identity evidence; it is not proof of permanent physical-place uniqueness.

No fuzzy, name-based, or proximity-based physical deduplication is inferred from this evidence.

## P1 conclusion

P1 establishes a reproducible bounded-snapshot inventory and raw?normalized trace at baseline `edd5cab05a3c4c66b2cdcb68af9ea5d5fa589750`.

It supports continued V2 work on:

- optional address feasibility from `properties.formatted`
- rejection of unsupported rating/hours/price semantics
- frozen interest/category truth evidence
- later immutable snapshot review

It does not finalize:

- `INTEREST_MATCH` reason behavior
- snapshot DTO implementation
- Flutter rendering behavior
- any blocked P0/global product decision
## Reproducibility

Run:

`powershell
python ai-ml/data/provider-spike/analyze_v2_provider_evidence.py
`

The script reads only the committed Stage 3 raw and normalized snapshots. It does not call Geoapify and does not require credentials.

Expected baseline results:

- raw records: 20
- normalized candidates: 19
- membership failures: 0
- coordinate failures: 0
- raw-to-normalized mismatches: 0

## Normalized field inventory

All 19 accepted candidates contain the current six canonical PlaceCandidate fields:

| Field | Observed |
|---|---:|
| Id | 19/19 |
| DestinationId | 19/19 |
| Name | 19/19 |
| CategoryIds | 19/19 |
| Latitude | 19/19 |
| Longitude | 19/19 |

No optional address, rating, opening-hours, price, website, wiki/media, or raw provider blob is present in the normalized snapshot at this baseline.
