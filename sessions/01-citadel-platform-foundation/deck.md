---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 01</p>

# Citadel platform foundation and landing-zone guardrails

300 minutes · Prepare the network and governance boundary Citadel will inherit

---

## Why it matters

Citadel can deploy a broad platform quickly. **Unresolved landing-zone decisions become expensive defaults.**

This session fixes the subscription, network, DNS, ownership, tag, policy, and upstream-release boundaries before the hub exists.

---

## Architecture overview

![Azure Policy](assets/icons/microsoft/azure-policy.svg)

```text
customer landing zone
       |
network, DNS, identity, policy
       |
Citadel Governance Hub + Agent Spokes
```

Azure owns live state. The customer repository owns the reviewed Bicep and parameter files.

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Session answer |
| --- | --- |
| Network | Existing platform network or dedicated Citadel network |
| Access | Private paths and approved execution host |
| Governance | Required tags and initial policy mode |
| Release | Tested Citadel commits and upgrade owner |

Stop on address overlap, unclear DNS ownership, unreviewed inherited policy, or unrelated what-if changes.

---

<!-- _class: implementation -->

## Working path

1. Complete the network and policy parameters.
2. Resolve current built-in policy IDs.
3. Run preflight and review all previews.
4. Deploy the approved foundation.
5. Check private DNS and connectivity.

---

## Safety gates

- Stop on overlapping address space or unresolved DNS ownership.
- Review inherited policy before changing the target scope.
- Apply only the reviewed network and policy preview.

---

## Expected result

- Dedicated Citadel subnets and controlled egress are ready.
- Private DNS resolves from the approved host.
- Required-tag policy is staged on the intended scope.
- Session 02 can deploy without guessing about the landing zone.

---

## Operating state

The platform team owns network, DNS, policy, and upstream release decisions. Later sessions consume this boundary instead of redefining it.

---

<!-- _class: closing -->

# Thank you!
