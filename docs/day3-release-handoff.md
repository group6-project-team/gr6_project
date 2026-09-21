# Stage 3 release evidence and Ahmad Card 15 handoff

Last refreshed: 21 September 2026. This is the canonical Day-3 release record.
It distinguishes the deployed runtime from later repository-only movement and
separates direct evidence from teammate-reported results.

## Release identity and runtime equivalence

| Field | Exact value | Status |
| --- | --- | --- |
| Deployed Backend runtime/source | `664dfa726629c47fbd12c5ca6e7c43f54b95291f` | Public Geoapify runtime verified |
| Current `main` reviewed | `bf24a7e9c9fc1a9fba61a0f31938561cb4eba074` | PR #24 merge |
| PR #24 reviewed head | `300e98093813962cd6cc45606f862228ab93abda` | Merged; Asma Card 10 DONE |
| Public Backend | `https://gr6-tripplanning-api.runasp.net/` | Read-only checks passed as recorded below |
| Public FastAPI | `https://gr6-planning-service.onrender.com/` | Health check passed |

The exact diff from deployed SHA `664dfa7...` to main `bf24a7e...` contains only:

- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/filtering-accepted-excluded-summary-latest-main.txt`
- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/geoapify-normalized-candidates-latest-main.json`
- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/geoapify-raw-response-latest-main.json`
- `Backend/TripPlanning.Api.Tests/Evidence/Stage3/retrieval-date.txt`
- `ai-ml/data/provider-spike/stage-3-validation-matrix.md`

A path-limited diff over `Backend/TripPlanning.Api`, `mobile`, `ai-ml/service`,
and `ai-ml/planning` is empty. No Backend, Flutter, FastAPI, or planner runtime
production file changed. Therefore the precise release statement is:

- deployed runtime SHA: `664dfa726629c47fbd12c5ca6e7c43f54b95291f`;
- current repository main SHA: `bf24a7e9c9fc1a9fba61a0f31938561cb4eba074`;
- runtime source equivalence: proven by the empty runtime-path diff.

Do not describe `bf24a7e...` as deployed.

## Live pull-request state at refresh

| PR | Head / base at initial refresh | Status and disposition |
| --- | --- | --- |
| #26, latest Stage 3 provider evidence | head `d95c38ae7ff387a651e724d2fc3e4bdf740bf64d`; base `664dfa7...` | OPEN, non-draft, clean, but fully superseded by merged PR #24; do not merge |
| #27, Card 15 release evidence | head before this refresh `50dd02a6be5e494360236065e20f478e59dc995d`; base `664dfa7...` | OPEN; refreshed through main `bf24a7e...`; keep open until final gates close |
| #28, Stage 3 security sign-off | head `0df88478c18d2b2789c76969a3353f3dc15577fb`; base `bf24a7e...` | OPEN, non-draft, clean; direct Sami-owned PASS evidence reviewed below |

PR #26's four file blobs are byte-for-byte identical to the same four files
already on main through PR #24. It contains no unique evidence. The correct
action is to close it as superseded by PR #24, without merging or deleting its
branch solely for cleanup.

## Strict gate status

| Gate | Status | Evidence / remaining dependency |
| --- | --- | --- |
| Backend Stage 3 | **DONE** | Deployed Geoapify path is live; Mohammad's 57/57 result remains attributed to his run; current public checks corroborate runtime behavior |
| Asma Card 10 | **DONE** | PR #24 reviewed and merged; V03/V07/V11/V12/V14 evidence accepted |
| Heba Flutter closure | **PARTIAL / WAITING** | Functional results were relayed, but no direct final closure package was found |
| Stage 3 integration gate | **WAITING / NOT GREEN** | Heba's direct analyze/test/build/device/E2E evidence is still incomplete |
| Balsam independent RC QA | **WAITING** | No new Stage 3 RC execution, evidence links, defect disposition, or Blocker/Critical count found |
| Sami security sign-off | **PASS SUBMITTED** | Direct owner artifact in PR #28; 0 unresolved security Blocker/Critical; PR remains open |
| Ahmad Card 15 | **WAITING** | Evidence pack is current; final technical sign-off waits for Heba and Balsam, plus normal disposition of PR #28 |
| Overall release readiness | **WAITING / NOT READY** | Stage 3 integration and independent RC QA are not complete |

Sami's direct sign-off does not make the release ready by itself. Likewise,
the public checks below support Ahmad's coordination work but do not replace
Heba's mobile closure or Balsam's independent QA.

## Team evidence review

### Asma and Backend

PR #24 is merged and Card 10 is DONE. Its fresh evidence is tied to deployed
SHA `664dfa7...`, request ID `b4aabdb8ded8425ba26429c1ed102d56`, and
retrieval time `2026-09-21T16:53:42+03:00`. It reconciles 20 raw records to 19
accepted plus one excluded record, Beyazıt Meydanı, because
`tourism.sights.square` has no approved mapping. Same-name records with
different provider IDs remain separate by design. Mohammad's 57/57 Backend
result is preserved as Mohammad-owned evidence; it was not rerun in this work
environment.

### Heba

The only current Stage 3 mobile result found is the relayed functional summary:
Istanbul/history and Istanbul/landmark returned real itineraries, while Rome
and Aqaba displayed `PLANNING_FAILED`. No new Heba branch commit, open PR,
comment, or checked-in artifact supplied all of the following:

- exact tested SHA and app configuration;
- `flutter analyze` output;
- `flutter test` output;
- final release APK/build result;
- device or emulator smoke evidence;
- direct real-Backend E2E capture and request IDs;
- screenshots, video, or equivalent evidence.

Heba therefore remains PARTIAL/WAITING. The relayed functional summary is not
promoted to an independent sign-off.

### Balsam

No Stage 3 RC QA PR, recent branch commit, comment, or evidence artifact was
found. The latest Balsam branch visible in the fetched repository remains the
historical Stage 2B QA branch. Missing items are the executed final-environment
matrix, evidence/request IDs, defect severity and retest status, Flutter-visible
states where applicable, and an explicit unresolved Blocker/Critical count.

### Sami

PR #28 contains direct owner-authored final security evidence against repository
main `bf24a7e...` and deployed runtime `664dfa7...`. It records 57 Backend tests,
117 Python tests, live provider and failure-path checks, dependency checks, a
447-blob history secret scan, no hidden fixture fallback, working correlation,
and 0 unresolved security Blocker/Critical findings. It leaves Medium/Low
hardening work open, including provider-origin validation, local response
bounds, request-ID normalization, startup configuration bounds, and provider-log
correlation. Those items are documented as nonblocking for this sign-off.

The artifact is internally consistent with the runtime-equivalence diff and
with the public checks in this refresh. Its PR is still open, so the release
record says PASS SUBMITTED rather than claiming it is already merged into main.

## Ahmad-owned public verification

The refreshed PR #27 version of `scripts/post-deploy-verify.ps1` was run against
the public services. This version extends the earlier six-case helper to cover
Rome, Aqaba, invalid days, exact day count, maximum three places per day,
canonical-ID uniqueness, `geoapify:` IDs, and presence of the warnings field.

| Check | HTTP | Request ID sent and returned | Result |
| --- | ---: | --- | --- |
| FastAPI health | 200 | `day3-fastapi-health-613661894d58` | `ready` |
| Istanbul / history / 3 days | 200 | `day3-istanbul-history-5bb8f223c62f` | 3 days, 9 unique `geoapify:` IDs, max 3/day, `warnings: []` |
| Istanbul / landmark / 3 days | 200 | `day3-istanbul-landmark-b840dab64714` | 3 days, 9 unique `geoapify:` IDs, max 3/day, `warnings: []` |
| Istanbul / no interests / 3 days | 200 | `day3-istanbul-no-interests-8de81dd93dd7` | 3 days, 9 unique `geoapify:` IDs, max 3/day, `warnings: []` |
| Rome | 500 | `day3-unsupported-rome-ab99a347e907` | Controlled `PLANNING_FAILED`; no leak marker |
| Aqaba | 500 | `day3-unsupported-aqaba-13a56837d4cc` | Controlled `PLANNING_FAILED`; no leak marker |
| Malformed JSON | 400 | `day3-malformed-json-c251ea06f946` | Controlled validation response |
| `days=0` | 400 | `day3-invalid-days-6e609f16e869` | Controlled 1–14 validation response |

Every case echoed the submitted `X-Request-ID`. The response scan rejected API
key query markers, the raw Geoapify host, Authorization/Bearer material, .NET
source-line diagnostics, stack traces, and Python traceback markers.

Rome and Aqaba are not required real-provider successes. Their older partial
and empty success behavior belongs to Stage 2B fixtures. In Stage 3 they are
controlled negative cases outside the Istanbul/Fatih provider scope. The live
service currently maps both to HTTP 500 with the sanitized code
`PLANNING_FAILED`; this matches the relayed Flutter behavior. It is not a reason
to add destination support or change Backend semantics during closure.

## Local tool availability and test attribution

The current work host has no `dotnet`, Flutter SDK, `adb`, Android emulator, or
Gradle command available. Java 8 is present, but it is not enough to run the
project's Flutter/Android workflow. Consequently:

- no independent Backend suite was run here; 57/57 remains attributed to
  Mohammad and is also directly reported by Sami in PR #28;
- no Flutter analyze, test, build, APK, device, or emulator evidence is claimed;
- the read-only public HTTP verification above is the Ahmad-owned evidence from
  this environment.

## Focused sanitization scan

A focused content scan was run over all five files introduced between
`664dfa7...` and `bf24a7e...`, plus this handoff and the verification script.
The scan checked high-confidence patterns for credential-bearing API-key query
parameters, Authorization headers, Bearer tokens, token/secret/password query
parameters, private keys, environment-secret assignments, .NET source-line
traces, and Python tracebacks.

No credential, token, private key, environment dump, or committed stack trace
was found. Two `apiKey=` matches were literal detection-rule text in this
handoff/script, not values. This is a focused pattern scan and manual
classification, not a substitute for a dedicated secret scanner or access to
private hosting configuration.

## Deployment decision

**NO REDEPLOY NEEDED.**

The existing handoff required the deployment owner to deploy the latest main
containing PR #25 and record its exact SHA. That deployment is `664dfa7...`.
The only later main movement is PR #24 evidence/documentation, and the runtime
path diff to `bf24a7e...` is empty. PR #24 and Sami's PR #28 explicitly retain
the same deployed runtime SHA while reviewing the later repository state.
There is no authoritative repository rule requiring an evidence-only commit to
be republished as identical runtime binaries.

Re-evaluate this decision if any Backend, Flutter, FastAPI, planner, runtime
configuration, or deployment artifact changes after this record. Do not call
`bf24a7e...` deployed merely because its runtime tree is equivalent.

## Final demo flow and frozen limitations

1. Confirm FastAPI health and the public Backend URL.
2. Launch the final Flutter build with `useMockApi=false`.
3. Select Istanbul, explain that the real-provider pool is bounded to Fatih,
   choose history or landmark, and request a valid day count.
4. Show returned day cards, real provider-backed places, and request
   correlation where the app exposes it.
5. Show Rome or Aqaba only as a controlled unsupported Stage 3 negative case.

State the implemented limitations plainly: public destination `istanbul` with a
Fatih-only provider pool; interests `history` and `landmark`; budget/pricing
disabled; no auth/login; no database/cloud persistence; no exact schedules;
no optimal-routing claim; no destination recommendation; no new provider or
LLM feature; no hidden fixture fallback; and no physical-place dedup across
different provider IDs.

## Ahmad's remaining checklist

DONE now:

- Backend Stage 3 and Asma Card 10;
- runtime-tree equivalence proof;
- current public pre-RC matrix and request IDs;
- focused sanitization scan;
- Sami's direct security PASS evidence reviewed;
- PR #26 proven redundant;
- PR #27 refreshed while remaining open.

Waiting on owners:

- Heba: direct final Flutter analyze/test/build/APK/device/E2E/media package;
- Balsam: independent final RC matrix, defects/retests, and explicit unresolved
  Blocker/Critical count;
- normal review/merge disposition for Sami's PR #28.

After those arrive, Ahmad must review the evidence against the exact runtime
and repository identities above, record final team-wide Blocker/Critical counts,
then complete Card 15 and release readiness. Until then, Stage 3 integration is
WAITING and the overall release is NOT READY.
