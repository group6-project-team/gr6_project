\# State Machine, Versioning, Concurrency, TTL \& Restart Acceptance Cases



\*\*Owner:\*\* Balsam Hashem Ahmad Khaleel  

\*\*Baseline:\*\* `main@edd5cab05a3c4c66b2cdcb68af9ea5d5fa589750`  

\*\*Status:\*\* Planning before implementation



\---



\## Goal



Define the independent acceptance suite for:



\- Generate state creation

\- version transitions

\- failed mutation behavior

\- stale writes

\- concurrent writes

\- session isolation

\- TTL boundary behavior

\- restart behavior

\- zero hidden provider refresh



The QA oracle must validate externally observable state only.



It must not copy production state-management or mutation algorithms.



\---



\## Observable State



Track only fields visible through the public/testable contract:



\- `sessionId`

\- `version`

\- requested days

\- selected place IDs

\- pinned place IDs

\- warnings

\- timestamps relevant to expiry

\- request IDs where available

\- provider call count where observable

\- FastAPI call count where observable



\---



\## Core State Invariants



\### ST-01 — Initial Generate



After a successful initial Generate:



\- a session exists;

\- committed state exists;

\- version is exactly `1`.



Expected:



`Generate → v1`



\---



\### ST-02 — Successful Mutation



For any successful committed mutation:



\- state changes according to the mutation;

\- version increments exactly once.



Expected:



`vN → vN+1`



No version skip is allowed.



\---



\### ST-03 — Failed Mutation



For any failed mutation:



\- committed state remains unchanged;

\- version remains unchanged.



Expected:



`vN → vN`



\---



\### ST-04 — Atomic Commit



A mutation must either:



\- commit the complete accepted new state;



or



\- commit nothing.



Partial mutation state is invalid.



\---



\## Generate Cases



\### GEN-01 — Generate New Session



Input:



\- valid Generate request.



Verify:



\- request succeeds;

\- session ID is returned;

\- version = 1;

\- requested day count is preserved;

\- output satisfies global invariants.



Status:



`PLANNED`



\---



\### GEN-02 — Two Independent Generates



Run two independent Generate requests.



Verify:



\- separate session IDs;

\- each starts at version 1;

\- mutations to session A do not modify session B.



Status:



`PLANNED`



\---



\### GEN-03 — Failed Generate



Use a controlled invalid request or controlled dependency failure.



Verify:



\- no usable committed session state is created;

\- no hidden successful itinerary is returned.



Status:



`PLANNED`



\---



\## Version Cases



\### VER-01 — v1 to v2



1\. Generate successful state.

2\. Submit one valid mutation.



Verify:



\- initial version = 1;

\- new version = 2.



\---



\### VER-02 — Multiple Sequential Mutations



1\. Generate v1.

2\. Successful mutation → v2.

3\. Successful mutation → v3.

4\. Successful mutation → v4.



Verify every transition is exactly `+1`.



\---



\### VER-03 — Failed Mutation Does Not Increment



1\. Start at version N.

2\. Submit mutation expected to fail.



Verify:



\- response is controlled failure;

\- state remains at version N;

\- subsequent valid request using version N is still evaluated against unchanged state.



\---



\### VER-04 — Validation Failure Does Not Increment



Submit malformed or invalid mutation request.



Verify:



\- version does not increment;

\- committed state does not change.



\---



\## Stale Version Cases



\### STALE-01 — Single Stale Write



1\. Generate version 1.

2\. Commit valid mutation → version 2.

3\. Submit another mutation using version 1.



Invariant:



The stale request must not overwrite version 2 state.



Exact response/recovery semantics:



`BLOCKED\_P0 — conflict recovery`



\---



\### STALE-02 — Very Old Version



Create multiple successful versions.



Example:



`v1 → v2 → v3 → v4`



Submit request using v1.



Verify:



\- current committed state is not overwritten;

\- no hidden rollback occurs.



Exact public error semantics:



`BLOCKED\_P0`



\---



\### STALE-03 — Stale Failure Has No Side Effect



Record:



\- state before stale write;

\- version before stale write;

