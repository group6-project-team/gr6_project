# Stage 3 Semantics Package

**Owner:** Asma Bzoor — AI/Data

**Scope:** Card 04 — Stage-3 Provider Semantics Handoff, minimum Fatih flow

**Status:** Card 04 Stage-3 semantics handoff is complete and Backend-confirmed. This focused revision retains the agreed public/taxonomy decisions and existing evidence. Mohammad’s final Backend handoff confirmation was received on 20 September 2026. Card 10 real-provider validation remains NOT RUN.

**Revision:** 20 September 2026 — final Backend confirmation recorded; Markdown formatting restored; accepted semantics unchanged

**Latest review baseline stated by the task card:** `6614578983758b41789c9a384114efc5d393ab30`. This is a supplied repository reference, not a claim that this document revision was tested against that checkout.

This package builds on existing Iteration 2 evidence. It prepares implementation guidance for Stage 3; it does not implement the production Geoapify client, Backend normalization, or orchestration.

Only decisions explicitly recorded as confirmed or accepted in this package should be treated as agreed for the minimum Stage 3 scope. Items still marked Pending remain open and must not be inferred or invented.

## 1. Existing Evidence Baseline

This package reuses the existing Geoapify provider/data evidence. No broad provider research spike is repeated.

The evidence baseline includes:

- 20 primary Fatih / Istanbul tourism-sights records.

- 20 primary Rome tourism-sights records.

- A separate Rome `limit=10` request/sample, retained as supporting request-limit evidence only. It is not automatically counted as additional unique evidence.

- Four clean Fatih development fixtures and seven clean Rome development fixtures.

- Companion provenance for every clean fixture record.

- Separate unresolved evidence for duplicate-like records in Fatih and destination-boundary cases in the Rome sample.

- Category review across all 40 primary records.

- Documented field mapping, development fixture ID policy, and destination-scope limitations.

- Documented distinction between provider identity and canonical identity.

- Documented zero-category structural behavior.

- Recorded JSON, structural, model, coordinate, ID, category, destination-consistency, and traceability validation.

- Sanitized provider request evidence using a placeholder rather than a real API key.

The clean fixtures are intentionally selective. Reviewing all 40 primary records does not mean that all 40 were normalized or approved for production use.

### 1.1 Evidence Artifacts

The existing evidence is located under:

`ai-ml/data/provider-spike/`

Key artifacts:

- `field-mapping.md`

- `findings.md`

- `supported-place-rules.md`

- `validation-results.md`

- `sample-responses/`

- `canonical-fixtures/fatih-clean.json`

- `canonical-fixtures/fatih-clean-provenance.json`

- `canonical-fixtures/fatih-unresolved.json`

- `canonical-fixtures/rome-clean.json`

- `canonical-fixtures/rome-clean-provenance.json`

- `canonical-fixtures/rome-unresolved.json`

The supporting Iteration 1/2 documents remain historical evidence. Where their provisional taxonomy or eligibility wording differs from the agreed minimum flow, use the current decisions in Sections 3–12 of this document. Updating this handoff does not require editing those historical files.

Earlier draft references to “general candidates” do not establish production eligibility and do not authorize inventing a fallback category named `general` or `other`. Stage 3 must state the agreed unmapped/zero-category policy explicitly.

### 1.2 Existing Canonical Contract

The Iteration 2 clean `PlaceCandidate` fixtures contain exactly:

- `id`

- `destinationId`

- `name`

- `categoryIds`

- `latitude`

- `longitude`

Provider-specific IDs, raw categories, source references, mapping explanations, and optional metadata remain outside this strict six-field object.

Compatibility checks were recorded against the planner model available during Iteration 2. Before implementation, confirm that the latest merged contract remains compatible.

### 1.3 Baseline Constraints and Open Decisions

The following describe the Iteration 2 baseline. Stage 3 decisions must be documented explicitly rather than silently inferred from development fixtures.

- Raw Geoapify categories require mapping before becoming canonical `categoryIds`.

- Provider `place_id` is source identity, not proof of unique physical-place identity.

- Provider `properties.city` must not be copied directly into `destinationId` or treated alone as a complete production membership rule.

- `tourism.sights.building` alone does not justify historical classification.

- `tourism.sights.memorial.tumulus` has no accepted mapping in the current evidence.

- The planner model structurally permits `categoryIds=[]`; this does not approve those records for production recommendations.

- No artificial fallback category should be invented solely to avoid an empty category list.

- Production physical-place deduplication was not solved in Iteration 2.

- Production destination-membership rules were not finalized.

- Final Backend taxonomy and public App Interest IDs were not frozen.

- Optional metadata must not be fabricated.

- Budget remains disabled for this release.

- UNKNOWN price must not be interpreted as FREE.

### 1.4 Evidence Cases to Carry Forward

**Fatih — duplicate-like identity**

`Atik Ali Paşa Medresesi` appears in two primary records with:

- Repeated naming.

- Nearby coordinates.

- Different provider `place_id` values.

- Some differences in category structure.

These observations do not prove whether the records represent one physical place or two. Preserve the evidence; do not silently merge or discard either record based on name/proximity alone.

**Rome — destination-boundary ambiguity**

The 20 primary Rome records contain these observed `city` values:

| Observed city | Records |
| ------------- | ------: |
| Rome | 17 |
| Riano | 2 |
| Formello | 1 |

