# S5 Rollback

Adversarial testing does not deploy a production control, but it can create scan
artifacts, logs, alerts, and incident records.

## Stop an in-progress run

- Cancel the local process with the terminal interrupt key.
- For managed Tier A runs, stop the Foundry red-team job from the customer's
  project interface or CLI according to local operating procedure.

## Clean up local artifacts

Keep required governance evidence first. If the customer approves deletion of
local generated files, remove only S5 evidence artifacts:

```bash
rm -f evidence/asr-scorecard.json
```

## Endpoint and SOC de-brief

- Reset or disable the non-production endpoint if test configuration was changed.
- Confirm whether Defender/SOC alerts or incidents were raised.
- Annotate alerts as authorized red-team activity where appropriate.
- Record lessons learned, remediation owners, and any follow-up test date.
