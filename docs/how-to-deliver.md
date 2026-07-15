# How to Deliver

This is the facilitator playbook for the RVAS AI Governance programme. Use it with [Plan the engagement](start/plan-engagement.md), the session guides, and the customer's change process.

The programme is co-delivered. The facilitator sets the pace, records decisions, and keeps the work safe. Customer administrators perform privileged actions and approve tenant changes. The programme produces governance evidence and production-readiness packages; it does not promote controls into production.

## Delivery outcome

At close, the customer should have:

- a signed S0 baseline, operating model, and ordered delivery backlog;
- evidence and a recorded control state for each in-scope session;
- a decision and owner for every unresolved prerequisite, exception, and remediation item; and
- an S6 comparison package that shows maturity change and the residual backlog.

A template, sample output, or offline mock result is useful preparation. It is not evidence that a customer control is deployed or operating. Record that distinction in the evidence and decision register.

## Before the first session

Name the executive sponsor, governance lead, platform owner, identity administrator, compliance/data administrator, Security Operations Center (SOC) contact, and AI developer or maker lead. Confirm the customer governance repository or evidence location, the change process, and the escalation route.

The facilitator should open the engagement register before S0. Add the platform path, planned session order, prerequisites, decision owners, and target dates. Run the S0 readiness report first. Missing licensing, roles, platform records, or safe test targets become owned backlog items; they are not workshop workarounds.

Use [the engagement cadence](delivery/engagement-cadence.md) to plan the working sessions and customer follow-through. Use [the gate model](delivery/gate-model.md) at every decision point. Keep the [evidence and decision register](delivery/evidence-decision-register.md) with the customer record.

For the in-room sequence, use [Facilitate a co-delivery working session](delivery/facilitation-pattern.md). It timeboxes the pilot, customer-led action and review, interpretation, decision, and handoff without prescribing tenant actions.

## The two-track cadence

Plan for six to eight weeks. The tracks run together, but they have different owners.

| Track | Owner | Work |
|---|---|---|
| Governance delivery | Facilitator and governance lead | S0 through S6, evidence review, risk and ownership decisions, and the residual backlog. |
| Customer change and observation | Customer administrators, platform team, and change approvers | Platform readiness, tenant changes, report-only or simulation observation, remediation, and production-readiness packages. |

Do not compress an observation period into a workshop. S1 Conditional Access report-only results and S2 DLP simulation results need customer review after the relevant policy is applied. S4 needs representative cases before a CI gate can become blocking. Customer change timing may extend the second track without stopping the governance work.

## Session choreography

1. Start with S0. Agree the use cases, owners, platform path, baseline, and sequence.
2. Schedule S1 and S2 when the relevant administrators, licenses, and change approvers are available. Start report-only or simulation observation on the customer track when the customer elects to apply a reviewed definition.
3. Run S3 when a safe runtime test target and SOC intake path are available. Platform-dependent Prompt Shield validation waits for the platform path.
4. Run S4 with an AI developer or maker, a non-production target, representative safe test cases, and an agreed threshold owner.
5. Run S5 only after the adversarial-test authorization, SOC notification, rules of engagement, thresholds, and non-production hard exit gate have passed.
6. Run S6 after the evidence review. Reconcile the registry and S1 inventory, compare the S0 and S6 scorecards, and assign the residual backlog.
7. Run optional S7 only after S6. It is an offline adoption-decision workshop and does not change the core delivery path.

The S0 roadmap can change the order of S1 through S5. It cannot waive hard dependencies. Record any changed order and its reason in the engagement register.

## Non-production hard exit gate

Do not run a live Prompt Shield test, live evaluation, or adversarial test until all of the following are recorded:

- the named endpoint or callable target is customer-owned and non-production;
- the endpoint owner confirms that it can be stopped, reset, or isolated;
- the written scope, test window, and rollback contact are present;
- the target contains no production users or unapproved customer data; and
- for S5, the written authorization, rules of engagement, and SOC notification are confirmed.

If any item is missing, stop test execution. Capture the blocker and owner in the register. The facilitator may continue with documentation, offline mock work, or another unblocked session, but must not substitute a production endpoint.

## Control states and customer outcomes

Use the same state vocabulary across all sessions:

| State | Meaning |
|---|---|
| Reference only | A template, example policy, sample dataset, or mock result has been reviewed. No customer control is claimed. |
| Designed | The customer has made a tenant-specific definition and identified an owner and change path. |
| Deployed, observe | The customer applied the control in report-only, simulation, alerts-only, or non-production mode. Evidence collection is under way. |
| Observed | The agreed observation period ended and the customer reviewed impact, findings, and rollback readiness. |
| Production-ready | The customer has a complete production-readiness package for its own approval process. The programme does not enable enforcement. |
| Exception or blocked | A dependency, risk acceptance, or capability gap prevents progression. It has an owner and review date. |

Only mark a maturity score higher when the customer can show the relevant control is in place and operating. A reference-only artifact does not justify a higher score.

## Production-readiness package

Prepare a production-readiness package only when the customer asks to take a reviewed control beyond its safe initial posture. The package should include:

- the tenant-specific definition and the intended scope;
- evidence from the report-only, simulation, alerts-only, or non-production period;
- impact review, known false positives, and accepted residual risks;
- approver, implementation owner, change window, rollback steps, and communications plan; and
- the post-change validation and review date.

Hand the package to the customer's change authority. Do not enable Conditional Access, DLP enforcement, blocking CI gates, or runtime blocking controls during this programme unless the customer separately executes and approves that change.

## Close the programme

Before closing, hold an evidence and decision review with the governance lead. Confirm that each in-scope session has a control state, evidence location, owner, and next action. S6 must retain the baseline and exit scorecards, the `compare.py` maturity-lift output, registry reconciliation, and the residual-gap backlog.

The executive sponsor accepts the prioritised backlog and the next review date. The CoE then owns the quarterly posture review described in the S0 operating model.
