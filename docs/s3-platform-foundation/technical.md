# S3 · Enterprise Platform & Trust Boundaries: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway, Azure API Center, private networking, and Azure Monitor capabilities vary by tenant, region, license, SKU, and service maturity. Verify official docs and customer platform status before delivery.

## Microsoft default

Default to an Azure landing-zone-aligned platform using Microsoft Foundry for AI workloads, Azure API Management AI Gateway or a Citadel-aligned gateway where supported, private networking where risk requires it, Azure API Center for registry, and Azure Monitor/Application Insights for telemetry.

S3 is a readiness and handoff gate, not a deployment or runtime-proof activity. It records the platform pattern, trust boundaries, control owners, unsupported assumptions, and release-impacting blockers so S6, S7, and S9 know what they can rely on and what must be proven later.

![S3 illustrative Azure platform pattern: callers cross an optional gateway trust boundary to orchestration or hosted execution, private data access, identity, and observability layers. The pattern identifies decisions and evidence expectations without claiming a deployed topology.](../assets/diagrams/s3-gateway-trust-boundary.svg)

## Decision tree

Use this route during workshop scenarios. Record the decision, evidence source, availability caveat, and owner for every gap. Do not change tenant policy, deploy resources, approve production, copy customer evidence into the repo, or claim runtime proof from S3.

1. **Confirm platform landing zone.** If the customer has a governed Azure landing zone, map the workload to subscription/resource group, policy, identity, network, logging, and ownership boundaries. If not, record the authoritative platform exception and backlog Azure/enterprise alignment deltas.
2. **Select the hosting pattern.** If Microsoft Foundry is supported for the tenant, region, license, SKU, and workload, use it as the primary AI platform record. If the workload is managed SaaS or a custom app, record the host owner and which controls are outside Foundry visibility.
3. **Name the gateway route.** If traffic can cross Azure API Management AI Gateway or a customer-approved gateway, record ingress, egress/tool, policy, auth, and log routes. If no gateway exists, defer S6 runtime proof and route the gap to platform/security.
4. **Validate private-network assumptions.** If sensitivity or policy requires private routing, require Private Link, VNet integration, DNS, route table, firewall, and owner records. If the private route is unknown, do not accept the topology as ready.
5. **Separate identity boundaries.** Record user, workload, managed identity/app registration, delegated OBO, and tool/API identities separately. If the identity boundary is shared, unnamed, or tenant support is unknown, route to S1 and platform identity before release decisions rely on it.
6. **Confirm telemetry and correlation path.** Record where correlation IDs originate, propagate, and land across gateway, app, model/agent, tools, and logs. If no correlation ID path exists, S6 cannot claim reviewed-request proof and S7 cannot rely on execution evidence.
7. **Assign retention, export, and registry ownership.** Name owners for Log Analytics/Application Insights retention, approved export path, API Center/catalog entries, and evidence references. Missing owners block S3 acceptance for the affected route.
8. **Close handoffs.** If the platform, control owners, blockers, and S6/S7/S9 handoff owners are recorded, accept S3. Otherwise defer or route with release impact and target owner.

### Platform decision/control matrix

Use this matrix to make S3 decision-oriented. Product names are not proof: each control must be checked for tenant, region, license, SKU, support status, configuration, and customer ownership before it is recorded as available.

