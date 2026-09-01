# Azure API Management AI gateway implementation

## Session scope

### What we will do

Implement the **Foundry Agent Service policy-assistant variant** designed in
[Session 06](../../06-apim-ai-gateway-design/implementation/README.md). Configure one Azure API
Management route for the governed [Session 04](../../04-governed-agent-baseline/implementation/README.md)
policy assistant. APIM validates the client token and product subscription, applies the approved
limits and Content Safety policy, then uses its managed identity to call the pinned Foundry agent.

The result is a marked, version-controlled APIM API and product with body-free telemetry. Confirm
that APIM rejects an invalid bearer identity before it calls Content Safety or Foundry.

### Why it matters

The API product owner manages workload access and limits in one place. Client authorization stays
separate from the identity used for backend calls. Operations gets correlation and token metrics
without storing prompts or responses.

### Boundaries

The deployment changes child resources in the approved nonproduction APIM instance. APIM stores
the live route and policy. Foundry stores the agent configuration. This control covers requests
sent through this route. Owners govern direct Foundry access separately.

The Session 06 design record can describe other approved backend types. This implementation uses a
Foundry Agent Service target agent endpoint. Production ingress, semantic caching, secondary-region
routing, and write-capable agents need separate designs.
[Session 08](../../08-api-center-ai-mcp-inventory/implementation/README.md)
records the route in API Center. [Session 09](../../09-mcp-tool-security/implementation/README.md)
adds the MCP tool boundary.

## Architecture

### Architecture at a glance

The caller sends a Microsoft Entra application token and a workload-specific APIM subscription
key. APIM validates both, rejects oversized bodies, applies token limits, and sends the input to
Azure AI Content Safety. For a passing request, APIM replaces the caller's authorization with a
Foundry token from its system-assigned managed identity, then calls the pinned Session 04 agent.

Application Insights receives correlation and token metrics. Request and response bodies stay out
of the logs.

![An approved client passes APIM identity, limit, safety, and routing gates before reaching the Foundry agent.](../assets/diagrams/apim-ai-gateway-flow.svg)

The repository defines the gateway configuration that the deployment scripts apply. APIM is
authoritative for the live route, product, backends, and policy. Foundry is authoritative for the
agent.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Client access | Entra application token plus one APIM subscription per workload | Identity and usage allocation can be revoked separately | Clients manage two credentials | Entra alone meets quota and revocation needs |
| Backend identity | APIM managed identity with Foundry Agent Consumer on one agent | APIM stores no backend key | Direct Foundry access remains possible | Another approved control governs the direct endpoint |
| Safety | APIM Content Safety before the agent's RAI policy | Unsafe input can stop before the agent call | Adds latency, cost, and another data path | Safety owners approve a different split |
| Routing | Primary backend and one read-safe retry; secondary disabled | Keeps the failure path bounded | No regional failover | Session 14 approves a compatible secondary |
| Telemetry | Correlation and token metrics; body logging disabled | Supports operations without retaining content | Logs cannot explain a failed exchange from its content | A data owner approves limited content capture |

### Architecture guidance

