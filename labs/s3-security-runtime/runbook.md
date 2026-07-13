# S3 Runbook

> **Safety:** report-only / audit-first. Defender and Content Safety checks must alert or record only; runtime tests target a customer-owned non-production endpoint/string.

## Pre-flight

- [ ] Change window + approver agreed.
- [ ] Security/SOC notified and triage owner named.
- [ ] AI Hub Gateway / Citadel Governance Hub endpoint and runtime safety owner confirmed.
- [ ] Content Safety / Prompt Shields configuration is available from the Citadel deployment.
- [ ] Non-production test endpoint/string approved.
- [ ] `rollback.md` open.

## Steps

1. **Confirm Citadel runtime safety.** Capture the AI Hub Gateway / Citadel Governance Hub endpoint, the Content Safety / Prompt Shields configuration, and the named platform owner in evidence.
2. **Verify Defender AI-SPM visibility.** In Defender for Cloud, confirm AI workloads appear in the AI Security Posture Management inventory / AI-BOM, or document that no AI workloads are discovered yet.
3. **Export recommendations read-only.**
   ```bash
   ./scripts/export_defender_ai_recommendations.sh ./evidence/defender-ai-recommendations.json
   ```
4. **Enable or stage AI Threat Protection alerts.** Use Defender for Cloud / CLI / portal steps approved by the customer. Confirm alerts route to Defender XDR. Do not configure blocking or production disruption during S3.
5. **Connect Content Safety / Prompt Shields where required through Citadel.** Capture any portal-only or Graph-only connection steps in `evidence/ai-threat-protection-status.md`.
6. **Run Prompt Shield test through the Citadel runtime safety path.**
   ```bash
   CONTENT_SAFETY_ENDPOINT="https://<account>.cognitiveservices.azure.com" \
     ./scripts/test_prompt_shield.sh ./evidence/prompt-shield-result.json
   ```
7. **Triage.** Assign owners and due dates to posture findings. Promotion from alert-only to enforcement is a later customer-owned change.
