# Stage 2B security closeout and early Stage 3 review

**Owner:** Sami Thaalba  
**Review date:** 20 September 2026  
**Reviewed main SHA:** `c54fd9daf2d4d66d27687c038047eb72336db236`

## Scope and conclusion

PR #14's corrections are already merged: its head `fca363da1cab7546d5a78f4eb923a80b777a37aa` is reachable from the reviewed main. The corrected Stage 2A record identifies the public path as `POST /trip-plans/preview → Backend → real FastAPI /plan → real planner`, the verified candidate pool as **9**, and an explicit fixture source as permitted only when deliberately selected.

This review exercised the current public route with the Backend and FastAPI services running locally. The Stage 2B explicit-fixture boundary is **security-reviewed at this SHA**: no new Blocker or Critical finding was identified, and dependency failure did not produce a fixture or mock success. This is evidence for the security boundary, not a claim that the whole product is secure or that a provider integration is ready.

## Targeted evidence

Environment: Backend in Development at `http://127.0.0.1:5185`; FastAPI at `http://127.0.0.1:8000`; .NET SDK 10.0.301; Python 3.14.3.

| Check | Result |
|---|---|
| Istanbul, 3 days, history + landmark | `200`; 3 itinerary days, 9 places, no warnings; request ID echoed. |
| Rome, 3 days, history | `200`; 3 itinerary days, 2 places, `PARTIAL_ITINERARY`. |
| Aqaba, 3 days, history | `200`; 3 itinerary days, 0 places, `NO_PLACES_AVAILABLE`. |
| Stop FastAPI, repeat public request | `503 PLANNING_SERVICE_UNAVAILABLE`; generic public message; no itinerary, fixture or mock success. |
| Candidate-source configuration | `Fixture` is selected explicitly. Missing or unsupported mode stops Backend startup; no default/fallback registration exists. |
| Automated checks | `dotnet test Backend/TripPlanning.Api.Tests/TripPlanning.Api.Tests.csproj --no-restore`: 35 passed. `python -m pytest ai-ml/service/tests ai-ml/planning/tests -q`: 117 passed, 5 deprecation warnings. |

The reviewed public path uses `FixtureCandidateSource` only because development configuration explicitly selects `CandidateSource:Mode: Fixture`. Its maximum Istanbul fixture pool is 9 candidates. The FastAPI service independently defaults to 500 candidates. A future dynamic/provider source must enforce an agreed Backend outbound maximum no greater than FastAPI's limit before serialization.

## Findings and carried actions

| ID | Boundary / risk | Priority | Owner | Suggested action | Evidence and verification | Status |
|---|---|---|---|---|---|---|
| 2B-01 (carried 2A-02) | Backend → FastAPI: Backend has no shared outbound candidate cap before serialization. A future provider source could send excessive candidate data and waste dependency capacity. | Medium | Backend / Mohammad; limit agreed with AI/ML | Validate an agreed candidate maximum in Backend before the HTTP call; add at-limit and over-limit tests. | Current fixture path is bounded at 9; FastAPI default is 500. Test a real provider source at max and max + 1 when implemented. | Open; not a blocker for explicit fixtures. |
| 2B-02 (carried 2A-03) | Client → Backend → FastAPI: Backend accepts arbitrary nonblank request IDs, while FastAPI limits/normalizes them. Oversized or invalid values can make logs diverge and enlarge headers/logs. | Medium | Backend / Mohammad | Apply FastAPI's 1–64 `[A-Za-z0-9._:-]` policy at the first Backend boundary; generate a fresh ID if invalid. | Valid IDs propagated in local public-route requests. Retest invalid and oversized headers after the owner fix. | Open. |
| 2B-03 (carried 2A-04) | Backend → FastAPI / hosting: development uses a safe loopback URL and 10-second timeout, but startup does not enforce a positive bounded timeout or valid production base URL. | Medium | Backend / Mohammad and deployment owner | Validate URL scheme/host and a positive bounded timeout at startup; keep hosted configuration in server-side secret/config management. | Local test used `http://127.0.0.1:8000/` and 10 seconds. Verify the eventual deployment settings before release. | Open; hosting gate. |
| 2B-04 | Backend logging: the public FastAPI-unavailable response is controlled, but Development console diagnostics include exception details, local URL and source path. | Low | Backend / deployment owner | Restrict production log access/retention and use production-safe log levels/templates; keep diagnostics out of public responses. | Observed during the deliberate downstream connection failure. Confirm production logging configuration before deployment. | Open; no public leakage observed. |

