# S13 Portfolio Governance Decision Record

Copy this template into the customer's approved records system. Use it to record the required portfolio-governance decision for S13 Portfolio Governance.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Scope

| Field | Record |
|---|---|
| Portfolio slice / pilot set / roadmap item | |
| Portfolio question | |
| Decision owner | |
| Roadmap owner | |
| Implementation owner | |
| Evidence owner | |
| Finance / FinOps / capacity owner if applicable | |
| Receiving forum / process | |
| Approved records location | |
| Target date | |

## Portfolio rollup

Default path: **Agent 365 and control-plane records, Azure Cost Management, operating evidence, roadmap, and the baseline**

| Source | Safe reference | Freshness / review date | Coverage limit | Owner |
|---|---|---|---|---|
| Agent 365 / control-plane inventory | | | | |
| Exception register | | | | |
| Azure Cost Management or capacity view | | | | |
| Operating evidence | | | | |
| Roadmap / funding / sequencing record | | | | |
| Baseline / operating-model record | | | | |

## Prioritization

| Field | Record |
|---|---|
| Decision options | Continue / pause / retire / fund / defer / route / blocked |
| Risk rationale | |
| Value rationale | |
| Cost or capacity rationale | |
| Operating readiness rationale | |
| Exception status and impact | |
| Prioritization decision | |
| Stop / continue / recheck criteria | |
| Roadmap impact | |

## Scenario route

| Scenario field | Record |
|---|---|
| Route selected | Complete rollup / incomplete evidence / cost-capacity decision / risk-value conflict / no action owner / baseline re-measurement trigger |
| Incomplete, stale, or non-comparable evidence | |
| Cost, capacity, or funding decision needed | |
| Risk/value conflict | |
| Missing action owner | |
| Baseline re-measurement trigger or no-trigger rationale | |
| Receiving owner and process | |

## Customer decision

| Decision field | Record |
|---|---|
| Result (approve / defer / reject / route / blocked) | |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Defer or blocker criteria | |
| Exception status | None / proposed / accepted / rejected |
| Backlog item to create | |
| Handoff owner and customer process | |
| Release, roadmap, or funding impact | |
| Next review trigger | |

## Exception

Complete this section only when the Microsoft default is not used or when the customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Affected portfolio item | |
| Source limitation | |
| Residual risk | |
| Value or cost impact | |
| Equivalent control or compensating review if one exists | |
| Owner | |
| Evidence location | |
| Acceptance test | |
| Target date | |
| Roadmap impact | |
| Review trigger | |

## Backlog and handoff

Create a portfolio-governance backlog item for each unowned exception, stale control-plane record, incomplete evidence source, missing freshness/coverage statement, unfunded roadmap item, missing operating evidence, cost/capacity decision, risk/value conflict, no action owner, or baseline re-measurement trigger.

| Backlog field | Record |
|---|---|
| Backlog item | |
| Microsoft control path | |
| Owner | |
| Evidence location | |
| Accepted when | |
| Freshness / coverage requirement | |
| Exception if any | |
| Target date | |
| Recheck trigger | |
| Handoff process | |

The receiving owner accepts only backlog items with clear acceptance tests, target dates, evidence locations, exception status, freshness/coverage statements, and recheck triggers. Keep final records in the customer-approved system.

## Filled example

Work item "prioritize pilot cohort for next funding review"; evidence location "customer-approved inventory, exception, cost, operating, roadmap, and baseline references"; accepted when source lineage, freshness, coverage limits, risk/value/cost rationale, roadmap owner, target date, baseline re-measurement trigger, and handoff owner are recorded.