The three Riano/Formello records were excluded from the clean Rome fixtures and retained as unresolved evidence.

This shows that provider-query scope and returned address-level city values can differ. Neither inclusion in the query results nor the city field alone establishes the product’s destination-membership policy.

### 1.5 Stage 3 Goal

Use the existing evidence to establish the minimum agreed rules for:

- Supported destination scope.

- Public Interest → canonical category mapping.

- Geoapify category → canonical category mapping.

- Destination membership and recommendation eligibility.

- Unmapped and zero-category behavior.

- Identity handling and deduplication limitations.

- Optional metadata.

- Disabled Budget behavior and unknown prices.

These sections establish the baseline and initial proposals. The handoff is complete only after the necessary implementation decisions are recorded and Mohammad confirms that no blocking semantic question remains.

## 2. Confirmed Minimum Destination Scope

### 2.1 Confirmed Minimum Scope

The minimum Stage 3 destination flow is confirmed as:

| Public destination | Real-provider scope | Status |
| --- | --- | --- |
| `istanbul` | Fatih district, Istanbul, Turkey | Confirmed minimum Stage 3 scope |
| `rome` | Deferred | Not included in the minimum Stage 3 scope because the current evidence still has Riano/Formello boundary ambiguity |

The Fatih evidence must not be presented as coverage of all Istanbul. The public ID `istanbul` routes to a Fatih-scoped real-provider candidate pool for this minimum flow.

### 2.2 Evidence Basis

Fatih is the smallest evidence-backed scope because the existing provider package contains:

- 20 primary Fatih / Istanbul records.

- Four clean development fixtures plus provenance.

- Duplicate-like identity evidence.

- Reviewed category evidence and fixture migration results.

- A bounded Fatih provider request and membership review.

- 20/20 bounded-request records matching the required `country_code=tr`, `city=Istanbul`, `town=Fatih`, and valid-coordinate checks.

Rome remains useful evidence, but it is deferred from the minimum supported flow because the sample contains 17 Rome, two Riano, and one Formello records.

### 2.3 Destination Identifiers and Routing

Confirmed routing for the minimum flow:

- Public Flutter/Backend destination ID: `istanbul`.

- Real-provider candidate pool behind `istanbul`: Fatih-only.

- Development fixture ID: `istanbul-tr`; this remains a fixture/development identifier and must not be exposed as the public destination ID.

- `rome-it` remains a development fixture identifier for the deferred Rome evidence.

Backend owns the routing from public `istanbul` to the Fatih-scoped candidate pool. This does not require renaming existing development fixtures.

### 2.4 Exact Boundary Evidence and Final Review

The exact boundary evidence is already present in the existing Card 04 files: the geocoding result at `/response/results/2`, bounded request filter, and membership review contain the same Fatih `place_id`. Section 15 records the exact value, retrieval timestamps, request context and three source filenames directly. No additional evidence-index file or repeat provider request is required to read this handoff. The original capture files retain their historical review-pending status; final acceptance must be documented through the actual team confirmation.

Do not expand the minimum flow to all Istanbul or re-open broad Rome research to close this handoff.

## 3. Minimum Public Interest Options / IDs — Release Scope Confirmed

### 3.1 Confirmed Minimum Public Options

The team confirmed these minimum public App Interest IDs for the Stage 3 flow:

- `history`

- `landmark`

Mohammad accepted this minimum scope, Heba confirmed that Flutter can update its screen/catalog accordingly, and Ahmad confirmed it from the public release-scope side.

The existing temporary Stage 1 Flutter catalog contains `history`, `culture`, `art`, `nature`, `adventure`, and `food`. Only `history` and `landmark` are included in the confirmed minimum Stage 3 scope. This package does not define provider mappings for the other existing options.

### 3.2 Contract Boundary — Confirmed

The earlier planner/FastAPI snapshot reported by Ahmad during the mapping review was:

`7f41755a7744721421471c93dff526be5496ff6e`

Relevant references supplied by Ahmad:

- `docs/contracts/planning-service-v0.md`

- `ai-ml/service/schemas.py`

- `ai-ml/planning/planner.py`

- `ai-ml/planning/models.py`

The confirmed boundary is:

1. Flutter sends agreed public App Interest IDs.

2. Backend maps those public IDs to canonical category IDs.

3. `/plan.interests` receives canonical category IDs only.

4. The planner matches the requested canonical IDs against `PlaceCandidate.categoryIds`.

The reported contract behavior does not define a fixed canonical allowlist. The latest supplied review baseline is recorded in the document header; compatibility with that checkout must be distinguished from the earlier review. Verified Stage 2A examples used IDs such as `historic_site`, `museum`, and `monument`, but those examples do not define the complete taxonomy.

### 3.3 Agreed Public Interest → Canonical Mapping

Retain the following already accepted minimum mapping; this update does not reopen public options or taxonomy:

| Confirmed public App Interest ID | Canonical category IDs sent to `/plan` | Evidence basis | Status |
| --- | --- | --- | --- |
| `history` | `historic_site` | Current evidence contains archaeological sites, memorial/historic evidence, ruins, and corroborated historic places | Accepted by TL and Backend for the minimum Stage 3 scope |
| `landmark` | `monument` | Current evidence contains explicit `tourism.sights.memorial.monument` records | Accepted by TL and Backend for the minimum Stage 3 scope |

This minimum mapping does not map `history` to `museum`, because the inspected provider evidence does not establish a museum mapping. It does not map generic sightseeing buildings or squares to `monument` without explicit accepted evidence.

