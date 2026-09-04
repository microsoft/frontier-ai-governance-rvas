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
workload -> APIM API and product policy
                |
        shared policy fragments
  authorization | safety | limits | routing
                |
      backend or pool -> AI provider
```

APIM is the runtime boundary. Azure and Foundry management remain separate control-plane paths.

---

## Hub resource topology

```text
VNet and private DNS
  |
  +-- APIM + managed identities + Key Vault
  +-- Foundry and configured model backends
  +-- Application Insights + Log Analytics
  +-- Event Hubs + Logic App + Cosmos DB
  +-- API Center and Managed Redis when enabled
```

Backend access, Key Vault lookup, and usage processing use separate identities.

---

## Two operating pipelines

| Runtime diagnostics | Usage allocation |
| --- | --- |
| APIM to Application Insights and Log Analytics | Scheduled processing into Cosmos DB |
| Health, latency, failures, tokens, correlation | Product, model, backend, and application allocation |
| Near-real-time operations | Delayed showback data |

Neither pipeline is the Foundry control plane.

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Session position |
| --- | --- |
| APIM | Production-capable tier and private ingress for production |
| Backend auth | APIM user-assigned identity |
| Secrets | Key Vault-backed named values |
| API Center | Enable only with a catalog owner |
| Message capture | Override the upstream default to `none` |

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
