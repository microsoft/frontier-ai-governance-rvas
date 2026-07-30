# S3 · Platform Plumbing Verification: Technical runbook

!!! info "Freshness"
    Last reviewed: 2026-07-30 · Azure AI Foundry, Azure AI services, Azure OpenAI, API Management AI Gateway, API Center, Private Link, Azure Monitor, Defender, Sentinel, and quota surfaces vary by tenant, region, SKU, and feature state.

## Microsoft default

Default to a route the customer can open and query: Microsoft Foundry project and
model deployment, Azure API Management or approved gateway, Private Link/private
DNS where required, Azure API Center, Application Insights and Log Analytics,
Defender/Sentinel handoff, and named cost/quota ownership.

![S3 illustrative Azure platform pattern: callers cross an optional gateway trust boundary to orchestration or hosted execution, private data access, identity, and observability layers. The pattern identifies decisions and evidence expectations without claiming a deployed topology.](../assets/diagrams/s3-gateway-trust-boundary.svg)

S3 verifies platform plumbing for one route. It does not configure or prove all
runtime controls.

## 1. Preflight

| Check | Required detail | Blocker if missing |
|---|---|---|
| Route | Caller, app/orchestrator, gateway/direct route, backend model/tool/API, and environment. | Do not run a generic platform review. |
| Owners | Platform, app, gateway, network, telemetry, catalog, security operations, and cost/quota owners. | Route or block missing owner. |
| Access | Reader access to Foundry/Azure resource, APIM/gateway, network, API Center, Application Insights/Log Analytics, Defender/Sentinel where used, and cost/quota views. | Do not infer state from diagrams. |
| Safe test | One synthetic non-customer request or approved read-only trace review. | Do not use customer data. |
| Evidence handling | Customer-approved location for portal links, trace IDs, and query text. | Do not paste logs or endpoints into repo files. |

## 2. Foundry project and model deployment

Portal route:

1. Open `ai.azure.com`.
2. Select the customer project.
3. Open **Management center**.
4. Inspect project, hub/resource, region, deployments, connections/tools,
   network settings, identity, monitoring/tracing settings, and owner.

Azure portal route:

1. Open **Azure portal** -> resource group.
2. Open the **Azure AI Foundry / Azure AI services / Azure OpenAI** resource.
3. Inspect **Overview**, **Networking**, **Identity**, **Model deployments** or
   deployment blade, **Metrics**, **Diagnostic settings**, and **Access control
   (IAM)**.

Read-only CLI anchors:

```bash
az resource show --ids "$FOUNDRY_OR_AI_RESOURCE_ID" \
  --query "{name:name,type:type,location:location,identity:identity.type}"
az monitor diagnostic-settings list --resource "$FOUNDRY_OR_AI_RESOURCE_ID" \
  --query "[].{name:name,workspaceId:workspaceId,logs:logs[].category,metrics:metrics[].category}"
az role assignment list --scope "$FOUNDRY_OR_AI_RESOURCE_ID" \
  --query "[].{principalName:principalName,role:roleDefinitionName,scope:scope}"
```

Capture: project/resource alias, model deployment alias, model/version, endpoint
type, network setting, diagnostic setting, capacity/quota owner, and support
limit. Do not store endpoints or resource IDs in this repo.

## 3. APIM or gateway route

Portal route:

1. **Azure portal** -> **API Management services** -> APIM instance.
2. Open **APIs** -> selected API -> selected operation.
3. Inspect **Settings**, **Design**, **Inbound processing**, **Backend**,
   **Products**, **Subscriptions**, **Diagnostics**, **Logs**, **Policy
   fragments**, and **Named values** references.

Read-only CLI anchors:

```bash
az apim api show --resource-group "$RG" --service-name "$APIM" --api-id "$API_ID" \
  --query "{name:name,path:path,protocols:protocols,serviceUrl:serviceUrl,apiRevision:apiRevision}"
az apim api operation show --resource-group "$RG" --service-name "$APIM" \
  --api-id "$API_ID" --operation-id "$OPERATION_ID" \
  --query "{name:name,method:method,urlTemplate:urlTemplate}"
az monitor diagnostic-settings list --resource "$APIM_RESOURCE_ID" \
  --query "[].{name:name,workspaceId:workspaceId,logs:logs[].category}"
```

