# Model governance, data residency, quota, and lifecycle

## Session scope

### What we will do

Deploy **exact approved serverless API model versions with version-controlled deployment profiles,
preflight checks, and Bicep**. Meet the workload's processing-location requirement. Under the
existing `AIServices` Microsoft Foundry resource in the approved nonproduction resource group,
define the deployment, compare it with current Azure availability, lifecycle, quota, and scope,
then create or update the listed child deployments. The deployment profiles record the approved
model coordinates, SKU, capacity, content filter reference, fixed no-auto-upgrade setting, and
approval ID. Bicep creates or updates the matching live child deployments.

### Why it matters

The model version and deployment type set the processing location, quota use, and lifecycle
exposure. Before deployment, preflight compares the approved settings with current Azure state.
The lifecycle owner can repeat this path without copying live Azure data into the repository.

### Boundaries

Azure holds the live availability, quota, lifecycle data, and deployed resource state. Keep the
supporting approval detail in the decision system. Store deployment profiles and Bicep definitions in the repository.

The deployment profiles, preflight scripts, and Bicep cover one deployment path. An authorized
principal can still create a deployment through another template, the portal, the CLI, or an API.
A separate control must detect or block those changes. Instant-access models and managed-compute
deployments require their own model governance design. Sessions 01, 03, and 11 own the Foundry
account, project, connection, private-networking, content-filter, and model-evaluation paths.
[Session 11](../../11-foundry-evaluations-quality-gates/implementation/README.md) adds repeatable
release evaluation.

