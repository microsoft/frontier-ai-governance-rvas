# S4 Runbook — Agent Engineering & Admission Standards

Use this runbook with the visible [S4 co-delivery activity](../../docs/s4-agent-engineering/index.md).
The customer reviews its records and makes decisions; the facilitator preserves
the 90-minute, evidence-first, report-only boundary.

> **Boundary:** do not request or generate customer code, select a framework,
> connect to a live system, execute an integration, alter access or
> configuration, or approve production use.

## Activity card

**90 minutes:** scope and stop condition (10), classification (15),
implementation path (15), evidence and ownership (20), tests and material
changes (15), lifecycle decision and handoff (15).

**Roles:** engineering owner explains the candidate; service owner explains
operation and retirement ownership; governance lead makes or defers the
decision; evidence owner records references; relevant specialists interpret
their requirements. The facilitator manages time, questions, boundaries, and
decision wording.

**Entry condition:** a bounded candidate with stated purpose, intended
authority, engineering owner, service owner, governance decision owner, and
approved records location. Stop the affected decision if any item is absent.

## 1. Set the scope and classify

- [ ] State the candidate's purpose, intended users, expected outcome, excluded
  use, decision sought, and stop condition.
- [ ] Select advisory assistant, human-confirmed action agent, bounded
  delegated-action agent, coordinating agent, or unclassified.
- [ ] Record the highest-consequence intended action, action/tool boundary,
  human-control point, exception path, and known limitation.

Ask: “What authority is actually intended?” and “What must never happen without
another decision?” If authority cannot be stated, record `unclassified` and
stop admission.

## 2. Record implementation path and ownership

- [ ] Identify the customer's approved path: governed platform capability,
  application/service delivery, workflow automation, or research/prototype.
- [ ] Name the purpose, engineering, service, governance decision, evidence,
  and applicable risk/control owners.
- [ ] Reference the applicable architecture, risk, security, change, and
  operational records; do not copy their content into this kit.

Ask: “Which approved process governs implementation and change?” and “Who
accepts the next decision?” A technology or prototype name is not an approved
path.

## 3. Review admission requirements and test expectations

1. Copy `templates/admission-record.template.md` into the approved records
   system.
2. Complete only the applicable requirement rows for the selected archetype.
3. Reference proportionate planned or completed evidence for scenarios,
   boundary/negative behavior, unavailable dependencies, human confirmation,
   recovery or escalation, and action/access limits.
4. Mark each expectation as planned, observed, passed, failed, not applicable,
   or blocked. A no-result records the checked scope and expected signal; it is
   not automatically a pass.

Do not create a test, connection, code change, or framework recommendation in
this session. An offline result establishes only the stated offline result.

## 4. Assess material change and retirement

- [ ] Copy `templates/change-and-retirement.template.md` when a change or
  withdrawal is proposed.
- [ ] Treat purpose, authority, action/tool/data/access scope, human control,
  implementation path, material dependency, ownership, risk decision, test
  scope, failure handling, and retirement obligations as reapproval triggers.
- [ ] For retirement, assign the customer process owners for stopping use,
  changing or removing access, retaining required records, communication, and
  closure confirmation.

The session records whether reapproval is required; it does not perform the
change, disable an integration, or retire a service.

## 5. Decide lifecycle entry and hand off

The governance lead chooses one:

- **admit to stated next lifecycle stage;**
- **defer pending owned evidence or decision;**
- **reject for the proposed path;** or
- **return for reclassification, reapproval, or retirement.**

Record the decision, permitted next stage, explicit exclusions, rationale,
owner, approver, review date, dependencies, and evidence references. Admission
in this runbook is never production approval.

## Blocker pathways

| If | Then |
|---|---|
| Candidate, authority boundary, owner, approved path, or evidence reference is missing | Stop that decision. Record the gap, owner, target date, and effect on lifecycle entry. |
| Evidence is planned, partial, failed, or outside the claimed boundary | Record the limitation and defer or narrow the decision; do not represent it as a pass. |
| A request involves code, a framework, live integration, access, configuration, or production approval | Route it to the customer's separate engineering or change process. Do not act in this session. |
| A change affects an admitted boundary or the candidate is no longer needed | Record the trigger and require reapproval or retirement through the relevant customer process. |
