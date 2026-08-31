---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 06</p>

# Microsoft Agent 365 onboarding and access boundaries

90 minutes · Prepare one deployment and hold access

<!-- Notes: Prepare the contract. Do not install the agent. -->

---

## Why it matters

> Prepare one approved Agent Registry deployment for a named Microsoft Entra test group. Keep it
> uninstalled until Session 10 confirms DLP coverage.

Record the agent, group, host, use case, and consent. Microsoft 365 must show no group installation.

---

<!-- _class: two-column -->

## Architecture

<div class="columns">
<div>

![Microsoft Agent 365](assets/icons/microsoft/agent-365.svg)

Agent 365 holds inventory and installation. Microsoft Entra holds identity and membership.

</div>
<div>

The repository holds `agent-deployment.json`.

Session 06 confirms no installation. Session 10 confirms DLP, installs, and checks both users.

</div>
</div>

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Answer |
|---|---|
| Agent | Available registry entry |
| Audience | Sponsored test group |
| Use | One host, use case, and approved consent |
| Restore | Administrator who can remove access |

Runtime, membership, Conditional Access, and tenant-wide blocks do not change.

---

<!-- _class: implementation -->

## Implementation path

**90 minutes total · about 60 minutes guided work**

1. Complete `agent-deployment.json`; run preflight.
2. Inspect the Available registry entry.
3. Confirm no group installation.
4. Match host and consent to the approval.
5. Hand off to Session 10.

**Stop:** unresolved value; unavailable agent; wider audience; changed permission; early access; or
no removal owner.

Do not select **Install**, grant consent, add a host product, or choose organization-wide deployment.

<!-- Notes: The admin center has no read-only installation preview. -->

---

<!-- _class: two-column -->

## Confirm both paths

<div class="columns">
<div>

### Intended

Contract matches. No installation exists.

</div>
<div>

### Blocked

Early access fails. Remove the group installation.

</div>
</div>

The delivery owner observes both checks.

<!-- Notes: Keep the contract only when the group is uninstalled and consent matches. -->

---

## Operate and restore

- Agent 365 administrator: registry
- Entra owner: membership
- Microsoft 365 administrator: contract
- Session 10: installation and checks

Restore by removing the group installation under **Agents > All agents > Registry**. Leave the
agent, runtime, and membership unchanged.

---

<!-- _class: closing -->

# Thank you!