The public and canonical layers remain distinct even when their concepts overlap. Backend must apply this mapping explicitly before calling `/plan`.

### 3.4 Fixture Migration Requirement

The original Iteration 2 fixtures used `history` and `landmark` in `categoryIds`. The clean fixtures included in this archive have already been migrated to `historic_site` and, only where supported, `monument`. Development destination IDs and fixture IDs remain unchanged.

The affected Stage 3/provider clean fixtures and provenance have been migrated consistently:

- Development `history` becomes canonical `historic_site` where the recorded evidence supports the historic-site rule.

- Development `landmark` becomes canonical `monument` only where explicit monument evidence supports it.

The migration preserved provenance and applied each mapping from observed provider evidence rather than blindly renaming old labels. Structural results are recorded in `fixture-migration-validation.md`.

Historical regression result reported in the supplied document (retained as reported evidence, not rerun during this archive review):

- Command: `python -m pytest planning/tests -v`

- Result: `83 passed in 1.21s`

- Environment: Windows, Python 3.13.12, pytest 9.1.1

- Status: PASS as reported in the earlier document. Its exact tested commit is not recorded here; it does not prove a run against the new `6614578...` baseline or validate Stage 3 normalization.

### 3.5 Existing Options Outside Minimum Scope

`culture`, `art`, `nature`, `adventure`, and `food` remain outside the confirmed minimum Stage 3 provider mapping in this package. The public contract/UI must handle them according to the team's release decision. They must not be silently mapped to `historic_site` or `monument`.

**Current status:** the minimum public IDs, mapping ownership, exact public-to-canonical mapping, and conservative Geoapify guidance are accepted by Ahmad and Mohammad for the minimum Stage 3 scope. Provider fixtures were migrated and repository regression tests were reported as `83 passed` in the earlier document. Final Backend handoff confirmation was received from Mohammad on 20 September 2026.

## 4. Geoapify Category → Canonical Mapping Guidance

### 4.1 Mapping Basis

Reuse the category evidence and mapping reasons recorded in:

- `field-mapping.md`

- `canonical-fixtures/fatih-clean-provenance.json`

- `canonical-fixtures/rome-clean-provenance.json`

The table below translates the existing evidence into the canonical IDs `historic_site` and `monument` accepted by Ahmad and Mohammad for the minimum Stage 3 scope.

| Observed Geoapify evidence | Canonical `categoryIds` | Guidance / limitation |
| --- | --- | --- |
| `tourism.sights.archaeological_site` | `historic_site` | Supported by the reviewed archaeological-site evidence |
| `tourism.sights.memorial` | `historic_site` | Apply the accepted minimum historic-site mapping; do not infer `monument` without explicit monument evidence |
| `tourism.sights.memorial.monument` | `historic_site`, `monument` | Supports both the history and landmark public flows |
| `tourism.sights.ruines` | `historic_site` | Accepted minimum mapping; preserve Geoapify's observed spelling `ruines` |
| `tourism.sights.building` with corroborating historic evidence | `historic_site` | Record-specific historic evidence is required; generic building alone is insufficient. `building.historic` is the demonstrated corroborating signal in the supplied examples, not a newly imposed exclusive rule |
| `tourism.sights.building` alone | No accepted mapping | Do not infer `historic_site` or `monument` |
| `tourism.sights.memorial.tumulus` | Unresolved | No subtype-specific canonical mapping is frozen |
| `tourism.sights`, `tourism.sights.square` | No accepted mapping in this package | Do not treat broad sightseeing/square labels as monuments automatically |
| Other observed categories | No mapping established | Preserve in provenance; do not invent canonical meanings |

### 4.2 Mapping Procedure

Using the already agreed release mapping, Backend should:

1. Read the provider category list.

2. Apply only explicitly accepted rules and their evidence conditions.

3. Combine the resulting canonical IDs without duplicates.

4. Preserve the source categories and applicable rule references outside `PlaceCandidate`.

5. Apply the unmapped and zero-category policies in Sections 7–8.

Do not use broad substring matching such as “contains `tourism`” to assign a canonical category.

Provider parent categories, accessibility categories, and other metadata must not automatically become user-interest categories.

### 4.3 Parent and Subtype Ambiguity

A record may contain both a broad category and a more specific unresolved subtype.

The presence of `tourism.sights.memorial` must not silently bypass the documented uncertainty around `tourism.sights.memorial.tumulus`.

**Proposed conservative release policy retained from the submitted draft:** hold records affected by an unresolved subtype decision outside the eligible pool until the relevant parent/subtype behavior is agreed.

Record the accepted behavior explicitly, including whether any independently supported category can still make such a record eligible. This revision does not freeze a stricter exclusion for all mixed-category records or invent a tumulus mapping.

### 4.4 Mapping Decision Record

The minimum public mapping and accepted Geoapify guidance retain their recorded team decisions. Section 4.3 preserves the unresolved subtype handling and its original proposal status; this document does not manufacture approval of an additional restriction. Preserve the actual reviewed version and confirmation reference in the final handoff.

## 5. Destination Membership Semantics — Agreed Minimum Fatih Policy

### 5.1 Minimum Supported Destination

The smallest defensible Stage 3 destination is ******Fatih district, Istanbul, Turkey******.

This choice is evidence-backed:

- The Fatih primary sample contains 20 records.

