# Model governance, data residency, quota, and lifecycle

## Session scope

### What we will do

**Objective.** Record approved models, deploy their exact serverless API versions, and apply the
matching built-in deployment policies. Version-controlled profiles and the approval register hold
the inputs. Preflight compares them with current Azure state and scoped Bicep previews.

The observable result is a live deployment whose model coordinates, SKU, capacity, and approval
tag match the approved profile.

### Why it matters

**Problem.** An unreviewed model version or deployment type can move data to the wrong processing location, burn
quota, or expose the workload to retirement without warning.

**Solution.** This session checks those choices against live Azure state before deployment. It then
uses the approval register to assign Azure Policy controls for approved models and model eligibility.

### Boundaries

Azure is authoritative for availability, quota, lifecycle data, and live deployment state. The
customer decision system holds the full approval and review history. This repository owns the
deployment profile and Bicep definition.

The deployment profile governs this Bicep path. The built-in Azure Policy assignments evaluate
model deployments at the approved resource group. The policy owner reviews Audit findings before
moving the assignments to Deny.

This session excludes instant-access and managed-compute models. Sessions 01-02 establish the
Foundry baseline and private path. Session 09 owns release evaluation.

## Architecture

### Architecture at a glance

One external approval maps to one Azure child deployment. `deployment-profiles.json` carries the
settings needed by preflight and Bicep. Preflight checks the exact Foundry scope, operator role,
model availability and lifecycle, Responsible AI policy, processing location, quota, and
resource-scoped what-if. A mismatch stops the run.

![An approved model choice moves through preflight, deployment, review, and a keep, replace, or retire decision.](../assets/diagrams/model-governance-flow.svg)

The deployment profile pins the model version with `NoAutoUpgrade`. Session 04 consumes the
approved deployment name and model coordinates.

The approval register records the approved publisher, asset ID, source, hosting route, review
decision, and processing-location boundary. The policy parameter file reads its allowed values,
so the policy assignment and approval decision stay aligned.

### Design choices and tradeoffs

| Decision | Chosen approach | Cost or limit |
|---|---|---|
| Approval record | Keep the full review in the decision system and deployment inputs in Git | The approval ID must match both systems |
| Service facts | Read lifecycle, availability, quota, and the named Responsible AI policy during preflight | Missing CLI fields require a named manual check |
| Version changes | Pin exact coordinates with `NoAutoUpgrade` | The owner must start replacement before retirement |
| Deployment policy | Assign the built-in approved-model and eligibility policies from the approval register | Audit needs review before Deny blocks a deployment |
| Control reach | Govern this version-controlled deployment path | Other authorized paths remain open |

### Architecture guidance

