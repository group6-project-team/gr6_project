# V2 INTEREST_MATCH Truth Matrix

**Owner:** Asma Yahya Faris Bzoor ? AI/Data & Provider Semantics
**Baseline:** `main@edd5cab05a3c4c66b2cdcb68af9ea5d5fa589750`

## Purpose

This document defines the evidence boundary for a truthful `INTEREST_MATCH` recommendation explanation.

It does not define Ahmad's planner factor mechanics. Final positive reason sign-off remains pending Ahmad's exact factor definition and implementation SHA.

## Canonical interest boundary

Public interests are mapped before planner comparison:

- `history` -> `historic_site`
- `landmark` -> `monument`

The explanation predicate must operate on the canonical requested interests and the candidate's canonical `CategoryIds`.

Raw provider category strings are not valid explanation inputs.

## Minimum truth predicate

`INTEREST_MATCH` may be emitted only when all of the following are true:

1. the request contains at least one approved public interest;
2. that public interest maps to an approved canonical interest;
3. the candidate contains the same canonical category;
4. the planner actually used that interest match as part of the factor that selected/ranked the candidate;
5. the explanation refers only to the supported matched interest/category.

Formally, category overlap is necessary but not sufficient:

`requestedCanonicalInterests ? candidate.CategoryIds != empty`

AND

`plannerFactorUsedInterestMatch == true`

## Negative rules

`INTEREST_MATCH` MUST NOT be emitted when:

- the plan has no requested interests;
- requested interests are empty after canonical mapping;
- candidate `CategoryIds` are missing or empty;
- the requested canonical interest is absent from the candidate;
- the candidate has a category whose corresponding public interest was not requested;
- raw provider categories match textually but no approved canonical category exists;
- the candidate/category overlap exists but the planner did not actually use the interest factor;
- a reason would require inventing a category or interest.

## Truth table

| Requested public interests | Candidate canonical categories | Planner used interest factor | INTEREST_MATCH |
|---|---|---|---|
| none | `historic_site` | no | NO |
| `history` | none | no | NO |
| `history` | `monument` | no | NO |
| `landmark` | `historic_site` | no | NO |
| `history` | `historic_site` | no | NO |
| `history` | `historic_site` | yes | YES, subject to Ahmad factor definition |
| `landmark` | `monument` | yes | YES, subject to Ahmad factor definition |
| `history, landmark` | `historic_site, monument` | yes | YES, exact explanation shape pending Ahmad |
| `history` | `historic_site, monument` | yes | history match only; landmark must not be claimed |
| `landmark` | `historic_site, monument` | yes | landmark match only; history must not be claimed |

## Important distinction

A candidate containing `historic_site` does not by itself prove a recommendation was made because of `history`.

Likewise, a candidate containing `monument` does not by itself prove it was selected because of `landmark`.

Category truth proves eligibility for an interest match.

Planner-factor evidence proves whether that match was actually used.

Both are required for a truthful recommendation reason.

## Current baseline planner evidence

At the recorded baseline, planner ranking computes an interest-match count from the intersection of:

- requested canonical interests
- candidate canonical category IDs

Candidates with more matching categories sort before candidates with fewer matches.

This confirms that category overlap is a real planning input at this baseline.

It does not by itself finalize the V2 explanation reason contract.

## Audit requirement

Final positive reason validation must trace:

1. public request interests;
2. canonical mapped interests;
3. selected candidate ID;
4. candidate canonical categories;
5. actual planner factor/use evidence;
6. emitted reason.

The audit must show that every emitted `INTEREST_MATCH` has both category truth and planner-use truth.

## Pending dependency

Final positive-case reason semantics remain:

`PENDING ? Ahmad factor definition / exact implementation head`

Negative cases above do not depend on that decision and are already fixed:

- no interest => no reason
- missing category => no reason
- interest not requested => no reason
- category mismatch => no reason
- factor not used => no reason

No PASS may be issued solely because a candidate contains a matching category.