- All 20 have `country_code = tr`.

- All 20 have `city = Istanbul`.

- All 20 have `town = Fatih`.

- The sample was collected as `tourism.sights` within the selected Fatih development scope.

This policy does not claim support for all Istanbul. Public `istanbul` is confirmed. The existing fixture value `istanbul-tr` remains development-only.

Rome is deferred from the minimum supported destination policy. Its current sample contains 17 records with `city = Rome`, two with `city = Riano`, and one with `city = Formello`, so its exact production boundary requires a separate decision.

### 5.2 Confirmed Retrieval Policy

For the minimum Fatih flow, Backend should request:

- Geoapify Places category: `tourism.sights`;

- geographic filter: `filter=place:<approved-fatih-boundary-place-id>`;

- a bounded `limit` consistent with the release implementation;

- pagination only if explicitly implemented and validated.

The exact Fatih boundary `place_id` is preserved in the three timestamped JSON evidence files in this archive. The captured request used `limit=20` and `lang=en`; the number 20 is a sample/request limit, not evidence of complete coverage or a planner allocation limit. Do not substitute a radius or a city-text-only query for the recorded `place:` filter. Commit/PR inclusion is a separate repository workflow step and is not proved by this ZIP.

### 5.3 Confirmed Executable Membership Rule

A provider record is an accepted Fatih member only when all conditions are true:

1. It was returned by a request using the approved Fatih `filter=place:<id>` configuration.

2. `properties.country_code`, normalized by trimming and case-folding, equals `tr`.

3. `properties.city`, normalized by trimming and case-folding, equals `istanbul`.

4. `properties.town`, normalized by trimming and case-folding, equals `fatih`.

5. Latitude and longitude are present, numeric, finite, not booleans, and within valid ranges. The evidence mapping uses `properties.lat` → `latitude` and `properties.lon` → `longitude`, consistent with `field-mapping.md`. GeoJSON Point coordinates are ordered `[longitude, latitude]` and can have different precision; they are retained as evidence, not silently substituted for the documented source fields.

This rule uses signals present and consistent in all 20 primary Fatih records. It does not derive membership from `formatted`, `postcode`, `suburb`, or a fixture `destinationId`.

### 5.4 Conflict Precedence

Apply this conservative precedence:

1. A mismatch in `country_code`, `city`, or `town` makes the record out of scope, even if the boundary-filtered request returned it.

2. A missing `country_code`, `city`, or `town` makes membership unknown.

3. `formatted`, `address_line2`, `postcode`, and `suburb` are audit/supporting metadata only; they do not override a mismatch or missing required signal.

4. Query inclusion alone never overrides conflicting structured address evidence.

### 5.5 Unknown-Membership Behavior

An out-of-scope, conflicting, or unknown-membership record must:

- remain outside the production candidate pool;

- retain its source identity and relevant location evidence for audit;

- receive an internal exclusion reason without inventing a new public API warning code;

- never be silently reassigned to `istanbul-tr` or another destination.

### 5.6 Narrow Validation Completed

The narrow evidence checks required to freeze the Fatih policy are complete:

1. Exact Geoapify Fatih boundary `place_id` recorded:

   `510de9a683abf23c40598128f3ea77824440f00101f901d8f21a0000000000c002089203054661746968`.

2. Sanitized geocoding evidence preserves the Geoapify endpoint, request parameters with `apiKey=YOUR_API_KEY`, retrieval timestamp, and matching Fatih response feature.

3. One bounded production-equivalent Places request is preserved with `categories=tourism.sights`, the exact `filter=place:<id>`, `limit=20`, and `lang=en`.

4. Public/Backend destination routing is confirmed as public `istanbul` → Fatih-only candidate pool; `istanbul-tr` remains fixture-only.

5. The bounded Fatih request returned 20 records; all 20 matched the required membership fields and valid coordinate ranges in the recorded review.

No additional city research, arbitrary radius, hand-drawn polygon, or postcode allowlist is required for this minimum policy.

**Review status:** Fatih-only membership semantics are frozen for the minimum Stage 3 scope, the exact boundary evidence is complete, and Mohammad’s final Backend handoff confirmation was received on 20 September 2026.

## 6. Recommendation Eligibility Semantics

### 6.1 Structural Validity vs Eligibility

A record can satisfy `PlaceCandidate` structurally without being eligible for a production recommendation.

Eligibility determines whether a record enters the candidate pool. Planner ranking and selection happen afterward and remain outside this package.

### 6.2 Minimum Eligibility Policy — Accepted by Backend

A provider record may enter the supported candidate pool only when:

- Source identity is available and traceable.

- Its canonical ID follows the agreed Backend identity policy.

- Its name is usable and comes from observed source data.

- Coordinates are numeric, finite, and within valid latitude/longitude ranges.

- Membership passes the agreed rule for the requested destination.

- Category handling passes the agreed mapping and eligibility policies.

- It has no unresolved blocking identity or semantic issue under the agreed release policy.

- The resulting candidate contains exactly the six canonical fields.

Mohammad accepted this minimum policy in Backend review. The membership, category, and canonical ID rules are consolidated in Sections 4–5 and 9.3. Final confirmation of the complete handoff was received from Mohammad on 20 September 2026; this policy is not a claim that Backend normalization has run.

### 6.3 Exclusion Evidence

For excluded records, retain an appropriate reason in audit evidence or internal diagnostics, such as invalid coordinates or unresolved membership.