\- provider/FastAPI call counts where available.



Submit stale request.



Verify:



\- committed state unchanged;

\- version unchanged;

\- no unexpected provider refresh.



\---



\## Concurrency Cases



\### CONC-01 — Two Same-Version Writes



1\. Start at version N.

2\. Submit two valid mutation requests concurrently.

3\. Both requests use version N.



Required invariant:



Exactly one committed transition may occur.



Final committed version:



`N+1`



There must not be:



\- two independent commits;

\- `N+2` caused by both same-version requests;

\- mixed partial state.



The losing request behavior is:



`BLOCKED\_P0 — conflict recovery`



\---



\### CONC-02 — Same-Version Writes With Different Mutations



Use two different mutations against the same current version.



Verify:



\- only one accepted commit;

\- final state corresponds to exactly one accepted mutation;

\- no merged hybrid state is created accidentally.



\---



\### CONC-03 — Concurrent Reads and Writes



While one mutation executes, perform a read/state retrieval if supported.



Verify:



\- externally visible state is either previous committed state or final committed state;

\- no partial intermediate mutation state is exposed.



\---



\### CONC-04 — Session Isolation Under Concurrency



Create session A and session B.



Submit mutations to both concurrently.



Verify:



\- session A changes only A;

\- session B changes only B;

\- versions evolve independently.



\---



\## Atomicity Cases



\### ATOMIC-01 — Successful Mutation



Snapshot full observable state before mutation.



After success verify:



\- all expected mutation changes are present;

\- unrelated state remains valid;

\- version increments exactly once.



\---



\### ATOMIC-02 — Failed Mutation



Snapshot full observable state.



Trigger controlled mutation failure.



Verify exact equality for contract-significant committed state before/after failure.



\---



\### ATOMIC-03 — Concurrent Loser



For two same-version writes:



\- one write commits;

\- losing write must not leave partial side effects.



Exact loser response waits for P0 conflict policy.



\---



\## Session Isolation



\### SESSION-01 — Independent Version Counters



Generate A and B.



Expected:



\- A starts v1;

\- B starts v1.



Mutate A.



Expected:



\- A becomes v2;

\- B remains v1.



\---



\### SESSION-02 — Independent Pins



If pinning is implemented:



\- pin in A;

\- inspect B.



Verify B does not inherit A's pinned IDs.



\---



\### SESSION-03 — Independent Remove/Replace/Regenerate



Apply mutation to session A.



Verify session B remains byte-equivalent or semantically equivalent in all contract-significant state.



\---



\## TTL Acceptance Cases



The task references a 45-minute boundary.



Exact assertions remain blocked until the P0 expiry decision is approved.



\---



\### TTL-01 — Just Before Boundary



Create session at time T0.



Test at:



`T0 + 45 minutes - epsilon`



Record actual result.



Exact expected result:



`BLOCKED\_P0`



\---



\### TTL-02 — Exact Boundary



Test at exactly:



`T0 + 45 minutes`



Record result.



Exact expected result:



`BLOCKED\_P0`



\---



\### TTL-03 — Just After Boundary



Test at:



`T0 + 45 minutes + epsilon`



Record result.



Exact expected result:



`BLOCKED\_P0`



\---



\### TTL-04 — Read Does Not Silently Extend



If read-only state retrieval is available:



1\. Create session.

2\. Perform read before expiry.

3\. Continue to original TTL boundary.



Verify according to approved policy whether reads extend expiry.



Current status:



`BLOCKED\_P0`



QA must not choose this policy.



\---



\### TTL-05 — Mutation and Expiry



Perform a valid mutation before the boundary.



Determine whether successful mutation:



\- extends expiry;

\- preserves original expiry;

\- sets another expiry rule.



Current status:



`BLOCKED\_P0`



\---



\## Restart Cases



\### RESTART-01 — Restart With Existing Session



1\. Create active session.

2\. Record session ID and version.

3\. Restart Backend/state service.

4\. Reuse previous session/version.



Task target mentions:



`410`



However exact expected response remains:



`BLOCKED\_P0 — expiry/restart decision`



Invariant that can already be required:



