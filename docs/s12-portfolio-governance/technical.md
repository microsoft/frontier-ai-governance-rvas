# S12 · Portfolio Evidence & Roadmap: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-30 · Agent 365, Microsoft control-plane records, Azure Cost Management, operating evidence, reporting, analytics, and governance capabilities vary by tenant, license, region, product baseline evidence, and configuration. Verify official docs and customer records before delivery.

## Workshop route

Default to Agent 365 and Microsoft control-plane records where available,
customer-approved exception and roadmap records, Azure Cost Management and
FinOps records for investment decisions, operating/evaluation/red-team records
for assurance and drift, and the foundation baseline for re-measurement.

1. Choose the portfolio slice and review period.
2. Define the decision question, owners, scope, and stop condition.
3. Trace source lineage and test coverage limits.
4. Compare decision fields across the portfolio slice.
5. Identify exception concentrations and dependency clusters.
6. Apply prioritization and trade-off mechanics.
7. Choose technical actions and confirm owner readiness.
8. Define baseline feedback triggers.
9. Decide continue, pause, retire, fund, defer, route, or block.

![S12 portfolio decision flow: portfolio review card, source-lineage and coverage, decision table, exception concentration, dependency clusters, prioritization, technical action, baseline feedback trigger, blocked gaps, and safe evidence boundary.](../assets/diagrams/s12-portfolio-to-s0-feedback-loop.svg)

## Source-system rollup walkthrough

Roll up concrete references from the sessions that already produced them. Do not
replace missing source records with guesses, framework labels, or score padding.

| Source | Open / inspect | Portfolio field to carry forward |
|---|---|---|
| S0 intake | Customer intake/backlog record for the candidate. | Sponsor, accountable owner, intended use, user population, platform path, target event, acceptance criteria. |
| S2 compliance | Purview/compliance record for the workload path. | Compliance state, unsupported data-path limits, retention/eDiscovery route, DLP boundary, open compliance gap. |
| S5 API/tool admission | API/tool admission record, API Center/API Management route, or tool catalog reference. | API/tool owner, schema/route, gateway state, permission boundary, unapproved or uncataloged tool gap. |
| S7 evaluation | Evaluation record and baseline/candidate result. | Scenario, threshold owner, unsupported slices, result state, retest owner. |
| S8 findings | Red-team/security/safety finding and remediation record. | Severity, exploitability or impact, remediation owner, exception expiry, retest plan, blocker state. |
| S9 inventory/control plane | Registry, identity, API/tool, Foundry, telemetry, lifecycle, and duplicate-record checks. | Owner match, orphan identity, uncataloged API, unmonitored deployment, stale lifecycle, duplicate record. |
| S10 operating/cost | Operating review, Log Analytics/App Insights, Azure Monitor, Cost Management, quota/capacity. | Alert/correlation coverage, latency/error/capacity/cost signal, incident route, budget/export, owner. |
| Customer backlog/change system | Roadmap, funding, dependency, release/change, or work item record. | Current status, blocker, target event, funding/capacity assumption, next accepted action. |

## Three-candidate rollup activity

Use exactly three candidate workloads unless the customer decision owner narrows
or expands the slice. Keep the ranking explainable instead of hiding blockers in
a single score.

| Candidate field | What to compare | Ranking use |
|---|---|---|
| Technical blocker | Missing owner, unsupported path, stale exception, unmonitored deployment, uncataloged API, evaluation gap, capacity gap, security finding, or duplicate initiative. | Blocks, defers, or sequences the candidate. |
| Risk | Open severity, compliance/data-path limit, security/safety finding, expired exception, unsupported claim, or operational blind spot. | Raises urgency or blocks promotion. |
| Value | Sponsor outcome, user/adoption signal, dependency leverage, cost/capacity impact, or roadmap commitment. | Supports continue, fund, or promote. |
| Dependency | Shared identity, API/tool, model, data source, gateway, telemetry, capacity, funding, owner, or change process. | Determines first unblock action and downstream effects. |
| Next action | Continue/promote, pause, retire, fund, defer, route, block, monitor, or re-baseline. | Produces owner-actionable portfolio work. |
| Confidence | Source freshness, source agreement, coverage, sampling, support status, exclusions, and interpretation owner. | Penalizes stale, unsupported, or non-comparable evidence. |

