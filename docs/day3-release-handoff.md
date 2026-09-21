# Stage 3 release evidence and Ahmad Card 15 handoff

Last refreshed: 21 September 2026. This is the canonical release-evidence pack.
It records what is independently verified, what is inherited with provenance,
and which owner gates remain open. It does not declare Stage 3 GREEN.

## Release identity

| Field | Value | Provenance |
| --- | --- | --- |
| Final release SHA under review | `664dfa726629c47fbd12c5ca6e7c43f54b95291f` | Fresh fetch of `origin/main` on 21 September 2026; also the reported deployed Backend SHA |
| Public Backend | `https://gr6-tripplanning-api.runasp.net/` | Independently exercised in this work run |
| Public FastAPI | `https://gr6-planning-service.onrender.com/` | Independently exercised in this work run |
| PR #23 | Merged; head `3a3683f9677b95ca3e1c67669639e1f4a936cbe5`, merge commit `2d2e1f7019fa0db97a5274c9c632eef67c54ed0c` | Fresh GitHub API and repository history check |
| PR #25 | Merged; head `e25057ad70729ae9952477efcd6a14b4a6fbbc4b`, merge commit `664dfa726629c47fbd12c5ca6e7c43f54b95291f` | Fresh GitHub API and repository history check |
| PR #24 | Open, non-draft, clean; head `300e98093813962cd6cc45606f862228ab93abda`, base `664dfa726629c47fbd12c5ca6e7c43f54b95291f` | Fresh GitHub API and fetched PR head on 21 September 2026 |

## Release gate

| Gate | Status | Evidence / remaining owner action |
| --- | --- | --- |
| Stage 2B closure | DONE | Sami's closeout at `c54fd9daf2d4d66d27687c038047eb72336db236`, committed as `5e0b252c77d041296c3abc0b93cdb44667ef2e83` and merged by PR #22 as `7a3e89992905a2aad9615b88d6fbf06e613b3d3e`; no Blocker/Critical was identified for that gate |
| PR #23 provider implementation | DONE | Merged; exact head and merge SHA above |
| PR #25 reproducibility/handoff | DONE | Merged; exact head and merge SHA above |
| Ahmad Card 03 | DONE (previous release record) | Authoritative release-coordination brief supplied for this work run. The repository does not contain a separate Card 03 artifact, so no additional test claim is inferred here |
| Ahmad Card 14 | DONE (previous release record) | Authoritative release-coordination brief supplied for this work run. The repository does not contain a separate Card 14 artifact, so no additional test claim is inferred here |
| Backend Stage 3 closure | READY | Mohammad reported 57/57 Backend tests and no Backend Blocker/Critical on release SHA; independent public checks below corroborate deployed happy paths, controlled public validation failures, correlation, and Geoapify IDs, but do not substitute for the reported suite |
| Asma V03/V07/V11/V14 | READY FOR AHMAD REVIEW | PR #24 now claims fresh PASS evidence on release SHA and contains new artifacts at head `300e9809...`; it remains open and owner-authored, so this pack does not merge or independently reclassify its semantic assertions |
| Heba Flutter E2E/build/device | WAITING | Need exact SHA, Flutter analyze/test/build results, device or emulator smoke, and real-Backend E2E evidence |
| Balsam independent RC QA | WAITING | Need executed matrix, evidence links/request IDs, issue results, Blocker/Critical count, and sign-off |
| Sami post-deploy security | WAITING | Need final deployed-environment security/config retest, unresolved Blocker/Critical count, and sign-off |
| Ahmad Card 15 | WAITING | Evidence pack and demo are prepared; final sign-off waits for the owner gates above |
| Stage 3 overall | WAITING / NOT GREEN | Independent Flutter, RC QA, and security gates are absent; PR #24 also requires Ahmad review/normal team disposition |
| Release readiness | NOT READY | Same remaining gates as Stage 3 overall |

## Evidence classification

### Verified in this work run

- Fresh `origin/main` was `664dfa726629c47fbd12c5ca6e7c43f54b95291f`
  at the start of verification.
- GitHub status for PRs #23, #24, and #25 and the exact heads/merge commits
  shown above was checked live.
- FastAPI health and six public Backend cases were exercised at
  `2026-09-21T14:56:00Z` through `2026-09-21T14:56:04Z`.
- History, landmark, and no-interest requests each returned HTTP 200, nine
  places, `warnings: []`, only `geoapify:` place IDs, and no `ist-` IDs.
- Unsupported destination, malformed JSON, and an invalid zero-day request
  each returned HTTP 400 and echoed the submitted `X-Request-ID`.
- The inspected public responses did not contain an API-key parameter or
  value marker, Authorization/Bearer value, raw Geoapify host URL, stack
  trace, .NET exception type, or Python traceback.

