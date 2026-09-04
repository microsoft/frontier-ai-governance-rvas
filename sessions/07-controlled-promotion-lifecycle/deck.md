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

![Azure Container Apps](assets/icons/microsoft/azure-container-apps.svg)

```text
release SHA -> gates -> nonproduction -> production -> APIM selector
                                                  |
                                      release and estate records
```

Every apply follows its matching preview and protected approval.

---

<!-- _class: decision -->

## Implementation tradeoffs

- Full commit SHA and fixed component digests
- Environment-scoped Azure OIDC
- Required reviewers and no self-approval
- Manual restore to an approved release
- Live estate, lifecycle, and retirement review

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
