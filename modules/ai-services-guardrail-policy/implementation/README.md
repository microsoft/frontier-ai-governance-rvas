# Implement Azure Policy guardrails for Microsoft Foundry AI services

## Module scope

### What we will do

**Objective.** Deploy one staged Azure Policy initiative for Microsoft Foundry and Azure AI services resources.

The module creates a custom deployment-SKU policy, groups it with verified built-ins, assigns the
initiative to the approved scope in `DoNotEnforce`, and checks policy states by reference ID. After
owner review, the same assignment can move selected references to `Deny` or `DeployIfNotExists`.

### Why it matters

**Problem.** Teams can harden one resource and still miss the next one. Policy drift also hides
when local keys, open network settings, weak content filters, or missing diagnostics return after a
manual change.

**Solution.** One version-controlled assignment gives the platform owner a shared view before
enforcement. The first pass audits. The promotion pass changes only the approved references.

**[EU AI Act](https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng).** For high-risk AI systems, this
module supports Article 9 (risk management) with content-filter minimums, Article 12
(record-keeping) with diagnostic logs, and Article 15 (cybersecurity) with the authentication and
network guardrails. This is an engineering mapping, not legal advice.

### Boundaries

This module sits outside the numbered session sequence.

It changes Azure Policy definitions and one assignment for the approved Foundry and Azure AI
services scope. Azure Policy remains the source of live compliance state. The repository owns the
policy definitions, parameters, and decision record.

It does not replace landing-zone tags and locations from
[Session 01](../../../sessions/01-platform-baseline/implementation/README.md), private networking
from [Session 02](../../../sessions/02-private-networking-dns/implementation/README.md), model
approval from [Session 03](../../../sessions/03-model-governance-lifecycle/implementation/README.md),
or policy promotion flow from
[Session 12](../../../sessions/12-cicd-promotion-controls/implementation/README.md).

## Architecture

### Architecture at a glance

The repository deploys a subscription-scope policy initiative and assigns it to the exact approved
scope. The initiative includes five guardrail areas:

| Guardrail | Policy path | First state | Promotion path |
|---|---|---|---|
| Disable local authentication | Built-in key-access policy | `Audit` | `Deny` after Entra access is ready |
| Restrict network access | Built-in network policy | `Audit` | `Deny` after private access is ready |
| Restrict deployment SKU | Custom policy definition | `Audit` | `Deny` after data-residency review |
| Content-filter minimums | Preview built-in, one reference per harm category | `Audit` | Stays `Audit` until the built-in supports blocking |
| Diagnostic logs | Built-in Log Analytics policy | `AuditIfNotExists` | `DeployIfNotExists` after role approval |

`guardrail-decisions.json` is the module's decision record. It names the target scope, owners,
effects, Log Analytics destination, disallowed SKUs, content-filter minimums, and restore reference.

The assignment starts with `enforcementMode = DoNotEnforce`. That lets the owner review current
Policy Insights data before a blocking effect or remediation effect is enabled.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
|---|---|---|---|
| Assignment rollout | One assignment staged in `DoNotEnforce`, then promoted in place | Keeps compliance history and avoids a second assignment | The team must wait for current policy states before promotion |
| Model approval | Excluded from this module | Keeps model allow-list ownership with Session 03 | This module cannot decide which models are approved |
| Network and local auth | Built-in Audit or Deny policies | Uses Microsoft-maintained aliases and effects | Deny can block tools that still need keys or public endpoints |
| Data residency | Custom SKU policy | Makes the residency choice explicit in source control | The SKU list must be reviewed when Foundry adds deployment types |
| Diagnostic logs | Audit first, then DINE with a managed identity | Shows missing logs before remediation writes settings | The assignment identity needs the approved Log Analytics role path |

### Architecture guidance