Azure Policy can deny disallowed deployment SKUs across other change paths. The documented
[deployment-type restriction pattern](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types#restrict-deployment-types-with-azure-policy)
is a separate platform control owned by the cloud platform team.

## Architecture

### Architecture at a glance

One business approval maps to one Azure model deployment. The decision system keeps the full
review. `deployment-profiles.json` holds the settings Bicep needs. Before anything changes,
preflight compares them with current Azure facts and a scoped Azure Resource Manager preview. It
stops on a mismatch. Bicep then creates or updates the child deployment under the existing Foundry
resource.

The decision system authorizes the model. The deployment profile states what Bicep deploys.
Preflight blocks the run when the profile differs from the approval or current Azure state. Azure
holds the live child deployment. These steps change model deployment settings. Session 05 uses the
approved deployment name and exact model coordinates.

![The approved deployment profile passes through live Azure checks before Bicep changes model child deployments; lifecycle review can keep, replace, or retire them](../assets/diagrams/model-governance-flow.svg)

The checks run when an operator uses the deployment profiles, preflight scripts, and Bicep files.
Another template, the portal, the CLI, or an API can bypass them. Operators can preview changes
and restore an earlier deployment file. Azure does not treat these files as an allowlist.

`deployment-profiles.json` records the external approval reference, model version, SKU, capacity,
content filter, processing-location requirement, review date, quota headroom, and
`NoAutoUpgrade` setting. Keep the full approval, lifecycle owner, and review history in the change
system.

### Design choices and tradeoffs

| Decision | Chosen approach | Why this shape works | Tradeoff | Revisit when |
|---|---|---|---|---|
| Where approval lives | Keep the full review in the decision system and a compact deployment record in Git | The inputs stay readable without duplicating the review | The approval ID and deployment names must match in both places | The decision system can provide deployment inputs through a stable machine-readable interface |
| Where service facts come from | Read availability, lifecycle, quota, and the named Responsible AI policy from Azure during preflight | The gate reads the state that exists when the operator runs it | If the CLI omits lifecycle or quota data, finish the named manual check before continuing | Microsoft exposes stable lifecycle and quota fields for every selected model |
| How versions move | Pin exact model coordinates with `NoAutoUpgrade` | Every version change returns to approval | The owner must start retirement work before support ends | The owner approves a tested automatic-upgrade policy |
| What these files check | Deploy approved model versions through the version-controlled profile, preflight, and Bicep path | Operators can preview each change, identify the lifecycle owner, and restore an earlier deployment file | Other authorized methods can still create deployments | The platform owner adds preventive policy or removes alternate change rights |

### Architecture guidance

- [Understanding deployment types in Microsoft Foundry Models](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types) explains how the chosen SKU affects processing location and capacity.
- [Deploy models using Azure CLI and Bicep](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/create-model-deployments) defines the supported deployment fields and change path used here.
- [Foundry Models lifecycle and support policy](https://learn.microsoft.com/en-us/azure/foundry/openai/concepts/model-retirements) guides review timing, replacement, and retirement.

## Before you start

Confirm the following:

- Sessions 01-02 are complete in the approved nonproduction subscription and resource group.
- The existing Microsoft Foundry resource has Azure resource kind `AIServices`.
- The deployment operator has a time-bound Cognitive Services Contributor assignment on that
  exact Foundry resource.
- The normal decision process has approved the exact model coordinates, workload purpose,
  processing-location requirement, and external decision reference.
- The platform owner can read model availability and subscription quota.

Use the repository Execution environment section in README.md for client setup.

The decision system can hold detailed terms, privacy, security, evaluation, and procurement
records. `deployment-profiles.json` stores the inputs that preflight and Bicep use on this path.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/infra/models/main.bicep`](artifacts/infra/models/main.bicep) | The Azure deployment pipeline operated by the Foundry platform team |
| Deployment | [`artifacts/environments/sandbox.bicepparam`](artifacts/environments/sandbox.bicepparam) | The Azure deployment pipeline operated by the Foundry platform team |
| Deployment | [`artifacts/models/deployment-profiles.json`](artifacts/models/deployment-profiles.json) | The Session 04 Bicep entrypoint and preflight scripts |

### Official documentation

Compare the selected option with Microsoft’s [Foundry model deployment types](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types)
before approving its processing location, capacity model, and operating boundary.

## Decisions and stop conditions

**Resolve every `__REQUIRED_*__` value** in the customer working copy. Preflight rejects unresolved
values.

### Deployment profile

`deployment-profiles.json` is the machine-readable input for preflight and ARM through Bicep.
Each entry contains an external approval reference, exact model coordinates, SKU and capacity,
content filter policy name, processing-location requirement, review date, quota headroom, and
`versionUpgradeOption: NoAutoUpgrade`.
Replace the entire quoted `capacity` and `minimumUnusedQuotaPercent` placeholders, including their
quotation marks, with positive JSON integers. Quoted numbers fail both preflight scripts.

Keep live quota, current availability, lifecycle status, published retirement dates, and deployed
capacity out of this file. Preflight reads them from Azure. Keep the full approval, lifecycle
owner, and review history in the change system.

The external approval covers exact model coordinates. `NoAutoUpgrade` holds that version in place.
For a lifecycle replacement or version change, record a new external decision, update the
deployment profile, rerun preflight, and inspect the Bicep what-if output.

Choose a serverless API deployment SKU that meets the recorded processing-location requirement:

| Requirement | Supported SKU family in this path |
|---|---|
| Global processing | `GlobalStandard`, `GlobalProvisionedManaged`, or `GlobalBatch` |
| Data-zone processing | `DataZoneStandard`, `DataZoneProvisionedManaged`, or `DataZoneBatch` |
| Regional processing | `Standard` or `ProvisionedManaged`, where the exact model supports it |

The valid data-zone values are `us`, `eu`, and `apac`, matching Microsoft's US, EU, and Asia
Pacific data zones. `DeveloperTier` is excluded. It supports fine-tuned model evaluation, expires
after 24 hours, has no SLA, and does not provide a data-residency guarantee.

Stop when the SKU behavior does not meet the approved requirement, the review date has passed, or
`versionUpgradeOption` is not `NoAutoUpgrade`.

### Live checks and manual gates

Preflight checks Cognitive Services Contributor for the supplied operator object ID at the
exact Foundry resource scope. It then uses `az cognitiveservices account list-models` to match the
model, SKU, capacity bounds, lifecycle state, and published deprecation fields returned by Azure.
For every `raiPolicyName`, it uses the stable `Microsoft.CognitiveServices/accounts/raiPolicies`
2026-05-01 resource API to stop unless that policy exists under the exact Foundry resource.

For quota, the script uses the SKU's live `usageName` and an exact metric from
`az cognitiveservices usage list`. Existing capacity receives credit when the live deployment with
the same name resolves to the same quota `usageName`. A different model or SKU mapping receives no
credit, so preflight counts the full requested capacity.

For `region:<azure-region>`, preflight requires the suffix to equal the existing Foundry account
location. A `data-zone:us`, `data-zone:eu`, or `data-zone:apac` requirement still requires a
DataZone SKU. Azure CLI does not expose a stable region-to-data-zone mapping. The operator compares
the reported account location with Microsoft's current data-zone region list, then uses the
explicit data-zone confirmation switch.

Some catalog entries do not return `lifecycleStatus` or a quota `usageName`. Permissions can also
block the quota call. The script stops in either case. Check the current model details, retirement
notice, and Foundry Quota page. Then rerun with `-ConfirmManualLifecycle` or
`-ConfirmManualQuota` in PowerShell, or the matching Bash flags. Data-zone deployments use
`-ConfirmManualDataZone` or `--confirm-manual-data-zone` after the location check. These switches
record an operator confirmation for that run. They do not claim that the CLI validated missing data.

Stop if a live model is Deprecating, Deprecated, or Retired; a SKU has reached deprecation; the
review date reaches or follows a published deprecation date; capacity breaks the live bounds; or
projected quota falls below the approved headroom policy.

## Implement

### 1. Complete the deployment profile

Add each approved deployment to `deployment-profiles.json` after normal change approval. Follow
Microsoft’s [Azure CLI and Bicep model deployment
guide](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/create-model-deployments)
when checking the supported deployment properties.

Set the existing Foundry resource name in `sandbox.bicepparam`.

### 2. Run preflight

Use real Azure identifiers in the current shell and command arguments. Set the preflight inputs,
including the deployment operator's Entra object ID:

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

Inspect the account before preflight:

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
the manual check that preflight names. Add the needed confirmation switch:

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
`FullResourcePayloads` what-if output. It permits Create, Modify, or NoChange for child resource
IDs in `deployment-profiles.json`. It rejects Ignore, Delete, Unsupported, and unrelated resource
changes.

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

The template creates or updates the listed child deployments under the existing Foundry resource.

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

Keep the versioned deployment definitions: the Bicep and parameter file, deployment profiles,
artifact index, and paired scripts. The platform owner manages live capacity and deployment
changes. Keep the lifecycle owner, review history, replacement work, and supporting approval
detail in the change system.

Use this path to deploy versioned models. Deployments created elsewhere need a separate Azure
Policy, deployment-permission, inventory, or change-control design. The
[Azure Policy deployment-type pattern](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types#restrict-deployment-types-with-azure-policy)
can deny selected SKU names across those paths. Instant-access and managed-compute models still
need their own controls.

If a model deployment must be removed, the workload and platform owners first confirm that no
consumer uses it. Use the approved Foundry or Azure deployment path to remove one selected Session
04 deployment at a time. Check for the `implementationSession=04-model-governance-lifecycle` tag.
Leave every other resource in place.
