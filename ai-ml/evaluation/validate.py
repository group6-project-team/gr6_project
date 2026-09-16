#!/usr/bin/env python3
"""
validate.py — Contract/invariant checker for Team 6 planning fixtures.

Implements the checks from Team6_Trip_Planning_AI_ML_Track_Specification_v2:
  E = len(candidatePlaces)
  N = min(E, 3 * D)
  q = N // D ; r = N % D
  capacity(day 1..r)        = q + 1
  capacity(remaining days)  = q
  N == 0        -> warnings must include NO_PLACES_AVAILABLE
  0 < N < D     -> warnings must include PARTIAL_ITINERARY
  N >= D        -> no coverage-related warning required

Also checks:
  - every day 1..D is present, in order, exactly once
  - returned placeIds all come from candidatePlaces ids (no unknown ids)
  - no placeId repeats anywhere in the whole response
  - no day has more than 3 places
  - total placed places == N
  - per-day place counts match the expected capacity split

Usage:
    python3 validate.py fixtures/*.json
    python3 validate.py                      # validates every *.json under fixtures/

One fixture (INVALID_*.json) is EXPECTED to fail. The script distinguishes
expected-invalid fixtures (filename starts with "INVALID") from the rest and
reports overall PASS only if:
  - every normal fixture has zero violations, AND
  - every fixture named INVALID_* has at least one violation.
"""

import json
import sys
import glob
import os

COVERAGE_WARNINGS = {"NO_PLACES_AVAILABLE", "PARTIAL_ITINERARY"}


def expected_capacities(d, n):
    """Return list of expected per-day capacities, length d, per spec formula."""
    q, r = divmod(n, d)
    return [q + 1 if i < r else q for i in range(d)]


def validate_fixture(fixture):
    violations = []

    request = fixture.get("request", {})
    response = fixture.get("response", {})

    d = request.get("days")
    candidates = request.get("candidatePlaces", [])
    e = len(candidates)
    n = min(e, 3 * d) if isinstance(d, int) and d > 0 else None

    if not isinstance(d, int) or d < 1 or d > 14:
        violations.append(f"request.days must be an integer 1..14, got {d!r}")
        return violations  # can't continue meaningfully

    valid_ids = {c.get("id") for c in candidates}
    if len(valid_ids) != len(candidates):
        violations.append("candidatePlaces contains duplicate ids in the input itself")

    days_resp = response.get("days", [])

    # 1. every day 1..D present, in order, exactly once
    expected_day_numbers = list(range(1, d + 1))
    actual_day_numbers = [entry.get("day") for entry in days_resp]
    if actual_day_numbers != expected_day_numbers:
        violations.append(
            f"response.days must contain days {expected_day_numbers} in order, "
            f"got {actual_day_numbers}"
        )

    # Collect all placeIds and per-day counts (best-effort even if day numbers are wrong)
    all_placed = []
    per_day_counts = []
    for entry in days_resp:
        ids = entry.get("placeIds", [])
        per_day_counts.append(len(ids))
        all_placed.extend(ids)

        if len(ids) > 3:
            violations.append(f"day {entry.get('day')} has {len(ids)} places, max is 3")

        for pid in ids:
            if pid not in valid_ids:
                violations.append(
                    f"day {entry.get('day')} references unknown placeId '{pid}' "
                    "not present in candidatePlaces"
                )

    # 2. no placeId repeats anywhere in the response
    seen = set()
    for pid in all_placed:
        if pid in seen:
            violations.append(f"placeId '{pid}' is duplicated across the response")
        seen.add(pid)

    # 3. total placed == N
    if len(all_placed) != n:
        violations.append(
            f"total placed places = {len(all_placed)}, expected N = min(E={e}, 3*D={3*d}) = {n}"
        )

    # 4. per-day capacities match q/r split (only meaningful if day count matches D)
    if len(per_day_counts) == d:
        expected = expected_capacities(d, n)
        if per_day_counts != expected:
            violations.append(
                f"per-day place counts {per_day_counts} do not match expected "
                f"capacities {expected} (q={n // d}, r={n % d})"
            )

    # 5. warnings
    warnings = set(response.get("warnings", []))
    coverage_present = warnings & COVERAGE_WARNINGS
    if n == 0:
        if "NO_PLACES_AVAILABLE" not in warnings:
            violations.append("N=0 requires warning NO_PLACES_AVAILABLE")
    elif 0 < n < d:
        if "PARTIAL_ITINERARY" not in warnings:
            violations.append("0<N<D requires warning PARTIAL_ITINERARY")
    else:  # n >= d
        if coverage_present:
            violations.append(
                f"N>=D requires no coverage-related warning, found {coverage_present}"
            )

    return violations


def main(paths):
    if not paths:
        paths = sorted(glob.glob(os.path.join(os.path.dirname(__file__), "fixtures", "*.json")))

    overall_ok = True
    print(f"{'CASE':30} {'RESULT':10} DETAILS")
    print("-" * 90)

    for path in paths:
        name = os.path.basename(path)
        with open(path, "r", encoding="utf-8") as f:
            fixture = json.load(f)

        violations = validate_fixture(fixture)
        is_marked_invalid = name.upper().startswith("INVALID")

        if is_marked_invalid:
            # This fixture MUST fail. Success = violations were found.
            if violations:
                print(f"{name:30} {'OK':10} correctly rejected ({len(violations)} violation(s))")
            else:
                print(f"{name:30} {'FAIL':10} expected this fixture to be rejected, but it passed!")
                overall_ok = False
        else:
            if not violations:
                print(f"{name:30} {'PASS':10} all invariants satisfied")
            else:
                print(f"{name:30} {'FAIL':10} {violations[0]}")
                for extra in violations[1:]:
                    print(f"{'':30} {'':10} - {extra}")
                overall_ok = False

    print("-" * 90)
    print("OVERALL:", "PASS" if overall_ok else "FAIL")
    sys.exit(0 if overall_ok else 1)


if __name__ == "__main__":
    main(sys.argv[1:])
