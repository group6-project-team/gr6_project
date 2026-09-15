# Iteration 2 — Canonical Fixture Validation Results

## Purpose

This document records the structural validation, model compatibility, traceability, source-review, and sanitization checks performed on the Iteration 2 Geoapify canonical development fixtures.

The goal is to verify that the clean normalized fixtures follow the current `PlaceCandidate` contract, remain traceable to provider evidence, and keep unresolved identity, taxonomy, and destination-boundary cases explicitly separated from accepted development fixtures.

---

## Validated Fixtures

The following clean fixtures were validated:

- `canonical-fixtures/fatih-clean.json`
- `canonical-fixtures/rome-clean.json`

Companion provenance artifacts:

- `canonical-fixtures/fatih-clean-provenance.json`
- `canonical-fixtures/rome-clean-provenance.json`

Unresolved evidence artifacts:

- `canonical-fixtures/fatih-unresolved.json`
- `canonical-fixtures/rome-unresolved.json`

---

## Fixture Coverage Note

The Iteration 2 canonical fixtures are intentionally selective development fixtures and are not an exhaustive normalization of all 40 primary provider records.

The primary samples were reviewed across:

- 20 Fatih records
- 20 Rome records

The extra Rome `limit=10` sample remains supporting request-limit evidence only and is not automatically counted as additional unique provider evidence.

Only records with currently justified development mappings were promoted into the clean fixtures.

Known ambiguous identity and destination-boundary cases were separated into unresolved companion artifacts.

Records not included in the clean or unresolved fixture artifacts remain part of the reviewed provider evidence but are not claimed as normalized Iteration 2 fixture records.

---

## Structural Validation Scope

The clean fixtures were checked for:

- valid JSON;
- exactly six required fields:
  - `id`
  - `destinationId`
  - `name`
  - `categoryIds`
  - `latitude`
  - `longitude`
- non-empty `id`;
- non-empty `destinationId`;
- non-empty `name`;
- `categoryIds` stored as a list;
- category IDs stored as non-empty strings;
- no duplicate category IDs;
- numeric latitude and longitude;
- finite coordinate values;
- latitude within `-90` to `90`;
- longitude within `-180` to `180`;
- unique fixture IDs.

---

## Structural and Planner Model Validation Command

```powershell
@'
import json
from pathlib import Path
from math import isfinite
import sys

sys.path.insert(0, "ai-ml")
from planning.models import PlaceCandidate

base = Path("ai-ml/data/provider-spike/canonical-fixtures")

files = ["fatih-clean.json", "rome-clean.json"]

required = {"id", "destinationId", "name", "categoryIds", "latitude", "longitude"}

for filename in files:
    path = base / filename
    data = json.loads(path.read_text(encoding="utf-8-sig"))

    print(f"=== {filename} ===")

    ids = set()
    destinations = set()

    for i, item in enumerate(data):
        assert set(item.keys()) == required, f"{filename} record {i}: unexpected/missing fields"

        assert isinstance(item["id"], str) and item["id"].strip()
        assert isinstance(item["destinationId"], str) and item["destinationId"].strip()
        assert isinstance(item["name"], str) and item["name"].strip()

        assert isinstance(item["categoryIds"], list)
        assert all(isinstance(x, str) and x.strip() for x in item["categoryIds"])
        assert len(item["categoryIds"]) == len(set(item["categoryIds"]))

        lat = item["latitude"]
        lon = item["longitude"]

        assert isinstance(lat, (int, float)) and not isinstance(lat, bool)
        assert isinstance(lon, (int, float)) and not isinstance(lon, bool)

        assert isfinite(lat) and isfinite(lon)
        assert -90 <= lat <= 90
        assert -180 <= lon <= 180

        assert item["id"] not in ids, f"Duplicate id: {item['id']}"
        ids.add(item["id"])

        destinations.add(item["destinationId"])

        PlaceCandidate.from_dict(item)

    assert len(destinations) == 1, f"{filename}: inconsistent destinationIds: {destinations}"

    print(f"PASS: {len(data)} records")
    print("PASS: PlaceCandidate.from_dict")
    print(f"PASS: destinationId={next(iter(destinations))}")
'@ | python
```

## Structural and Model Validation Result

