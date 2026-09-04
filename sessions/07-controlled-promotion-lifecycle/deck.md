---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 07</p>

# Promote and operate the Citadel platform lifecycle

300 minutes · Bind, promote, restore, and inventory one immutable release

---

## Why it matters

Citadel spans upstream source, customer overlays, agents, contracts, gates, and Azure resources.

**One release SHA keeps those parts from drifting across pipeline stages.**

---

## Architecture overview

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

```text
customer release manifest
hub | spoke | gateway | contracts | agent | gates
                    |
          protected promotion workflow
                    |
 nonproduction preview/apply/smoke
                    |
 production preview/approval/apply
```

One manifest binds several independent Citadel release tracks.

---

## Choose the correct release path

| Change | Deployment path |
| --- | --- |
| Initial hub | Hub landing-zone deployment |
| APIM APIs, policies, fragments, backends | Pinned Gateway Upgrade path |
| Model supply | Backend Contract |
| MCP or A2A publication | Publish Contract |
| Workload access | Access Contract |
| Agent runtime | Spoke or agent deployment |

Do not reprovision the landing zone for an APIM policy change.

---

## Restore boundaries

```text
application revision | gateway configuration
infrastructure       | data
```

A previous APIM configuration does not restore deleted data, networking, identities, model capacity, or regional services.

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Session position |
| --- | --- |
| Release identity | Full SHA plus every changed track |
| Azure access | Environment-scoped OIDC |
| Approval | Protected environments and no self-approval |
| Restore | Previous approved manifest through the same workflow |
| Recovery | Keep application, gateway, infrastructure, and data recovery separate |

---

<!-- _class: implementation -->

## Working path

1. Complete release and estate definitions.
2. Run local, identity, gate, and what-if preflight.
3. Promote one approved immutable release.
4. Prove the generated blocked run stops before Azure.
5. Deploy the estate workbook and assign findings.

---

## Safety gates

- Promote only a full commit SHA and fixed component digests.
- Require a matching preview and protected approval before apply.
- Keep restore manual and limited to an approved release.

---

## Expected result

The same release reaches both environments, routing moves once, restore remains available, and the deployed Citadel estate has named lifecycle owners.

---

## Operating state

The release pipeline owns promotion and restore. The estate process identifies drift and retirement work without replacing live Azure state as the authority.

---

<!-- _class: closing -->

# Thank you!
