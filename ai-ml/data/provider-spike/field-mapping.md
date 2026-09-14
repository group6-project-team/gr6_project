# Geoapify Places Data Spike — Canonical Field Mapping

## Purpose

This document records the traceable mapping between fields observed in the current Geoapify provider-spike evidence and the canonical place-candidate shape used by the trip-planning system.

Iteration 1 established the initial provider evidence. Iteration 2 refines that evidence into explicit, reproducible canonical mapping rules and development fixture guidance.

The mapping in this document is based only on the inspected Fatih and Rome samples. It must not be interpreted as a complete description of the Geoapify schema or as a finalized application taxonomy.

---

## Evidence Context

The current primary evidence base contains:

### Fatih Sample

- **Destination scope:** Fatih, Istanbul, Turkey
- **Provider:** Geoapify Places API
- **Query category:** `tourism.sights`
- **Primary sample size:** 20 returned records
- **Collection date:** 2026-09-13
- **Source file:** `sample-responses/fatih-istanbul-tourism-sights.txt`
- **Sanitized request context:** Geoapify Places API request for tourism sights within the selected Fatih development scope, with sensitive credentials omitted.

### Rome Sample

- **Destination scope:** Rome / Roma Capitale, Italy
- **Provider:** Geoapify Places API
- **Query category:** `tourism.sights`
- **Primary sample size:** 20 returned records
- **Collection date:** 2026-09-13
- **Source file:** `sample-responses/rome-tourism-sights.txt`
- **Sanitized request context:** Geoapify Places API request for tourism sights within the selected Rome development scope, with sensitive credentials omitted.

### Additional Limit Experiment

- **Source file:** `sample-responses/rome-tourism-sights-page1-limit10.txt`
- **Purpose:** Verify `limit=10` response behavior.
- **Evidence role:** Supporting request-limit evidence only.
- The returned records are not automatically counted as 10 additional unique provider records.
- The primary evidence count remains 20 Fatih records and 20 Rome records unless additional records are separately verified as unique evidence.

Only non-sensitive request information is documented. API keys, tokens, secrets, or other credentials must not be committed.

---

## Canonical PlaceCandidate Contract

The clean development fixtures produced from this evidence use the strict planner candidate shape:

- `id`
- `destinationId`
- `name`
- `categoryIds`
- `latitude`
- `longitude`

Provider-specific provenance, raw Geoapify categories, source identifiers, request scope, address metadata, descriptions, websites, image metadata, and other optional fields are not part of this strict six-field object.

Where such information is useful for traceability, it must remain in documentation or a separate companion provenance artifact.

---

## Field → Canonical Mapping

| Observed Geoapify Source | Canonical Field | Status | Mapping / Evidence Rule |
|---|---|---|---|
| `properties.place_id` | `id` | Observed source identity / Canonicalized | `place_id` is the observed Geoapify source identifier. It may be used as the basis of a declared development fixture ID mapping, but it must not be interpreted as guaranteed universal physical-place identity. |
| Fixture / request scope | `destinationId` | Explicitly assigned | `destinationId` does not come from a Geoapify provider field. It is assigned explicitly from the declared development fixture/request scope. It must not be inferred only from `properties.city`, `properties.county`, or another address field. |
| `properties.name` | `name` | Observed | Place name observed directly in the inspected source record. |
| `properties.categories` | `categoryIds` | Observed → Normalized | Raw Geoapify categories are evidence inputs only. They must pass through documented canonical normalization rules before producing canonical `categoryIds`. Raw categories must not be copied directly. |
| `properties.lat` | `latitude` | Observed | Latitude observed directly in the inspected source record. |
| `properties.lon` | `longitude` | Observed | Longitude observed directly in the inspected source record. |
| `properties.description` | Companion metadata only | Optional / Inconsistent | Observed only for some records. It is not part of the strict six-field `PlaceCandidate` fixture. |
| `properties.website` | Companion metadata only | Optional / Inconsistent | Observed in some provider evidence but not consistently enough to be a required canonical field. |
| `properties.wiki_and_media.image` | Companion metadata only | Optional / Inconsistent | Image data was observed only for some inspected records. This is the image location observed in the current evidence and must not be assumed to be Geoapify's only possible image source. |
| Not consistently observed | Rating metadata | Unconfirmed | No reliable rating field was established from the current inspected samples. |
| Not consistently observed | Price metadata | Unconfirmed | No reliable price semantics were established. `UNKNOWN` price must never be interpreted as `FREE`; Budget remains disabled. |

---

