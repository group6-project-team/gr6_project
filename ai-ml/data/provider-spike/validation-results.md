# Iteration 2 — Canonical Fixture Validation Results

## Purpose

This document records the structural validation and traceability checks performed on the Iteration 2 Geoapify canonical development fixtures.

The goal is to verify that the clean normalized fixtures follow the current `PlaceCandidate` contract and remain traceable to their provider evidence.

---

## Validated Fixtures

The following clean fixtures were validated:

- `canonical-fixtures/fatih-clean.json`
- `canonical-fixtures/rome-clean.json`

Companion provenance artifacts:

- `canonical-fixtures/fatih-clean-provenance.json`
- `canonical-fixtures/rome-clean-provenance.json`

Unresolved evidence is kept separately:

- `canonical-fixtures/fatih-unresolved.json`
- `canonical-fixtures/rome-unresolved.json`

---

## Structural Validation Scope

The validation checked that every clean candidate:

- is valid JSON;
- contains exactly the six required fields:
  - `id`
  - `destinationId`
  - `name`
  - `categoryIds`
  - `latitude`
  - `longitude`
- uses non-empty strings for `id`, `destinationId`, and `name`;
- uses a list for `categoryIds`;
- contains only non-empty string category IDs;
- contains no duplicate category IDs;
- uses numeric latitude and longitude values;
- uses finite coordinate values;
- keeps latitude within `-90` to `90`;
- keeps longitude within `-180` to `180`;
- has a unique candidate ID within the fixture.

---

## Structural Validation Command

The clean fixtures were validated locally with Python:

```powershell
@'
import json
from pathlib import Path
from math import isfinite

base = Path("ai-ml/data/provider-spike/canonical-fixtures")
files = ["fatih-clean.json", "rome-clean.json"]

required = {"id", "destinationId", "name", "categoryIds", "latitude", "longitude"}

for filename in files:
    path = base / filename
    data = json.loads(path.read_text(encoding="utf-8-sig"))

    print(f"\nValidating {filename} ...")

    ids = set()

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

    print(f"PASS: {len(data)} records")
'@ | python