| Control area | Decision to record | Evidence / control record | Scenario blocker | Safe route |
|---|---|---|---|---|
| Hosting pattern | Whether the workload is Foundry-hosted, Azure app-hosted, managed SaaS, hybrid, or non-Azure, and which platform owns runtime changes | Foundry project/workspace, Azure subscription/resource group, app service/container/AKS record, SaaS service record, approved exception | unsupported region/SKU/tenant; managed SaaS cannot expose required controls; no accountable platform owner | record as readiness gap; route to platform owner and S9 catalog with no deployment or control-operation claim |
| Gateway route | Whether ingress and model/API calls cross Azure API Management AI Gateway, Citadel/customer gateway, or a direct app route | APIM API/product/policy/backend, gateway owner, route diagram/reference, auth and logging settings | custom app without gateway; gateway exists but cannot see prompt/tool context; gateway support unknown | defer S6 gateway proof; add app boundary controls or platform backlog owner |
| Egress/tool route | How tool, plugin, connector, retrieval, and outbound API calls are mediated and logged | APIM/backend route, firewall/proxy rule, tool registry entry, connector owner, allowed destination record | direct outbound calls; unmanaged tool endpoint; destination owner missing | route to S5 tool/API governance and S6 runtime proof; do not claim controlled egress |
| Private network | Whether private endpoints, VNet integration, private DNS, firewall, and route tables are required and owned | Private Endpoint, private DNS zone, VNet/subnet, NSG, route table, firewall, approved public-endpoint exception | private route unknown; DNS/route owner missing; public endpoint not policy-approved | defer S3 acceptance for sensitive path; route to network/platform owner |
| Identity boundary | Which human, workload, managed identity/app registration, OBO, service principal, and tool identities authorize each boundary | Entra Agent ID/Agent 365 where available, managed identity, app registration, federated credential, RBAC/API permission record | shared identity; missing sponsor; broad tenant permission; tenant/workload support unknown | route to S1 identity owner; do not treat platform record as access approval |
| Telemetry/correlation | Where requests, traces, policy decisions, tool calls, and failures are logged and how correlation IDs are propagated | Application Insights, Azure Monitor diagnostic settings, Log Analytics workspace, gateway correlation header, trace query owner | no correlation ID path; managed SaaS has limited telemetry; empty/no logs without scope validation | route to S6 for runtime proof gap and S7 evidence caveat; empty results are not proof |
| Retention/export | Who owns log/evidence retention, approved export, investigation access, and deletion/records requirements | Log Analytics retention setting, Application Insights retention, Purview/records owner, approved evidence storage/export path | missing retention owner; unapproved export path; customer evidence would need copying into repo | hold acceptance for evidence route; route to S2 compliance and records owner |
| Registry/API Center | Which APIs, tools, model endpoints, and lifecycle states are cataloged for S9 control-plane reconciliation | Azure API Center API/tool entry, API owner, version/lifecycle status, backend/gateway mapping | API Center unavailable; route not cataloged; owner/version missing | route to S9 control-plane/catalog; record registry gap and release impact |
| Platform ownership | Who owns each platform backlog item, exception, review date, and support check | platform backlog/ticket, architecture decision record, support matrix link/reference, named owner and target date | no S6/S7/S9 handoff owner; unsupported dependency with no exception owner | defer or reject release recommendation until owner and decision path exist |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Landing zone fit | Azure landing-zone subscription/resource group policy, Azure Policy assignments, CAF/Well-Architected review, approved exception record |
| Foundry workspace/project | Foundry project, model deployment, agent/tool configuration references, availability check for tenant/region/license/SKU |
| Hosting and app boundary | Azure App Service, Container Apps, AKS, Functions, SaaS service record, customer platform owner, exception topology |
| Gateway route | Azure API Management API/product/policy/backend record, gateway logs, Citadel accelerator docs if used, customer gateway authority record |
| Egress/tool path | APIM/backend route, firewall/proxy rule, tool/API allowlist, connector owner, S5 handoff reference |
| Private connectivity | Private Endpoint, private DNS zone, VNet integration, network security group, route table, firewall records |
| Observability | Azure Monitor, Application Insights, Log Analytics workspace, diagnostic settings, correlation ID plan, query/reviewer owner |
| Retention/export | log retention setting, approved export/storage route, records-management owner, evidence handling caveat |
| Registry | Azure API Center API/tool entry, lifecycle owner, version/status, S9 catalog reconciliation owner |
| Handoff ownership | named S6 runtime-proof owner, S7 evaluation-evidence owner, S9 catalog/control-plane owner, target date for gaps |

## Decision and blocker routes

