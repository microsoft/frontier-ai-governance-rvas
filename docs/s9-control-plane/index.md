# S9 · Control Plane, Catalog & Lifecycle

!!! info "Freshness"
    Last reviewed: 2026-07-15

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Catalog steward</span> <span class="rvas-badge rvas-persona">Service owner</span>

## 1. Outcome & durable artifact

The customer leaves with a decision-ready, customer-owned operating closeout:

- a read-only reconciliation of explicit catalog identity identifiers with the
  normalized identity inventory;
- an evidence-first stewardship view of agents and tools, including ownership,
  lifecycle state, material-change review, and closure accountability; and
- a residual-gap backlog with owners, dates, validation references, recurrence
  checks, exceptions, and next-review decisions.

Durable artifact: `labs/s9-control-plane/` provides blank stewardship and
closeout templates, sample-only schemas, and read-only reconciliation tooling.
Customer evidence remains in approved records and is referenced, not copied
into this repository.

### Implementation pathway

S9 produces a catalog and lifecycle implementation backlog for later
customer-owned work. The recommendation should state whether to close, close
with owned gaps, defer, or keep open, and which Agent 365, Entra Agent ID, API
Center, catalog-stewardship, lifecycle, material-change, reconciliation,
retirement, recurrence, S11, or S12 item owns the next action.

## 2. Prerequisites

- A baseline scorecard and a normalized identity inventory with explicit object
  identifiers.
- A customer-normalized agent and tool catalog using
  `rvas.s9.control-plane-registry.v1`.
- A governance lead able to assign accountable owners, residual-risk
  dispositions, and review dates.
- An approved records location for evidence references and decisions.

## 3. Why this session

Control-plane governance is durable when every in-scope agent and tool has a
known steward, lifecycle decision, material-change posture, and route to
reconciliation and closure. S9 makes gaps visible without inferring facts or
changing the operating environment.

Read the [S9 Concepts](concepts.md) before delivery.

## 4. Co-delivery walkthrough

!!! warning "Evidence-first, read-only boundary"
    This 90-minute session uses customer-held references and sample-only,
    normalized inputs. Do not connect to live data, copy raw records, or
    create a catalog, lifecycle, identity, access, policy, or production
    change.

**Facilitator:** protects the boundary, timebox, and decision wording.
**Governance lead:** owns the closeout decision. **Catalog steward:** explains
the agent and tool records. **Evidence owner:** provides approved references.
Include specialist reviewers only for questions within their remit.

| Activity | Time | Customer operation | Facilitator prompts and interpretation |
|---|---:|---|---|
| Set scope and decision boundary | 10 min | Select one bounded catalog population, review period, records location, and closeout decision. | “What decision can this session support?” “What remains a separate change?” Stop on missing authority or evidence. |
| Review catalog stewardship | 15 min | Review agent and tool entries for purpose, accountable owner, technical steward, lifecycle state, and parent relationship. | “Who owns this entry through closure?” “Can a tool extend authority beyond its reviewed use?” Unknowns are findings, not assumptions. |
| Review lifecycle and material changes | 15 min | Identify transitions, suspensions, retirements, and material changes in scope; reference their decision and review records. | “Was this destination permitted?” “Who reviewed the authority or operating-scope change?” Do not execute the transition or remediation here. |
| Reconcile and triage | 20 min | Run the read-only identifier comparison and review identity, ownership, lifecycle, material-review, tool-parent, and closure findings. | “Is this a record-quality gap, a stewardship gap, or a separately governed change?” A no-result is not a pass without scope and expected signal. |
| Set remediation and recurrence | 15 min | Assign every open item an owner, due date, validation reference, recurrence check, exception route, and escalation path. | “What validates the remedy?” “What detects recurrence?” Closure without validation remains open. |
| Close out and set cadence | 15 min | Choose close, close with owned gaps, defer, or do not close; record approver and next review. | “Who accepts residual risk?” “When will catalog stewardship, reconciliation, and closure status be revisited?” |

Use this triage lens during reconciliation:

| Finding type | Interpretation | Handoff |
|---|---|---|
| Record-quality gap | A required field or reference is absent, invalid, stale, or not normalized. | Return to the accountable steward with the required correction and validation reference. |
| Stewardship gap | Ownership, lifecycle accountability, parent-tool relationship, or closure owner is unclear. | Assign an accountable owner, decision owner, due date, and recurrence check. |
| Governed-change need | A transition, suspension, retirement, access change, policy change, or remediation is required. | Route to the customer's approved change process; do not perform it in S9. |
| Unsupported coverage | Expected evidence is missing or the checked population is incomplete. | Record the coverage limit, alternative control or observation path, and next review. |

Run the reconciliation during the fourth activity:

```bash
python labs/s9-control-plane/scripts/reconcile-registry.py \
  --registry labs/s9-control-plane/evidence/control-plane-registry.json \
  --inventory labs/s1-identity/evidence/agent-inventory.json \
  --out labs/s9-control-plane/evidence/reconciliation-report.json
```

### Results, evidence, and handoff

Reference—not copy—the baseline and exit scorecards, catalog record, identity
inventory, reconciliation report, lifecycle and material-change decisions,
validation records, and closeout decision. The handoff records scope, observed
result or no-result, interpretation, decision, owner, next review, and
dependency. Samples, local tool output, and facilitator notes are not proof of
an operating control.

### Blocker pathways

| Blocker | Safe response and handoff |
|---|---|
| No accountable owner, decision owner, or evidence reference | Stop the affected step; record the gap, owner, target date, and reschedule. Do not manufacture evidence or acceptance. |
| Catalog field is incomplete or cannot be normalized explicitly | Record an input-quality finding and return it to its accountable steward. Do not match by name or rewrite fields during the session. |
| A lifecycle transition, suspension, retirement, remediation, or material change is needed | Create an owned backlog item and use the customer's separate approved change, rollback, and verification process. Do not make the change in S9. |
| Expected evidence is absent or coverage is unsupported | Record the bounded scope and interpretation; observe, refine the question, use another customer control, or defer. Never treat absence as a pass. |

## 5. Verification & evidence capture

- [ ] Every in-scope agent and tool has an accountable owner, technical
  steward, lifecycle state, and approved-record reference.
- [ ] Every material change and lifecycle transition in scope has a review or
  decision reference; suspended, retired, and decommissioned entries have
  closure accountability.
- [ ] Reconciliation preserves unmatched and invalid records as findings.
- [ ] Every residual finding has an owner, due date, validation reference,
  recurrence check, exception or escalation route, and status.
- [ ] The governance lead has recorded the closeout decision and next review.

## 6. Change boundary

S9 makes no live-data query and no catalog, lifecycle, identity, policy,
access, or production change. Any change follows the customer's separate
approved implementation, rollback, and verification process.

## 7. Facilitator notes

- Keep the session within 90 minutes. Customer actions, evidence, and risk
  acceptance remain customer-owned.
- **RACI:** Governance lead = decision owner; catalog steward = responsible for
  record interpretation; evidence owner = responsible for approved references;
  service, identity, risk, and finance specialists = consulted as relevant.
- Closeout confirms accountability and cadence; it does not certify that a
  control is deployed or operating.
