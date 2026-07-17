# S11 · Operate, Monitor & FinOps

**Facilitator deck**

Governance lead · Service owner · Cost owner · 90-minute operating-review design session

Note:
Welcome and set the evidence boundary. This is a reference-only operating review. It does not query live data, copy telemetry, create dashboards, calculate metrics, set thresholds, or implement change. Roles: facilitator, governance lead, service owner, cost owner, evidence owner, and specialists only for questions in scope.

---

## One operating question

> **"What decision can this review support — and what evidence limits must travel with it?"**

By the end, the customer has a repeatable review definition with owners, cadence, limits, and next review.

Note:
Keep the outcome tied to a decision. A dashboard tour is not governance. The customer leaves with a review definition they own, not a new monitoring implementation.

---

## Why this matters

- Operating governance needs a cadence, not just a dashboard.
- Evidence must lead to interpretation, decision, escalation, and validation.
- Foundry observability can inform a review when enabled and retained.
- FinOps evidence can inform spend ownership and allocation limits.

Note:
Name the failure mode: teams collect signals but cannot say who interprets them, what population they cover, what decision follows, or whether remediation is truly closed.

---

## An operating review turns evidence into a decision

![S11 flow: Foundry observability, OpenTelemetry/Application Insights signals and a stated population and review period feed an operating review (population, review period, coverage limit, accountable owner, decision per question); a coverage limit blocks over-reading the evidence; outputs are an operating decision and a drift hypothesis against the S7 baseline, routed to an accountable owner, validation reference, or exception/escalation route.](../assets/diagrams/s11-operating-review-flow.svg)

Define population, review period, coverage limit, accountable owner, and decision for each selected question.

Note:
Walk the flow from signals to the operating review to decisions and drift hypotheses. Stress that the coverage limit blocks over-reading. If the room cannot name an owner or decision, that question is blocked.

---

## Coverage comes before a result

- Reliability, risk, quality, cost, adoption, and outcome observations need scope.
- Unavailable, uninstrumented, or excluded populations are coverage limits.
- A coverage limit is not a zero result or a pass.
- No trusted evidence or owner means blocked.

Note:
Use this slide to discipline the whole session. Missing evidence is a finding. Do not let the group substitute intuition, a template, or a partial dashboard for a scoped evidence reference.

---

## Operating signals stay bounded

- Foundry observability can provide traces, token usage, latency, and evaluation scores where enabled.
- OpenTelemetry, Application Insights, and Foundry traces can supply performance signals.
- First-token latency is separate from end-to-end p95 for streaming agents.
- Every number carries sampling, retention, and population limits.

Note:
Record project, model deployment, agent or run identifier where available, review period, sampling, retention, evaluator type and version, and interpretation owner. A production evaluation score is an operating signal, not sign-off to ship or proof a control was enforced.

---

## FinOps is operating accountability

- Cost review asks who owns the spend decision.
- Scope, allocation limits, shared-cost assumptions, and exclusions must be recorded.
- Subscription billing and project-level attribution can differ.
- Fine-tuning training cost is separate from inference cost.

Note:
Do not set a target, chargeback method, or threshold in this session. Cost evidence helps only when the workload scope, assumptions, latency, exclusions, and decision owner are visible.

---

## Drift is a hypothesis to test

- Changes can suggest drift in reliability, risk, quality, cost, adoption, or outcome.
- Causes can include behavior, workload mix, configuration, usage, evidence coverage, or external conditions.
- Record the hypothesis, limits, owner, and test or observation plan.
- Do not call drift confirmed without a clear review basis.

Note:
Tie this back to S7 when production percentiles differ from a synthetic baseline. The gap is a drift hypothesis, not confirmed drift, until the customer tests plausible explanations.

---

## Escalation and closure preserve accountability

- Every finding needs owner, target date, validation reference, recurrence check, and route.
- Exceptions need expiry, acceptance, and escalation path.
- Remediation is not closed because someone reports completion.
- Closure requires reviewer validation and remaining-exception review.
- Owned gaps become the operating backlog.

