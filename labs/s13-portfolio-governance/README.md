# S13 Portfolio Governance Work Package

This lab helps the customer make one bounded portfolio-governance decision and hand it to the right owner. The facilitator guides the method; the customer inspects its own Microsoft records, chooses the decision, and keeps completed evidence in its approved records system.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Entry condition

Bring a bounded portfolio slice, decision owner, roadmap owner, implementation owner, evidence owner, finance/FinOps or capacity owner if relevant, receiving forum, and approved customer records location. If any owner, forum, or location is missing, create a blocker backlog item instead of completing the decision.

## Required record

| Record | Required use |
|---|---|
| [`templates/decision-record.template.md`](templates/decision-record.template.md) | Required customer-owned record for the S13 decision, source lineage, freshness, coverage limits, prioritization rationale, roadmap owner, baseline re-measurement trigger, exception status, backlog, target date, and handoff. Copy it into the customer's approved records system before completion. |

## Work package outcomes

By the end of the lab, the customer has a customer-owned decision record that summarizes:

- **Portfolio question:** the bounded portfolio slice, pilot set, roadmap item, exception set, or cost/capacity decision under review.
- **Decision route:** approve, defer, reject, route, or blocked with rationale and owner.
- **Source lineage:** Agent 365/control-plane inventory, exception register, Azure Cost Management or capacity view, operating evidence, roadmap, and baseline references.
- **Freshness and coverage limits:** review dates, refresh cadence, stale sources, included/excluded scope, and owner for each rollup source.
- **Prioritization rationale:** risk, value, cost/capacity, operating readiness, exception status, decision options, and stop/continue criteria.
- **Roadmap and ownership:** roadmap owner, funding/sequencing decision owner, implementation owner, evidence owner, and receiving process.
- **Baseline re-measurement trigger:** whether the portfolio decision changes scope, risk appetite, operating model, ownership, funding, or roadmap sequencing enough to revisit the baseline.
- **Backlog and handoff:** incomplete evidence, stale rollup, cost/capacity decision, risk/value conflict, or missing action owner captured with owner, acceptance test, target date, evidence location, and recheck trigger.

## Technical capture fields

| Area | Fields to capture |
|---|---|
| Scorecard | Coverage, residual risk, assurance, operating health, cost/capacity, maturity, exception age, dependency, roadmap owner. |
| Prioritization | Risk, value, cost/capacity, coverage, dependency, confidence, weights, rejected alternatives, decision forum. |
| Exception concentration | Exception by owner, control/session, platform dependency, age/severity, recurrence, and escalation route. |
| Baseline feedback | Baseline change trigger, policy question, operating-model gap, funding assumption, roadmap sequencing change, next baseline owner. |

## Facilitation flow

1. Confirm the customer has a bounded portfolio question, owners, receiving forum, and approved records location. If not, stop the decision and create a blocker backlog item.
2. Copy [`templates/decision-record.template.md`](templates/decision-record.template.md) into the customer-owned records system. Complete only safe references in this repository.
3. Inspect the Microsoft control path: **Agent 365 and control-plane records, Azure Cost Management, operating evidence, roadmap, and the baseline**.
4. Build the portfolio rollup by reference: inventory, exception register, cost/capacity view, operating evidence, roadmap, and baseline.
5. Record source lineage, freshness, coverage limits, owner, and evidence location for every rollup source before making a recommendation.
6. Ask: **Which portfolio item should continue, pause, retire, fund, defer, or route, and who owns the roadmap action?**
7. Classify the route: complete rollup, incomplete evidence, cost/capacity decision, risk/value conflict, no action owner, or baseline re-measurement trigger.
8. Record one result in the customer system: approve, defer, reject, route, or blocked.
9. Create a portfolio-governance backlog item for each unowned exception, stale control-plane record, incomplete evidence source, unfunded roadmap item, missing operating evidence, cost/capacity decision, risk/value conflict, no action owner, or re-measurement trigger.
10. Handoff the completed decision record and backlog references to the receiving owner. Keep final evidence only in the customer-approved records system.

## Decision criteria

- **Approve** when source lineage, freshness, coverage limits, prioritization rationale, roadmap owner, evidence location, acceptance test, target date, handoff, and baseline re-measurement trigger are complete.
- **Defer** when evidence is incomplete, stale, non-comparable, unowned, lacks a freshness/coverage statement, or lacks a target date but can be completed by a named owner.
- **Reject** when the portfolio item cannot meet the bounded risk, value, cost, capacity, or operating-readiness goal.
- **Route** when finance, FinOps, platform capacity, risk, roadmap, evidence, operating, exception, or baseline owner must decide first.
- **Blocked** when ownership, forum authority, evidence location, cost/capacity basis, roadmap ownership, or scope clarity prevents a decision.

## Scenario routes

| Scenario | Route | Required handoff |
|---|---|---|
| Complete rollup | Approve / handoff | Source lineage, freshness, coverage limits, prioritization rationale, roadmap owner, target date, and baseline trigger are complete. |
| Incomplete or stale evidence | Defer | Missing source, stale state, coverage limit, owner, target date, evidence location, and recheck trigger are recorded. |
| Cost or capacity decision | Route | Finance/FinOps/capacity owner, cost basis, capacity assumption, funding decision date, and roadmap impact are named. |
| Risk/value conflict | Route | Portfolio forum receives risk/value rationale, exception status, value hypothesis, stop/continue criteria, and owner. |
| No action owner | Block / defer | Roadmap owner, implementation owner, evidence owner, receiving process, and assignment forum are recorded. |
| Portfolio decision changes foundation assumptions | Baseline re-measurement | Baseline owner receives scope/risk/operating-model/ownership/funding/roadmap trigger and target review date. |

## Session-specific considerations

When completing the shared decision record, capture the exception register, governance roadmap, portfolio review, operating evidence, cost/capacity view, source lineage, freshness, coverage limits, prioritization rationale, roadmap owner, and baseline re-measurement trigger references.

## Handoff

Handoff to portfolio governance board, executive sponsor, roadmap owner, finance/FinOps owner, capacity owner, control-plane steward, operating evidence owner, baseline owner, and session owners as applicable. The receiving owner accepts only decisions or backlog items with clear acceptance tests, target dates, evidence locations, exception status, freshness/coverage statements, and recheck triggers. Keep final records in the customer-approved system.
