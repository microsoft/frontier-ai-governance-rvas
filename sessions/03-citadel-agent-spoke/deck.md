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

The upstream pattern can deploy more infrastructure than this workload needs.

**Pin one Bicep release and disable every component without a current owner.**

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
| Deployment source | AI Landing Zones Bicep `v2.6.1` |
| Foundry Agent Service | Include |
| Agent and private-endpoint subnets | Use approved workload ranges |
| Egress route | Reuse the platform-owned route table |
| Shared Governance Hub | Use for model and tool traffic |
| Separate workload data services | Exclude until the workload needs them |
| Container Apps | Exclude unless required |
| Local APIM or Application Gateway | Exclude unless required |

---

<!-- _class: implementation -->

## Working path

1. Verify the Bicep remote and pinned commit.
2. Generate parameters from the spoke profile.
3. Review the resource-group what-if.
4. Apply and check the workload plane.
5. Create the fixed policy-assistant version.

---

## Safety gates

- Verify the pinned Agent Spoke source.
- Stop on an unexpected resource or deletion in what-if.
- Stop when an optional component lacks an owner or current need.
- Keep the first tool read-only and the agent version fixed.

---

## Expected result

The deployed resource group matches the spoke profile. The fixed agent version is ready for model
and tool access through Citadel contracts.

---

## Operating state

The workload team owns the spoke and agent configuration. The platform team owns shared Citadel services and the contract onboarding path.

---

<!-- _class: closing -->

# Thank you!
