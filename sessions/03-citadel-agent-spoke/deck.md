---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 03</p>

# Deploy a Citadel Agent Spoke and governed agent

300 minutes · Build the smallest useful workload plane and one bounded agent

---

## Why it matters

The complete Agent Spoke can include more infrastructure than a first workload needs.

**Start with the runtime, network, identity, and data services that have a current owner.**

---

## Architecture overview

![Microsoft Foundry Agent Service](assets/icons/microsoft/foundry-agent-service.svg)

```text
users or application
        |
workload entry point
        |
versioned agent or orchestrator
   |                      |
private workload data   Citadel access contract
                          |
                    Governance Hub APIM
```

The spoke owns workload runtime and data. The shared hub owns model and published-asset access.

---

## Choose the spoke boundary

Use one spoke per **workload ownership and data boundary**, not automatically one per agent.

Split when any of these differ:

- subscription or network;
- data owner or classification;
- release authority;
- recovery requirement.

Container Apps, Application Gateway, jump VMs, and local APIM remain optional.

---

## Identity and traffic

```text
agent identity -> workload data roles
agent or project identity -> Citadel product
Citadel APIM identity -> model or tool backend
```

Managed identity removes stored credentials. RBAC and the Session 04 contracts still define what each hop may do.

---

<!-- _class: decision -->

## Implementation tradeoffs

| Component | Default |
| --- | --- |
| Foundry Agent Service | Include |
| Shared Governance Hub | Use for model and tool traffic |
| Private workload data | Keep inside the spoke boundary |
| Container Apps | Exclude unless required |
| Local APIM or Application Gateway | Exclude unless required |

---

<!-- _class: implementation -->

## Working path

1. Pin the AI Landing Zones commit.
2. Complete the spoke profile.
3. Deploy or integrate the workload plane.
4. Run agent preflight.
5. Create and pin the policy-assistant agent.

---

## Safety gates

- Verify the pinned Agent Spoke source.
- Stop when an optional component lacks an owner or current need.
- Keep the first tool read-only and the agent version fixed.

---

## Expected result

The workload team can name every deployed component and its owner. The fixed agent version is ready for model and tool access through Citadel contracts.

---

## Operating state

The workload team owns the spoke and agent configuration. The platform team owns shared Citadel services and the contract onboarding path.

---

<!-- _class: closing -->

# Thank you!
