# Governed Microsoft Foundry agent baseline

## Session scope

### What we will do

Create and pin **a versioned prompt agent** in the existing Microsoft Foundry project. Its unique
Entra Agent Identity identifies the agent and secures the endpoint. The Foundry project managed
identity authorizes the approved read-only OpenAPI operation. This session produces a stable endpoint
pinned to the implemented version, with no write tool, the RAI policy listed in `agent.json`, and
server-side tracing.

### Why it matters

A pinned version gives the release owner a known agent configuration to operate. Keeping the
agent identity separate from the project identity also makes the endpoint boundary and downstream
API authority inspectable without pretending that one identity performs both jobs.

### Boundaries

This session changes a prompt agent in the approved nonproduction Foundry project. The live
Foundry agent and pinned endpoint are authoritative for runtime state; the repository definitions
own the intended configuration. The direct OpenAPI path is application-only: the project managed
identity calls the downstream API, and no signed-in human token is propagated.

The absent write operation and downstream read authorization constrain the tool path. Instructions
do not enforce that boundary on their own. Publishing to Microsoft 365 or Teams and delegated
user access are excluded. [Session 06](../../06-apim-ai-gateway/implementation/README.md) configures
the APIM route, [Session 08](../../08-mcp-tool-security/implementation/README.md) replaces the direct
tool with an MCP path, and
[Session 10](../../10-foundry-evaluations-quality-gates/implementation/README.md) adds repeatable
evaluations.

This baseline attaches the OpenAPI contract directly to the agent. It does not use Foundry Toolbox.
If several agents need the same governed tool, move that reuse decision into a future optional
Toolbox module. Use Session 08 when the path also needs APIM and MCP controls.

## Architecture

### Architecture at a glance

The agent sits between a caller and the approved read-only API. A caller reaches the stable Responses
endpoint, Foundry routes the request to the pinned prompt-agent version, and that version may call
the single GET operation in its OpenAPI tool. The model input and output pass through the
responsible AI (RAI) policy. Foundry also sends server-side trace signals to the connected
Application Insights resource.

Identity changes at the tool boundary. The agent's unique Entra Agent Identity identifies the
agent and protects its endpoint. The Foundry project managed identity makes the downstream OpenAPI
call, with the approved read assignment on that API. The API therefore sees the project identity rather
than the user or the individual agent.

![A fixed prompt-agent version sits between its repository definition and pinned endpoint; the endpoint uses the agent identity, while the project identity makes the approved OpenAPI GET call](../assets/diagrams/governed-agent-flow.svg)

Foundry shows which agent version and identity are live, and where the endpoint sends traffic. The
repository defines the configuration operators intend to release. Deployment scripts combine that
definition with the instructions and tool manifest. They
create an immutable prompt-agent version in the existing Foundry project and send all endpoint
traffic to it.

The boundary ends at the direct read API. No write operation appears in the tool definition, and
downstream authorization denies writes. Session 06 adds APIM ingress. Session 08 later replaces the
direct tool path with MCP.

### Design choices and tradeoffs

| Decision | Chosen approach | Why this shape works | Tradeoff | Revisit when |
|---|---|---|---|---|
| Agent runtime | Use a persistent prompt agent with an immutable version and pinned stable endpoint | Operators can identify and recreate the released configuration | Each configuration change creates another version | The workload needs hosted code or an application-owned ephemeral definition |
| Identities at each boundary | Use Agent Identity at the endpoint and the project managed identity for the direct OpenAPI call | Each identity follows the current Foundry boundary and its scope remains visible | The downstream API sees the project identity, not the user or agent | The tool path supports agent identity or requires delegated user authority |
| Tool attachment | Attach the approved OpenAPI contract directly to this agent | The baseline keeps the tool definition and downstream authorization path visible | Reuse, toolbox versioning, and centralized tool lifecycle are outside this agent | Several agents need the same curated tool, or Session 08 replaces the path with MCP |
| Tool authority | Expose the approved GET operation; omit writes and deny them through downstream authorization | The enforceable surface stays small | A read-only design limits what the agent can do | A separately approved workflow adds consequential actions and Session 08 controls |
| Release routing | Send 100% of traffic to the pinned version | Operators always know which configuration handles a request | Promotion requires an explicit deployment step | A tested rollout design needs weighted traffic |

### Architecture guidance

