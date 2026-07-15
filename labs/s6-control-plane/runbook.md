# S6 Runbook — Read-only reconciliation and closeout

## Pre-flight

- [ ] The S0 baseline scorecard reference and the same S0 scorecard structure
  are available for the exit re-score.
- [ ] A customer-produced S1 normalized identity inventory is available using
  the S1 kit's explicit inventory schema.
- [ ] The customer has supplied a normalized control-plane registry using
  `rvas.s6.control-plane-registry.v1`, as illustrated by
  `data/agent-registry.sample.json`.
- [ ] A governance lead owns the closeout and residual-gap backlog.

## Customer-operated path

1. The customer produces its registry export using its supported product process,
   then normalizes it before it enters this kit. Each registry agent explicitly
   supplies `registryId`, `displayName`, `entraObjectId` (or `null`),
   `executionMode`, `managed`, `lifecycleState` (or `null`), and `sponsor` (or
   `null`). Do not map alternate fields or match by display name in this
   workshop.
2. Reconcile the normalized registry with the S1 inventory. This read-only
   command matches only registry `entraObjectId` to S1 `objectId`:
   ```bash
   python scripts/reconcile-registry.py \
     --registry evidence/control-plane-registry.json \
     --inventory ../s1-identity/evidence/agent-inventory.json \
     --out evidence/reconciliation-report.json
   ```
3. Triage shadow, registry-only, unmanaged/OBO, sponsor, and lifecycle
   findings. Assign an owner and action; do not write registry metadata here.
4. Follow [`assessment/exit-rescore.md`](assessment/exit-rescore.md) to produce
   the mandatory S0 baseline-to-exit comparison.

## Evidence and decision handoff

- [ ] The customer records references to the normalized registry, S1 inventory,
  reconciliation report, S0 baseline, S6 exit scorecard, and maturity-lift
  output in its approved records system.
- [ ] Every reconciliation and maturity finding has a decision, owner, due
  date, and status in
  [`assessment/closeout-backlog.md`](assessment/closeout-backlog.md).
- [ ] The governance lead records the closeout decision, approver, and next
  governance review. Customer registry changes, if any, use a separate
  approved change and rollback process.
