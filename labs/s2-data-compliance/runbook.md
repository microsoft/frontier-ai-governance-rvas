# S2 Runbook

> **Safety:** report-only / audit-first. DLP is created in simulation/test mode only.

## Pre-flight
- [ ] Change window + approver agreed.
- [ ] Compliance/Data admin has Purview permissions.
- [ ] `rollback.md` open.
- [ ] Evidence folder agreed: `labs/s2-data-compliance/evidence/`.

## Steps
1. **Export DSPM for AI findings (read-only).**
   ```powershell
   ./scripts/Get-AISensitiveDataFindings.ps1 -OutFile ./evidence/dspm-ai-findings.json
   ```
2. **Prepare DLP simulation policy.** In `policies/dlp-ai-simulation.json`, replace tenant-specific placeholders for reviewer group, sensitive information type, and AI workload identifiers.
3. **Static safety check (offline).**
   ```bash
   python pipelines/run_mock.py
   ```
   Must print `PASS`.
4. **Create simulation/test DLP.**
   ```powershell
   ./scripts/New-AIDataLossPreventionPolicy.ps1 -PolicyFile ./policies/dlp-ai-simulation.json
   ```
5. **Bake and review.** Leave the policy in simulation/test mode while Purview collects matches.
6. **Verify + capture evidence** (see `verify.md`).
7. **Do not enforce during the session.** Promotion to enforce is a later, customer-owned change.
