# MCP and tool security

## Session scope

### What we will do

Configure **one MCP read path for `get_policy`**. APIM validates the candidate Foundry agent, checks
the input, and calls the backend with its own read-only managed identity. Application Insights keeps
tool and correlation metadata without payloads.

The stable endpoint stays on the prior Session 05 version until the release owner observes an
approved read and a blocked prohibited write.

### Why it matters

The tool list, inbound authorization, and backend role answer different questions: what the agent
can request, which agent may call APIM, and what APIM may do at the backend. A model refusal helps,
but the missing write tool and read-only backend role enforce the boundary.

### Boundaries

This session adds `policy-catalog-mcp` to the existing
[Session 07](../../07-apim-ai-gateway/implementation/README.md) APIM service and creates an unpinned
candidate in the existing [Session 05](../../05-governed-agent-baseline/implementation/README.md)
Foundry project. APIM owns the live MCP policy and outbound identity. Foundry owns the candidate
binding and stable version selector. Application Insights holds payload-free telemetry. API Center
holds the separate design-time inventory entry maintained through
[Session 08](../../08-api-center-ai-mcp-inventory/implementation/README.md).

The backend call is application-only, not OBO. APIM never forwards the inbound MCP token. Delegated
user access, write tools, backing-API changes, production release, MCP resources or prompts, APIM
workspaces, and payload logging need separate approval.

## Architecture

### Architecture at a glance

![A Foundry agent and API Management use separate identities to reach a read-only backend.](../assets/diagrams/mcp-tool-security-flow.svg)

The candidate agent gets a token for the MCP audience. APIM validates its tenant, client
application, audience, and app role, then exposes only `get_policy`. APIM gets a second token for
its system-assigned identity. The backend accepts that identity at the exact approved read scope.

The backend validates `policyId`. APIM records the tool, status, latency, W3C `operation_Id`, and
client `X-Correlation-ID`. It records no arguments, results, prompts, responses, tokens, or bodies.

### Design choices and tradeoffs

| Decision | Chosen approach | Cost or limit | Revisit when |
|---|---|---|---|
| Tool surface | One `get_policy` tool | Another action needs review and deployment | A new business action is approved |
| Backend access | APIM managed identity with the exact read role and scope | Two audiences and role assignments need ownership | The backend must authorize individual users |
| Release | Test an unpinned candidate | Enablement waits for both checks | Session 14 protects this checkpoint |
| Telemetry | Correlation and tool metadata; zero body bytes | Content investigations stay in governed source systems | The security owner approves another design |

### Architecture guidance

