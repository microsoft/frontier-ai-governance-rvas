# S3 Rollback

S3 is audit-first. This kit does not deploy runtime safety infrastructure. Rollback covers alerting changes and evidence retention; Content Safety / Prompt Shields rollback belongs to the Citadel Governance Hub change path.

## Defender plan / AI Threat Protection

If Defender pricing or AI Threat Protection was enabled during the session, revert using the same customer-approved change path used to enable it (Defender for Cloud portal, Azure CLI, or platform change record). Record the before/after state in `evidence/ai-threat-protection-status.md`.

## Evidence and exports

Evidence files are governance records. Delete them only if the customer chooses not to retain the workshop record:

```bash
rm -f ./evidence/defender-ai-recommendations.json \
  ./evidence/prompt-shield-result.json \
  ./evidence/gateway-proof-manifest.json \
  ./evidence/ai-threat-protection-status.md \
  ./evidence/citadel-runtime-safety.md
```

## Confirm rollback

- [ ] Defender AI Threat Protection / pricing state matches the customer's intended baseline.
- [ ] Defender XDR has no unexpected test alert stream continuing from S3.
