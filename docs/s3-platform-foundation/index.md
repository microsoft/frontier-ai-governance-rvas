# S3 · Platform Plumbing Verification

!!! info "Freshness"
    Last reviewed: 2026-07-30 · Use this as a read-only platform-route verification for one pilot path. Confirm service support, region, SKU, network mode, and customer access before delivery.

<span class="rvas-badge rvas-persona">Platform owner</span> <span class="rvas-badge rvas-persona">App owner</span> <span class="rvas-badge rvas-persona">Security operations</span>

!!! abstract "What this workshop does"
    S3 opens the actual platform records for one caller-to-model/tool route: Foundry project/resource, model deployment, APIM or gateway route, private endpoint and DNS where relevant, API Center catalog entry, telemetry, Defender/Sentinel handoff, and cost/quota owner. It runs one safe synthetic request or reviews one read-only trace.

## 1. Verify one route, not a platform slogan

Pick one pilot route and name the caller, app/orchestrator, gateway route,
backend model/tool/API, identity boundary, telemetry store, catalog record, and
cost/quota owner.

The route is accepted only when the customer can open or query each record below
or route the specific blocker:

1. **Foundry project/resource**: project, hub/resource, region, network mode,
   model deployment, connection/tool reference, identity, and owner.
2. **Model deployment**: model name/version, deployment name, endpoint type,
   quota/capacity, content-safety/evaluation handoff where applicable.
3. **APIM/gateway route**: API, product, subscription, backend, policy family,
   auth, diagnostics, correlation header, and bypass owner.
4. **Private route**: Private Endpoint, public-network access setting, private
   DNS zone/link, VNet/subnet, firewall/NSG/route table, and flow-log owner.
5. **API Center/catalog**: API/tool/model route record, version, lifecycle state,
   environment, owner, and deprecation/exception route.
6. **Telemetry**: Application Insights, Log Analytics, diagnostic settings,
   trace IDs, request IDs, workspace, retention, and query owner.
7. **Defender/Sentinel handoff**: Defender plan/alert route, Sentinel workspace,
   analytics rule/incident owner, and unsupported security-monitoring gaps.
8. **Cost and quota**: Foundry/Azure OpenAI quota owner, APIM product quota,
   token/capacity metric owner, cost allocation tag/subscription owner.

Store completed evidence in the customer's approved system. This repo keeps only
safe field shapes.

## 2. Exact inspection sequence

### Foundry and model deployment

- Open `ai.azure.com` -> select the project -> **Management center**. Check the
  project, connected Azure resource, region, model deployments, connections,
  tracing/monitoring settings, and owner.
- Open **Azure portal** -> resource group -> **Azure AI Foundry / Azure AI
  services / Azure OpenAI** resource -> **Overview**, **Networking**,
  **Identity**, **Model deployments** or deployment blade, **Metrics**,
  **Diagnostic settings**, **Access control (IAM)**.
- Check model deployment route: deployment name, model/version, endpoint type,
  SKU/capacity/quota, private/public endpoint state, and capacity owner.

### APIM or gateway

- Open **Azure portal** -> **API Management services** -> instance ->
  **APIs** -> selected API -> operation.
- Inspect **Settings**, **Design**, **Inbound processing**, **Backend**,
  **Products**, **Subscriptions**, **Named values** references, **Diagnostics**,
  **Logs**, and **Policy fragments**.
- Confirm the route ID: gateway hostname alias, API ID, operation ID, product,
  backend ID, and correlation header or request ID.

### Private endpoint and DNS

- Open target resource -> **Networking** -> public-network access and private
  endpoint connections.
- Open **Azure portal** -> **Private endpoints** -> endpoint -> **DNS
  configuration** and **Network interface**.
- Open **Private DNS zones** -> zone, record set, and VNet links.
- Open VNet/subnet -> **Network security group**, **Route table**, peering, DNS
  resolver, firewall route, and flow-log/traffic analytics owner where relevant.

### API Center and catalog

- Open **Azure portal** -> **API Center** -> API -> version -> definition,
  environments, deployments, lifecycle, contacts/owners, custom properties, and
  related APIM deployment.
- If API Center is not used, open the customer's catalog record and verify the
  same fields.

### Monitoring, security, and cost

- Open resource/APIM/app -> **Diagnostic settings**. Confirm logs and metrics
  route to the named Log Analytics workspace, Event Hub, or Storage account.