Capture: route ID, API ID, operation ID, product/subscription, backend ID,
policy family expected, auth mode, diagnostics destination, correlation field,
and bypass owner.

Policy evidence to look for without pasting live policy:

- caller auth / `validate-jwt` or equivalent;
- backend route / `set-backend-service`;
- rate/quota/token policy;
- diagnostics/correlation headers;
- retry/circuit breaker/fallback where relevant;
- direct endpoint exceptions and admin/background routes.

## 4. Private endpoint and private DNS

![Private DNS resolution flow showing component, DNS query, private DNS zone, private IP resolution, internal VNet traffic, and target Azure service.](../assets/diagrams/s3-private-dns-resolution-flow.svg)

Portal route:

1. Target Azure resource -> **Networking** -> public-network access and private
   endpoint connections.
2. **Azure portal** -> **Private endpoints** -> endpoint -> **DNS
   configuration** and **Network interface**.
3. **Private DNS zones** -> zone -> record set and **Virtual network links**.
4. VNet/subnet -> **Network security group**, **Route table**, peering, DNS
   resolver, firewall route, and flow logs/traffic analytics.

Read-only CLI anchors:

```bash
az network private-endpoint show --ids "$PRIVATE_ENDPOINT_ID" \
  --query "{name:name,subnet:subnet.id,customDnsConfigs:customDnsConfigs}"
az network private-dns link vnet list --resource-group "$DNS_RG" --zone-name "$ZONE" \
  --query "[].{name:name,virtualNetwork:virtualNetwork.id,registrationEnabled:registrationEnabled}"
az network private-dns record-set a list --resource-group "$DNS_RG" --zone-name "$ZONE" \
  --query "[].{name:name,records:aRecords[].ipv4Address}"
```

Typical private DNS zones:

| Service | Public FQDN pattern | Private DNS zone |
|---|---|---|
| Azure AI Search | `*.search.windows.net` | `privatelink.search.windows.net` |
| Blob Storage | `*.blob.core.windows.net` | `privatelink.blob.core.windows.net` |
| Cosmos DB | `*.documents.azure.com` | `privatelink.documents.azure.com` |
| Cognitive services | `*.cognitiveservices.azure.com` | `privatelink.cognitiveservices.azure.com` |
| Azure OpenAI where applicable | `*.openai.azure.com` | `privatelink.openai.azure.com` |
| Azure Container Registry | `*.azurecr.io` | `privatelink.azurecr.io` |

Accepted only when DNS, endpoint, route, public fallback, and owner are clear.

## 5. API Center and catalog

Portal route:

1. **Azure portal** -> **API Center**.
2. Open API -> version -> definition, environments, deployments, contacts,
   custom properties, lifecycle, and related APIM deployment.

CLI anchors:

```bash
az apic api show --service-name "$APIC" --resource-group "$RG" --api-id "$CATALOG_API_ID"
az apic api version list --service-name "$APIC" --resource-group "$RG" --api-id "$CATALOG_API_ID"
```

Capture: API/tool/model route alias, version, environment, deployment target,
owner/contact, lifecycle state, data classification/custom property, exception,
and withdrawal/deprecation owner. If API Center is not used, inspect the
customer-approved catalog with the same fields.

## 6. Telemetry and security operations

Portal routes:

- Resource/APIM/app -> **Diagnostic settings**.
- **Application Insights** -> **Transaction search**, **Failures**,
  **Performance**, **Logs**.
- **Log Analytics workspace** -> **Logs**.
- **Defender for Cloud** -> resource recommendations and alerts.
- **Microsoft Sentinel** -> workspace -> **Logs**, **Analytics**, **Incidents**.

Query examples to adapt in the customer workspace:

```kusto
AppRequests
| where TimeGenerated between (datetime({start}) .. datetime({end}))
| where OperationId == "{trace-id}" or Id == "{request-id}"
| project TimeGenerated, Name, ResultCode, OperationId, AppRoleName
```