The successful public responses prove real provider-backed identities reached
the public response. They do not alone prove Asma's Fatih membership,
canonical-shape, different-provider-ID duplicate semantics, or filtering-count
requirements.

### Verified previously with exact provenance

- Stage 2B closure: `docs/security-stage2b-closeout.md`, reviewed main
  `c54fd9d...`, artifact commit `5e0b252...`, PR #22 merge `7a3e899...`.
- PR #23 and PR #25 merger facts are listed in the release identity table.
- Card 03 and Card 14 are DONE in the authoritative release-coordination brief
  supplied for this run. No repository-only test result is invented for them.

### Teammate-reported / waiting independent confirmation

- Mohammad's Backend closure report on release SHA: 57/57 PASS, real-provider
  public smoke request `c0f2e3afd43a493f91ac3ffbaa16348c`, controlled
  provider/FastAPI failures, deterministic canonical-ID dedup, no hidden
  fixture fallback, and no key leakage. The 57-test suite was not rerun in this
  docs-focused work environment.
- PR #24 head `300e9809...` states V03, V07, V11, and V14 PASS from a fresh
  bounded Fatih run on release SHA, with request ID
  `b4aabdb8ded8425ba26429c1ed102d56`, 20 raw records, 19 accepted, and one
  excluded. These are Asma-owned claims and artifacts awaiting Ahmad review;
  this run did not recreate the private provider capture.

### Waiting

- Heba final Flutter E2E/build/device evidence: **WAITING**.
- Balsam independent RC QA evidence and Blocker/Critical count: **WAITING**.
- Sami final post-deploy security sign-off and Blocker/Critical count:
  **WAITING**.
- Ahmad Card 15 final sign-off: **WAITING**.
- Final team-wide unresolved Blocker count: **UNKNOWN until all waiting owners report**.
- Final team-wide unresolved Critical count: **UNKNOWN until all waiting owners report**.
- Backend-owner reported unresolved Blocker/Critical count: **0 / 0**, attributed
  to Mohammad's closure report; not a team-wide count.

## Independent public runtime checks

| UTC timestamp | Check | HTTP | Request ID sent and returned | Key result |
| --- | --- | --- | --- | --- |
| `2026-09-21T14:56:00.1571793Z` | FastAPI `GET /health` | 200 | `ahmad-fastapi-health-7c2a12d37879` | `{"status":"ready"}` |
| `2026-09-21T14:56:00.8982436Z` | Istanbul, 3 days, history | 200 | `ahmad-istanbul-history-0ef4011a89e3` | 9 places; all `geoapify:`; no `ist-`; `warnings: []` |
| `2026-09-21T14:56:01.9025477Z` | Istanbul, 3 days, landmark | 200 | `ahmad-istanbul-landmark-2bc19e07353d` | 9 places; all `geoapify:`; no `ist-`; `warnings: []` |
| `2026-09-21T14:56:02.9660372Z` | Istanbul, 3 days, no interests | 200 | `ahmad-istanbul-no-interests-4fda0924457e` | Public contract accepts empty interests; 9 places; all `geoapify:`; `warnings: []` |
| `2026-09-21T14:56:03.7039019Z` | Unsupported destination | 400 | `ahmad-unsupported-destination-c192dc7dbd10` | Controlled validation response |
| `2026-09-21T14:56:03.9399414Z` | Malformed JSON | 400 | `ahmad-malformed-json-bf736d867f87` | Controlled validation response |
| `2026-09-21T14:56:04.1647502Z` | Zero days | 400 | `ahmad-invalid-days-da469c260274` | Controlled day-range validation response |

The originally merged `scripts/post-deploy-verify.ps1` passed health plus its
three successful Backend cases, then exited at the expected unsupported-
destination 400 because its PowerShell 7 error handler called the obsolete
`GetResponseStream()` API on `HttpResponseMessage`. This branch changes only
that response-capture mechanism to use `-SkipHttpErrorCheck` and UTF-8 decoding
for byte-array error bodies; the check set and acceptance rules are unchanged.
The repaired script completed all six checks successfully:

| Script check | HTTP | Echoed request ID | Script assertion |
| --- | --- | --- | --- |
| FastAPI health | 200 | `day3-fastapi-health-a69ce0d57216` | Ready response received |
| Istanbul/history | 200 | `day3-istanbul-history-aab4404fbb71` | Nonempty response; every place ID is `geoapify:` |
| Istanbul/landmark | 200 | `day3-istanbul-landmark-a3067338b61d` | Nonempty response; every place ID is `geoapify:` |
| Istanbul/no interests | 200 | `day3-istanbul-no-interests-b2b3dcc94b8d` | Nonempty response; every place ID is `geoapify:` |
| Unsupported destination | 400 | `day3-unsupported-destination-ed28fdccbe8e` | Expected controlled status |
| Malformed JSON | 400 | `day3-malformed-json-446b31ea0935` | Expected controlled status |

