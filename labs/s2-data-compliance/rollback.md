# S2 Rollback

This kit makes no tenant changes.

## Customer-owned policy changes
If the customer independently creates the reviewed simulation/test policy, its approved change process owns reversal and confirmation. The policy must remain in simulation/test mode until that process completes.

## DSPM exports and evidence
DSPM findings, audit searches, and evidence files are read-only artifacts — nothing to revert in the tenant. The repository ignores live evidence output; discard it only if the customer's records policy allows it.

## Confirm removal
```powershell
Get-DlpCompliancePolicy -Identity "RVAS S2 - AI sensitive data DLP (simulation)" -ErrorAction SilentlyContinue
# should return nothing
```
