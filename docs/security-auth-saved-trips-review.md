# Auth + Saved Trips focused security review

**Owner:** Sami Thaalba — Cybersecurity  
**Verdict:** **FAIL — do not merge the candidate into the final release yet. Keep the current released `main` as the submission fallback.**  
**Review date:** 23 September 2026  
**Released main:** `edd5cab05a3c4c66b2cdcb68af9ea5d5fa589750`  
**Backend candidate:** `99316f3bbaeabc1eb0665eded11777351699b5cb` (`feature/user-auth-trip-persistence`)  
**Flutter candidate:** `a4f327712dd2a78a47c03f96e2ab31a688ec2ec5` (`feature/auth-saved-trips-flutter`)  
**Locally combined review SHA:** `aa98c09071bd8fd68b2d8f0143b76216a7198ef5`

The combined SHA is a local review-only merge. It was never pushed or merged. At review time there was no remote branch containing the complete Backend + Flutter candidate, so the final integrated release state still requires integration, QA, security retest, and an exact-SHA decision.

## Scope and method

This was a focused release-candidate review of password handling, authentication bypass, bearer-token handling, saved-trip authorization and ownership, request/storage bounds, secrets, logs, errors, dependencies, and Flutter credential handling. V2/P0 Planning Sessions, Map, Replanning, Pace, and contract work were excluded as directed.

The review combined static inspection with controlled local requests against ASP.NET and SQL LocalDB. Test credentials and tokens were temporary and were not committed or included in evidence. No feature-owner code was changed.

## Findings

| ID | Severity | Finding and evidence | Owner | Required action | Retest |
|---|---|---|---|---|---|
| AUTH-001 | **High — release blocker unless deployment evidence disproves exposure** | A predictable JWT signing value is tracked in `appsettings.Development.json` and accepted directly by the Backend. A token signed with that known value successfully read another user's saved trip. The exploit requires the release to load that Development value or reuse it. | Mohammad | Remove the usable tracked value, inject a unique high-entropy deployment secret, rotate any reused value, and fail startup for missing, placeholder, or weak JWT configuration. Confirm the release runs in `Production`. | Sign with the old tracked value and require `401`; verify a valid release token still works. |
| AUTH-002 | **High — release blocker** | Saved-trip snapshots, string fields, row count, and list response are unbounded. A controlled 256 KiB snapshot returned `201`; snapshots are stored as `nvarchar(max)` and list loads every full snapshot. Public self-registration makes persistent resource abuse reachable. | Mohammad | Add body/snapshot/string/day bounds, a per-user saved-trip cap, and paginated summary listing. Reject invalid or oversized work before persistence with controlled `400/413`. | Oversized requests must create no row; quota and page limits must be deterministic. |
| AUTH-003 | Medium | Failed login attempts use `CheckPasswordAsync` without updating Identity failure state or applying another limit. Controlled failures left `AccessFailedCount` at zero. | Mohammad | Use Identity failed-attempt tracking/lockout or an equivalent bounded login control while retaining generic errors. | Repeated failures must increment protected state or trigger the approved throttle/lockout. |
| AUTH-004 | Medium | Logout returns success but performs no server-side invalidation. The same bearer token remained authorized after logout and can work until its 60-minute expiry. | Mohammad + product decision | Implement revocation/security-stamp validation, or explicitly accept local-only logout, shorten the lifetime appropriately, and make the behavior clear in the UI. | If revocation is chosen, the old token must immediately return `401`; otherwise record the accepted behavior. |
| AUTH-005 | Low | Duplicate registration returns `Email is already registered.`, which reliably reveals account membership. | Mohammad + product/privacy decision | Return an indistinguishable response or explicitly accept account existence as non-private. | Compare existing and new-address registration responses. |
| AUTH-006 | Medium — controlled-error gap | A missing `trip` value reached `GetRawText()` and produced an unhandled `500`. In Development, the exception and stack trace appeared in server diagnostics. | Mohammad | Validate required saved-trip fields and return a controlled `400`; ensure the submitted release does not expose Developer Exception Page responses. | Malformed requests must return sanitized `400` responses without stack traces and without creating rows. |

## Controls that passed

- ASP.NET Identity stored password hashes; no plaintext passwords were found in the database or standard logs.
- Saved Trips requires authorization. Unauthenticated and tampered-token requests returned `401`.
- Repository queries bind both trip ID and user ID. Cross-user read and delete attempts returned `404`.
- Known and unknown login failures returned the same generic message.
- Flutter keeps the bearer token in memory, obscures password inputs, and did not log passwords or tokens in the reviewed code.
- Standard runtime logs used parameter placeholders; no password, bearer token, raw request body, or provider secret was observed.
- The .NET dependency audit reported no known vulnerable direct or transitive packages.
- The repository scan found no confirmed provider credentials or user tokens. The tracked Development JWT value is covered by AUTH-001.

## Validation evidence

Environment: Windows native; .NET SDK 10.0.301; SQL Server LocalDB; local FastAPI on `127.0.0.1:8000`; Backend on `127.0.0.1:5099` in the controlled Development test environment.

- Backend Release build: **passed**, 0 warnings and 0 errors.
- Backend tests with FastAPI available: **57 passed, 0 failed**.
- Focused Auth/Saved Trips checks: registration, generic login failure, authorization, tampered token, cross-user isolation, logout reuse, known-key forgery, oversized snapshot, and malformed snapshot exercised.
- Flutter tests: **not run**. Installed Dart is 3.11.0 while the project requires `^3.12.2`; this is an integration-validation gap.
- No Backend tests specifically covering Auth/Saved Trips were added in the candidate.
- Codex Security diff scan: `1dd3aad6-81b5-4499-9585-27fb3b9bd923`; 54 changed files reviewed; 2 High, 2 Medium, and 1 Low reportable findings.

## Release decision and next actions

The candidate does not meet the team's quick integration + QA + security gate. There are two open High findings, no remote integrated Backend + Flutter branch, and Flutter could not be tested in the available SDK environment. Keep released `main` as the final fallback.

Before reconsidering the feature:

1. Mohammad addresses AUTH-001, AUTH-002, AUTH-003, and AUTH-006, and records the deployment environment/secret source.
2. The team decides and records the expected logout and account-enumeration behavior.
3. Mohammad and Heba publish one integrated candidate SHA and demonstrate the real Backend + Flutter flow.
4. Balsam completes independent smoke testing on that exact SHA.
5. Sami retests every affected finding on the same exact SHA and issues the final PASS/FAIL verdict.

## Submission update

- **Done:** Focused Auth/Saved Trips static and runtime security review; ownership, password storage, token behavior, bounds, logging, error, dependency, and secret checks.
- **Link or evidence:** This report; tested local integration `aa98c09071bd8fd68b2d8f0143b76216a7198ef5`; scan `1dd3aad6-81b5-4499-9585-27fb3b9bd923`.
- **Next:** Feature owners fix the High findings and publish one integrated candidate; QA and security retest that exact SHA.
- **Blocked:** Final security sign-off is blocked by two High findings, missing remote integration, and the Flutter SDK mismatch.
- **Dependency at risk:** Authentication + Saved Trips integration is at risk for today's submission.
- **Is the end-to-end flow at risk? Why?** Yes. Backend and Flutter exist on separate branches, the combined flow is not a published release candidate, and the current candidate has security blockers. The already-released `main` remains the safe fallback.
