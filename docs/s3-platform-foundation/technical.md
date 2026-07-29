# S3 · Platform Route & Trust Boundaries: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway, Azure API Center, private networking, and Azure Monitor capabilities vary by tenant, region, license, SKU, and service maturity. Verify official docs and customer platform status before delivery.

## Microsoft default

Default to an Azure landing-zone-aligned platform using Microsoft Foundry for AI workloads, Azure API Management AI Gateway or a Citadel-aligned gateway where supported, private networking where risk requires it, Azure API Center for registry, and Azure Monitor/Application Insights for telemetry.

S3 is a readiness and handoff gate, not a deployment or runtime-proof activity. It records the platform pattern, trust boundaries, control owners, unsupported assumptions, and release-impacting blockers so runtime, evaluation, and catalog owners know what they can rely on and what must be proven later.

![S3 illustrative Azure platform pattern: callers cross an optional gateway trust boundary to orchestration or hosted execution, private data access, identity, and observability layers. The pattern identifies decisions and evidence expectations without claiming a deployed topology.](../assets/diagrams/s3-gateway-trust-boundary.svg)

## Workshop route: trace the platform path

Use this route during workshop scenarios. Record the decision, evidence source, availability caveat, and owner for every gap. Do not change tenant policy, deploy resources, approve production, copy customer evidence into the repo, or claim runtime proof from S3.

1. **Choose one pilot route.** Name the caller, workload, environment, business
   purpose, platform owner, security owner, network owner where relevant,
   telemetry owner, evidence owner, and approved records location.
2. **Confirm landing zone and hosting pattern.** If the customer has a governed
   Azure landing zone, map the route to subscription/resource group, policy,
   identity, network, logging, and ownership boundaries. If Microsoft Foundry is
   supported for the tenant, region, license, SKU, and workload, use it as the AI
   platform record. If the workload is managed SaaS, custom Azure app, hybrid, or
   non-Azure, record the host owner and which controls are outside Foundry
   visibility.
3. **Trace ingress through the gateway.** If traffic can cross Azure API
   Management AI Gateway or a customer-approved gateway, record caller, API,
   product/policy, auth, backend/model route, logs, owner, and bypasses. If no
   gateway exists, defer gateway proof and route the gap to platform/security.
4. **Trace egress to model, tools, APIs, and data.** Record backend route,
   outbound tool/API calls, connector owner, retrieval/data dependencies, allowed
   destinations, firewall/proxy decision, and direct-route exceptions.
5. **Validate private-network assumptions.** If sensitivity or policy requires
   private routing, require Private Link, VNet integration, private DNS, route
   table, firewall/NSG, public-endpoint exception, flow-log route, and owner
   records. If the private route is unknown, do not accept the topology as ready.
6. **Separate identity boundaries.** Record human caller, workload identity,
   managed identity/app registration, delegated OBO, gateway identity, tool/API
   identity, and resource authorization separately. If the identity boundary is
   shared, unnamed, or tenant support is unknown, route to identity and platform
   owners before release decisions rely on it.
7. **Confirm telemetry and correlation path.** Record where correlation IDs
   originate, propagate, and land across gateway, app, model/agent, tools, data,
   and logs. If no correlation ID path exists, runtime assurance cannot claim
   reviewed-request proof and evaluation cannot rely on execution evidence.
8. **Assign retention, export, and registry ownership.** Name owners for Log
   Analytics/Application Insights retention, approved export path, API
   Center/catalog entries, route lifecycle records, and evidence references.
   Missing owners block S3 acceptance for the affected route.
9. **Close downstream evidence requests.** If the platform route, control owners,
   blockers, and runtime/evaluation/catalog handoff owners are recorded, accept
   the readiness decision. Otherwise defer or route with release impact and
   target owner.

### Platform-route trace card

Record references only. Do not copy customer architecture diagrams, network
details, endpoint names, telemetry exports, resource IDs, tenant IDs, secrets,
live configuration, or evidence payloads into this repository.

