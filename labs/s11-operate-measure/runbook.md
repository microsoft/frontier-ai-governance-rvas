# S11 Runbook — Operate, monitor, and FinOps review definition

Use this runbook with the [S11 co-delivery activity](../../docs/s11-operate-measure/index.md).
The customer selects scope, evidence references, owners, and decisions; the
facilitator maintains the evidence-first, no-live-data, no-change boundary.

## Activity card

**90 minutes.** Entry condition: S9 closeout or deferral, an accountable
governance lead, service owner, cost owner where cost is in scope, and an
approved records location. Stop any question with no accountable owner or
authoritative evidence.

1. Copy `templates/operating-review.template.md` and
   `templates/remediation-closure.template.md` into approved records.
2. Define one bounded population, review period, review cadence, and decision.
   Record the evidence reference plus known coverage, attribution, and latency
   limits for each chosen question.
3. Select only relevant coverage, reliability, risk, quality, cost ownership,
   adoption, human-review, and business-outcome questions. Record an
   interpretation owner and decision or escalation route. Do not infer a
   metric, target, threshold, allocation method, or outcome from the template.
   When quality trend, latency drift, or token-cost accountability is in scope,
   also copy `templates/quality-cost-latency-review.template.md`. It references
   customer-held evidence only; Foundry traces are optional project-gated
   context, and every cost observation needs an accountable spend-decision
   owner.
   When production agent performance — first-token latency, end-to-end latency,
   throughput, or error/saturation — is in scope, also copy
   `templates/performance-telemetry-review.template.md`. It references
   customer-held OpenTelemetry, Application Insights, or Foundry-trace evidence
   only, records sampling and coverage limits, and reconciles against the S7
   synthetic baseline as a drift hypothesis rather than a confirmed result.
4. For a suspected change, record a drift hypothesis, alternative explanations,
   evidence limits, test or observation plan, owner, and escalation trigger.
   Do not label the hypothesis confirmed or investigate live data in this
   session.
5. For each finding, record accountable-owner acceptance, target date,
   remediation validation reference, recurrence check, exception expiry or
   escalation route, closure reviewer, and next review.
6. The governance lead approves, defers, or rejects the review definition.
   Retain the decision reference and limitations in approved records.
7. Record the operating implementation backlog in the operating-review record:
   Application Insights/OpenTelemetry or Foundry observability coverage,
   alerting/SOC route, remediation validation, review cadence, FinOps/cost
   owner, quota or allocation limits, exception route, S12 handoff, recommendation,
   confidence, assumptions, evidence reference or gap, owner, and customer
   operating/change process.

No raw telemetry, identifiers, prompts, responses, costs, or business data
belong in this kit. S11 does not query live data or make a monitoring,
remediation, exception, policy, identity, or production change.

## Safe interpretation rules

- An evidence gap, excluded population, or delayed record is a coverage
  limitation—not a zero result, no-cost result, or pass.
- Reliability, risk, quality, cost, adoption, and business outcome are
  different questions. Do not use one as proof of another.
- A cost observation requires an accountable spend decision owner and stated
  attribution limits; it does not by itself establish value or fault.
- A closed remediation needs a validation reference and recurrence result.
  Remaining risk must be accepted through an explicit exception or escalation
  route.

## Blocker pathways

| If | Then |
|---|---|
| No evidence, owner, decision use, or approved records location | Block the affected question; record the gap, owner, date, and next review. Do not manufacture a measure or decision. |
| A drift hypothesis needs data collection or analysis | Record the hypothesis and separately governed observation plan; do not query live data during S11. |
| A finding requires a configuration, monitoring, policy, remediation, or exception change | Create an owned follow-up and use the customer's approved change process; do not make the change during S11. |
| Validation or recurrence evidence is unavailable | Keep the item open or explicitly escalate; do not mark it closed based only on reported completion. |
