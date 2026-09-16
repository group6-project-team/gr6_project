# Stage 1 security review — Iteration 2

Owner: Sami Thaalba. Review date: 16 September 2026. Branch: `security/stage1-api-review`.

## Baseline and conclusion

Reviewed and locally tested merged main **583c3432849995eb82e81974ab0542bf98ecafde**. Separately reviewed pending Flutter changes **21e8cdd** on `feature/flutter-backend-integration`; these were not merged into the tested backend checkout. Builds used .NET SDK 10.0.301 on Windows. Standalone parser checks used Dart 3.11.0; this does not satisfy mobile's declared Dart ^3.12.2 requirement and is not a full Flutter test run.

**Readiness: not yet verified for Stage 1 exit.** Backend validation and normal/partial/empty responses have bounded local HTTP evidence. Main still contains the original Flutter route/DTO mismatch. The pending Flutter fix addresses those differences but has a reproducible permissive-parser issue. Final integrated device/network retest is still required. No owner component was rewritten, no penetration test or public target probing was performed.

This continues [the initial review](security-initial-review.md), merged through [PR #6](https://github.com/group6-project-team/gr6_project/pull/6). Its “local/not pushed” end-of-day paragraph is historical and now stale. FastAPI and Data changes have since merged; their existence does not make them Stage 1 prerequisites.

## Evidence and results

- [HTTP harness](evidence/stage1/http_review.py), [24 recorded HTTP cases](evidence/stage1/http-results.json), and [generated Swagger](evidence/stage1/openapi.json). Twenty cases had defined expected status codes and all matched. Four cases characterize policy without inventing an expected rejection.
- Normal Istanbul, partial Rome, empty Aqaba and 14-day requests: 200; requested-day count and max three places/day checks passed. Invalid/null destinations, missing/null/out-of-range/fractional/boolean days, unsupported/wrong-type interests, malformed JSON and null body: 400. Optional interests missing/null/[]: 200.
- Duplicate interests, unknown fields, Budget extra field and string `days:"3"`: 200. These are observed coercion/ignore behaviors, not automatically vulnerabilities. Owners must agree/document the intended policy. No arbitrary payload limit was invented or stress-tested.
- Old `/trips/plan` route: 404. Pending Flutter uses `/trip-plans/preview`, port 5185, structured warnings and request-derived requestedDays. Its options come from an explicit local Stage 1 catalog instead of calling a missing options endpoint. Owner agreement on this catalog remains necessary.
- [Standalone parser output](evidence/stage1/parser-results.txt): missing `days` and `days:["bad"]` both produce a successful model with zero days despite requestedDays=3; dayNumber 1.5 becomes 1. Source: pending `mobile/lib/models/trip_plan.dart`, `TripPlan.fromJson`, `DayPlan.fromJson`, `_requiredInt`.
- Captured HTTP errors contained validation/model-binding descriptions and request trace IDs, not observed stack traces or credentials. This does not verify unexpected exceptions or production configuration. No synthetic `SYNTHETIC_REVIEW_MARKER` from the supplied Authorization header/extra JSON field appeared in the captured console log. No actual secrets were used.

## Findings register

| ID / prior item | Finding and severity rationale | Evidence / affected component | Recommended fix / owner | Status / retest |
|---|---|---|---|---|
| I2-01 / S1 | High integration blocker, not an exploit: merged Flutter routes/DTOs differ from Backend. | Main client paths/models; old path returns 404. Pending 21e8cdd changes inspected. | Mohammad (Backend) + Heba (Flutter): agree catalog/contract and integrate fixes. | Open on main; pending source fix reviewed, final E2E not tested. |
| I2-02 / new | Medium integrity/reliability: malformed successful responses can become incomplete itineraries instead of controlled failures. | Pending Flutter parser: defaults missing days to [], filters non-map entries, truncates fractional day numbers; standalone reproduction output linked above. | Heba: reject malformed required arrays/elements/integer days and validate requested-day preservation; add regression cases. | Open; reproduced in isolated parser. Full supported-SDK Flutter retest required. |
| I2-03 / S2 | Medium policy gap: request count/byte/string bounds and duplicate/unknown/Budget/coercion rules are not agreed explicitly. No large-input exploit claimed. | Backend validator and request DTO; HTTP characterization cases return 200. | Mohammad with Ahmad: document intended policies and reasonable agreed limits; test boundaries after agreement. | Open decision; basic invalid-input rejection verified only for recorded cases. |
| I2-04 / S3 | Medium assurance gap: central unexpected-error mapping is absent; observed validation errors are controlled but generic exception behavior remains untested. | Program.cs; Swagger and HTTP errors; Flutter userMessage maps codes to fixed user-facing text. | Mohammad: ensure safe shared-environment exception responses; Heba tests malformed error bodies and offline behavior. | Open; no actual secret/stack-trace leak observed in successful test run. |
| I2-05 / S4 | Low for current Stage 1, future normal-runtime gate: fake backend is unconditional, but fake responses are intentional at this stage. | Program.cs fake service registration; mobile mock mode explicit; pending branch defaults real client. | Mohammad/Heba: keep Stage 1/demo designation explicit; no silent fake success on network failure. | Intentional Stage 1 behavior; source shows no automatic mock fallback. Device failure-path retest not tested. |
| I2-06 / S5 | Medium preventive hygiene gap: pattern checks are limited; Python ignores added, but root secret exclusions/automated scanning are not established. | 232 unique historical blobs across fetched refs scanned for credential assignments, private-key headers and common token formats: two placeholder matches, no real secret identified. Config/fixtures/Flutter source inspected. | All owners: keep credentials server-side and add scoped secret hygiene; rotate/revoke and notify Ahmad if real exposure is found. | No observed exposure; preventive work remains. Not a comprehensive secret audit. |
| I2-07 / D1 | Medium maintenance risk: FluentValidation.AspNetCore is unsupported; an empty advisory result does not establish security. | Resolved backend packages and mobile lockfile, audit below. | Mohammad evaluates supported validation path; each owner reviews dependency changes. | Open maintenance finding; no advisory returned for queried versions. |

## Dependencies, configuration and network scope

[OSV audit evidence](evidence/stage1/dependency-audit.json): queried **38 exact versions** on 16 September 2026: 10 resolved direct/transitive NuGet packages and 28 hosted Pub packages (including test dependencies). OSV querybatch returned no advisories for those queries. Excludes SDK/runtime advisories, non-hosted SDK packages, native platform build dependencies and FastAPI/Python (outside this Stage 1 audit). This is one advisory database, not a vulnerability-free certification. [Official FluentValidation documentation](https://docs.fluentvalidation.net/en/latest/aspnet.html) still says the ASP.NET package is unsupported; checked on review date.

Initial online NuGet restore failed with NU1301/Windows TLS credentials. Exact cached packages were copied into a workspace-local feed and restored successfully; build had zero warnings/errors. `NuGetAudit=false` applied only to that offline restore; the separate OSV query provides the recorded advisory scope. No TLS verification was disabled.

HTTP tests bound only to 127.0.0.1:5185 in Development, with no HTTPS endpoint configured. HTTPS redirection logged “Failed to determine the https port for redirect”; requests stayed local HTTP. This does not validate a LAN/mobile or deployed transport. Initial execution hit a sandbox Windows Event Log write error; `Logging__EventLog__LogLevel__Default=None` was set only in the test process, retaining console logs. Default Event Log behavior is not verified here.

Android emulator 10.0.2.2 and physical-device LAN reachability still need owner/device testing; localhost binding alone is not proof of phone access. No firewall/CORS/TLS weakening performed. CORS is relevant only if an actual browser target is selected; mobile native tests do not establish browser compatibility. Provider/FastAPI direct calls and credentials were not found in reviewed Flutter source. No live provider/service credentials or deployment environment were available to inspect.

## Reproduce and finish

From the repository root, with the required .NET SDK/packages available:

```powershell
dotnet build Backend/TripPlanning.Api/TripPlanning.Api.csproj
$env:ASPNETCORE_ENVIRONMENT='Development'
$env:ASPNETCORE_URLS='http://127.0.0.1:5185'
# Only for the restricted Windows test environment:
$env:Logging__EventLog__LogLevel__Default='None'
dotnet run --no-build --no-launch-profile --project Backend/TripPlanning.Api
# In another terminal:
python docs/evidence/stage1/http_review.py http://127.0.0.1:5185
```

For parser reproduction, export `mobile/lib/models/trip_plan.dart` from 21e8cdd into a temporary directory and run a Dart script importing it. Call `TripPlan.fromJson(body, requestedDays:3)` with each of `{"destinationId":"rome"}`, `{"destinationId":"rome","days":["bad"]}`, and `{"destinationId":"rome","days":[{"dayNumber":1.5,"places":[]}]}`. Expected owner fix: controlled rejection rather than the accepted models recorded here. Repeat under the supported Dart/Flutter SDK before marking verified.

Final retest matrix: normal/partial/empty real Flutter flow; destination/day/interests validation; malformed success/error body; connection refused/timeout; no fake fallback; agreed input bounds; exception/log hygiene. Record final integrated SHA and owner-fix links. These final checks remain **Not tested** until owner changes and supported device/toolchain access exist.

## Card checklist status

- Done: inspect current merged report/source and Stage 1 diffs.
- Done, with stated limits: review validation, controlled errors, logs, secrets and configuration.
- Done: record dependency audit scope and network assumptions.
- Done: evidence-backed findings with severity, component owner, status and retest result.
- Not done: retest owner fixes on final Stage 1 SHA. Untested checks are labelled, but that alone does not complete this combined item.
- Pending publication: publish readiness conclusion and retain this review's individual PR URL. Local report exists; update card only after PR publication.

Do not mark the entire card complete yet. Remaining dependency is owner integration/fixes and final retest, not FastAPI, provider, taxonomy deployment, Auth, Budget or local saving.