```text
=== fatih-clean.json ===
PASS: 4 records
PASS: PlaceCandidate.from_dict
PASS: destinationId=istanbul-tr

=== rome-clean.json ===
PASS: 7 records
PASS: PlaceCandidate.from_dict
PASS: destinationId=rome-it
```

The Rome development destination ID `rome-it` is an Iteration 2 fixture identifier only.

It is not sourced from Geoapify and is not claimed as the final Backend destination ID.

---

## Traceability Validation

Each clean normalized fixture record was checked against its companion provenance artifact.

The validation confirmed that:

- every clean fixture ID has matching provenance;
- clean fixture IDs are unique;
- provenance fixture IDs are unique;
- no orphan provenance entries exist;
- source file is retained;
- source record index is retained;
- provider `place_id` is retained;
- observed provider categories are retained;
- category mapping decisions are recorded.

## Traceability Result

```text
=== fatih-clean.json ===
PASS: IDs unique and provenance matches clean fixture exactly

=== rome-clean.json ===
PASS: IDs unique and provenance matches clean fixture exactly
```

---

## Unresolved Record Traceability

All unresolved records retain direct source references.

Each unresolved record includes:

- `caseId`
- `sourceFile`
- `sourceRecordIndex`
- `providerPlaceId`
- `destinationId`

Fatih unresolved records use:

- `destinationId = istanbul-tr`

Rome unresolved records use:

- `destinationId = rome-it`

This keeps unresolved evidence traceable and consistent while preserving the distinction between provider identity and development fixture scope.

---

## Full Primary-Sample Review

A final evidence review was performed across the complete primary provider samples.

### Primary Evidence Counts

- Fatih: 20 records
- Rome: 20 records
- Rome `limit=10` sample: supporting request-limit evidence only

---

## Fatih Category Review

Observed across the 20 Fatih primary records:

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

A duplicate-name review identified:

- `Atik Ali Paşa Medresesi` — 2 provider records

These records remain unresolved duplicate-like evidence and are not silently deduplicated.

---

## Rome Category Review

Observed across the 20 Rome primary records:

- `tourism`
- `tourism.sights`
- `tourism.sights.archaeological_site`
- `tourism.sights.memorial`
- `tourism.sights.memorial.monument`
- `tourism.sights.memorial.tumulus`
- `tourism.sights.ruines`

`tourism.sights.memorial.tumulus` remains unresolved.

No invented canonical meaning is assigned.

---

## Rome Destination-Boundary Review

Observed `properties.city` values across the 20 Rome primary records:

- Rome: 17
- Riano: 2
- Formello: 1

The two Riano records and one Formello record remain unresolved destination-boundary evidence.

They are excluded from the claimed clean Rome fixture.

No production destination-membership rule is inferred from `properties.city`.

---

## JSON Parse Validation

All six Iteration 2 JSON artifacts were parsed successfully.

### Command

```powershell
$files = @(
  "ai-ml\data\provider-spike\canonical-fixtures\fatih-clean.json",
  "ai-ml\data\provider-spike\canonical-fixtures\fatih-clean-provenance.json",
  "ai-ml\data\provider-spike\canonical-fixtures\fatih-unresolved.json",
  "ai-ml\data\provider-spike\canonical-fixtures\rome-clean.json",
  "ai-ml\data\provider-spike\canonical-fixtures\rome-clean-provenance.json",
  "ai-ml\data\provider-spike\canonical-fixtures\rome-unresolved.json"
)

foreach ($file in $files) {
    try {
        Get-Content $file -Raw | ConvertFrom-Json | Out-Null
        Write-Host "PASS: $file"
    }
    catch {
        Write-Host "FAIL: $file"
        Write-Host $_
    }
}
```

### Result

```text
PASS: ai-ml\data\provider-spike\canonical-fixtures\fatih-clean.json
PASS: ai-ml\data\provider-spike\canonical-fixtures\fatih-clean-provenance.json
PASS: ai-ml\data\provider-spike\canonical-fixtures\fatih-unresolved.json
PASS: ai-ml\data\provider-spike\canonical-fixtures\rome-clean.json
PASS: ai-ml\data\provider-spike\canonical-fixtures\rome-clean-provenance.json
PASS: ai-ml\data\provider-spike\canonical-fixtures\rome-unresolved.json
```