| Field | What to record |
|---|---|
| Pilot route | Caller, workload, environment, business purpose, customer record location, and stop condition. |
| Landing zone | Tenant/subscription/resource group, Azure Policy or exception posture, platform owner, support caveats. |
| Hosting pattern | Foundry-hosted, Azure app-hosted, managed SaaS, hybrid, non-Azure, unsupported, or exception route. |
| Gateway ingress | APIM/customer gateway API, product, policy, backend/model route, auth owner, route owner, bypass owner. |
| Model/tool/data egress | Model endpoint, tool/API route, connector, retrieval/data dependency, allowed destination, direct-route exception. |
| Private network | Public/private/managed VNet/BYO VNet/hybrid/deferred path, Private Link, DNS, VNet/subnet, firewall/NSG, route table, flow-log owner. |
| Identity boundary | Human caller, workload identity, managed identity/app registration, OBO/delegated path, gateway identity, tool/API identity, resource authorization. |
| Telemetry/correlation | Trace/correlation origin, propagation point, gateway/app/model/tool/data log destinations, time-window method, reviewer, blind spots. |
| Retention/export | Log retention, approved export route, evidence access owner, deletion/hold expectation, records owner. |
| Registry/catalog | API Center/catalog/tool/model entry, route/backend mapping, version, lifecycle status, owner, exception/backlog reference. |
| Downstream evidence | Runtime proof question, evaluation evidence need, catalog/control-plane reconciliation, acceptance criteria. |
| Decision | Proceed with assumptions, defer, route, reject, or blocked with owner, target date, release impact, and review trigger. |

### Platform decision/control matrix

Use this matrix to make S3 decision-oriented. Product names are not proof: each control must be checked for tenant, region, license, SKU, support status, configuration, and customer ownership before it is recorded as available.

| Control area | Decision to record | Evidence / control record | Scenario blocker | Safe route |
|---|---|---|---|---|
| Hosting pattern | Whether the workload is Foundry-hosted, Azure app-hosted, managed SaaS, hybrid, or non-Azure, and which platform owns runtime changes | Foundry project/workspace, Azure subscription/resource group, app service/container/AKS record, SaaS service record, approved exception | unsupported region/SKU/tenant; managed SaaS cannot expose required controls; no accountable platform owner | record as readiness gap; route to platform and catalog owners with no deployment or control-operation claim |
| Gateway route | Whether ingress and model/API calls cross Azure API Management AI Gateway, Citadel/customer gateway, or a direct app route | APIM API/product/policy/backend, gateway owner, route diagram/reference, auth and logging settings | custom app without gateway; gateway exists but cannot see prompt/tool context; gateway support unknown | defer gateway proof; add app boundary controls or platform backlog owner |
| Egress/tool route | How tool, plugin, connector, retrieval, and outbound API calls are mediated and logged | APIM/backend route, firewall/proxy rule, tool registry entry, connector owner, allowed destination record | direct outbound calls; unmanaged tool endpoint; destination owner missing | route to tool/API and runtime owners; do not claim controlled egress |
| Private network | Whether private endpoints, VNet integration, private DNS, firewall, and route tables are required and owned | Private Endpoint, private DNS zone, VNet/subnet, NSG, route table, firewall, approved public-endpoint exception | private route unknown; DNS/route owner missing; public endpoint not policy-approved | defer S3 acceptance for sensitive path; route to network/platform owner |
| Identity boundary | Which human, workload, managed identity/app registration, OBO, service principal, and tool identities authorize each boundary | Entra Agent ID/Agent 365 where available, managed identity, app registration, federated credential, RBAC/API permission record | shared identity; missing sponsor; broad tenant permission; tenant/workload support unknown | route to the identity owner; do not treat platform record as access approval |
| Telemetry/correlation | Where requests, traces, policy decisions, tool calls, and failures are logged and how correlation IDs are propagated | Application Insights, Azure Monitor diagnostic settings, Log Analytics workspace, gateway correlation header, trace query owner | no correlation ID path; managed SaaS has limited telemetry; empty/no logs without scope validation | route runtime-proof and evaluation-evidence gaps to receiving owners; empty results are not proof |
| Retention/export | Who owns log/evidence retention, approved export, investigation access, and deletion/records requirements | Log Analytics retention setting, Application Insights retention, Purview/records owner, approved evidence storage/export path | missing retention owner; unapproved export path; customer evidence would need copying into repo | hold acceptance for evidence route; route to compliance and records owners |
| Registry/API Center | Which APIs, tools, model endpoints, and lifecycle states are cataloged for control-plane reconciliation | Azure API Center API/tool entry, API owner, version/lifecycle status, backend/gateway mapping | API Center unavailable; route not cataloged; owner/version missing | route to catalog/control-plane owner; record registry gap and release impact |
| Platform ownership | Who owns each platform backlog item, exception, review date, and support check | platform backlog/ticket, architecture decision record, support matrix link/reference, named owner and target date | no runtime/evaluation/catalog handoff owner; unsupported dependency with no exception owner | defer or reject release recommendation until owner and decision path exist |