Note:
This is where operating governance becomes accountable. Reported completion is an input; closure is a reviewer decision against validation evidence and any remaining exceptions. Backlog rows can include instrumentation coverage, alert routes, remediation validation, recurrence checks, cadence, FinOps ownership, allocation limits, exception escalation, and S12 handoff.

---

## The activity — how we'll work

- **Timebox:** 90 minutes · **six activities**
- **To start:** S9 closure or documented deferral, owners, evidence references, and approved records location.
- Use approved references only.
- No telemetry, identifiers, prompts, responses, costs, or business data go into the kit.

Note:
Review the observability-stack, cost-attribution, and alerting/drift technical decision menus first. If the customer lacks trusted evidence, an accountable owner, or a records location, block that question and record the gap.

---

## Step 1 — Set the operating question · 10 min

Select one population, review period, decision, owners, and records location.

> **"What decision can this review support?"**
> **"What is out of scope?"**

Note:
Start narrow. If the question has no owner or trusted evidence, stop and record it as blocked. The output should be a bounded operating question, not a general monitoring ambition.

---

## Step 2 — Map evidence coverage · 15 min

Record evidence references, population and time coverage, exclusions, latency, and attribution limits.

> **"What can this record not support?"**

For Foundry workloads, name project, deployment, agent identifier where available, token-attribution method, evaluator type, and version.

Note:
Missing coverage is a finding, not zero risk or zero cost. Keep raw records out of the kit; retain only approved references and limits in the customer's records system.

---

## Step 3 — Define balanced review questions · 20 min

Select only relevant questions across:

- control coverage
- reliability, risk, quality
- cost ownership and adoption
- human review and business outcome

> **"Who interprets this?"**
> **"What decision follows?"**
> **"What else could explain the change?"**

Note:
Do not turn every category into a required metric or target. Each question needs an interpretation owner and a decision use, or it stays out of the review. When quality, latency, or cost trends are in scope, complete the addendum using prior and current references; treat the trend as an operating signal, not sign-off to ship.

---

## Step 4 — Form drift hypotheses and routes · 15 min

Record observable hypotheses, alternatives, evidence limits, test or observation plan, owner, and escalation trigger.

> **"What would challenge this hypothesis?"**
> **"When does it need escalation?"**

Note:
Keep the language tentative unless the evidence supports more. The review should produce testable hypotheses and routes, not premature root-cause claims.

---

## Step 5 — Define remediation and exceptions · 15 min

Record finding owner, target date, validation, recurrence approach, exception expiry, escalation route, and next review.

> **"What validates the remedy?"**
> **"Who accepts an exception?"**

Note:
Closure requires reviewer validation. Exceptions need accountable acceptance and an expiry or review route. Do not let reported completion become automatic closure.

---

## Step 6 — Decide and hand over · 15 min

Approve, defer, or reject the review definition and technical decision.

> **"Which technical option is selected, deferred, or rejected?"**
> **"What remains unresolved?"**

Note:
Record limits and next review. Adopting a review method does not authorize enforcement, dashboard creation, remediation, thresholds, identity change, policy change, or production change.

---

## Verification & evidence

- [ ] Population, decision, evidence location, accountable owners, cadence, and next review are selected.
- [ ] Every selected question records coverage limits and interpretation owner.
- [ ] Every drift hypothesis records alternatives, limits, test or observation plan, owner, and escalation route.
- [ ] Every finding records owner acceptance, target date, validation, recurrence, route, closure reviewer, and status.
- [ ] Operating-review and technical decisions are recorded or backlogged.
- [ ] Any quality-cost-latency addendum is referenced in customer records.

Note:
Save approved references and decisions in the customer's records system. Do not retain raw payloads, personal data, credentials, identifiers, prompts, responses, costs, or business data in this kit.

---

## Change boundary & hand-off

- S11 makes no live-data query.
- It makes no platform, dashboard, metric, threshold, identity, policy, remediation, exception, or production change.
- Actions use the customer's approved engineering and change process.
- The review definition and remediation references enter the governance cadence.

Note:
Close with the blocker path: no trusted evidence, accountable owner, or approved records location means the affected question is blocked. Record the gap, owner, and date instead of creating a substitute measure.
