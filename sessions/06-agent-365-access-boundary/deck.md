---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: Microsoft Agent 365 onboarding and access boundaries
description: Prepare one approved Agent Registry deployment without granting group access before Session 10 confirms DLP coverage.
---

<!-- _class: cover -->

# Microsoft Agent 365 onboarding and access boundaries

## Session 06 · 180 minutes

Prepare one nonproduction Agent Registry deployment for one test group.

<!-- Notes: Keep the session focused on availability and consent. The agent runtime stays in its native service. -->

---

## Control objective

Prepare one approved Agent Registry deployment for a named Microsoft Entra test group. Do not
install it or grant group availability until Session 10 confirms DLP coverage.

![Microsoft Agent 365](assets/icons/microsoft/agent-365.svg)

<!-- Notes: This is a tenant change. It is not an owner review packet. -->

---

## Why it matters

Agent Registry answers which agents exist. Installing to a group decides who can use one of them.

The deployment remains uninstalled until **Session 10 confirms that DLP is enabled and propagated**.

<!-- Notes: Avoid treating inventory visibility as an access boundary. -->

---

<!-- _class: decision -->

## Control boundary

| In scope | Outside this session |
| --- | --- |
| One Available Agent Registry entry | Agent creation or runtime changes |
| One Microsoft Entra test group | Group installation before DLP confirmation |
| One host product and approved consent decision | Tenant-wide block or Conditional Access |
| Post-DLP installation route | Agent deletion |

<!-- Notes: If any proposed action exceeds this boundary, stop and return it to the approved change path. -->

---

## Architecture overview

![An Agent Registry entry, group, host product, and consent decision are prepared for a Microsoft Entra test group. Session 10 installs it after DLP confirmation.](assets/icons/microsoft/agent-365.svg)

1. Agent Registry supplies the approved agent.
2. Microsoft 365 admin center retains the uninstalled registry entry.
3. Session 10 confirms DLP before installation.
4. Microsoft Entra supplies group membership after the approved installation.

<!-- Notes: The icon represents Agent Registry. Explain the relationship in the spoken narrative rather than claiming it is an architecture diagram. -->

---

## Implementation tradeoffs

| Choice | Decision |
| --- | --- |
| Audience | Prepare one Microsoft Entra test group without installing |
| Permissions | Record the reviewed consent decision for the post-DLP deployment |
| Restore | Remove a mistaken installation through Microsoft 365 admin center |

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

## Prepare the scoped deployment

1. Complete `agent-deployment.json` and run preflight.
2. Open Agents > All agents > Registry and inspect the approved Available agent.
3. Confirm that it is not installed for the named test group.
4. Record the group, host product, and approved consent decision.
5. Hand the contract to Session 10 for the DLP-gated installation.

<!-- Notes: Stop if the portal shows a different agent, wider audience, or unexpected permission. -->

---

## Hold user access until DLP is confirmed

| Check | Expected result |
| --- | --- |
| Test group | Is recorded for synthetic post-DLP validation; it has no agent access yet |
| Session 10 DLP policy | Is enabled and propagation is confirmed before meaningful use |
| Delivery owner | Confirms the withheld-access boundary and consent scope |

<!-- Notes: The excluded-user result matters. Do not add the excluded user to the group to make the test pass. -->

---

## What remains

Microsoft 365 keeps the Agent Registry entry. Microsoft Entra keeps group membership.
Session 10 owns the installation and consent state after DLP confirmation.

If an installation occurs before DLP confirmation, the Microsoft 365 administrator removes it from
the recorded test group. The agent and its runtime remain unchanged.

<!-- Notes: Wider rollout needs a separate approved change. -->

---

<!-- _class: closing -->

# Thank you!
