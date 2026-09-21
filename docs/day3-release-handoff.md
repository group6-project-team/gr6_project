# Stage 3 release evidence and Ahmad Card 15 handoff

Last reconciled: 21 September 2026. This is the canonical Day-3 technical
release record. It distinguishes deployed runtime evidence, committed evidence,
direct owner reports, and Ahmad's independent public verification.

## Release identity and runtime equivalence

| Field | Exact value | Status |
| --- | --- | --- |
| Deployed Backend runtime/source SHA | `664dfa726629c47fbd12c5ca6e7c43f54b95291f` | Public Geoapify runtime verified |
| Main before final Card 15 evidence update | `7b6889524967b8c582195cbc342253260ae5a9cf` | PR #28 merge |
| PR #24 reviewed head | `300e98093813962cd6cc45606f862228ab93abda` | Merged; Asma Card 10 DONE |
| PR #28 reviewed head | `a19fa594be886bf9474b245d1460dec1d87895bd` | Approved and merged |
| PR #28 merge SHA | `7b6889524967b8c582195cbc342253260ae5a9cf` | Sami security sign-off on main |
| Public Backend | `https://gr6-tripplanning-api.runasp.net/` | Verified public runtime |
| Public FastAPI | `https://gr6-planning-service.onrender.com/` | Health verified |

The full diff from deployed SHA `664dfa7...` through main `7b68895...` contains
only Stage 3 evidence, the validation matrix, and the final security sign-off.
A path-limited diff over `Backend/TripPlanning.Api`, `mobile`, `ai-ml/service`,
and `ai-ml/planning` is empty. No Backend, Flutter, FastAPI, or planner runtime
production file changed. The precise release statement is:

- deployed runtime SHA: `664dfa726629c47fbd12c5ca6e7c43f54b95291f`;
- repository main before this final evidence PR: `7b6889524967b8c582195cbc342253260ae5a9cf`;
- runtime source equivalence: proven by the empty runtime-path diff.

Do not describe a later evidence-only main SHA as deployed. Re-run the runtime
path comparison if any production or runtime-configuration file changes.

## Pull-request disposition

| PR | Final disposition |
| --- | --- |
| #24 | Merged. Supplies Asma's final Card 10 real-data evidence. |
| #26 | Closed without merge because PR #24 fully superseded it. |
| #28 | Reviewed file-by-file, approved, and merged as `7b68895...`. It adds only `docs/security-stage3-final-signoff.md`. |
| #27 | This final Card 15 evidence update. It should be merged because the repository guide requires Ahmad to synchronize the canonical handoff and perform technical release sign-off. |

## Final gate status

| Gate | Status | Evidence basis |
| --- | --- | --- |
| Backend Stage 3 | **DONE** | Mohammad direct closure; 57/57 Backend tests; public Geoapify path corroborated independently |
| Asma Card 10 | **DONE** | PR #24 merged; V03/V07/V11/V12/V14 and 20 = 19 accepted + 1 excluded reconciled |
| Heba Card 11 / Flutter | **DONE** | Direct owner report on deployed SHA; analyze, 21/21 tests, APK build, emulator smoke, real-provider E2E, loading and network Retry evidence |
| Stage 3 integration | **GREEN** | Backend, Asma and Heba integration requirements are complete on the equivalent deployed runtime tree |
| Balsam independent RC QA | **DONE / PASS** | Direct owner final RC report; 57/57, 21/21 and 19/19 suites; planner invariants; 0 Blocker/Critical |
| Sami security | **DONE / PASS** | PR #28 approved and merged; 0 security Blocker/Critical; Medium/Low follow-ups remain explicit |
| Ahmad Card 15 | **READY FOR FINAL SIGN-OFF** | Evidence sources reconciled, runtime equivalence proven, and canonical handoff finalized |
| Overall technical release readiness | **READY** | All Day-3 technical gates complete; 0 unresolved release Blocker/Critical reported by owners |

## Evidence-source ledger

### Committed evidence

PR #24 ties the bounded Geoapify/Fatih validation to deployed SHA `664dfa7...`,
request ID `b4aabdb8ded8425ba26429c1ed102d56`, and retrieval time
`2026-09-21T16:53:42+03:00`. It reconciles 20 raw records to 19 accepted and one
excluded square. Canonical IDs are provider-derived and records with different
provider IDs remain separate; physical-place deduplication is not claimed.

PR #28 records Sami's final security review against repository main
`bf24a7e...` and deployed runtime `664dfa7...`. It reports 57 Backend tests, 117
Python tests, dependency advisory checks, a 447-blob history-aware secret scan,
controlled provider/planner failures, explicit Geoapify mode, no hidden fixture
fallback, and 0 unresolved security Blocker/Critical. Hosting-secret values,
permissions, and private logs were not directly inspectable and are not claimed
verified.

### Direct owner-reported evidence

Heba reported the final Flutter package against deployed SHA `664dfa7...`, main
up to date at test time, the public RunASP Backend, and `useMockApi=false`:

