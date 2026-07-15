# S6 Runbook

> **Safety:** read-only reconciliation first. Any registry writes are a later, approved customer action.

## Pre-flight

- [ ] Agent 365 export path agreed.
- [ ] `../s1-identity/evidence/agent-inventory.json` exists or a customer-approved equivalent is identified.
- [ ] `evidence/` folder prepared for registry, reconciliation, and exit-score artifacts.
- [ ] S0 baseline scorecard/output available for comparison.
- [ ] A governance lead is assigned to approve the closeout and own the
  residual-gap backlog.

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
5. **Require the baseline-to-exit comparison.** Follow
   `assessment/exit-rescore.md`, including `compare.py`, and retain
   `evidence/maturity-lift.txt`. Do not close S6 with an exit score alone.
6. **Formalize closeout and residual gaps.** Complete
   `assessment/closeout-backlog.md` in the customer's approved records system.
   Record the comparison references, closeout decision, approver, and an owner,
   due date, and status for every remaining D0-D6 gap.