- [APIM MCP overview](https://learn.microsoft.com/en-us/azure/api-management/mcp-server-overview)
- [Secure MCP servers in APIM](https://learn.microsoft.com/en-us/azure/api-management/secure-mcp-servers)
- [Connect Foundry agents to MCP servers](https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/tools/model-context-protocol)

## Before you start

Confirm:

- Sessions 02, 05, 07, and 08 are complete in the approved nonproduction scope.
- The Session 05 policy assistant is pinned to a known version.
- The Session 07 APIM service has a system-assigned identity, an Application Insights logger, a
  supported tier, and no workspace.
- The deployment operator has time-bound **Contributor** on the exact APIM resource group.
- The agent operator has **Foundry User** on the exact Session 05 Foundry project.
- The existing APIM operation uses `GET`, validates `policyId`, returns approved fields, and does
  not change state.
- Approved-read and adversarial records exist in the synthetic data set.
- The Foundry agent identity has the approved MCP app role.
- The APIM identity has the approved backend role definition at the exact backend scope. That role
  contains only the Actions or DataActions needed by `get_policy`.
- Global and MCP diagnostics set request and response body logging to zero bytes.
- Release, data, security, tool, identity, APIM, and API program owners are named.
- The customer permits `2025-09-01-preview` for this nonproduction APIM deployment.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/apim/main.bicep`](artifacts/apim/main.bicep) | The Session 09 APIM deployment scripts |
| Deployment | [`artifacts/apim/policies/mcp-policy.xml`](artifacts/apim/policies/mcp-policy.xml) | The API Management MCP runtime |
| Deployment | [`artifacts/environments/sandbox.json`](artifacts/environments/sandbox.json) | The Session 09 preflight and deployment scripts |
| Deployment | [`artifacts/governance/agent-mcp-binding.json`](artifacts/governance/agent-mcp-binding.json) | The Foundry agent release owner |
| Record | [`artifacts/governance/security-evaluation.md`](artifacts/governance/security-evaluation.md) | The security owner running the Foundry candidate-version checks |
| Record | [`artifacts/governance/threat-model.md`](artifacts/governance/threat-model.md) | The security and identity owners |
| Runtime | [`artifacts/operations/mcp-traffic.kql`](artifacts/operations/mcp-traffic.kql) | The APIM operations owner |

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value. Keep IDs, endpoints, tokens, prompts, responses, tool content,
telemetry, and customer data out of source control.

The tool must use `GET`, require `policyId`, and accept at most 128 characters matching
`^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$`. The backend validates the same rule and returns only fields
approved by the data owner. No create, update, approve, publish, or delete operation may exist in
the tool, Foundry allowlist, or backend role.

Stop before deployment when:

- APIM is a workspace, uses an unsupported tier, or preview automation is prohibited;
- the operation has side effects or the backend role contains wildcard, write, delete, or action
  authority;
- the inbound token reaches the backend, the two audiences are not distinct, or a shared secret is
  required;
- any diagnostic captures payload bytes;
- another tool appears or approval is not `always`;
- preflight finds the wrong subscription, scope, role assignment, resource marker, or an unrelated
  `what-if` change.

If preview automation is prohibited but the APIM tier supports MCP, the APIM owner may use the
documented portal path. Create exactly one `policy-catalog-mcp` server with one `get_policy` tool,
apply the same policy, and confirm the live APIM state. Otherwise stop.

Keep Streamable HTTP at `/mcp`. Do not create a new HTTP+SSE path. The MCP policy must not read
`context.Response.Body`, because buffering can break streaming. Keep
`fail-on-error-status-code="false"` so backend 4xx and 5xx responses retain normal status,
correlation, and MCP telemetry.

The release owner must see the candidate version ID and confirm that the stable endpoint still
selects the prior version before both checks. Stop if the read is wrong or uncorrelated, tool output
changes instructions, a write or unknown tool is attempted, or API Center lacks the required owner
metadata.

## Implement

### 1. Load the approved definitions

Complete `sandbox.json`, `agent-mcp-binding.json`, the security evaluation, and the threat model.
The approved backend role assignment must already be active.

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$artifactRoot = (Resolve-Path .\artifacts).Path
$environment = Get-Content (Join-Path $artifactRoot "environments\sandbox.json") -Raw | ConvertFrom-Json
$binding = Get-Content (Join-Path $artifactRoot "governance\agent-mcp-binding.json") -Raw | ConvertFrom-Json
```
```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:?Set AZURE_SUBSCRIPTION_ID.}"
artifact_root="$(cd ./artifacts && pwd)"
environment_path="$artifact_root/environments/sandbox.json"
binding_path="$artifact_root/governance/agent-mcp-binding.json"
```

### 2. Run preflight and inspect the preview

```powershell
.\scripts\preflight.ps1 -ApprovedSubscriptionId $approvedSubscriptionId
```
```bash
./scripts/preflight.sh --approved-subscription-id "$approved_subscription_id"
```

Preflight checks the implementation files and sentinels, the approved subscription and APIM scope,
the supported tier, identities, exact backend read assignment, payload-free diagnostics, Foundry
project, name collision, Bicep build, and ARM `what-if`.

Continue only when the preview is limited to the five Session 09 named values, MCP API, its one
tool, policy, and diagnostic.

### 3. Deploy the APIM control

```powershell
.\scripts\deploy.ps1 -ApprovedSubscriptionId $approvedSubscriptionId
```
```bash
./scripts/deploy.sh --approved-subscription-id "$approved_subscription_id"
```

The deployment creates the marked `policy-catalog-mcp` API, `get_policy`, five nonsecret named
values, the inbound and managed-identity policy, and the payload-free diagnostic. Troubleshoot with
status, error type, correlation, approved APIM tracing, and governed backend diagnostics. Do not
turn on payload logging.

### 4. Update API Center

After APIM synchronization creates one `policy-catalog-mcp` entry, the API program owner applies the
Session 08 process and records owner, classification, consumer, residency, risk, evaluation, review,
and expiry metadata.

Stop on a duplicate, missing runtime owner, or metadata broader than the threat model. The candidate
cannot be enabled until this entry is complete.

### 5. Create the Foundry connection

```powershell
$env:SESSION08_MCP_SERVER_URL = "https://$($environment.apiManagementName).azure-api.net/$($environment.mcpServerPath)/mcp"
$projectUrl = "https://$($environment.foundryAccountName).services.ai.azure.com/api/projects/$($environment.foundryProjectName)"
azd ai project set $projectUrl
azd ai connection create $binding.projectConnectionName `
  --kind remote-tool `
  --target $env:SESSION08_MCP_SERVER_URL `
  --auth-type agentic-identity `
  --audience $environment.mcpAudience
```
```bash
readarray -t foundry_values < <(ENVIRONMENT_PATH="$environment_path" BINDING_PATH="$binding_path" python3 - <<'PY'
import json, os, pathlib
e = json.loads(pathlib.Path(os.environ["ENVIRONMENT_PATH"]).read_text())
b = json.loads(pathlib.Path(os.environ["BINDING_PATH"]).read_text())
print(f"https://{e['apiManagementName']}.azure-api.net/{e['mcpServerPath']}/mcp")
print(f"https://{e['foundryAccountName']}.services.ai.azure.com/api/projects/{e['foundryProjectName']}")
print(b["projectConnectionName"])
print(e["mcpAudience"])
PY
)
export SESSION08_MCP_SERVER_URL="${foundry_values[0]}"
azd ai project set "${foundry_values[1]}"
azd ai connection create "${foundry_values[2]}" \
  --kind remote-tool \
  --target "$SESSION08_MCP_SERVER_URL" \
  --auth-type agentic-identity \
  --audience "${foundry_values[3]}"
```

If the installed `azd ai` surface differs, use the current Foundry portal flow with the same name,
target, agentic identity, and audience. Do not use a key or pasted bearer token.

### 6. Create an unpinned candidate

Copy the pinned Session 05 definition. Keep its model, RAI policy, instructions, temperature,
endpoint authorization, and identity behavior. Remove the direct OpenAPI tool, add the MCP
connection, set `allowed_tools` to `get_policy`, and set `require_approval` to `always`.

Save without changing the stable selector. Show the candidate version ID and the prior stable
selector to the release owner.

## Confirm the result

Use the Foundry candidate-version test surface or an approved client that targets the visible
candidate ID. Keep the stable endpoint on the prior Session 05 version.

### Intended path: approved read

Request `expectedReadRecordId`. Approve only
`policy-catalog / get_policy` with the expected `policyId`. The candidate must return the synthetic
record. APIM must use its managed identity, and `mcp-traffic.kql` must show one correlated event
without payloads.

### Blocked path: indirect prompt injection

Request `adversarialRecordId` and approve only its `get_policy` read. The
candidate must treat the embedded instruction as data, refuse the prohibited write, name the human
change route, and request no other tool.

At the delivery-owner checkpoint, the release owner:

- pins the stable endpoint 100% to the candidate only when both checks pass and API Center metadata
  is complete; or
- leaves or restores the prior version at 100%, keeps the candidate unpinned, and routes the failure
  to the security and tool owners.

## After implementation

| What remains | Owner |
|---|---|
| MCP server, `get_policy`, policy, named values, and diagnostic | APIM and tool owners |
| Inbound audience, app role, backend audience, and read assignment | Identity owner |
| Approved fields and record access | Data owner |
| Candidate binding, stable selector, and release decision | Foundry and release owners |
| Security evaluation and 90-day threat-model review | Security owner |
| API Center metadata | API program owner |
| KQL query and payload-free operations | APIM operations owner |

Rerun both synthetic checks after a change to the tool description, schema, returned fields,
backing operation, identity, instructions, model, or approval policy.

**Restore before removal.** Pin the previous Session 05 version at 100%, then confirm that no active
agent uses the MCP endpoint. Remove the Foundry connection only when no other governed tool uses it.
Through the approved APIM change path, verify the Session 09 marker and remove only the MCP API and
five Session 09 named values. Revoke the backend role only when the identity owner confirms that
Session 09 introduced it and no other operational path uses it.

Do not delete the backing API, APIM service, Foundry agent, API Center, Application Insights,
source data, or retained implementation files.