## Source Identity vs Canonical Identity

Geoapify `properties.place_id` is preserved as source evidence and provenance.

However, the current evidence does not demonstrate that one physical place will always correspond permanently to exactly one Geoapify `place_id`.

The observed duplicate-like Atik Ali Paşa case reinforces this limitation: two nearby records with the same or highly similar place name were returned with different provider identifiers and slightly different category structures.

Therefore:

- provider `place_id` is treated as source-specific identity;
- it is not treated as guaranteed physical-place uniqueness;
- canonical fixture IDs must follow a declared and reproducible fixture mapping policy;
- production deduplication is outside the scope of this iteration;
- duplicate-like records must remain documented rather than silently merged.

### Development Fixture ID Policy

Iteration 2 clean fixtures use local development IDs with the following declared form:

- Fatih: `fatih-001`, `fatih-002`, ...
- Rome: `rome-001`, `rome-002`, ...

These IDs are assigned to accepted clean fixture records in fixture order.

They are:

- deterministic within the committed fixture version;
- separate from Geoapify `place_id`;
- traceable to the source record through the companion provenance artifact;
- not claimed as permanent production place identifiers.

If fixture membership or ordering changes in a later iteration, ID stability must be reviewed rather than assumed.

---

## Destination Assignment Policy

`destinationId` is assigned from the declared development fixture/request scope.

It is not an observed Geoapify field.

A returned provider record may contain address metadata such as:

- `city`
- `town`
- `suburb`
- `county`
- `state`
- `formatted`

These fields may support traceability, but they do not independently define the canonical `destinationId`.

This distinction is important because the Rome evidence contains records associated with the broader Roma Capitale request boundary while some returned address metadata identifies other city values including `Riano` and `Formello`.

For development fixtures, the destination scope must therefore be declared explicitly and applied consistently.

Production destination-membership decisions are outside the scope of this iteration.

---

## Category Normalization Flow

Geoapify categories must not be copied directly into application `categoryIds`.

The intended flow is:

`Observed Geoapify Category → Evidence Review → Canonical Mapping Decision → categoryIds`

The provider taxonomy and the application's canonical taxonomy are separate concerns.

Iteration 2 documents evidence-supported proposals, but it does not finalize the application's full taxonomy or App Interest IDs.

---

## Category Mapping Evidence / Proposal

The mappings below describe evidence-supported semantic proposals only.

They do not finalize App Interest IDs or Backend taxonomy values.

The current planner development fixtures use category strings such as `history` and `landmark`, but those existing mock values are not treated here as proof of final product taxonomy.

Any category IDs used in Iteration 2 normalized fixtures must be declared explicitly as development fixture mappings and must remain distinguishable from final product taxonomy decisions.

| Geoapify Category | Proposed Semantic Meaning | Status | Evidence Rule |
|---|---|---|---|
| `tourism.sights` | sightseeing / landmark-like | Draft | General tourism-sight signal observed in both destination samples. |
| `tourism.sights.square` | sightseeing / landmark-like | Draft | Public-square tourism signal observed in the inspected evidence. |
| `tourism.sights.archaeological_site` | historical / heritage-like | Draft | Archaeological-site semantics provide explicit historical or heritage evidence. |
| `tourism.sights.memorial` | historical / commemorative-like | Draft | Memorial semantics support a historical or commemorative interpretation. |
| `tourism.sights.memorial.monument` | historical / landmark-like | Draft | Monument semantics support historical and landmark-like interpretation. |
| `tourism.sights.ruines` | historical / heritage-like | Draft | Ruins provide an explicit historical or heritage signal. |
| `tourism.sights.memorial.tumulus` | No accepted mapping yet | Observed / Unresolved | Observed in the full Rome primary sample. Iteration 2 does not invent a canonical meaning for this category; records depending on this semantic decision remain unmapped until the taxonomy decision is coordinated. |
| `tourism.sights.building` | No automatic historical mapping | Conditional / Unresolved | A generic tourism building must not automatically become historical. Additional observed historic or heritage evidence is required. |

### Full Primary-Sample Category Review

Iteration 2 reviewed the category values observed across all 20 Fatih primary records and all 20 Rome primary records.

Observed Fatih category values include:

- `building`
- `building.historic`
- `highway`
- `highway.pedestrian`
- `man_made`
- `tourism`
- `tourism.attraction`
- `tourism.sights`
- `tourism.sights.archaeological_site`
- `tourism.sights.building`
- `tourism.sights.memorial`
- `tourism.sights.memorial.monument`
- `tourism.sights.ruines`
- `tourism.sights.square`
- `wheelchair`
- `wheelchair.limited`

