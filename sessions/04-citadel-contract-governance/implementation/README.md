# Govern Citadel backends, access, tools, and agents

## Session scope

### What we will do

**Onboard one workload through Citadel contracts.** We will deploy one approved model backend, create one workload-specific access contract, and optionally publish one read-only MCP tool through the hub. The workload owner will observe the intended path and a prohibited action that remains unavailable.

### Why it matters

A shared gateway becomes another manual bottleneck if model, tool, and access changes live only in APIM portal configuration. Citadel contracts split platform supply, asset publishing, and workload access into reviewable customer overlays.

### Boundaries

This session changes the Citadel hub and the workload's access material. Citadel's upstream Bicep modules own the resource implementation. The three parameter files are the customer-owned desired state. The publish contract is preview; backend and access contracts remain useful without it.

## Architecture

### Architecture at a glance

The backend contract defines what the gateway can route to. The publish contract defines which MCP tools or agents the gateway exposes. The access contract grants a workload a bounded product and supplies its approved endpoints and access material.

```text
Backend contract ----\
                      -> Citadel APIM -> Access contract -> workload
Publish contract ----/         |
                         API Center inventory
```

Deploy in that order. Publishing an asset does not grant a workload access to it.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| Contract unit | One access contract per use case and environment | Clear quota, policy, ownership, and telemetry boundary | More contract files to operate |
| Backend auth | Managed identity | Avoids backend keys in workload configuration | Requires exact role assignments |
| Access material | Store in workload Key Vault | Keeps generated keys outside source control | Needs Key Vault access and rotation ownership |
| Tool publishing | Optional preview contract | Gives one governed MCP and API Center path | Contract surface may change before general availability |

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
