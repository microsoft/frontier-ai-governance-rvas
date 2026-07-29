# S0 · Governance Baseline & Operating Model: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-29 · Verify current customer authority, Microsoft service coverage, and evidence locations before delivery.

## Baseline decision route

S0 does not create a governance program. It answers one practical question:
which technical blocker must be closed first for a bounded AI pilot?

1. Name the pilot, service path, environment, decision owner, and evidence
   location.
2. Identify the first blocker that prevents safe downstream work.
3. Route the blocker to the owner who can inspect the Microsoft surface.
4. Stop if no owner, evidence location, or bounded pilot exists.

## Decision-owner matrix

| Owner type | Owns the go/no-go for | Typical Microsoft surface |
|---|---|---|
| Sponsor | Whether the pilot remains in scope. | Customer records system. |
| Identity owner | Agent, host, delegated, gateway, and resource authority. | Entra ID, Entra Agent ID, managed identity, app registration. |
| Data/privacy owner | Source exposure, classification, DLP/audit route, retention. | Microsoft Purview, SharePoint, audit/eDiscovery, DLP. |
| Platform owner | Hosting pattern, gateway, network, telemetry, catalog route. | Foundry, APIM, Azure landing zone, Private Link, Azure Monitor, API Center. |
| Engineering owner | Build path, model/tool/data package, promotion gates. | Foundry Agent Service, Copilot Studio, Microsoft 365 extensibility, Azure apps. |
| Security/SOC owner | Runtime control placement, response route, adversarial findings. | Defender, Sentinel, APIM, Content Safety, Prompt Shields. |
| Evaluation owner | Scenario set, evaluator/rubric, baseline/candidate comparison. | Foundry evaluations, manual rubric, CI/CD evaluation. |
| Operations/FinOps owner | Signals, alerts, correlation, cost/capacity, validation. | Azure Monitor, Application Insights, Log Analytics, Cost Management. |
| Portfolio owner | Cross-workload priority and baseline feedback. | Customer register plus safe Microsoft references. |

## Technical blocker taxonomy

| Blocker | Route to | Minimum acceptance check |
|---|---|---|
| No decision owner | Sponsor | Named owner and approved record location. |
| Agent identity unclear | Identity owner | Host identity, agent identity, authority mode, disable/audit route. |
| Data path unclear | Data/privacy owner | Source -> prompt/retrieval/tool/response/log path and minimization point. |
| Platform route unknown | Platform owner | Caller -> gateway/app/model/tool/data/telemetry route with owner. |
| Tool/API authority broad | API/tool owner | Consumer, operation, scope, quota, audit, withdrawal path. |
| Runtime evidence missing | Security/SOC owner | Control point, telemetry/correlation, response and retention route. |
| Evaluation cannot be trusted | Evaluation owner | Scenario set, evaluator/rubric, baseline, threshold owner, limitation. |
| Operating signal missing | Operations/FinOps owner | Signal coverage, correlation, alert owner, cost/capacity owner. |
| Cross-workload pattern | Portfolio owner | Population, source lineage, dependency cluster, next technical action. |

## Evidence system fields

Every downstream artifact should be able to point back to:

| Field | Purpose |
|---|---|
| Scenario / route / change | Keeps the decision bounded. |
| Microsoft service path | Prevents generic governance language. |
| Owner | Names who can inspect or fix the blocker. |
| Safe evidence reference | Points to customer-owned records without copying evidence. |
| Acceptance check | States what would unblock the next technical action. |
| Decision | Proceed, defer, route, reject, or block. |

## Boundary note

S0 makes no tenant, platform, policy, access, budget, production, evidence
movement, or compliance decision. It selects a technical blocker and owner.

## Related references

- [Governance capability guide](../reference/governance-capability-guide.md): capability and availability context.
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md): technical package shape.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md): official reference sources.
