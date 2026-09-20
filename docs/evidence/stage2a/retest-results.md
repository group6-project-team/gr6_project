# Stage 2A security evidence — 17 September 2026

## Historical scope and post-merge status

The commands, counts and results below are preserved historical evidence from 17 September at `71323258799cd15bc4ac77abd7d701158bf6589d`; “final SHA” below means that historical owner-fix SHA, not the final post-merge gate. No runtime tests were rerun for the 20 September documentation correction.

Stage 2A GREEN is closed on main `dd72cc1313387908c51b497ee97b8167650e429a`, with no current security Blocker/Critical identified for that gate, as recorded in [Ahmad's PR #14 review](https://github.com/group6-project-team/gr6_project/pull/14#pullrequestreview-5241477565) and card update. At that baseline, following `b75b806`, the public path is `POST /trip-plans/preview → Backend → real FastAPI /plan → real planner` and the verified candidate pool reaches **9 candidates**. Source inspection corroborates `TripPlansController.Preview` → `RealTripPreviewService` → `PlanningService` → `FastApiPlanningClient`; `CreateStage2ACandidates` contains `ist-001` through `ist-009`. This reported post-merge gate is distinct from the historical 24-test client-only proof below; `dd72cc1` is a gate baseline, not a claim about the latest main head.

See [the corrected review summary and prepared Stage 2B checks](../../security-stage2a-review.md) for active Stage 2B work, explicit dev/test/integration fixture sources, no silent dependency/provider fallback, retained Medium Backend/config findings 2A-02/03/04, and the production Geoapify gate (Stage 2B GREEN plus Asma handoff readiness). Hosting/external protection remains **N/A / pending target**, not tested. No Auth/JWT/CORS scope is added.

## Tested source and environment

- Owner implementation: `71323258799cd15bc4ac77abd7d701158bf6589d` (`feature/backend-stage2a-fastapi-integration`, PR #13).
- Earlier reproduced-failure baseline: `bd4bd98a3eb22faffb7617f9c961d99208fa32e4`.
- Windows native environment; .NET SDK 10.0.301; Python 3.14.3.
- Real FastAPI process: `python -m uvicorn service.app:app --host 127.0.0.1 --port 8000`.
- Backend test client: `http://127.0.0.1:8000/`, 10-second timeout.

## Recorded checks

| Check | Result |
|---|---|
| `python -m pytest ai-ml/service/tests ai-ml/planning/tests -q` | **116 passed** at final SHA. Five dependency/deprecation warnings; no failed test. |
| `dotnet test Backend/TripPlanning.Api.Tests/TripPlanning.Api.Tests.csproj --no-restore` with real FastAPI running | **24 passed** at final SHA, including three real-service integration cases. Compiler emitted nullable warnings in test assertions after response DTOs became nullable; no failed test. |
| Earlier owner SHA full .NET suite | **20 passed** before the null-response owner fix. |
| Focused malformed-success probe at earlier SHA | `{"days":null,"warnings":[]}` produced `NullReferenceException`, not `PlanningFailedException`: finding reproduced. |
| Owner-fix retest | Commit `7132325` added required/null validation and four regression cases; all passed in the 24-test run. |
| Focused request-ID probe at final SHA | A 4,096-character inbound ID was retained in `HttpContext.Items` and echoed in the response: finding 2A-03 reproduced. |
| Focused candidate-bound probe at final SHA | Backend client serialized/sent 501 candidates; stub FastAPI 413 was reached and mapped to `PlanningFailedException`: finding 2A-02 reproduced. |
| Retry/fallback inspection | No retry policy or fixture fallback in `Program.cs`, `FastApiPlanningClient` or `PlanningService`; timeout/connection/503 tests throw controlled failures. |
| NuGet advisory check | `dotnet list ... package --vulnerable --include-transitive`: no vulnerable packages reported by configured sources. |
| Python advisory check | `pip-audit` against service runtime/dev requirement files: no known vulnerabilities reported. |
| Repository secret-pattern scan | 290 unique reachable blobs across fetched refs; two placeholder credential assignments; no real credential/private-key/common-token match identified. |

Temporary focused C# probes were added only to the detached owner worktree, executed, and removed. They were not committed to the owner's branch. No owner implementation was changed.

## Reproduction commands

From the repository at the tested owner SHA, start FastAPI:

```powershell
cd ai-ml
python -m uvicorn service.app:app --host 127.0.0.1 --port 8000
```

In another terminal at the repository root:

```powershell
python -m pytest ai-ml/service/tests ai-ml/planning/tests -q
dotnet restore Backend/TripPlanning.Api.Tests/TripPlanning.Api.Tests.csproj
dotnet test Backend/TripPlanning.Api.Tests/TripPlanning.Api.Tests.csproj --no-restore
dotnet list Backend/TripPlanning.Api.Tests/TripPlanning.Api.Tests.csproj package --vulnerable --include-transitive
```

The dependency advisory results are time-sensitive and require network access. The real integration tests require FastAPI on port 8000; the service README example uses port 8001, so use the test suite's configured port or update both sides together.