Observed Rome category values include:

- `tourism`
- `tourism.sights`
- `tourism.sights.archaeological_site`
- `tourism.sights.memorial`
- `tourism.sights.memorial.monument`
- `tourism.sights.memorial.tumulus`
- `tourism.sights.ruines`

Only categories with an explicit documented development mapping are used to produce accepted fixture `categoryIds`.

Other observed provider categories, including parent, accessibility, transport, generic tourism, or otherwise unresolved values, remain provenance evidence and are not assigned invented canonical meanings.

### Development Fixture Category Policy

For Iteration 2 fixtures, category IDs must be declared as development-only mappings.

Where a provider record has clear evidence and an existing planner development category is used, the provenance must record the exact mapping decision.

For example, a record with explicit historic evidence may use a development fixture category such as `history`, while a monument may additionally justify `landmark`.

This does not finalize Backend taxonomy, App Interest IDs, or production category semantics.

---

## Historical Classification Rule

`tourism.sights.building` alone is not sufficient evidence for the canonical meaning `historical`.

A building may be treated as a historical candidate only when an additional observed signal supports that interpretation.

Examples of potentially supporting provider evidence may include an explicit historic category or another clearly observed heritage-related signal in the same record.

This iteration does not create a universal historical classification rule and does not silently equate Geoapify categories with Backend values such as `historic_site` or `history`.

Final Backend taxonomy and App Interest mapping remain separate decisions owned by the relevant consumers.

---

## Raw Category Preservation

Raw Geoapify categories are useful for provenance and category-decision traceability.

They must not be inserted unchanged into canonical `categoryIds`.

When normalized fixtures are created:

- accepted canonical categories belong in the strict fixture;
- original provider categories should remain available in provenance evidence where needed;
- unresolved category semantics must remain visibly unresolved;
- unsupported provider categories must not be given invented canonical meanings.

---

## Zero-Category Proposal

The planner contract structurally allows:

`"categoryIds": []`

This structural allowance does not mean that a zero-category place is automatically eligible for production recommendation.

For Iteration 2 development fixtures:

- a record may remain structurally representable with an empty `categoryIds` array when its provider evidence is valid but no current canonical category mapping is justified;
- such a record must be clearly identified as unmapped or unresolved;
- it must not be presented as evidence of an accepted category mapping;
- no artificial `general`, `other`, or equivalent category should be invented solely to avoid an empty category list;
- final production eligibility remains a Backend/product decision outside this scope.

---

## Clean vs Unresolved Fixture Records

Iteration 2 separates clean consumable fixtures from records whose semantics remain ambiguous.

### Clean Fixture Record

A clean normalized record must have:

- a declared canonical fixture ID;
- an explicitly assigned development `destinationId`;
- a usable observed name;
- valid finite latitude and longitude;
- canonical `categoryIds` supported by documented mapping evidence;
- traceable source provenance.

### Unresolved / Ambiguous Record

A record should remain outside the claimed clean accepted mapping set when:

- its category meaning cannot currently be justified;
- its destination membership is ambiguous;
- its identity relationship to another duplicate-like record is unresolved;
- required canonical fields cannot be supported from the source evidence.

Such records may remain documented in companion evidence but must not be silently normalized as if the unresolved decision had already been made.

---

## Known Identity Limitation — Atik Ali Paşa

The Fatih evidence contains a duplicate-like Atik Ali Paşa case.

The inspected records show:

- the same or highly similar place name;
- nearby coordinates;
- different Geoapify `place_id` values;
- slightly different category structures.

A full primary-sample duplicate-name review found this as the only repeated place name in the 20-record Fatih primary sample.

This is documented as an identity limitation.

Iteration 2 does not implement production deduplication and does not claim that the records definitely represent either one or multiple physical places.

The case remains traceable evidence for later deduplication decisions.

---

## Known Destination-Boundary Limitation — Rome / Riano / Formello

The Rome sample was collected using a broader Rome / Roma Capitale development request scope.

Across the 20 primary Rome records, the observed `properties.city` values were:

- Rome: 17 records
- Riano: 2 records
- Formello: 1 record

The Riano and Formello records demonstrate that the selected provider request boundary and the returned address-level city value are not identical concepts.

This demonstrates that:

- provider request boundaries and address `city` values may not be identical concepts;
- `properties.city` must not be used by itself to generate `destinationId`;
- the development fixture scope must be explicit;
- production destination membership remains unresolved and outside this iteration.