These descriptions do not define new public API warning codes.

Missing optional metadata alone should not exclude an otherwise eligible record unless an explicit release requirement makes that metadata mandatory.

## 7. Unmapped-Category Behavior

### 7.1 Definition

An unmapped category is an observed provider category without an accepted release mapping.

Do not copy it into `categoryIds`, invent a canonical equivalent, or assign `general`/`other` merely to produce a non-empty list.

### 7.2 Handling — Accepted in Principle by Backend

- Preserve unmapped values in source/provenance evidence.

- If accepted rules produce canonical categories and no blocking semantic ambiguity exists, retain those accepted categories.

- If no accepted rule produces a category, apply Section 8.

- If an unresolved category changes the interpretation of another mapping, apply the agreed ambiguity policy from Section 4.3.

Unmapped incidental metadata and a blocking category ambiguity are different cases. Backend must be able to distinguish them from the documented rules.

## 8. Zero-Category Behavior

The current planner model structurally permits:

```json

{

  "categoryIds": []

}

```

This is not approval for recommendation eligibility.

**Backend review status:** Mohammad agreed in principle to exclude zero-category records from the production candidate pool while retaining their source evidence for review.

Keep that exclusion for the minimum flow. Do not reopen zero-category eligibility, change planner ranking, or invent fallback categories as part of this carry-over task.

**Decision status:** retained from Backend review; final Backend handoff confirmation was received on 20 September 2026.

## 9. Provider Identity and Deduplication

### 9.1 Identity Layers

| Identifier | Meaning |
| ------------------------ | ----------------------------------------------------- |
| Provider `place_id` | Identity of a source record at Geoapify |
| Canonical candidate `id` | Identity used within the application/planner contract |
| Development fixture ID | Local fixture identifier such as `fatih-001` |

The fixture-order ID policy must not automatically become the production identity policy.

Section 9.3 records the Backend-frozen canonical ID policy and source traceability.

### 9.2 Duplicate Handling Guidance — Conservative Rule Accepted in Principle

- Canonical IDs must be unique within a candidate pool.

- Apply the already frozen repeated-record policy in Section 9.3.

- Conflicting data under the same provider ID must not be silently combined.

- Different provider IDs do not prove different physical places.

- Similar names and nearby coordinates may identify review candidates, but do not prove physical equivalence.

### 9.3 Production Canonical Candidate ID Policy

For Geoapify-backed production candidates, the canonical `PlaceCandidate.id` must be deterministic and traceable to the original Geoapify record.

Policy:

- Use the Geoapify `place_id` as the source identity input.

- Generate the canonical candidate ID using the provider namespace plus the provider ID:

  `geoapify:<place_id>`

- The same Geoapify `place_id` encountered more than once within the same candidate-building operation must resolve to the same canonical candidate ID.

- Identical repeated records with the same provider `place_id` should produce one candidate while preserving traceability to the repeated source observations.

- If repeated records with the same provider `place_id` contain conflicting canonical-relevant data, they must not be silently merged. The candidate remains blocked until the conflict is handled explicitly.

- Different Geoapify `place_id` values remain different canonical candidate IDs even when names or coordinates are similar.

- This policy deduplicates repeated provider records only. It does not solve physical-place deduplication across different provider IDs.

**Decision status:** accepted and frozen by Mohammad from the Backend side.

### 9.4 Known Physical-Place Limitation

The two Atik Ali Paşa Medresesi records remain unresolved evidence.

Mohammad agreed in principle that duplicate-like places must not be merged from name similarity or proximity alone. No physical-place deduplication rule is established by this sample alone.

**Physical-place deduplication remains unsolved unless an explicit rule is supported by sufficient evidence and agreed for the release.**

## 10. Representative Normalized Fixtures

### 10.1 Existing Fixture Set

| Artifact | Count | Use |
| ----------------------------- | ----: | ------------------------------------ |
| `fatih-clean.json` | 4 | Canonical development-input examples |
| `rome-clean.json` | 7 | Canonical development-input examples |
| `fatih-clean-provenance.json` | 4 | Source and mapping traceability |
| `rome-clean-provenance.json` | 7 | Source and mapping traceability |
| `fatih-unresolved.json` | 2 | Duplicate-like identity review cases |
| `rome-unresolved.json` | 3 | Destination-boundary review cases |

These artifacts remain under `canonical-fixtures/`.

### 10.2 Representative Cases

- ******Gate of Salutation:****** historic evidence accompanying a generic sightseeing-building category.

- ******Milion:****** explicit memorial/monument evidence; migrated from the earlier development labels to canonical `historic_site` and `monument`.

- ******Archeological Park:****** archaeological-site mapping to migrated canonical category `historic_site`.

- ******Rome archaeological fixtures:****** additional examples of the same documented mapping.

- ******Atik records:****** unresolved physical identity.

- ******Riano/Formello records:****** unresolved destination membership.

### 10.3 Backend Consumption Conditions

The clean fixtures can support contract and normalization development. They are not a production allowlist or proof of destination-wide coverage.

Before adopting them as release expectations:

- Confirm the latest canonical contract and agreed IDs.

- Re-run relevant structural/model checks.

- Check expected outputs against the accepted release semantics.

- Preserve original source evidence and provenance.

- Record any fixture changes and their reasons.

Do not silently replace a failed live provider request with a successful fixture itinerary.