- [AI gateway capabilities in Azure API Management](https://learn.microsoft.com/en-us/azure/api-management/genai-gateway-capabilities)
- [Authenticate and Authorize to LLM APIs](https://learn.microsoft.com/en-us/azure/api-management/api-management-authenticate-authorize-ai-apis)
- [Azure API Management Backends](https://learn.microsoft.com/en-us/azure/api-management/backends)

## Before you start

Confirm the following:

- The approved [Session 06 gateway design](../../06-apim-ai-gateway-design/implementation/README.md)
  record uses `ready-for-implementation`, has no open readiness gaps, names this APIM instance,
  and selects `foundry-agent-service` with the `policy-assistant-responses` variant. The delivery
  owner confirms those values. (Session 06.)
- The target Foundry Agent Service policy assistant exposes a pinned Entra-authorized Responses
  endpoint that matches `sandbox.json`. The Foundry platform owner confirms the endpoint and
  network path. (Sessions 02-04.)
- The operator has time-bound **Contributor** on the exact resource group that contains APIM.
- APIM uses Developer, Basic, Basic v2, Standard, Standard v2, Premium, or Premium v2 and has a
  system-assigned managed identity.
- That identity has **Foundry Agent Consumer**
  (`eed3b665-ab3a-47b6-8f48-c9382fb1dad6`) on the individual Session 04 agent.
- The approved APIM Content Safety backend uses managed identity, and the APIM identity has
  **Cognitive Services User** (`a97b65f3-24c7-4388-baec-2e87135dc908`) on that exact Content Safety
  resource.
- The named Application Insights logger exists in APIM and uses the approved managed-identity
  connection.
- `sandbox.json` names the live APIM virtual network type and the live Foundry and Content Safety
  public-network-access values. The network owner confirms that they agree with the Session 06
  inbound, backend, and private DNS paths.
- The Entra application, audience, client application, and app role are approved.
- The product owner has issued one workload-specific APIM subscription and stored its key in the
  approved secret store.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/gateway/main.bicep`](artifacts/gateway/main.bicep) | The Session 07 APIM deployment scripts |
| Deployment | [`artifacts/gateway/apis/policy-assistant-responses.openapi.json`](artifacts/gateway/apis/policy-assistant-responses.openapi.json) | The API Management API import |
| Deployment | [`artifacts/gateway/policies/policy.xml`](artifacts/gateway/policies/policy.xml) | The API Management gateway runtime |
| Deployment | [`artifacts/governance/gateway-control.json`](artifacts/governance/gateway-control.json) | The Session 07 preflight and APIM deployment scripts |
| Record | [`artifacts/governance/model-routing-decision.md`](artifacts/governance/model-routing-decision.md) | The API product, platform, safety, and operations owners |
| Deployment | [`artifacts/environments/sandbox.json`](artifacts/environments/sandbox.json) | The Session 07 preflight and deployment scripts |

Keep subscription IDs, backend URLs, keys, bearer tokens, prompts, responses, and customer data out
of the repository.

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value in `gateway-control.json` and `sandbox.json`.

**Design record.** Keep the Session 06 record in `ready-for-implementation` status. Its APIM
instance must match `sandbox.json`. Its backend type and implementation variant must be
`foundry-agent-service` and `policy-assistant-responses`. Set its Content Safety decision to
`enabled` and name the approved backend reference. Preflight reads the record, then checks its APIM
tier and the live APIM, Foundry, and Content Safety network values against `sandbox.json`.

**Client access.** Pin the tenant, client application, audience, and required `roles` claim. Use
one APIM subscription per workload. Do not use shared team keys, the all-access subscription, or a
user token for an application workload.

**Backend access.** Scope Foundry Agent Consumer to the individual agent. The base URL must end at:

```text
https://<account>.services.ai.azure.com/api/projects/<project>/agents/<agent>/endpoint/protocols/openai
```

APIM appends `/responses`. Keep the full runtime URL out of source control.

**Runtime controls.**

| Control | Approved value |
|---|---:|
| Tokens per minute per APIM subscription | 20,000 |
| Daily token quota per APIM subscription | 500,000 |
| Request body limit | 65,536 bytes |
| Backend response-header timeout | 120 seconds |
| Retry for 429/5xx | 1 |
| Circuit breaker | 5 errors in 1 minute; open for 1 minute |

The retry is allowed because the Session 04 agent has a read-only tool. Keep the secondary backend
disabled. Enable it after the service and cost owners approve a Responses-compatible endpoint with
matching model behavior, agent version, data boundary, safety policy, logging dimensions, and
restore path. APIM counters are gateway-local. Session 14 must assign per-region budgets.

**Safety and telemetry.** APIM enables Prompt Shields and checks Hate, SelfHarm, Sexual, and
Violence at threshold 4 on the eight-level scale. A nonstreaming violation returns `403`. For a
streaming completion, APIM can stop later events and leave the client with a truncated stream.

Set diagnostic request and response body logging to zero bytes and disable client IP logging.
Streaming clients set `stream_options.include_usage=true`. Interrupted streams can undercount token
metrics, and streaming limits use estimates. Azure Cost Management and the invoice are the billing
records.

Stop when any of these conditions applies:

- The Azure subscription, APIM resource group, APIM service, agent, Content Safety resource, or
  Application Insights logger differs from the approved inputs.
- The operator lacks time-bound Contributor on the APIM resource group.
- APIM lacks its system-assigned identity, agent-scoped Foundry Agent Consumer, or resource-scoped
  Cognitive Services User.
- The client identity, audience, app role, or workload subscription is missing or shared.
- Content Safety uses a key, the network cannot reach its endpoint, or its policy conflicts with
  the Session 04 RAI policy.
- A retry could repeat a write or other consequential action.
- ARM `what-if` replaces or removes unrelated resources, changes the APIM service, changes the
  approved API or product ID, or exposes a live endpoint in source.

## Implement

### 1. Complete the inputs

Edit `gateway-control.json`, `sandbox.json`, and `model-routing-decision.md`. Set the runtime values:

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$primaryAgentBaseUrl = $env:session07_PRIMARY_AGENT_BASE_URL
$secondaryAgentBaseUrl = $env:session07_SECONDARY_AGENT_BASE_URL
```
```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:?Set AZURE_SUBSCRIPTION_ID.}"
primary_agent_base_url="${session07_PRIMARY_AGENT_BASE_URL:?Set session07_PRIMARY_AGENT_BASE_URL.}"
secondary_agent_base_url="${session07_SECONDARY_AGENT_BASE_URL:-}"
```

Leave the secondary URL empty while `secondaryBackendEnabled` is `false`.

### 2. Run preflight and inspect the preview

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -PrimaryAgentBaseUrl $primaryAgentBaseUrl `
  -SecondaryAgentBaseUrl $secondaryAgentBaseUrl
```
```bash
./scripts/preflight.sh --approved-subscription-id "$approved_subscription_id" --primary-agent-base-url "$primary_agent_base_url" --secondary-agent-base-url "$secondary_agent_base_url"
```

Preflight checks the approved Session 06 record, actual backend URL and authorization, APIM tier
and identity, APIM, Foundry, and Content Safety network values, both role assignments, Content
Safety backend, logger, existing API marker, and ARM `what-if`. Stop on any listed gate.

### 3. Deploy

```powershell
.\scripts\deploy.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -PrimaryAgentBaseUrl $primaryAgentBaseUrl `
  -SecondaryAgentBaseUrl $secondaryAgentBaseUrl
```
```bash
./scripts/deploy.sh --approved-subscription-id "$approved_subscription_id" --primary-agent-base-url "$primary_agent_base_url" --secondary-agent-base-url "$secondary_agent_base_url"
```

The script reruns preflight and deploys the marked API, product, named values, backend pool,
policy, and body-free diagnostics. Use the subscription issued before the session.

## Confirm the result

Use a valid workload subscription key with an invalid bearer token. Use synthetic content.

```powershell
$gatewayUrl = "https://$((Get-Content .\artifacts\environments\sandbox.json -Raw |
  ConvertFrom-Json).apiManagementName).azure-api.net/ai/policy-assistant/responses"
$headers = @{
  Authorization = "******"
  "Ocp-Apim-Subscription-Key" = $env:session07_APIM_SUBSCRIPTION_KEY
  "X-Correlation-ID" = [guid]::NewGuid().ToString()
}
$body = @{ input = "Return the title of synthetic policy POL-001." } | ConvertTo-Json

try {
  Invoke-WebRequest `
    -Method POST `
    -Uri $gatewayUrl `
    -Headers $headers `
    -ContentType "application/json" `
    -Body $body `
    -ErrorAction Stop
  throw "The invalid identity was accepted."
}
catch {
  if ($null -eq $_.Exception.Response) {
    throw
  }
  $statusCode = [int]$_.Exception.Response.StatusCode
  if ($statusCode -ne 401) {
    throw "Expected 401 for the invalid identity; received $statusCode."
  }
  Write-Host "PASS: APIM rejected the invalid identity with 401."
}
```
```bash
gateway_url="https://$(python3 -c 'import json, pathlib; print(json.loads(pathlib.Path("artifacts/environments/sandbox.json").read_text())["apiManagementName"])').azure-api.net/ai/policy-assistant/responses"

export session07_GATEWAY_URL="$gateway_url"
export session07_APIM_SUBSCRIPTION_KEY="${session07_APIM_SUBSCRIPTION_KEY:?Set session07_APIM_SUBSCRIPTION_KEY.}"
export session07_CORRELATION_ID="$(python3 -c 'import uuid; print(uuid.uuid4())')"
python3 - <<'PY'
import json
import os
import urllib.error
import urllib.request

body = json.dumps({"input": "Return the title of synthetic policy POL-001."}).encode()
request = urllib.request.Request(
    os.environ["session07_GATEWAY_URL"],
    data=body,
    headers={
        "Authorization": "******",
        "Ocp-Apim-Subscription-Key": os.environ["session07_APIM_SUBSCRIPTION_KEY"],
        "X-Correlation-ID": os.environ["session07_CORRELATION_ID"],
        "Content-Type": "application/json",
    },
    method="POST",
)
try:
    urllib.request.urlopen(request)
    raise SystemExit("The invalid identity was accepted.")
except urllib.error.HTTPError as error:
    if error.code != 401:
        raise SystemExit(f"Expected 401 for the invalid identity; received {error.code}.")
    print("PASS: APIM rejected the invalid identity with 401.")
PY
unset session07_GATEWAY_URL session07_APIM_SUBSCRIPTION_KEY session07_CORRELATION_ID
```

APIM must return `401 Unauthorized` before calling Content Safety or Foundry. Do not retain the
response, subscription key, or headers. Test other identities and policy branches separately.

## After implementation

| What remains | Owner |
|---|---|
| Product subscriptions and workload limits | API product owner |
| Entra app role and APIM identity assignments | Identity owner |
| APIM capacity, backends, and routing | Platform owner |
| Content Safety backend and thresholds | Safety owner |
| Correlation, metrics, alerts, retention, and cost | Operations owner |
| Deployment definitions and scripts | Platform engineering |

Run this configuration against the nonproduction resources named in the deployment inputs and
routing decision.

To remove the route, first confirm that no approved consumer uses it. Through the approved APIM
change path, check `implementationSession=07-apim-ai-gateway-implementation`. Remove only the
Session 07 API, product, backends, and four nonsecret named values. Leave APIM, the logger, Content
Safety, Foundry, role assignments, and repository definitions in place.

To disable an approved secondary while keeping the primary live, set `secondaryBackendEnabled` to
`false`, clear `session07_SECONDARY_AGENT_BASE_URL`, rerun preflight, and redeploy. For permanent
retirement, identity reviews both role assignments. Remove one only when no other approved APIM
route uses it.
