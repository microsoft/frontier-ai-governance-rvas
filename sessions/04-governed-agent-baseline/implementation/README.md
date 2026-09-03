# Governed Microsoft Foundry agent baseline

## Session scope

### What we will do

**Objective.** Create and pin **a versioned prompt agent** in the existing Microsoft Foundry project. Its unique
Entra Agent Identity identifies the agent and secures the endpoint. The Foundry project managed
identity authorizes one approved read-only OpenAPI operation.

The deployed version uses the RAI policy in `agent.json`, sends server-side traces, and exposes no
write tool. We will call `get_policy` once with synthetic data and confirm that no other tool runs.

### Why it matters

**Problem.** An agent that drifts after release, or shares its identity with other agents, leaves the release
owner unable to say what configuration is live or which identity called a given API.

**Solution.** Pinning one version gives the release owner a known configuration to operate. Separate identities
show which identity protects the endpoint and which one calls the downstream API.

### Boundaries

This session changes one prompt agent in the approved nonproduction Foundry project. Foundry holds
the live identity, versions, endpoint routing, and RAI policy. The repository holds the deployment
definition.

The direct OpenAPI path is application-only. The downstream API sees the Foundry project managed
identity, not a signed-in user or the agent identity. The missing write operation and downstream
read authorization constrain the tool path. Instructions add refusal behavior but do not enforce
that boundary.

The Microsoft 365 and Teams distribution owner manages this boundary.
[APIM AI gateway guide](../../06-apim-ai-gateway/implementation/README.md) adds APIM ingress.
[MCP tool security guide](../../08-mcp-tool-security/implementation/README.md) replaces the direct tool path
with MCP controls. [Foundry evaluation gate guide](../../09-foundry-evaluations-quality-gates/implementation/README.md)
adds repeatable evaluations. Use a separately approved delegated-access implementation when the
API must authorize the signed-in user.

## Architecture

### Architecture at a glance

A caller reaches the Entra-authorized stable Responses endpoint. Foundry routes the request to the
pinned prompt-agent version. That version can call the single GET operation in its OpenAPI tool.
The RAI policy handles model input and output, while Foundry sends server-side traces to the
connected Application Insights resource.

![A versioned agent definition becomes an immutable endpoint whose project identity calls one read-only API.](../assets/diagrams/governed-agent-flow.svg)

The deployment scripts read `agent.json`, `instructions.md`, and `tool-manifest.json`, create an
immutable version, and route all endpoint traffic to it. The control boundary ends at the direct
read API.

### Design choices and tradeoffs

| Decision | Chosen approach | Tradeoff |
|---|---|---|
| Runtime and release | Persistent prompt agent with an immutable version and pinned endpoint | Every configuration change creates a version |
| Identities | Agent identity at the endpoint; project managed identity for the OpenAPI call | The API sees the project identity, not the user or agent |
| Tool | Attach one GET-only OpenAPI definition directly | Reuse and centralized tool lifecycle stay outside this baseline |
| Routing | Send 100% of traffic to the new version | Promotion is an explicit deployment step |

### Architecture guidance