| Case | Decision route | Record before continuing |
|---|---|---|
| Managed SaaS with limited telemetry | Treat telemetry and control visibility as limited to documented customer-accessible records | SaaS owner, available logs, unavailable fields, retention owner, S6/S7 evidence caveat |
| Custom app without gateway | Do not claim gateway enforcement or gateway proof | app owner, direct route, proposed gateway/backlog owner, app-only controls, release impact |
| Private route unknown | Defer platform readiness for sensitive or policy-bound paths | data/path affected, required private components, network owner, target design review |
| No correlation ID path | Block runtime-proof dependency on S3 telemetry | missing propagation point, affected logs, correlation owner, S6 proof gap, S7 evidence caveat |
| Missing retention owner | Block acceptance of the evidence/log route | log/evidence store, expected retention/export rule, records owner escalation, decision due date |
| Unsupported region, SKU, license, tenant, or workload | Record the Microsoft control as not established for this scenario slice | unsupported dependency, official/support check needed, alternate manual route, release/backlog impact |
| No S6 handoff owner | Defer runtime-assurance readiness | route needing proof, expected reviewer, platform/security escalation, target owner |
| No S7 handoff owner | Defer evaluation-evidence readiness | telemetry/evidence needed by eval, reviewer, dataset/result storage owner, target owner |
| No S9 handoff owner | Defer catalog/control-plane readiness | API/tool/model route, registry gap, catalog owner escalation, target owner |
| Empty or no logs | Do not treat absence of events as proof that controls operated or risk is absent | query, time range, route coverage, sampling/diagnostic status, reviewer, next validation step |
| Customer evidence required | Keep records in customer-approved systems; do not copy customer evidence into the repo | system of record, reference ID if approved, evidence owner, access boundary |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Platform readiness | the hosting pattern, landing-zone or exception topology, support caveats, platform owner, assumptions, and release-impacting gaps are recorded; unsupported tenant/region/license/SKU items are not claimed as available | Architecture/platform owner |
| Trust boundary | ingress, gateway, app, model/agent, tool/egress, identity, private-network, and telemetry boundaries are named with owners and route status: accepted, deferred, or blocked | Platform/security |
| Gateway and egress route | APIM/Citadel/customer gateway or direct-route exception is documented for ingress and outbound tool/API calls; custom app without gateway is routed to backlog and S6 is told no gateway proof exists | S6 runtime-proof owner + S5 tool/API owner |
| Private route | selected Private Link, DNS, VNet, firewall, and route-table dependencies have owners and verified support status, or the route is blocked with network owner and release impact | Network/platform owner |
| Identity boundary | human sponsor, workload identity, delegated/OBO path, app registration/managed identity, and tool/API identity assumptions are separated and routed to S1 when missing or unsupported | S1 identity owner |
| Telemetry/correlation | a facilitator can point to where correlation IDs originate, propagate, and are reviewed across gateway/app/model/tool logs, or the no-correlation blocker is recorded for S6 and S7 | S6 runtime-proof owner + S7 evaluation owner |
| Retention/export | log retention, approved export/evidence storage, reviewer access, and records owner are named; no customer evidence is copied into the repo and missing owners block acceptance | S2 records/compliance owner |
| Registry/API Center | APIs, tools, model endpoints, lifecycle state, and owners are registered in API Center or an approved customer catalog, or S9 has a named catalog gap and target date | S9 control-plane/catalog owner |
| S6 handoff | S6 can identify the route to test, expected policy/control point, correlation source, log query/reviewer, retention owner, and any known unsupported product capability | Security/runtime owner |
| S7 handoff | S7 can identify which telemetry or platform evidence is usable for evaluation evidence, which gaps limit evaluation claims, and who owns evidence storage and review | Evaluation owner |
| S9 handoff | S9 can reconcile the route, API/tool/model owner, lifecycle status, exception, and platform backlog item in the control plane/catalog | Control-plane/catalog owner |
| Facilitator decision | for each scenario slice, the facilitator can mark S3 **accepted** only when owners and routes are complete, **deferred** when a named owner/date exists, or **routed/blocked** when missing ownership, unsupported product status, private path, correlation, retention, or catalog gaps remain | Workshop facilitator |
| Change safety | S3 records readiness and handoff decisions only; it makes no tenant/live-policy changes, deployment claims, runtime proof claims, production approvals, or repo copies of customer evidence | Workshop facilitator |

## Boundary note

S3 records platform readiness and handoff decisions; it deploys no resources, proves no controls operate, grants no production approval, and keeps customer records in customer-approved systems.

## Related references

- [S3 Concepts](concepts.md): trust boundaries, gateway boundary, private-connectivity assumptions, telemetry coverage, and platform backlog.
- [S6 technical decisions](../s6-security-runtime/technical.md): runtime proof and gateway correlation.
- [S7 technical decisions](../s7-evaluation/technical.md): evaluation evidence and release assurance inputs.
- [S9 technical decisions](../s9-control-plane/technical.md): catalog handoff.
- [Platform technical guide](../reference/platform-technical-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
