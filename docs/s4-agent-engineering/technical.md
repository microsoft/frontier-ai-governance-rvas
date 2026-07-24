# S4 · Agent Engineering: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Microsoft Foundry Agent Service, Copilot Studio, Microsoft 365 Copilot extensibility, model availability, fine-tuning, and deployment features vary by tenant, region, license, quota, and product maturity. Verify official docs before delivery.

## Microsoft default

Default to the Microsoft implementation path that fits the candidate: Copilot Studio, Microsoft Foundry Agent Service, Microsoft 365 Copilot extensibility, workflow automation, or a custom Azure app on Foundry models. S4 records path selection, model/deployment choice, admission, and promotion gates.

## Decision tree

1. **If a low-code business workflow fits**, choose Copilot Studio and apply Power Platform governance.
2. **If a pro-code agent needs tools, traces, evaluations, or custom orchestration**, choose Microsoft Foundry Agent Service or a custom Azure app on Foundry models.
3. **If the agent lives in the Microsoft 365 productivity surface**, choose Microsoft 365 Copilot extensibility and Agent 365 governance where available.
4. **If deterministic automation is enough**, choose workflow automation instead of an agent.
5. **If production evidence is missing**, hold at DEV or PRE and route S6/S7/S9/S11 prerequisites.

| Path | Microsoft control surface to inspect | Admission emphasis |
|---|---|---|
| Copilot Studio | Power Platform environment, DLP policy, connector inventory, maker ownership | connector and environment governance |
| Foundry Agent Service | Foundry project, agent, model deployment, tool, trace, evaluation records | tool, model, telemetry, and evaluation readiness |
| Custom Azure app | app repo/release, managed identity, API Management route, Azure Monitor telemetry | full engineering ownership |
| M365 Copilot extensibility | M365 Copilot admin/extension records, Agent 365 where available, Graph connector/data controls | M365 data and extension governance |
| Workflow automation | Power Automate/Logic Apps/run history/connector records | deterministic change control |
| Prototype isolation | sandbox owner, data boundary, expiration date | explicit non-production constraint |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Path fit | Copilot Studio, Foundry, M365 Copilot extensibility, Power Platform, or Azure app architecture record |
| Model/deployment | Foundry model deployment alias, quota/capacity, region, version owner, fine-tuning proposal if any |
| Admission | authority archetype, human-control point, S6 runtime proof need, S7 evaluation plan, S8 red-team trigger |
| Promotion | DEV/PRE/PRO labels, release manifest, rollback owner, customer change approval record |
| Catalog/handoff | Azure API Center or S9 register entry, S11 operations owner |

## Decision matrix

| Stage | Entry decision | Accepted when... | Next route |
|---|---|---|---|
| DEV | bounded engineering/prototype admission | owner, data boundary, path choice, and non-production label are recorded | S6/S7 backlog |
| PRE | integration/certification admission | S3 platform profile, S6 runtime proof plan, S7 evaluation plan, and rollback owner are recorded | customer release process |
| PRO | customer production decision | S9 lifecycle entry, S11 support/alert route, accepted S7 evidence, and customer approvals are in the approved record | operations |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Path selection | selected path, rejected alternatives, assumptions, and owner are recorded | Engineering owner |
| Model selection | deployment alias, model/version owner, residency/quota/cost limits, and fine-tuning rationale if any are recorded | Platform/model owner |
| Admission | authority archetype maps to required safety, evaluation, red-team, and human-control gates | Release owner |
| Promotion | DEV/PRE/PRO gate, rollback owner, and material-change trigger are recorded | Change authority |

## Boundary note

S4 selects and admits a path; deployment, configuration, and production approval stay with the customer process.

## Related references

- [S4 Concepts](concepts.md): authority model, path choices, material changes, retirement.
- [S6 technical decisions](../s6-security-runtime/technical.md), [S7 technical decisions](../s7-evaluation/technical.md), and [S9 technical decisions](../s9-control-plane/technical.md).
- [Quality, cost, latency & rollout guide](../reference/quality-cost-latency-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