### Gateway/APIM readiness checklist

| Check | Question |
|---|---|
| Caller route | Which users, apps, jobs, agents, tools, or administrators must enter through the gateway? |
| API and product | Which APIM API, product, backend, policy, subscription, or equivalent gateway route represents the path? |
| Model/backend route | Which model endpoint, Foundry deployment, API backend, or app service does the gateway reach? |
| Tool/API egress | Which outbound tool/API calls are routed through gateway, proxy, firewall, or direct exception? |
| Auth and policy owner | Who owns authentication, authorization, throttling, content/policy controls, and change approval? |
| Bypass | Which direct, admin, background job, connector, or hybrid routes bypass the gateway, and who owns the exception? |
| Logs and correlation | Which gateway logs and correlation fields allow later reviewers to connect caller, backend, tool, and data action? |
| Support caveat | Which SKU, tenant, region, policy, streaming, payload, or connector limits affect the route? |

### Private network outcome interpretation

| Outcome | Use when | Required fields |
|---|---|---|
| Private route selected | The customer has selected a private route pattern for the bounded path. | VNet/subnet, Private Endpoint, private DNS, firewall/NSG, route table, owner, public-endpoint exception, validation owner. |
| Public route approved | The route is intentionally public or public-with-controls. | Architecture/security owner, gateway/identity/telemetry compensating controls, exception status, review trigger. |
| Managed network selected | The platform uses a managed network pattern where supported. | Foundry/network mode, supported region/SKU, outbound rules, private endpoints, owner, limitation. |
| BYO VNet selected | The customer-owned VNet is part of the platform route. | VNet/subnet, integration method, DNS, NSG/firewall, peering/hybrid route, owner. |
| Hybrid route selected | The path crosses on-premises, partner, or externally managed networks. | Boundary, routing owner, support owner, log/export route, incident escalation path. |
| Deferred or blocked | The private route is required but not designable from current records. | Missing component, affected path, network/platform owner, accepted-when condition, release impact. |

### Telemetry and correlation checklist

| Review area | Required question |
|---|---|
| Correlation origin | Which request ID, trace ID, session ID, header, run ID, or time-window method starts the trace? |
| Propagation | Where is the correlation key propagated: gateway, app, Foundry/model, tool/API, data, and logs? |
| Destination | Which Application Insights, Azure Monitor, Log Analytics, gateway, app, model, data, or SIEM record receives it? |
| Coverage limits | Which segments are sampled, unsupported, managed by SaaS, unlogged, or outside the customer's export path? |
| Empty results | Which query, time range, diagnostic status, route coverage, sampling, and reviewer make absence meaningful? |
| Retention/export | Who owns retention, export, evidence access, deletion/hold, and approved records location? |
| Downstream use | Which runtime, evaluation, or operating-review owner can rely on the trace later, and what must still be proven? |

### Registry and catalog handoff checklist

| Record | Question |
|---|---|
| API/tool/model entry | Is the API, tool, model endpoint, gateway route, backend, or connector registered where the customer expects to govern it? |
| Version and lifecycle | Which version, environment, lifecycle state, deprecation route, and owner apply? |
| Gateway/backend mapping | Does the registry identify whether traffic uses APIM/gateway, direct route, or exception route? |
| Access contract | Which identity, auth, rate limit, data class, owner, and support expectation belongs to the route? |
| Exception/backlog | Which missing entry, owner, unsupported capability, or route mismatch must be fixed before control-plane reliance? |

### Azure agent platform reference pattern

Use this as a concrete review aid when the customer is planning an Azure-hosted
agent platform. It is a pattern to compare against customer records, not a
required design or proof of deployed controls.

