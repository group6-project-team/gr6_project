# Stage 2A Backend–FastAPI security review

**Owner:** Sami Thaalba

**Review date:** 17 September 2026

**Security branch:** `security/stage2a-boundary-review`
**Implementation reviewed and retested:** `71323258799cd15bc4ac77abd7d701158bf6589d` from `feature/backend-stage2a-fastapi-integration` ([PR #13](https://github.com/group6-project-team/gr6_project/pull/13))

## Gate conclusion

**Stage 2A is GREEN for the tested local boundary at the exact SHA above.** The Backend FastAPI client called a real loopback FastAPI service, which called the real deterministic `plan_trip()` implementation. Normal, partial and empty cases returned valid results. Timeout, connection failure, HTTP failure, malformed JSON and semantically invalid success responses have explicit tests and controlled mappings. No automatic retry or fixture fallback was found.

This is a bounded Stage 2A conclusion, not a claim that the deployment is secure. The PR proves the Backend client path directly; it does not add a public ASP.NET endpoint that invokes that path. Three medium configuration/integration findings remain open before dynamic Stage 2B candidates or shared hosting. A malformed-success finding reproduced on the earlier owner SHA was fixed during the review and passed retest.

## Findings log

| ID | Finding, risk and evidence | Severity | Affected component / owner | Suggested action | Status and verification |
|---|---|---|---|---|---|
| 2A-01 | A successful FastAPI response with `days`, `warnings` or `placeIds` null/missing could escape the intended `PLANNING_FAILED` path as an unhandled null error. Reproduced against `bd4bd98a3eb22faffb7617f9c961d99208fa32e4`. | Medium | Backend / Mohammad | Treat required response members as required and reject null/missing members through semantic validation. | **Fixed and retested.** Owner commit `7132325` added required/null checks and four regression cases. All 24 Backend tests, including three real-service tests, passed. |
| 2A-02 | The FastAPI service rejects more than 500 candidates by default, but the Backend client has no equal or smaller outbound bound. A focused probe confirmed it serialized and sent 501 candidates, then mapped FastAPI's 413 to generic `PLANNING_FAILED`. This wastes serialization/network work and can turn future provider volume into avoidable dependency load. | Medium; Stage 2B gate | Backend / Mohammad, limit agreed with AI/ML | Validate candidate count before serialization; share or configure an agreed maximum no larger than FastAPI's. Add at-limit and over-limit tests. | **Open.** Current Stage 2A fixtures contain at most eight candidates, so this does not invalidate the local fixture gate. Must close before dynamic/provider candidate input. |
| 2A-03 | Backend `RequestIdMiddleware` accepts and echoes any nonblank request ID without FastAPI's 1–64 character allowlist. A focused probe confirmed a 4,096-character value was retained and returned. FastAPI replaces that value, so Backend and FastAPI logs can use different IDs; oversized values can also inflate headers/logs. | Medium | Backend / Mohammad | Apply the same 1–64 `[A-Za-z0-9._:-]` policy at the first Backend boundary; generate a new ID when invalid and propagate only the normalized value. Add invalid/oversized tests. | **Open.** Valid IDs propagate correctly. Close before relying on correlation in shared logs. |
| 2A-04 | The configured 10-second timeout is active in Development and timeout behavior is tested, but configuration accepts arbitrary integers. `-1` disables `HttpClient` timeout, and missing/invalid production base URL or nonpositive timeout is not validated at startup. A bad deployment can therefore remove the bound or fail only when the client is resolved. | Medium; hosting/config gate | Backend / Mohammad, deployment owner | Validate base URL and a positive bounded timeout at startup; keep production URL in server configuration/secret management. Prefer an internal HTTPS/private service address in hosted environments. | **Open for hosting.** The reviewed local environment used `http://127.0.0.1:8000/` and 10 seconds. |

No High/Critical finding or known secret exposure was identified. The open Medium findings are explicit and assigned; none is silently accepted.

## Targeted checks and results

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

1. Keep fixtures visibly test-only and require real mode explicitly. Production/runtime configuration must never select a fixture implementation.
2. Stop FastAPI or return 503/timeout/invalid JSON/invalid semantics. Assert one outbound attempt, controlled public failure and no successful itinerary.
3. At the agreed candidate maximum, expect a real plan. At maximum + 1, require Backend rejection before the request is sent.
4. Send unknown/duplicate place IDs, wrong day sequence/count/capacities, extra warnings and null/missing fields. Backend must reject every invalid success response.
5. Trace valid and malformed inbound request IDs through Backend and FastAPI. The same normalized ID must appear on both sides.
6. Run normal, partial and empty cases using explicit Stage 2B fixtures and the real planner. Record SHA, configuration and whether provider/network data is real or fixture data.
7. Simulate dependency failure and assert it cannot silently become fixture success. Keep the service unavailable until the owner deliberately restores it; do not add retries or fallback to make the test pass.

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

**Done:** Reviewed the new Backend–FastAPI implementation, ran the real planner path and defensive-failure suites, checked exposure/configuration/logging/secrets/dependencies, reproduced two boundary gaps, and retested the malformed-response owner fix that landed during review.

**Link or evidence:** `docs/security-stage2a-review.md`; `docs/evidence/stage2a/retest-results.md`; tested owner SHA `71323258799cd15bc4ac77abd7d701158bf6589d`; PR #13.

**Next:** Backend owner closes 2A-02 and 2A-03 before dynamic Stage 2B candidates and validates production configuration for 2A-04. Run the prepared no-fallback/fixture-separation checks on the final Stage 2B SHA.

**Blocked:** No blocker for the tested local Stage 2A client-to-real-planner gate. External exposure protection cannot be tested until a hosting target exists. No public ASP.NET route invokes this client in the reviewed PR, so application-level HTTP end-to-end invocation is outside the current proof.

**Dependency at risk:** Agreed shared candidate maximum, production FastAPI URL/timeout validation, normalized correlation-ID policy and final hosting protection.

**Is the end-to-end flow at risk? Why?** The local Stage 2A Backend-client → FastAPI → real-planner flow works. The future dynamic/hosted flow remains at risk if unbounded candidate lists are sent, request IDs diverge, or timeout/base-URL configuration is invalid. Those risks are recorded with owners and verification steps.