The Riano and Formello records are retained as unresolved boundary evidence rather than being silently treated as accepted Rome fixture members.

---

## Optional Metadata

Optional metadata should be retained only when it is actually observed.

Examples in the current evidence include:

- description;
- website;
- wiki/media information;
- address information;
- formatted address;
- provider datasource information.

Optional metadata must not be fabricated to make records look complete.

When retained for traceability, optional fields should live in documentation or a separate companion provenance artifact rather than expanding the strict six-field planner candidate without coordination with consumers.

---

## Provenance Requirements

Every normalized development record should be traceable back to provider evidence.

Provenance should make it possible to identify:

- source destination sample;
- source file;
- provider `place_id`;
- observed provider categories;
- declared development destination scope;
- category mapping decision;
- unresolved identity, category, or boundary notes where applicable.

Provenance is not part of the strict six-field planner candidate and should be stored separately where necessary.

---

## Structural Validation Requirements

Canonical fixture validation must verify at least the following:

1. Fixture content is valid JSON.
2. Every clean candidate contains exactly the required planner fields:
   - `id`
   - `destinationId`
   - `name`
   - `categoryIds`
   - `latitude`
   - `longitude`
3. Required values are present and structurally valid.
4. Latitude and longitude are finite numeric values.
5. Latitude is within `-90` to `90`.
6. Longitude is within `-180` to `180`.
7. Candidate IDs are unique within the fixture.
8. `categoryIds` do not contain duplicate values.
9. Destination assignment is consistent with the declared fixture scope.
10. Every normalized record can be traced to source evidence.
11. Raw provider categories have not been passed directly into canonical `categoryIds` unless explicitly supported by a declared canonical mapping.
12. No fabricated optional metadata is present.
13. No API keys, secrets, or unsanitized sensitive request information are committed.

Actual validation commands and results should be recorded alongside the produced Iteration 2 fixtures.

---

## Evidence Limitations

The current conclusions are limited to the inspected provider evidence.

The evidence base currently consists primarily of:

- 20 Fatih tourism-sight records;
- 20 Rome tourism-sight records;
- one supporting Rome `limit=10` experiment.

This sample does not establish provider-wide coverage.

It does not prove:

- universal category behavior;
- global physical-place uniqueness;
- final destination membership;
- production deduplication behavior;
- complete optional metadata availability;
- reliable rating support;
- reliable price support;
- a finalized application taxonomy;
- finalized App Interest IDs;
- vendor lock-in suitability.

Geoapify currently provides useful evidence for development place discovery, but the limited sample must not be generalized beyond what was directly observed.

---

## Ownership / Coordination Boundaries

Iteration 2 documentation and fixture evidence are owned by AI / ML.

The current responsibility split is:

- AI / ML documents provider evidence, canonical mapping proposals, normalized fixtures, provenance, and limitations.
- Backend owns later mapping implementation, production eligibility, destination membership, and production deduplication.
- Planner consumers may use validated canonical fixtures for development and evaluation.
- Shared contract changes must be coordinated with affected owners before merge.

No live Geoapify integration, FastAPI service, provider adapter, production deployment, trained model, LLM, embeddings, or finalized taxonomy is required for this mapping task.

---

## Non-Goals

This iteration does not implement:

- live provider integration;
- ASP.NET provider adapters;
- planner ranking changes;
- production destination membership;
- production deduplication;
- final taxonomy;
- final App Interest IDs;
- Budget support;
- Auth/Login/JWT;
- database or cloud persistence;
- saved trips;
- direct Flutter → Geoapify communication;
- direct Flutter → FastAPI communication;
- trained models, LLMs, or embeddings;
- routing optimality;
- exact visit schedules;
- production deployment.

Fixtures and mocks produced here are development/test data only.

A network/provider failure must never silently become a fake successful itinerary.

---

## Current Mapping Status

The field-level canonical contract is sufficiently defined for Iteration 2 development fixtures.

Category mappings remain evidence-based proposals and are not final product taxonomy decisions.

The following cases remain intentionally unresolved:

- final sightseeing taxonomy;
- final historical taxonomy;
- `tourism.sights.building` without corroborating historical evidence;
- `tourism.sights.memorial.tumulus` canonical meaning;
- App Interest IDs;
- duplicate-like physical-place identity;
- Rome / Riano / Formello production destination membership;
- production zero-category eligibility;
- rating and price semantics.

These unresolved cases must remain visible in fixture provenance and PR documentation rather than being silently decided during normalization.