| Layer | Review question | Typical records |
|---|---|---|
| Entry and governance | Which gateway route mediates inbound callers, model calls, tool calls, quotas, policy checks, and logs? | API Management API/product/policy/backend, API Center entry, gateway owner, exception route. |
| Orchestration | Which AI platform owns agent definition, model deployment, tool configuration, and native observability? | Foundry project, model deployment, agent record, tool configuration, project owner. |
| Execution | Which compute host runs custom or external agent code, and which identity does that host use? | App Service, Application Service Environment, Functions, Container Apps, AKS, managed identity or federation record. |
| Data | Which data services are reachable, through what path, and under which classification? | Cosmos DB, Azure AI Search, Storage, Document Intelligence, data classification, Private Endpoint, data owner. |
| Identity | Which human, workload, agent, delegated, gateway, and resource identities cross each boundary? | Entra Agent ID/Agent 365, managed identity, app registration, OBO record, RBAC/API permissions. |
| Observability | How can a reviewer connect gateway, agent, model, tool, data, safety, and cost events? | Application Insights, Azure Monitor, Log Analytics, diagnostic settings, correlation field, retention/export owner. |

For sensitive workloads, also record whether the platform uses managed network
isolation, bring-your-own VNet, private endpoints, private DNS, firewall or
route-table controls, and NSG segmentation. If the answer is "planned" or
"assumed" rather than recorded, route the item as a readiness gap.

### Private network and DNS checklist

Use this checklist to prevent "private" from becoming an unsupported label.

![Private DNS resolution flow showing component, DNS query, private DNS zone, private IP resolution, internal VNet traffic, and target Azure service.](../assets/diagrams/s3-private-dns-resolution-flow.svg)

| Area | Decision to record | Blocker signal |
|---|---|---|
| VNet and subnets | Main platform network, orchestration subnet, execution subnet, data private endpoint subnet, platform private endpoint subnet, owner for each segment. | No owner can say where the route starts, terminates, or crosses subnets. |
| Private endpoints | Which PaaS services require Private Endpoint and public-network disablement; which exceptions are approved. | Data service is sensitive but only public endpoint status or URL is known. |
| Private DNS | Which private DNS zones are linked to the platform VNet and which owner validates resolution for Azure service FQDNs. | DNS route owner missing, split-horizon behavior unknown, or fallback to public resolution not reviewed. |
| NSG and egress control | Whether subnets are deny-by-default with explicit APIM, orchestration, execution, data, monitor, and deployment paths. | Generic allow rules, unmanaged Internet egress, or no flow-log owner. |
| Peering and hybrid routes | Whether peering, gateway transit, route propagation, firewall, proxy, or on-premises routes are allowed for this workload. | The platform inherits routes or trust from a broader network without a recorded exception owner. |
| Monitoring | Where NSG flow logs, DNS failures, denied traffic, and unexpected public endpoint use are reviewed. | Network telemetry exists but no population, retention, query owner, or alert route is recorded. |

#### Reference subnet model

Use these rows as a review template. Customers may use different names or
topology; record the actual approved records and owners.

| Segment | Purpose | Typical sizing question | Evidence to record |
|---|---|---|---|
| Platform VNet | Main network boundary for the agent platform route. | Is the address space large enough for orchestration, execution, private endpoints, and growth? | VNet/subscription/resource-group owner, peering/route owner, approved exceptions. |
| Orchestration subnet | Hosts or connects the AI orchestration plane where supported. | Does the platform need managed network, BYO VNet, or hybrid connectivity? | Foundry network mode, subnet or managed-network record, route owner. |
| Execution subnet | Hosts custom app, Function, container, or ASE workloads. | Is the host private-only, and how does it reach gateway, data, and monitor endpoints? | App host, subnet integration, managed identity, NSG, route table. |
| Data private endpoint subnet | Holds private endpoints for data services. | Are endpoint count and IP allocation sufficient for data dependencies? | Private Endpoint list, data owner, public-network setting, DNS zone link. |
| Platform private endpoint subnet | Holds endpoints for ACR, monitoring, and platform dependencies. | Are operations endpoints separated from data endpoints where policy requires it? | Endpoint list, platform owner, diagnostic settings, support exceptions. |

#### Private endpoint and DNS reference

