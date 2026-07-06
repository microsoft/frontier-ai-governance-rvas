# S3 Runbook

> **Safety:** report-only / audit-first. Defender and Content Safety checks must alert or record only; runtime tests target a customer-owned non-production endpoint/string.

## Pre-flight

- [ ] Change window + approver agreed.
- [ ] Security/SOC notified and triage owner named.
- [ ] Target subscription and resource group confirmed.
- [ ] Non-production test endpoint/string approved.
- [ ] `rollback.md` open.

## Steps

1. **Review Azure-plane deployment.** Replace placeholders in `infra/main.parameters.json`. Keep `enableDefenderAiPricing` explicit; if the customer prefers portal enablement, leave it `false` and record the manual step.
2. **Preview or deploy Content Safety.**
   ```bash
   az deployment sub what-if --location westeurope \
     --template-file infra/main.bicep \
     --parameters @infra/main.parameters.json
   ```
3. **Verify Defender AI-SPM visibility.** In Defender for Cloud, confirm AI workloads appear in the AI Security Posture Management inventory / AI-BOM, or document that no AI workloads are discovered yet.
4. **Export recommendations read-only.**
   ```bash
   ./scripts/export_defender_ai_recommendations.sh ./evidence/defender-ai-recommendations.json
   ```
5. **Enable or stage AI Threat Protection alerts.** Use Defender for Cloud / CLI / portal steps approved by the customer. Confirm alerts route to Defender XDR. Do not configure blocking or production disruption during S3.
6. **Connect Content Safety / Prompt Shields where required.** Capture any portal-only or Graph-only connection steps in `evidence/ai-threat-protection-status.md`.
7. **Run Prompt Shield test.**
   ```bash
   CONTENT_SAFETY_ENDPOINT="https://<account>.cognitiveservices.azure.com" \
     ./scripts/test_prompt_shield.sh ./evidence/prompt-shield-result.json
   ```
8. **Triage.** Assign owners and due dates to posture findings. Promotion from alert-only to enforcement is a later customer-owned change.