For every case the script also rejected a missing response request ID and
scanned the decoded body for `apiKey=`, the raw Geoapify host, .NET source-line
diagnostics, and stack-trace markers. This is a narrow public-response leakage
check, not a server-log audit or complete secret scan.

## Final demo flow

### Presenter steps

1. Precheck `GET https://gr6-planning-service.onrender.com/health`; continue
   when it returns HTTP 200 with `{"status":"ready"}`. Confirm the Flutter app
   is configured for `https://gr6-tripplanning-api.runasp.net/`.
2. Launch the app and open the trip-planning flow.
3. Select destination **Istanbul**. Explain that the current real-provider pool
   is bounded to Fatih within Istanbul.
4. Select **history** (or **landmark**) and a valid day count such as 3.
5. Submit preview and show the returned day cards and places.
6. Explain the implemented path: the ASP.NET Backend fetches bounded Geoapify
   records, validates membership, maps and filters categories, deduplicates by
   canonical provider ID, sends canonical candidates to FastAPI, validates and
   enriches the plan, and returns the itinerary to Flutter.
7. For technical evidence, correlate the request with Backend evidence and
   confirm returned place identities are `geoapify:`-backed. Raw IDs need not
   be exposed in the end-user UI.
8. Do not require a warning, partial, or empty state in the live presentation
   unless Heba or Balsam first records a reproducible final-runtime case. Until
   then, present those states only from accepted QA evidence.

### 30–60 second technical explanation

Flutter sends the supported Istanbul request to the public ASP.NET Backend;
it never calls Geoapify or FastAPI directly. The Backend owns the server-side
Geoapify key and the Fatih-bounded provider integration. It normalizes eligible
records into canonical candidates, applies category mapping and canonical-ID
deduplication, then calls the provider-independent FastAPI `/plan` endpoint.
FastAPI runs the deterministic planner. The Backend validates the returned
selection, enriches it from its candidate lookup, and returns the itinerary to
Flutter. Request IDs support technical correlation across this path; they are
verification evidence rather than an end-user feature.

The demo must not claim authentication, accounts, database/cloud persistence,
budget prices, exact schedules, optimal routing, broad-city/global provider
coverage, destination recommendation, or an LLM feature.

## Known limitations

- Real-provider coverage is the Fatih-bounded pool for public destination
  `istanbul`; broader Istanbul, other cities, and global coverage are outside
  the final sprint scope.
- Public interests are `history` and `landmark`, mapped to `historic_site` and
  `monument` respectively.
- There is no authentication/account persistence or database/cloud-backed trip
  saving in this scope.
- Budget is disabled. The contracts provide no reliable price semantics, and
  unknown price must not be presented as free.
- The planner uses deterministic selection and distribution heuristics; it
  does not guarantee a globally optimal route or travel-time optimization.
- It does not produce exact visit schedules.
- Deduplication is deterministic for repeated canonical provider IDs. Records
  with different provider IDs are not fully resolved as one physical place;
  PR #24's fresh sample intentionally preserves such a same-name pair.
- Optional provider metadata can be absent and is not fabricated. The public
  planning contract uses the established canonical fields.
- Geoapify and FastAPI are external runtime dependencies. Availability,
  timeout, malformed responses, and provider/service failures can prevent plan
  generation; the Backend is expected to return controlled failures without a
  hidden fixture success.
- Open security/config hardening items remain owner-verification work until
  Sami's final sign-off: provider-base allowlisting, a local Backend response
  cap, Backend request-ID bounds, stricter startup timeout/base-URL validation,
  and explicit root `.env` ignore/hygiene. These are engineering controls, not
  product features. Their final accepted/open state must come from Sami.

## Exact remaining dependencies

1. Ahmad reviews PR #24 head `300e9809...` and its four fresh artifacts without
   taking over Asma's work; normal merge/disposition follows that review.
2. Heba supplies final Flutter analyze/test/build, device or emulator smoke,
   and real-Backend E2E evidence tied to release SHA.
3. Balsam supplies independent RC QA evidence, issue results, and final
   Blocker/Critical count.
4. Sami supplies the deployed security/config retest, accepted/open hardening
   status, final Blocker/Critical count, and sign-off.
5. Ahmad reconciles every owner artifact to the exact release SHA and then,
   only if all required gates pass, signs Card 15 and marks Stage 3/release
   readiness accordingly.
