# S3 · Platform Route & Trust Boundaries: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-27 · Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway, Azure API Center, Private Link, private DNS, and Azure Monitor capabilities vary by tenant, region, license, SKU, and service support. Verify current docs and customer platform status before delivery.

## Microsoft default

Use an Azure landing-zone-aligned route where possible:

- Microsoft Foundry for AI project, model, agent, tool, tracing, and evaluation
  records where supported.
- Azure API Management AI Gateway or a customer-approved gateway for AI API,
  model, and tool/API boundaries.
- Private Link, VNet integration, private DNS, firewall/NSG, and route-table
  controls where sensitivity or customer policy requires private routing.
- Entra ID, managed identity, workload identity federation, app registration,
  OBO/delegated authority, and RBAC/API scopes as separate authority layers.
- Azure Monitor, Application Insights, Log Analytics, diagnostic settings, and
  approved export paths for telemetry and retention.
- Azure API Center or customer catalog for API/tool/model route ownership and
  lifecycle records.

S3 is a readiness decision. It records route assumptions, owners, and blockers;
it does not prove runtime enforcement or approve production.

![S3 illustrative Azure platform pattern: callers cross an optional gateway trust boundary to orchestration or hosted execution, private data access, identity, and observability layers. The pattern identifies decisions and evidence expectations without claiming a deployed topology.](../assets/diagrams/s3-gateway-trust-boundary.svg)

## Platform-route trace fields

| Field | Required technical detail |
|---|---|
| Pilot route | Caller, workload, environment, business purpose, owner, evidence location, stop condition. |
| Landing zone | Tenant/subscription/resource group reference, Azure Policy or exception posture, platform owner, support caveat. |
| Hosting pattern | Foundry-hosted, Azure app-hosted, managed SaaS, hybrid, non-Azure, prototype-only, unsupported, or exception route. |
| Gateway ingress | APIM/customer gateway API, product, policy family, backend/model route, auth owner, log owner, bypass owner. |
| Model/tool/data egress | Model endpoint, tool/API route, connector, retrieval/data dependency, allowed destination, direct-route exception. |
| Private route | Public/private/managed VNet/BYO VNet/hybrid/deferred path, Private Endpoint, DNS, VNet/subnet, firewall/NSG, route table, flow-log owner. |
| Identity boundary | Human caller, workload identity, managed identity/app registration, OBO/delegated authority, gateway identity, tool/API identity, resource authorization. |
| Telemetry/correlation | Trace origin, propagation points, gateway/app/model/tool/data destinations, time-window method, reviewer, blind spots. |
| Retention/export | Log retention, approved export route, evidence access owner, deletion/hold expectation, records owner. |
| Registry/catalog | API Center/catalog/tool/model entry, route/backend mapping, version, lifecycle status, owner, exception/backlog reference. |
| Decision | Proceed with assumptions, defer, route, reject, or block with owner, acceptance criterion, and release impact. |

## Control checks

| Control area | Accept only when | Block or defer when |
|---|---|---|
| Hosting pattern | Tenant/region/SKU support, platform owner, environment boundary, and support caveat are known. | Product exists but route owner, support status, or hosting boundary is unknown. |
| Gateway route | Caller path, backend/model route, auth, policy owner, logging, and bypasses are recorded. | Direct route bypasses gateway and no exception owner exists. |
| Egress/tool route | Tool/API, connector, retrieval, outbound destination, owner, and mediation path are known. | Unmanaged endpoint, broad egress, or missing destination owner. |
| Private network | Private Endpoint, VNet/subnet, private DNS, firewall/NSG, route table, public-endpoint exception, and validation owner are recorded. | "Private" is claimed from a diagram or service name without DNS/route evidence. |
| Identity boundary | Each human/workload/delegated/gateway/tool/resource identity is separate and owned. | Shared identity, broad tenant permission, or missing sponsor/lifecycle owner. |
| Telemetry/correlation | Correlation key, propagation path, log destination, query owner, time window, and retention owner are recorded. | Empty logs, planned telemetry, or sampled data are treated as proof. |
| Registry/catalog | API/tool/model/gateway/backend route has version, lifecycle state, and owner. | API Center/catalog record is missing, stale, or disconnected from the actual route. |

## APIM/gateway checklist

Record policy intent and ownership only. Do not paste customer policy exports or
claim enforcement without runtime evidence.

