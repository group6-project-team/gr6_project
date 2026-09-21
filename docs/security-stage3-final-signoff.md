# Stage 3 final security, secrets and configuration sign-off

**Owner:** Sami Thaalba
**Review date:** 21 September 2026
**Final repository SHA reviewed and locally tested:** `bf24a7e9c9fc1a9fba61a0f31938561cb4eba074`
**Deployed runtime SHA retested:** `664dfa726629c47fbd12c5ca6e7c43f54b95291f`

## Gate conclusion

**PASS for the card's security gate: 0 unresolved security Blocker/Critical findings.** The deployed public Backend is genuinely Geoapify-backed, returns canonical `geoapify:` IDs, preserves request IDs, and returns controlled public errors. The repository and history scan found no committed real provider key or other recognized credential. Two new Medium findings and the previously recorded Medium configuration/correlation actions remain open with the Backend/deployment owner; they are explicit follow-ups and are not silently accepted.

The deployed runtime is `664dfa7`. Later main `bf24a7e` adds evidence/documentation and is the final integrated repository state reviewed here. Runtime source at `bf24a7e` is unchanged from the deployed implementation, so local regressions were run at `bf24a7e` and public post-deployment checks were run against `664dfa7`.

## Final evidence

Environment: Windows native; .NET SDK 10.0.301; Python 3.14.3; local FastAPI at `127.0.0.1:8000`; public Backend `https://gr6-tripplanning-api.runasp.net/`; public FastAPI `https://gr6-planning-service.onrender.com/`.

| Check | Evidence | Result |
|---|---|---|
| Backend regression | `dotnet test Backend/Backend.slnx --configuration Release --no-restore --nologo` with local FastAPI running | **57 passed** |
| FastAPI/planner regression | `python -m pytest ai-ml/service/tests ai-ml/planning/tests -q` | **117 passed**, 5 deprecation warnings |
| Live provider path | Public history, landmark and no-interest requests | **200**; canonical `geoapify:` IDs; 3 balanced days; no secret/provider URL leakage |
| Public validation errors | Unsupported destination and malformed JSON | **400** controlled validation bodies; no stack trace, key or raw provider URL |
| Correlation | Supplied valid request IDs on live requests | Exact `X-Request-ID` echoed by Backend; FastAPI health returned a generated request ID |
| Failure behavior | Provider HTTP failure test and planning exception middleware | Controlled **503 `PLANNING_SERVICE_UNAVAILABLE`**; no fixture/mock success |
| NuGet advisory check | Backend direct and transitive packages | No known vulnerable package reported by configured sources |
| Python advisory check | `pip-audit` against `ai-ml/service/requirements-dev.txt` | No known vulnerabilities found |
| Secret scan | History-aware scan of fetched refs | 447 unique blobs checked; matches were code variable assignments, test markers or `YOUR_API_KEY` placeholders; no literal real credential/private key/common token found |

The repository's `scripts/post-deploy-verify.ps1` failed locally during its FastAPI health step because of a PowerShell response/null-handling issue. Equivalent direct HTTPS checks were completed successfully for health, three Geoapify-backed planning requests, unsupported destination and malformed JSON. The script issue affects reproducibility of the helper, not the observed deployed security behavior.

## Verification status

| Area / previous finding | Status | Evidence / action |
|---|---|---|
| `GEOAPIFY_API_KEY` server-side only; absent from Flutter/Git | **Verified** | Runtime reads the key only from Backend configuration. Flutter contains no provider key/reference. History scan found no real key. |
| Secrets in logs, public URLs, errors, screenshots or committed artifacts | **Verified** | Provider application logs omit URI/body/key; built-in provider HTTP logging is removed; public errors are generic. Committed raw evidence contains public landmark/attribution/image URLs only, with no query credential or internal host. |
| Explicit provider/planner timeouts and limits | **Verified with open hardening** | Deployment evidence records `GEOAPIFY_TIMEOUT=10` and `AI_SERVICE_TIMEOUT=10`. Provider request uses fixed `limit=20`; FastAPI `PLANNING_MAX_CANDIDATES` defaults to 500. Startup range validation remains open. |
| No hidden fixture fallback | **Verified** | `CANDIDATE_SOURCE_MODE` must be exactly `Fixture` or `Geoapify`; missing/unknown mode stops startup. Provider failures propagate to controlled errors and never select fixtures. |
| Production/development separation | **Verified** | Development configuration explicitly selects `Fixture`; deployed evidence explicitly records `Geoapify`. No key is stored in development settings. |
| Provider/planner failure paths | **Verified** | Missing key, unsupported destination, provider non-success, timeout/transport, malformed JSON and invalid provider shape use controlled exceptions. Planner defensive tests pass. |
| 2A-02 / Backend candidate bound | **Open; now Stage3-02** | Provider request asks for 20, but the Backend does not independently cap response bytes/features/candidates before parsing and forwarding. |
| 2A-03 / Backend request-ID normalization | **Open; retested** | A live 100-character request ID was accepted and echoed unchanged. Apply the shared 1–64 allowlist before trusting/logging/forwarding IDs. |
| 2A-04 / URL and timeout startup validation | **Open** | Current deployed values are explicit and appropriate, but the application still accepts arbitrary URL/timeout configuration without a bounded startup validator. |
| Provider-log request correlation | **Open; Low** | Public response and Backend-to-FastAPI correlation work, but `IGeoapifyClient` and provider log templates do not carry the Backend request ID. |