- Open **Application Insights** -> **Transaction search**, **Failures**,
  **Performance**, and **Logs** for the trace ID/time window.
- Open **Log Analytics** -> query APIM, AppRequests, AppTraces, AzureDiagnostics,
  and resource-specific tables for the trace.
- Open **Microsoft Defender for Cloud** -> workload/resource recommendations and
  security alerts where the service is covered.
- Open **Microsoft Sentinel** -> workspace -> **Logs**, **Analytics**, and
  **Incidents** only if the customer's SOC uses Sentinel for this path.
- Open **Cost Management + Billing** -> cost analysis/tags/budgets and service
  quota blade for the owner of quota, PTU, token budget, and APIM quota.

## 3. Run a safe synthetic request or inspect one trace

Use synthetic non-customer content. If a live test is not approved, use a
read-only trace from the customer's existing non-production logs.

Required safe fields:

- route ID: APIM API/operation/backend or direct route alias;
- time window and trace/request ID;
- app/agent alias and model/tool/API alias;
- expected gateway policy and backend route;
- telemetry query owner and workspace alias;
- private/public route expectation;
- cost/quota counter owner.

Expected checks:

1. Request enters the expected gateway route or the direct-route exception is
   visible and owned.
2. Gateway policy applies: auth, rate/quota, token policy, diagnostics, or
   configured policy family.
3. Backend route matches the intended Foundry/model/tool/API endpoint.
4. Identity is propagated or intentionally exchanged at the app/gateway/backend.
5. Private route is used when required; public fallback is disabled or exception
   owned.
6. Telemetry emits to Application Insights / Log Analytics with joinable
   correlation fields.
7. API Center/catalog has the route/version/lifecycle/owner.
8. Unsupported bypasses are recorded with owner and fix route.

## 4. Expected signals

| Signal | How to verify | Result route |
|---|---|---|
| Gateway policy applied | APIM trace/log shows API, operation, subscription/product, policy branch, response code, and correlation ID. | If absent, route to gateway owner. |
| Backend route matched | APIM backend ID, app trace, or model deployment log matches the expected backend. | If mismatched, route to platform/app owner. |
| Identity propagated | Gateway/app/backend logs show expected app, managed identity, user/OBO, or service principal correlation. | If lost, route to identity/app owner. |
| Private route used | Private endpoint connection, DNS resolution, VNet flow/DNS logs, or resource firewall logs show private path. | If public path used, route to network owner. |
| Telemetry emitted | Application Insights/Log Analytics query finds request, dependency, trace, or APIM event. | If empty, check diagnostics and sampling before no-result. |
| Catalog present | API Center/catalog record links API/version/deployment/owner/lifecycle. | If missing or stale, route to catalog owner. |
| Defender/Sentinel handoff | Covered alerts/recommendations/log rules have owner or unsupported status. | If absent, route to security operations owner. |
| Unsupported bypass found | Direct endpoint, admin path, connector, background job, or SaaS route avoids the gateway or logs. | Block reliance until exception owner accepts or fixes. |

## 5. Support limits

S3 does not deploy resources, change APIM policies, enable diagnostics, create
Private Endpoints, alter DNS, register API Center entries, configure Defender or
Sentinel, change quotas, or approve production.

Record these limits when they apply:

- Foundry, model deployment, gateway, telemetry, network, Defender, and API
  Center support depend on tenant, region, SKU, feature state, and customer
  configuration.
- A private endpoint existing does not prove the request used it; DNS and route
  evidence are needed.
- APIM policy configured does not prove every consumer uses APIM; bypasses must
  be checked.
- Application Insights sampling, diagnostic settings, and ingestion delay can
  hide events.
- Defender/Sentinel coverage is a handoff to security operations, not proof that
  the route is monitored.
- Cost tags and quotas need named owners; S3 does not allocate budget.

## 6. Lab output

`labs/s3-platform-foundation/` contains the route verification lab and template.
The completed customer record should include route ID, portal links, trace IDs,
telemetry query, result state, owner, fix route, and recheck condition without
storing endpoints, resource IDs, customer data, logs, or screenshots in this
repository.

## Related references

- [Technical decisions](technical.md)
- [Platform technical guide](../reference/platform-technical-guide.md)
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md)