## 11. Optional Metadata Coverage and Limitations

Observed coverage is limited to the inspected samples.

| Metadata | Evidence status | Handling |
| ------------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------ |
| Description | Observed for some Rome records; not consistently available | Preserve when observed; do not generate missing content |
| Website | Present for some records | Treat as optional |
| Image | `wiki_and_media.image` observed in some Fatih records; not observed in the inspected Rome sample | Do not assume universal coverage or that this is the provider’s only possible image source |
| Address information | Present in the evidence | May support display/audit; not a complete membership rule by itself |
| Rating | No reliable coverage established | Do not invent or substitute a rating |
| Price | No trustworthy semantics established | Keep unknown; do not infer zero cost |

Optional metadata remains outside the strict six-field planner candidate.

Backend owns any agreed enrichment representation. UI handling of missing metadata requires coordination with Flutter rather than expanding `PlaceCandidate` unilaterally.

## 12. Budget and Price Semantics

**Budget remains disabled for this release.**

- Do not expose or send a budget input that the system silently ignores.

- Do not filter or rank candidates using unsupported price assumptions.

- Do not convert missing price information into `0`, `FREE`, or equivalent.

- Preserve the distinction between a known free price and an unknown price.

- Finding isolated price information does not authorize expanding release scope.

**UNKNOWN price does not mean FREE.**

Any future Budget support requires separate evidence, contract decisions, and implementation scope.

## 13. Implementation-Ready Handoff to Mohammad — Accepted

### 13.1 Package Contents

Deliver:

- This mapping/decision document.

- The existing representative fixtures and provenance.

- The unresolved identity and boundary examples.

- Validation commands and recorded results.

- A decision log identifying accepted rules and remaining blockers.

- The relevant PR/commit references.

AI/Data provides semantics and evidence. Mohammad owns production Backend implementation.

### 13.2 Decision Log

Complete the following before claiming implementation readiness:

| Decision | Agreed value / rule | Status | Evidence / next owner |
| --- | --- | --- | --- |
| Minimum supported destination | Public `istanbul` routed to Fatih district, Istanbul, Turkey | Confirmed minimum scope | Ahmad/Heba/Mohammad coordination; Sections 2, 5, and 15 |
| Public destination routing | Public `istanbul` → Fatih-scoped candidate pool; `istanbul-tr` remains fixture-only | Confirmed | Heba/Ahmad coordination; Sections 2 and 15 |
| Current Flutter Stage 1 catalog | `history`, `culture`, `art`, `nature`, `adventure`, `food` | Confirmed development state | Heba's response |
| Minimum Stage 3 public options | `history`, `landmark` | Confirmed release minimum | Ahmad/Mohammad/Heba coordination; Section 3 |
| Mapping ownership and `/plan` boundary | Backend owns both mapping layers; `/plan.interests` is canonical-only | Confirmed | Team responses and Mohammad review |
| Verified planner contract | Earlier reviewed snapshot `7f41755a7744721421471c93dff526be5496ff6e`; latest card reports `6614578983758b41789c9a384114efc5d393ab30` | Earlier contract review retained; latest checkout not independently tested in this archive | Ahmad / task-card baseline; Section 3.2 and document header |
| Canonical category IDs | `historic_site`, `monument` | Accepted for minimum Stage 3 scope | Ahmad + Mohammad reviews; Sections 3.3 and 4 |
| Public Interest → canonical mapping | `history` → `historic_site`; `landmark` → `monument` | Accepted for minimum Stage 3 scope | Ahmad + Mohammad reviews; Section 3.3 |
| Other current public IDs | Outside minimum Stage 3 mapping | Documented scope limitation | Section 3.5 |
| Provider category rules | Mapping to `historic_site` / `monument` in Section 4 | Accepted minimum mapping retained | Ahmad + Mohammad reviews; unresolved subtype handling keeps its proposal status in Section 4.3 |
| Membership mechanism and conflict handling | Fatih-only executable rule in Section 5 | Accepted for minimum Stage 3 scope | Exact boundary evidence and source filenames are recorded directly in Section 15; final Backend confirmation received 20 September 2026 |
| Eligibility policy | Minimum conditions in Section 6.2 | Accepted by Backend, with dependencies | Mohammad review |
| Unmapped-category behavior | No invented mapping; preserve evidence; use zero-category policy when none maps | Accepted in principle by Backend | Mohammad final handoff confirmation, 20 September 2026 |
| Zero-category behavior | Exclude from production pool; preserve evidence | Accepted in principle by Backend | Mohammad final handoff confirmation, 20 September 2026 |
| Canonical ID assignment | Deterministic provider-namespaced ID `geoapify:<place_id>`; identical repeated provider IDs collapse to one candidate with preserved traceability; conflicting repeats are not silently merged | Accepted and frozen by Backend | Section 9.3; Mohammad final review confirmation |
| Duplicate-like physical places | Do not merge from name/proximity alone | Accepted in principle by Backend | Mohammad review; Atik evidence |
| Optional metadata | Optional and not fabricated | Documented non-blocking limitation | Section 11; acknowledged in Mohammad final handoff confirmation |
| Budget and price | Budget disabled; UNKNOWN ≠ FREE | Fixed release constraint | Final Sprint Guide / Card 04 |

A proposal is not an accepted decision. Replace pending entries only with actual agreement and a traceable reference.

### 13.3 Review and Acceptance

Mohammad should confirm that the package answers:

