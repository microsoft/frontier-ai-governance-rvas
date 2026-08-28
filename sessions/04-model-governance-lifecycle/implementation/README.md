# Model governance, data residency, quota, and lifecycle

## Session scope

### What we will do

Deploy **exact approved serverless API model versions by using version-controlled deployment
profiles, preflight checks, and Bicep** while meeting the workload's processing-location
requirement. Under the existing `AIServices` Microsoft Foundry resource in the approved
nonproduction resource group, define desired deployment state, check it against current Azure
availability, lifecycle, quota, and scope, then create or update the listed child deployments. The
deployment profiles record the approved model coordinates, SKU, capacity, content filter reference,
fixed no-auto-upgrade setting, and approval ID. Bicep creates or updates the matching live child
deployments.

### Why it matters

The selected model version and deployment type determine processing location, quota use, and
lifecycle exposure. Before deployment, preflight compares the approved deployment settings with
current Azure state. The lifecycle owner can repeat these steps without copying live Azure service
data into the repository.

### Boundaries

Read live availability, quota, lifecycle data, and deployed resource state from Azure. Keep
supporting approval detail in the customer decision system. Store the deployment profiles and
Bicep configuration in the repository.

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
system keeps the full review. `deployment-profiles.json` contains the deployment settings needed to
apply that decision. Before anything changes, preflight compares those settings with current Azure
facts and a scoped Azure Resource Manager preview. It stops the run if they do not agree. Bicep can
then create or update the child deployment under the existing Foundry resource.

The decision system records authorization for the model. The deployment profile describes what
Bicep will deploy, and preflight blocks the deployment when that profile does not match the approval
or current Azure state. Azure stores the live resource state. These deployment steps change
configuration only; they do not transmit prompts or responses. Session 05 uses the approved
deployment name and exact model coordinates.

![The approved deployment profile passes through live Azure checks before Bicep changes model child deployments; lifecycle review can keep, replace, or retire them](../assets/diagrams/model-governance-flow.svg)

These checks apply only when an operator uses these deployment profiles, preflight scripts, and
Bicep files. Changes made through another template, the portal, the CLI, or an API bypass them.
Operators can preview changes and restore an earlier version of the deployment files, but Azure
does not enforce these files as an allowlist.

`deployment-profiles.json` records the external approval reference, model version, SKU, capacity,
content filter, processing-location requirement, review date, quota headroom, and
`NoAutoUpgrade` setting. Keep the full approval, named lifecycle owner, and review history in the
customer change system.

### Design choices and tradeoffs

| Decision | Chosen approach | Why this shape works | Tradeoff | Revisit when |
|---|---|---|---|---|
| Where approval lives | Keep the full review in the customer decision system and a compact deployment record in Git | The deployment inputs remain readable without copying the review into a second system | The approval ID and deployment names must match in both places | The decision system can provide the deployment inputs through a stable machine-readable interface |
| Where service facts come from | Read availability, lifecycle, quota, and the named Responsible AI policy from Azure during preflight | The gate uses the platform state that exists when the operator runs it | If the CLI omits lifecycle or quota data, the named manual check must finish before work continues | Microsoft exposes stable lifecycle and quota fields for every selected model |
| How versions move | Pin exact model coordinates with `NoAutoUpgrade` | Every version change returns to the approval path | The owner must start manual retirement work before support ends | The owner approves a tested automatic-upgrade policy |
| What these files check | Use the version-controlled deployment profiles, preflight scripts, and Bicep to deploy approved model versions | Operators can preview each change, identify the lifecycle owner, and restore an earlier version of the deployment files | Other authorized methods can still create deployments | The platform owner adds preventive policy or removes alternate change rights |

### Architecture guidance

- [Understanding deployment types in Microsoft Foundry Models](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types) explains how the chosen SKU affects processing location and capacity.
- [Deploy models using Azure CLI and Bicep](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/create-model-deployments) defines the supported deployment fields and change path used here.
- [Foundry Models lifecycle and support policy](https://learn.microsoft.com/en-us/azure/foundry/openai/concepts/model-retirements) guides review timing, replacement, and retirement.

## Before you start

Confirm these prerequisites:

- Sessions 01-02 are complete in the approved nonproduction subscription and resource group.
- The existing Microsoft Foundry resource has Azure resource kind `AIServices`.
- The deployment operator has a time-bound **Cognitive Services Contributor** assignment on that
  exact Foundry resource.
- The customer's normal decision process has approved the exact model coordinates, workload
  purpose, processing-location requirement, and external decision reference.
- The platform owner can read model availability and subscription quota.

Use the repository Execution environment section in README.md for client setup.

The customer can compare models and keep detailed terms, privacy, security, evaluation, and
procurement records in its normal systems. `deployment-profiles.json` stores the inputs that
preflight and Bicep use for deployments made with this implementation.

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

### Deployment desired state

`deployment-profiles.json` is the machine-readable input checked by preflight and supplied to ARM
through Bicep. Each entry contains its external approval reference, exact model coordinates, SKU
and capacity, content filter policy name, processing-location requirement, review date, quota
headroom, and `versionUpgradeOption: NoAutoUpgrade`.
Replace the entire quoted `capacity` and `minimumUnusedQuotaPercent` placeholders, including their
quotation marks, with positive JSON integers. Quoted numbers fail both preflight scripts.

Do not add live quota, current availability, lifecycle status, published retirement dates, or
deployed capacity to this file. Read those current values from Azure during preflight. Keep the
full approval, lifecycle owner, and review history in the customer change system.

The external approval covers exact model coordinates. This implementation does not allow automatic
deployment upgrades to another version. For a lifecycle-driven replacement or version change,
record a new external decision, update the deployment profile, rerun preflight, and inspect the
Bicep what-if output.

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

Use real Azure identifiers only in the current shell and command arguments. Set the preflight
inputs, including the deployment operator's Entra object ID:

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
artifact index, and paired scripts. The platform owner manages live capacity and deployment
changes. Record the named lifecycle owner, review history, replacement work, and supporting
approval detail in the customer change system.

Use this path to deploy versioned models. Deployments created elsewhere need
a separate Azure Policy, deployment permission, inventory, or change-control design. The
[Azure Policy deployment-type pattern](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types#restrict-deployment-types-with-azure-policy)
can deny selected SKU names across those paths. Instant-access and managed-compute models still
need their own controls.

If a model deployment must be removed, the workload and platform owners first confirm that no
consumer depends on it. Use the approved Foundry or Azure deployment path to remove one selected
Session 04 deployment at a time. Check for the
`implementationSession=04-model-governance-lifecycle` tag and leave every other resource in place.
