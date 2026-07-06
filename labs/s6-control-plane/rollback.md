# S6 Rollback

S6 is read-only by default. Registry exports, reconciliation reports, and scorecards are local evidence documents.

## Read-only artifacts

To roll back documents, remove or supersede the affected files in `evidence/`:

```bash
rm labs/s6-control-plane/evidence/agent-registry.json
rm labs/s6-control-plane/evidence/reconciliation-report.json
rm labs/s6-control-plane/evidence/exit-scorecard.csv
```

## Optional registry writes

If the customer later updates Agent 365 owner, lifecycle, or access metadata, record the pre-change export first. Revert by restoring the previous field values from that export using the current Agent 365 admin UI or supported Graph/PowerShell API.