\- no silent reconstruction;

\- no fake-success response;

\- no unnoticed provider refresh restoring prior state.



\---



\### RESTART-02 — New Session After Restart



After restart:



\- create a new session;

\- verify normal Generate still works;

\- verify new session version starts at 1.



\---



\### RESTART-03 — Old and New Session Separation



After restart:



\- old state follows approved gone/expired behavior;

\- new state behaves normally.



\---



\## Zero Provider Refresh Cases



Where the mutation is state-only, provider calls must be observed.



\### ZR-01 — Rejected Stale Write



Expected provider refresh:



`0`



unless contract explicitly requires otherwise.



\---



\### ZR-02 — Validation Failure



Expected provider refresh:



`0`



\---



\### ZR-03 — Losing Same-Version Concurrent Write



Expected provider refresh:



`0`



if version conflict is rejected before provider work.



If implementation architecture differs, record behavior and compare with approved contract.



\---



\### ZR-04 — Pin Existing Place



Expected provider refresh:



`0` if pin is confirmed as state-only.



Current status:



`P0 / contract dependent`



\---



\### ZR-05 — Remove Existing Place



Expected provider refresh:



`0` if remove is confirmed as state-only.



Current status:



`P0 / contract dependent`



\---



\### ZR-06 — Replace



Provider refresh expectation:



`BLOCKED\_P0`



\---



\### ZR-07 — Regenerate



Provider refresh expectation:



`BLOCKED\_P0`



\---



\## Evidence Format



For every executed state case capture:



\- Case ID

\- exact RC SHA

\- environment

\- request/session ID

\- starting version

\- ending version

\- sanitized input

\- expected invariant

\- actual result

\- before-state digest

\- after-state digest

\- provider call count

\- FastAPI call count

\- PASS / FAIL

\- defect reference

\- retest status



Never store:



\- API keys

\- raw tokens

\- credentials

\- secret provider URLs containing sensitive query parameters



\---



\## Normalized State Digest



For concurrency/atomicity checks, create a normalized digest from contract-significant state only.



Include where applicable:



\- session ID

\- version

\- requested days

\- day/place IDs

\- pinned IDs

\- warnings



Exclude:



\- timestamps not part of contract;

\- trace IDs;

\- request IDs;

\- logging metadata;

\- transport headers.



\---



\## Required Negative Controls



\### NEG-STATE-01 — Illegal Version Jump



Construct controlled QA evidence/result with:



`v1 → v3`



Expected checker result:



`FAIL`



Reason:



`successful mutation must increment version exactly +1`



\---



\### NEG-STATE-02 — Failed Mutation Changes Version



Construct controlled failed mutation result where version increments.



Expected:



`FAIL`



\---



\### NEG-STATE-03 — Session Leak



Inject session B state with an ID from session A.



Expected:



`FAIL`



\---



\### NEG-STATE-04 — Double Commit



Simulate two same-version writes both marked committed.



Expected:



`FAIL`



\---



\## Machine-Readable Result Example



```json

{

&#x20; "caseId": "CONC-01",

&#x20; "startVersion": 4,

&#x20; "requests": 2,

&#x20; "sameVersion": true,

&#x20; "committedWrites": 1,

&#x20; "finalVersion": 5,

&#x20; "checks": {

&#x20;   "oneCommitOnly": true,

&#x20;   "versionPlusOne": true,

&#x20;   "noPartialState": true,

&#x20;   "sessionIsolation": true

&#x20; },

&#x20; "status": "PASS"

}



Current Status



Baseline:



edd5cab05a3c4c66b2cdcb68af9ea5d5fa589750



Prepared before production implementation:



Generate/version rules defined.

Failed mutation invariants defined.

stale-version tests defined.

same-version concurrency tests defined.

atomicity tests defined.

session isolation tests defined.

45-minute TTL boundary cases prepared.

restart cases prepared.

zero-refresh cases prepared.

negative controls defined.



Still blocked:



exact conflict recovery;

exact TTL boundary semantics;

restart response semantics;

TTL extension rules;

some provider-refresh rules.



Execution Status: NOT READY

