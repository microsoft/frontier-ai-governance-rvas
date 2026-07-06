# S1 Runbook

> **Safety:** report-only / audit-first. Confirm the break-glass exclusion before creating any policy.

## Pre-flight
- [ ] Break-glass account/group confirmed and its object ID recorded.
- [ ] Change window + approver agreed.
- [ ] `rollback.md` open.

## Steps
1. **Inventory (read-only).**
   ```powershell
   ./scripts/Get-AgentIdentities.ps1 -OutFile ./evidence/agent-inventory.json
   ```
2. **Sponsor register.** Record a human sponsor for each agent in `policies/sponsor-register.csv`. Flag any agent with no sponsor.
3. **Prepare policy.** In `policies/ca-agent-baseline.json`, replace:
   - `includeServicePrincipals` → the agent service principal object ID(s).
   - `excludeServicePrincipals` → the break-glass service principal object ID.
4. **Static safety check (offline).**
   ```bash
   python pipelines/run_mock.py
   ```
   Must print `PASS`.
5. **Create report-only.**
   ```powershell
   ./scripts/New-AgentConditionalAccess.ps1 -PolicyFile ./policies/ca-agent-baseline.json
   ```
6. **Verify + capture evidence** (see `verify.md`).
7. **Leave in report-only.** Impact review + any promotion to enforce is a later, customer-owned decision.