## Expected portfolio signals

| Signal | Meaning | Route |
|---|---|---|
| Promotable workload | Source references are current enough and no blocking S2/S5/S7/S8/S9/S10 gap prevents the next customer process. | Continue, fund, promote, or submit to change/release process. |
| Blocked workload | Required owner, evidence, remediation, evaluation, operating signal, funding/capacity, or records location is missing. | Block or defer with owner and acceptance check. |
| Unsupported workload | Product, region, connector, data path, API/tool route, monitoring, or compliance coverage is unsupported for the intended claim. | Route to platform/product/risk owner. |
| Duplicate initiative | Same workload, owner action, or dependency appears in multiple intake, portfolio, backlog, or change records. | Merge/split with portfolio owner. |
| Missing owner | Accountable, risk, API/tool, operations, FinOps, evidence, or receiving owner is absent. | Stop ranking reliance until assigned. |
| Missing operating signal | S10 telemetry, alert, incident route, cost/export, quota/capacity, or correlation signal is unavailable. | Route to operations/telemetry/FinOps owner. |
| Stale exception | Exception is expired or lacks recheck owner/date. | Route to risk owner; block promotion reliance. |

## Support limits

| Limit | Portfolio handling |
|---|---|
| Source unavailable or unsupported | Mark the field unusable for ranking until source owner provides route or accepts limitation. |
| Source stale or outside review period | Defer reliance or assign recheck before decision. |
| Sampled, aggregate-only, or non-comparable evidence | Preserve the limitation and lower confidence. |
| Score hides excluded high-risk workload | Split the population or block the aggregate conclusion. |
| Cost/capacity field lacks allocation owner | Route to FinOps/capacity owner before funding or sequencing reliance. |
| Framework mapping requested as certification | Route to assurance/legal/compliance owner; S12 does not certify. |

## Portfolio review card

| Field | Record |
|---|---|
| Portfolio slice | Pilot cohort, agent population, capability group, business unit, region, platform path, technical action set, exception set, dependency cluster, or cost/capacity scope. |
| Review period | Start/end date, refresh cadence, and expected next review. |
| Decision question | Continue, pause, retire, fund, defer, route, block, or re-baseline? |
| Included scope | Agents, workloads, controls, regions, business units, cost centers, evidence sources, and record types included. |
| Excluded scope | Items deliberately excluded and why. |
| Decision path | Customer owner process that can act on the recommendation. |
| Owners | Portfolio, roadmap, risk, evidence, control-plane, operating review, evaluation, red-team, data/privacy, platform, FinOps/capacity, and baseline owners as applicable. |
| Approved records location | Customer-approved system for completed decision and evidence references. |
| Evidence limits | Stale, missing, sampled, unsupported, non-comparable, or unavailable sources. |
| Stop condition | Condition that prevents a recommendation from being used for roadmap, funding, baseline, or policy action. |

## Trace source lineage and coverage

