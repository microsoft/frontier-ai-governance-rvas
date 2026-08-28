# Azure API Management as the AI gateway

## Session scope

### What we will do

Configure **one Azure API Management route** for the governed
[Session 05](../../05-governed-agent-baseline/implementation/README.md) policy assistant. On that
route, APIM checks the client token and product subscription, applies the approved limits and
Content Safety policies, then uses its managed identity to call the pinned Foundry agent. This
session produces a marked, version-controlled APIM API and product with body-free operational
telemetry.

### Why it matters

The configured route gives the API product owner one place to manage workload access and limits.
It also separates client authorization from the identity used for the backend call, while giving
operations correlation and token metrics without prompt or response logging.

### Boundaries

This session changes child resources in the established nonproduction APIM instance. APIM is
the service that stores and applies the deployed gateway policy. Foundry stores the agent
configuration and reports the direct endpoint state. The control applies to requests sent through
this APIM route. It does not disable the direct Foundry endpoint or prove that every possible client
path uses APIM. Owners must govern direct endpoint access separately.

Production ingress, semantic caching, secondary-region routing, and write-capable agents are
excluded. [Session 07](../../07-api-center-ai-mcp-inventory/implementation/README.md) records the
route in API Center, while
[Session 08](../../08-mcp-tool-security/implementation/README.md) adds the MCP tool boundary.

## Architecture

### Architecture at a glance

Every request governed by this design follows one APIM route. The caller presents two credentials
because they answer different questions. A Microsoft Entra application token says which workload
is calling. The APIM product subscription assigns usage to that workload and gives operators
another way to revoke access.

APIM applies the checks in a fixed order. Its inbound policy validates both credentials, rejects an
oversized body, enforces the subscription's token limit, and sends the input to Azure AI Content
Safety. Only a request that passes those checks reaches the primary backend. Before making that
call, APIM replaces the caller's authorization with a Foundry token obtained through its
system-assigned managed identity. The pinned Session 05 agent then applies its own responsible AI
(RAI) policy.

Application Insights receives correlation and token metrics from this path. Request and response
bodies stay out of the logs.

![The APIM request pipeline checks the product subscription and Entra token, then applies size, token, and safety controls before routing to the pinned Foundry endpoint](../assets/diagrams/apim-ai-gateway-flow.svg)

APIM shows the live route, product, backends, and runtime policy. Foundry remains the record for the
agent itself. The repository defines the gateway configuration that the deployment path applies.

This control covers requests from their entry to this APIM route through the Foundry backend call.
Direct access to the Foundry endpoint needs a separate access decision. Session 07 uses the API
definition and runtime location for inventory. Session 08 adds MCP tool controls.

### Design choices and tradeoffs

| Decision | Chosen approach | Why this shape works | Tradeoff | Revisit when |
|---|---|---|---|---|
| Client access | Require an Entra application token and one APIM subscription per workload | Identity and usage allocation can be inspected or revoked separately | Each client must manage two credentials | Entra-only allocation can meet the product owner's quota and revocation needs |
| Backend identity | Give the APIM system-assigned managed identity Foundry Agent Consumer on one agent | APIM stores no backend key, and the role stops at the selected agent | The direct Foundry endpoint still exists | Direct endpoint access is removed or governed by another approved route |
| Safety layers | Run APIM Content Safety before the Foundry agent's RAI policy | APIM can stop unsafe input before it reaches the agent | The extra check adds latency, cost, and another data path | Safety owners approve a different split based on measured behavior |
| Routing | Use a primary backend with one read-safe retry; keep the secondary disabled | The failure path stays bounded and easy to reason about | This session provides no regional failover | A compatible secondary endpoint and Session 14 regional design are approved |
| Telemetry | Emit correlation and token metrics with body logging disabled | Operators can follow requests without retaining prompts or responses | They cannot debug the content of a failed exchange from these logs | A data owner approves narrowly scoped content capture |

### Architecture guidance