No High/Critical finding is known or ignored. The existing Medium findings remain explicit, assigned and testable.

## Stage 2B fixture and fallback result

`ICandidateSource` is registered only after an explicit `CANDIDATE_SOURCE_MODE` / `CandidateSource:Mode` choice. `Fixture` deliberately selects `FixtureCandidateSource`; another or absent value throws during startup. `RealTripPreviewService` obtains candidates only through that injected source and then calls FastAPI. When FastAPI was unavailable, the public route returned the controlled `503` result; it did not return an itinerary from the fixture source. No automatic retry policy was registered.

This means an explicit fixture is allowed for local/dev/test use with the real planner. It must remain visibly selected, and it must never become a hidden substitute for a failed dependency or silently serve production provider traffic.

## Early Stage 3 provider review

There is **no live Places Provider runtime client, provider key configuration, provider HTTP call, or hosting deployment configuration** at this SHA. The `ai-ml/data/provider-spike` files are offline research scripts and saved evidence, not runtime integration. They obtain a key interactively with `getpass`, redact it before saving output, and use `YOUR_API_KEY` placeholders in committed examples.

Therefore, these Stage 3 checks are deferred until real code/config exists: server-side provider-key custody, allowed host/config restrictions, provider request/result bounds and timeout, dependency failure behavior, and no secret or raw sensitive URL in logs/responses. An externally reachable FastAPI service is also pending the hosting decision; encryption and service-to-service protection can only be verified after that design exists.

## Repository hygiene and limits

A history-aware secret-pattern scan covered 411 unique blobs on fetched refs. It flagged interactive `api_key = getpass(...)` assignments and placeholders, but no literal provider credential, private key or common token was found. No tracked `.env` file was found. This does not verify external GitHub secrets or deployed environment variables.

Mobile source review found that production API construction uses `BackendTripApi`; test mocks are test support and are not a runtime fallback. Flutter automated tests were not runnable here because installed Dart 3.11.0 does not meet the project's `^3.12.2` SDK requirement. Retest the mobile suite in a matching SDK environment before declaring mobile integration verified.

## Card checklist status

Mark these **done**:

- Fix PR #14 on its branch/PR; correct the public planning-path description, candidate-count evidence and explicit-fixture wording; its correction head is merged.
- Pull and review the latest main after that merge.
- Review Stage 2B fixture-source separation and verify no hidden fallback.
- Review timeout, bounds, request IDs, logging and error behavior where implemented.
- Record tested SHA/environment and findings.

Leave this **pending**:

- Stage 3 provider-key/configuration, provider timeout/bounds and provider failure review: no runtime provider implementation exists.
- External FastAPI encryption/protected exposure: no externally reachable deployment exists.
- Retest owner fixes for 2B-01 through 2B-04 after they land.

## End-of-day update

**Done:** Fetched and reviewed main `c54fd9d`. Confirmed PR #14 correction head `fca363d` is merged. Ran the public Backend → real FastAPI route for normal, partial, empty and dependency-unavailable cases. Explicit fixtures require configuration and FastAPI failure returned a controlled 503 without fixture/mock success. Completed the Stage 2B security review; no Blocker/Critical is known.

**Link or evidence:** `docs/security-stage2b-closeout.md`; tested SHA `c54fd9daf2d4d66d27687c038047eb72336db236`; 35 Backend tests passed; 117 Python tests passed; local request results recorded above.

**Next:** Retest the assigned Backend/config fixes for 2B-01 through 2B-04 at their merged SHA. Start the provider review once a real runtime provider client/configuration lands.

**Blocked:** Stage 3 provider and hosting checks are waiting for implementation and an exposure decision. Flutter automated testing waits for Dart 3.12.2 or later.

**Dependency at risk:** Shared candidate maximum, Backend request-ID normalization, production FastAPI URL/timeout validation, production logging controls, and the later provider/hosting design.

**Is the end-to-end flow at risk? Why?** The reviewed local explicit-fixture path works with controlled downstream failure and has no known Blocker/Critical. A future dynamic/provider or hosted flow remains at risk until the Medium candidate bound, correlation and configuration findings are fixed and the Stage 3 provider/hosting controls are implemented and tested.