| Source family | Example references | Coverage fields |
|---|---|---|
| Inventory and control plane | Agent 365 where available, control-plane registry, Entra Agent ID, Foundry project, API Center, API Management, customer register. | Source owner, source-of-record field, explicit join key, population, stale state, unsupported tools, and excluded records. |
| Identity and access | Agent identity, managed identity, app registration, sponsor, authority mode, disabled state, review reference. | Identity owner, review date, orphan/shared identity count, disable-route gap, and accepted-risk status. |
| Tool/API/action | API/tool/MCP registry, gateway route, schema version, owner, lifecycle state, withdrawal path. | Catalog coverage, uncataloged tools, route mismatch, stale version, missing withdrawal owner. |
| Model/deployment | Baseline, candidate, fallback, deprecated, retired, deployment alias, capacity/cost owner, support owner. | Version coverage, fallback gap, retirement gap, capacity pressure, support boundary. |
| Assurance | Runtime-path acceptance, evaluation result, red-team remediation record, release-readiness handoff. | Evidence reference, accepted/diagnostic-only state, limitations, retest status, exception owner. |
| Operating health | Signal coverage, correlation, alert route, drift hypothesis, remediation validation, recurrence checks. | Signal owner, time window, sampled/excluded paths, alert owner, validation state, blind spots. |
| Cost/capacity | Azure Cost Management, Foundry/project cost, tags/dimensions, PTU/committed capacity, quota, budget/anomaly route. | Allocation owner, cost center, shared-cost assumption, capacity owner, forecast confidence, excluded spend. |
| Exceptions and risks | Exception register, accepted-risk items, unresolved blockers, issue/finding records. | Age, expiry, severity, recurrence, owner, escalation, closure criterion. |
| Roadmap and baseline | Roadmap, funding/sequencing record, owner-readiness register, foundation baseline questions. | target event, owner, funding status, dependency, baseline trigger, recheck owner process. |

## Compare decision fields

Each decision field uses the same field shape:

| Field | Record |
|---|---|
| Decision field | Coverage, residual risk, assurance, operating health, cost/capacity, baseline evidence, exception age, dependency, roadmap, owner readiness, or confidence. |
| Metric or statement | The specific count, status, trend, or decision claim. |
| Source reference | Customer-approved reference, not raw export. |
| Source owner | Person or role accountable for the source. |
| Freshness date | Date/time or review period covered. |
| Population | Included records. |
| Exclusions | Records, regions, business units, cost centers, tools, or evidence types excluded. |
| Coverage limit | Missing, stale, sampled, unsupported, non-comparable, or unavailable evidence. |
| Interpretation owner | Owner who accepted what the field can and cannot mean. |
| Action implication | Continue, pause, retire, fund, defer, route, block, or monitor. |

## Portfolio decision table field families

| Field family | Example fields | Decision use |
|---|---|---|
| Coverage | Total scoped agents, cataloged agents, uncataloged findings, supported/unsupported workloads, stale records, missing owners. | Shows whether the portfolio population is known enough to act. |
| Residual risk | Open high-risk findings, expired exceptions, unowned blockers, repeated control gaps, accepted-risk expiry. | Highlights risk concentration and escalation needs. |
| Assurance | Evaluation coverage, runtime-path acceptance, red-team status, release-readiness state, retest status. | Shows whether evidence supports reliance or only diagnostic backlog. |
| Operating health | Alert trend, incident/backlog trend, telemetry gaps, drift hypotheses, latency/cost/capacity signal, support owner. | Shows whether the fleet can be operated, not just built. |
| Cost/capacity | Cost center/tag, model/deployment spend, PTU/committed capacity, quota pressure, forecast owner, allocation confidence. | Supports funding, capacity, chargeback/showback, or optimization decisions. |
| Baseline evidence | Baseline score, current evidence status, movement rationale, blocked domains, confidence. | Supports movement/no-movement/revisit questions, not certification. |
| Exception age | Exception count, age bucket, owner, expiry, escalation, recurrence. | Finds expired or repeated accepted-risk pressure. |
| Dependency | Shared identity, tool/API, data source, model, gateway, platform, telemetry, or owner dependency. | Determines sequencing and unblock order. |
| Roadmap | Initiative, owner, target event, funding/capacity status, decision path, next recheck condition, blocked-by list. | Converts portfolio learning into owner-actionable work. |
| Owner readiness | Accountable owner, implementation owner, evidence owner, funding owner, receiving owner process, acceptance test. | Blocks unowned work from becoming fake roadmap. |
| Confidence | Evidence quality, freshness, support status, sampling, source agreement, interpretation owner. | Penalizes thin or stale evidence before prioritization. |

