# S1 Runbook

> **Boundary:** this is an inventory-review and ownership-decision session. It
> does not use a heuristic discovery query, create a Conditional Access policy,
> validate a break-glass configuration, or retain customer evidence in Git.

## Activity card

**90 minutes.** Facilitator runs the evidence-first review; identity
administrator performs the customer action; governance lead owns the decision;
evidence owner records references; security reviewer interprets risk. Entry
condition: bounded workload, authorized source, approved records location, and
decision owner. Stop a population whose source, access, or owner is missing.

## 1. Set the question and source boundary

- [ ] Customer identifies the workload, identity administrator, source,
  coverage, exclusions, review date, evidence reference, and stop condition.
- [ ] Facilitator asks: “What can this source authoritatively describe?” and
  “What cannot it prove?” A service-principal listing, tag/name match, or
  unsupported result is not an Agent ID inventory.
- [ ] A documented source-coverage statement is a result. If the authorized
  source is unavailable, record unsupported/blocked scope, owner, and date;
  do not substitute a directory query.

## 2. Customer-led inventory review

- [ ] Administrator reviews each in-scope record with the
  [inventory schema](README.md#identity-inventory-schema): classification,
  workload, sponsor, lifecycle, purpose, source reference, risk context,
  reviewer, and next review.
- [ ] Ask: “Who owns purpose and lifecycle?”, “What ties this to the
  workload?”, and “What action follows this finding?”
- [ ] Record a complete review as meaningful result. Record no entries only
  with source/scope/date/reviewer. Record missing attributes as unsupported
  coverage; missing source/access/owner is blocked. Keep identifiers, exports,
  and sponsor information in customer systems.

## 3. Interpret corroboration correctly

- [ ] Treat service principal, managed identity, OBO, or application data only
  as corroboration. Ask whether it proves Agent ID status; record its limit.
- [ ] Record whether the reviewed activity is user-delegated or agent-operated,
  the approved tool/action scope, accountable approver, and material changes
  that require reapproval. This is an authority-boundary review, not a policy
  design or access change.

## 4. Make the ownership decision

- [ ] Governance lead chooses remediation, `accepted_risk`, `blocked`, or
  deferred decision based on coverage, attributable sponsor, lifecycle,
  access-risk context, and customer authority.
- [ ] Record the customer inventory/source reference and retention metadata in
  `04-operate/evidence-register.json`, and decision/owner/approver/date in
  `04-operate/decision-register.json`.

## 5. Hand off without designing controls

- [ ] Read back evidence reference, control state, next owner, and S6
  reconciliation dependency. If no decision owner attended, record deferred
  owner/date.
- [ ] Hand Conditional Access, break-glass, access remediation, and enforcement
  to the customer identity-change process; it owns design, change safety,
  verification, and evidence retention.