- `flutter analyze`: no issues;
- `flutter test`: 21/21 passed;
- release APK build and generation: passed;
- Android emulator smoke: passed;
- Istanbul history, landmark, and no-interest real-provider flows: passed;
- loading and network-failure Retry states: passed without mock/fixture success;
- Rome and Aqaba: controlled `PLANNING_FAILED` as unsupported Stage 3 cases;
- E2E video and network-failure screenshot: attached to the Flutter Stage 3
  Trello card.

Partial, empty, provider-failure, and planner-failure states were not injected
into the public production flow by Heba. Their controlled behavior is covered
by Backend and independent QA tests. The approved release guide does not require
unsafe live fault injection merely to repeat that coverage.

Balsam reported final independent RC QA against deployed SHA `664dfa7...`, main,
the public RunASP Backend, and the Istanbul/Fatih Geoapify scope:

- real happy path, history, landmark, and no-interest flows: passed;
- `days=0` and unknown destination validation: controlled and passed;
- planner invariants: every requested day present; `E=19`, `D=3`,
  `N=min(E,3D)=9`; distribution 3/3/3; maximum 3/day; selected IDs unique and
  contained in the candidate pool; warning semantics valid;
- Backend regression: 57/57 passed;
- dependency/failure handling: 21/21 targeted tests passed;
- invalid/malformed `PlanningResult`: 19/19 targeted tests passed;
- no production code changed; final RC QA PASS; unresolved Blocker/Critical: 0.

Mohammad directly reported Backend Stage 3 closure at deployed SHA `664dfa7...`:
57/57 Backend tests, final RC QA PASS, real Istanbul/Fatih Geoapify path,
controlled dependency failures, dedup/validation/enrichment/correlation checks,
public E2E, and 0 open Blocker/Critical. No further Backend change was required.

### Ahmad independent supporting verification

Ahmad's public matrix corroborated the owner reports without replacing them:

| Case | Observed result |
| --- | --- |
| FastAPI health | 200 |
| Istanbul / history | 200; 3 days; 9 unique `geoapify:` IDs; max 3/day; `warnings=[]` |
| Istanbul / landmark | Same success invariants |
| Istanbul / no interests | Same success invariants |
| Rome | Controlled 500 `PLANNING_FAILED` |
| Aqaba | Controlled 500 `PLANNING_FAILED` |
| Malformed JSON | Controlled 400 |
| `days=0` | Controlled 400 |

Every case echoed the submitted request ID. Responses showed no API key,
Authorization material, raw provider URL, stack trace, or source-line leakage.

## PR #28 review conclusion

The final PR changed one documentation file and no production or semantic code.
Review confirmed exact repository and deployed SHAs, server-side key custody,
Geoapify-backed IDs, explicit provider mode, no hidden Fixture fallback,
controlled provider/FastAPI failures, request-ID evidence, dependency checks,
history-scan scope and limitations, and explicit 0 security Blocker/Critical.
No committed secret was found in its diff. Three trailing-whitespace findings
were corrected before approval.

Open nonblocking security work remains visible:

- Medium: restrict `GEOAPIFY_BASE_URL` to the expected HTTPS origin;
- Medium: independently bound provider response bytes/features/candidates;
- Medium carried items: normalize Backend request IDs and validate startup URL/
  timeout ranges;
- Low: add provider-log request correlation.

These findings are accepted as release follow-ups, not represented as fixed.

## Deployment decision

**NO REDEPLOY NEEDED.**

The deployed runtime is `664dfa7...`. All later main movement through PR #28,
and this Card 15 update, is evidence/documentation or a read-only verification
helper. The authoritative repository guide requires an exact deployed runtime
identity and final evidence on the equivalent integrated tree; it does not
require publishing identical binaries after evidence-only commits. Re-evaluate
if runtime code, runtime configuration, or a deployment artifact changes.

## Supported demo and accepted limitations

Demo the final Flutter build with `useMockApi=false`, select Istanbul, explain
that the provider pool is limited to Fatih, choose history, landmark, or no
interest, and generate the itinerary through the public Backend. Rome or Aqaba
may be shown only as controlled unsupported-destination negative cases.

Accepted scope and limitations: public destination `istanbul`; Fatih-only
Geoapify pool; interests `history` and `landmark`; no auth/login; no database or
cloud persistence; budget/pricing disabled; no exact schedules; no optimal
routing claim; no destination recommender; no new provider or LLM feature; no
hidden fixture fallback; no physical-place dedup across different provider IDs.

## Card 15 decision

All required Day-3 technical gates are supported. Card 15 is **READY FOR FINAL
SIGN-OFF**, and the release is technically **READY** with 0 unresolved
Blocker/Critical according to Mohammad's Backend closure, Balsam's independent
RC report, and Sami's merged security sign-off. Remaining Medium/Low security
hardening is documented above.

After this PR merges, only administrative synchronization remains: move the
applicable Trello cards/lists to their final state and link the merged PRs and
this canonical handoff. No remaining technical dependency blocks the approved
Stage 3 scope.
