# S6 · Control Plane & Operationalization

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Security / SOC</span>

## 1. Outcome & durable artifact

The customer leaves with an owned operating closeout:

- a read-only reconciliation of its normalized control-plane registry and the
  explicit S1 Entra Agent ID inventory;
- the S0 baseline-to-S6 exit maturity comparison; and
- a decision-ready residual-gap backlog with owners, due dates, and status.

Durable artifact: `labs/s6-control-plane/` - explicit input schemas,
read-only reconciliation tooling, and the closeout templates. Customer evidence
remains in the approved customer records system and is referenced, not
committed to this repository.

## 2. Prerequisites

- The S0 baseline scorecard and a customer-produced S1 normalized identity
  inventory using the S1 kit's explicit schema.
- A customer-normalized registry using
  `rvas.s6.control-plane-registry.v1`; `agent-registry.sample.json` is the
  safe, explicit example.
- Governance lead empowered to assign owners, decisions, and review dates.
- An approved customer records-system location for the closeout evidence.

## 3. Why this session

Governance becomes operational when known agents, identities, ownership,
lifecycle state, and unresolved gaps can be reconciled into one accountable
record. S6 uses explicit field mappings so a mismatch becomes a finding instead
of a guessed match.

Read the [S6 Concepts](concepts.md) for reconciliation, lifecycle ownership,
and the boundary between visibility and governance.

## 4. Co-delivery walkthrough

!!! warning "Read-only reconciliation"
    This kit does not export from a product API or write lifecycle, ownership,
    or access metadata. The customer uses its supported product process to
    obtain source data, then normalizes it before S6.

**Timebox:** 90 minutes. **Facilitator:** runs the method and records
references; never performs customer actions or accepts risk. **Customer
activity owner:** prepares and runs the reconciliation. **Evidence owner:**
points to approved records. **Governance lead / decision owner:** assigns
dispositions and makes the closeout or deferral decision. Include an identity
administrator and a maker or platform specialist when findings need their
interpretation.

**Entry condition:** the decision owner is present (or a dated decision
deferral is agreed); the customer has an S0 baseline reference, a
customer-produced S1 normalized inventory, a candidate registry source, and
an approved records-system location. The facilitator confirms the safe posture:
no product export, no registry write, no tenant change, and no raw customer
records copied into this repository.

| Activity | Time | Customer operation | Facilitator prompts and interpretation |
|---|---:|---|---|
| Set the question and evidence boundary | 10 min | Confirm the pilot question: “Can this bounded registry be reconciled to S1 using explicit Entra object IDs, and what must be owned before closeout?” Name the records location and decision owner. | “Which source is authoritative for this pilot?” “What would make us stop?” Record only references, scope, date, roles, and expected signal. |
| Review input quality | 15 min | Show the approved references for the S0 baseline and S1 inventory, then inspect the candidate registry for completeness and provenance. | “Is this customer-produced and current enough for the decision?” “Which field is unknown rather than inferred?” Missing, stale, or unowned input is a finding or blocker—not a reason to fill a field from a display name. |
| Normalize explicitly | 15 min | Normalize the registry to `rvas.s6.control-plane-registry.v1`, using the sample only as a field-level illustration. Supply `registryId`, `displayName`, `entraObjectId` or `null`, `executionMode`, `managed`, `lifecycleState` or `null`, and `sponsor` or `null`. | “Can every value be traced to the customer source?” “Which nulls are intentional findings?” Do not map aliases or alternate fields. A schema failure means the input is not ready; it is not a reconciliation result. |
| Reconcile and triage | 20 min | Run the read-only comparison below, then review shadow, registry-only, unmanaged/OBO, missing-sponsor, and lifecycle findings with the appropriate specialist. | “What does this finding mean operationally?” “Is it a source gap, an ownership gap, or a separate change?” Matches are only `entraObjectId` ↔ `objectId`; a no-result is not a pass unless the expected signal and checked scope are recorded. Do not change the registry in the session. |
| Discuss maturity lift | 15 min | Re-run the same S0 scorecard in the customer-approved records system, compare the baseline and exit scores with the S0 offline scoring tools, and retain the maturity-lift reference with closeout records. | “What evidence supports a score change?” “Which domains remain below target?” Treat the comparison as a decision input, not proof that a control is deployed or operating. Add each residual gap to the customer-owned backlog. |
| Close out and set cadence | 15 min | Choose close, close with owned gaps, defer, or do not close. Name the approver, backlog owner, target dates, and next governance review. | “Are all findings owned with a due date?” “What cadence will re-check registry quality, reconciliation, and residual gaps?” A closeout is valid only when the governance lead accepts the stated residual risk; otherwise record a deferred decision and review date. |

Run the reconciliation during the fourth activity:

```bash
python labs/s6-control-plane/scripts/reconcile-registry.py \
  --registry labs/s6-control-plane/evidence/control-plane-registry.json \
  --inventory labs/s1-identity/evidence/agent-inventory.json \
  --out labs/s6-control-plane/evidence/reconciliation-report.json
```

### Results, evidence, and handoff

Reference—not copy—these customer-approved records: S0 baseline and exit
scorecards, normalized registry source, S1 inventory, reconciliation report,
maturity-lift output, and closeout/backlog decision. The handoff records the
pilot question, scope, observed result or no-result, interpretation, control
state, decision, owner, next review, and any dependency. A sample, offline
tool run, or facilitator note is preparation material, not proof of a customer
control.

### Blocker pathways

| Blocker | Safe response and handoff |
|---|---|
| S0 baseline, S1 inventory, or decision owner is absent | Stop the dependent step. Record the missing input or owner, assign a target date, and reschedule; do not create a substitute inventory or decision. |
| Registry is incomplete, stale, or cannot be normalized without inference | Record an input-quality finding. Return the record to the customer source owner; do not match by name or alter fields in the workshop. |
| A reconciliation finding needs a registry, identity, lifecycle, or access change | Create a customer-owned backlog item. The change proceeds only through the customer's supported process with its own approval, rollback, and verification. |
| The report produces no expected finding or a capability is unsupported | Record the checked scope and interpretation. Decide to observe, refine the bounded question, use a customer control, or defer—never label absence as a pass by itself. |

## 5. Verification & evidence capture

- [ ] Registry, S1 inventory, reconciliation report, baseline scorecard, exit
  scorecard, and maturity-lift output have customer records-system references.
- [ ] The report documents matches by Entra object ID only and preserves all
  unmatched records as findings.
- [ ] Every residual finding has a decision, owner, due date, and status.
- [ ] The governance lead has recorded a closeout decision, approver, and next
  governance review.

## 6. Change boundary

S6 makes no registry or tenant changes. Any customer registry update follows
the customer's supported product procedure and separate approved change,
rollback, and verification process.

## 7. Facilitator notes

- Follow the 90-minute [co-delivery facilitation method](../delivery/facilitation-pattern.md):
  customer actions and customer evidence remain customer-owned; the
  facilitator keeps time, boundaries, interpretation, and decision wording
  explicit.
- **RACI:** Governance lead = decision owner; customer activity owner = R for
  normalization and reconciliation; evidence owner = R for approved references;
  identity admin, Security/SOC, and AI developer/maker = specialist reviewers.
- **Close the loop:** the comparison and owned backlog support a closeout and
  operating-cadence decision; they do not certify a product control.
