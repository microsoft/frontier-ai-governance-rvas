# S2 Rollback

Every S2 tenant change is reversible with **no blocking impact** because the DLP policy is simulation/test only.

## Remove the DLP simulation policy
```powershell
./scripts/Remove-AIDataLossPreventionPolicy.ps1 -DisplayName "RVAS S2 - AI sensitive data DLP (simulation)"
```
The script finds the policy by display name and deletes it.

## DSPM exports and evidence
DSPM findings, audit searches, and evidence files are read-only artifacts — nothing to revert in the tenant. Discard local evidence only if your records policy allows it.

## Confirm removal
```powershell
Get-DlpCompliancePolicy -Identity "RVAS S2 - AI sensitive data DLP (simulation)" -ErrorAction SilentlyContinue
# should return nothing
```
