# S12 Portfolio Decision Work Package

This lab helps the customer build one bounded portfolio decision package and
hand it to the right owner. The facilitator guides the method; the customer
inspects its own Microsoft and customer records, chooses the decision, and keeps
completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, cost exports, inventory exports, dashboards, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, funding approval, compliance certification, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry condition

Bring one bounded portfolio slice, review period, population definition,
decision question, decision forum, portfolio owner, roadmap owner, risk owner,
evidence owner, control-plane steward, operating review owner, FinOps/capacity
owner where relevant, baseline owner, and approved customer records location.
If any owner, forum, scope, or location is missing, create a blocker backlog
item instead of completing the decision.

Examples of valid scope: pilot cohort, agent population, capability group,
roadmap item set, exception set, dependency cluster, cost/capacity decision,
funding-readiness package, or baseline feedback question.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the portfolio review card, source lineage, coverage limits, scorecard fields, exception concentrations, dependency clusters, prioritization rationale, roadmap action, owner readiness, baseline feedback, decision, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned record that summarizes:

- **Portfolio review card:** slice, population, review period, decision
  question, included/excluded scope, decision forum, owners, evidence limits,
  stop condition, and approved records location.
- **Source lineage and coverage:** inventory/control-plane, identity, tool/API,
  model/deployment, assurance, operating, exception, cost/capacity, roadmap,
  and baseline references with source owner, freshness, population, exclusions,
  coverage limit, and interpretation owner.
- **Portfolio scorecard:** coverage, residual risk, assurance, operating health,
  cost/capacity, maturity, exception age, dependency, roadmap, owner readiness,
  and confidence fields supported by safe references.
- **Exception concentration and dependency clusters:** repeated patterns,
  affected items, shared dependency, risk consequence, owner, escalation route,
  sequence owner, first unblock action, and closure criterion.
- **Prioritization and trade-off record:** risk, value, cost/capacity, coverage,
  dependency, maturity, urgency, confidence, effort/complexity, weights if used,
  rejected alternatives, uncertainty, and decision forum.
- **Roadmap action and owner readiness:** action type, accountable owner,
  implementation owner, evidence owner, funding/capacity owner where relevant,
  dependency owner, target date, acceptance test, evidence reference, exception
  status, blocked-by list, and next review trigger.
- **Baseline feedback:** trigger, question, owner, evidence references, target
  forum, accepted-when condition, and review trigger.
- **Backlog and handoff:** incomplete evidence, stale rollup, expired exception,
  cost/capacity decision, risk/value conflict, dependency cluster, no action
  owner, or baseline feedback trigger captured with owner, acceptance test,
  target date, evidence location, and recheck trigger.

## Technical capture fields

| Area | Fields to capture |
|---|---|
| Review card | Portfolio slice, population, review period, decision question, included/excluded scope, forum, owners, records location, evidence limits, stop condition. |
| Source lineage | Source family, source reference, source owner, source-of-record field, freshness date, refresh cadence, population, exclusions, coverage limit, interpretation owner. |
| Scorecard | Coverage, residual risk, assurance, operating health, cost/capacity, maturity, exception age, dependency, roadmap, owner readiness, confidence. |
| Exception concentration | View, population, pattern, affected items, shared dependency, risk consequence, owner, escalation, closure criterion. |
| Dependency cluster | Cluster name, dependency type, blocked roadmap items, sequence owner, first unblock action, downstream effects, risk if ignored, review trigger. |
| Prioritization | Criteria, weights, weight owner, rationale, rejected alternatives, uncertainty, sensitivity, decision forum, action implication. |
| Roadmap action | Action type, accountable owner, implementation owner, evidence owner, funding/capacity owner, dependency owner, target date, acceptance test, exception status, blocked-by list, review trigger. |
| Baseline feedback | Trigger, question, owner, evidence references, target forum, accepted-when condition, review trigger. |

## Facilitation flow

1. Confirm the customer has a bounded portfolio slice, review period, population
   definition, owners, decision forum, and approved records location. If not,
   stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md)
   into the customer-owned records system. Complete only safe references in
   this repository.
