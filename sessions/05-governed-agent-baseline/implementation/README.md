# Governed Microsoft Foundry agent baseline

## Session scope

### What we will do

Create and pin **a versioned prompt agent** in the existing Microsoft Foundry project. Its unique
Entra Agent Identity identifies the agent and secures the endpoint. The Foundry project managed
identity authorizes the approved read-only OpenAPI operation. The deployment creates a stable
endpoint pinned to the implemented version. The agent has no write tool, uses the RAI policy in
`agent.json`, and sends server-side traces.

### Why it matters

A pinned version gives the release owner a known configuration to operate. Separate identities let
operators verify that the Entra Agent Identity protects the endpoint and that the project managed
identity calls the downstream API.

### Boundaries

This session changes a prompt agent in the approved nonproduction Foundry project. Foundry holds
the live agent and pinned endpoint state. Repository definitions state the configuration that
deployment applies. The direct OpenAPI path is application-only. The project managed identity calls
the downstream API. It does not forward a signed-in human token.

The absent write operation and downstream read authorization constrain the tool path. Instructions
tell the agent how to respond; they do not enforce the boundary. Session 06 owns Microsoft 365 and
Teams publishing, while the delegated-access module owns delegated user access.
[Session 07](../../07-apim-ai-gateway/implementation/README.md) configures the APIM route.
[Session 09](../../09-mcp-tool-security/implementation/README.md) replaces the direct tool with an
MCP path. [Session 11](../../11-foundry-evaluations-quality-gates/implementation/README.md) adds
repeatable evaluations.

This baseline attaches the OpenAPI definition directly to the agent. A future optional Toolbox
module can provide a curated reusable tool when several agents need it.
Use Session 09 when the tool must also pass through APIM and MCP controls.

## Architecture

### Architecture at a glance

The agent sits between a caller and the approved read-only API. A caller reaches the stable
Responses endpoint. Foundry routes the request to the pinned prompt-agent version. That version can
call the one GET operation in its OpenAPI tool. The model input and output pass through the
responsible AI (RAI) policy. Foundry sends server-side trace signals to the connected Application
Insights resource.

The endpoint and downstream tool call use different identities. The agent's unique Entra Agent
Identity identifies the agent and protects its endpoint. The Foundry project managed identity makes
the downstream OpenAPI call with the approved read assignment. The API sees the project identity,
not the user or individual agent.

![A fixed prompt-agent version sits between its repository definition and pinned endpoint; the endpoint uses the agent identity, while the project identity makes the approved OpenAPI GET call](../assets/diagrams/governed-agent-flow.svg)

Foundry shows the live agent version and identity, and where the endpoint routes traffic.
`agent.json`, `instructions.md`, and `tool-manifest.json` define the agent version. The deployment
scripts read those files, create an immutable prompt-agent version in the existing Foundry project,
and route all endpoint traffic to that version.

The boundary ends at the direct read API. The tool definition has no write operation, and
downstream authorization denies writes. Session 07 adds APIM ingress. Session 09 replaces the
direct tool path with MCP.

### Design choices and tradeoffs

| Decision | Chosen approach | Why this shape works | Tradeoff | Revisit when |
|---|---|---|---|---|
| Agent runtime | Use a persistent prompt agent with an immutable version and pinned stable endpoint | Operators can identify and recreate the released configuration | Each configuration change creates another version | The workload needs hosted code or an application-owned ephemeral definition |
| Identities at each boundary | Use Agent Identity at the endpoint and the project managed identity for the direct OpenAPI call | Operators can verify which identity protects the endpoint and which has the downstream API role | The downstream API sees the project identity, not the user or agent | The tool path supports agent identity or requires delegated user authority |
| Tool attachment | Attach the approved OpenAPI definition directly to this agent | The agent version includes the definition, and `tool-manifest.json` records the downstream role definition ID and assignment scope | A Toolbox module owns reuse, versioning, and centralized tool lifecycle | Several agents need the same curated tool, or Session 09 replaces the path with MCP |
| Tool authority | Expose the approved GET operation; omit writes and deny them through downstream authorization | The agent can call the approved GET operation | A read-only design limits what the agent can do | A separately approved workflow adds consequential actions and Session 09 controls |
| Release routing | Send 100% of traffic to the pinned version | Operators know which agent version handles a request | Promotion needs an explicit deployment step | A tested rollout design needs weighted traffic |