- [Configure and share your Microsoft Foundry agent](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/configure-agent) covers fixed-version routing, endpoint authorization, and agent identity.
- [Connect OpenAPI tools to Microsoft Foundry agents](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/tools/openapi) defines the project-managed-identity tool path and OpenAPI contract.
- [What is Toolbox in Foundry?](https://learn.microsoft.com/en-us/azure/foundry/agents/concepts/toolbox-overview) explains the managed reuse option that this baseline deliberately leaves for a later module.

## Before you start

Confirm the implementation definitions:

- Sessions 01-03 are complete for the approved nonproduction environment.
- `agent.json`, `instructions.md`, and `tool-manifest.json` have no unresolved decisions.
- `tool-manifest.json` contains the `get_policy` GET operation and no write operation.
- The live Foundry agent, RAI policy, and Application Insights connection are ready for inspection.

Confirm the live Foundry resources:

- Azure CLI is installed, signed in to the approved subscription, and can acquire a token for
  `https://ai.azure.com/.default`.
- The existing Microsoft Foundry resource has the Azure resource property `kind` set to
  `AIServices`. This property identifies the current Foundry resource type.
- The existing Foundry project is reachable from the approved execution host over the private path
  implemented in Session 03.
- The [Session 04](../../04-model-governance-lifecycle/implementation/README.md) consolidated
  approval record links the selected deployment name to its exact model coordinates. The matching
  live ARM child deployment has provisioning state `Succeeded`. The AI product owner has checked the current Agent Service
  region-and-model support table for prompt agents and OpenAPI tools in the Foundry project region.
- An existing read-only HTTPS operation accepts a policy identifier and can authenticate with
  managed identity. No customer endpoint is committed to this repository.
- The downstream API authorization owner has approved the exact read role for the Foundry project
  managed identity at the downstream API resource scope. If that service uses a custom role, its
  official authorization documentation must name the action required by `get_policy`, and
  `tool-manifest.json` must record the custom role definition ID and exact assignment scope.
- The named RAI policy and existing Application Insights connection already exist. The operations group has
  **Log Analytics Reader** on that exact Application Insights resource. If its Log Analytics tables
  are protected, the group also has **Privileged Monitoring Data Reader**. The operations owner has
  approved the retention boundary.
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

Resolve every `__REQUIRED_*__` value in a customer working copy before deployment.

### Agent and release model

Use a **persistent prompt agent**. The agent name is immutable, each saved configuration becomes
an immutable version, and the stable endpoint must be pinned to the version created in this session.
Do not use the "always latest" selector for this baseline.

Stop if the selected model deployment does not match the [Session 04](../../04-model-governance-lifecycle/implementation/README.md) consolidated approval record and live ARM child deployment, the region/model does
not support the OpenAPI tool, the proposed name collides with an unmarked agent, or an existing
agent has no unique `instance_identity`. A legacy shared-identity agent is not upgraded in place;
choose a new name and create a current-model agent.

The shared project identity for development agents and the distinct identity created at publication
describe the older Agent Application publishing model. This session uses the current agent object
model: the agent receives its own `instance_identity` when it is created, and its stable endpoint is
live without a separate publish resource. The direct OpenAPI `managed_identity` option still uses
the Foundry project managed identity for the downstream call.

The Foundry portal can show the endpoint and pin its active version. It cannot currently configure
protocols, authorization schemes, or the agent card. `agent.json` and the deployment scripts remain
the intended configuration, and the Foundry REST API is authoritative for the live endpoint state.
Stop and correct the mismatch if the API response differs from those settings.

### Which identity makes the OpenAPI call

The agent itself receives a unique Entra Agent Identity. In the current direct OpenAPI integration,
the `managed_identity` authentication option uses the Foundry project's managed identity for the
downstream call. This is an application-only boundary. The downstream API sees the project identity,
not a signed-in human token and not the endpoint identity. Before preflight, the downstream API authorization owner assigns the project identity the approved read role
at the downstream API resource scope. The role must include the exact action that the service's
official authorization documentation requires for `get_policy`. Keep
the agent's unique identity for independent inventory, endpoint governance, and later tool
patterns that support agent-identity authentication; do not assume that it authenticates this
direct OpenAPI call. If the API must authorize each signed-in user, stop here and require a
separately approved delegated-access implementation.

The authoritative OpenAPI manifest contains exactly one path and one `GET` operation. No `POST`, `PUT`,
`PATCH`, or `DELETE` operation is registered. The runtime API base URL is supplied in the shell and
substituted in memory; never write it into the repository.

Stop if the exact role definition ID or downstream API assignment scope is missing from
`tool-manifest.json`. Stop if preflight cannot find exactly one matching assignment for the Foundry
project managed identity. Also stop when its owner is unnamed, the API specification contains a
credential, the Microsoft Entra audience is unresolved, the `get_policy` operation can change
state despite using GET, or the assigned role includes a write action. Do not treat the system
prompt as the primary write control: absence of a write operation and downstream authorization are
the enforceable boundaries.

### Prohibited action

Name a realistic write action, its policy owner, and the human-owned change route. The agent
instructions require refusal, and the agent has no tool that can call the action.

Stop if the product owner asks to add a write tool during this session. Consequential write
authorization, approval tokens, and MCP controls belong in [Session 08](../../08-mcp-tool-security/implementation/README.md).

### Content controls and tracing

Apply the RAI policy listed in `rai_config.rai_policy_name`. The safety owner checks the live
policy in Foundry before deployment and updates it through the approved Azure change path. Stop if
the policy is missing or no longer meets the approved safety boundary. The agent instructions add
a business-behavior boundary; they do not replace platform content controls.

Server-side tracing starts automatically when the project is connected to Application Insights.
Traces can include prompts, outputs, tool arguments, results, tokens, latency, and cost. Use only the
synthetic prohibited-action prompt in this session. Stop if trace readers, retention ownership,
regional handling, sampling, or sensitive-content restrictions are unresolved.

## Implement

### 1. Complete the implementation definitions

Populate `agent.json`, `instructions.md`, and the read path and audience in `tool-manifest.json`.
Keep **`__RUNTIME_READ_API_BASE_URL__` unchanged**; deployment replaces it in memory. Use Microsoft’s [OpenAPI tool
guidance](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/tools/openapi) to check the
supported authentication and operation contract.

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

Do not place these values, access tokens, prompts, responses, or customer data in the repository.

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

Preflight rejects unresolved decisions, checks that the definition exposes the GET tool and the
refusal policy,
checks the approved subscription, Foundry resource, model deployment, Application Insights target,
project access, identity path, name collision, and the live stable endpoint selector before printing
the planned mutation.

Foundry does not expose a data-plane `what-if` operation for agent version creation. The supported
preview is therefore a read-only project/agent lookup plus the exact version, tool, protocol,
authorization, and routing summary. Stop on any unmarked name collision, write operation, live
endpoint in source, unexpected model, legacy shared identity, or resource outside the approved
scope.

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

Deployment creates a new immutable prompt-agent version, applies the model, instructions, RAI policy
from `agent.json`, and the OpenAPI tool, then configures the stable endpoint for Responses with Entra
authorization and pins 100% of traffic to the returned version. It refuses to update an existing
agent unless its agent card carries `implementationSession=05-governed-agent-baseline`.

The script confirms that Foundry returned a unique `instance_identity`. Foundry retains the active
version and endpoint selector. The script does not store the endpoint, principal ID, subscription
ID, prompt, response, or trace data.

## Confirm the result

Send **a synthetic request through the stable endpoint** for policy `POL-001`. The agent's unique
**Entra Agent Identity** identifies the agent and secures its endpoint. The Foundry **project
managed identity** authenticates the direct OpenAPI read.

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

Confirm that the expected record is returned, `get_policy` is the only tool call, and the downstream
API authorized the Foundry project managed identity without a signed-in human token. Stop if the
read fails, returns another field, or invokes another tool. Do not retain the response or export the
trace.

## After implementation

Keep the **pinned agent and stable endpoint configuration**, together with its unique identity,
instructions, GET-only tool manifest, deployment scripts, and Application Insights connection. The AI product owner owns behavior and
release selection. The platform/identity owner owns endpoint access and downstream authorization.
The safety owner owns the RAI policy. The operations owner owns trace access, retention, and cost.

Run this implementation only against the nonproduction project, model, API, and identity settings
listed in `agent.json` and `tool-manifest.json`. It does not approve
production release, write-capable tools, Microsoft 365/Teams distribution, APIM ingress, MCP, or
evaluation quality.

Keep the agent in operation by default. If removal is required, the product, platform, identity, and
operations owners first confirm that no approved consumer depends on the endpoint. Use the approved
Foundry change path to remove only the agent whose name matches `agent.json` and whose live agent
card contains the Session 05 marker. That removal includes the agent's versions, identity, and
stable endpoint. It does not remove the Foundry project, model, read API, RAI policy, Application
Insights resource, or repository definitions.