## Findings requiring owner follow-up

| ID | Boundary / risk | Severity | Owner | Suggested action | Verification method | Status |
|---|---|---|---|---|---|---|
| Stage3-01 | Backend configuration → Geoapify: `GEOAPIFY_BASE_URL` accepts any absolute URI, then the provider key is appended to that origin. Misconfiguration or a compromised configuration channel could disclose the key or select plaintext HTTP. | Medium | Backend / Mohammad; deployment owner | Enforce at startup the exact HTTPS Geoapify origin, expected port, no user-info and expected base path. Reject all alternatives. | Add startup/config tests for alternate host, `http`, port, user-info and path; retest the real provider request. | **Open** |
| Stage3-02 | Geoapify → Backend → FastAPI: `limit=20` is a remote request hint. Backend buffers/parses the full response and accumulates all eligible features with no response-byte or local result ceiling. | Medium | Backend / Mohammad | Bound response bytes before JSON materialization and cap provider features/candidates/category/string sizes no greater than the agreed planner limit. | Add exact-limit, over-return and oversized-body tests; verify rejection occurs before large allocation/serialization. | **Open** |
| Stage3-03 | Public request → provider diagnostics: provider logs lack the Backend request ID, weakening investigation of provider failures. | Low | Backend / Mohammad | Pass or scope the normalized request ID through the candidate/provider path and include it in concise log templates. | Trigger provider status/timeout/malformed-response cases and correlate one normalized ID across public response, Backend and FastAPI logs. | **Open** |

The two Medium Stage 3 findings require configuration/provider-path influence rather than ordinary control of a single public request. They do not create an unresolved Blocker/Critical at the tested release state, but they should be fixed and retested before treating the provider boundary as fully hardened.

## Final secret-scan interpretation

The history scan flagged strings such as `test-api-key`, `secret-key-that-must-not-be-logged`, `YOUR_API_KEY`, configuration reads such as `apiKey = ...`, and old login-field variable names. Manual review confirmed these are test values, placeholders or source-code identifiers, not real credentials. No tracked `.env`, private-key file or literal provider credential was found. External hosting secrets and access permissions were not readable from the repository and are not claimed verified.

## Card closeout

**Done:** Reviewed Stage 3 implementation and later Day-3 evidence through final main `bf24a7e`; retested deployed runtime `664dfa7`; verified live Geoapify-backed responses, safe public errors, explicit fixture/provider selection, dependency failures, configuration values, repository hygiene and dependency advisories. Recorded two new Medium findings and carried open items with owners and retest methods.

**Link or evidence:** `docs/security-stage3-final-signoff.md`; final repository SHA `bf24a7e9c9fc1a9fba61a0f31938561cb4eba074`; deployed runtime SHA `664dfa726629c47fbd12c5ca6e7c43f54b95291f`; 57 Backend tests; 117 Python tests; live public checks; 447-history-blob secret scan.

**Next:** Backend/deployment owners address Stage3-01, Stage3-02, Stage3-03 and the carried request-ID/config-validation actions. Sami retests those fixes at their final merged/deployed SHA.

**Blocked:** No security Blocker/Critical. Hosting-platform secret values, permissions and private logs were unavailable for direct inspection. Flutter device/build evidence remains owned by the mobile/release tracks.

**Dependency at risk:** Exact Geoapify-origin enforcement, local provider response bounds, Backend request-ID normalization, bounded startup configuration and provider-log correlation.

**Is the end-to-end flow at risk? Why?** The tested deployed path is operational and genuinely Geoapify-backed, with controlled public errors and no observed credential leakage. Residual Medium risk remains if provider configuration is redirected or the provider returns an oversized successful payload. These conditions are documented and assigned, with 0 unresolved Blocker/Critical at sign-off.