| Service category | Typical service | Public FQDN pattern | Private DNS zone to check |
|---|---|---|---|
| Data store | Cosmos DB | `*.documents.azure.com` | `privatelink.documents.azure.com` |
| Search | Azure AI Search | `*.search.windows.net` | `privatelink.search.windows.net` |
| Storage | Blob Storage | `*.blob.core.windows.net` | `privatelink.blob.core.windows.net` |
| Document processing | Document Intelligence or cognitive service | `*.cognitiveservices.azure.com` | `privatelink.cognitiveservices.azure.com` |
| Model endpoint | Azure OpenAI or Foundry-backed endpoint where applicable | `*.openai.azure.com` | `privatelink.openai.azure.com` |
| Container platform | Azure Container Registry | `*.azurecr.io` | `privatelink.azurecr.io` |
| Monitoring | Log Analytics / Azure Monitor / Application Insights | service-specific monitor endpoints | approved Azure Monitor private link scope or service-specific private link record |

#### Deny-by-default NSG review pattern

| Source | Destination | Port | Review question |
|---|---|---|---|
| Gateway subnet or peered gateway VNet | Orchestration or execution subnet | 443 | Is this the approved inbound route, and are direct bypass routes blocked or recorded? |
| Orchestration subnet | Execution subnet | 443 | Is agent-to-execution traffic required, authenticated, and logged? |
| Execution subnet | Orchestration subnet | 443 | Are callbacks or orchestration calls expected and bounded? |
| Orchestration/execution subnet | Data private endpoint subnet | 443 | Which data services are approved and tied to S2 classification? |
| Orchestration/execution subnet | Platform private endpoint subnet | 443 | Which monitor, registry, or platform services are required for operations? |
| Orchestration/execution subnet | Gateway route | 443 | Are model, tool, API, and agent calls forced through the approved gateway where required? |
| Any | Any | Any | Is the final rule deny-by-default, and are generic allow rules absent or exception-owned? |

Record NSG flow-log enablement, retention, and the reviewer who can distinguish
expected denied traffic from anomalous exfiltration or lateral-movement attempts.

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Landing zone fit | Azure landing-zone subscription/resource group policy, Azure Policy assignments, CAF/Well-Architected review, approved exception record |
| Foundry workspace/project | Foundry project, model deployment, agent/tool configuration references, availability check for tenant/region/license/SKU |
| Hosting and app boundary | Azure App Service, Container Apps, AKS, Functions, SaaS service record, customer platform owner, exception topology |
| Gateway route | Azure API Management API/product/policy/backend record, gateway logs, Citadel accelerator docs if used, customer gateway authority record |
| Egress/tool path | APIM/backend route, firewall/proxy rule, tool/API allowlist, connector owner, tool/API handoff reference |
| Private connectivity | Private Endpoint, private DNS zone, VNet integration, network security group, route table, firewall records |
| Network segmentation | VNet/subnet ownership, NSG deny-by-default rule set, flow-log route, peering or route propagation decision |
| Observability | Azure Monitor, Application Insights, Log Analytics workspace, diagnostic settings, correlation ID plan, query/reviewer owner |
| Retention/export | log retention setting, approved export/storage route, records-management owner, evidence handling caveat |
| Registry | Azure API Center API/tool entry, lifecycle owner, version/status, catalog reconciliation owner |
| Handoff ownership | named runtime-proof owner, evaluation-evidence owner, catalog/control-plane owner, target date for gaps |

## Decision and blocker routes

