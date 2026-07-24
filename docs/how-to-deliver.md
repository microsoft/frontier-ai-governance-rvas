# How to Deliver

This facilitator playbook for the S0-S12 curriculum complements [Plan the engagement](start/plan-engagement.md), the session guides, and the customer's change process. The facilitator protects scope, evidence boundaries, and decision language; customer administrators perform privileged actions, while customer owners approve changes and accept risk.

## Delivery outcome

At close, the customer should have:

- an S0 baseline, operating model, and selected session roadmap;
- customer-owned evidence and a control state for each in-scope session;
- an owner and decision for each prerequisite, exception, and remediation item;
- an S9 reconciliation and lifecycle-stewardship record;
- an S11 operating-review cadence; and
- an S12 portfolio decision and next maturity roadmap.

Templates, samples, and offline tool output aid preparation; they do not prove that a customer control is deployed or operating.

## Before the first session

Name the executive sponsor, governance lead, platform owner, identity administrator, compliance or data administrator, security operations contact, AI developer or maker lead, and evidence owner.

Confirm the records location, change process, escalation route, and initial platform path. Run S0 first. Missing roles, licenses, records, architecture decisions, or safe test targets become owned backlog items, not workshop shortcuts.

## Curriculum sequencing

The curriculum is flexible, but the dependencies are not optional.

| Phase | Session sequence | Delivery purpose |
|---|---|---|
| Govern | S0-S2 | Baseline the operating model, identity and authority, and data posture. |
| Establish | S3-S5 | Define the platform path, agent admission, and tool/API exposure controls. |
| Assure | S6-S8 | Review runtime security, evaluation and release evidence, and approved adversarial testing. |
| Operate | S9-S12 | Reconcile the control plane, assess in-process governance where it applies, operate with evidence, and make portfolio decisions. |

The S0 roadmap may reorder sessions within a phase, not waive dependencies. S10 runs only where an in-process tool-call boundary exists; S12 feeds the next S0 baseline.

## Suggested cadence

Plan for eight to twelve weeks. The exact length depends on architecture readiness, observation periods, and customer change lead times.

1. **Mobilize and govern:** run S0-S2; set up the evidence register and decision owners.
2. **Establish the enterprise path:** run S3-S5; send platform, engineering, and publication gaps to the customer's implementation process.
3. **Assure safely:** run S6-S8 only when the customer provides the non-production target, reviewers, and authorization.
4. **Operate and improve:** run S9-S12; reconcile evidence, set the operating cadence, and agree portfolio priorities.

Customer implementation and observation can run alongside governance delivery; do not squeeze an observation period into a workshop.

## Practical activities

Every **Facilitate the session** card starts with a **Practical activity**. It
gives the customer one bounded action to perform after choosing the technical
approach.

The customer performs environment actions, operates credentials, and retains
evidence in its approved records system. The facilitator explains the method,
protects the boundary, and helps interpret the result. Use the card's offline
or evidence-reference fallback if the required access, authorization,
non-production target, or safe data is not available. Do not manufacture a
result or use a template as evidence that a control is operating.

The facilitator card is not a second runbook. Its practical-activity section
owns the customer steps, expected signal, safe fallback, and activity evidence.
Its facilitation section holds the timebox, prompts, interpretation, decision,
and escalation.

## Non-production hard exit gate

Do not run a live runtime assurance request, live evaluation, or adversarial test until all items below are recorded:

- the target is customer-owned and non-production;
- the endpoint owner can stop, reset, or isolate the target;
- the written scope, test window, and rollback contact are present;
- the target contains no production users or unapproved customer data; and
- for S8, written authorization, rules of engagement, and security-operations notification are confirmed.

If any item is missing, stop the dependent action. Continue only with documentation, offline work, or another unblocked session.

## Control states

A **decision outcome** says what should happen next in that session: for
example, proceed, hold, defer, reject, remediate, or accept risk. A **control
state** says how far a customer control has progressed. They are related, but
they are not interchangeable: a session can approve a next action while the
related control remains designed or under observation.

Use these control states throughout the curriculum:

| State | Meaning |
|---|---|
| Reference only | The team reviewed a reusable starting point; no customer control is claimed. |
| Designed | The customer defined the control, owner, and change path. |
| Deployed, observe | The customer applied a report-only, simulation, alerts-only, or non-production control and is collecting evidence. |
| Observed | The observation period ended, and the customer reviewed impact, findings, and rollback readiness. |
| Production-ready | The customer has a complete approval package; the curriculum does not turn on enforcement. |
| Exception or blocked | A dependency, risk acceptance, or capability gap prevents progress and has an owner and review date. |

Raise maturity only when customer evidence shows an operating control. A reference-only artifact never raises maturity.

## Close the cycle

At S12, the customer records system references the S0 baseline, selected-session evidence, S9 reconciliation, S11 review, open exceptions, remediation validation, and portfolio decision. The executive sponsor accepts the prioritized roadmap and next review date.
