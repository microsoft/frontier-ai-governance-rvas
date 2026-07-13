# S6 Takeaway Kit — Control Plane & Operationalization

Turns the Agent 365 registry into an operational governance record and re-runs the S0 maturity assessment as the capstone exit score.

## Contents

```
scripts/
  Get-AgentRegistry.ps1       Tier A reference export of the Agent 365 registry -> JSON
  reconcile-registry.py       offline reconciliation: registry vs S1 inventory -> evidence JSON
data/
  agent-registry.sample.json  sample Agent 365-style registry export
  s1-agent-inventory.sample.json sample S1 Entra Agent ID inventory export
assessment/
  exit-rescore.md             how to copy S0 scorecard, rescore at S6, and compare lift
policies/
  lifecycle-states.json       allowed lifecycle states for registry reconciliation
pipelines/
  run_mock.py                 static offline check of the reconciliation invariants
evidence/                    registry export, reconciliation report, exit scorecard/output
runbook.md  rollback.md  verify.md
```

## Prerequisites

- Tier A: Microsoft Agent 365 available/licensed; Graph PowerShell installed for export.
- Tier B: S1 Entra Agent ID inventory and workshop inputs for a spreadsheet-based registry.
- Python 3.10+ for offline reconciliation and static validation.

## Run order

1. Export the registry or use the Tier B registry spreadsheet converted to JSON.
2. Copy the S1 inventory export into evidence, or point the script at the existing S1 file.
3. Run `python scripts/reconcile-registry.py` for the sample, or pass `--registry` and `--inventory` for customer evidence.
4. Review `evidence/reconciliation-report.json` for shadow, unmanaged/OBO, and missing-sponsor findings.
5. Follow `assessment/exit-rescore.md` to produce the S6 exit maturity score.
6. Capture evidence per `verify.md` and use `rollback.md` before any optional registry writes.

## Optional: Citadel Governance Hub evidence

If the customer has a pre-provisioned [AI Hub Gateway / Citadel Governance Hub (`citadel-v1`)](https://aka.ms/ai-hub-gateway), treat its API Center / Access Contract exports as adjacent **Layer 1** evidence. Capture the customer-provided export in `evidence/` and reference it in the reconciliation notes, but do not deploy the hub or change the reconciliation script during the S6 workshop.

This optional path is for Tier A environments only. Tier B remains the Agent 365-style registry sample plus S1 Entra Agent ID inventory sample.

<!-- Verified: static-only — Python compile/ruff, JSON parse, and mock reconciliation run. Live execution is the customer's co-delivery step. -->
