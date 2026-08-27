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

# Microsoft Foundry platform baseline and inventory

**210 minutes · Deploy an owned, rebuildable Foundry baseline**

---

## Control and session outcomes

> Establish one owned, tagged Microsoft Foundry baseline connected to workspace-based Application Insights through a repeatable deployment.

- create the current Foundry parent-and-project model from Bicep;
- give both boundaries managed identities and explicit ownership metadata;
- connect the project to workspace-based Application Insights; and
- record the customer inventory link and, when needed, a migration-backlog pointer with the resource-model decision.

The connection configures a monitoring path. This session does not prove that application logs are arriving.

<!-- Notes: Set the boundary early. Policy enforcement, production RBAC, and private networking come later. -->

---

<!-- _class: section-divider -->

## Why it matters

Later controls need a stable Foundry boundary that the team can rebuild and identify by owner. Operations also needs one place to find the live resource details.

---

<!-- _class: two-column -->

## Architecture overview

One deployment creates the Foundry boundary that later controls build on. Azure shows what is
running; the repository defines the intended shape; the customer inventory tells operators where
the environment belongs.

<div class="columns">
<div>

### What happens

1. Read the subscription and existing tags without changing them.
2. Preview the approved resource group.
3. Deploy the Foundry resource, child project, and Application Insights connection.
4. Record the live baseline in the customer system.

Classic assets are not pulled into this boundary. Their migration backlog stays in the customer
inventory system.

</div>
<div>

![Flow from the customer repository to the Foundry baseline, operational inventory, and migration backlog](assets/diagrams/session-flow.svg)

</div>
</div>

<!-- Notes: The repository holds reusable definitions. Environment inventory stays in the customer's operating system. -->

---

## The current resource model

<div class="cards">
<div class="card">

### Foundry resource

`Microsoft.CognitiveServices/accounts`

`kind: AIServices`

</div>
<div class="card">

### Child project

`accounts/projects`

Identity and ownership boundary

</div>
<div class="card">

### Classic candidates

Run classic discovery only when classic assets are in scope and subscription Reader access is available. Otherwise, skip it.

The operator verifies candidates in Foundry (classic).

The platform owner assigns confirmed migrations in the backlog.

</div>
</div>

> The product name changed. The Azure resource provider did not.

<!-- Notes: New work uses the current child-project model. Do not mix hub templates into this baseline. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Chosen approach | Tradeoff |
|---|---|---|
| Resource model | Current Foundry resource and child project | Classic assets need separate migration work |
| Desired state | Bicep and `.bicepparam` | Portal changes must be reconciled |
| Baseline identity and tracing | System-assigned identities and an Application Insights connection | Session 03 grants access; a later runtime check proves trace delivery |

<!-- Notes: Keep an existing landing-zone restriction. This session never weakens the network rule to make deployment easier. -->

---

## Record ownership, cost, risk, and expiry

| Ownership and cost | Risk and lifecycle |
|---|---|
| `businessOwner` | `dataClassification` |
| `technicalOwner` | `criticality` |
| `costCenter` | `expiryDate` |
| `environment` | Plain text only; no sensitive values |

The same tag object is applied to the resource group and every taggable resource. Tags do not inherit automatically from the resource group.

<!-- Notes: Use team aliases and synthetic classifications. Tags are visible to anyone with tag read access. -->

---

## Implementation path

1. **Decide** the region, network choice, ownership values, expiry, and resource model.
2. **Mark** the approved resource group with `implementationSession=01-platform-baseline`.
3. **Preflight** tools, providers, sentinels, the approved sandbox subscription and resource group, Bicep syntax, and planned changes.
4. **Deploy** the parent, project, Log Analytics workspace, Application Insights, and connection.
5. **Confirm** the live state with one repeat deployment preview.
6. **Operate** live inventory and any migration backlog through the customer system.

---

<!-- _class: implementation -->

## Deploy the Foundry baseline

**Timebox:** 100 minutes

Deploy a production-shaped Foundry baseline in one approved sandbox resource group.

- **State change:** current Foundry parent, child project, and observability connection
- **Operator access:** Contributor on the approved sandbox subscription when creating the resource group, or on the approved sandbox resource group when it already exists
- **Safety boundary:** resolved decisions, approved sandbox subscription and resource group, and marked removal scope
- **Data rule:** no secrets or customer content in parameters, tags, outputs, or source control
- **Live state:** deployed baseline, reusable definitions, and one decision plus customer-system pointer

---

## Stop before the change when

- any `__REQUIRED_*__` value remains;
- Azure CLI is not using the approved sandbox subscription or approved sandbox resource group;
- the resource-group marker is missing or belongs to another implementation;
- provider registration or public access would bypass the customer's change rules; or
- the first preview includes anything outside the documented baseline.

The Application Insights connection string is resolved inside Bicep. Never move it into a parameter, output, tag, or repository file.

<!-- Notes: These are the consequential gates. Routine steps do not need a checkpoint. -->

---

## One result check

Rerun the preflight and inspect its final Bicep deployment preview:

```powershell
.\scripts\preflight.ps1 `
  -ResourceGroupName $resourceGroup `
  -DeploymentName "rvas-s01-baseline"
```

**Expected:** no unintended change to the operational baseline.

The project `AppInsights` connection may appear as `Modify` or `Deploy` because its credential is write-only. Treat only that connection as expected platform noise.

Any other change means stop and investigate. The command output does not need to be saved.

<!-- Notes: Observe the live preview with the team. This is the session's single result check. -->

---

## What remains after implementation

| Operational item | Location | Owner |
|---|---|---|
| Foundry resource, project, workspace, Application Insights, and connection | Approved sandbox resource group | Platform owner |
| Bicep, parameters, preflight, and guarded removal guidance | Customer-owned repository | Platform engineering |
| Live resource inventory and any migration backlog | Customer operational system | Platform operations |
| Current-versus-classic decision and external system reference | Resource-model decision | Platform owner |

The `expiryDate` tells the owner when to keep or remove the sandbox baseline. Removal applies only to the marked group and resources listed by the current deployment.

<!-- Notes: Keep the baseline for Session 02 unless the customer chooses the guarded removal path. -->

---

## Recap and next dependency

- Session 01 leaves a rebuildable current-model Foundry boundary.
- Identity, tags, and the observability connection are defined in source.
- Operations receives the baseline; classic candidates stay out of this deployment.
- [Session 02](../02-landing-zone-guardrails/) turns the configuration requirements into Azure Policy audit and deny controls.

---

<!-- _class: closing -->

# Thank you!
