---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 02</p>

# Deploy the Citadel Governance Hub

300 minutes · Pin, configure, deploy, and check the shared runtime control plane

---

## Why it matters

Citadel's quick start can create services, capacity, telemetry stores, and network paths the customer did not plan to own.

**The deployment profile turns those defaults into reviewed choices.**

---

## Architecture overview

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

```text
workloads -> APIM -> safety and routing -> Foundry backends
              |
          API Center
              |
 monitoring and usage processing
```

The upstream commit owns the implementation. Customer overlays own the deployment choice.

---

<!-- _class: decision -->

## Implementation tradeoffs

| Enable now | Enable when needed |
| --- | --- |
| APIM, Foundry, identities, monitoring | AI Search, Document Intelligence |
| API Center and PII handling | Managed Redis and extra models |
| Existing VNet and Log Analytics | New shared services |

Prompt and response bodies stay disabled by default.

---

<!-- _class: implementation -->

## Working path

1. Check out the pinned Citadel commit.
2. Complete `deployment-profile.json`.
3. Run source, scope, and prerequisite preflight.
4. Run the upstream `azd` deployment.
5. Inspect resources, identities, private paths, and telemetry.

---

## Safety gates

- Verify the immutable upstream commit before deployment.
- Stop when the profile enables an unowned optional service.
- Keep prompt and response body logging disabled by default.

---

## Expected result

One shared Governance Hub is running from a known source. No unapproved optional service exists. Session 04 can onboard workloads through contracts instead of manual APIM changes.

---

## Operating state

The platform team owns the hub release, deployment profile, shared identities, and runtime services. Workload teams consume the hub through contracts.

---

<!-- _class: closing -->

# Thank you!
