\# Stage 2B — Integrated Output QA



\*\*Owner:\*\* Balsam Hashem Ahmad Khaleel  

\*\*Track:\*\* AI / ML Evaluation  

\*\*Branch:\*\* `test/stage2b-integrated-output-qa`  

\*\*Baseline main SHA:\*\* `dd72cc1313387908c51b497ee97b8167650e429a`



\## Objective



Independently validate the actual integrated trip-planning outputs without copying planner internals or modifying production code.



Stage 2B extends the earlier planner-level evaluation to the real integration path:



`Mobile Request -> Backend /trip-plans/preview -> FastAPI -> Planner -> Backend Response -> Mobile`



Backend-only evidence is not sufficient to declare Stage 2B GREEN. Final integrated execution also requires the explicit fixture/source configuration and real Flutter/runtime evidence.



\## Required QA Coverage



Stage 2B will check, where applicable:



\- No interests

\- With interests

\- Normal itinerary

\- Partial itinerary

\- Empty itinerary

\- `D=1`

\- `D=14`

\- `E > 3D`

\- Determinism



For each applicable integrated output, the independent checks verify:



\- `N = min(E, 3D)`

\- Exactly `D` days

\- Day numbers are exactly `1..D`

\- Expected `q/r` capacity distribution

\- Maximum 3 places per day

\- Selected place IDs are a subset of the candidate source

\- No duplicate selected place IDs

\- Correct warning semantics

\- Deterministic output for repeated identical requests



\## Existing Independent Baseline



The existing planner-level evaluation already covers:



\- Normal

\- Selection limit / `E > 3D`

\- Partial

\- Empty

\- No interests

\- Determinism

\- `D=1`

\- `D=14`

\- Independent invariant validation

\- Expected-invalid negative control



These results remain useful baseline evidence, but they do not replace Stage 2B integrated-output evidence.



\## Current Integrated Contract Findings



The public Backend endpoint is:



`POST /trip-plans/preview`



The current integrated path uses `RealTripPreviewService`, which constructs candidate places before calling the planning service.



Current candidate sets observed on the tested baseline:



\- `istanbul`: 9 candidates

\- `rome`: 2 candidates

\- `aqaba`: 0 candidates



The mobile-facing response uses:



\- `days\[].dayNumber`

\- `days\[].places\[].id`

\- `warnings\[].code`



The existing independent checker uses:



\- `days\[].day`

\- `days\[].placeIds`

\- warning code strings



Stage 2B may therefore use a QA-only normalization adapter to map the integrated response shape into the independent checker shape. This adapter must only normalize the contract representation; it must not reproduce planner selection or distribution logic.



\## Interests Limitation



`TripPlanPreviewRequest` supports `Interests`, and the Backend validates supported interest values.



However, on the tested baseline, `RealTripPreviewService` currently creates an empty canonical interest list instead of forwarding the request interests to the planner.



Therefore, a true integrated \*\*with-interests\*\* case is not yet considered verified.



This limitation must not be worked around by modifying production code as part of AI/ML evaluation.



\## Evidence Required Before GREEN



Final Stage 2B evidence must record:



\- Exact tested Git SHA

\- Exact candidate/fixture source and configuration

\- Requests used for each case

\- Actual integrated responses

\- Independent checker results

\- Determinism comparison

\- Negative-control result

\- Backend/FastAPI runtime evidence

\- Real Flutter/mobile runtime evidence

\- Exact commands used



Stage 2B must not be declared GREEN from Backend-only proof.



\## Constraints



\- Do not copy planner internals into the checker.

\- Do not weaken existing invariants.

\- Do not modify production code for the purpose of making QA pass.

\- Retain valid negative controls.

\- Do not claim unexecuted cases as PASS.

\- Do not use production Geoapify until Stage 2B is GREEN and the required handoff is ready.



\## Current Status



\*\*Stage 2B: PREPARATION / WAITING FOR FULL INTEGRATED EVIDENCE\*\*



Independent QA preparation can proceed now.



Final integrated execution remains dependent on:



1\. An explicit fixture/candidate-source path and configuration for the Stage 2B run.

2\. Real Flutter/mobile runtime evidence.



No final Stage 2B GREEN claim has been made.

