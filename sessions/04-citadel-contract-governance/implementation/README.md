# Govern Citadel backends, access, tools, and agents

## Session scope

### What we will do

**Onboard one workload through Citadel contracts.** We will deploy one approved model backend, create one workload-specific access contract, and optionally publish one read-only MCP tool through the hub. The workload owner will observe the intended path and a prohibited action that remains unavailable.

### Why it matters

A shared gateway becomes another manual bottleneck if model, tool, and access changes live only in APIM portal configuration. Citadel contracts split platform supply, asset publishing, and workload access into reviewable customer overlays.

### Boundaries

This session changes the Citadel hub and the workload's access material. Citadel's upstream Bicep modules own the resource implementation. The three parameter files hold the customer-owned contract configuration. The publish contract is preview; backend and access contracts remain useful without it.

## Architecture

### Architecture at a glance

Citadel separates supply, publication, and consumption so one owner does not need to edit every
APIM object manually. The contracts are deployment modules that create or reconcile live APIM and
API Center state. They are not documentation records.

```text
1. Backend contract
   model endpoints + identity + routing
          |
          v
   APIM backends, pools, aliases, routing fragments

2. Publish contract
   existing MCP server or A2A agent
          |
          v
   APIM API + baseline policy + optional API Center record

3. Access contract
   use case + environment + approved assets + limits
          |
          v
   APIM product + API attachments + policy + subscription
          |
          +-> optional key and asset endpoints in workload Key Vault
```

The Backend Contract defines model supply. It creates APIM backends and pools, routing fragments,
model metadata, aliases, and the live backend-contract fragment. Priority, weight, circuit-breaker,
and session-affinity settings belong here.

The Publish Contract exposes an existing MCP server or A2A agent. It creates the APIM API, remote
backend where the asset type needs one, baseline policy, usage metrics, and optional API Center
registration. It does not create the backing tool or agent, and it does not create a product or
consumer subscription.

The Access Contract creates the consumer boundary. It creates an APIM product, attaches approved
LLM, MCP, or A2A APIs, applies product policy, and creates a subscription. It can place the
subscription key and per-asset endpoints in the workload Key Vault or create supported Foundry
connections.

Deploy backend, then publish, then access. Access resolves the published API paths, so rerun it after
a published path changes. Publishing makes an asset available to the gateway; only the Access
Contract grants a workload permission to consume it.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| Contract ownership | Platform owns backend, asset owner owns publish, workload owns access | Separates supply from consumption | Changes sometimes need coordinated releases |
| Access unit | One product per use case and environment | Gives quota, policy, ownership, and telemetry a clear boundary | More products and subscriptions to operate |
| Backend auth | Managed identity for Azure backends | Avoids backend keys in workload configuration | Requires exact role assignments |
| Access material | Access Contract writes to workload Key Vault when supported | Keeps generated keys outside source control and logs | Needs Key Vault access and rotation ownership |
| Tool publishing | Optional preview contract | Gives one governed MCP or A2A exposure path | Preview behavior and clients need nonproduction testing |
| API-to-MCP sources | Test subscription-key handling end to end | Detects a common invocation failure before release | Initialization can succeed while calls still return `401` |

### Architecture guidance

- [MCP server support in API Management](https://learn.microsoft.com/azure/api-management/mcp-server-overview)
- [Azure API Center](https://learn.microsoft.com/azure/api-center/overview)

## Before you start

The hub must be running. Name the APIM service, APIM managed identity, Foundry backend, model deployment, workload Key Vault, business unit, tool owner, API Center service, MCP endpoint, and MCP audience. Confirm the APIM identity has the exact backend role and the tool supports managed-identity authentication.

This repository does not deploy the backing API or MCP server. The included `get_policy` binding is
a concrete example. Replace it with the approved operation exposed by the customer's existing MCP
server, or remove the optional publish path.

### Implementation files

| Type | File | Consumer |
| --- | --- | --- |
| Record | `artifacts/citadel-release.json` | Citadel contract deployment pipeline |
| Deployment | `artifacts/contracts/backend/main.bicepparam` | Citadel backend-contract deployment |
| Deployment | `artifacts/contracts/access/main.bicepparam` | Citadel access-contract deployment |
| Deployment | `artifacts/contracts/publish/main.bicepparam` | optional Citadel publish-contract deployment |
| Runtime | `artifacts/governance/agent-mcp-binding.json` | agent deployment and release process |
| Record | `artifacts/governance/security-evaluation.md` | security and tool owners |
| Record | `artifacts/governance/threat-model.md` | workload security owner |
| Runtime | `artifacts/operations/mcp-traffic.kql` | operations and security teams |

Install Git, Azure CLI, Bicep, and `jq`. Check out the Citadel commit in `citadel-release.json`.

## Decisions and stop conditions

Stop when an overlay still contains a placeholder, the upstream checkout is not pinned, the model version or capacity is unapproved, the APIM identity cannot authenticate to the backend, generated access material would be printed into logs, the tool contains an unreviewed write action, or the publish-contract preview has no accepting owner.

The prohibited write must be absent from the published operations and denied by the backend authorization boundary. A prompt instruction alone is not a control.

## Implement

### 1. Complete the overlays

Resolve every `__REQUIRED_*__` value. Keep one model and one customer-supplied tool for the first vertical slice. Replace the sample `get_policy` identifiers, review the threat model, and update `agent-mcp-binding.json` to the fixed agent version.

### 2. Run preflight

```powershell
.\scripts\preflight.ps1 `
  -CitadelPath $citadelPath `
  -ResourceGroup $hubResourceGroup
```

```bash
./scripts/preflight.sh \
  --citadel-path "$citadel_path" \
  --resource-group "$hub_resource_group"
```

### 3. Preview and deploy the contracts

Omit `-IncludePublish` or `--include-publish` when the customer does not accept the preview feature.

```powershell
.\scripts\deploy.ps1 `
  -CitadelPath $citadelPath `
  -ResourceGroup $hubResourceGroup `
  -IncludePublish `
  -Confirm
```

```bash
./scripts/deploy.sh \
  --citadel-path "$citadel_path" \
  --resource-group "$hub_resource_group" \
  --include-publish
```

The script previews and deploys backend, optional publish, and access contracts in dependency order.

Each deployment runs `az deployment group what-if` before `az deployment group create`. Stop when the preview reaches an unlisted APIM API, product, backend, Key Vault, or API Center record.

## Confirm the result

### Intended path

Call the stable gateway model alias and the read-only MCP operation with the workload's Citadel access material. Both calls succeed, use the expected APIM product, and emit the approved correlation and ownership dimensions.

### Blocked or failure path

Attempt the named prohibited write through the same workload identity. The operation is absent or the backend returns the approved authorization failure. No state changes.

### Delivery-owner checkpoint

The workload owner confirms the intended path. The tool and security owners confirm the blocked path and accept the publish-contract preview boundary when enabled.

## After implementation

Platform teams own backend contracts. Workload teams own access contracts. Tool owners own publish contracts and API Center metadata. Rotate access material through the Citadel contract process. Restore by redeploying the previous approved overlay commit; remove a workload by removing its access contract before removing published assets or backends.
