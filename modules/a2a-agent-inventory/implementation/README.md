# Implementation - A2A agent inventory in Microsoft Agent 365

## Module scope

### What we will do

Connect an approved A2A agent to Microsoft Agent 365 through the supported route for its runtime:
built-in integration, Registry sync, or a runtime-owned Agent 365 SDK integration. The delivery
team then reviews the live Agent Registry entry with the agent owner.

Microsoft Agent 365 owns the enterprise inventory record. The runtime owner owns the A2A
definition, agent card, endpoint, and integration source.

### Why it matters

Agent 365 gives the organization a live view of the agent, its lifecycle, and its owners. Runtime
changes flow through the owner's source and supported integration.

### Boundaries

Use the agent baseline in
[Session 05](../../../sessions/05-governed-agent-baseline/implementation/README.md) and apply data
controls from [Session 10](../../../sessions/10-purview-data-governance/implementation/README.md).
Use the separate A2A API Center discovery module when developers need a catalog entry for the
agent's technical interface.

Use the selected integration to keep the Agent 365 record current. The runtime owner continues to
govern the A2A runtime, developer discovery, and data controls.

## Architecture

### Architecture at a glance

The agent already exists when this module begins. The team chooses the Agent 365 integration that
fits the runtime, then reviews the resulting live record in the Agent Registry.

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

Built-in integration and Registry sync bring an existing agent into Agent 365. The runtime team
uses the SDK path in its product repository when the agent needs code-level Agent 365 capabilities.

The selected integration carries the A2A agent from its runtime source to Agent Registry.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefit | Limit | Revisit when |
|---|---|---|---|---|
| Enterprise inventory | Agent 365 Agent Registry | One live record for inventory and lifecycle | The record has to arrive through a supported integration | The platform adds an approved A2A-specific onboarding route |
| Runtime onboarding | Use built-in integration or Registry sync before a runtime-owned SDK integration | Avoids custom code when the platform path already covers the need | A route must match the runtime and required Agent 365 capabilities | The runtime changes platform or integration model |
| A2A technical discovery | Separate API Center add-on when needed | Keeps developer discovery separate from enterprise inventory | It adds a second live platform record | Developers no longer need catalog discovery |
| Operational record | Agent Registry | The inventory stays with the service that operates it | The facilitator reviews the live service | A platform-supported export becomes an approved operational need |

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
- The Agent 365 administrator has confirmed licensing, can use the selected route, and can open
  the Agent Registry.
- The runtime owner has identified the product repository or supported source integration that
  maintains the agent definition and card.
- The agent owner, runtime owner, and retirement owner can review the live record and explain the
  approved update and removal path.
- The delivery team has selected the route before changing any state.

Run the readiness check in **Implement › 1. Run preflight** before the platform change. It checks
the selected route and runtime-owned source reference.
A read-only deployment preview is unsupported because Agent 365 onboarding follows the selected
platform or runtime-owned change path.

## Decisions and stop conditions

### Select the integration route

Use this table before choosing a preflight value or starting a platform change:

| Runtime fact | Select this route | Operator action | Expected live state | Stop or choose another route when |
|---|---|---|---|---|
| The current agent platform has a documented Agent 365 integration that covers the scenario | built-in | The platform operator enables or publishes the existing agent through that platform's current supported path | The in-scope agent is visible in Agent Registry through the platform integration | The platform does not document the integration for this agent or the scenario needs code-level capabilities the platform path does not supply |
| The runtime is one of the supported connected platforms | registry-sync | The Agent 365 administrator configures or reviews the connected platform, validates its credentials in the Microsoft 365 admin center, and runs the sync | The connection shows the selected provider and a current sync result; the in-scope agent is visible in Agent Registry | The provider is unsupported, the administrator cannot validate the connection, or the required agent is not available from that provider |
| The runtime owner builds and deploys the agent and needs Agent 365 capabilities in code | sdk | The runtime owner adds or updates the Agent 365 SDK integration in the runtime product repository, then releases through that product's approved path | The released runtime integration produces a live Agent Registry record for the in-scope agent | A built-in or Registry sync route already meets the need, the runtime owner cannot release the change, or the required code-level capability is unclear |

For Registry sync, preflight accepts these provider names: `Amazon Bedrock`, `Anthropic Claude
Managed Agents`, `Databricks Genie`, `Google Vertex AI`, `Oracle Generative AI Agents`, and
`Salesforce Agentforce`. Recheck the current connected-platform guidance before starting because
that preview surface can change.

Stop if the team proposes a manual inventory entry, an unsupported sync provider, or an SDK change
without an approved runtime-product delivery path. Agent 365 onboarding uses the selected
integration.

### Interpret the preflight inputs

| Input | What to enter | Route rule | Preflight stops when |
|---|---|---|---|
| `TargetScope` / `--target-scope` | `one-approved-a2a-agent` | Required for every route; it limits this module to one approved agent | The value differs from the approved literal |
| `IntegrationPath` / `--integration-path` | `built-in`, `registry-sync`, or `sdk` | Match the route-selection table above | The value is missing or does not name one of those routes |
| `RuntimeSourceReference` / `--runtime-source-reference` | An absolute HTTP or HTTPS URL for the runtime-owned product repository or supported source integration | Required for every route; it identifies the maintainer's source without copying it here | The value is absent, unresolved, not an absolute URL, or embeds credentials |
| `RegistrySyncPlatform` / `--registry-sync-platform` | One supported provider name from the preceding list | Required for `registry-sync`; omit it for `built-in` and `sdk` | It is missing for Registry sync, supplied for another route, or not supported |

