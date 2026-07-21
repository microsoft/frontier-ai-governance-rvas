# S9 · Control Plane, Catalog & Lifecycle

**Facilitator deck**

Governance lead · Catalog steward · Service owner · 90-minute read-only reconciliation

## The reconciliation question

> **"Do the agent, identity, tool, and lifecycle records agree for this bounded population?"**

Record close, close with owned gaps, defer, or remain open.

---

## What S9 reviews

![Reconciliation gaps route to a lifecycle backlog.](../assets/diagrams/s9-reconciliation-gap-flow.svg)

- A catalog entry needs purpose, accountable owner, steward, lifecycle state, and review reference.
- Compare explicit identifiers; never infer a match from names or aliases.
- A lifecycle transition or material authority, tool, data, model, scope, or ownership change needs a decision trail.

---

## Boundary and entry

- **Entry:** baseline, normalized identity inventory, normalized catalog, governance authority, and approved records location.
- **Boundary:** approved references and sample-only normalized inputs; no live-data query or catalog, identity, access, policy, lifecycle, or production change.
- Missing authority or evidence stops the affected step and becomes an owned gap.

---

## Step 1: Scope and stewardship · 25 min

Choose one population, review period, records location, and closeout decision. Review agent and tool purpose, owners, stewards, lifecycle state, and parent relationship.

> **"Who owns this entry through closure? Can this tool extend authority beyond its reviewed use?"**

---

## Step 2: Lifecycle review · 15 min

Reference in-scope transitions, suspensions, retirements, material changes, and their decisions.

> **"Was this destination permitted? Who reviewed the authority or operating-scope change?"**

---

## Step 3: Reconcile and triage · 20 min

Run the read-only comparison:

```bash
python labs/s9-control-plane/scripts/reconcile-registry.py \
  --registry labs/s9-control-plane/data/agent-registry.sample.json \
  --inventory labs/s9-control-plane/data/s1-agent-inventory.sample.json \
  --out labs/s9-control-plane/evidence/reconciliation-report.json
```

- Record-quality gap → accountable steward.
- Stewardship gap → assign accountable owner.
- Governed change → customer change process.
- Unsupported coverage → record limit and next review.

---

## Step 4: Remediate and close · 30 min

Assign owner, due date, validation reference, recurrence check, exception route, and escalation path for every open item. Then choose close, close with owned gaps, defer, or do not close.

---

## Verification and handoff

- [ ] Entries have owner, steward, lifecycle state, and approved reference.
- [ ] Material changes and transitions have decision references.
- [ ] Unmatched and invalid records remain findings.
- [ ] Residual findings have owner, due date, validation, recurrence, route, and status.

Reference the baseline, catalog, identity inventory, reconciliation report, lifecycle decisions, technical decision, and closeout in customer records. S9 makes no change; implementation, rollback, and verification remain with customer processes.
