# S9 Runbook: Catalog stewardship, lifecycle, and closeout

Use this runbook with the [S9 co-delivery activity](../../docs/s9-control-plane/index.md).
The customer performs all operations; the facilitator timeboxes, preserves the
evidence-first boundary, and captures decisions. Do not store raw customer
records in this kit. Customer-controlled, gitignored `evidence/` paths may be
used as a temporary local working location for the normalized inputs and
report; the approved records system remains the evidence of record.

## Roles, timebox, and entry condition

- **Timebox:** 90 minutes: scope and boundary (10 min), catalog stewardship
  (15 min), lifecycle and material-change review (15 min), reconciliation and
  triage (20 min), remediation and recurrence (15 min), closeout and cadence
  (15 min).
- **Catalog steward:** explains agent and tool records. **Evidence owner:**
  points to approved records. **Governance lead / decision owner:** assigns
  dispositions and accepts, defers, or rejects closeout. Service, identity,
  risk, and finance specialists interpret relevant findings.
- **Entry condition:** an accountable decision owner, an approved records
  location, a baseline reference, a normalized identity inventory, and a
  candidate agent-and-tool catalog are available. If one is absent, record the
  dependency, owner, and date; do not substitute a record or decision.

## Catalog stewardship and explicit normalization

Copy `templates/catalog-stewardship.template.md`,
`templates/technical-decision-record.template.md`, and
`assessment/closeout-backlog.md` into approved records before the session.

- [ ] The catalog follows
  [`contracts/control-plane-registry.schema.json`](../../contracts/control-plane-registry.schema.json),
  uses `rvas.s9.control-plane-registry.v1`, and contains explicit `agents` and
  `tools` arrays.
- [ ] Each agent identifies `registryId`, `displayName`, `identityObjectId` or
  `null`, execution mode, managed status, lifecycle state, accountable owner,
  technical owner, lifecycle-review reference, and material-change-review
  status.
- [ ] Each tool identifies `toolId`, display name, parent agent or approved
  shared-use relationship, owner, lifecycle state, lifecycle-review reference,
  and material-change-review status.
- [ ] Suspended, retired, and decommissioned entries identify a closure owner
  and closure-review reference. A transition, when supplied, identifies its
  from-state, to-state, decision owner, and review reference.

Verify record date, bounded scope, accountable owner, and traceable evidence
before normalization. Keep unknown values as `null`; they become findings.
Never infer a match, owner, parent, lifecycle state, or approval from a name,
alias, or sample.

## Read-only reconciliation and triage

1. The customer creates a normalized catalog in approved records, then places
   only the permitted normalized input in the local, gitignored evidence
   location. The sample is illustrative and never customer evidence.
2. Run the read-only reconciliation. It matches only catalog
   `identityObjectId` with identity-inventory `objectId`:
   ```bash
   python scripts/reconcile-registry.py \
     --registry evidence/control-plane-registry.json \
     --inventory ../s1-identity/evidence/agent-inventory.json \
     --out evidence/reconciliation-report.json
   ```
3. Interpret the report with the applicable owner. Triage shadow and
   catalog-only identities, unmanaged or user-delegated agents, ownership
   gaps, invalid lifecycle states, invalid tool-parent relationships,
   material-change-review gaps, transition-review gaps, and closure-accountability
   gaps. A no-result is not a pass unless the checked scope and expected signal
   are recorded.
   Use this triage matrix:

   | Finding | Classify as | Required record |
   |---|---|---|
   | Missing or invalid identifier, state, owner, parent, or review reference | Input-quality gap | Corrected normalized record and validation reference. |
   | Unmatched catalog or inventory entry | Reconciliation finding | Scope statement, accountable owner, disposition, and recurrence check. |
   | Missing steward, decision owner, closure owner, or review cadence | Stewardship gap | Owner acceptance, due date, escalation route, and next review. |
   | Needed transition, suspension, retirement, access change, or remediation | Governed change | Approved change item, rollback/verification route, and dependency owner. |
   | Missing expected signal or partial coverage | Coverage limitation | Interpretation, alternative evidence path, and review date. |
4. Do not write registry metadata, execute a transition, suspend or retire an
   entry, revoke access, or make a remediation during S9. Send every required
   change through the customer's separate approved change, rollback, and
   verification process.
5. Add every finding to the closeout backlog with an accountable owner,
   disposition, due date, validation reference, recurrence check, exception or
   escalation route, and status. Follow
   [`assessment/exit-rescore.md`](assessment/exit-rescore.md) when the
   baseline-to-exit comparison is in scope.

## Closeout and operating cadence

Choose **close**, **close with owned gaps**, **defer**, or **do not close**.
The decision owner records rationale, residual-risk disposition, approver,
next catalog review, reconciliation cadence, and deferred-decision owner and
date where needed.

Closeout confirms that accountability is visible. It does not confirm that an
entry was changed, a remediation operates, or an exception is resolved. A
closure requires a validation reference and a recorded recurrence review.
References to S11 or S13 are optional handoffs, not S9 exit conditions.

Record the catalog and lifecycle implementation backlog in the stewardship
record: Agent 365, Entra Agent ID, API Center or registry reconciliation,
stewardship fix, lifecycle-state change, material-change route, suspension,
withdrawal, retirement, validation, recurrence, exception, S11/S13 handoff,
recommendation, confidence, assumptions, owner, and customer process.

## Reference-only evidence and handoff

- [ ] Record references to the catalog, identity inventory, reconciliation
  report, lifecycle and material-change decisions, closeout backlog, and
  scorecard comparison in approved records.
- [ ] Record each open or closed finding's owner, decision, due date,
  validation, recurrence check, exception or escalation, and next review.
- [ ] Record the closeout decision, approver, and review cadence.

Retain only scope, date, approved-record references, observed result or
no-result, interpretation, decision, owner, and dependency in the handoff.
Local samples and tool output are not evidence that a control operates. The
reconciliation report is an input-quality and matching result only; confirm
its source, date, and scope in the approved records before using it in a
decision.

## Decision and exception record

Ask: **approve, defer, reject, or route closure for this bounded population?**
Default to eligible API Center, Foundry, and Entra references reconciled in a
customer register. Any other authority records its owner, reason,
field-level/compensating reconciliation, acceptance criteria, target date, and
S11/S13 handoff. This review changes no catalog or lifecycle state.

## Blocker pathways

| If | Then |
|---|---|
| Required record, evidence reference, or decision owner is missing | Stop the dependent step; record the gap, owner, date, and reschedule. |
| A catalog record cannot be normalized without inference | Return it to the accountable steward as an input-quality gap; do not match by name or alternate fields. |
| A transition, material change, suspension, retirement, or remediation is required | Create an owned backlog item and hand it to the approved change process; do not make the change during S9. |
| No expected result appears or coverage is unsupported | Record the scope and interpretation; observe, refine the question, use another customer control, or defer. |
