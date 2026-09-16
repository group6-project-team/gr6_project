# Planner Evaluation Case Table

Owner: Balsam Hashem Ahmad Khaleel
Track: AI / ML
Area: `ai-ml/evaluation`

## Capacity Formula

For `D` requested days and `E` valid unique eligible candidates:

```text
N = min(E, 3D)
q = N // D
r = N % D
```

The expected daily capacities are:

```text
[q+1] for the first r days
[q]   for the remaining D-r days
```

Maximum capacity is 3 places per day.

## Carried-Over Fixture Foundation

| Case            | Fixture                       |  D |  E |  N | Expected capacities   | Warning               |
| --------------- | ----------------------------- | -: | -: | -: | --------------------- | --------------------- |
| Normal          | `normal_D3_E8.json`           |  3 |  8 |  8 | 3 / 3 / 2             | none                  |
| Selection limit | `selection_limit_D3_E10.json` |  3 | 10 |  9 | 3 / 3 / 3             | none                  |
| Partial         | `partial_D3_E2.json`          |  3 |  2 |  2 | 1 / 1 / 0             | `PARTIAL_ITINERARY`   |
| Empty           | `empty_D3_E0.json`            |  3 |  0 |  0 | 0 / 0 / 0             | `NO_PLACES_AVAILABLE` |
| No-interests    | `no_interests_D3_E8.json`     |  3 |  8 |  8 | 3 / 3 / 2             | none                  |
| Invalid         | `INVALID_D3_E5.json`          |  3 |  5 |  5 | intentionally invalid | must be rejected      |

## Additional Independent Evaluation Cases

These cases were executed against the real `planning.plan_trip()` implementation.

| Case         |  D |  E | Expected capacities                                   | Result |
| ------------ | -: | -: | ----------------------------------------------------- | ------ |
| D=4, E=7     |  4 |  7 | 2 / 2 / 2 / 1                                         | PASS   |
| D=4, E=2     |  4 |  2 | 1 / 1 / 0 / 0                                         | PASS   |
| Minimum days |  1 |  8 | 3                                                     | PASS   |
| Maximum days | 14 |  8 | 1 / 1 / 1 / 1 / 1 / 1 / 1 / 1 / 0 / 0 / 0 / 0 / 0 / 0 | PASS   |
| E > 3D       |  3 | 10 | 3 / 3 / 3                                             | PASS   |
| Overlap case |  3 |  5 | 2 / 2 / 1                                             | PASS   |
| Tie case     |  3 |  6 | 2 / 2 / 2                                             | PASS   |

## Input Validation Cases

The real planner was also tested with invalid inputs.

| Case                            | Expected behavior | Result |
| ------------------------------- | ----------------- | ------ |
| `days=0`                        | Reject            | PASS   |
| `days=15`                       | Reject            | PASS   |
| Missing candidate ID            | Reject            | PASS   |
| Invalid `categoryIds`           | Reject            | PASS   |
| Invalid latitude type           | Reject            | PASS   |
| Non-finite longitude            | Reject            | PASS   |
| Destination mismatch            | Reject            | PASS   |
| Duplicate candidate IDs         | Reject            | PASS   |
| Duplicate interests             | Reject            | PASS   |
| Latitude outside `[-90, 90]`    | Reject            | PASS   |
| Longitude outside `[-180, 180]` | Reject            | PASS   |

## Independent Invariants

The evaluator checks the following independently of the planner implementation:

* Exactly `D` days are returned.
* Days are numbered `1..D` exactly once and in order.
* Empty days are retained.
* Total selected places equals `N`.
* No day contains more than 3 places.
* Daily counts follow the `q/r` distribution.
* Selected place IDs are unique.
* Every selected ID belongs to the supplied candidate pool.
* Warning codes match the coverage contract.
* Repeated execution is deterministic for the tested inputs.

## Warning Contract

| Condition   | Required behavior     |
| ----------- | --------------------- |
| `N = 0`     | `NO_PLACES_AVAILABLE` |
| `0 < N < D` | `PARTIAL_ITINERARY`   |
| `N >= D`    | No coverage warning   |

## Negative Control

`INVALID_D3_E5.json` is deliberately malformed.

The independent checker correctly rejects it because its response violates multiple invariants, including:

* Missing a requested day.
* Incorrect total number of selected places.
* Duplicate place ID.
* Unknown place ID.

The negative control passing means **the checker successfully detected the invalid output**.

## Scope Notes

The evaluation verifies the planner contract and independent invariants only.

It does not assert:

* Ahmad's exact ranking order.
* Exact geographic grouping.
* Optimal routes.
* Provider behavior.
* Embedding behavior.
* Model training.
* FastAPI or Flutter behavior.

The carried-over fixture foundation and the new independent real-planner evaluation are intentionally documented separately.

