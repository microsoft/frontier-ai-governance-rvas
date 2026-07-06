# S2 Takeaway Kit — Data & Compliance

Governs AI-agent data exposure with Microsoft Purview. All privileged actions are
the customer's; scripts default to read-only and simulation/test mode.

## Contents

```
scripts/
  Get-AISensitiveDataFindings.ps1       read-only DSPM for AI findings export -> JSON
  New-AIDataLossPreventionPolicy.ps1    create a SIMULATION/TEST DLP policy (refuses enforce mode)
  Remove-AIDataLossPreventionPolicy.ps1 rollback: delete the simulation DLP policy
policies/
  dlp-ai-simulation.json                curriculum-template DLP policy (illustrative schema) in simulation/test mode
  dspm-ai-baseline.json                 exported-style DSPM for AI baseline config
pipelines/
  run_mock.py                           static safety check of policy JSON invariants
evidence/                               captured DSPM findings, DLP export, approver/change record
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
4. `./scripts/New-AIDataLossPreventionPolicy.ps1 -PolicyFile ./policies/dlp-ai-simulation.json`
5. Capture evidence per `verify.md` after the simulation policy bakes.

Rollback any time with `./scripts/Remove-AIDataLossPreventionPolicy.ps1`.

<!-- Verified: static-only — ruff + py_compile + JSON load + mock pipeline in CI. Live execution is the customer's co-delivery step. -->
