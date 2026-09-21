# Day 3 release handoff

This handoff's runtime evidence is pinned to the pre-documentation `main`
baseline `2d2e1f7019fa0db97a5274c9c632eef67c54ed0c`. PR #25 changes only
documentation and the read-only verification script. The deployment owner must
deploy the latest `main` commit containing this handoff and record its exact SHA.
Stage 3 and release readiness remain **WAITING** until the deployment and
independent owner checks below are completed on that final SHA.

## Current evidence index

| Area | Evidence | Status |
| --- | --- | --- |
| Stage 2B | `docs/security-stage2b-closeout.md` | GREEN/CLOSED at its recorded SHA |
| Provider implementation | PR #23 merged as current main | Merged |
| Real-data validation | PR #24 head `2254c7918d01c7a9f2ec1dae49c4857231e57da6` | WAITING for final-SHA V03/V07/V11/V14 evidence; do not merge yet |
| Planner/FastAPI | `python -m pytest ai-ml/service/tests ai-ml/planning/tests -q` | 117 passed on runtime baseline `2d2e1f7`, Python 3.14.4 |
| Backend | PR #24 records 57 passed on its owner branch | Provenance retained; rerun on final release SHA after deployment changes |
| Flutter | Source/config inspected; commands and matrix below | WAITING for matching Flutter SDK, build, device smoke, and real-provider E2E |
| Security | Repository review reports no unresolved Blocker/Critical | WAITING for Sami's deployed Geoapify-mode retest/sign-off |
| RC QA | Matrix below is prepared | WAITING for Balsam's independent execution/sign-off |
| Documentation | `docs/reproducibility.md` and this handoff | Prepared; synchronize SHA after final merge |
| Demo | Implemented-feature flow below | Prepared; real runtime proof WAITING |

## Existing MonsterASP deployment path

The repository has no `.github/workflows` files, GitHub Actions workflows,
GitHub deployment records, tracked publish profile, WebDeploy/FTP script, or
CI/CD configuration. No existing repository-authorized path was found that can
update `https://gr6-tripplanning-api.runasp.net/`. Updating that same service
therefore still requires the owning MonsterASP account or its existing
deployment credentials. Do not create a second MonsterASP service.

The currently reachable service is known to be stale/fixture-backed. A fresh
run of `scripts/post-deploy-verify.ps1` on 21 September 2026 reached FastAPI
health successfully, then stopped the Istanbul/history check because the
Backend returned `ist-001`, `ist-007`, `ist-003`, `ist-004`, `ist-009`,
`ist-006`, `ist-005`, `ist-002`, and `ist-008` instead of `geoapify:` IDs.
This is evidence that the public Backend is not in final Geoapify mode.

## MonsterASP owner checklist

1. Fetch and check out the latest `main` commit containing PR #25. Record its
   exact full SHA before building; do not deploy from an unrecorded branch tip.
2. On a machine with the .NET 10 SDK, run:

   ```text
   dotnet restore Backend/Backend.slnx
   dotnet test Backend/Backend.slnx --configuration Release --no-restore --nologo
   dotnet publish Backend/TripPlanning.Api/TripPlanning.Api.csproj --configuration Release --no-restore --output artifacts/backend-2d2e1f7 --nologo
   ```

3. Archive the contents of `artifacts/backend-2d2e1f7`, calculate SHA-256 for
   the archive, and record both the hash and the publishing machine's .NET SDK
   version. No artifact/hash is claimed in this repository because .NET was
   unavailable in the preparation environment.
4. Configure the service without copying values into source or screenshots:

   | Setting | Required value |
   | --- | --- |
   | `CANDIDATE_SOURCE_MODE` | `Geoapify` |
   | `GEOAPIFY_BASE_URL` | `https://api.geoapify.com/` |
   | `GEOAPIFY_TIMEOUT` | `10` |
   | `GEOAPIFY_API_KEY` | server-side secret supplied by the owner; never reveal it |
   | `AI_SERVICE_BASE_URL` | `https://gr6-planning-service.onrender.com/` |
   | `AI_SERVICE_TIMEOUT` | `10` |

5. Deploy the Release publish output to the existing
   `gr6-tripplanning-api.runasp.net` application and restart it if the platform
   requires a restart.
6. Run `scripts/post-deploy-verify.ps1` against that exact URL. Save its
   secret-free output, deployment timestamp, deployed SHA, artifact SHA-256,
   and platform environment name.
7. Retain server-side sanitized evidence for the live provider input count,
   accepted/excluded counts, six-field canonical candidates, Fatih membership,
   duplicate behavior, and the request sent to FastAPI. These are required for
   Asma's V03/V07/V11/V14; public response IDs alone cannot prove all four.

## Post-deployment proof requirements

The checked-in script covers FastAPI health, Istanbul/history,
Istanbul/landmark, no interests, unsupported destination, and malformed JSON.
It records status, `X-Request-ID`, sanitized body, and verifies that every
returned public place ID begins with `geoapify:`. Public errors must not contain
the provider host, an API-key parameter, stack traces, or exception type names.

