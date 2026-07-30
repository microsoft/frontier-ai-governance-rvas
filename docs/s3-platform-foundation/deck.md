# S3 · Platform Plumbing Verification

**Facilitator deck**

Microsoft default: **Microsoft Foundry, Azure AI resources, Azure API
Management or approved gateway, Private Link/private DNS where required, Azure
API Center, Application Insights, Log Analytics, Defender/Sentinel handoff, and
named cost/quota ownership**.

Concrete decision: **Can the customer verify the actual route from caller to
model/tool/API and see where it is private, mediated, observable, cataloged, and
owned?**

---

## Pick one platform route

- Caller -> app/orchestrator -> gateway or direct route -> model/tool/API.
- Name the route ID, environment, backend alias, trace handle, and owner.
- Use one synthetic non-customer request or one existing non-production trace.

Note:
Do not let "Azure platform" become the unit of review. The route is the unit.

---

## Open Foundry and model records

Routes:

- `ai.azure.com` -> project -> **Management center**.
- Azure portal -> Azure AI Foundry / Azure AI services / Azure OpenAI resource.

Inspect:

- project/resource, region, model deployment, connections/tools;
- Networking, Identity, Metrics, Diagnostic settings, IAM;
- quota/capacity owner and model deployment owner.

Note:
If the model deployment cannot be named, later gateway and telemetry checks are
not meaningful.

---

## Inspect APIM or gateway

Route:

**Azure portal** -> **API Management services** -> instance -> **APIs** ->
API -> operation.

Check:

- API ID, operation ID, product, subscription;
- inbound policy family and auth;
- backend ID and route;
- diagnostics and correlation header;
- direct-route and background bypasses.

Note:
Configured policy is not proof that every caller used the gateway.

---

## Verify private route and DNS

![Private DNS resolution flow showing component, DNS query, private DNS zone, private IP resolution, internal VNet traffic, and target Azure service.](../assets/diagrams/s3-private-dns-resolution-flow.svg)

Open:

- resource **Networking**;
- **Private endpoints** -> DNS configuration and NIC;
- **Private DNS zones** -> record sets and VNet links;
- VNet/subnet NSG, route table, firewall, flow logs.

Note:
Private endpoint existence is not enough. DNS and route evidence decide whether
the request used the private path.

---

## Check API Center/catalog

Open:

- Azure portal -> **API Center** -> API -> version -> definition, environments,
  deployments, lifecycle, contacts, custom properties.
- Customer catalog if API Center is not used.

Record route, version, owner, lifecycle, deployment target, exception, and
withdrawal/deprecation owner.

Note:
The catalog entry must point to the route the test actually uses.

---

## Query telemetry

Open:

- resource/APIM/app **Diagnostic settings**;
- Application Insights -> Transaction search and Logs;
- Log Analytics workspace -> Logs.

Look for:

- APIM request or gateway log;
- app request and dependency;
- backend/model/tool event;
- trace ID and correlation fields;
- sampling, delay, or missing diagnostic settings.

Note:
Empty logs are not a result until diagnostics, time range, sampling, and table
selection are checked.

---

## Security and cost handoff

Open:

- Defender for Cloud recommendations/alerts for covered resources.
- Sentinel Logs, Analytics, Incidents if the SOC uses Sentinel.
- Cost Management, budgets/tags, service quota, Foundry/model quota, APIM quota.

Record owner for alert route, incident route, token/capacity budget, quota
exception, and cost allocation.

Note:
S3 does not promise SOC monitoring. It finds who receives the handoff or records
that there is no supported handoff yet.

---

## Expected signals

| Signal | Good result |
|---|---|
| Gateway policy applied | APIM log shows API/operation/policy/correlation. |
| Backend route matched | APIM/app dependency points to intended deployment. |
| Identity propagated | Logs preserve user/app/managed identity as expected. |
| Private route used | DNS/flow/resource logs support private path. |
| Telemetry emitted | App Insights/Log Analytics has joinable events. |
| Catalog present | API Center/catalog has version, route, owner, lifecycle. |
| Bypass found | Direct path is owned, fixed, or blocks reliance. |

Note:
Each failed signal needs an owner, fix route, and recheck condition.

---

## Decide and hand over

Confirm:

- route ID and trace ID;
- Foundry/resource and model deployment;
- gateway route and bypasses;
- private endpoint/DNS state;
- API Center/catalog link;
- telemetry query and result state;
- Defender/Sentinel handoff;
- cost/quota owner.

Note:
S3 changes no resources and approves no production release.