- What provider evidence should be requested for each supported destination?

- How is destination membership established?

- Which records enter or leave the candidate pool?

- How are categories mapped, including ambiguous and unmapped cases?

- How are canonical IDs assigned and duplicates handled within the stated limits?

- Which metadata is optional?

- Which fixtures represent accepted behavior?

Any unanswered implementation-critical question keeps the handoff open.

An explicit, agreed unsupported behavior can resolve a release question without claiming that the broader research problem is solved.

## 14. Mohammad’s Handoff Review and Final Confirmation

**Current confirmation status: Final Backend handoff confirmation received — implementation-ready.**

### 14.1 Recorded Backend Review

Mohammad confirmed:

- Separation of Public Interest → canonical mapping from Geoapify → canonical mapping is correct.

- Backend owns both mappings.

- `/plan.interests` remains canonical-only.

- The minimum eligibility policy in Section 6.2 is acceptable.

- Excluding zero-category records is acceptable in principle.

- Unmapped categories must not receive invented mappings.

- Duplicate-like places must not be merged using name or proximity alone.

The supplied package records agreement on mapping, public destination, minimum membership semantics, and production candidate identity. The exact boundary evidence is present. The historical regression result is retained as reported evidence without claiming a new repository or Stage 3 runtime execution.

Mohammad provided final Backend confirmation on 20 September 2026. He confirmed that the agreed minimum Stage 3 semantics are implementation-ready and that no blocking semantic questions remain for mapping, membership, or eligibility in the agreed minimum Fatih flow.

### 14.2 Confirmation Record

| Confirmation field | Recorded value |
| --- | --- |
| Reviewer | Mohammad Salameh |
| First review date | 17 September 2026 |
| Final confirmation date | 20 September 2026 |
| Relevant Backend baseline | Latest task-card baseline: `6614578983758b41789c9a384114efc5d393ab30`; actual Stage 3 implementation SHA remains a Card 10 execution record |
| Accepted areas | Public `istanbul` → Fatih-only routing; Public Interest → canonical mapping; Geoapify → canonical mapping; destination membership and conflict handling; recommendation eligibility and exclusion behavior; zero/unmapped handling; production candidate IDs and repeated-record handling; conservative handling of unresolved blocking subtypes such as `tourism.sights.memorial.tumulus` |
| Remaining blocking questions | None |
| Final outcome | Confirmed — implementation-ready for the agreed minimum Fatih flow |
| Non-blocking limitations | Physical-place deduplication across different provider IDs is not solved; optional metadata coverage is incomplete; Budget remains disabled; Rome remains outside the minimum Stage 3 scope; the historical `83 passed` result does not prove execution against the latest Stage 3 implementation baseline |

### 14.3 Final Confirmation Record

Mohammad’s final Backend confirmation states that the agreed minimum Stage 3 semantics are implementation-ready and provide sufficient guidance to implement:

- public `istanbul` → Fatih-only candidate routing;
- Public Interest → canonical mapping;
- Geoapify → canonical category mapping;
- destination membership and conflict handling;
- recommendation eligibility and exclusion behavior;
- zero-category and unmapped-category handling;
- production canonical candidate IDs and repeated-record handling;
- conservative handling of unresolved blocking subtypes such as `tourism.sights.memorial.tumulus`.

Mohammad confirmed that no remaining blocking semantic questions exist for mapping, membership, or eligibility in the agreed minimum Fatih flow.

The documented limitations remain non-blocking:

- physical-place deduplication across different provider IDs is not solved;
- optional metadata coverage is incomplete;
- Budget remains disabled;
- Rome remains outside the minimum Stage 3 scope;
- the historical `83 passed` result does not prove execution against the latest Stage 3 implementation baseline.

**Card 04 completion status: COMPLETE for semantics handoff.**

Completion of this handoff does not establish that Stage 3 integration, real-data validation, or release verification has passed.

> Coordination note: the destination-routing and membership decisions from the latest team review are normalized into Section 15 below.

## 15. Final Coordination and Fatih Membership Evidence

This update supersedes earlier Pending entries for the public destination

ID, minimum destination scope, and membership semantics. The exact boundary identifier is now supported by sanitized geocoding evidence. Final Backend handoff confirmation was received from Mohammad on 20 September 2026.

### 15.1 Confirmed Destination Routing

| Item | Confirmed decision |
|---|---|
| Public Flutter/Backend destination ID | `istanbul` |
| Real-provider candidate pool behind it | Fatih-only |
| Development fixture destination ID | `istanbul-tr`; not a public destination ID |
| Rome | Deferred from the minimum Stage 3 scope |

Backend routes public `istanbul` to the Fatih-scoped candidate pool.

This describes destination routing; it does not introduce a new internal

destination ID or rename existing development fixtures.

### 15.2 Confirmed Membership Semantics

For returned place records:

- Retrieve candidates through the approved bounded Fatih provider request.

- Require `country_code=tr`, `city=Istanbul`, and `town=Fatih`.

- Compare required text fields after trimming and case normalization.

- Require finite numeric latitude within [-90, 90] and longitude within [-180, 180].

- Exclude conflicting or out-of-scope records.

- Treat missing required membership fields as unknown membership and exclude them.

- Preserve source evidence and exclusion reasons internally.

Membership acceptance does not replace category mapping, identity review,

or the remaining recommendation eligibility checks.

### 15.3 Boundary Candidate and Executed Request

