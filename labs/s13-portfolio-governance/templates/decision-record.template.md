# S13 Portfolio Decision Record

Copy this template into the customer's approved records system. Use it to record
the required portfolio-governance decision for S13 Portfolio Evidence & Roadmap.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, cost exports, inventory exports, dashboards, live configuration, access grants, tenant changes, runtime proof, enforcement evidence, funding approval, compliance certification, or production approval claims in this repository. Do not change tenant configuration or live policy during the lab.

## Portfolio review card

| Field | Record |
|---|---|
| Portfolio slice / pilot set / roadmap item | |
| Population definition | |
| Review period | |
| Portfolio question | |
| Decision forum / process | |
| Included scope | |
| Excluded scope | |
| Portfolio decision owner | |
| Roadmap owner | |
| Risk owner | |
| Evidence owner | |
| Control-plane steward | |
| Operating review owner | |
| Evaluation / assurance owner if applicable | |
| Finance / FinOps / capacity owner if applicable | |
| Baseline owner | |
| Approved records location | |
| Evidence limits | |
| Stop condition | |
| Target date / review trigger | |

## Source lineage and coverage

| Source family | Safe reference | Source owner | Source-of-record field / join key | Freshness date | Refresh cadence | Population | Exclusions | Coverage limit | Interpretation owner |
|---|---|---|---|---|---|---|---|---|---|
| Inventory / control plane | | | | | | | | | |
| Identity / access | | | | | | | | | |
| Tool / API / action | | | | | | | | | |
| Model / deployment | | | | | | | | | |
| Assurance | | | | | | | | | |
| Operating health | | | | | | | | | |
| Cost / capacity | | | | | | | | | |
| Exception / risk register | | | | | | | | | |
| Roadmap / funding / sequencing | | | | | | | | | |
| Baseline / operating model | | | | | | | | | |

## Scorecard field records

| Scorecard field | Metric or statement | Source reference | Source owner | Freshness date | Population | Exclusions | Coverage limit | Interpretation owner | Action implication |
|---|---|---|---|---|---|---|---|---|---|
| Coverage | | | | | | | | | |
| Residual risk | | | | | | | | | |
| Assurance | | | | | | | | | |
| Operating health | | | | | | | | | |
| Cost / capacity | | | | | | | | | |
| Maturity | | | | | | | | | |
| Exception age | | | | | | | | | |
| Dependency | | | | | | | | | |
| Roadmap | | | | | | | | | |
| Owner readiness | | | | | | | | | |
| Confidence | | | | | | | | | |

## Exception concentration

| Field | Record |
|---|---|
| Concentration view | Owner / control domain / platform / identity / model / gateway / data / tool/API / telemetry / age-severity / expiry / recurrence / accepted-risk pressure / other |
| Population | |
| Pattern | |
| Affected items | |
| Shared dependency | |
| Risk consequence | |
| Owner | |
| Escalation route | |
| Closure criterion | |

## Dependency cluster

| Field | Record |
|---|---|
| Cluster name | |
| Dependency type | Identity / gateway / tool/API / model / data source / telemetry / capacity / policy / funding / ownership / release-change / other |
| Blocked roadmap items | |
| Sequence owner | |
| First unblock action | |
| Downstream effects | |
| Risk if ignored | |
| Review trigger | |

## Prioritization

| Dimension | Weight if used | Score / assessment | Rationale | Evidence reference | Owner |
|---|---|---|---|---|---|
| Risk reduction | | | | | |
| Business value | | | | | |
| Cost / capacity impact | | | | | |
| Coverage improvement | | | | | |
| Dependency leverage | | | | | |
| Maturity movement | | | | | |
| Urgency | | | | | |
| Confidence | | | | | |
| Effort / complexity | | | | | |

| Prioritization field | Record |
|---|---|
| Weight owner / forum | |
| Alternatives rejected | |
| Uncertainty / sensitivity | |
| Selected action implication | Continue / pause / retire / fund / defer / route / block / monitor / re-baseline / open policy question |

## Roadmap action and owner readiness

| Field | Record |
|---|---|
| Roadmap action | |
| Action rationale | |
| Accountable owner | |
| Implementation owner | |
| Evidence owner | |
| Funding / capacity owner if applicable | |
| Dependency owner if applicable | |
| Target date | |
| Acceptance test | |
| Evidence reference | |
| Exception status | None / proposed / accepted / expired / rejected / needs escalation |
| Blocked-by list | |
| Next review trigger | |

## Baseline feedback

| Field | Record |
|---|---|
| Trigger | Repeated ownership gap / repeated evidence gap / risk appetite issue / cost-capacity pressure / dependency concentration / matured control / stale baseline assumption / policy ambiguity / forum cadence / funding model / other |
| Baseline question | |
| Owner | |
| Evidence references | |
| Target forum | |
| Accepted when | |
| Review trigger | |

## Customer decision

| Decision field | Record |
|---|---|
| Result | Continue / pause / retire / fund / defer / route / blocked |
| Customer decision rationale | |
| Evidence reference | |
| Accepted when | |
| Defer or blocker criteria | |
| Exception status | None / proposed / accepted / expired / rejected / needs escalation |
| Backlog item to create | |
| Handoff owner and customer process | |
| Release, roadmap, funding, or baseline impact | |
| Next review trigger | |

## Exception

Complete this section only when the Microsoft default is not used or when the
customer accepts residual risk.

| Exception field | Record |
|---|---|
| Reason | |
| Affected portfolio item | |
| Source limitation | |
| Residual risk | |
| Value or cost impact | |
| Equivalent control or compensating review if one exists | |
| Owner | |
| Evidence reference | |
| Acceptance test | |
| Target date | |
| Roadmap impact | |
| Expiry / review date | |
| Review trigger | |

## Backlog and handoff

Create a portfolio-governance backlog item for each unowned exception, stale
control-plane record, incomplete evidence source, hidden coverage limit,
unfunded roadmap item, missing operating evidence, expired accepted-risk item,
cost/capacity decision, risk/value conflict, dependency cluster, no action
owner, framework/assurance route, or baseline feedback trigger.

| Backlog field | Record |
|---|---|
| Backlog item | |
| Source lineage requirement | |
| Owner | |
| Evidence reference | |
| Accepted when | |
| Freshness / coverage requirement | |
| Exception if any | |
| Target date | |
| Recheck trigger | |
| Handoff process | |

The receiving owner accepts only backlog items with clear acceptance tests,
target dates, evidence locations, exception status, freshness/coverage
statements, owner, and recheck trigger. Keep final records in the
customer-approved system.

## Safe filled example

Work item: "prioritize pilot cohort for next roadmap review"; evidence
location: "customer-approved inventory, exception, cost, operating, roadmap, and
baseline references"; accepted when: "source lineage, freshness, coverage
limits, risk/value/cost rationale, roadmap owner, target date, baseline feedback
trigger, and handoff owner are recorded."
