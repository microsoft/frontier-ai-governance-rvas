# S3 Verify & Capture Evidence

## Verify

- [ ] `evidence/deployment-output.json` records the Content Safety endpoint and resource ID, or deployment was intentionally skipped.
- [ ] `evidence/defender-ai-recommendations.json` exists and contains AI-related Defender posture findings or an empty result documented by the SOC.
- [ ] `evidence/ai-threat-protection-status.md` records AI Threat Protection status and Defender XDR routing.
- [ ] `evidence/prompt-shield-result.json` contains a Prompt Shield response from a customer-owned test string.
- [ ] Findings have owner, severity, due date, and next action.

## Capture evidence

```bash
./scripts/export_defender_ai_recommendations.sh ./evidence/defender-ai-recommendations.json
CONTENT_SAFETY_ENDPOINT="https://<account>.cognitiveservices.azure.com" \
  ./scripts/test_prompt_shield.sh ./evidence/prompt-shield-result.json
```

Commit the exported JSON, deployment output, and SOC status notes into `labs/s3-security-runtime/evidence/` when the customer wants the governance record retained.
