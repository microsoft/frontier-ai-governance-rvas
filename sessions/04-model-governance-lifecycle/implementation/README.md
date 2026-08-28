# Model governance, data residency, quota, and lifecycle

## Session scope

### What we will do

Deploy **exact approved serverless API model versions through a versioned path** that
meets the workload's processing-location requirement. Under the existing `AIServices` Microsoft
Foundry resource in the approved nonproduction resource group, define desired deployment state,
check it against current Azure availability, lifecycle, quota, and scope, then create or update
the listed child deployments. This session owns the versioned deployment profiles and live child
deployments that match the approved model coordinates, SKU, capacity, content filter reference,
fixed no-auto-upgrade setting, and approval ID.

### Why it matters

The selected model version and deployment type determine processing location, quota use, and
lifecycle exposure. Preflight joins customer approval to current Azure state before deployment,
giving the lifecycle owner a repeatable change path without copying volatile service facts into the
repository.

### Boundaries

Azure is authoritative for live availability, quota, lifecycle data, and deployed resource state.
The customer decision system owns supporting approval detail. The repository owns the deployment
profiles and Bicep desired state.

Use this implementation for one deployment path. A principal with access can still create a deployment
through another template, the portal, the CLI, or an API. Detecting or blocking those changes needs
a separate control. Instant-access models and managed-compute deployments are outside scope. The
Foundry account, projects, connections, private networking, content filter definitions, and model
evaluation stay unchanged.
[Session 10](../../10-foundry-evaluations-quality-gates/implementation/README.md) adds repeatable
release evaluation.