Use [Built-in policy definitions for Foundry Tools](https://learn.microsoft.com/en-us/azure/ai-services/policy-reference)
for the current Microsoft-maintained policy names and effects.

Use [Details of the policy assignment structure](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/assignment-structure)
for assignment `scope`, parameters, identity, non-compliance messages, and `enforcementMode`.

Use [Bicep What-If](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if)
to preview the initiative and assignment before deployment.

## Before you start

Confirm these prerequisites:

- The approved target scope is the subscription that contains the Foundry and Azure AI services
  resources governed by this module.
- The deployment operator has time-bound **Resource Policy Contributor** on the subscription where
  the initiative and assignment are deployed.
- The operator can run subscription-scope Bicep what-if.
- A Log Analytics workspace exists, and its owner can approve the assignment identity's access
  before diagnostic remediation moves to `DeployIfNotExists`.
- The platform policy owner, compliance review owner, data-residency owner, and promotion authority
  can review current policy states together.
- The team knows which controls are owned by the related sessions named in the boundaries.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/policy/definitions/restrict-foundry-deployment-sku.json`](artifacts/policy/definitions/restrict-foundry-deployment-sku.json) | The subscription policy deployment pipeline |
| Record | [`artifacts/policy/guardrail-decisions.json`](artifacts/policy/guardrail-decisions.json) | The policy deployment pipeline, preflight scripts, and compliance review owner |
| Deployment | [`artifacts/policy/initiative.bicep`](artifacts/policy/initiative.bicep) | The subscription policy deployment pipeline |
| Deployment | [`artifacts/policy/assignment.bicep`](artifacts/policy/assignment.bicep) | The subscription policy deployment pipeline |
| Deployment | [`artifacts/environments/initiative.bicepparam`](artifacts/environments/initiative.bicepparam) | The subscription policy deployment pipeline |
| Deployment | [`artifacts/environments/assignment.bicepparam`](artifacts/environments/assignment.bicepparam) | The subscription policy deployment pipeline |

Resolve every `__REQUIRED_*__` value before running a live preview. Keep tenant IDs, subscription
IDs, policy-state exports, resource IDs beyond the approved scope, and customer data in customer
systems.

## Decisions and stop conditions

### Scope and owners

Record the exact subscription resource ID in `targetScopeResourceId`. The same value must be passed
to preflight.

Stop if the target scope is broader than the approved AI services estate, if the Azure CLI is set to
another subscription, or if any owner in `guardrail-decisions.json` is missing.

### Effects and promotion

Start with:

- `DoNotEnforce` assignment mode;
- `Audit` for local authentication, network access, deployment SKU, and content filters; and
- `AuditIfNotExists` for diagnostic logs.

Promote in place only after the compliance review owner has reviewed current policy states and the
promotion authority has approved the change record.

Stop if the team asks to create a second assignment for the same scope, skips the state review, or
moves diagnostic logs to `DeployIfNotExists` before the Log Analytics role path is approved.

### Data residency and content filters

The data-residency owner owns `disallowedDeploymentSkus`. The shipped default excludes Global
deployment SKUs. Change it only when the residency decision says so.

The content-filter built-in is a preview, audit-only policy. Use it to find deployments whose
settings miss the recorded minimums. Do not describe it as a blocking control.

### Diagnostic remediation

The diagnostic-log policy can audit first and remediate later. When it moves to
`DeployIfNotExists`, the assignment identity must have the approved Log Analytics role path for the
workspace.

Stop if the workspace owner cannot approve that path, if `categoryGroup` changes without data
owner review, or if remediation would target resources outside the approved scope.

## Implement

### 1. Complete the decision record

Edit `artifacts/policy/guardrail-decisions.json` in the approved private path. Keep the initial
effects in audit mode unless the owner has already reviewed the current policy states.

### 2. Run preflight

```powershell
$targetScope = "<approved subscription resource ID>"
$deploymentLocation = "<approved deployment location>"

.\scripts\preflight.ps1 `
  -TargetScope $targetScope `
  -DeploymentLocation $deploymentLocation
```

```bash
target_scope="<approved subscription resource ID>"
deployment_location="<approved deployment location>"

./scripts/preflight.sh \
  --target-scope "$target_scope" \
  --deployment-location "$deployment_location"
```

Preflight rejects unresolved decisions, unsupported effects, a mismatched scope, Bicep syntax
errors, and a subscription mismatch. After those checks pass, it runs two subscription-scope
what-if previews: one for the initiative and custom definition, and one for the assignment.

### 3. Deploy the initiative and staged assignment

Deploy the initiative first:

```powershell
az deployment sub create `
  --location $deploymentLocation `
  --name "optional-ai-services-guardrail-policy-initiative" `
  --template-file .\artifacts\policy\initiative.bicep `
  --parameters .\artifacts\environments\initiative.bicepparam `
  --only-show-errors
```

```bash
az deployment sub create \
  --location "$deployment_location" \
  --name "optional-ai-services-guardrail-policy-initiative" \
  --template-file ./artifacts/policy/initiative.bicep \
  --parameters ./artifacts/environments/initiative.bicepparam \
  --only-show-errors
```

Then deploy the assignment:

```powershell
az deployment sub create `
  --location $deploymentLocation `
  --name "optional-ai-services-guardrail-policy-assignment" `
  --template-file .\artifacts\policy\assignment.bicep `
  --parameters .\artifacts\environments\assignment.bicepparam `
  --only-show-errors
```

```bash
az deployment sub create \
  --location "$deployment_location" \
  --name "optional-ai-services-guardrail-policy-assignment" \
  --template-file ./artifacts/policy/assignment.bicep \
  --parameters ./artifacts/environments/assignment.bicepparam \
  --only-show-errors
```

Keep the assignment in `DoNotEnforce` until current policy states are available and reviewed.

### 4. Review current compliance by reference

```powershell
.\scripts\check-compliance.ps1 -TargetScope $targetScope
```

```bash
./scripts/check-compliance.sh --target-scope "$target_scope"
```

The script summarizes live policy states by policy definition reference. It does not export or
store live-state data in this repository.

### 5. Promote approved references

Update `guardrail-decisions.json` for the approved promotion. Common changes are:

- `enforcementMode` from `DoNotEnforce` to `Default`;
- `networkAccess`, `localAuthentication`, or `deploymentSku` from `Audit` to `Deny`; and
- `diagnosticLogs` from `AuditIfNotExists` to `DeployIfNotExists`.

Set `policyStateReviewStatus` to `Reviewed` only after the owner review. Rerun preflight and
redeploy the same assignment.

## Confirm the result

Run the compliance check after Azure Policy evaluation has produced current states. The module is
complete when the assignment exists at the approved scope, uses the recorded effects, and the
review owner can explain every non-compliant reference before promotion.

Stop if policy states are missing, stale, or show unexpected resources. Keep the assignment in
`DoNotEnforce` or audit effects until the owner explains the result.

## After implementation

| What remains | Owner |
|---|---|
| Policy initiative, custom SKU policy, assignment, and parameters | Platform policy owner |
| Current policy states and exceptions | Compliance review owner |
| Deployment SKU list and residency exceptions | Data-residency owner |
| Diagnostic workspace and remediation role path | Observability owner and Log Analytics workspace owner |
| Promotion and restore decision | Promotion authority |

Restore through the approved policy change path:

1. Change the assignment back to `DoNotEnforce` to stop blocking while keeping compliance data.
2. Change individual effects to `Audit`, `AuditIfNotExists`, or `Disabled` when the owner approves
   that narrower restore.
3. Remove the assignment only after the platform policy owner confirms no workflow uses it.
4. Remove the custom policy and initiative only after every assignment that references them is gone.

`DeployIfNotExists` remediation does not undo diagnostic settings. If diagnostic settings need to be
removed, the resource owner removes them through the resource's normal change path after checking
retention and incident needs.
