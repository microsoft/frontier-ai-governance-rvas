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

Run this track only when the AI Hub Gateway / Citadel path, Content Safety configuration, and a customer-owned non-production string are available. Otherwise record the track as blocked and proceed with Track A.

1. **Confirm runtime safety.** Capture the endpoint, Prompt Shields configuration, and platform owner in evidence.
2. **Run Prompt Shield test.**
   ```bash
   CONTENT_SAFETY_ENDPOINT="https://<account>.cognitiveservices.azure.com" \
     ./scripts/test_prompt_shield.sh ./evidence/prompt-shield-result.json
   ```
3. **Triage.** Assign owners and due dates to posture findings. Promotion from alert-only to enforcement is a later customer-owned change.