## Identify exception concentrations

| Field | Record |
|---|---|
| Concentration view | Owner, control domain, platform dependency, identity dependency, data source, model/deployment, gateway/tool/API, telemetry, age/severity, expiry, recurrence, or accepted-risk pressure. |
| Population | Included agents/workloads/exceptions and excluded items. |
| Pattern | Repeated gap or shared condition. |
| Affected items | Safe references to affected records. |
| Shared dependency | Platform, owner, service, model, gateway, data, identity, telemetry, policy, funding, or process dependency. |
| Risk consequence | Why the pattern matters to the portfolio. |
| Owner | Receiving owner for interpretation and closure. |
| Escalation route | owner process or authority if unresolved. |
| Closure criterion | What must change before the concentration is closed or downgraded. |

## Map dependency clusters

| Field | Record |
|---|---|
| Cluster name | Neutral description of shared dependency. |
| Dependency type | Identity, gateway, tool/API, model, data source, telemetry, capacity, policy, funding, ownership, or release/change. |
| Blocked technical actions | Safe references only. |
| Sequence owner | Owner who can order the unblock path. |
| First unblock action | Concrete next action with acceptance test. |
| Downstream effects | Which items can move after the unblock action. |
| Risk if ignored | Decision consequence. |
| Recheck condition | Date or event for rechecking the cluster. |

## Prioritization mechanics

Use weights only when the decision owner owns them. Scores are decision aids,
not proof of value, risk reduction, funding approval, or baseline movement.

| Dimension | Suggested scale | Notes |
|---|---|---|
| Risk reduction | 1-5 | Higher when item closes high-impact residual risk, expired exception, repeated control gap, or blocked accepted-risk review. |
| Business value | 1-5 | Higher when owner has a measurable outcome, user/adoption route, and service usage hypothesis. |
| Cost/capacity impact | 1-5 | Higher when spend, PTU/committed capacity, quota, or savings opportunity is material and allocated. |
| Coverage improvement | 1-5 | Higher when item improves many agents, shared controls, or critical dependency visibility. |
| Dependency leverage | 1-5 | Higher when item unblocks multiple teams, technical actions, or evidence routes. |
| Baseline movement | 1-5 | Higher when movement can be supported by evidence against a stable baseline question. |
| Urgency | 1-5 | Higher when expiry, incident pattern, customer commitment, regulatory date, or funding window is near. |
| Confidence | 1-5 | Penalize stale, unsupported, sampled, non-comparable, or thin evidence. |
| Effort/complexity | 1-5 | Higher effort reduces priority unless risk/value/dependency leverage justifies it. |

Example discussion formula:

```text
priority_score =
  (risk_weight * risk_reduction) +
  (value_weight * business_value) +
  (coverage_weight * coverage_improvement) +
  (dependency_weight * dependency_leverage) +
  (baseline_evidence_weight * baseline_evidence_movement) +
  (urgency_weight * urgency) +
  (confidence_weight * confidence) -
  (cost_weight * cost_or_capacity_burden) -
  (effort_weight * effort_or_complexity)
```

Record the weight owner, rationale, alternatives rejected, uncertainty,
sensitivity, and decision path. Do not use the formula as automatic ranking,
funding, or compliance logic.

## Choose technical actions

| Field | Record |
|---|---|
| Technical action | Continue, pause, retire, fund, defer, route, block, monitor, re-baseline, or open policy question. |
| Action rationale | Risk/value/cost/capacity/coverage/dependency/baseline evidence reason. |
| Accountable owner | Owner who accepts the action. |
| Implementation owner | Owner who will execute or coordinate work. |
| Evidence owner | Owner who will validate closure. |
| Funding/capacity owner | Required when the item changes spend, quota, PTU/committed capacity, support, or staffing. |
| Dependency owner | Required when shared blocker exists. |
| Target event | Date or event. |
| Acceptance test | Observable condition for completion. |
| Evidence reference | Customer-approved reference location. |
| Exception status | None, proposed, accepted, expired, rejected, or needs escalation. |
| Blocked-by list | Safe references to blockers. |
| Next recheck condition | Date, event, evidence update, exception expiry, or baseline review. |

