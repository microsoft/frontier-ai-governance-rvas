# S2 Verify & Capture Evidence

## Verify
- [ ] `evidence/dspm-ai-findings.json` exists and documents findings or an empty result.
- [ ] The DLP policy exists with mode **TestWithoutNotifications**, **TestWithNotifications**, or equivalent simulation/test state.
- [ ] The policy targets only the intended AI workload scope.
- [ ] Purview Audit/eDiscovery search locations for AI prompts/responses are documented.
- [ ] IRM and Communication Compliance reviewers know the queue or policy where AI interaction alerts appear.

```powershell
Get-DlpCompliancePolicy -Identity "RVAS S2 - AI sensitive data DLP (simulation)" |
  Select-Object Name, Mode, State
# Mode should be TestWithoutNotifications or TestWithNotifications
```

## Capture evidence
```powershell
./scripts/Get-AISensitiveDataFindings.ps1 -OutFile ./evidence/dspm-ai-findings.json
Get-DlpCompliancePolicy -Identity "RVAS S2 - AI sensitive data DLP (simulation)" |
  ConvertTo-Json -Depth 8 |
  Set-Content -Path ./evidence/dlp-ai-simulation.deployed.json -Encoding utf8
```
Commit the DSPM findings export, deployed DLP export, policy match summary, and the approver/change record. These form the customer's dated data-governance record and feed S6 control-plane reconciliation.
