# S3 Takeaway Kit — Security Posture & Runtime

Builds an audit-first security baseline for AI workloads: Defender for Cloud AI-SPM
exports, AI Threat Protection status capture, direct Content Safety component
evidence, and optional Prompt Shields gateway-path smoke tests.

This kit does not deploy runtime safety infrastructure. Content Safety / Prompt Shields are owned by Citadel Governance Hub; RVAS verifies and captures evidence from that path.

The live export and non-production test scripts are customer-operated evidence
capture. Their output is ignored by Git and must remain in the customer's
approved records system.

## Contents

```
scripts/
  test_prompt_shield.sh       calls Content Safety Prompt Shields directly for component evidence
  test_gateway_prompt_shield.sh parameterized customer-operated gateway smoke-test adapter
  export_defender_ai_recommendations.sh read-only Defender AI recommendation export
policies/
  content-safety-runtime-baseline.json   runtime safety baseline placeholders
  defender-ai-assessment-export-template.json Defender evidence schema/template
pipelines/
  run_mock.py                 static safety/config validation, no network
evidence/                     ignored customer-captured output, exports, Prompt Shield results
runbook.md  rollback.md  verify.md
```

## Prerequisites

- Azure CLI logged in to the customer subscription.
- Security/SOC permissions for Defender for Cloud exports.
- AI Hub Gateway / Citadel Governance Hub deployed, with an approved non-production
  gateway route, authentication method, and Prompt Shields / Content Safety
  configuration available.
- A customer-owned non-production test endpoint/string for runtime checks.

## Run order

1. Capture the Citadel Governance Hub gateway endpoint, route/access-contract
   reference, and Content Safety / Prompt Shields configuration.
2. Export Defender AI recommendations:
   ```bash
   ./scripts/export_defender_ai_recommendations.sh ./evidence/defender-ai-recommendations.json
   ```
3. Optionally test the Content Safety component directly. This does **not** prove
   a request traversed the gateway:
   ```bash
   CONTENT_SAFETY_ENDPOINT="https://<account>.cognitiveservices.azure.com" \
     ./scripts/test_prompt_shield.sh ./evidence/prompt-shield-result.json
   ```
4. For gateway-path proof, the customer supplies the approved route and
   credential through its secure operating process, plus safe references for
   the platform records. The adapter writes a normalized manifest only; it does
   not write the gateway response, prompt, document, endpoint, or credential:
   ```bash
   GATEWAY_ENDPOINT="https://<customer-gateway-host>" \
   GATEWAY_PATH="/<approved-prompt-shield-route>?api-version=<approved-version>" \
   GATEWAY_ENVIRONMENT="<customer-nonproduction-environment>" \
   GATEWAY_AUTH_HEADER_VALUE="<customer-operated-credential>" \
   GATEWAY_REFERENCE="platform-record:gateway-np" \
   ACCESS_CONTRACT_REFERENCE="contract-record:approved-route" \
   BACKEND_REFERENCE="backend-record:content-safety-np" \
   POLICY_REFERENCE="policy-record:prompt-shields-v1" \
   EXPECTED_BEHAVIOR="Approved gateway route returns a recorded result" \
   REQUEST_EVIDENCE_REFERENCE="change-record:request-window" \
   TELEMETRY_EVIDENCE_REFERENCE="telemetry-record:proof-query" \
   ./scripts/test_gateway_prompt_shield.sh ./evidence/gateway-proof-manifest.json
   ```
5. The platform owner reviews the customer telemetry with the printed proof ID,
   then updates the manifest review state and evidence references according to
   the customer records policy. Capture evidence per `verify.md`; rollback per
   `rollback.md` if needed.

The gateway adapter neither deploys nor configures Citadel. For the platform
acceptance criteria and proof manifest, use
[`docs/delivery/platform-foundation/`](../../docs/delivery/platform-foundation/).
Do not commit raw component responses, prompts, documents, endpoint values, or
credentials to the takeaway kit.

<!-- Verified: static-only — ruff + py_compile + JSON/config invariants. Live execution is the customer's co-delivery step. -->
