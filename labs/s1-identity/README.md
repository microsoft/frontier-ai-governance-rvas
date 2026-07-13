# S1 Takeaway Kit — Identity & Access

Governs AI agents as first-class Entra identities. All privileged actions are the
customer's; scripts default to read-only and report-only.

The live export scripts are customer-operated evidence capture. Their output is
ignored by Git and must remain in the customer's approved records system.

## Contents

```
scripts/
  Get-AgentIdentities.ps1            read-only inventory of agent identities + sponsors -> JSON
  Export-AgentConditionalAccess.ps1  export the deployed policy for evidence
policies/
  ca-agent-baseline.json             report-only CA policy targeting agent identities (fill group IDs)
  sponsor-register.csv               human sponsor per agent
pipelines/
  run_mock.py                        static safety check of the CA policy (report-only + break-glass)
evidence/                            ignored customer-captured inventory + deployed policy JSON
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
5. Hand the reviewed policy definition to the customer's approved change process. This kit intentionally does not create or remove tenant policy.
6. After the customer completes its change, `./scripts/Export-AgentConditionalAccess.ps1` captures evidence per `verify.md`.

Use the customer's approved change process to reverse a policy change.

<!-- Verified: static-only — PSScriptAnalyzer + JSON schema + mock pipeline in CI. Live execution is the customer's co-delivery step. -->
