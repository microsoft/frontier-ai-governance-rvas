# S6 Runbook

> **Safety:** read-only reconciliation first. Any registry writes are a later, approved customer action.

## Pre-flight

- [ ] Agent 365 export path agreed.
- [ ] `../s1-identity/evidence/agent-inventory.json` exists or a customer-approved equivalent is identified.
- [ ] `evidence/` folder prepared for registry, reconciliation, and exit-score artifacts.
- [ ] S0 baseline scorecard/output available for comparison.

## Steps

1. **Export registry.**
   ```powershell
   ./scripts/Get-AgentRegistry.ps1 -OutFile ./evidence/agent-registry.json
   ```
2. **Collect S1 inventory.** Use `labs/s1-identity/evidence/agent-inventory.json` or a customer-approved equivalent. If it was not captured in S1, run `labs/s1-identity/scripts/Get-AgentIdentities.ps1` before proceeding.
3. **Reconcile offline.**
   ```bash
   python scripts/reconcile-registry.py \
     --registry evidence/agent-registry.json \
     --inventory ../s1-identity/evidence/agent-inventory.json
   ```
4. **Triage findings.** Assign owner, lifecycle state, and backlog action for shadow, unmanaged/OBO, and missing-sponsor findings.
5. **Re-score maturity.** Follow `assessment/exit-rescore.md` and capture score output.
6. **Hand off residual gaps.** Convert remaining D0-D6 gaps into the AI governance backlog.
