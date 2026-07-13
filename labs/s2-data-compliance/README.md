# S2 Takeaway Kit — Data & Compliance

Governs AI-agent data exposure with Microsoft Purview. All privileged actions are
the customer's; scripts default to read-only and simulation/test mode.

The live export script is customer-operated evidence capture. Its output is
ignored by Git and must remain in the customer's approved records system.

## Contents

```
scripts/
  Get-AISensitiveDataFindings.ps1       read-only DSPM for AI findings export -> JSON
policies/
  dlp-ai-simulation.json                curriculum-template DLP policy (illustrative schema) in simulation/test mode
  dspm-ai-baseline.json                 exported-style DSPM for AI baseline config
pipelines/
  run_mock.py                           static safety check of policy JSON invariants
evidence/                               ignored DSPM findings, DLP export, approver/change record
runbook.md  rollback.md  verify.md
```

## Prerequisites

- PowerShell 7+, `Install-Module Microsoft.Graph`.
- Security & Compliance PowerShell available for DLP cmdlets.
- Customer admin with Compliance Administrator or Compliance Data Administrator.
- A named change window + approver; DLP starts in simulation/test mode only.

## Run order

1. `./scripts/Get-AISensitiveDataFindings.ps1 -OutFile ./evidence/dspm-ai-findings.json`
2. Edit `policies/dlp-ai-simulation.json`: set tenant, reviewer group, AI workload, and sensitive information type IDs.
3. `python pipelines/run_mock.py` *(offline safety check — must PASS)*
4. Hand the reviewed simulation policy definition to the customer's approved change process. This kit intentionally does not create or remove tenant policy.
5. Capture evidence per `verify.md` after the customer-created simulation policy bakes.

Use the customer's approved change process to reverse a policy change.

<!-- Verified: static-only — ruff + py_compile + JSON load + mock pipeline in CI. Live execution is the customer's co-delivery step. -->