---

## Category Validation Notes

Raw Geoapify categories are retained only as provenance/evidence.

They are not passed directly into canonical `categoryIds`.

Development fixture categories such as:

- `history`
- `landmark`

remain development mappings only.

They do not finalize:

- Backend taxonomy;
- App Interest IDs;
- production eligibility;
- product semantics.

`tourism.sights.building` is not automatically classified as historical.

Historical classification requires corroborating observed historic or heritage evidence.

`tourism.sights.memorial.tumulus` remains unresolved.

---

## Zero-Category Validation Note

The current planner contract structurally permits:

```json
{
  "categoryIds": []
}
```

This is only a structural observation.

It does not approve zero-category records for production recommendation eligibility.

Iteration 2 does not invent fallback categories such as:

- `general`
- `other`

Final production eligibility remains a Backend/product decision.

---

## Optional Metadata Validation

Optional provider metadata is retained only when observed.

Examples may include:

- description;
- website;
- wiki/media information;
- address information;
- formatted address;
- provider datasource information.

Optional metadata is not fabricated.

It remains outside the strict six-field `PlaceCandidate` fixture unless separately coordinated.

---

## Secret and Request Sanitization

The provider-spike area was reviewed for likely secret-related strings.

The sanitized Rome request uses:

```text
apiKey=YOUR_API_KEY
```

No real API key, password, token, or provider credential is intentionally included in the Iteration 2 artifacts.

---

## Price and Budget Limitation

Reliable price semantics were not established from the current evidence.

`UNKNOWN` price must never be interpreted as `FREE`.

Budget support remains disabled.

---

## Validation Summary

| Validation Check | Result |
|---|---|
| Primary Fatih evidence count | PASS |
| Primary Rome evidence count | PASS |
| Extra `limit=10` evidence separated | PASS |
| Clean fixture JSON syntax | PASS |
| All six JSON artifacts parse successfully | PASS |
| Exact six-field clean fixture contract | PASS |
| Required string fields | PASS |
| Category list structure | PASS |
| Duplicate category IDs | PASS |
| Finite/ranged coordinates | PASS |
| Unique clean fixture IDs | PASS |
| Clean fixture → provenance traceability | PASS |
| Provenance has no orphan fixture IDs | PASS |
| Existing `PlaceCandidate.from_dict` compatibility | PASS |
| Within-fixture destination consistency | PASS |
| Unresolved record source traceability | PASS |
| Full 20-record Fatih category review | PASS |
| Full 20-record Rome category review | PASS |
| Fatih duplicate-name review | PASS |
| Rome city/boundary review | PASS |
| Unresolved cases separated from clean fixtures | PASS |
| Selective fixture coverage documented | PASS |
| Zero-category behavior documented | PASS |
| No raw provider-category passthrough | PASS |
| No fabricated optional metadata | PASS |
| Sanitized request evidence | PASS |

---

## Remaining Unresolved Decisions

The following remain intentionally unresolved:

- final sightseeing taxonomy;
- final historical taxonomy;
- `tourism.sights.building` without corroborating historical evidence;
- `tourism.sights.memorial.tumulus` canonical meaning;
- final App Interest IDs;
- duplicate-like physical-place identity;
- Rome / Riano / Formello production destination membership;
- production zero-category eligibility;
- rating semantics;
- price semantics;
- final Backend destination ID for Rome.

These decisions must not be silently finalized during normalization.

---

## Current Result

The Iteration 2 canonical fixture artifacts satisfy the current development contract and validation requirements for handoff.

The clean fixtures:

- are structurally valid;
- load through the existing planner model;
- use consistent development destination IDs;
- remain traceable to provider evidence;
- keep provenance outside the strict six-field object;
- keep ambiguous records outside the clean accepted fixture set.

All 20 Fatih and 20 Rome primary records were reviewed for category, identity, and destination-boundary evidence.

The canonical fixtures intentionally contain only selected records with justified development mappings.

Known identity, category, taxonomy, and destination-boundary ambiguity remains explicitly unresolved instead of being converted into unsupported production rules.

These fixtures remain development/test data only.
