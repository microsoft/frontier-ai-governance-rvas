---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: Microsoft Agent 365 onboarding and access boundaries
description: Install one approved Agent Registry agent for a nonproduction group, confirm group access, and keep an uninstall route.
---

<!-- _class: cover -->

# Microsoft Agent 365 onboarding and access boundaries

## Session 06 · 180 minutes

Install one nonproduction agent for synthetic setup in one test group.

<!-- Notes: Keep the session focused on availability and consent. The agent runtime stays in its native service. -->

---

## Control objective

Install one approved Agent Registry agent for a named Microsoft Entra test group. Review and grant
its approved permissions. Withhold meaningful user access until Session 10 confirms DLP coverage.

![Microsoft Agent 365](assets/icons/microsoft/agent-365.svg)

<!-- Notes: This is a tenant change. It is not an owner review packet. -->

---

## Why it matters

Agent Registry answers which agents exist. Group deployment decides who can use one of them.

The pilot stays with an accountable test group until **the delivery owner approves a wider change**.

<!-- Notes: Avoid treating inventory visibility as an access boundary. -->

---

<!-- _class: decision -->

## Control boundary

| In scope | Outside this session |
| --- | --- |
| One Available Agent Registry entry | Agent creation or runtime changes |
| One Microsoft Entra test group | Organization-wide publishing |
| One host product and approved consent | Tenant-wide block or Conditional Access |
| Uninstall from the same group | Agent deletion |

<!-- Notes: If any proposed action exceeds this boundary, stop and return it to the approved change path. -->

---

## Architecture overview

![An Agent Registry entry is installed through Microsoft 365 admin center for a Microsoft Entra test group. A group member can use the agent in one host product, while a user outside the group cannot.](assets/icons/microsoft/agent-365.svg)

1. Agent Registry supplies the approved agent.
2. Microsoft 365 admin center installs it for the test group.
3. Microsoft Entra supplies group membership.
4. The administrator can uninstall the same deployment.

<!-- Notes: The icon represents Agent Registry. Explain the relationship in the spoken narrative rather than claiming it is an architecture diagram. -->

---

## Implementation tradeoffs

| Choice | Decision |
| --- | --- |
| Audience | Install for one Microsoft Entra test group |
| Permissions | Grant the reviewed consent during group deployment |
| Restore | Uninstall from that same group |

<!-- Notes: These choices keep the tenant change narrow and reversible. -->

---

## Decisions before the change

- The exact Available agent and its registry ID
- The named nonproduction test group
- One approved host product and use case
- The requested permissions and consent decision
- The administrator who can uninstall

<!-- Notes: Preflight rejects incomplete values in agent-deployment.json. -->

---

<!-- _class: implementation -->

## Install the scoped pilot

1. Complete `agent-deployment.json` and run preflight.
2. Open Agents > All agents > Registry.
3. Select the approved Available agent and choose **Install**.
4. Select the named test group.
5. Review permissions, grant **approved admin consent**, and finish deployment.

<!-- Notes: Stop if the portal shows a different agent, wider audience, or unexpected permission. -->

---

## Hold user access until DLP is confirmed

| Check | Expected result |
| --- | --- |
| Test group | Uses synthetic setup data only |
| Session 10 DLP policy | Is enabled and propagation is confirmed before meaningful use |
| Delivery owner | Confirms the withheld-access boundary and consent scope |

<!-- Notes: The excluded-user result matters. Do not add the excluded user to the group to make the test pass. -->

---

## What remains

Microsoft 365 keeps the deployment and consent state. Microsoft Entra keeps group membership.
Agent 365 keeps the registry record.

To restore the prior state, the Microsoft 365 administrator uninstalls the agent from the recorded
test group. The agent and its runtime remain unchanged.

<!-- Notes: Wider rollout needs a separate approved change. -->

---

<!-- _class: closing -->

# Thank you!
