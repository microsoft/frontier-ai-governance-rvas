# Implementation - A2A agent inventory in Microsoft Agent 365

## Module scope

### What we will do

Connect an approved A2A agent to Microsoft Agent 365 through the supported route for its runtime:
built-in integration, Registry sync, or a runtime-owned Agent 365 SDK integration. The delivery
team then reviews the live Agent Registry entry with the agent owner.

Microsoft Agent 365 holds the live inventory record. This module does not create an agent card,
technical definition, or copied inventory record in this repository.

### Why it matters

Agent 365 records the agent, its lifecycle, and its owners. The runtime continues to own the A2A
protocol, endpoint, and agent card. This split avoids a repository copy that goes stale when the
runtime changes.

### Boundaries

This optional module sits outside the 14-session sequence. It follows the agent baseline in
[Session 05](../../../sessions/05-governed-agent-baseline/implementation/README.md) and hands
data controls to [Session 09](../../../sessions/09-purview-data-governance/implementation/README.md).
Use the separate A2A API Center discovery module when developers need a catalog entry for the
agent's technical interface.

Microsoft Agent 365 is authoritative for the enterprise inventory. The runtime uses the A2A
definition, agent card, endpoint, and behavior stored in its product repository. This repository
retains neither customer-specific records nor completion evidence.

## Architecture

### Architecture at a glance

The agent already exists when this module begins. The team selects the Agent 365 integration that
fits its runtime, then reviews the live record in the Agent Registry.

```text
Runtime-owned A2A agent and definition
                |
     supported Agent 365 integration
                |
                v
      Microsoft Agent 365 Agent Registry
                |
       live owner and lifecycle review
```

Built-in integrations and Registry sync bring the existing agent into Agent 365. When an agent
needs code-level Agent 365 features, the runtime team implements the SDK path in its product
repository. This module does not add runtime code.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefit | Limit | Revisit when |
|---|---|---|---|---|
| Enterprise inventory | Agent 365 Agent Registry | One live record for inventory and lifecycle | The record has to arrive through a supported integration | The platform adds an approved A2A-specific onboarding route |
| Custom runtime integration | Built-in integration, Registry sync, or runtime-owned SDK | Uses the path Microsoft supports for the actual runtime | The workshop does not author SDK changes | The runtime changes platform or integration model |
| A2A technical discovery | Separate API Center add-on when needed | Keeps developer discovery separate from enterprise inventory | It adds a second live platform record | Developers no longer need catalog discovery |
| Repository record | None; the module is live-only | Avoids a stale repository copy | The facilitator must review the live service | A platform-supported export becomes an approved operational need |

### Architecture guidance

Use [Connect existing agents to Microsoft Agent 365](https://learn.microsoft.com/microsoft-agent-365/connect-existing-agents)
to select the built-in, Registry sync, or SDK path.

Use [Choose an Agent 365 integration option](https://learn.microsoft.com/microsoft-agent-365/developer/choose-integration-option)
to confirm whether the runtime already has a built-in path, can use Registry sync, or needs the
SDK.

Use [Connected platforms in the Microsoft 365 agent registry](https://learn.microsoft.com/microsoft-agent-365/admin/connected-platforms)
when Registry sync is the selected route.

## Before you start

Confirm these prerequisites:

- An A2A agent already runs in the approved nonproduction scope.
- The Agent 365 administrator has confirmed licensing and can open the Agent Registry.
- The runtime owner has identified the product repository or supported source integration where
  the agent definition and card are maintained.
- The agent owner and retirement owner can review the live record and its removal path.
- The delivery team has selected a supported integration route before changing any state.

Run the readiness check in **Implement › 1. Run preflight** before the platform change. It checks
the selected route and runtime-owned source reference without creating an Agent 365 record or
storing supplied values.
A read-only deployment preview is unsupported because Agent 365 onboarding follows the selected
platform or runtime-owned change path.

## Decisions and stop conditions

### Select the integration route

Choose **built-in** when the current agent platform has a documented Agent 365 integration.
Choose **registry-sync** only when the runtime is one of the platforms currently supported by
Registry sync. Choose **sdk** when the runtime owner must integrate the Agent 365 SDK in the
runtime-owned product repository.

Stop if the team proposes a manual inventory entry, an unsupported sync provider, or an SDK change
in this governance repository. Do not treat API Center registration as Agent 365 onboarding.

### Keep the source boundary

The runtime owner keeps the A2A definition and agent card in the runtime product repository or the
approved source system. Supply its source reference to preflight at run time.

Stop if the source contains embedded credentials, if no owner can maintain it, or if the team plans
to copy the agent card, endpoint, or catalog metadata into this module.

### Confirm the live record

The Agent 365 administrator opens the Agent Registry and confirms that the expected agent is
present through the selected integration. The agent owner confirms the displayed owner and
lifecycle state. The runtime owner confirms the integration can be updated and retired through its
approved path.

Stop the module if the record is absent, its ownership is unresolved, the selected integration is
not current, or the retirement path is unclear.

## Implement

### 1. Run preflight

Run the paired preflight command with the selected path and the runtime-owned source reference.
For Registry sync, also supply the supported provider name.

```powershell
.\scripts\preflight.ps1 `
  -TargetScope "one-approved-a2a-agent" `
  -IntegrationPath "registry-sync" `
  -RegistrySyncPlatform "Amazon Bedrock" `
  -RuntimeSourceReference "https://example.invalid/agent-source"
```

```bash
./scripts/preflight.sh \
  --target-scope "one-approved-a2a-agent" \
  --integration-path "registry-sync" \
  --registry-sync-platform "Amazon Bedrock" \
  --runtime-source-reference "https://example.invalid/agent-source"
```

### 2. Complete the selected platform path

For **built-in**, use the current platform guidance to enable or publish the existing agent.

For **Registry sync**, the Agent 365 administrator creates or reviews the supported connected
platform, validates its credentials in the Microsoft 365 admin center, and runs the sync.

For **SDK**, the runtime owner makes the approved change in the runtime product repository and
deploys it through that product's release path.

### 3. Observe the result

With the Agent 365 administrator, open the Agent Registry and review the new or updated record.
Confirm the integration route, owner, and lifecycle state in the live service.
No screenshot, export, or local record is created.

## Confirm the result

The module is complete when the Agent 365 administrator and agent owner review the live record,
the runtime owner can identify its supported update path, and the selected integration remains
supported for the runtime.

The facilitator stops rather than marks the module complete if the record is missing, a provider
is unsupported, or any owner cannot explain the retirement path.

## After implementation

Agent 365 remains the enterprise inventory. The runtime owner maintains the A2A definition, card,
and integration source. The Agent 365 administrator maintains inventory visibility. The agent
owner makes lifecycle decisions.

Restore or retire the agent through the selected platform path. Remove a connected-platform
configuration only through the Microsoft 365 admin center after the agent owner confirms that
removal will not affect another in-scope agent. Do not remove runtime code or the runtime service
from this module.
