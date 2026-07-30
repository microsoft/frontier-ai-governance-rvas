# S0 · Technical Intake & Feasibility Triage: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-30 · Verify current customer authority, Microsoft
    service coverage, and evidence locations before delivery.

## Microsoft default

Start with the customer-owned Microsoft surface that already exists for the
candidate: Azure subscription/resource group, Microsoft Foundry project, Copilot
Studio environment, Microsoft 365 extension record, Entra identity, API
gateway/catalog, Purview/Defender/Monitor signal, or customer backlog item.
If none exists, classify the candidate as discovery-only instead of forcing it
into a downstream session.

## Intake runbook

1. **Choose one candidate.** Name the workload, agent, capability, environment,
   lifecycle state, sponsor, technical owner, and approved records location.
2. **Open or identify the primary surface.** Use the customer portal, backlog,
   architecture record, or safe reference for the Foundry project, Copilot
   Studio environment, M365 extension, Azure app, APIM/API Center record, Entra
   identity, Purview record, Monitor workspace, or prototype sandbox.
3. **Check inspectability.** Confirm the team can see enough to inspect
   identity, data, platform route, tool/API path, telemetry, and owner records
   without changing configuration or exporting customer evidence.
4. **Classify the first technical blocker.** Pick exactly one first blocker:
   identity, data, platform, build path, tool/API, runtime, evaluation,
   red-team, control-plane, operations, LLMOps, portfolio, or intake readiness.
5. **Route the blocker.** Assign the next technical session or customer owner
   with an accepted-when condition and recheck trigger.
6. **Stop if unsafe or vague.** Block when the candidate has no owner, no
   evidence location, no inspectable system, or only a production target without
   an approved read-only review.

## Source-system inspection checklist

| Surface | Open or identify | Ready signal | Blocked signal |
|---|---|---|---|
| Azure subscription/resource group | Subscription, resource group, workload resources, environment tag, owner. | Candidate maps to a known non-production or read-only production resource. | No access, no owner, unknown subscription, or live-only target. |
| Microsoft Foundry | Foundry project, model deployment, agent/app, data/tool connections, tracing/evaluation area. | Project and workload references are visible enough for S2/S3/S4/S7 routing. | Project unknown, unsupported region/SKU, missing owner, or no safe test target. |
| Copilot Studio / Power Platform | Environment, solution, agent, topics/actions, connectors, DLP policy, maker/admin owner. | Environment and connector owner are known. | Personal environment, unmanaged connector, no DLP owner, or unclear publication state. |
| Microsoft 365 extensibility | App/agent metadata, Graph permissions, admin review route, distribution state. | Admin owner and permission route are visible. | Unknown app owner, unreviewed Graph scope, or unsupported extension path. |
| Entra | App registration, enterprise app, managed identity, service principal, user/delegated path. | Identity owner can inspect authority in S1. | Missing app identity, unmanaged secret, unclear consent, or no owner. |
| API gateway/catalog | APIM API/operation, API Center record, connector inventory, MCP/tool registry, owner. | Tool/API can enter S5 admission. | Direct unmanaged endpoint, no operation owner, or no withdrawal path. |
| Data/compliance | Source, retrieval/index, prompt/context boundary, output/log path, Purview or records route. | Data path can enter S2. | Data owner missing, minimization unknown, unsupported evidence path. |
| Telemetry/security | App Insights, Log Analytics, Azure Monitor, Defender, Sentinel, SOC queue, cost/quota source. | Runtime/operations route can be queried. | No correlation field, no telemetry owner, no retention owner, or no SOC route. |
| Customer backlog/change system | Work item, risk record, release item, portfolio item, exception, owner. | Downstream action can be tracked by the customer. | No source of truth or stale/unowned item. |

## Result states

| State | Meaning | Next action |
|---|---|---|
| Ready for technical session | Owner, surface, evidence location, and first inspection target exist. | Route to the named session with the source-system reference. |
| Blocked by access | The team cannot open the system needed for inspection. | Assign access owner; recheck only after access exists. |
| Blocked by owner | No one can explain or accept the candidate path. | Sponsor names owner or candidate is blocked. |
| Blocked by evidence handling | Evidence would need unsafe export or no approved records location exists. | Create customer records route before continuing. |
| Unsupported or wrong route | The requested Microsoft surface does not fit the candidate. | Route to alternate product owner or mark unsupported. |
| Discovery-only | Candidate is not yet a workload, app, agent, path, or change. | Return to customer discovery; do not enter downstream sessions. |

## Triage-to-session map

| First inspectable gap | Minimum evidence before routing | Session |
|---|---|---|
| User/app/agent authority | Identity reference and permission surface. | S1 |
| Source, prompt, retrieval, tool response, output, logs | Data path owner and source reference. | S2 |
| Caller, gateway/app, backend, network, telemetry | Route owner and platform reference. | S3 or S6 |
| Build path, authority, lifecycle stage | Candidate card and engineering owner. | S4 |
| Tool, connector, API, operation, auth, quota | Tool/API owner and operation reference. | S5 |
| Evaluation question, scenario set, threshold | Candidate change and scenario owner. | S7 |
| Authorized adversarial target | Written authorization path and non-production target. | S8 |
| Inventory mismatch or stale ownership | Source systems to reconcile. | S9 |
| Alert, query, cost, quota, support | Telemetry/cost source and operating owner. | S10 |
| Baseline/candidate change package | Release references and rollback/fallback owner. | S11 |
| Multiple workloads competing for priority | Source records for each workload. | S12 |

## Intake card

| Field | Required value |
|---|---|
| Candidate reference | Safe name or customer record reference; no tenant IDs, endpoints, prompts, or telemetry exports. |
| Environment | Dev, test, pre-release, production read-only, prototype, discovery-only, or unknown. |
| Primary Microsoft surface | Foundry, Copilot Studio, M365, Azure app, Entra, APIM, API Center, Purview, Defender, Monitor, Cost, or other. |
| Technical owner | Person or group who can open the surface and accept the next action. |
| Evidence location | Customer-approved system for safe references and completed notes. |
| First blocker | One blocker only; do not create a laundry list. |
| Ready signal | What must be visible before the next session starts. |
| Blocked signal | What prevents the next session from producing value. |
| Next route | Session or customer process, owner, accepted-when condition, and recheck trigger. |

## Boundary note

S0 is read-only technical triage. It changes no access, configuration, policy,
deployment, model, gateway, data source, telemetry route, budget, or production
state.

## Related references

- [Customer journey](../start/customer-journey.md): where S0 fits in engagement planning.
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md): technical package shape.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md): official reference sources.
