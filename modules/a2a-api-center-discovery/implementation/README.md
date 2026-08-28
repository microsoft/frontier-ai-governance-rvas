# Implementation - A2A agent discovery in Azure API Center

## Module scope

### What we will do

Add or refresh an already-governed A2A agent in Azure API Center when developers need its
technical interface. The API Center asset comes from a runtime-owned Git or API Management source
integration. The delivery team then reviews the live catalog asset.

Azure API Center holds the live discovery entry. This module does not create a manual agent
registration, copy the A2A definition, or keep a second inventory record in this repository.

### Why it matters

Agent 365 records which agents exist for the enterprise. API Center gives developers a current A2A
interface and definition. Source integrations keep those records aligned without asking people to
update the same facts twice.

### Boundaries

This optional 60-minute add-on follows the [A2A agent inventory in Microsoft Agent 365](../../a2a-agent-inventory/implementation/README.md)
module and [Session 07](../../../sessions/07-api-center-ai-mcp-inventory/implementation/README.md).

Microsoft Agent 365 remains authoritative for enterprise inventory and lifecycle. Azure API Center
is authoritative for its live discovery asset. The runtime-owned source system remains
authoritative for the A2A definition, agent card, and endpoint. This module changes no runtime
authentication, authorization, or traffic policy.

## Architecture

### Architecture at a glance

The runtime owner publishes the technical asset through an approved source integration. API Center
then makes the A2A asset available for developers.

```text
Microsoft Agent 365
enterprise inventory
        |
        | cross-reference
        v
Runtime-owned Git or API Management source
        |
        v
Azure API Center A2A discovery asset
```

The runtime owner updates the Git or API Management source, and synchronization updates API Center.
A portal registration beside that integration creates a competing record.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefit | Limit | Revisit when |
|---|---|---|---|---|
| Need for API Center | Add it only for developer discovery | Teams without that need avoid a second catalog entry | Developers need another way to find the interface | Discovery becomes a platform requirement |
| Source | Runtime-owned Git or API Management integration | The A2A definition has one technical source | Source integration has setup and synchronization behavior | A supported direct runtime integration replaces it |
| Registration | Source synchronization | Updates flow from the technical owner | Portal fields can be source-owned | The source cannot represent the required A2A metadata |
| Completion | Live asset review | No repository copy can drift | The API Center owner needs access | A supported stable inspection API covers the needed fields |

### Architecture guidance

Use [Register and manage agents in Azure API Center](https://learn.microsoft.com/en-us/azure/api-center/register-manage-agents)
for the current A2A agent and synchronization behavior.

Use [Synchronize API assets from a Git repo to Azure API Center](https://learn.microsoft.com/en-us/azure/api-center/synchronize-assets-git)
when the runtime product repository is the source.

Use [Synchronize APIs from an API Management instance](https://learn.microsoft.com/en-us/azure/api-center/synchronize-api-management-apis)
when API Management is the approved technical source.

## Before you start

Confirm these prerequisites:

- The Agent 365 core module has produced a live enterprise inventory record for the agent.
- Developers need API Center discovery for this A2A interface.
- The runtime owner has selected Git or API Management as the technical source.
- The selected source has the current agent definition and card without credentials embedded in
  source-controlled discovery content.
- The API Center owner can review the source integration and resulting live asset.

Run preflight with the selected source reference in **Implement › 1. Run preflight**. It checks the
module boundary before a portal-led integration change without creating an API Center asset or
retaining supplied values.
A read-only deployment preview is unsupported because the change is made through the selected
source integration.

## Decisions and stop conditions

### Confirm the discovery need

Use this add-on when developers need the A2A interface in API Center. Do not add the asset merely
because an Agent 365 enterprise record exists.

Stop if the developer use case is unclear or the existing Agent 365 record is missing.

### Select the source integration

Choose **git** when the runtime product repository is the approved source. Choose **api-management**
when API Management publishes the technical A2A asset and the documented synchronization path
supports it.

Stop if the plan relies on a manual Agent registration beside an existing source integration, an
unsupported source, a local agent-card upload, or copied metadata in this repository.

### Review source ownership

The runtime owner maintains the source. The API Center owner maintains the integration and
discovery configuration. Changes to source-owned fields follow the runtime release path.

Stop if the source owner, API Center owner, or Agent 365 owner cannot identify their live record
and update path.

## Implement

### 1. Run preflight

Run preflight with the chosen source integration and source reference.

```powershell
.\scripts\preflight.ps1 `
  -TargetScope "one-approved-a2a-discovery-asset" `
  -SourceIntegration "api-management" `
  -RuntimeSourceReference "https://example.invalid/agent-source"
```

```bash
./scripts/preflight.sh \
  --target-scope "one-approved-a2a-discovery-asset" \
  --source-integration "api-management" \
  --runtime-source-reference "https://example.invalid/agent-source"
```

### 2. Configure or refresh the source integration

The API Center owner follows the current Microsoft-supported Git or API Management integration
path. The runtime owner confirms that the source has the current A2A definition and card before
synchronization.

### 3. Observe the catalog asset

Open the Agent asset in API Center. Confirm that it uses the selected source, represents the
approved A2A interface, and links to the live Agent 365 record.
Do not export the record or save a local comparison file.

## Confirm the result

The module is complete when the Agent 365 record exists, the API Center asset comes from the
selected source integration, and the API Center owner can show the current A2A interface in the
live catalog.

Stop the session if the source is stale, the asset is manually maintained beside an integration, or
the Agent 365 and API Center owners cannot resolve a mismatch.

## After implementation

The runtime owner maintains the A2A source. The API Center owner maintains the discovery
integration. Agent 365 remains the live record for enterprise inventory and lifecycle.

Restore through the selected integration's approved portal or source-management path. Remove the
API Center discovery asset only after confirming that developers no longer need it. That removal
does not retire the Agent 365 record or change the A2A runtime.