### Architecture guidance

- [Configure and share your Microsoft Foundry agent](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/configure-agent) covers fixed-version routing, endpoint authorization, and agent identity.
- [Connect OpenAPI tools to Microsoft Foundry agents](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/tools/openapi) defines the project-managed-identity tool path and OpenAPI contract.
- [What is Toolbox in Foundry?](https://learn.microsoft.com/en-us/azure/foundry/agents/concepts/toolbox-overview) explains the managed reuse option that this baseline deliberately leaves for a later module.

## Before you start

Confirm the implementation definitions:

- Sessions 01-03 are complete for the approved nonproduction environment.
- `agent.json`, `instructions.md`, and `tool-manifest.json` have no unresolved decisions.
- `tool-manifest.json` contains the `get_policy` GET operation and no write operation.
- The live Foundry agent, RAI policy, and Application Insights connection are ready to inspect.

Confirm the live Foundry resources:

- The existing Microsoft Foundry resource has the Azure resource property `kind` set to
  `AIServices`. This property identifies the current Foundry resource type.
- The existing Foundry project is reachable from the approved execution host over the private path
  implemented in Session 03.
- The [Session 04](../../04-model-governance-lifecycle/implementation/README.md) consolidated
  approval record links the selected deployment name to its exact model coordinates. The matching
  live ARM child deployment has provisioning state `Succeeded`. The AI product owner has checked
  the current Agent Service region-and-model support table for prompt agents and OpenAPI tools in
  the Foundry project region.
- An existing read-only HTTPS operation accepts a policy identifier and can authenticate with
  managed identity. Keep the endpoint out of this repository.
- The downstream API authorization owner has approved the exact read role for the Foundry project
  managed identity at the downstream API resource scope. For a custom role, its official
  authorization documentation must name the action required by `get_policy`.
  `tool-manifest.json` must record the custom role definition ID and exact assignment scope.
- The named RAI policy and existing Application Insights connection already exist. The operations
  group has Log Analytics Reader on that exact Application Insights resource. If its Log
  Analytics tables are protected, the group also has Privileged Monitoring Data Reader. The
  operations owner has approved the trace retention period and data-handling requirements.
- The agent deployment operator has the time-bound **Foundry User** role, role ID
  `53ca6127-db72-4b80-b1b0-d745d6d5456d`, on that exact Foundry project. This project-scoped role
  authorizes creating and managing agents. No substitute role is assumed.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/agents/policy-assistant/agent.json`](artifacts/agents/policy-assistant/agent.json) | The Session 05 agent deployment scripts |
| Deployment | [`artifacts/agents/policy-assistant/instructions.md`](artifacts/agents/policy-assistant/instructions.md) | The Microsoft Foundry prompt-agent version |
| Deployment | [`artifacts/agents/policy-assistant/tool-manifest.json`](artifacts/agents/policy-assistant/tool-manifest.json) | The Session 05 agent deployment scripts |

### Official documentation

Use Microsoft’s [Foundry agent configuration guide](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/configure-agent)
when checking endpoint behavior, fixed-version routing, Entra authorization, and agent identity.

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value in a working copy before deployment.

### Agent and release model

Use a persistent prompt agent. The agent name is immutable. Each saved configuration becomes an
immutable version. Pin the stable endpoint to the version created in this session. Do not use the
"always latest" selector for this baseline.

Stop if the selected model deployment differs from the [Session 04](../../04-model-governance-lifecycle/implementation/README.md)
consolidated approval record and live ARM child deployment. Also stop when the region/model does
not support the OpenAPI tool, the name collides with an unmarked agent, or an existing agent has no
unique `instance_identity`. Do not upgrade a legacy shared-identity agent in place. Choose a new
name and create a current-model agent.

The shared project identity for development agents and the distinct identity created at publication
belong to the older Agent Application model. Use the current agent object model here. The agent
receives its own `instance_identity` when it is created, and its stable endpoint is live without a
separate publish resource. The direct OpenAPI `managed_identity` option uses the Foundry project
managed identity for the downstream call.

The Foundry portal can show the endpoint and pin its active version. It cannot currently configure
protocols, authorization schemes, or the agent card. `agent.json` and the deployment scripts
define those settings. Inspect the Foundry REST API response for the live endpoint. Stop if it
differs from the defined settings.

### Which identity makes the OpenAPI call

The agent receives a unique Entra Agent Identity. In the current direct OpenAPI integration, the
`managed_identity` authentication option uses the Foundry project's managed identity for the
downstream call. This is an application-only boundary. The downstream API sees the project
identity. It does not see a signed-in human token or the endpoint identity. Before preflight, the
downstream API authorization owner assigns the approved read role to the project identity at the
downstream API resource scope. The role must include the exact action that the service's official
authorization documentation requires for `get_policy`. Keep the agent's unique identity so
operators can identify the agent, secure its endpoint, and use future tools that support
agent-identity authentication. Do not assume that it authenticates this direct OpenAPI call. If the
API must authorize each signed-in user, stop here and require a separately approved delegated-access
implementation.

The authoritative OpenAPI manifest contains one path and one `GET` operation. It does not register
`POST`, `PUT`, `PATCH`, or `DELETE`. The runtime API base URL is supplied in the shell and
substituted in memory. Keep it out of the repository.

Stop if `tool-manifest.json` lacks the exact role definition ID or downstream API assignment scope.
Stop if preflight cannot find exactly one matching assignment for the Foundry project managed
identity. Also stop when the owner is unnamed, the API specification contains a credential, the
Microsoft Entra audience is unresolved, the `get_policy` operation can change state despite using
GET, or the assigned role includes a write action. The system prompt is not the primary write
control. The absent write operation and downstream authorization enforce the boundary.

### Prohibited action

Name a realistic write action, its policy owner, and how a person requests and approves the
change. The agent instructions require refusal. The agent has no tool that can call the action.

Stop if the product owner asks to add a write tool during this session. Consequential write
authorization, approval tokens, and MCP controls belong in [Session 09](../../09-mcp-tool-security/implementation/README.md).

### Content controls and tracing

Apply the RAI policy in `rai_config.rai_policy_name`. The safety owner checks the live policy in
Foundry before deployment and updates it through the approved Azure change path. Stop if the policy
is missing or no longer meets the approved safety requirements. The agent instructions define
additional business behavior. They do not replace platform content controls.

Server-side tracing starts when the project connects to Application Insights. Traces can include
prompts, outputs, tool arguments, results, tokens, latency, and cost. Use the synthetic
prohibited-action prompt in this session. Stop if the trace-reader list is unapproved or if
retention ownership, regional handling, sampling, or sensitive-content restrictions are unresolved.

## Implement

### 1. Complete the implementation definitions

Populate `agent.json`, `instructions.md`, and the read path and audience in `tool-manifest.json`.
Keep `__RUNTIME_READ_API_BASE_URL__` unchanged. Deployment replaces it in memory. Use
Microsoft’s [OpenAPI tool guidance](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/tools/openapi)
to check the supported authentication and operation definition.

Set runtime-only scope values:

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$resourceGroup = "approved-session-06-resource-group"
$foundryAccount = "approved-existing-foundry-resource"
$projectName = "approved-existing-foundry-project"
$readApiBaseUrl = $env:SESSION05_READ_API_BASE_URL
$applicationInsightsResourceId = $env:SESSION05_APP_INSIGHTS_RESOURCE_ID
```
```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:?Set AZURE_SUBSCRIPTION_ID.}"
resource_group="approved-session-06-resource-group"
foundry_account="approved-existing-foundry-resource"
project_name="approved-existing-foundry-project"
read_api_base_url="${SESSION05_READ_API_BASE_URL:?Set SESSION05_READ_API_BASE_URL.}"
application_insights_resource_id="${SESSION05_APP_INSIGHTS_RESOURCE_ID:?Set SESSION05_APP_INSIGHTS_RESOURCE_ID.}"
```

Keep these values, access tokens, prompts, responses, and customer data out of the repository.

### 2. Run preflight and inspect the preview

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
./scripts/preflight.sh --approved-subscription-id "$approved_subscription_id" --resource-group-name "$resource_group" --foundry-account-name "$foundry_account" --project-name "$project_name" --read-api-base-url "$read_api_base_url" --application-insights-resource-id "$application_insights_resource_id"
```

Preflight rejects unresolved decisions. It checks the GET tool, refusal policy, approved
subscription, Foundry resource, model deployment, Application Insights target, project access,
identity used for the API call, agent-name collision, and stable-endpoint version. It then prints
the exact changes that deployment will make.

Foundry does not expose a data-plane `what-if` operation for agent version creation. Use a
read-only project and agent lookup plus the exact version, tool, protocol, authorization, and
routing summary. Stop on an unmarked name collision, write operation, live endpoint in source,
unexpected model, legacy shared identity, or resource outside the approved scope.

### 3. Create and pin the governed version

```powershell
.\scripts\deploy.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroup `
  -FoundryAccountName $foundryAccount `
  -ProjectName $projectName `
  -ReadApiBaseUrl $readApiBaseUrl
```
```bash
./scripts/deploy.sh --approved-subscription-id "$approved_subscription_id" --resource-group-name "$resource_group" --foundry-account-name "$foundry_account" --project-name "$project_name" --read-api-base-url "$read_api_base_url"
```

Deployment creates an immutable prompt-agent version. It applies the model, instructions, RAI
policy from `agent.json`, and OpenAPI tool. It then sets the stable endpoint for Responses
with Entra authorization and pins 100% of traffic to the returned version. It refuses to update an
existing agent unless its agent card carries `implementationSession=05-governed-agent-baseline`.

The script confirms that Foundry returned a unique `instance_identity`. Foundry holds the active
version and endpoint selector. The script keeps the endpoint, principal ID, subscription ID,
prompt, response, and trace data out of the repository.

## Confirm the result

Send **a synthetic request through the stable endpoint** for policy `POL-001`. The unique
Entra Agent Identity identifies the agent and secures its endpoint. The Foundry project managed
identity authenticates the direct OpenAPI read.

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

export SESSION05_URI="$uri"
export SESSION05_TOKEN="$token"
python3 - <<'PY'
import json
import os
import urllib.request

body = json.dumps({
    "input": "Use get_policy to read synthetic policy POL-001. Return only its approved fields."
}).encode()
request = urllib.request.Request(
    os.environ["SESSION05_URI"],
    data=body,
    headers={
        "Authorization": f"Bearer {os.environ['SESSION05_TOKEN']}",
        "Content-Type": "application/json",
    },
    method="POST",
)
with urllib.request.urlopen(request) as response:
    payload = json.load(response)
print(payload.get("output"))
PY
unset SESSION05_URI SESSION05_TOKEN
```

Confirm that the expected record is returned and `get_policy` is the only tool call. Confirm that
the downstream API authorized the Foundry project managed identity without a signed-in human token.
Stop if the read fails, returns another field, or invokes another tool. Do not retain the response
or export the trace.

## After implementation

Retain `agent.json`, `instructions.md`, `tool-manifest.json`, and the deployment scripts. Keep the
live pinned agent, stable endpoint, unique identity, and Application Insights connection in place.
The AI product owner owns agent behavior and release selection. The platform and identity owner
manages endpoint access and downstream authorization. The safety owner manages the RAI policy. The
operations owner manages trace access, retention, and cost.

Run this implementation against the nonproduction project, model, API, and identity settings in
`agent.json` and `tool-manifest.json`. The release owner approves production release and
write-capable tools through their change process. Sessions 06, 07, 09, and 11 own Microsoft 365 or
Teams distribution, APIM ingress, MCP, and evaluation quality.

Keep the agent in operation by default. If removal is required, the product, platform, identity,
and operations owners first confirm that no approved consumer uses the endpoint. Use the approved
Foundry change path to remove the agent whose name matches `agent.json` and whose live agent card
contains the Session 05 marker. That removal includes the agent's versions, identity, and stable
endpoint. It leaves the Foundry project, model, read API, RAI policy, Application Insights
resource, and repository definitions in place.
