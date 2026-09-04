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
users -> workload entry -> Foundry agent
                            |       |
                       workload   Citadel hub
                         data     models/tools
```

The agent has one fixed version, Entra authorization, and one read-only tool.

---

<!-- _class: decision -->

## Implementation tradeoffs

| Component | Default |
| --- | --- |
| Foundry Agent Service | Include |
| Existing network and Key Vault | Reuse |
| Container Apps | Exclude unless required |
| Application Gateway, build VM, jump VM | Exclude unless required |

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
