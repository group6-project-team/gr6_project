# Planner Independent Evaluation

Owner: Balsam Hashem Ahmad Khaleel
Track: AI / ML
Area: `ai-ml/evaluation`

## Purpose

This evaluation independently tests the real `planning.plan_trip()` implementation using contract-valid synthetic inputs and negative controls.

The evaluator verifies the planning contract without reproducing the planner's internal ranking, geographic grouping, or ordering logic.

## Structure

```text
evaluation/
├── fixtures/
│   ├── normal_D3_E8.json
│   ├── selection_limit_D3_E10.json
│   ├── partial_D3_E2.json
│   ├── empty_D3_E0.json
│   ├── no_interests_D3_E8.json
│   └── INVALID_D3_E5.json
├── 01_Planner_Independent_Evaluation.ipynb
├── CASE_TABLE.md
├── README.md
├── validate.py
└── interest_category_mapping.dev.json
```

## Independent Evaluation

The notebook invokes the real `planning.plan_trip()` implementation and independently checks:

* Expected number of selected places:
  `N = min(E, 3D)`
* Daily capacity distribution using:
  `q = N // D`
  `r = N % D`
* Maximum 3 places per day
* Every requested day is present exactly once
* Empty days are retained
* Selected place IDs are unique
* Selected IDs belong to the candidate pool
* Warning behavior
* Deterministic repeated execution

## Covered Cases

### Capacity and Boundary Cases

| Case                       | Expected capacities                                   | Result |
| -------------------------- | ----------------------------------------------------- | ------ |
| Normal: D=3, E=8           | 3 / 3 / 2                                             | PASS   |
| Selection limit: D=3, E=10 | 3 / 3 / 3                                             | PASS   |
| Partial: D=3, E=2          | 1 / 1 / 0                                             | PASS   |
| Empty: D=3, E=0            | 0 / 0 / 0                                             | PASS   |
| D=4, E=7                   | 2 / 2 / 2 / 1                                         | PASS   |
| D=4, E=2                   | 1 / 1 / 0 / 0                                         | PASS   |
| D=1, E=8                   | 3                                                     | PASS   |
| D=14, E=8                  | 1 / 1 / 1 / 1 / 1 / 1 / 1 / 1 / 0 / 0 / 0 / 0 / 0 / 0 | PASS   |
| E > 3D                     | 3 / 3 / 3                                             | PASS   |

## Warning Behavior

The evaluation verifies:

* `N = 0` → `NO_PLACES_AVAILABLE`
* `0 < N < D` → `PARTIAL_ITINERARY`
* `N >= D` → no coverage warning

## Input Validation

Negative controls cover:

* Invalid `days` values outside `1..14`
* Missing or malformed candidate fields
* Invalid category ID structure
* Invalid or non-finite coordinates
* Coordinates outside valid latitude/longitude ranges
* Candidate destination mismatch
* Duplicate candidate IDs
* Duplicate interests

All tested invalid inputs were rejected by the real planner/models.

## Overlap and Tie Cases

Synthetic overlap and tie cases were evaluated without asserting an exact ranking or ordering.

The checks only verify contract-level behavior such as:

* Correct number of selected places
* Valid selected IDs
* No duplicate selections
* Correct daily capacities

Both cases passed.

## Negative Control

`fixtures/INVALID_D3_E5.json` is intentionally invalid.

The independent checker correctly rejects it because the output contains contract violations including:

* Missing requested day
* Incorrect total number of selected places
* Duplicate place ID
* Unknown place ID

The negative control is expected to fail validation and is considered a successful test when rejection occurs.

## Golden Cases

Small reference cases are included for:

* Normal planning
* Partial planning
* Selection-limit behavior

These cases validate justified contract expectations without asserting Ahmad's exact ranking or geographic grouping.

## Results

The completed independent evaluation produced:

```text
Valid fixtures              5/5 PASS
INVALID fixture rejection   PASS
Determinism                 4/4 PASS
Day number validation       5/5 PASS
Golden cases                PASS
No-interests                PASS
D=4, E=7                    PASS
D=4, E=2                    PASS
D=1                         PASS
D=14                        PASS
E > 3D                      PASS
Invalid days                PASS
Malformed candidates        4/4 PASS
Destination mismatch        PASS
Duplicate candidate IDs     PASS
Duplicate interests         PASS
Invalid coordinates         4/4 PASS
Overlap case                PASS
Tie case                    PASS

Overall result: PASS
```

## Running the Evaluation

The main independent evaluation is implemented in:

```text
01_Planner_Independent_Evaluation.ipynb
```

The notebook should be run from a clean checkout after the required planner implementation and fixture foundation are available.

The notebook reports the individual checks and the final:

```text
Overall result: PASS
```

## Scope

This evaluation is limited to planner contract and invariant verification.

It does not evaluate:

* Exact ranking order
* Optimal geographic routes
* Provider API calls
* Embeddings
* Model training
* FastAPI or Flutter behavior
* Production deployment
* Planner algorithm reimplementation

## Fixture Foundation

The fixture set and supporting files were carried over from the earlier planning-fixtures foundation.

The new independent evaluation is kept distinct from the carried-over fixture-response validator.

`validate.py` remains a fixture-level contract checker, while
`01_Planner_Independent_Evaluation.ipynb` invokes and evaluates the real planner independently.
