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

# Microsoft Foundry platform baseline, inventory, and landing-zone guardrails

**300 minutes · Deploy an owned baseline, then stage deny-mode guardrails**

---

## Control and session outcomes

> Deploy an owned, tagged Microsoft Foundry baseline with workspace-based Application Insights. Stage an Azure Policy assignment that denies evaluated ARM changes with disallowed locations or missing required tags.

- Deploy the current Foundry parent-and-project model from Bicep.
- Give both boundaries managed identities and explicit ownership metadata.
- Connect the project to workspace-based Application Insights.
- Update the customer inventory and, when needed, the migration backlog through normal systems.
- Resolve current built-ins and deploy a reusable initiative staged on the same resource group.
- Promote the assignment to `Default` after owner review and change approval.

The connection configures a monitoring path; it does not prove that application logs are arriving.
The policy assignment does not fix existing resources or cover controls outside these two rules.

<!-- Notes: Set the boundary early, then narrow the change path into it. Production RBAC and private networking come later. -->

---

<!-- _class: section-divider -->

## Why it matters

Later controls need a stable Foundry boundary the team can rebuild and identify by owner. Operations needs a single place to find live resource details. Staging the policy shows its likely impact before deny mode is turned on, so the owner can handle exemptions before the change authority promotes enforcement.

---

<!-- _class: two-column -->

## Architecture overview

One deployment creates the Foundry boundary. A policy layer then controls evaluated ARM changes within it. Azure shows what is running and what policy applies; the repository defines the intended shape; the customer inventory and change systems own their records.

<div class="columns">
<div>

### What happens

1. Inspect the subscription and existing tags without changing them.
2. Preview and deploy the Foundry resource, child project, and Application Insights connection.
3. Resolve current built-ins and preview the initiative and assignment.
4. Stage the assignment in `DoNotEnforce`, then promote to `Default` after review.
5. Record the live baseline in the customer inventory system.

Classic assets are not pulled into this boundary. Their migration backlog stays in the customer
inventory system.

</div>
<div>

![Flow from the customer repository to the Foundry baseline, operational inventory, and migration backlog](assets/diagrams/session-flow.svg)

</div>
</div>

<!-- Notes: The repository holds reusable definitions. Environment inventory and change approval stay in the customer's operating systems. -->

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

## Promotion path for the guardrails

![Azure Policy state machine from built-in resolution through staged assignment, approval, enforcement, and operation](assets/diagrams/policy-promotion.svg)

<!-- Notes: New assignments take time to propagate. A stale first policy-state query is a stop condition. Enforcement mode and observed compliance are separate facts. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Chosen approach | Tradeoff |
|---|---|---|
| Resource model | Current Foundry resource and child project | Classic assets need separate migration work |
| Desired state | Bicep and `.bicepparam` | Update the Bicep after portal changes create drift |
| Tracing authentication | Stable `ApiKey` Application Insights connection; preview `ProjectManagedIdentity` is a later upgrade decision | The baseline stays deployable, but the connection remains key-based |
| Outbound network posture | `restrictOutboundNetworkAccess: false` until Session 03 | Session 01 does not claim outbound isolation |
| Policy packaging | One initiative referencing current Microsoft built-ins | Built-in IDs and effects must be checked before each deployment |
| Assignment scope | Exact same sandbox resource group | Sibling groups and wider scopes stay outside this control |
| Enforcement rollout | `DoNotEnforce`, owner review, then `Default` | Evaluation time can delay enforcement |

<!-- Notes: Keep an existing landing-zone restriction. This session never weakens a network or policy rule to make deployment easier. -->

---

## Record ownership, cost, risk, and expiry

| Ownership and cost | Risk and lifecycle |
|---|---|
| `businessOwner` | `dataClassification` |
| `technicalOwner` | `criticality` |
| `costCenter` | `expiryDate` |
| `environment` | Plain text only; no sensitive values |

The same tag object is applied to the resource group and every taggable resource. The initiative requires `businessOwner`, `technicalOwner`, `dataClassification`, `criticality`, `costCenter`, and `expiryDate`. The `implementationSession` and fixed sandbox `environment` tags remain deployment-owned markers.

Foundry model approval and eligibility policies are separate AI-specific built-ins. Session 04 owns
that model-governance decision; they are not added to this initiative.

<!-- Notes: Use team aliases and synthetic classifications. Tags are visible to anyone with tag read access. -->

---

