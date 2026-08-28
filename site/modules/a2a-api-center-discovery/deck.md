---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: A2A agent discovery in Azure API Center
description: Optional implementation add-on for publishing a runtime-owned A2A agent interface to Azure API Center.
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Optional add-on</p>

# A2A agent discovery in Azure API Center

**60 minutes - A live developer-discovery asset**

---

## Control objective

Expose one already-governed A2A agent for developer discovery in Azure API Center through a
supported Git or API Management integration maintained by the runtime owner.

![Azure API Center](assets/icons/microsoft/azure-api-center.svg)

---

## Why it matters

Agent 365 covers enterprise inventory. Developers sometimes also need a current A2A interface in
their API catalog.

The source integration keeps that technical entry current. It does not copy the agent card or
definition into this repository.

---

## Architecture at a glance

| Platform | Stores or maintains |
|---|---|
| Microsoft Agent 365 | Enterprise inventory, owner, and lifecycle |
| Azure API Center | Developer discovery asset |
| Runtime source | A2A definition, agent card, endpoint, and behavior |

This repository stores no copy of these records.

---

## Use API Center only when developers need it

Add this asset only when developers need discovery.

If they do not need it, keep the Agent 365 enterprise inventory record and do not create another
catalog entry.

---

## Implementation tradeoffs

| Choice | Route | Limit |
|---|---|---|
| Discovery record | Azure API Center | It exists only for developer discovery |
| Technical source | Git or API Management integration | Source setup and refresh remain owner work |
| Completion | Live asset review | A portal or supported API read is required |

---

## Use one source integration

```text
Runtime-owned Git or API Management source
                  |
                  v
       Azure API Center synchronization
                  |
                  v
       Live A2A discovery asset
```

Do not manually register the agent beside its source integration.

---

## Preflight safety gates

- The Agent 365 record is present.
- Developers need the A2A interface in API Center.
- Git or API Management is the approved source.
- The runtime owner maintains the source.
- The API Center owner can review the live asset.

---

<!-- _class: implementation -->

## Run the add-on

1. Confirm the developer-discovery need.
2. Run preflight with the runtime-owned source reference.
3. Configure or refresh the approved source integration.
4. Open the live Agent asset in API Center.
5. Confirm the A2A interface and its source relationship.

---

## Confirm the result

The module passes when API Center exposes the current A2A asset from the approved source, while
Agent 365 remains the enterprise inventory.

No local card, definition, export, or comparison record is created.

---

## Operating state

| Owner | Maintains |
|---|---|
| Runtime owner | Technical source and A2A interface |
| API Center owner | Source integration and discovery configuration |
| Agent 365 administrator | Enterprise inventory and lifecycle visibility |

---

<!-- _class: closing -->

# Thank you!
