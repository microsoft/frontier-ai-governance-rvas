# S1 Rollback

Every S1 change is reversible with **no user impact** (the policy is report-only).

## Remove the Conditional Access policy
```powershell
./scripts/Remove-AgentConditionalAccess.ps1 -DisplayName "RVAS S1 - Agent baseline (report-only)"
```
The script finds the policy by display name and deletes it. Because it never enforced anything, deletion changes no sign-in outcomes.

## Inventory & sponsor register
These are read-only exports/documents — nothing to revert in the tenant. Discard the files locally if needed:
```bash
git checkout -- labs/s1-identity/evidence/ labs/s1-identity/policies/sponsor-register.csv
```

## Confirm removal
```powershell
Get-MgIdentityConditionalAccessPolicy -All |
  Where-Object DisplayName -eq "RVAS S1 - Agent baseline (report-only)"
# should return nothing
```
