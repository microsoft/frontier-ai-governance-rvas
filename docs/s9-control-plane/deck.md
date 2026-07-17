# S9 · Control Plane, Catalog & Lifecycle

**Facilitator deck**

Governance lead · Catalog steward · Service owner · 90-minute read-only reconciliation

Note:
Welcome and framing. S9 gives the customer a read-only operating view of agents and tools. It reviews records and decisions. It does not query live data or change a catalog, identity, access setting, policy, production state, or lifecycle state. Roles in the room: facilitator, governance lead, catalog steward, evidence owner, and service owner.

---

## The reconciliation question

> **"Do the agent, identity, tool, and lifecycle records agree for this bounded population?"**

The answer becomes close, close with owned gaps, defer, or keep open.

Note:
This is the whole session in one line. The customer is not trying to fix records live. They are checking whether customer-held records agree and turning gaps into owned backlog.

---

## Why this matters

- Agent governance breaks when Entra, tool catalog, and lifecycle records disagree.
- S9 does not guess or match by name.
- It reconciles records the customer provides.
- Gaps become accountable backlog.

Note:
Set the stakes. A catalog label, dashboard, export, or no-result is not proof by itself. The session depends on explicit identifiers, approved references, and customer decision authority.

---

## A catalog is an operating record

- Each entry needs purpose and accountable owner.
- Each entry needs technical steward and lifecycle state.
- Review references keep the record anchored.
- Unknown fields stay unknown and become findings.
- Tools can extend authority beyond reviewed use.

Note:
Distinguish agent and tool stewardship. An agent entry names the accountable service. A tool entry names the callable capability, its steward, its parent agent or approved shared-use relationship, and its lifecycle decision.

---

## Lifecycle is a decision trail

- States show intended operating posture.
- Transitions need accountable decisions and review references.
- Material changes need recorded review before acceptance.
- Suspension, retirement, and decommissioning are different states.
- S9 records distinctions; it never performs them.

Note:
Use examples from the source language: proposed, active, exception, suspended, retired, and decommissioned. Material changes include authority, tool use, data handling, model behavior, operating scope, or ownership.

---

## Reconciliation keeps gaps visible

![S9 reconciliation flow: several source records (agent registry / Agent 365 view, Entra Agent ID records, API Center / gateway records, platform telemetry, approved lifecycle / change-review) are compared by explicit identity identifiers; disagreements become findings (unmatched identities, catalog-only entries, missing owners, invalid lifecycle states, unreviewed material changes, incomplete closure records) routed to the customer steward or change process as a lifecycle backlog.](../assets/diagrams/s9-reconciliation-gap-flow.svg)

Compare explicit identity identifiers — not names, aliases, or nearby fields.

Note:
Walk the diagram from source records through explicit identifier comparison to findings and lifecycle backlog. The customer may need records from an agent registry or Agent 365 view, Entra Agent ID, API Center or gateway, telemetry, and lifecycle or change-review records.

---

## Reconciliation becomes lifecycle backlog

- Decide: close, close with owned gaps, defer, or remain open.
- Assign steward, lifecycle, parent-tool, and material-change follow-up.
- Route retirement, suspension, and remediation to customer change processes.
- Name stewards for versioned datasets or evaluator definitions when they are dependencies.
- Include S11 cadence and S12 portfolio risk where needed.

Note:
The recommendation should name the next owner and decision path. Where evaluation depends on versioned datasets or evaluator definitions, S9 should name a steward, version record, and lifecycle decision. Unowned evaluation assets are dependencies, not proof that a future release decision remains valid. S9 does not execute catalog, identity, access, policy, or retirement changes.

---

## Closeout accepts accountability

- Closeout can happen with owned gaps.
- Record residual-risk disposition and accountable owner.
- Include due date, validation reference, and recurrence check.
- Include exception route and next review.
- Blank templates and local no-results are not proof.

Note:
The closeout decision is about accountability and cadence, not absence of findings. If validation is missing, closure remains open or close with owned gaps only through customer authority.

---

## Fleet and workflow controls differ

- Fleet control planes show agents, ownership, lifecycle, and gaps.
- Workflow controls decide inside a specific agent workflow.
- S9 reconciles fleet-level records and dependencies.
- It does not infer that a workflow control is installed.
- A catalog entry is not proof of runtime behavior.