3. Build the portfolio review card. Ask: **What population and decision forum
   can actually act on this review?**
4. Assemble the source-lineage and coverage package. Ask: **Which scorecard
   fields are supported by fresh, owned, scoped references, and which are
   coverage limits?**
5. Build the scorecard and mark unsupported fields as unavailable, stale,
   sampled, excluded, non-comparable, or blocked.
6. Identify exception concentrations and dependency clusters. Ask: **Which
   repeated pattern or shared dependency changes the roadmap sequence?**
7. Compare trade-offs. Ask: **Which item should continue, pause, retire, fund,
   defer, route, or block, and what evidence would change that answer?**
8. Record roadmap action and owner readiness. Unowned items are deferred or
   blocked; do not rank them as ready.
9. Record baseline feedback. Ask: **Which ownership, evidence, risk appetite,
   funding, cadence, policy, or sequencing question must return to the baseline
   owner?**
10. Record one result in the customer system: continue, pause, retire, fund,
    defer, route, or blocked.
11. Create a portfolio backlog item for each unowned exception, stale
    control-plane record, incomplete evidence source, hidden coverage limit,
    unfunded roadmap item, missing operating evidence, cost/capacity decision,
    risk/value conflict, dependency cluster, no action owner, or baseline
    feedback trigger.
12. Handoff the completed decision record and backlog references to the
    receiving owner. Keep final evidence only in the customer-approved system.

## Decision criteria

- **Continue** when the action should proceed through the receiving customer
  process with owner, evidence, target date, and review trigger.
- **Pause** when expansion should stop until evidence, cost, risk, or ownership
  changes.
- **Retire** when the item should enter the customer's retirement/removal
  process with dependency review and retained-record route.
- **Fund** when the package is ready for the customer funding process. This is
  not funding approval.
- **Defer** when evidence is incomplete, stale, non-comparable, unowned, lacks a
  freshness/coverage statement, or lacks a target date but can be completed by a
  named owner.
- **Route** when finance, FinOps, platform capacity, risk, roadmap, evidence,
  operating, exception, assurance, legal/compliance, policy, or baseline owner
  must decide first.
- **Blocked** when ownership, forum authority, evidence location,
  cost/capacity basis, roadmap ownership, source lineage, or scope clarity
  prevents a decision.

## Scenario routes

| Scenario | Route | Required handoff |
|---|---|---|
| Complete rollup | Continue / fund / roadmap handoff | Source lineage, freshness, coverage limits, scorecard interpretation, prioritization rationale, roadmap owner, target date, and baseline trigger are complete. |
| Incomplete or stale evidence | Defer | Missing source, stale state, coverage limit, owner, target date, evidence location, and recheck trigger are recorded. |
| Expired accepted-risk item | Route / block | Risk owner receives affected items, residual risk, expiry, closure criterion, escalation, and roadmap impact. |
| Cost or capacity decision | Route | Finance/FinOps/capacity owner, cost basis, capacity assumption, funding decision date, excluded spend, and roadmap impact are named. |
| Risk/value conflict | Route | Portfolio forum receives risk/value rationale, exception status, value hypothesis, stop/continue criteria, and owner. |
| Shared dependency cluster | Sequence backlog | Sequence owner, first unblock action, downstream items, risk if ignored, and review trigger are recorded. |
| No action owner | Block / defer | Roadmap owner, implementation owner, evidence owner, receiving process, and assignment forum are recorded. |
| Portfolio decision changes foundation assumptions | Baseline feedback | Baseline owner receives scope/risk/operating-model/ownership/funding/policy/roadmap trigger and target review date. |

## Handoff

Handoff to portfolio governance board, executive sponsor, roadmap owner,
finance/FinOps owner, capacity owner, control-plane steward, operating review
owner, evidence owner, risk owner, assurance owner, policy owner, baseline
owner, or accepted-risk authority as applicable. The receiving owner accepts
only decisions or backlog items with clear acceptance tests, target dates,
evidence locations, exception status, freshness/coverage statements, owners,
and recheck triggers. Keep final records in the customer-approved system.
