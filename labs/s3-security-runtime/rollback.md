# S3 Rollback

S3 is audit-first. Rollback removes staged resources or alerting changes and should not affect production traffic unless controls were promoted outside the workshop.

## Content Safety account

If the account was created only for S3 and is not needed:

```bash
az cognitiveservices account delete \
  --name "<content-safety-account-name>" \
  --resource-group "<resource-group-name>" \
  --yes
```

## Defender plan / AI Threat Protection

If Defender pricing or AI Threat Protection was enabled during the session, revert using the same customer-approved change path used to enable it (Bicep parameter, Defender for Cloud portal, or Azure CLI). Record the before/after state in `evidence/ai-threat-protection-status.md`.

## Evidence and exports

Evidence files are governance records. Delete them only if the customer chooses not to retain the workshop record:

```bash
rm -f ./evidence/defender-ai-recommendations.json \
  ./evidence/prompt-shield-result.json \
  ./evidence/ai-threat-protection-status.md
```

## Confirm rollback

- [ ] Content Safety account is removed or explicitly retained.
- [ ] Defender AI Threat Protection / pricing state matches the customer's intended baseline.
- [ ] Defender XDR has no unexpected test alert stream continuing from S3.