Note:
This prevents a common overclaim. A control-plane view and in-process control have different jobs. S9 checks record agreement; it does not certify deployed runtime enforcement.

---

## The activity — how we'll work

- **Timebox:** 90 minutes · **six activities**
- **Boundary:** evidence-first and read-only.
- **Inputs:** baseline scorecard, normalized identity inventory, normalized catalog.
- Missing authority or evidence? **Stop that step** and record the gap.

Note:
The facilitator protects the boundary and decision wording. The governance lead owns the closeout decision. Review the technical-decision menus for system of record, reconciliation cadence, and change or versioning options before deciding between them.

---

## Step 1 — Set scope and decision boundary · 10 min

> **"Which system-of-record, reconciliation cadence, or lifecycle decision can this session support?"**
> **"What remains a separate customer-owned change?"**

Select one bounded catalog population, review period, records location, and closeout decision.

Note:
Stop on missing authority or evidence. The goal is to declare exactly what population is being checked and what decision the session can support without drifting into implementation.

---

## Step 2 — Review catalog stewardship · 15 min

> **"Who owns this entry through closure?"**
> **"Can a tool extend authority beyond its reviewed use?"**

Review purpose, accountable owner, technical steward, lifecycle state, and parent relationship.

Note:
Unknowns are findings, not assumptions. For tools, confirm steward and parent agent or approved shared-use relationship. For agents, confirm accountable service and record reference.

---

## Step 3 — Review lifecycle and material changes · 15 min

> **"Was this destination permitted?"**
> **"Who reviewed the authority or operating-scope change?"**

Reference transitions, suspensions, retirements, material changes, and review decisions.

Note:
Do not execute any transition or remediation here. Material changes to authority, tool use, data handling, model behavior, operating scope, or ownership require a recorded review before acceptance.

---

## Step 4 — Reconcile and triage · 20 min

> **"Is this a record-quality gap, a stewardship gap, or a separately governed change?"**

Run the read-only identifier comparison and preserve unmatched or invalid records as findings.

Note:
This is where the customer reviews identity, ownership, lifecycle, material-review, tool-parent, and closure findings. A no-result is not a pass without scope and expected signal. Do not match by name or rewrite fields during the session.

---

## Step 5 — Set remediation and recurrence · 15 min

> **"What validates the remedy?"**
> **"What detects recurrence?"**

Assign every open item an owner, due date, validation reference, recurrence check, exception route, and escalation path.

Note:
Use the triage lens: record-quality gaps return to stewards; stewardship gaps get accountable owners; governed changes route to the customer's approved process; unsupported coverage records limits and next review. Closure without validation remains open.

---

## Step 6 — Close out and set cadence · 15 min

> **"Who accepts remaining risk?"**
> **"When will catalog stewardship, reconciliation, and closure status be reviewed again?"**

Choose close, close with owned gaps, defer, or do not close.

Note:
Record approver and next review. Closeout confirms accountability and cadence. It does not certify that a control is deployed or operating, and it does not make any live-data, catalog, lifecycle, identity, policy, access, or production change.

---

## Verification & evidence

- [ ] Every in-scope agent and tool has owner, steward, lifecycle state, and approved-record reference.
- [ ] Material changes and lifecycle transitions have review or decision references.
- [ ] Reconciliation preserves unmatched and invalid records as findings.
- [ ] Every residual finding has owner, due date, validation reference, recurrence check, route, and status.
- [ ] Governance lead recorded closeout decision and next review.

Note:
Reference, do not copy, the baseline and exit scorecards, catalog record, identity inventory, reconciliation report, lifecycle and material-change decisions, validation records, technical decision record, and closeout decision. Save only safe references in the generated delivery workspace.

---

## Change boundary & hand-off

- S9 makes no live-data query.
- S9 makes no catalog, lifecycle, identity, policy, access, or production change.
- Any change follows the customer's approved implementation, rollback, and verification process.
- Handoff confirms accountability and cadence.

Note:
When stuck: no owner or decision authority stops the affected step; incomplete catalog fields go back to the steward; lifecycle changes go to the customer's change process; missing evidence becomes a coverage gap. S9 checks record agreement for the declared population; it does not choose a system for the customer.