The source reference identifies the live maintenance location. Use an absolute URL without
credentials.

### Keep the source safe

Supply the runtime-owned source reference to preflight at run time. Stop if it contains embedded
credentials or no owner can maintain it.

### Check the owners before the change

The Agent 365 administrator confirms that they can operate the selected route and inspect Agent
Registry. The runtime owner confirms that the referenced source is theirs to update and that the
approved release path can change or remove the integration. The agent owner confirms accountability
for the agent's lifecycle. The retirement owner confirms who approves the change that removes the
agent from use.

Stop if one person claims an owner role without control of its live system, if the same role names
different people with no agreed authority, or if the route has no owner who can update it.

### Confirm the live record and handle mismatches

The Agent 365 administrator opens the Agent Registry and confirms that the expected agent is
present through the selected integration. The agent owner confirms the displayed owner and
lifecycle state. The runtime owner confirms the integration can be updated and retired through its
approved path.

If the record is absent, first check the selected route and its live state: the built-in platform
publication, the Registry sync connection and latest result, or the released SDK integration. If a
record appears to describe the wrong agent, is duplicated, or has an owner or lifecycle conflict,
stop. Do not overwrite the live record, create a manual replacement, or decide which record wins
inside this module. The Agent 365 administrator, runtime owner, and agent owner resolve the
conflict through the source platform and then repeat the live review.

Stop the module if the record remains absent, ownership is unresolved, the selected integration is
not current, or the retirement path is unclear.

## Implement

### 1. Run preflight

Run the paired command for the selected route. Replace the example source reference with the
approved runtime-owned URL. It must not contain credentials.

For built-in:

```powershell
.\scripts\preflight.ps1 `
  -TargetScope "one-approved-a2a-agent" `
  -IntegrationPath "built-in" `
  -RuntimeSourceReference "https://example.invalid/agent-source"
```

```bash
./scripts/preflight.sh \
  --target-scope "one-approved-a2a-agent" \
  --integration-path "built-in" \
  --runtime-source-reference "https://example.invalid/agent-source"
```

For Registry sync:

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

For SDK:

```powershell
.\scripts\preflight.ps1 `
  -TargetScope "one-approved-a2a-agent" `
  -IntegrationPath "sdk" `
  -RuntimeSourceReference "https://example.invalid/agent-source"
```

```bash
./scripts/preflight.sh \
  --target-scope "one-approved-a2a-agent" \
  --integration-path "sdk" \
  --runtime-source-reference "https://example.invalid/agent-source"
```

### 2. Complete the selected route

| Route | Operator action | Observe before moving on |
|---|---|---|
| built-in | The platform operator follows the current documented enablement or publication path for the existing agent. | The platform shows that the in-scope agent is enabled or published through its Agent 365 integration. |
| registry-sync | The Agent 365 administrator opens Agents > All Agents, selects Manage in Connected platforms, creates or reviews the connection, validates its credentials, and runs the sync. | The connection identifies the selected provider and shows a current result. Review sync errors before expecting the agent in Agent Registry. |
| sdk | The runtime owner changes the integration in the runtime product repository and deploys it through the approved release path. | The released version is the one intended to register or update the in-scope agent. |

### 3. Observe the result

With the Agent 365 administrator, open the Agent Registry and review the new or updated record.
Confirm that it is the intended agent, arrives through the selected route, and has a known owner
and lifecycle state. The runtime owner identifies the source and release or synchronization path
that will update it. The retirement owner identifies the approved removal decision.

Resolve a mismatch before proceeding. A missing record, wrong agent, duplicate, stale sync result,
or unresolved owner is a stop condition.

## Confirm the result

The module is complete when the Agent 365 administrator and agent owner review the intended live
record, the runtime owner can identify its supported update path, and the retirement owner can
identify the approved removal decision. For Registry sync, the selected provider and current
connection result also match the route.

**Stop the module** if the record is missing, a provider is unsupported, the live state does not match
the selected route, or any owner cannot explain the retirement path.

## After implementation

The Agent 365 administrator maintains inventory visibility. The agent owner makes lifecycle
decisions. The retirement owner approves a change that removes the agent from use.

Use the same route to update, restore, or retire the inventory state:

| Route | Safe retirement or removal action | Consequence to check first |
|---|---|---|
| built-in | The platform operator follows the platform's approved retirement, unpublish, or removal path. | Check the platform's own lifecycle effect and then review Agent Registry. A runtime retirement requires the platform's approved lifecycle action; Agent Registry reflects the result. |
| registry-sync | Retire the agent in the connected platform, then run or await the approved synchronization path. Remove a connected-platform configuration only through the Microsoft 365 admin center. | Treat a connection change as potentially affecting every agent synchronized through it. The retirement owner and Agent 365 administrator must review that impact before removal. |
| sdk | The runtime owner changes or removes the SDK integration through the runtime product repository and its approved release path. | Review the released live state in Agent Registry. The runtime owner retires runtime code and service through that approved change path. |

After any route-specific change, the Agent 365 administrator, runtime owner, and agent owner review
the live record again. If the agent should no longer appear, confirm it through the selected route.
