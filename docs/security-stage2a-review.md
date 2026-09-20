# Stage 2A Backend–FastAPI security review

**Owner:** Sami Thaalba

**Review date:** 17 September 2026

**Security branch:** `security/stage2a-boundary-review`
**Historical implementation reviewed and retested (17 September):** `71323258799cd15bc4ac77abd7d701158bf6589d` from `feature/backend-stage2a-fastapi-integration` ([PR #13](https://github.com/group6-project-team/gr6_project/pull/13))

**Summary correction:** 20 September 2026. Post-merge Stage 2A gate baseline: main `dd72cc1313387908c51b497ee97b8167650e429a` (not a claim that this remains the latest main).

## Gate conclusion

**Stage 2A GREEN is closed on main `dd72cc1313387908c51b497ee97b8167650e429a`, with no current security Blocker/Critical identified for that gate.** The current public planning path at this baseline is `POST /trip-plans/preview → Backend → real FastAPI /plan → real planner`. The verified Stage 2A candidate pool reaches **9 candidates**. This post-merge status is recorded from [Ahmad's review of PR #14](https://github.com/group6-project-team/gr6_project/pull/14#pullrequestreview-5241477565) and his card update; the route and pool are corroborated by the source at `dd72cc1` following `b75b806`.

The `7132325` results below remain dated historical client-to-real-planner evidence: normal, partial and empty cases passed, defensive failures had controlled mappings, and no automatic retry or fixture fallback was found. Those 24 Backend tests are not presented as final post-merge public-route gate proof. This documentation correction performs no new runtime testing. Three Medium Backend/config findings remain assigned for later Stage 2B/hosting work and do not reopen verified local Stage 2A. A malformed-success finding on the earlier owner SHA was fixed and retested. Hosting/external protection remains **N/A / pending target**, not tested; this is not a full security assessment and adds no Auth/JWT/CORS scope.

## Findings log

| ID | Finding, risk and evidence | Severity | Affected component / owner | Suggested action | Status and verification |
|---|---|---|---|---|---|
| 2A-01 | A successful FastAPI response with `days`, `warnings` or `placeIds` null/missing could escape the intended `PLANNING_FAILED` path as an unhandled null error. Reproduced against `bd4bd98a3eb22faffb7617f9c961d99208fa32e4`. | Medium | Backend / Mohammad | Treat required response members as required and reject null/missing members through semantic validation. | **Fixed and retested.** Owner commit `7132325` added required/null checks and four regression cases. All 24 Backend tests, including three real-service tests, passed. |
| 2A-02 | The FastAPI service rejects more than 500 candidates by default, but the Backend client has no equal or smaller outbound bound. A focused probe confirmed it serialized and sent 501 candidates, then mapped FastAPI's 413 to generic `PLANNING_FAILED`. This wastes serialization/network work and can turn future provider volume into avoidable dependency load. | Medium; Stage 2B gate | Backend / Mohammad, limit agreed with AI/ML | Validate candidate count before serialization; share or configure an agreed maximum no larger than FastAPI's. Add at-limit and over-limit tests. | **Open.** The verified Stage 2A pool at main `dd72cc1` reaches 9 candidates, so this does not invalidate the local Stage 2A gate. Must close before dynamic/provider candidate input. |
| 2A-03 | Backend `RequestIdMiddleware` accepts and echoes any nonblank request ID without FastAPI's 1–64 character allowlist. A focused probe confirmed a 4,096-character value was retained and returned. FastAPI replaces that value, so Backend and FastAPI logs can use different IDs; oversized values can also inflate headers/logs. | Medium | Backend / Mohammad | Apply the same 1–64 `[A-Za-z0-9._:-]` policy at the first Backend boundary; generate a new ID when invalid and propagate only the normalized value. Add invalid/oversized tests. | **Open.** Valid IDs propagate correctly. Close before relying on correlation in shared logs. |
| 2A-04 | The configured 10-second timeout is active in Development and timeout behavior is tested, but configuration accepts arbitrary integers. `-1` disables `HttpClient` timeout, and missing/invalid production base URL or nonpositive timeout is not validated at startup. A bad deployment can therefore remove the bound or fail only when the client is resolved. | Medium; hosting/config gate | Backend / Mohammad, deployment owner | Validate base URL and a positive bounded timeout at startup; keep production URL in server configuration/secret management. Prefer an internal HTTPS/private service address in hosted environments. | **Open for hosting.** The reviewed local environment used `http://127.0.0.1:8000/` and 10 seconds. |

No High/Critical finding or known secret exposure was identified. The open Medium findings are explicit and assigned; none is silently accepted.

## Historical targeted checks and results (`7132325`, 17 September)

- **Real path:** three .NET integration tests called `FastApiPlanningClient` → loopback FastAPI `/plan` → real `plan_trip()`. Normal, partial and empty results passed at `7132325`.
- **Defensive failures:** Backend tests cover timeout, connection failure, 503, other HTTP error, malformed JSON, unknown IDs, invalid result structure, and middleware mappings to controlled 503/500 bodies. The fixed null/missing response cases passed.
- **Input validation and bounds:** FastAPI uses strict Pydantic models, forbids extra fields, validates days/coordinates/string/list shapes, and rejects over-limit candidate lists before planning. Backend semantic validation checks day preservation, exact selection count, fixed distribution, known/unique IDs, max three per day and warning codes. Finding 2A-02 records the missing Backend outbound guard.
- **Retries and fallback:** no retry policy is registered and each client call makes one HTTP attempt. Unavailable/error responses throw controlled exceptions; no fixture response is substituted. Stage 2A fixtures live explicitly under the test project.
- **Correlation:** valid IDs propagate. FastAPI sanitizes malformed IDs and logs concise outcome counts without payloads. Finding 2A-03 records the Backend mismatch.
- **Errors and logs:** FastAPI returns generic 413/422/500 envelopes and does not log candidate payloads, secrets or exception traces. Backend public mappings are generic. Backend internal warning/error logs include exception diagnostics for timeout, connection and JSON failures; protect production log access and retention. No payload logging was found.
- **Exposure:** documented development commands bind FastAPI to `127.0.0.1`; Backend development configuration also targets loopback. No public FastAPI deployment configuration was found. If it becomes externally reachable, HTTPS and appropriate platform/service-to-service protection remain a hosting gate; no JWT work is required by this review.
- **Schema:** current camel-case request/response fields match the FastAPI OpenAPI contract and passed real-service tests. No explicit schema-version negotiation exists; coordinate breaking changes jointly before Stage 2B.
- **Secrets and repository hygiene:** a history-aware pattern scan covered 290 unique blobs on fetched refs. Two matches were documented placeholders; no real credential, private key or common token was identified. No tracked `.env` file was found. Deployed environment variables and GitHub secrets were unavailable and are not claimed verified.
- **Dependencies:** NuGet's advisory check reported no vulnerable direct/transitive package for the Backend test project. `pip-audit` reported no known vulnerability for `fastapi==0.141.1`, `uvicorn==0.53.0`, `httpx==0.28.1` and `pytest==9.1.1` plus resolved dependencies. These are dated database results, not a security guarantee. The inherited unsupported `FluentValidation.AspNetCore` maintenance issue remains recorded in the Stage 1 review.

Detailed commands, environment and counts are in [the Stage 2A evidence record](evidence/stage2a/retest-results.md).

## Stage 2B checks prepared

**Stage 2B is active.** These are prepared checks, not completed Stage 2B verification. Production Geoapify remains pending **Stage 2B GREEN and Asma handoff readiness**.

1. An explicitly selected fixture candidate source (`FixtureCandidateSource`) is allowed and required for dev/test/integration, including intentional local runtime use with the real planner. Record the selected source/configuration. Prohibit hidden fallback from a failed dependency/provider path to fixture success and silently using fixtures as production behavior; production provider mode must not silently select fixture data.
2. Stop FastAPI or return 503/timeout/invalid JSON/invalid semantics. Assert one outbound attempt, controlled public failure and no successful itinerary.
3. At the agreed candidate maximum, expect a real plan. At maximum + 1, require Backend rejection before the request is sent.
4. Send unknown/duplicate place IDs, wrong day sequence/count/capacities, extra warnings and null/missing fields. Backend must reject every invalid success response.
5. Trace valid and malformed inbound request IDs through Backend and FastAPI. The same normalized ID must appear in responses and logs on both sides. Check safe public errors and logs for leaked payloads, secrets, stack traces or internal dependency details; keep credentials server-side and check repository secret hygiene.
6. Run normal, partial and empty cases using explicit Stage 2B fixtures and the real planner. Record SHA, configuration and whether provider/network data is real or fixture data.
7. Simulate FastAPI and provider/dependency failures and assert they cannot silently become fixture success. Keep the failed dependency unavailable until the owner deliberately restores it; do not add retries or fallback to make the test pass. Record explicit fixture separation, candidate/payload bounds, safe errors, normalized correlation/logging and secrets checks at the final Stage 2B SHA before declaring Stage 2B GREEN.

## Card checklist status

You can check these as **done**:

- Review FastAPI exposure.
- Prefer internal/private exposure (the current reviewed setup is loopback; hosted exposure remains a gate).
- Review Backend → FastAPI candidate/payload bounds.
- Review timeout configuration.
- Review request/correlation ID behavior.
- Review schema compatibility.
- Verify no automatic retry.
- Review validation in both directions.
- Review Backend semantic validation of FastAPI output.
- Review logs for stack traces/internal details/secrets/full-payload leakage.
- Check `.env`/repository secret hygiene.
- Review relevant dependency/config risks.
- Review FastAPI error behavior.
- Prepare Stage 2B checks for explicit fixture separation.
- Prepare check that dependency failure cannot silently become fixture success.
- For each meaningful finding record evidence, severity, affected component, owner and status.
- Retest material fixes that landed today.

For **“If externally reachable, check appropriate encryption/protected exposure”**, record **Not applicable to the reviewed local setup / pending hosting decision**. Leave it unchecked if the card cannot represent N/A; check it only after a real externally reachable deployment is available and verified.

## End-of-day update

**Done:** Historical 17 September review and retest at `7132325` retained. Current summary corrected to the reported post-merge Stage 2A GREEN on main `dd72cc1313387908c51b497ee97b8167650e429a`: `POST /trip-plans/preview → Backend → real FastAPI /plan → real planner`, reaching 9 candidates, with no current security Blocker/Critical identified for that gate. This update is documentation/security evidence only.

**Link or evidence:** `docs/security-stage2a-review.md`; `docs/evidence/stage2a/retest-results.md`; tested owner SHA `71323258799cd15bc4ac77abd7d701158bf6589d`; PR #13.

**Next:** Stage 2B is active. Backend/config owners retain Medium 2A-02/03/04 and their later boundary/hosting verification actions. Run prepared safe-error, normalized correlation/logging, bounds, secrets and explicit-fixture/no-silent-fallback checks on the final Stage 2B SHA. Production Geoapify waits for Stage 2B GREEN and Asma handoff readiness; no Auth/JWT/CORS expansion.

**Blocked:** No current security Blocker/Critical identified for the closed local Stage 2A gate at `dd72cc1`. The public route now invokes the real planner path; the earlier client-only limitation applies only to historical `7132325` evidence. Hosting/external protection is N/A / pending target and has not been tested.

**Dependency at risk:** Agreed shared candidate maximum, production FastAPI URL/timeout validation, normalized correlation-ID policy and final hosting protection.

**Is the end-to-end flow at risk? Why?** The public Stage 2A preview → Backend → real FastAPI → real-planner gate is GREEN at `dd72cc1`. The future dynamic/hosted flow remains at risk if unbounded candidate lists are sent, request IDs diverge, or timeout/base-URL configuration is invalid. Those Medium risks remain recorded with Backend/config owners and verification steps; they do not reopen local Stage 2A.