## Define baseline feedback

| Trigger | Baseline question |
|---|---|
| Repeated ownership gap | Do decision rights, RACI, escalation path, or owner process cadence need to change? |
| Repeated evidence gap | Do evidence-system fields, source ownership, or retention expectations need to change? |
| New risk appetite issue | Does sponsor-level risk appetite or exception authority need clarification? |
| Cost/capacity pressure | Do funding, capacity, service tier, quota, or cost allocation assumptions need to change? |
| Roadmap dependency concentration | Does sequencing, ownership, or platform investment need to be re-baselined? |
| Matured control with stable evidence | Can baseline movement be recorded with supporting references and next cadence? |
| Stale baseline assumption | Is the original scope, platform assumption, owner model, or operating cadence still true? |
| Policy ambiguity | Does policy need clarification, exception criteria, or new decision rights? |

The record proposes a question, owner, evidence references, target owner process,
accepted-when condition, and recheck condition. It does not update policy or the
baseline by itself.

## Hard stops

| Stop condition | Required outcome |
|---|---|
| No approved records location | Block. Do not choose portfolio priorities. |
| Unknown population or review period | Defer until scope is defined. |
| Missing source lineage for a key metric | Defer or mark the decision field unusable. |
| Stale or non-comparable evidence without owner | Defer and create evidence backlog. |
| Score hides excluded high-risk workload | Block the aggregate conclusion or split the population. |
| Cost/capacity decision without allocation owner | Route to FinOps/capacity owner before prioritization reliance. |
| Unowned technical action | Defer or block until owner assignment is accepted. |
| Framework mapping requested as certification | Route to assurance/legal owner; do not issue a conformity conclusion. |
| Funding approval requested in the workshop | Route to customer funding process. |
| Baseline movement lacks stable evidence | Record no movement and route the evidence gap. |

## Acceptance tests

| Work item | Accepted when... | Receiving owner |
|---|---|---|
| Portfolio review card | population, review period, included/excluded scope, decision path, owners, records location, evidence limits, and stop condition are recorded | Portfolio owner |
| Source lineage | every decision field or claim links to source owner, freshness date, coverage limit, interpretation owner, and safe reference | Evidence owner |
| Decision table | field families include coverage, risk, assurance, operating, cost/capacity, baseline evidence, exceptions, dependencies, roadmap, owner readiness, and confidence where relevant | Portfolio/governance owner |
| Exception concentration | population, affected items, repeated pattern, shared dependency, owner, escalation, and closure criterion are recorded | Risk owner |
| Dependency cluster | dependency type, blocked items, sequence owner, first unblock action, downstream effect, and recheck condition are recorded | Roadmap owner |
| Prioritization | weights, rationale, rejected alternatives, uncertainty, decision path, and action implication are recorded | decision owner |
| technical action | owner, target event, acceptance test, evidence reference, exception status, blocked-by list, and next recheck condition are recorded | Roadmap owner |
| Baseline feedback | question, trigger, owner, evidence references, target owner process, accepted-when condition, and recheck condition are recorded | Baseline owner |

## Related references

- [S0 technical decisions](../s0-foundations/technical.md), [S9 technical decisions](../s9-control-plane/technical.md), and [S10 technical decisions](../s10-operate-measure/technical.md).
- [Governance capability guide](../reference/governance-capability-guide.md).
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).

## Boundary note

S12 sets portfolio priorities and a backlog. It creates no dashboard,
queries no live tenant, consolidates no raw evidence, approves no funding,
changes no policy, certifies no compliance, proves no runtime enforcement,
approves no production release, and changes no baseline.
