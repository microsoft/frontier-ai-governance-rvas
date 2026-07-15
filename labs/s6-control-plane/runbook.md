# S6 Runbook — Read-only reconciliation and closeout

Use this runbook with the visible [S6 co-delivery activity](../../docs/s6-control-plane/index.md).
The customer performs the operations; the facilitator timeboxes, asks
interpretation questions, and captures references and decisions. Do not store
raw customer records in this kit.

## Roles, timebox, and entry condition

- **Timebox:** 90 minutes: set the boundary (10 min), input-quality review
  (15 min), explicit normalization (15 min), reconciliation and triage
  (20 min), maturity-lift discussion (15 min), and closeout/cadence decision
  (15 min).
- **Customer activity owner:** supplies and normalizes customer data, then runs
  the command. **Evidence owner:** points to approved records. **Governance
  lead / decision owner:** assigns dispositions and accepts, defers, or rejects
  closeout. Identity, platform, maker, or Security/SOC specialists interpret
  relevant findings.
- **Entry condition:** the customer has an S0 baseline reference, its
  normalized S1 inventory, a candidate registry source, an approved records
  location, and a decision owner (or an agreed deferred-decision owner and
  date).

## Input-quality review and explicit normalization

- [ ] The S0 baseline scorecard reference and the same S0 scorecard structure
  are available for the exit re-score.
- [ ] A customer-produced S1 normalized identity inventory is available using
  the S1 kit's explicit inventory schema.
- [ ] The customer has supplied a normalized control-plane registry using
  `rvas.s6.control-plane-registry.v1`, as illustrated by
  `data/agent-registry.sample.json`.
- [ ] A governance lead owns the closeout and residual-gap backlog.

The customer verifies source provenance, date, scope, and accountable owner
before normalization. Unknown values stay `null` and become findings; do not
infer them from names, aliases, or a sample. The sample is a field-level
illustration, not customer evidence.

Facilitator prompts: “What source supports this field?” “What is unknown?”
“What is the expected reconciliation signal?” Stop if a required input is
missing or cannot be normalized without inference; record the dependency,
owner, date, and effect on closeout.

## Customer-operated reconciliation and triage

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
3. Interpret the report with the relevant specialist. Triage shadow,
   registry-only, unmanaged/OBO, sponsor, lifecycle, and invalid-lifecycle
   findings. Ask whether each is an input-quality issue, an ownership gap, or a
   separately governed change. A no-result is not a pass unless the checked
   scope and expected signal are recorded.
4. Assign every finding an owner, action, due date, and status; do not write
   registry metadata here. Registry, identity, lifecycle, or access changes
   must follow the customer's separate approved change, rollback, and
   verification process.
5. Follow [`assessment/exit-rescore.md`](assessment/exit-rescore.md) to produce
   the mandatory S0 baseline-to-exit comparison.

## Maturity lift, closeout, and operating cadence

Discuss the comparison with the governance lead: “What evidence supports a
score change?” “Which domains remain below target?” “What review cadence will
re-check reconciliation and residual gaps?” The lift is a decision input, not
proof that a control is deployed or operating.

Choose one: **close**, **close with owned gaps**, **defer**, or **do not close**.
The decision owner records the rationale, residual-risk disposition, approver,
next governance review, and cadence. If no decision owner is present, complete
only the review and interpretation, mark the decision deferred, and assign the
owner and date.

## Reference-only evidence and handoff

- [ ] The customer records references to the normalized registry, S1 inventory,
  reconciliation report, S0 baseline, S6 exit scorecard, and maturity-lift
  output in its approved records system.
- [ ] Every reconciliation and maturity finding has a decision, owner, due
  date, and status in
  [`assessment/closeout-backlog.md`](assessment/closeout-backlog.md).
- [ ] The governance lead records the closeout decision, approver, and next
  governance review and cadence. Customer registry changes, if any, use a
  separate approved change and rollback process.

Record only the pilot question, scope, date, approved-record references,
observed result or no-result, interpretation, decision, owner, and next
dependency in the handoff. A template, sample, local tool output, or
facilitator-created note does not establish a customer control.

## Blocker pathways

| If | Then |
|---|---|
| Required input, evidence reference, or decision owner is missing | Stop the dependent step; record the missing dependency, owner, date, and reschedule. Do not manufacture evidence or a decision. |
| Registry cannot be normalized explicitly | Return it to the customer source owner as an input-quality gap. Do not match by display name or alternate fields. |
| A finding needs a customer change | Add an owned backlog item and hand it to the approved change process; do not make the change during S6. |
| No finding appears where one was expected, or a capability is unsupported | Record the scope and interpretation; decide to observe, refine the question, use another customer control, or defer. |