```kusto
AzureDiagnostics
| where TimeGenerated between (datetime({start}) .. datetime({end}))
| where ResourceProvider has "MICROSOFT.APIMANAGEMENT"
| where CorrelationId_g == "{correlation-id}" or requestId_s == "{request-id}"
| project TimeGenerated, apiId_s, operationId_s, backendUrl_s, responseCode_d
```

```kusto
AppDependencies
| where TimeGenerated between (datetime({start}) .. datetime({end}))
| where OperationId == "{trace-id}"
| project TimeGenerated, Target, Name, ResultCode, DependencyType
```

Capture: workspace alias, query owner, query text reference, trace ID, result
state, sampling/ingestion delay, retention owner, Defender/Sentinel handoff owner.

## 7. Cost and quota

Portal routes:

- **Azure portal** -> Foundry/Azure OpenAI/Azure AI resource -> **Quotas** or
  model deployment capacity view where available.
- **Azure portal** -> **API Management** -> product/API/subscription quotas and
  policy owner.
- **Cost Management + Billing** -> **Cost analysis**, **Budgets**, **Tags**.
- **Azure portal** -> subscription -> **Usage + quotas** for service quota where
  applicable.

Capture owner for PTU/quota/token budget, APIM product allocation, cost tags,
budget alert recipient, and escalation route.

## 8. Safe synthetic request or read-only trace review

Preferred safe test:

1. Send one synthetic non-customer request through the non-production app.
2. Include an approved correlation header such as `x-correlation-id`.
3. Record only the route alias, timestamp, and correlation handle.
4. Query APIM, Application Insights, dependencies, and backend/model telemetry.
5. Check private route evidence only through customer-approved network/DNS logs.

Read-only fallback:

1. Use one existing non-production trace ID and time window.
2. Open the same portal records and queries.
3. Record whether the trace is complete, partial, delayed, unsupported, or
   blocked.

## 9. Expected result states

| State | Meaning | Next action |
|---|---|---|
| Verified | Gateway, backend, identity, private route if required, telemetry, catalog, security handoff, and quota owner all match. | Continue S5/runtime work using this route ID. |
| Partial | One segment is visible but another is delayed, sampled, or unqueried. | Assign recheck owner and time. |
| Bypass | Direct endpoint, background job, connector, admin route, or SaaS path avoids gateway/logging. | Route to platform/security owner; block reliance if unowned. |
| Public path | Private route was expected but DNS/flow/resource logs show public access or public fallback. | Route to network owner. |
| No telemetry | Diagnostics disabled, workspace missing, sampled away, or ingestion delayed. | Route to telemetry owner before relying on observability. |
| Catalog gap | API Center/catalog record missing, stale, or not linked to route/version. | Route to catalog owner. |
| Unsupported | Product/SKU/region/service route cannot provide the assumed feature. | Route to architecture owner for alternate path. |

## 10. Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Foundry/resource | Project/resource, deployment, region, network mode, identity, diagnostics, and owner are inspected. | Foundry/platform owner |
| Gateway route | API/operation/product/backend/policy intent/diagnostics/correlation/bypass owner are recorded. | Gateway owner |
| Private route | Private Endpoint, DNS zone/link, public fallback, route, firewall/NSG, and validation owner are recorded where required. | Network owner |
| API Center | API/tool/model route, version, deployment, lifecycle, and owner are present or gap is routed. | Catalog owner |
| Telemetry | Trace/query finds APIM/app/dependency/backend event or validated no-result with diagnostics scope. | Telemetry owner |
| Defender/Sentinel | Monitoring handoff is covered, unsupported, or routed with owner. | Security operations |
| Cost/quota | Quota, token/capacity, APIM product, cost tag/budget owner are named. | FinOps/platform owner |
| Limits | Bypass, public route, unsupported service, sampled telemetry, and stale catalog gaps are routed with recheck. | Governance lead |

## Boundary note

S3 performs read-only verification and one safe synthetic or trace review. It
does not deploy, configure, enable diagnostics, change network routing, change
gateway policy, register catalog entries, alter quota, export logs, or approve
production.
