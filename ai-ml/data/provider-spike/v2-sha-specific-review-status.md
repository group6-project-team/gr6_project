# V2 SHA-Specific Semantic Review Status

**Owner:** Asma Yahya Faris Bzoor ? AI/Data & Provider Semantics
**Baseline:** `main@edd5cab05a3c4c66b2cdcb68af9ea5d5fa589750`

## Current status

The evidence work owned by AI/Data is prepared.

Final implementation verdicts remain intentionally pending until the required exact implementation PR heads are available.

## Ahmad ? recommendation reason factor

Status:

`PENDING ? exact factor definition / implementation head required`

Before finalizing positive `INTEREST_MATCH` semantics, review must confirm:

- which planner factor counts as an interest match;
- that candidate/category overlap was actually used by the planner;
- that emitted reason text does not claim an unrequested interest;
- no-interest plans emit no `INTEREST_MATCH`;
- missing/mismatching candidate categories emit no `INTEREST_MATCH`.

No positive reason PASS may be issued from category overlap alone.

## Mohammad ? Backend immutable snapshot

Status:

`PENDING ? exact PR head SHA required`

Review against:

`ai-ml/data/provider-spike/v2-snapshot-semantic-guardrails.md`

Required verdict format:

`PASS @ <exact SHA>`

or

`FAIL @ <exact SHA>`

A FAIL must list exact semantic findings.

No verdict is issued from a branch name, task description, older SHA, or planned implementation.

## Heba ? Flutter semantic rendering

Status:

`PENDING ? exact PR head SHA required`

Flutter semantic review must confirm that the UI:

- displays only truthfully supplied optional address data;
- handles absent address without invented placeholders presented as provider truth;
- does not expose rating, opening hours, or price claims;
- does not expand website/wiki/media into the frozen MVP;
- displays recommendation reasons only when present in the approved Backend contract;
- does not infer `INTEREST_MATCH` from UI-side category inspection;
- does not expose raw provider blobs, provider keys, or debug metadata.

Required verdict format:

`PASS @ <exact SHA>`

or

`FAIL @ <exact SHA>`

## Evidence prepared before dependency reviews

Prepared AI/Data artifacts include:

- bounded provider field prevalence and normalized inventory;
- reproducible evidence analysis script;
- optional `formatted -> address` truth predicate;
- positive and negative sanitized address fixtures;
- explicit rating/opening-hours/price rejection;
- website/wiki/media MVP exclusion;
- public interest to canonical category evidence;
- provider-category mapping and exclusion cases;
- Fatih membership and coordinate negative cases;
- duplicate-like identity limitation;
- immutable snapshot semantic guardrails;
- `INTEREST_MATCH` positive/negative truth matrix.

## Completion rule

This card is not fully DONE until:

1. Ahmad's factor definition is reviewed where required;
2. Mohammad's exact Backend PR head receives a semantic verdict;
3. Heba's exact Flutter PR head receives a semantic verdict.

Until then, dependency status remains `PENDING`, not PASS and not FAIL.
