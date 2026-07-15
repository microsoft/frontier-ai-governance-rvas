# S3 Runbook

> **Safety:** report-only / audit-first. Defender and Content Safety checks must alert or record only; runtime tests target a customer-owned non-production endpoint/string.

## Track A - Defender for Cloud

- [ ] Change window + approver agreed.
- [ ] Security/SOC notified and triage owner named.
- [ ] `rollback.md` open.

1. **Verify Defender AI-SPM visibility.** In Defender for Cloud, confirm AI workloads appear in the AI Security Posture Management inventory / AI-BOM, or document that no AI workloads are discovered yet.
2. **Export recommendations read-only.**
   ```bash
   ./scripts/export_defender_ai_recommendations.sh ./evidence/defender-ai-recommendations.json
   ```
3. **Enable or stage AI Threat Protection alerts.** Use Defender for Cloud / CLI / portal steps approved by the customer. Confirm alerts route to Defender XDR. Do not configure blocking or production disruption during S3.

## Track B - Citadel runtime safety

Run this track only when the AI Hub Gateway / Citadel path, an approved
non-production gateway route, Content Safety configuration, and a
customer-owned non-production string are available. Otherwise record the track
as blocked and proceed with Track A.

1. **Confirm runtime safety.** Capture the gateway endpoint, route/access-contract
   reference, Prompt Shields configuration, and platform owner in evidence.
2. **Optionally test the Content Safety component directly.** This confirms the
   component response only; it is not gateway-path proof.
   ```bash
   CONTENT_SAFETY_ENDPOINT="https://<account>.cognitiveservices.azure.com" \
     ./scripts/test_prompt_shield.sh ./evidence/prompt-shield-result.json
   ```
3. **Run the gateway smoke-test adapter.** The customer provides the approved
   route and credential through its secure operating process, together with
   safe platform-record references. The adapter suppresses the raw response
   and writes a normalized manifest only.
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
4. **Review and triage.** The platform owner correlates the proof ID with the
   customer telemetry, updates `review.state` and the evidence references, and
   assigns owners and due dates to findings. Promotion from alert-only to
   enforcement is a later customer-owned change. Do not retain raw response
   bodies, prompts, documents, endpoint values, or credentials in this kit.
