# How to Deliver

This is the facilitator playbook for the S0-S12 AI Governance curriculum. Use it with [Plan the engagement](start/plan-engagement.md), the session guides, and the customer's change process.

The programme is co-delivered. The facilitator protects the scope, evidence boundary, and decision language. Customer administrators perform privileged actions. Customer owners approve changes and accept risk.

## Delivery outcome

At close, the customer should have:

- an S0 baseline, operating model, and selected session roadmap;
- customer-owned evidence and a control state for each in-scope session;
- an owner and decision for each prerequisite, exception, and remediation item;
- an S9 reconciliation and lifecycle-stewardship record;
- an S11 operating-review cadence; and
- an S12 portfolio decision and next maturity roadmap.

A template, sample, or offline tool output helps the team prepare. It is not evidence that a customer control is deployed or operating.

## Before the first session

Name the executive sponsor, governance lead, platform owner, identity administrator, compliance or data administrator, security operations contact, AI developer or maker lead, and evidence owner.

Confirm the customer records location, change process, escalation route, and initial platform path. Run S0 first. Missing roles, licenses, records, architecture decisions, or safe test targets become backlog items with owners. They are not workshop shortcuts.

## Curriculum sequencing

The curriculum is flexible, but the dependencies are not optional.

| Phase | Session sequence | Delivery purpose |
|---|---|---|
| Govern | S0-S2 | Baseline the operating model, identity and authority, and data posture. |
| Establish | S3-S5 | Define the platform path, agent admission, and tool/API exposure controls. |
| Assure | S6-S8 | Review runtime security, evaluation and release evidence, and approved adversarial testing. |
| Operate | S9-S12 | Reconcile the control plane, assess in-process governance where it applies, operate with evidence, and make portfolio decisions. |

The S0 roadmap may change the order inside a phase. It cannot waive a hard dependency. S10 runs only where an in-process tool-call boundary exists. S12 closes the current cycle and feeds the next S0 baseline.

## Suggested cadence

Plan for eight to twelve weeks. The exact length depends on architecture readiness, observation periods, and customer change lead times.

1. **Mobilize and govern:** run S0-S2; set up the evidence register and decision owners.
2. **Establish the enterprise path:** run S3-S5; send platform, engineering, and publication gaps to the customer's implementation process.
3. **Assure safely:** run S6-S8 only when the customer provides the non-production target, reviewers, and authorization.
4. **Operate and improve:** run S9-S12; reconcile evidence, set the operating cadence, and agree portfolio priorities.

Customer implementation and observation can run alongside governance delivery. Do not squeeze an observation period into a workshop.

## Non-production hard exit gate

Do not run a live runtime assurance request, live evaluation, or adversarial test until all items below are recorded:

- the target is customer-owned and non-production;
- the endpoint owner can stop, reset, or isolate the target;
- the written scope, test window, and rollback contact are present;
- the target contains no production users or unapproved customer data; and
- for S8, written authorization, rules of engagement, and security-operations notification are confirmed.

If any item is missing, stop the dependent action. Continue only with documentation, offline work, or another unblocked session.

## Control states

Use the same vocabulary throughout the curriculum:

| State | Meaning |
|---|---|
| Reference only | The team reviewed a reusable starting point; no customer control is claimed. |
| Designed | The customer defined the control, owner, and change path. |
| Deployed, observe | The customer applied a report-only, simulation, alerts-only, or non-production control and is collecting evidence. |
| Observed | The observation period ended, and the customer reviewed impact, findings, and rollback readiness. |
| Production-ready | The customer has a complete approval package; the curriculum does not turn on enforcement. |
| Exception or blocked | A dependency, risk acceptance, or capability gap prevents progress and has an owner and review date. |

Raise maturity only when customer evidence shows the control is in place and operating. A reference-only artifact never raises maturity.

## Close the cycle

At S12, confirm that the customer records system references the S0 baseline, selected-session evidence, S9 reconciliation, S11 operating review, open exceptions, remediation validation, and portfolio decision.

The executive sponsor accepts the prioritized roadmap and next review date.
