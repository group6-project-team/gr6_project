# V2 Immutable Snapshot Semantic Guardrails

**Owner:** Asma Yahya Faris Bzoor ? AI/Data & Provider Semantics
**Baseline:** `main@edd5cab05a3c4c66b2cdcb68af9ea5d5fa589750`

## Purpose

This document defines the data-truth conditions an immutable V2 candidate snapshot must preserve.

It is an evidence contract only. It does not implement or approve Mohammad's production DTO or persistence design.

Final Backend semantic PASS/FAIL must be issued against Mohammad's exact PR head SHA.

## Allowed semantic content

A frozen candidate snapshot may preserve only truthfully normalized public semantics needed by the approved contract.

Expected semantic fields may include:

- canonical candidate identity
- public destination identity
- candidate display name
- canonical category IDs
- finite validated latitude
- finite validated longitude
- optional sanitized address, if the approved address predicate passes

The optional address source is limited to provider `properties.formatted` under the separate V2 address evidence rules.

## Identity

Canonical provider-backed candidate identity is:

`geoapify:<place_id>`

Requirements:

- provider `place_id` must be nonblank
- the provider namespace prefix must remain explicit
- snapshot identity must not be reconstructed from name, coordinates, or address
- same-name candidates with distinct canonical IDs remain distinct

Provider identity is not a universal physical-place identity guarantee.

## Membership

Only records passing the approved structured Fatih predicate are eligible for snapshot inclusion:

- `country_code = tr`
- `city = Istanbul`
- `town = Fatih`

Required signals must be present as strings.

Formatted address, postcode, suburb, query inclusion, or display name must not override missing or mismatching structured membership.

## Canonical categories

Snapshot categories must contain only approved canonical category IDs derived from approved provider predicates.

For current frozen public scope:

- `historic_site`
- `monument`

Rules:

- zero mapped categories => candidate excluded
- no provider category blob is exposed as a public canonical category
- no fallback category is invented
- no new taxonomy value is introduced by snapshot serialization

## Coordinates

Snapshot coordinates must preserve only values already validated as:

- numeric
- finite
- latitude within `[-90, 90]`
- longitude within `[-180, 180]`

Invalid coordinates exclude the candidate rather than being coerced or replaced.

## Optional address

If the approved snapshot DTO includes `address`, it must remain optional.

It may be present only when the V2 address truth predicate succeeds.

It must not be fabricated from:

- `address_line1`
- `address_line2`
- postcode
- street
- suburb
- city
- country
- any concatenation of provider fields

Missing/unusable `formatted` => address absent/null.

The numeric maximum-length decision remains P0-blocked until explicitly frozen.

## Duplicate limitation

The snapshot must not infer physical-place duplicates from:

- equal names
- similar names
- close coordinates
- matching formatted addresses

Canonical-ID deduplication is allowed.

Fuzzy or proximity-based deduplication is not supported by current evidence.

## Fields that must not be exposed

The immutable public snapshot must not contain:

- raw Geoapify response objects
- raw `datasource` blobs
- arbitrary provider category arrays
- provider/API credentials or keys
- request secrets
- rating
- opening hours
- price or price-level claims

Website and wiki/media metadata remain outside the frozen MVP.

## Provider provenance vs public snapshot

Evidence/provenance artifacts may retain enough sanitized information to reproduce normalization decisions.

That does not authorize copying raw provider blobs into the public immutable snapshot.

The public snapshot should preserve normalized truth, not implementation/debug payload.

## Immutability semantics

Once a snapshot is created for a planning result, its exposed candidate semantics must represent that captured planning input rather than silently changing because the live provider later changes.

A later provider retrieval is a new evidence event; it must not retroactively rewrite the meaning of an already-issued immutable snapshot.

Exact storage/versioning mechanics belong to the Backend implementation owner.

## Semantic review checklist for Mohammad PR

At Mohammad's exact PR head, review:

1. canonical identity source
2. structured Fatih membership before snapshot inclusion
3. canonical category-only exposure
4. finite coordinate preservation
5. optional address source and absence behavior
6. duplicate behavior
7. absence of raw provider blobs
8. absence of provider/API credentials
9. absence of rating/hours/price
10. no website/wiki/media MVP expansion
11. no invented fallback values
12. snapshot immutability behavior

Verdict format:

`PASS @ <exact SHA>`

or

`FAIL @ <exact SHA>`

Any FAIL must list the exact semantic finding.

## Current status

`PENDING ? Mohammad exact PR head not yet reviewed.`

This pending state is intentional and must not be converted into PASS based only on branch names, plans, or earlier SHAs.
