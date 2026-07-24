# S13 · Portfolio Governance & Continuous Improvement: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Agent 365, Microsoft control-plane records, Azure Cost Management, operating evidence, reporting, analytics, and governance capabilities vary by tenant, license, region, product maturity, and configuration. Verify official docs and customer records before delivery.

## Microsoft default

Default to Agent 365 and Microsoft control-plane records where available, Azure Cost Management and FinOps records for investment decisions, S9/S11 operating evidence for coverage and drift, and the S0 baseline for re-measurement. S13 turns session decisions into the next portfolio roadmap.

## Decision tree

1. **If Agent 365, Entra, Foundry, Azure API Center, and S11 records cover the portfolio question**, roll them up into the customer scorecard.
2. **If evidence is mixed or incomplete**, use the S9 control register as the reconciliation spine and show coverage limits.
3. **If spend or capacity is the main decision**, use Azure Cost Management, Foundry/project context, PTU/committed-capacity allocation, and FinOps analysis.
4. **If risk, value, maturity, and dependency priorities conflict**, use a hybrid triage with weights and owner agreement.
5. **If no owner can act on the roadmap**, route or defer rather than create a dashboard with no decision path.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Portfolio reporting | Agent 365/Entra/Foundry/API Center/S9/S11 rollup into customer scorecard | approved GRC/BI tool is authoritative and preserves lineage |
| Prioritization | risk + value + maturity + dependency triage using S0 baseline and S9/S11 evidence | legal/regulatory cycle imposes a stricter order |
| Continuous improvement | quarterly portfolio review with event-driven triggers | higher-risk portfolio requires shorter cadence |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Agent/control coverage | Agent 365, Entra Agent ID, Azure API Center, Foundry project, S9 register |
| Operating health | S11 Azure Monitor/Application Insights/Foundry observability records, alert/drift review |
| Cost and capacity | Azure Cost Management, budgets, tags, PTU/committed capacity, FinOps Toolkit analysis |
| Assurance backlog | S6/S7/S8 accepted evidence, findings, exceptions, retest status |
| Baseline movement | S0 maturity baseline, S13 roadmap, owner adoption status, review cadence |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Portfolio report | every score or trend links to a customer-held source, owner, freshness date, and coverage limit | Portfolio/governance owner |
| Prioritization | roadmap items show risk/value/maturity/dependency rationale, rejected alternatives, owner, and target date | Executive sponsor |
| Re-baseline | S0 baseline questions are revisited with evidence of movement, no movement, or blocked status | Governance forum |
| Continuous review | cadence, event triggers, metric definitions, interpretation owner, and next review date are recorded | S13 portfolio owner |

## Boundary note

S13 creates the portfolio roadmap and next S0 re-baseline; it creates no dashboard, policy, budget, or production approval.

## Related references

- [S13 Concepts](concepts.md): portfolio evidence limits, exception concentration, prioritization, maturity movement, and the S0 feedback loop.
- [S0 technical decisions](../s0-foundations/technical.md), [S9 technical decisions](../s9-control-plane/technical.md), and [S11 technical decisions](../s11-operate-measure/technical.md).
- [Governance capability guide](../reference/governance-capability-guide.md).
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