| Case | Decision route | Record before continuing |
|---|---|---|
| Managed SaaS with limited telemetry | Treat telemetry and control visibility as limited to documented customer-accessible records | SaaS owner, available logs, unavailable fields, retention owner, runtime/evaluation evidence caveat |
| Custom app without gateway | Do not claim gateway enforcement or gateway proof | app owner, direct route, proposed gateway/backlog owner, app-only controls, release impact |
| Private route unknown | Defer platform readiness for sensitive or policy-bound paths | data/path affected, required private components, network owner, target design review |
| No correlation ID path | Block runtime-proof dependency on platform telemetry | missing propagation point, affected logs, correlation owner, runtime-proof gap, evaluation-evidence caveat |
| Missing retention owner | Block acceptance of the evidence/log route | log/evidence store, expected retention/export rule, records owner escalation, decision due date |
| Unsupported region, SKU, license, tenant, or workload | Record the Microsoft control as not established for this scenario slice | unsupported dependency, official/support check needed, alternate manual route, release/backlog impact |
| No runtime handoff owner | Defer runtime-assurance readiness | route needing proof, expected reviewer, platform/security escalation, target owner |
| No evaluation handoff owner | Defer evaluation-evidence readiness | telemetry/evidence needed by evaluation, reviewer, dataset/result storage owner, target owner |
| No catalog handoff owner | Defer catalog/control-plane readiness | API/tool/model route, registry gap, catalog owner escalation, target owner |
| Empty or no logs | Do not treat absence of events as proof that controls operated or risk is absent | query, time range, route coverage, sampling/diagnostic status, reviewer, next validation step |
| Customer evidence required | Keep records in customer-approved systems; do not copy customer evidence into the repo | system of record, reference ID if approved, evidence owner, access boundary |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Platform readiness | the hosting pattern, landing-zone or exception topology, support caveats, platform owner, assumptions, and release-impacting gaps are recorded; unsupported tenant/region/license/SKU items are not claimed as available | Architecture/platform owner |
| Trust boundary | ingress, gateway, app, model/agent, tool/egress, identity, private-network, and telemetry boundaries are named with owners and route status: accepted, deferred, or blocked | Platform/security |
| Gateway and egress route | APIM/Citadel/customer gateway or direct-route exception is documented for ingress and outbound tool/API calls; custom app without gateway is routed to backlog and the runtime owner is told no gateway proof exists | Runtime-proof owner and tool/API owner |
| Private route | selected Private Link, DNS, VNet, firewall, and route-table dependencies have owners and verified support status, or the route is blocked with network owner and release impact | Network/platform owner |
| Identity boundary | human sponsor, workload identity, delegated/OBO path, app registration/managed identity, and tool/API identity assumptions are separated and routed when missing or unsupported | Identity owner |
| Telemetry/correlation | a facilitator can point to where correlation IDs originate, propagate, and are reviewed across gateway/app/model/tool logs, or the no-correlation blocker is recorded for runtime and evaluation owners | Runtime-proof owner and evaluation owner |
| Retention/export | log retention, approved export/evidence storage, reviewer access, and records owner are named; no customer evidence is copied into the repo and missing owners block acceptance | Records/compliance owner |
| Registry/API Center | APIs, tools, model endpoints, lifecycle state, and owners are registered in API Center or an approved customer catalog, or a named catalog gap has owner and target date | Control-plane/catalog owner |
| Runtime handoff | Runtime owners can identify the route to test, expected policy/control point, correlation source, log query/reviewer, retention owner, and any known unsupported product capability | Security/runtime owner |
| Evaluation handoff | Evaluation owners can identify which telemetry or platform evidence is usable for evaluation evidence, which gaps limit evaluation claims, and who owns evidence storage and review | Evaluation owner |
| Catalog handoff | Catalog owners can reconcile the route, API/tool/model owner, lifecycle status, exception, and platform backlog item in the control plane/catalog | Control-plane/catalog owner |
| Facilitator decision | for each scenario slice, the facilitator can mark S3 **accepted** only when owners and routes are complete, **deferred** when a named owner/date exists, or **routed/blocked** when missing ownership, unsupported product status, private path, correlation, retention, or catalog gaps remain | Workshop facilitator |
| Change safety | S3 records readiness and handoff decisions only; it makes no tenant/live-policy changes, deployment claims, runtime proof claims, production approvals, or repo copies of customer evidence | Workshop facilitator |

## Boundary note

S3 records platform readiness and handoff decisions; it deploys no resources, proves no controls operate, grants no production approval, and keeps customer records in customer-approved systems.

## Related references

- [S3 Concepts](concepts.md): trust boundaries, gateway boundary, private-connectivity assumptions, telemetry coverage, and platform backlog.
- [Runtime security decisions](../s6-security-runtime/technical.md): runtime proof and gateway correlation.
- [Evaluation decisions](../s7-evaluation/technical.md): evaluation evidence and release assurance inputs.
- [Control-plane decisions](../s9-control-plane/technical.md): catalog handoff.
- [Platform technical guide](../reference/platform-technical-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
