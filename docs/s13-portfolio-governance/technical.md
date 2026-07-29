# S13 · Portfolio Governance & Continuous Improvement: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Agent 365, Microsoft control-plane records, Azure Cost Management, operating evidence, reporting, analytics, and governance capabilities vary by tenant, license, region, product maturity, and configuration. Verify official docs and customer records before delivery.

## Microsoft default

Default to Agent 365 and Microsoft control-plane records where available, Azure Cost Management and FinOps records for investment decisions, control-plane and operating evidence for coverage and drift, and the S0 baseline for re-measurement. S13 turns session decisions into the next portfolio roadmap.

## Decision tree

1. **If Agent 365, Entra, Foundry, Azure API Center, and operating records cover the portfolio question**, roll them up into the customer scorecard.
2. **If evidence is mixed or incomplete**, use the control-plane register as the reconciliation spine and show coverage limits.
3. **If spend or capacity is the main decision**, use Azure Cost Management, Foundry/project context, PTU/committed-capacity allocation, and FinOps analysis.
4. **If risk, value, maturity, and dependency priorities conflict**, use a hybrid triage with weights and owner agreement.
5. **If no owner can act on the roadmap**, route or defer rather than create a dashboard with no decision path.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Portfolio reporting | Agent 365/Entra/Foundry/API Center/control-plane/operating rollup into customer scorecard | approved GRC/BI tool is authoritative and preserves lineage |
| Prioritization | risk + value + maturity + dependency triage using S0 baseline and control-plane/operating evidence | legal/regulatory cycle imposes a stricter order |
| Continuous improvement | quarterly portfolio review with event-driven triggers | higher-risk portfolio requires shorter cadence |

## Portfolio scorecard field model

| Field group | Example fields | Source route |
|---|---|---|
| Coverage | Total scoped agents, cataloged agents, uncataloged findings, supported/unsupported workloads, stale records. | Control-plane register and platform records. |
| Residual risk | Open high-risk findings, expired exceptions, unowned blockers, repeated control gaps, accepted-risk expiry. | Runtime, evaluation, red-team, catalog, and in-process decision records. |
| Assurance | Evaluation coverage, red-team status, runtime-control evidence, release-gate status, retest status. | Runtime, evaluation, red-team, and release records. |
| Operating health | Alert trend, incident/backlog trend, telemetry gaps, latency/cost/capacity signal, support owner. | S11 operating records. |
| Cost/capacity | Cost center/tag, model/deployment spend, PTU/committed capacity, quota pressure, forecast owner. | Azure Cost Management, Foundry/project, FinOps record. |
| Maturity | S0 baseline score, current evidence status, movement rationale, blocked domains. | S0 baseline and session closeouts. |
| Exception age | Exception count, age bucket, owner, expiry, escalation, recurrence. | Exception register and S13 forum. |
| Dependency | Shared identity, tool/API, data source, model, gateway, platform, or owner dependency. | Platform, tool/API, control-plane, and operating records. |
| Roadmap | Initiative, owner, target date, funding/capacity status, decision forum, next review trigger. | Portfolio roadmap. |

## Prioritization mechanics

Use weights only when the governance forum owns them. Scores are decision aids,
not proof of value or risk reduction.

| Dimension | Suggested scale | Notes |
|---|---|---|
| Risk reduction | 1-5 | Higher when item closes high-impact residual risk, expired exception, or repeated control gap. |
| Business value | 1-5 | Higher when owner has a measurable outcome and adoption route. |
| Cost/capacity impact | 1-5 | Higher when spend/capacity pressure or savings opportunity is material. |
| Coverage improvement | 1-5 | Higher when item improves many agents, shared controls, or critical dependency visibility. |
| Dependency leverage | 1-5 | Higher when item unblocks multiple sessions, teams, or roadmap items. |
| Confidence | 1-5 | Penalize stale, unsupported, or thin evidence. |

Example portfolio formula for discussion:

```text
priority_score =
  (risk_weight * risk_reduction) +
  (value_weight * business_value) +
  (coverage_weight * coverage_improvement) +
  (dependency_weight * dependency_leverage) -
  (cost_weight * cost_or_capacity_burden)
```

Record the weights, owner, alternatives rejected, and decision forum. Do not use
the formula as automatic funding approval.

## Exception concentration and dependency views

| View | Use |
|---|---|
| Exception by owner | Finds overloaded or missing accountable teams. |
| Exception by control domain | Shows repeated identity, data, tool/API, runtime, evaluation, catalog, or operating gaps that may need baseline or policy work. |
| Exception by platform dependency | Identifies shared gateway, identity, data source, model, or telemetry blockers. |
| Exception by age/severity | Escalates expired or high-impact items. |
| Dependency cluster | Groups roadmap items that should be sequenced together. |

## S13-to-S0 feedback loop

| Portfolio signal | S0 action |
|---|---|
| Repeated ownership gap | Revisit decision rights, RACI, or forum cadence. |
| Repeated evidence gap | Update baseline evidence-system expectations. |
| New risk appetite issue | Open S0 policy/baseline question for sponsor decision. |
| Cost/capacity pressure | Revisit funding, prioritization, or service tier assumptions. |
| Roadmap dependency concentration | Re-baseline scope and sequencing assumptions. |
| Matured control with stable evidence | Record maturity movement and next review cadence. |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Agent/control coverage | Agent 365, Entra Agent ID, Azure API Center, Foundry project, S9 register |
| Operating health | S11 Azure Monitor/Application Insights/Foundry observability records, alert/drift review |
| Cost and capacity | Azure Cost Management, budgets, tags, PTU/committed capacity, FinOps Toolkit analysis |
| Assurance backlog | runtime, evaluation, and red-team accepted evidence, findings, exceptions, retest status |
| Baseline movement | S0 maturity baseline, S13 roadmap, owner adoption status, review cadence |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Portfolio report | every score or trend links to a customer-held source, owner, freshness date, and coverage limit | Portfolio/governance owner |
| Prioritization | roadmap items show risk/value/maturity/dependency rationale, rejected alternatives, owner, and target date | Executive sponsor |
| Re-baseline | S0 baseline questions are revisited with evidence of movement, no movement, or blocked status | Governance forum |
| Continuous review | cadence, event triggers, metric definitions, interpretation owner, and next review date are recorded | S13 portfolio owner |

## Boundary note

S13 creates the portfolio roadmap and next baseline re-measurement; it creates no dashboard, policy, budget, or production approval.

## Related references

- [S13 Concepts](concepts.md): portfolio evidence limits, exception concentration, prioritization, maturity movement, and the S0 feedback loop.
- [S0 technical decisions](../s0-foundations/technical.md), [S9 technical decisions](../s9-control-plane/technical.md), and [S11 technical decisions](../s11-operate-measure/technical.md).
- [Governance capability guide](../reference/governance-capability-guide.md).
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