- [AI gateway capabilities in Azure API Management](https://learn.microsoft.com/en-us/azure/api-management/genai-gateway-capabilities) lists the supported gateway controls and tier requirements.
- [Authenticate and Authorize to LLM APIs](https://learn.microsoft.com/en-us/azure/api-management/api-management-authenticate-authorize-ai-apis) explains the ingress and managed-identity backend split.
- [Azure API Management Backends](https://learn.microsoft.com/en-us/azure/api-management/backends) covers managed-identity authorization, pools, and circuit breakers.

## Before you start

Confirm these prerequisites:

- Sessions 01-04 are complete in the approved nonproduction scope.
- The deployment operator has a time-bound **Contributor** role assignment on the exact
  nonproduction resource group that contains the APIM instance.
- The existing APIM instance uses Developer, Basic, Basic v2, Standard, Standard v2, Premium, or
  Premium v2.
- That APIM instance has a system-assigned managed identity.
- The APIM identity has Foundry Agent Consumer
  (`eed3b665-ab3a-47b6-8f48-c9382fb1dad6`) at the individual Session 05 agent scope.
- The approved APIM Content Safety backend points to
  `https://<resource>.cognitiveservices.azure.com`, uses managed-identity authorization, and the APIM
  identity has Cognitive Services User on that Content Safety resource.
- The Application Insights logger listed in the deployment inputs exists in APIM and uses the customer's approved
  managed-identity connection.
- The Microsoft Entra application registration, audience, client application, and required app role
  are approved.
- The product owner has issued one workload-specific APIM product subscription for the live check
  and stored its key in the approved secret store.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/gateway/main.bicep`](artifacts/gateway/main.bicep) | The Session 06 APIM deployment scripts |
| Deployment | [`artifacts/gateway/apis/policy-assistant-responses.openapi.json`](artifacts/gateway/apis/policy-assistant-responses.openapi.json) | The API Management API import |
| Deployment | [`artifacts/gateway/policies/policy.xml`](artifacts/gateway/policies/policy.xml) | The API Management gateway runtime |
| Deployment | [`artifacts/governance/gateway-control.json`](artifacts/governance/gateway-control.json) | The Session 06 preflight and APIM deployment scripts |
| Record | [`artifacts/governance/model-routing-decision.md`](artifacts/governance/model-routing-decision.md) | The API product, platform, safety, and operations owners |
| Deployment | [`artifacts/environments/sandbox.json`](artifacts/environments/sandbox.json) | The Session 06 preflight and deployment scripts |

### Official documentation

Check Microsoft’s [API Management AI gateway capabilities](https://learn.microsoft.com/en-us/azure/api-management/genai-gateway-capabilities)
before selecting a tier or relying on a token, safety, routing, or observability policy.

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value in the two implementation JSON deployment inputs before deployment.

### How clients authenticate to APIM

The product requires **two independent client credentials**: a workload-specific APIM subscription key and a
Microsoft Entra application token. The token policy pins the tenant, client application, audience,
and required `roles` claim. The subscription ID is also the token-limit counter key. Each APIM gateway maintains its own
counter; there is no tenant-wide counter shared across regions. For a multi-region deployment, the
API product owner divides the approved workload allowance into a stated budget for each region.
The platform owner configures those regional values in [Session 14](../../14-agent-fleet-multiregion-rehearsal/implementation/README.md).

The API product owner issues one subscription per consuming workload. Keep each key in the approved
secret store and rotate or revoke it through the customer's API credential process. Do not use
shared team keys, the all-access subscription, or long-lived keys in application settings.

Stop if the workload-specific subscription has not been issued, the client uses a user token where
an application identity is required, the app role is
shared with unrelated APIs, the audience is ambiguous, or the product owner cannot issue and revoke
one subscription per workload. Do not use the all-access APIM subscription for an application.

### How APIM authenticates to Foundry

The APIM system-assigned identity receives Foundry Agent Consumer at the individual agent scope.
The backend base URL must end at:

```text
https://<account>.services.ai.azure.com/api/projects/<project>/agents/<agent>/endpoint/protocols/openai
```

APIM appends `/responses` from the API operation. The full runtime URL stays outside source control.

Stop if the endpoint differs from the existing Foundry account, project, or agent; if the agent
endpoint is not pinned and Entra-authorized; or if the APIM identity's **Foundry Agent Consumer**
assignment applies to the Foundry project or resource instead of the individual Session 05 agent.

### Limits, retry, and routing

Review the approved defaults against model quota and workload demand:

| Control | Approved default |
|---|---:|
| Tokens per minute per APIM subscription | 20,000 |
| Daily token quota per APIM subscription | 500,000 |
| Request body limit | 65,536 bytes |
| Backend response-header timeout | 120 seconds |
| Retry count for 429/5xx | 1 |
| Circuit breaker | 5 errors in 1 minute, open for 1 minute |

The backend pool always contains the primary Session 05 agent. A secondary route is disabled by
default. Record the routing decision in
[`artifacts/governance/model-routing-decision.md`](artifacts/governance/model-routing-decision.md).
Enable a secondary route only when the service owner approves a distinct endpoint with the same
Responses-compatible operation shape, model behavior, agent version, data-residency boundary,
safety policy, logging dimensions, and restore path. The cost owner must approve the PTU
allocation or pay-as-you-go fallback before the route is enabled. Multi-region design remains
[Session 14](../../14-agent-fleet-multiregion-rehearsal/implementation/README.md) work.

Microsoft Foundry can also surface a Foundry-native AI Gateway setup path through the Foundry
portal, backed by Azure API Management. This session uses the Bicep files in this repository as the
stable deployment route. Treat the unified model API as preview awareness only unless a
separate architecture decision approves it for a nonproduction experiment.

Stop if retrying a request could repeat a consequential side effect. The Session 05 agent has only a
read tool, which makes one buffered retry acceptable here.

### Safety policy

The current API Management tier must be Developer, Basic, Basic v2, Standard, Standard v2,
Premium, or Premium v2.
The APIM policy calls the approved Azure AI Content Safety backend. Prompt Shields is enabled.
Requests and completions are checked against Hate, SelfHarm, Sexual, and Violence at threshold 4 on
the eight-level scale.

For a nonstreaming violation, APIM returns `403 Forbidden`. For a streaming completion, APIM checks
sliding windows and stops forwarding later events when it detects a violation. The client can
receive a truncated stream instead of a normal 403 response.

The safety owner approves the threshold and data handling. The network owner confirms that the APIM
gateway can reach the exact Content Safety endpoint. The identity owner confirms **Cognitive
Services User** (`a97b65f3-24c7-4388-baec-2e87135dc908`) for the APIM system-assigned identity on
that Content Safety resource. Stop if the backend uses a key, points to another resource, lacks that
assignment, or conflicts with the Session 05 RAI policy. APIM safety is another layer. It does not
replace the model-level policy.

### Telemetry and caching

Application Insights receives W3C correlation, APIM request telemetry, and token metrics with API,
product, and subscription dimensions. Diagnostic body logging is set to zero bytes and client IP
logging is disabled. Do not add `trace`, Event Hub body logging, prompt logging, or completion
logging during this session.

For streaming Responses calls, clients set `stream_options.include_usage` to `true`. The metric
policy uses reported usage when the response includes it, although an interrupted stream can leave
the captured count incomplete. The token-limit policy estimates prompt and completion tokens for
streaming calls. Treat both as operational signals for limits and monitoring. Use Azure Cost
Management data and the issued invoice as the billing records.

The metric policy stays before backend selection. Its API, product, and subscription dimensions do
not depend on the selected backend, and moving it would not identify the concrete member chosen
from the backend pool.

Semantic caching is deferred. The data owner decides which content may be cached. The API product
owner sets the maximum age and the event that invalidates an entry. The identity owner approves the
tenant and workload values used in the cache key. Operations owns cache access, retention, purge,
and incident handling. Keep caching disabled until all four owners approve those settings.

## Implement

### 1. Complete the required decisions

Edit `gateway-control.json` and `sandbox.json`. Keep **customer endpoints, credentials, and
telemetry outside the repository**, including subscription IDs, APIM subscription keys, bearer
tokens, prompts, and responses.
Do not import a broader hub-and-spoke topology or extra controls into this bounded route without a
separate architecture decision.

Set the runtime values in the shell:

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$primaryAgentBaseUrl = $env:SESSION06_PRIMARY_AGENT_BASE_URL
$secondaryAgentBaseUrl = $env:SESSION06_SECONDARY_AGENT_BASE_URL
```
```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:?Set AZURE_SUBSCRIPTION_ID.}"
primary_agent_base_url="${SESSION06_PRIMARY_AGENT_BASE_URL:?Set SESSION06_PRIMARY_AGENT_BASE_URL.}"
secondary_agent_base_url="${SESSION06_SECONDARY_AGENT_BASE_URL:-}"
```

Leave `$secondaryAgentBaseUrl` empty when `secondaryBackendEnabled` is `false`.

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

Preflight parses every implementation definition and checks the policy shape. It confirms the approved
subscription and resource group, APIM tier and identity, agent-scoped Foundry role, Content Safety
resource and role, APIM Content Safety backend, Application Insights logger, agent URL, and existing
API marker. It then runs an Azure Resource Manager `what-if` deployment.

Stop if `what-if` replaces or removes an unrelated APIM resource, changes the APIM service itself,
shows a different API or product ID, or introduces a live endpoint into source.

### 3. Deploy the gateway control

```powershell
.\scripts\deploy.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -PrimaryAgentBaseUrl $primaryAgentBaseUrl `
  -SecondaryAgentBaseUrl $secondaryAgentBaseUrl
```
```bash
./scripts/deploy.sh --approved-subscription-id "$approved_subscription_id" --primary-agent-base-url "$primary_agent_base_url" --secondary-agent-base-url "$secondary_agent_base_url"
```

The script reruns preflight, then deploys child resources into the existing APIM instance. The
result is one subscription-protected API and product, four non-secret APIM named values, a primary-first
backend pool, managed-identity backend authentication, safety and token policies, and body-free
Application Insights diagnostics.

The OpenAPI definition documents `stream_options.include_usage` for streaming clients. Keep it set to
`true` when `stream` is `true`.

Use the already issued test-workload subscription. Do not create or issue a subscription during
this session.

## Confirm the result

Use a **valid subscription key with an invalid bearer token**. The synthetic body must not
contain customer data.

```powershell
$gatewayUrl = "https://$((Get-Content .\artifacts\environments\sandbox.json -Raw |
  ConvertFrom-Json).apiManagementName).azure-api.net/ai/policy-assistant/responses"
$headers = @{
  Authorization = "Bearer invalid-session06-token"
  "Ocp-Apim-Subscription-Key" = $env:SESSION06_APIM_SUBSCRIPTION_KEY
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

export SESSION06_GATEWAY_URL="$gateway_url"
export SESSION06_APIM_SUBSCRIPTION_KEY="${SESSION06_APIM_SUBSCRIPTION_KEY:?Set SESSION06_APIM_SUBSCRIPTION_KEY.}"
export SESSION06_CORRELATION_ID="$(python3 -c 'import uuid; print(uuid.uuid4())')"
python3 - <<'PY'
import json
import os
import urllib.error
import urllib.request

body = json.dumps({"input": "Return the title of synthetic policy POL-001."}).encode()
request = urllib.request.Request(
    os.environ["SESSION06_GATEWAY_URL"],
    data=body,
    headers={
        "Authorization": "Bearer invalid-token",
        "Ocp-Apim-Subscription-Key": os.environ["SESSION06_APIM_SUBSCRIPTION_KEY"],
        "X-Correlation-ID": os.environ["SESSION06_CORRELATION_ID"],
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
unset SESSION06_GATEWAY_URL SESSION06_APIM_SUBSCRIPTION_KEY SESSION06_CORRELATION_ID
```

Expected result: APIM returns `401 Unauthorized`. This proves the invalid bearer identity is blocked
at ingress before Content Safety or the Foundry agent is called; it does not prove other identities
or policy branches.
Do not retain the response, subscription key, or request headers.

## After implementation

Keep the **APIM API and controlled product in operation**, with their APIM named values, backend pool,
circuit breakers, policy, diagnostics, deployment inputs, routing decision, and deployment scripts. The API product
owner owns client subscriptions and limits. Identity owns the Entra app role and APIM identity
assignments. Platform owns routing and APIM capacity. Safety owns the Content Safety settings.
Operations owns telemetry, alerts, retention, and cost.

Run this implementation only against the nonproduction APIM and backend resources listed in the
deployment inputs and routing decision. It does not approve a
production ingress, secondary region, semantic cache, API Center registration, MCP server, or
write-capable agent.

If the gateway API must be removed, the product and service owners first confirm that no approved
consumer depends on it. Use the approved APIM change path to check the live API marker and remove
only the Session 06 API, product, backends, and four non-secret APIM named values. Leave the APIM
instance, Application Insights logger, Content Safety backend and resource, Foundry agent, role
assignments, and repository definitions in place.
If the secondary route is enabled and must be backed out while the primary route remains live, set
`secondaryBackendEnabled` back to `false`, clear `SESSION06_SECONDARY_AGENT_BASE_URL`, rerun
preflight, and redeploy the gateway. The deployment removes the secondary backend from the pool
without changing the primary path.
If the gateway is permanently retired, the identity owner reviews the **Foundry Agent Consumer**
assignment on the Session 05 agent and the **Cognitive Services User** assignment on the Content
Safety resource. Remove an assignment only when no other approved APIM call depends on it.
