---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: External agent inventory in Microsoft Agent 365
description: Optional implementation module for onboarding an existing external agent into Microsoft Agent 365.
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Optional module</p>

# External agent inventory in Microsoft Agent 365

**150 minutes - A live enterprise inventory record**

<!--
Set the frame: one existing external agent, one supported route, one live registry record.
-->

---

## Control objective

Onboard one existing external agent into Microsoft Agent 365 through a supported route. Record the
route, credential, owner, and retirement decisions, then review the live Agent Registry record.

![Microsoft Agent 365](assets/icons/microsoft/agent-365.svg)

---

## Why it matters

**Problem.** Agents built outside the Microsoft ecosystem run on their own platforms. Nobody in the
tenant can say which of them exist, who owns them, or how they get retired.

**Solution.** Onboarding puts the agent in the same registry as Microsoft-built agents. The runtime
owner keeps maintaining the agent through its existing source.

<!--
Foundry, Copilot Studio, and Agent Builder agents are integrated automatically. This module is for
everything else.
-->

---

## Architecture at a glance

```text
External agent + runtime-owned source
             |
   one supported Agent 365 route
             |
             v
Agent 365 Agent Registry
  enterprise inventory and lifecycle
```

The decision record holds what the registry does not: the chosen route, the credential owners, and
the retirement plan.

---

## Choose a route the runtime supports

| Route | Who acts | Expected live state |
|---|---|---|
| Built-in integration | The platform operator enables or publishes the agent | The agent appears in Agent Registry through the platform integration |
| Registry sync (preview) | The administrator validates a supported connection and runs sync | The connection shows a current result and the agent appears in Agent Registry |
| Agent 365 SDK | The runtime owner releases the SDK integration from the product repository | The released integration produces a live record |

**Stop if no route fits the runtime.** Try built-in and Registry sync before adding code.

---

## Sequencing with Agent 365 access-boundary control

Built-in means the agent is already in Agent Registry, so Agent 365 data controls can come first.

Registry sync and the SDK **create** the registry record here. The access-boundary control follows this module
on those routes.

<!--
Call this out. The access-boundary control needs an agent with Available status, which does not exist yet on the
sync and SDK routes.
-->

---

## The credential decision

A Registry sync connection uses a credential the external platform issues. On every supported
platform it also carries **delete permissions** on agent resources.

Record before the connection is created:

- Issuing owner and the approved least-privilege scope.
- The retirement coordinator's acceptance of the delete permissions.
- The managed secret store that holds it, never this repository.
- The rotation and revocation owner, and the concrete revoke action.

---

## Implementation tradeoffs

| Choice | Approach | Limit |
|---|---|---|
| Inventory | Agent 365 Agent Registry | The record only arrives through a supported route |
| Route preference | Built-in and Registry sync before the SDK | Registry sync is preview; the platform list changes |
| Retirement | One coordinator, one cross-platform plan | Stays a human process across two organizations |

---

## What preflight checks

It reads `onboarding-decision.json` and rejects:

- unresolved decisions and an unrecognized route;
- a source reference that is not absolute HTTP or HTTPS, or that carries embedded credentials;
- an incomplete credential decision, or a store inside this repository;
- a retirement plan missing a required action.

**It does not contact Agent 365 or the external platform.** Licensing, admin access, and a working
connection are still confirmed live.

---

<!-- _class: implementation -->

## Run the module

1. Complete the decision record with the owners in the room.
2. Run preflight in PowerShell or Bash.
3. Complete the platform or runtime change for the selected route.
4. Open Agent Registry with the administrator.
5. Confirm the intended record, owner, lifecycle state, and retirement path.

---

## Confirm the result

The intended live record is in Agent Registry, arrived through the selected route, and its owners
can maintain and retire it.

Stop for a missing, duplicate, stale, or wrongly owned record. Resolve it in the source platform,
then read the registry again.

---

## Operating state

| Owner | Maintains |
|---|---|
| Runtime owner | Agent definition, endpoint, and source integration |
| Agent 365 administrator | Inventory visibility and connected-platform configuration |
| Agent owner | Lifecycle decisions |
| Retirement coordinator | The cross-platform retirement plan and credential revocation |

Delete a Registry sync connection only after checking every agent it can affect.

---

<!-- _class: closing -->

# Thank you!