Provider failure and FastAPI failure require controlled environment tests by
the deployment owner: temporarily use a safe invalid provider key/endpoint in
a non-production slot, and temporarily use an unreachable AI service URL.
Each must produce a controlled error with a request ID and no fixture itinerary.
Restore the exact production settings immediately after each check. Unit-level
coverage is in `GeoapifyClientTests`, `GeoapifyCandidateSourceTests`,
`PlanningExceptionMiddlewareTests`, and `FastApiPlanningClientTests`.

## Render Backend Plan B

No Dockerfile or `render.yaml` exists. Render can host the Backend through its
Docker runtime, but the repo needs a small multi-stage .NET 10 Dockerfile and
must bind ASP.NET to `0.0.0.0:$PORT`. A proposed container build is:

```text
docker build -f Backend/TripPlanning.Api/Dockerfile -t gr6-backend .
```

The container start command should be equivalent to:

```text
dotnet TripPlanning.Api.dll --urls http://0.0.0.0:${PORT}
```

Use the same six Backend environment variables from the MonsterASP checklist.
`PLANNING_MAX_CANDIDATES` belongs to FastAPI, not this Backend service. A new
Render web service receives a new public `onrender.com` URL. Flutter would then
need `mobile/lib/config/app_config.dart` `backendBaseUrl` changed to that URL,
followed by `flutter analyze`, `flutter test`, a release APK/build, device smoke,
the full Stage 3 E2E matrix, Backend failure-path checks, RC QA, and security
retest. Risks are the new Docker/port configuration, free-tier cold starts,
public URL change, secret transfer, and another complete deployment regression.
Production and Flutter are not switched by this preparation.

## Heba Stage 3 E2E checklist

Use a matching Flutter/Dart SDK (`pubspec.yaml` requires Dart `^3.12.2`) and
keep `useMockApi=false`.

- Run `flutter pub get`, `flutter analyze`, `flutter test`,
  `flutter build apk --release`, and `flutter run` on the selected device.
- Capture the app version/build, device/OS, Backend URL, Backend SHA, date/time,
  and request ID for each network scenario.
- Prove Istanbul with history, landmark, both interests, and no interests.
  Successful place IDs must be `geoapify:`-backed and each day must show at
  most three unique places.
- Prove normal success, `PARTIAL_ITINERARY`, and `NO_PLACES_AVAILABLE` UI states
  when those states are produced by controlled final-SHA inputs.
- Prove unsupported/invalid input, provider failure, FastAPI failure, local
  network/offline failure, Retry behavior, and that none becomes mock/fixture
  success.
- Capture readable screenshots for inputs, result days/warnings, and every
  error state; capture one continuous video for the real happy path and Retry.
  Do not expose provider URLs, headers, keys, or private logs.

## Balsam RC matrix

For every row record final SHA, environment, request ID, input, expected
result, actual result, evidence link, issue, and Pass/Fail. Independent QA must
cover: real happy path; history; landmark; combined and no interests; partial;
empty; invalid public request; provider failure; FastAPI failure; malformed or
invalid `PlanningResult`; Flutter loading/success/warning/error/Retry states;
all requested days present; `N=min(E,3D)`; quotient/remainder balance; maximum
three places/day; selected subset and uniqueness; and exact warning semantics
for `N=0`, `0<N<D`, and `N>=D`.

## Sami post-deployment security retest

Record final SHA and environment, then verify the key exists only in server
secret configuration; actual source mode is Geoapify; returned IDs prove the
deployed mode; logs and public failures contain no key, raw provider URL,
stacktrace, or exception details; provider and FastAPI failures are controlled;
request IDs correlate Flutter/Backend/FastAPI without accepting unsafe values;
and no provider failure silently returns fixtures. Sami owns the final security
sign-off.

## Final demo flow and limitations

Demo only the implemented flow: open the planner, choose Istanbul and a day
count, select history and/or landmark (or no interests), generate through the
ASP.NET Backend, show the returned days and real provider-backed places, then
show one coverage warning and one controlled Retry error if reproducible.

State these limitations: real-provider scope is Istanbul with a Fatih-only
pool; public interests are history and landmark; budget/pricing is disabled;
there is no auth/login, database/cloud save, exact schedules, optimal-route
guarantee, or broader real-provider destination support. The current Medium/Low
items (provider-base allowlist, local response cap, Backend request-ID bound,
startup timeout/base validation, and explicit `.env` ignore) remain accepted
and open unless owners decide they block release.

## Strict gate

Stage 3: **WAITING / NOT GREEN**. Release readiness: **NOT READY**. Remaining
dependencies are the existing MonsterASP deployment by its owner, final-SHA
live-provider evidence for PR #24, Flutter build/device E2E, independent RC QA,
deployed security sign-off, and final technical sign-off against one recorded
SHA and environment.
