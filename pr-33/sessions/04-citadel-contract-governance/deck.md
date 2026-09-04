---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 04</p>

# Govern Citadel backends, access, tools, and agents

330 minutes · Onboard one workload through reviewable contracts

---

## Why it matters

Manual gateway configuration does not scale across workloads.

Citadel contracts separate **model supply**, **asset publishing**, and **workload access** so each owner changes only their boundary.

---

## Architecture overview

![Azure API Center](assets/icons/microsoft/azure-api-center.svg)

```text
Backend contract -> model supply and routing
Publish contract -> MCP or A2A exposure
Access contract  -> workload product and subscription
```

The contracts create or reconcile live APIM state. They are not inventory documents.

---

## What each contract changes

| Contract | Creates or updates |
| --- | --- |
| Backend | Backends, pools, aliases, routing fragments, model metadata |
| Publish | API, baseline policy, usage metrics, optional API Center record |
| Access | Product, API attachments, product policy, subscription, access material |

The Publish Contract does not create the backing MCP server or grant consumer access.

---

## Deployment order

```text
backend -> publish -> access -> workload
```

- Access resolves the published API paths.
- Re-run access after a published path changes.
- Store generated access material in the workload Key Vault.
- Publishing and consumption remain separate approvals.

---

<!-- _class: decision -->

## Implementation tradeoffs

| Contract | Scope |
| --- | --- |
| Backend | Model endpoints, identity, priority, weight, and routing behavior |
| Publish | Existing MCP or A2A asset; preview adoption is optional |
| Access | One use case and environment with explicit APIs and limits |
| API-to-MCP | Test subscription-key behavior through a real invocation |

---

<!-- _class: implementation -->

## Working path

1. Complete the three customer overlays.
2. Review the tool threat model.
3. Run preflight against the pinned Citadel source.
4. Deploy backend, optional publish, then access.
5. Check the intended path and prohibited action.

---

## Safety gates

- Preview each contract before deployment.
- Stop on changes outside the approved backend, publish, and access scope.
- Treat publishing and access as separate approvals.

---

## Expected result

The workload reaches its approved model and read-only tool through one Citadel access contract. Runtime telemetry identifies the use case without copying prompts or tool payloads.

---

## Operating state

Platform, tool, security, and workload owners update their own contract boundary. The approved deployment path reconciles those overlays with the pinned hub release.

---

<!-- _class: closing -->

# Thank you!