Azure Policy can complement this path by denying disallowed deployment SKUs across other change
paths. The documented
[deployment-type restriction pattern](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types#restrict-deployment-types-with-azure-policy)
is a separate platform control; this session does not assign it.

## Architecture

### Architecture at a glance

This design connects one business approval to one model deployment in Azure. The customer decision
system keeps the full review. The repository carries the smaller set of deployment choices needed
to apply that decision. Before anything changes, preflight compares those choices with current
Azure facts and a scoped Azure Resource Manager preview. It stops the run if they do not agree.
Bicep can then create or update the child deployment under the existing Foundry resource.

The responsibilities follow the change. The decision system authorizes the model, the repository
describes the intended deployment, and preflight guards the approved path. Azure holds the live
state. Model traffic stays in Azure because this path moves configuration, not prompts or
responses. Session 05 receives the approved deployment name and exact model coordinates.

![The approved deployment profile passes through live Azure checks before Bicep changes model child deployments; lifecycle review can keep, replace, or retire them](../assets/diagrams/model-governance-flow.svg)

The boundary follows this repository path from recorded intent through preflight and Bicep. Portal,
CLI, API, or template changes made elsewhere bypass it. Each change through this path is easy to preview and
restore, but the path is not a platform-enforced allowlist.

`deployment-profiles.json` records the external approval reference, model version, SKU, capacity,
content filter, processing-location requirement, review date, quota headroom, and
`NoAutoUpgrade` setting. The customer change system remains authoritative for the full approval,
named lifecycle owner, and review history.

### Design choices and tradeoffs

| Decision | Chosen approach | Why this shape works | Tradeoff | Revisit when |
|---|---|---|---|---|
| Where approval lives | Keep the full review in the customer decision system and a compact deployment record in Git | The deployment inputs remain readable without copying the review into a second system | The approval ID and deployment names must match in both places | The decision system can provide a stable machine contract directly |
| Where service facts come from | Read availability, lifecycle, quota, and the named Responsible AI policy from Azure during preflight | The gate uses the platform state that exists when the operator runs it | If the CLI omits lifecycle or quota data, the named manual check must finish before work continues | Microsoft exposes stable lifecycle and quota fields for every selected model |
| How versions move | Pin exact model coordinates with `NoAutoUpgrade` | Every version change returns to the approval path | The owner must start manual retirement work before support ends | The owner approves a tested automatic-upgrade policy |
| What the path enforces | Use this versioned path to deploy approved model versions | Operators get a defined preview, owner, and restore boundary | Other authorized paths can still create deployments | The platform owner adds preventive policy or removes alternate change rights |

### Architecture guidance

- [Understanding deployment types in Microsoft Foundry Models](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types) explains how the chosen SKU affects processing location and capacity.
- [Deploy models using Azure CLI and Bicep](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/create-model-deployments) defines the supported deployment fields and change path used here.
- [Foundry Models lifecycle and support policy](https://learn.microsoft.com/en-us/azure/foundry/openai/concepts/model-retirements) guides review timing, replacement, and retirement.

## Before you start

Confirm these prerequisites:

- Sessions 01-02 are complete in the approved nonproduction subscription and resource group.
- Azure CLI is installed, signed in to the approved subscription, and can build Bicep.
- The existing Microsoft Foundry resource has Azure resource kind `AIServices`.
- The deployment operator has a time-bound **Cognitive Services Contributor** assignment on that
  exact Foundry resource. Record the operator's Entra object ID for preflight.
- The customer's normal decision process has approved the exact model coordinates, workload
  purpose, processing-location requirement, and external decision reference.
- The platform owner can read model availability and subscription quota.

The customer can compare models and keep detailed terms, privacy, security, evaluation, and
procurement records in its normal systems. Session 04 keeps the deployment inputs needed to
control one change path.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/infra/models/main.bicep`](artifacts/infra/models/main.bicep) | The Azure deployment pipeline operated by the Foundry platform team |
| Deployment | [`artifacts/environments/sandbox.bicepparam`](artifacts/environments/sandbox.bicepparam) | The Azure deployment pipeline operated by the Foundry platform team |
| Deployment | [`artifacts/models/deployment-profiles.json`](artifacts/models/deployment-profiles.json) | The Session 04 Bicep entrypoint and preflight scripts |

### Official documentation

Compare the selected option with Microsoft’s [Foundry model deployment types](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types)
before approving its processing location, capacity model, and operating boundary.

### Set the runtime scope

Use real Azure identifiers only in the current shell and command arguments.

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$resourceGroup = "approved-session-04-resource-group"
$foundryAccount = "approved-existing-foundry-resource"
$operatorObjectId = "00000000-0000-0000-0000-000000000000"
```

```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:-}"
resource_group="approved-session-04-resource-group"
foundry_account="approved-existing-foundry-resource"
operator_object_id="00000000-0000-0000-0000-000000000000"
```

Inspect the account before editing the implementation files:

```powershell
az cognitiveservices account show `
  --name $foundryAccount `
  --resource-group $resourceGroup `
  --query "{id:id,kind:kind,location:location}" `
  --output table
```

```bash
az cognitiveservices account show \
  --name "$foundry_account" \
  --resource-group "$resource_group" \
  --query '{id:id,kind:kind,location:location}' \
  --output table
```

The resource ID must point to the approved subscription and resource group. `kind` must read
`AIServices`.

## Decisions and stop conditions

**Resolve every `__REQUIRED_*__` value** in the customer working copy. Preflight rejects unresolved
values.

### Deployment desired state

`deployment-profiles.json` is the machine contract sent to ARM and checked by preflight. Each
deployment carries its external approval reference, exact model coordinates, SKU and capacity,
content filter policy name, processing-location requirement, review date, quota headroom, and
`versionUpgradeOption: NoAutoUpgrade`.
Replace the entire quoted `capacity` and `minimumUnusedQuotaPercent` placeholders, including their
quotation marks, with positive JSON integers. Quoted numbers fail both preflight scripts.

Do not add live quota, current availability, lifecycle status, published retirement dates, or
deployed capacity to this file. Azure already owns those values. Keep the full approval, lifecycle
owner, and review history in the customer change system.

This control approves exact model coordinates. Automatic deployment moves to a different version
are outside this path. A lifecycle-driven replacement or version change starts with a new external
decision, then updates the deployment profile through the same preflight and what-if path.

Choose a serverless API deployment SKU that meets the recorded processing-location requirement:

| Requirement | Supported SKU family in this path |
|---|---|
| Global processing | `GlobalStandard`, `GlobalProvisionedManaged`, or `GlobalBatch` |
| Data-zone processing | `DataZoneStandard`, `DataZoneProvisionedManaged`, or `DataZoneBatch` |
| Regional processing | `Standard` or `ProvisionedManaged`, where the exact model supports it |

The valid data-zone values are `us`, `eu`, and `apac`, matching Microsoft's US, EU, and Asia
Pacific data zones. `DeveloperTier` is excluded because it is for fine-tuned model evaluation,
expires after 24 hours, has no SLA, and does not provide a data-residency guarantee.

Stop when the SKU behavior does not meet the approved requirement, the review date has passed, or
`versionUpgradeOption` is not `NoAutoUpgrade`.

### Live checks and manual gates

Preflight checks **Cognitive Services Contributor** for the supplied operator object ID at the
exact Foundry resource scope. It then uses `az cognitiveservices account list-models` to match the
model, SKU, capacity bounds, lifecycle state, and published deprecation fields returned by Azure.
For every `raiPolicyName`, it uses the stable `Microsoft.CognitiveServices/accounts/raiPolicies`
2026-05-01 resource API to stop unless that policy exists under the exact Foundry resource.

For quota, the script uses the SKU's live `usageName` and an exact metric from
`az cognitiveservices usage list`. Existing capacity receives credit only when the live deployment
with the same name resolves to the same quota `usageName`. A different model or SKU mapping gets no
credit, so preflight counts the full requested capacity.

For `region:<azure-region>`, preflight requires the suffix to equal the existing Foundry account
location. A `data-zone:us`, `data-zone:eu`, or `data-zone:apac` requirement still requires a
DataZone SKU. Azure CLI does not expose a stable region-to-data-zone mapping, so the operator must
compare the reported account location with Microsoft's current data-zone region list and use the
explicit data-zone confirmation switch.

Some catalog entries do not return `lifecycleStatus` or a quota `usageName`. Permissions can also
block the quota call. The script stops in those cases. Check the current model details, retirement
notice, and Foundry **Quota** page. Then rerun with `-ConfirmManualLifecycle` or
`-ConfirmManualQuota` in PowerShell, or the matching Bash flags. Data-zone deployments use
`-ConfirmManualDataZone` or `--confirm-manual-data-zone` after the location check. These switches
record an operator confirmation for that run. They do not claim that the CLI validated missing
data.

Stop if a live model is Deprecating, Deprecated, or Retired; a SKU has reached deprecation; the
review date reaches or follows a published deprecation date; capacity breaks the live bounds; or
projected quota falls below the approved headroom policy.

## Implement

### 1. Complete the deployment profile

Add each approved deployment to `deployment-profiles.json` after its normal change approval is
complete. Follow Microsoft’s [Azure CLI and Bicep model deployment
guide](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/create-model-deployments)
when checking the supported deployment properties.

Set the existing Foundry resource name in `sandbox.bicepparam`.

### 2. Run preflight

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroup `
  -FoundryAccountName $foundryAccount `
  -OperatorObjectId $operatorObjectId
```

```bash
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --resource-group-name "$resource_group" \
  --foundry-account-name "$foundry_account" \
  --operator-object-id "$operator_object_id"
```

When Azure omits lifecycle or quota data, or the approval uses a data-zone requirement, complete
the manual check listed by preflight and add only the needed confirmation switch:

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroup `
  -FoundryAccountName $foundryAccount `
  -OperatorObjectId $operatorObjectId `
  -ConfirmManualDataZone `
  -ConfirmManualLifecycle `
  -ConfirmManualQuota
```

```bash
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --resource-group-name "$resource_group" \
  --foundry-account-name "$foundry_account" \
  --operator-object-id "$operator_object_id" \
  --confirm-manual-data-zone \
  --confirm-manual-lifecycle \
  --confirm-manual-quota
```

Preflight verifies every named Responsible AI policy before building the Bicep and requesting
`FullResourcePayloads` what-if output. It permits only Create, Modify, or NoChange for child
resource IDs listed in `deployment-profiles.json`. It rejects Ignore, Delete, Unsupported, and
changes to unrelated resources.

### 3. Deploy

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name rvas-s04-approved-models `
  --template-file .\artifacts\infra\models\main.bicep `
  --parameters .\artifacts\environments\sandbox.bicepparam `
  --only-show-errors
```

```bash
az deployment group create \
  --resource-group "$resource_group" \
  --name rvas-s04-approved-models \
  --template-file ./artifacts/infra/models/main.bicep \
  --parameters ./artifacts/environments/sandbox.bicepparam \
  --only-show-errors
```

The template creates or updates only the listed child deployments under the existing Foundry
resource.

## Confirm the result

For each approved profile, inspect the **matching live child deployment**:

```powershell
$profiles = Get-Content .\artifacts\models\deployment-profiles.json -Raw | ConvertFrom-Json
foreach ($profile in $profiles.deployments) {
  az cognitiveservices account deployment show `
    --name $foundryAccount `
    --resource-group $resourceGroup `
    --deployment-name $profile.deploymentName `
    --query "{state:properties.provisioningState,model:properties.model,sku:sku,approvalId:tags.modelApprovalId}" `
    --output json
}
```

```bash
python3 - "$foundry_account" "$resource_group" <<'PY'
import json
import subprocess
import sys

with open("./artifacts/models/deployment-profiles.json", encoding="utf-8") as handle:
    profiles = json.load(handle)["deployments"]

for profile in profiles:
    subprocess.run([
        "az", "cognitiveservices", "account", "deployment", "show",
        "--name", sys.argv[1],
        "--resource-group", sys.argv[2],
        "--deployment-name", profile["deploymentName"],
        "--query", "{state:properties.provisioningState,model:properties.model,sku:sku,approvalId:tags.modelApprovalId}",
        "--output", "json",
        "--only-show-errors",
    ], check=True)
PY
```

Expected result: every child deployment reports `Succeeded`. Its exact model coordinates, SKU,
capacity, and `modelApprovalId` match `deployment-profiles.json`.

## After implementation

Keep the **versioned deployment definitions**: the Bicep and parameter file, deployment profiles,
artifact index, and paired scripts. The platform owner owns live capacity and deployment changes.
The customer change process owns the named lifecycle owner, review history, replacement work, and
supporting approval detail.

Use this path to deploy versioned models. Deployments created elsewhere need
a separate Azure Policy, deployment permission, inventory, or change-control design. The
[Azure Policy deployment-type pattern](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types#restrict-deployment-types-with-azure-policy)
can deny selected SKU names across those paths. Instant-access and managed-compute models still
need their own controls.

If a model deployment must be removed, the workload and platform owners first confirm that no
consumer depends on it. Use the approved Foundry or Azure deployment path to remove one selected
Session 04 deployment at a time. Check for the
`implementationSession=04-model-governance-lifecycle` tag and leave every other resource in place.
