---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: A2A agent inventory in Microsoft Agent 365
description: Optional implementation module for onboarding an existing A2A agent into Microsoft Agent 365.
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Optional module</p>

# A2A agent inventory in Microsoft Agent 365

**150 minutes - A live enterprise inventory record**

---

## Control objective

Onboard or confirm an approved A2A agent in Microsoft Agent 365 through a supported integration
route, then confirm its live inventory record, owner, and lifecycle state.

![Microsoft Agent 365](assets/icons/microsoft/agent-365.svg)

---

## Why it matters

Teams need a live inventory for the agent and its lifecycle.

The runtime owner maintains the A2A definition, card, endpoint, and behavior. A repository copy
goes stale when the runtime changes.

---

## Architecture at a glance

```text
Runtime product repository
  A2A definition and agent card
             |
             v
Supported Agent 365 integration
             |
             v
Agent 365 Agent Registry
  enterprise inventory and lifecycle
```

This repository does not hold a second inventory record.

---

## Choose a path the runtime supports

| Path | Use it when |
|---|---|
| Built-in integration | The current agent platform already integrates with Agent 365 |
| Registry sync | The runtime is on a supported connected platform |
| Agent 365 SDK | The runtime owner needs code-level Agent 365 capabilities |

Stop if none of these paths is available.

---

## Implementation tradeoffs

| Choice | Route | Limit |
|---|---|---|
| Inventory | Agent 365 Agent Registry | A supported integration is required |
| Runtime source | Product repository or platform source | This module does not author runtime code |
| Technical discovery | Separate API Center add-on | It is used only when developers need it |

---

## Implementation boundary

The runtime owner makes and deploys SDK changes from the runtime product repository. The Agent 365
administrator configures supported connected platforms and reviews the registry. This module does
not create an agent card, upload a Markdown definition, or duplicate ownership and lifecycle metadata.

---

## Preflight safety gates

- An approved A2A agent already runs in the nonproduction scope.
- The selected integration route is currently supported.
- The runtime owner controls the source identified by the reference, and it has no embedded credentials.
- Agent owner and retirement owner are available.
- Agent 365 licensing and administrator access are confirmed.

---

<!-- _class: implementation -->

## Run the supported path

1. Select built-in integration, Registry sync, or SDK.
2. Run preflight with the runtime-owned source reference.
3. Complete the platform or runtime-owned product change.
4. Open Agent Registry with the administrator.
5. Confirm the live record, owner, lifecycle state, and retirement path.

---

## Confirm the result

The module passes when the live Agent 365 record exists and the owners can maintain and retire it
through the supported path.

No screenshot, export, or repository record is created.

---

## Operating state

| Owner | Maintains |
|---|---|
| Runtime owner | A2A definition, agent card, endpoint, and integration source |
| Agent 365 administrator | Inventory visibility and connected-platform configuration |
| Agent owner | Lifecycle and retirement decision |

Use the separate API Center discovery add-on when developers need the A2A interface in a catalog.

---

<!-- _class: closing -->

# Thank you!