## Implementation path

1. **Decide** the region, network choice, ownership values, expiry, and resource model.
2. **Mark** the approved resource group with `implementationSession=01-platform-baseline`.
3. **Preflight** tools, providers, sentinels, inherited policy assignments, the approved sandbox scope, Bicep syntax, and planned changes for both layers.
4. **Deploy** the Foundry parent, project, workspace, Application Insights, and connection.
5. **Resolve** the current built-ins, then deploy the initiative and stage the assignment in `DoNotEnforce`.
6. **Review** live Policy Insights findings, then promote to `Default` after change-authority approval.
7. **Confirm** the deployment preview and the live assignment state.
8. **Operate** live inventory, the migration backlog, and policy exemptions through the customer systems.

---

<!-- _class: implementation -->

## Deploy the baseline and guardrails

**Timebox:** 250 minutes

Deploy a production-shaped Foundry baseline, then stage Azure Policy guardrails on the same resource group.

- **State change:** current Foundry parent, child project, observability connection, subscription initiative, and resource-group assignment
- **Operator access:** Contributor on the approved sandbox scope, plus a time-bound Resource Policy Contributor assignment for the guardrails
- **Safety boundary:** resolved decisions, approved sandbox subscription and resource group, and marked removal scope
- **Data rule:** no secrets or customer content in parameters, tags, outputs, or source control
- **Live state:** deployed baseline, staged-then-promoted policy assignment, reusable definitions, and customer-system records

---

## Stop before the change when

- any `__REQUIRED_*__` value remains;
- Azure CLI is not using the approved sandbox subscription or approved sandbox resource group;
- the resource-group marker is missing or belongs to another implementation;
- inherited policy effects and exemptions have not been reviewed by the cloud platform owner;
- a resolved built-in is deprecated, changed effect, or no longer matches the expected parameters;
- provider registration or public access would bypass the customer's change rules; or
- a preview includes anything outside the documented baseline or guardrail scope.

The stable Application Insights connection uses `ApiKey`; Bicep resolves its connection string without exposing it as a parameter or output. Preview `ProjectManagedIdentity` trace ingestion is a later upgrade decision. Keep `DoNotEnforce` until the cloud platform owner has reviewed live Policy Insights findings and the change authority has approved `Default`.

<!-- Notes: These are the consequential gates. Routine steps do not need a checkpoint. -->

---

## Confirm the result

Rerun the preflight and inspect its final deployment previews, then inspect the live policy assignment:

```powershell
.\scripts\preflight.ps1 `
  -ResourceGroupName $resourceGroup `
  -DeploymentName "rvas-s01-baseline" `
  -DeploymentLocation $location `
  -ConfirmInheritedPolicyReview
```

**Expected:** no unintended change to the Foundry baseline, and a `Default`-enforcement assignment with the approved locations, tags, and session marker.

The project `AppInsights` connection may appear as `Modify` or `Deploy` because its credential is write-only. Treat only that connection as expected platform noise. A `DoNotEnforce` assignment means the guardrail rollout is incomplete.

<!-- Notes: Observe both live states with the team. Neither check needs a saved output file. -->

---

## What remains after implementation

| Operational item | Location | Owner |
|---|---|---|
| Foundry resource, project, workspace, Application Insights, and connection | Approved sandbox resource group | Platform owner |
| Subscription initiative and sandbox policy assignment | Same sandbox scope | Cloud platform owner |
| Bicep, parameters, preflight, and guarded removal guidance | Customer-owned repository | Platform engineering |
| Live resource inventory and any migration backlog | Customer operational system | Platform operations |
| Policy Insights findings, exemptions, and change approval | Customer change and risk system | Cloud platform owner and change authority |

The `expiryDate` tells the owner when to keep or remove the sandbox baseline. If enforcement causes an operational problem, first redeploy the assignment with `DoNotEnforce`.

<!-- Notes: Keep the baseline and guardrails for Session 02 unless the customer chooses the guarded removal path. -->

---

## Recap and next dependency

- Session 01 leaves a rebuildable current-model Foundry boundary with staged, reviewed policy guardrails.
- Identity, tags, the observability connection, and the required-tag policy are defined in source.
- Operations receives the baseline and inventory; the change authority owns the enforcement decision.
- [Session 02](../02-identity-privileged-access/) gives people and workloads narrow, time-bound identities inside this same boundary.

---

<!-- _class: closing -->

# Thank you!