| Check | What to capture |
|---|---|
| Caller route | Users, apps, agents, jobs, tools, or admins expected to enter through the gateway. |
| API/product/backend | APIM API, product, subscription, backend/model route, and route owner. |
| Authentication | JWT/audience, managed identity to backend, app registration, OBO path, or customer-approved alternative. |
| Policy families | Rate/quota, token limit, content safety/prompt shield, semantic cache, diagnostics, retry, circuit breaker, fallback. |
| Bypass | Direct routes, admin routes, background jobs, connectors, private endpoints, or hybrid paths outside gateway view. |
| Diagnostics | Gateway logs, correlation fields, destination workspace, retention, and query owner. |

## Private network and DNS checks

![Private DNS resolution flow showing component, DNS query, private DNS zone, private IP resolution, internal VNet traffic, and target Azure service.](../assets/diagrams/s3-private-dns-resolution-flow.svg)

| Area | Required record |
|---|---|
| VNet/subnet | Platform VNet, orchestration subnet, execution subnet, data private endpoint subnet, route owner. |
| Private Endpoint | Services requiring Private Endpoint, public-network setting, exception owner. |
| Private DNS | Zone name, VNet link, resolver/split-horizon behavior, validation owner. |
| Firewall/NSG | Deny-by-default posture, allowed paths, route table, flow-log owner. |
| Hybrid/peering | Peering, gateway transit, proxy/firewall route, on-premises or partner boundary owner. |
| Monitoring | NSG flow logs, DNS failures, denied traffic, unexpected public endpoint use, query owner. |

Typical private DNS zones to verify by service category:

| Service | Public FQDN pattern | Private DNS zone |
|---|---|---|
| Cosmos DB | `*.documents.azure.com` | `privatelink.documents.azure.com` |
| Azure AI Search | `*.search.windows.net` | `privatelink.search.windows.net` |
| Blob Storage | `*.blob.core.windows.net` | `privatelink.blob.core.windows.net` |
| Cognitive services | `*.cognitiveservices.azure.com` | `privatelink.cognitiveservices.azure.com` |
| Azure OpenAI where applicable | `*.openai.azure.com` | `privatelink.openai.azure.com` |
| Azure Container Registry | `*.azurecr.io` | `privatelink.azurecr.io` |

## Identity boundary checklist

| Boundary | Technical question |
|---|---|
| Human caller | Is the user authenticated directly, delegated through OBO, or abstracted by a host service? |
| Host workload | Which managed identity, app registration, federated credential, or service principal runs the host? |
| Agent identity | Is Entra Agent ID/Agent 365 available and in scope, or is the agent represented by another owned identity record? |
| Gateway identity | Which identity authenticates to backend/model/tool routes? |
| Tool/API identity | Which scopes, roles, consent, secrets, certificates, managed identities, or federated credentials authorize the operation? |
| Resource authorization | Which RBAC/API permission actually allows the data or action? |

## Telemetry and correlation contract

| Area | Required question |
|---|---|
| Origin | Which request ID, W3C `traceparent`, APIM request ID, run ID, session ID, or time-window method starts the trace? |
| Propagation | Does it reach gateway, app, Foundry/model, tool/API, data dependency, and log store? |
| Destination | Which Application Insights, Azure Monitor, Log Analytics, gateway, app, data, or SIEM record receives it? |
| Blind spot | Which segments are sampled, unsupported, SaaS-owned, unlogged, or outside export scope? |
| Empty result | Which query, route scope, diagnostic state, time range, and reviewer make absence meaningful? |
| Retention | Who owns retention, export, deletion/hold, and evidence access? |

## Decision outcomes

| Outcome | Use when |
|---|---|
| Proceed with assumptions | Route, owners, support caveats, telemetry plan, and blockers are explicit enough for later runtime/evaluation/control-plane work. |
| Defer | A required route component exists conceptually but lacks owner, evidence reference, or acceptance criterion. |
| Route | Architecture, network, identity, security, catalog, or telemetry owner must resolve a specific technical blocker. |
| Reject | The route cannot meet the minimum trust-boundary, support, observability, or ownership requirement for the pilot. |
| Block | Missing owner, unknown hosting boundary, unmanaged egress, unsafe identity, unreviewable SaaS/hybrid boundary, or no retention route prevents reliance. |

## Boundary note

S3 never deploys, configures, tests, grants access, exports logs, proves runtime
control effectiveness, or approves production. Record safe references and
technical blockers only.
