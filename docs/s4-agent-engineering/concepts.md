# S4 · Agent Engineering & Admission Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Reconfirm applicable admission requirements
    before each delivery.

Use [S4 Prepare](index.md) for the 90-minute co-delivery method. This page
defines the standards that the session reviews; it does not prescribe a
technology, implementation framework, or deployment design.

## Classification is about authority

Classify a candidate by the authority it is intended to exercise, not by its
label or implementation style:

| Archetype | Intended authority | Minimum admission focus |
|---|---|---|
| Advisory assistant | Produces information or recommendations; a person takes any consequential action. | Purpose, audience, information boundaries, quality expectations, limitations, and accountable owner. |
| Human-confirmed action agent | Prepares or requests an action that requires a named human confirmation before execution. | Confirmation point, action scope, approver role, failure handling, action traceability, and test evidence. |
| Bounded delegated-action agent | Performs defined actions within a constrained authority without per-action confirmation. | Explicit authority and tool/action inventory, access boundary, safeguards, exception path, monitoring expectation, and negative testing. |
| Coordinating agent | Sequences, delegates, or selects among multiple actions or components. | All delegated-action requirements plus orchestration boundary, dependency map, escalation, recovery, and evidence for each consequential path. |

If the intended authority cannot be stated, classify the candidate as
**unclassified** and do not admit it. The most consequential intended action
sets the minimum standard; a candidate does not become advisory merely because
it also produces explanations.

## Approved implementation paths

Admission records the implementation path that the organization already
approves. It does not select one on the customer's behalf:

- **Governed platform capability:** a capability delivered under an existing
  platform ownership, access, release, and operational process.
- **Application or service delivery:** an engineering implementation governed
  through the established software delivery, architecture, security, and
  change process.
- **Workflow automation:** a bounded automation governed through the
  organization's workflow, access, and operational-change process.
- **Research or prototype:** an isolated learning activity with no admission to
  an operational lifecycle until a production-intent path is chosen.

The path must identify its accountable engineering and service owners, review
points, evidence location, rollback or recovery owner where relevant, and
route for exceptions. A named technology is not an implementation path.

## Admission requirements are proportional

Every archetype needs a bounded purpose, classification, implementation path,
accountable owners, evidence location, lifecycle state, and a decision record.
Higher authority adds requirements; it never removes the lower ones.

For candidates that can request or perform actions, the admission record also
states:

- the allowed tools, actions, targets, and data categories at a level suitable
  for governance review;
- authority limits, human-control points, exception handling, and stop or
  escalation behavior;
- access and dependency boundaries, including what the candidate must not
  access or do;
- test expectations and acceptance criteria appropriate to the consequence of
  a failure; and
- operational ownership, review cadence, incident or issue route, and known
  limitations.

Evidence is a reference to a customer-held record. A claim, a demonstration,
or an empty field is not evidence.

## Ownership separates accountability

One person may hold more than one role only when that is explicitly recorded.
The admission record names:

| Role | Accountability |
|---|---|
| Business or purpose owner | Intended outcome, permitted use, and continued need. |
| Engineering owner | Design integrity, implementation path, and technical remediation. |
| Service owner | Operability, support route, lifecycle coordination, and retirement execution. |
| Governance decision owner | Admission, deferral, exception, and reapproval decisions. |
| Evidence owner | References, retention location, and reviewability of the decision record. |
| Risk or control owner | Applicable risk acceptance and control obligations. |

Ownership must survive handoffs. An unnamed future owner is a gap, not a
retirement or operating plan.

## Tests show bounded claims

Test expectations should match the archetype and intended authority. They may
include reviewed design checks, representative scenario tests, boundary and
negative cases, denied or unavailable dependency behavior, human-confirmation
behavior, recovery or escalation behavior, and access or action-limit tests.

The record should distinguish **planned**, **observed**, **passed**, **failed**,
and **not applicable**. Evidence of an offline test is limited to the stated
test; it does not demonstrate a live integration, operating effectiveness, or
production readiness.

## Material changes require reapproval

Reapproval is required before a change that could invalidate the admission
decision, including a change to:

- purpose, intended users, or permitted use;
- classification or degree of delegated authority;
- action, tool, target, data category, access boundary, or human-control point;
- implementation path, material component, dependency, or operating model;
- accountable owner, exception decision, risk posture, or acceptance criteria;
- test scope, failure handling, recovery behavior, or retirement obligation.

The organization may define additional triggers. A version number change alone
does not decide materiality; the decision owner records why the change does or
does not affect the admitted boundary.

## Lifecycle entry and retirement are decisions

Lifecycle entry occurs when the decision owner admits the candidate to a stated
next stage with owners, evidence references, limitations, and a review date.
The decision must say what remains out of scope. S4 does not approve a
production release.

Retirement begins when the purpose ends, an owner cannot be sustained, risk is
no longer acceptable, a replacement supersedes the candidate, or a lifecycle
decision requires withdrawal. The customer retirement process should assign
responsibility for stopping use, removing or disabling approved access through
the applicable change process, retaining required records, communicating the
status, and confirming closure. A retirement decision must not leave an
unowned authority boundary behind.
