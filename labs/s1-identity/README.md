# S1 Takeaway Kit — Identity & Access

Governs AI agents as first-class Entra identities. All privileged actions are the
customer's; scripts default to read-only and report-only.

## Contents

```
scripts/
  Get-AgentIdentities.ps1            read-only inventory of agent identities + sponsors -> JSON
  New-AgentConditionalAccess.ps1     create a REPORT-ONLY CA policy (refuses non-report-only / placeholder)
  Export-AgentConditionalAccess.ps1  export the deployed policy for evidence
  Remove-AgentConditionalAccess.ps1  rollback: delete the report-only policy
policies/
  ca-agent-baseline.json             report-only CA policy targeting agent identities (fill group IDs)
  sponsor-register.csv               human sponsor per agent
pipelines/
  run_mock.py                        static safety check of the CA policy (report-only + break-glass)
evidence/                            captured inventory + deployed policy JSON
runbook.md  rollback.md  verify.md
```

## Prerequisites

- PowerShell 7+, `Install-Module Microsoft.Graph`.
- Customer admin with Conditional Access Administrator (or Security Administrator).
- A confirmed **break-glass** account/group, **excluded** from the policy.

## Run order

1. `./scripts/Get-AgentIdentities.ps1 -OutFile ./evidence/agent-inventory.json`
2. Fill `policies/sponsor-register.csv` for every inventoried agent.
3. Edit `policies/ca-agent-baseline.json`: set the agent-identity include group and the break-glass exclude group object IDs.
4. `python pipelines/run_mock.py`  *(offline safety check — must PASS)*
5. `./scripts/New-AgentConditionalAccess.ps1 -PolicyFile ./policies/ca-agent-baseline.json`
6. `./scripts/Export-AgentConditionalAccess.ps1` and capture evidence per `verify.md`.

Rollback any time with `./scripts/Remove-AgentConditionalAccess.ps1`.

<!-- Verified: static-only — PSScriptAnalyzer + JSON schema + mock pipeline in CI. Live execution is the customer's co-delivery step. -->