- [Configure and share your Microsoft Foundry agent](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/configure-agent)
- [Connect OpenAPI tools to Microsoft Foundry agents](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/tools/openapi)
- [What is Toolbox in Foundry?](https://learn.microsoft.com/en-us/azure/foundry/agents/concepts/toolbox-overview)

## Before you start

Confirm:

- The approved nonproduction `AIServices` Foundry resource and project are reachable from the
  approved execution host. The platform owner confirms the recorded subscription, resource group, resource,
  project, and private path. (The platform baseline, private-networking, and model-governance controls establish these prerequisites.)
- The recorded model approval matches a live ARM child model deployment in `Succeeded` state. The
  selected region and model
  support prompt agents and OpenAPI tools. ([Model governance and lifecycle guide](../../03-model-governance-lifecycle/implementation/README.md).)
- The operator has time-bound **Foundry User**, role ID
  `53ca6127-db72-4b80-b1b0-d745d6d5456d`, on the exact Foundry project.
- The downstream API accepts a policy ID over HTTPS and supports managed identity. Its authorization
  owner has assigned the exact read role to the Foundry project managed identity at the downstream
  API resource scope. A custom role must name the action required by `get_policy`.
- The named RAI policy exists. Application Insights is connected to the project. The approved
  operations group has Log Analytics Reader on that Application Insights resource and, for
  protected tables, Privileged Monitoring Data Reader. The operations owner has approved trace
  access, retention, regional handling, sampling, cost, and sensitive-content rules.

Keep endpoints, credentials, access tokens, prompts, responses, trace exports, and customer data
out of the repository.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/agents/policy-assistant/agent.json`](artifacts/agents/policy-assistant/agent.json) | The Session 04 agent deployment scripts |
| Deployment | [`artifacts/agents/policy-assistant/instructions.md`](artifacts/agents/policy-assistant/instructions.md) | The Microsoft Foundry prompt-agent version |
| Deployment | [`artifacts/agents/policy-assistant/tool-manifest.json`](artifacts/agents/policy-assistant/tool-manifest.json) | The Session 04 agent deployment scripts |

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value in a working copy before deployment. Keep
`__RUNTIME_READ_API_BASE_URL__`; deployment replaces it in memory.

| Gate | Continue when | Stop when |
|---|---|---|
| Agent and model | The immutable agent name, accountable owner, approved model deployment, named RAI policy, Responses protocol, Entra authorization, and fixed-version routing are set | The selected model differs from the approved deployment profile, the region or model does not support the tool, the name collides with an unmarked agent, or an existing agent has no unique `instance_identity` |
| Tool authority | `tool-manifest.json` contains one genuine read-only GET operation, the exact Entra audience, role definition ID, assignment scope, authorization owner, and human change route | The API specification contains a credential; `get_policy` can change state; the role can write; the owner, audience, role, or scope is unresolved; or preflight does not find exactly one matching project-identity assignment |
| Prohibited action | `instructions.md` names the blocked write action and the human approval route | The product owner asks to add a write tool in this session |
| Safety and tracing | The live RAI policy meets the approved filters and trace ownership is settled | The policy is missing or trace readers, retention, regional handling, sampling, cost, or sensitive-content restrictions are unresolved |

Use the current agent object model. The agent receives its own `instance_identity` and stable
endpoint when created. Do not upgrade a legacy shared-identity agent in place; choose a new name.
The direct OpenAPI `managed_identity` option still uses the Foundry project managed identity.

The portal can show the endpoint and pin a version. The scripts set protocol, authorization, and
agent-card properties through the REST API. Stop if the live response differs from the definition.

## Implement

### 1. Complete the definitions and runtime scope

Populate the three implementation files. The OpenAPI manifest must contain `get_policy` and no
`POST`, `PUT`, `PATCH`, or `DELETE` operation.

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$resourceGroup = "approved-session-04-resource-group"
$foundryAccount = "approved-existing-foundry-resource"
$projectName = "approved-existing-foundry-project"
$readApiBaseUrl = $env:session04_READ_API_BASE_URL
$applicationInsightsResourceId = $env:session04_APP_INSIGHTS_RESOURCE_ID
```
```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:?Set AZURE_SUBSCRIPTION_ID.}"
resource_group="approved-session-04-resource-group"
foundry_account="approved-existing-foundry-resource"
project_name="approved-existing-foundry-project"
read_api_base_url="${session04_READ_API_BASE_URL:?Set session04_READ_API_BASE_URL.}"
application_insights_resource_id="${session04_APP_INSIGHTS_RESOURCE_ID:?Set session04_APP_INSIGHTS_RESOURCE_ID.}"
```

### 2. Run preflight

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroup `
  -FoundryAccountName $foundryAccount `
  -ProjectName $projectName `
  -ReadApiBaseUrl $readApiBaseUrl `
  -ApplicationInsightsResourceId $applicationInsightsResourceId
```
```bash
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --resource-group-name "$resource_group" \
  --foundry-account-name "$foundry_account" \
  --project-name "$project_name" \
  --read-api-base-url "$read_api_base_url" \
  --application-insights-resource-id "$application_insights_resource_id"
```

Foundry has no data-plane `what-if` for agent creation. Preflight uses read-only resource and agent
lookups, then prints the exact version, tool, protocol, authorization, and routing changes. Stop on
any failed gate or unexpected scope.

### 3. Create and pin the version

```powershell
.\scripts\deploy.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroup `
  -FoundryAccountName $foundryAccount `
  -ProjectName $projectName `
  -ReadApiBaseUrl $readApiBaseUrl
```
```bash
./scripts/deploy.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --resource-group-name "$resource_group" \
  --foundry-account-name "$foundry_account" \
  --project-name "$project_name" \
  --read-api-base-url "$read_api_base_url"
```

Deployment applies the model, instructions, RAI policy, and OpenAPI tool. It creates a unique
`instance_identity`, configures the stable Responses endpoint with Entra authorization, and pins
100% of traffic to the returned version. It will not update an existing agent unless the agent card
contains `implementationSession=04-governed-agent-baseline`.

## Confirm the result

Send one synthetic request for policy `POL-001` through the stable endpoint:

```powershell
$config = Get-Content .\artifacts\agents\policy-assistant\agent.json -Raw |
  ConvertFrom-Json
$token = az account get-access-token `
  --scope https://ai.azure.com/.default `
  --query accessToken `
  --output tsv `
  --only-show-errors
$uri = "https://$foundryAccount.services.ai.azure.com/api/projects/$projectName/agents/$($config.agentName)/endpoint/protocols/openai/responses"
$body = @{
  input = "Use get_policy to read synthetic policy POL-001. Return only its approved fields."
} | ConvertTo-Json

$result = Invoke-RestMethod `
  -Method POST `
  -Uri $uri `
  -Headers @{ Authorization = "Bearer $token" } `
  -ContentType "application/json" `
  -Body $body

$result.output
```
```bash
agent_name=$(python3 -c 'import json, pathlib; print(json.loads(pathlib.Path("artifacts/agents/policy-assistant/agent.json").read_text())["agentName"])')
token=$(az account get-access-token --scope https://ai.azure.com/.default --query accessToken --output tsv --only-show-errors)
uri="https://${foundry_account}.services.ai.azure.com/api/projects/${project_name}/agents/${agent_name}/endpoint/protocols/openai/responses"

export session04_URI="$uri"
export session04_TOKEN="$token"
python3 - <<'PY'
import json
import os
import urllib.request

body = json.dumps({
    "input": "Use get_policy to read synthetic policy POL-001. Return only its approved fields."
}).encode()
request = urllib.request.Request(
    os.environ["session04_URI"],
    data=body,
    headers={
        "Authorization": f"Bearer {os.environ['session04_TOKEN']}",
        "Content-Type": "application/json",
    },
    method="POST",
)
with urllib.request.urlopen(request) as response:
    payload = json.load(response)
print(payload.get("output"))
PY
unset session04_URI session04_TOKEN
```

The expected record must contain only approved fields, and `get_policy` must be the only tool call.
Confirm that the downstream API authorized the Foundry project managed identity without a signed-in
human token. Stop on any other result. Do not retain the response or export the trace.

## After implementation

| What remains | Owner |
|---|---|
| Agent behavior and pinned release | AI product owner |
| Endpoint access, Entra Agent Identity, and downstream authorization | Platform and identity owner |
| RAI policy | Safety owner |
| OpenAPI definition and human-approved write route | API and policy owner |
| Trace access, retention, and cost | Operations owner |
| Implementation files and deployment scripts | AI engineering |

Keep the marked agent, its pinned endpoint, unique identity, and Application Insights connection in
operation. Production release and write-capable tools require the approved change process.

To remove this baseline, the product, platform, identity, and operations owners first confirm that
no approved consumer uses the endpoint. Through the approved Foundry change path, remove only the
agent whose name matches `agent.json` and whose live agent card contains
`implementationSession=04-governed-agent-baseline`. This removes its versions, identity, and stable
endpoint. It leaves the Foundry project, model deployment, read API, RAI policy, Application
Insights resource, and repository definitions in place.