The selected Geoapify geocoding result is the Fatih administrative result

from OpenStreetMap, at zero-based result index 2.

Boundary candidate `place_id`:

`510de9a683abf23c40598128f3ea77824440f00101f901d8f21a0000000000c002089203054661746968`

Relevant Geoapify feature and boundary details:

- `name=Fatih`

- `result_type=city`

- `category=administrative`

- `datasource=openstreetmap`

- `formatted=Fatih, Istanbul, Turkey`

- center coordinates: `lat=41.0192846`, `lon=28.9479296`

- boundary bbox: `[28.919882, 40.9876327, 28.9881084, 41.04086]`

Destination ID note:

- Public Flutter/Backend destination ID: `istanbul`

- `istanbul-tr` remains development/fixture-only and must not be exposed as a public destination ID.

Sanitized geocoding endpoint: `GET https://api.geoapify.com/v1/geocode/search`

Geocoding parameters:

- `text=Fatih, Istanbul, Turkey`

- `type=locality`

- `filter=countrycode:tr`

- `bias=countrycode:none`

- `lang=en`

- `limit=5`

- `format=json`

- `apiKey=YOUR_API_KEY`

Geocoding evidence retrieval time: `2026-09-17T20:07:19.257491Z`

Executed endpoint: `GET https://api.geoapify.com/v2/places`

Parameters:

- `categories=tourism.sights`

- `filter=place:510de9a683abf23c40598128f3ea77824440f00101f901d8f21a0000000000c002089203054661746968`

- `limit=20`

- `lang=en`

The API key is represented only by a placeholder in saved request evidence.

Evidence files under `ai-ml/data/provider-spike/`:

- `fatih-geocoding-20260917T200719257491Z.json`

- `fatih-bounded-response-20260917T201633097033Z.json`

- `fatih-membership-review-20260917T201633097033Z.json`

### 15.4 Observed Validation Result

- Request completed on 17 September 2026 at approximately 20:16:33 UTC.

- HTTP status: 200.

- Returned records: 20.

- Membership-field and coordinate-range matches: 20.

- Missing or mismatching required membership fields observed: 0.

Applying the reviewed category rules to the reported categories yields:

- 19 records with a supported `historic_site` mapping (mapping-only expectation, not a count from Backend production output).

- 3 of those 19 also map to `monument`.

- Source index 15, `Beyazıt Meydanı`, remains unmapped because the package

  does not define a canonical mapping for its square category.

  It is excluded under the zero-canonical-category policy.

Source indices 6 and 12 share the name `Fatih Sultan Mehmet Anıtı`,

but have different provider IDs and coordinates. This does not justify

merging them or claiming physical-place deduplication is solved.

The response contains multilingual source names despite `lang=en`.

Preserve source names; do not invent translations.

This is one bounded validation sample. It does not establish exhaustive

coverage, independent polygon verification, or full recommendation

eligibility. It is not counted as 20 additional unique places beyond

the existing Iteration 2 evidence.

### 15.5 Final Review Record

- Public destination routing: confirmed by Ahmad.

- Minimum membership semantics: accepted by Mohammad in principle and confirmed/frozen by Ahmad for the minimum Stage 3 scope.

- Bounded request evidence: captured on 17 September; source JSON and all 20 review rows cross-checked locally in this revision. This is an offline evidence check.

- Historical repository regression evidence (reported in the supplied document; exact tested SHA and raw console artifact are not included):

  - Command: `python -m pytest planning/tests -v`

  - Result: `83 passed in 1.21s`

  - Environment: Windows, Python 3.13.12, pytest 9.1.1

  - Status: PASS

- Exact Fatih boundary identifier evidence/reference: Complete — sanitized Geoapify geocoding request/response recorded for the exact `place_id`; Ahmad's coordination message identified this as the final boundary-evidence item.

- Final Backend handoff confirmation: CONFIRMED — Mohammad confirmed the agreed minimum Stage 3 semantics are implementation-ready on 20 September 2026, with no remaining blocking semantic questions for mapping, membership, or eligibility.

- Reviewer / confirmation / date: Mohammad Salameh — final Backend handoff confirmed — 20 September 2026.

The historical reported `83 passed` regression result above is retained without claiming a new repository or Stage 3 implementation run. The production canonical candidate ID policy is accepted and frozen by Backend, and the exact Fatih boundary `place_id` now has sanitized geocoding evidence plus bounded-request evidence. No remaining Card 04 semantic blocker exists for the agreed minimum Fatih flow.

### 15.6 Focused Source-Provenance Correction

This revision concerns only this semantics document and `canonical-fixtures/fatih-clean-provenance.json`. The latter restores three incorrectly encoded `observedName` values from the exact existing raw source records:

| Fixture ID | Source file | Zero-based source index | Restored observedName |
| --- | --- | ---: | --- |
| `fatih-001` | `sample-responses/fatih-istanbul-tourism-sights.txt` | 0 | `Bâbüsselâm` |
| `fatih-002` | `sample-responses/fatih-istanbul-tourism-sights.txt` | 6 | `Milyon Taşı` |
| `fatih-004` | `sample-responses/fatih-istanbul-tourism-sights.txt` | 9 | `Piskoposluk Sarayı` |

Source indices, provider IDs, raw categories, mapping reasons, and canonical fixture values are unchanged. The source spelling is recovered from the preserved response, not inferred or translated. The raw response files are not edited.