- [Understanding deployment types in Microsoft Foundry Models](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types)
- [Deploy models using Azure CLI and Bicep](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/create-model-deployments)
- [Foundry Models lifecycle and support policy](https://learn.microsoft.com/en-us/azure/foundry/openai/concepts/model-retirements)

## Before you start

Confirm:

- An `AIServices` Microsoft Foundry resource and project exist in the approved nonproduction
  subscription and resource group. The platform owner confirms the resource and project names, and the approved
  execution host reaches the project through the recorded private path. (Sessions 01-02.)
- The operator has time-bound **Cognitive Services Contributor** on that exact resource.
- The model decision authority approved the exact model coordinates, workload purpose,
  processing-location requirement, and external decision reference through the customer
  model-change process.
- The platform owner can read model availability and subscription quota.
- The named Responsible AI policy exists under the exact Foundry resource.
- The policy operator holds **Owner** or **Resource Policy Contributor** on the approved resource
  group, and the reviewers can read the selected model card in the Foundry model catalog.

Do not store subscription IDs, endpoints, customer data, prompts, responses, or full approval
records in the repository.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/infra/models/main.bicep`](artifacts/infra/models/main.bicep) | The Azure deployment pipeline operated by the Foundry platform team |
| Deployment | [`artifacts/environments/sandbox.bicepparam`](artifacts/environments/sandbox.bicepparam) | The Azure deployment pipeline operated by the Foundry platform team |
| Deployment | [`artifacts/models/deployment-profiles.json`](artifacts/models/deployment-profiles.json) | The Session 03 Bicep entrypoint and preflight scripts |
| Record | [`artifacts/model-approval-register.json`](artifacts/model-approval-register.json) | The model reviewers, policy owner, and policy parameter file |
| Deployment | [`artifacts/policy/model-governance.bicep`](artifacts/policy/model-governance.bicep) | The platform deployment pipeline |
| Deployment | [`artifacts/policy/model-governance.bicepparam`](artifacts/policy/model-governance.bicepparam) | The platform deployment pipeline |

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value. Replace the quoted `capacity` and
`minimumUnusedQuotaPercent` placeholders, including their quotation marks, with JSON integers.

For each deployment, record:

- the external approval ID and exact model name, version, and format;
- deployment name, SKU, capacity, and named Responsible AI policy;
- `global`, `data-zone:us`, `data-zone:eu`, `data-zone:apac`, or
  `region:<azure-region>` processing;
- review date and minimum unused quota percentage.

Keep `versionUpgradeOption: NoAutoUpgrade`. A version change needs a new external decision and an
updated profile.

| Processing requirement | Supported SKU family in this path |
|---|---|
| Global | `GlobalStandard`, `GlobalProvisionedManaged`, `GlobalBatch` |
| US, EU, or APAC data zone | `DataZoneStandard`, `DataZoneProvisionedManaged`, `DataZoneBatch` |
| Regional | `Standard`, `ProvisionedManaged`, where the model supports it |

`DeveloperTier` is excluded. It expires after 24 hours, has no SLA, and gives no data-residency
guarantee.

Stop when the scope or operator role is wrong; the model is `Deprecating`, `Deprecated`, or
`Retired`; the SKU has reached deprecation; or the review date reaches or follows a published
deprecation date. Also stop when processing location does not match the SKU, capacity exceeds live
bounds, projected unused quota falls below the approved percentage, the Responsible AI policy is
missing, or what-if contains an unrelated resource, deletion, unsupported change, or unresolved
value. Preflight maps quota through the SKU's live `usageName` and credits existing capacity only
when the current deployment resolves to that same metric.

Azure may omit `lifecycleStatus`, quota `usageName`, or stable data-zone membership. Preflight stops
and names the required Microsoft source or Foundry Quota check. Complete that check, then rerun with
the matching PowerShell switch or Bash flag:

| Manual check | PowerShell | Bash |
|---|---|---|
| Data-zone membership | `-ConfirmManualDataZone` | `--confirm-manual-data-zone` |
| Lifecycle | `-ConfirmManualLifecycle` | `--confirm-manual-lifecycle` |
| Quota | `-ConfirmManualQuota` | `--confirm-manual-quota` |

These switches record the operator's check for that run. They do not turn missing CLI data into an
Azure-validated result.

### Approval register and policy

Complete one approval-register entry for each model before assigning policy. Use an asset ID ending
in a trailing slash to approve a model family, or an explicit version to approve one version.
Preflight rejects an asset ID that could match a successor version.

Deploy the two built-in policies in `Audit`, review the owners of noncompliant deployments, then
move to `Deny` through the approved change path. Keep `onlyAllowDirectFromAzure` and
`denyPreviewModels` set to `true` unless the decision authority records an exception.

## Implement

### 1. Complete the inputs

Add every approved deployment to `artifacts/models/deployment-profiles.json`. Set the existing
Foundry resource name in `artifacts/environments/sandbox.bicepparam`.

### 2. Run preflight

Set the approved scope and operator identity:

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$resourceGroup = "approved-session-03-resource-group"
$foundryAccount = "approved-existing-foundry-resource"
$operatorObjectId = "00000000-0000-0000-0000-000000000000"
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroup `
  -FoundryAccountName $foundryAccount `
  -OperatorObjectId $operatorObjectId
```

```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:-}"
resource_group="approved-session-03-resource-group"
foundry_account="approved-existing-foundry-resource"
operator_object_id="00000000-0000-0000-0000-000000000000"
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --resource-group-name "$resource_group" \
  --foundry-account-name "$foundry_account" \
  --operator-object-id "$operator_object_id"
```

Add a manual-confirmation switch only after completing the check named by preflight. Inspect the
`FullResourcePayloads` preview. It may contain `Create`, `Modify`, or `NoChange` for listed child
deployments and nothing else.

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

### 4. Assign model-deployment policy

Resolve the two built-in definition IDs, complete `artifacts/model-approval-register.json`, then
run the policy preflight:

```powershell
$env:RVAS_APPROVED_MODELS_POLICY_ID = az policy definition list --query "[?displayName=='Foundry model deployments should only use approved models'].id | [0]" --output tsv
$env:RVAS_MODEL_ELIGIBILITY_POLICY_ID = az policy definition list --query "[?displayName=='Foundry model deployments should meet eligibility requirements'].id | [0]" --output tsv
.\scripts\preflight-model-policy.ps1 -TargetScope "approved-model-policy-scope" -ResourceGroup $resourceGroup
az deployment group create --resource-group $resourceGroup --template-file .\artifacts\policy\model-governance.bicep --parameters .\artifacts\policy\model-governance.bicepparam --only-show-errors
```

```bash
export RVAS_APPROVED_MODELS_POLICY_ID="$(az policy definition list --query "[?displayName=='Foundry model deployments should only use approved models'].id | [0]" --output tsv)"
export RVAS_MODEL_ELIGIBILITY_POLICY_ID="$(az policy definition list --query "[?displayName=='Foundry model deployments should meet eligibility requirements'].id | [0]" --output tsv)"
./scripts/preflight-model-policy.sh --target-scope "approved-model-policy-scope" --resource-group "$resource_group"
az deployment group create --resource-group "$resource_group" --template-file ./artifacts/policy/model-governance.bicep --parameters ./artifacts/policy/model-governance.bicepparam --only-show-errors
```

## Confirm the result

Inspect each child deployment listed in the profile:

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
import json, subprocess, sys
with open("./artifacts/models/deployment-profiles.json", encoding="utf-8") as handle:
    profiles = json.load(handle)["deployments"]
for profile in profiles:
    subprocess.run([
        "az", "cognitiveservices", "account", "deployment", "show",
        "--name", sys.argv[1], "--resource-group", sys.argv[2],
        "--deployment-name", profile["deploymentName"],
        "--query", "{state:properties.provisioningState,model:properties.model,sku:sku,approvalId:tags.modelApprovalId}",
        "--output", "json", "--only-show-errors",
    ], check=True)
PY
```

Every deployment must report `Succeeded`. Its exact model coordinates, SKU, capacity, and
`modelApprovalId` must match `deployment-profiles.json`.

```powershell
.\scripts\check-model-policy.ps1 -ResourceGroup $resourceGroup
```

```bash
./scripts/check-model-policy.sh --resource-group "$resource_group"
```

Both assignments must match the approval register.

## After implementation

The Foundry platform team owns live capacity and deployment changes. The lifecycle owner keeps the
review date, replacement work, and notifications current. The decision authority keeps the full
approval and review history. The policy owner maintains the approval register and policy
assignments. Platform engineering maintains the Bicep, parameters, profiles, and paired preflight
scripts.

Use this path for later version changes. Deployments created elsewhere need their own control.
Azure Policy can separately deny selected deployment SKU names across other authorized paths.

To restore an earlier approved version, restore its profile through the approved change process,
rerun preflight, inspect what-if, and redeploy. To remove a deployment, the workload and platform
owners must first confirm that no consumer uses it. Check for
`implementationSession=03-model-governance-lifecycle`, then remove that one child deployment
through the approved Foundry or Azure deployment path. Leave the parent Foundry resource and every
other deployment in place.
