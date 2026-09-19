# Stage 3 Provider Fixture Migration Validation

**Date:** 17 September 2026
**Scope:** Provider fixtures only; unrelated planner regression fixtures are unchanged
**Taxonomy:** Public `history` → canonical `historic_site`; public `landmark` → canonical `monument`

## Migrated Artifacts

- `canonical-fixtures/fatih-clean.json`
- `canonical-fixtures/fatih-clean-provenance.json`
- `canonical-fixtures/rome-clean.json`
- `canonical-fixtures/rome-clean-provenance.json`

The two unresolved artifacts were retained unchanged.

## Migration Result

| Fixture ID | Previous development categories | Stage 3 canonical categories |
| --- | --- | --- |
| `fatih-001` | `history, landmark` | `historic_site` |
| `fatih-002` | `history, landmark` | `historic_site, monument` |
| `fatih-003` | `history` | `historic_site` |
| `fatih-004` | `history` | `historic_site` |
| `rome-001` | `history, landmark` | `historic_site, monument` |
| `rome-002` | `history` | `historic_site` |
| `rome-003` | `history` | `historic_site` |
| `rome-004` | `history` | `historic_site` |
| `rome-005` | `history` | `historic_site` |
| `rome-006` | `history` | `historic_site` |
| `rome-007` | `history` | `historic_site` |

`fatih-001` now contains only `historic_site`: its evidence is an historic building, not an explicit monument. The two explicit `memorial.monument` records (`fatih-002` and `rome-001`) contain both `historic_site` and `monument`.

## Validation Results

| Check | Result |
| --- | --- |
| Fatih clean/provenance counts = 4/4 | PASS |
| Rome clean/provenance counts = 7/7 | PASS |
| Exact six-field clean fixture shape | PASS |
| Unique fixture IDs per file | PASS |
| Non-empty canonical categories | PASS |
| Canonical categories limited to `historic_site`, `monument` | PASS |
| Clean/provenance category agreement | PASS |
| Finite coordinates within legal ranges | PASS |
| No remaining clean `history` / `landmark` category values | PASS |
| 11 `historic_site` records and 2 explicit `monument` records | PASS |
| Unresolved evidence files preserved unchanged | PASS |

## Remaining Repository Check

After placing these files in the current task branch, run the repository's current planner/service test suite against contract snapshot `7f41755a7744721421471c93dff526be5496ff6e` or the approved later baseline. This package validates the JSON artifacts structurally; it does not claim that repository tests were run in this workspace.
