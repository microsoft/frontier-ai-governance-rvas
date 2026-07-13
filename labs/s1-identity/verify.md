# S1 Verify & Capture Evidence

## Verify
- [ ] `evidence/agent-inventory.json` exists and lists agent identities.
- [ ] Every inventoried agent has a sponsor in `policies/sponsor-register.csv`.
- [ ] The Conditional Access policy exists with state **report-only** and the break-glass group **excluded**.

```powershell
Get-MgIdentityConditionalAccessPolicy -All |
  Where-Object DisplayName -eq "RVAS S1 - Agent baseline (report-only)" |
  Select-Object DisplayName, State
# State should be: enabledForReportingButNotEnforced
```

## Capture evidence
```powershell
./scripts/Export-AgentConditionalAccess.ps1 -OutFile ./evidence/ca-agent-baseline.deployed.json
```
Commit `evidence/agent-inventory.json`, `evidence/ca-agent-baseline.deployed.json`, and the completed `policies/sponsor-register.csv`. These form the customer's dated identity-governance record and feed S6 (Agent 365 registry reconciliation).
