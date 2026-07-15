# S3 Verify & Capture Evidence

## Verify

- [ ] `evidence/citadel-runtime-safety.md` records the Citadel gateway endpoint,
  route/access-contract reference, Content Safety / Prompt Shields configuration,
  platform owner, and the customer evidence-manifest reference.
- [ ] `evidence/defender-ai-recommendations.json` exists and contains AI-related Defender posture findings or an empty result documented by the SOC.
- [ ] `evidence/ai-threat-protection-status.md` records AI Threat Protection status and Defender XDR routing.
- [ ] `evidence/prompt-shield-result.json`, if present, is labelled as direct
  Content Safety component evidence rather than gateway-path proof.
- [ ] `evidence/gateway-proof-manifest.json`, when gateway validation is in
  scope, has schema version `1.0`, the printed proof ID, an environment label,
  gateway/access-contract/backend/policy references, expected behavior,
  request and telemetry evidence references, and result/review states.
- [ ] The gateway manifest contains no raw response body, prompt, document,
  endpoint value, credential, or token.
- [ ] Findings have owner, severity, due date, and next action.

## Capture evidence

```bash
./scripts/export_defender_ai_recommendations.sh ./evidence/defender-ai-recommendations.json
CONTENT_SAFETY_ENDPOINT="https://<account>.cognitiveservices.azure.com" \
  ./scripts/test_prompt_shield.sh ./evidence/prompt-shield-result.json

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

Retain only the normalized manifest, Citadel runtime safety note, and SOC status
references in the approved governance record. Keep raw component responses and
gateway traces in the customer's separately approved systems; do not commit
credentials, tokens, endpoints, prompts, documents, or raw response content.
