# Implement the Microsoft Foundry platform baseline and landing-zone guardrails

## Session scope

### What we will do

Establish one **owned, tagged Microsoft Foundry baseline** connected to workspace-based Application
Insights, then put that baseline behind an **Azure Policy assignment that denies evaluated Azure
Resource Manager changes** using disallowed locations or missing required resource tags. In one
approved sandbox or nonproduction resource group, we deploy a current `AIServices` Foundry resource
and child project, give both system-assigned identities, and connect the project to
workspace-based Application Insights. The same seven governance tags cover the resource group and
every taggable resource. We then create a policy initiative at the subscription scope, assign it to
that resource group in `DoNotEnforce`, review Policy Insights, and move the same assignment to
`Default` after owner review and change approval.

This session owns the deployed baseline, a repeat deployment preview with no unintended change,
and the live initiative and assignment whose scope, parameters, references, marker, and enforcement
mode match the approved design.

### Why it matters

Later controls need a stable Foundry resource and project with clear ownership, reusable desired
state, and a known telemetry connection. Operations also needs one inventory location for the live
resource details instead of competing copies in the repository. The policy assignment then puts two
landing-zone rules on that resource group's change path before the sandbox expands. Staging exposes
likely impact first, so the cloud platform owner can handle exemptions and the change authority can
decide whether denial is safe.

### Boundaries

Live Azure resource state is authoritative for the Foundry baseline. The customer inventory system
owns environment inventory and any migration backlog; the repository keeps deployable desired
state. The Application Insights connection uses the stable `ApiKey` connection shape. Bicep reads the
connection string from Azure and does not expose it as a parameter or output. The preview
`ProjectManagedIdentity` trace-ingestion path is an explicit upgrade decision, not part of this
baseline. This session does not run an application or prove that telemetry is arriving.

Azure Policy is authoritative for the initiative, assignment, enforcement mode, and exemptions.
Policy Insights is authoritative for evaluated compliance. `Default` enforcement applies when Azure
Policy evaluates an in-scope ARM request at the live resource-group assignment. It does not prove
that existing resources are compliant, remediate them, or cover change paths and controls outside
these two policy rules.

The work stays in one approved sandbox or nonproduction resource group. It does not deploy a model,
assign roles, create a private network path, deploy a management-group policy definition, prepare
production parameters, or move subscriptions.
[Session 02](../../02-identity-privileged-access/implementation/README.md) and
[Session 03](../../03-private-networking-dns/implementation/README.md) own identity and private
connectivity. Diagnostic settings, network controls, managed identity, Defender plans, approved
SKUs, encryption, and sandbox expiry require their own designs and handoffs. Session 03 also owns
the change from the temporary `restrictOutboundNetworkAccess: false` baseline to the approved
outbound network posture.

## Architecture

### Architecture at a glance

This session creates the Foundry boundary that later controls build on, then narrows the change
path into that boundary. One deployment places a Foundry resource of the `AIServices` kind and its
child project in the approved resource group, alongside a Log Analytics workspace and
workspace-based Application Insights. Azure Resource Manager applies the customer-owned Bicep, then
connects the project to Application Insights. Bicep resolves the connection string during
deployment; operators never pass it in or receive it as output.

Every evaluated Azure Resource Manager change in that same resource group then passes through two
checks. Azure Policy checks the location against the allowed list and looks for the approved tags.
It can deny a request that fails either rule. The boundary is deliberately narrow: sibling resource
groups and wider scopes remain untouched, and the policy does not repair resources that already
exist. The rollout begins in audit-only `DoNotEnforce`, where Policy Insights evaluates the rules
without Azure Policy denying the change. Once those results are current, the cloud platform owner
reviews the likely impact and any exemptions, and the change authority may then approve `Default`.

The design groups Microsoft's location and required-tag built-ins into a custom initiative instead
of maintaining local copies. Before deployment, a lookup step finds the IDs currently visible in
the tenant and confirms that the rules still have the expected effects. The required-tag list
includes `dataClassification` and `criticality`, so those deployment tags are covered by the same
deny boundary. A single assignment limits that initiative to the sandbox resource group.

Microsoft also publishes AI-specific built-ins for model approval and eligibility. Those controls
belong with the model-governance boundary in
[Session 04](../../04-model-governance-lifecycle/implementation/README.md); this session does not
add them to the landing-zone initiative.

Azure shows what is deployed now and what policy state applies to it. The repository defines the
intended resource and policy shape. The customer inventory system tracks the environment and any classic assets that still need work;
the customer change or risk system records the decision to enforce.

This session stops at the platform, tracing connection, and the two policy rules. It does not
enforce broader policy, grant production access, or prove that traces are arriving.
[Session 02](../../02-identity-privileged-access/implementation/README.md) adds access, and
[Session 03](../../03-private-networking-dns/implementation/README.md) adds private connectivity,
both inheriting the checks assigned here.

![The customer-owned repository deploys the Foundry resource hierarchy and Application Insights connection, then hands live inventory ownership to the customer system](../assets/diagrams/session-flow.svg)

![Azure Policy moves from current built-in resolution through a staged assignment, owner review, approval, and enforcement](../assets/diagrams/policy-promotion.svg)

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Foundry resource model | Use the current `AIServices` resource with one child project | New work starts within the supported management boundary | Confirmed classic assets remain outside this deployment and need separate migration work | A classic workload is approved for migration |
| Desired state | Keep Bicep and `.bicepparam` in the customer repository | The team can review and repeat the deployment | A portal change creates drift and must be reconciled | The deployment pipeline or ownership model changes |
| Tracing authentication | Use the stable `ApiKey` Application Insights project connection without exposing the connection string in parameters or outputs | The baseline uses the stable resource API and remains deployable through Bicep | The connection remains key-based; preview `ProjectManagedIdentity` also needs Application Insights authentication and role changes | The preview path is approved for the environment |
| Outbound network posture | Keep `restrictOutboundNetworkAccess: false` during the baseline | Session 01 does not claim outbound isolation before its network design exists | This is temporary and allows outbound access subject to other platform controls | Session 03 implements the approved private networking and outbound-control design |
| Policy packaging | Group the current Microsoft built-ins in one custom initiative | References and parameters stay together; Microsoft still owns the underlying rules | Built-in IDs or behavior can change, so check both before deployment | Microsoft deprecates a built-in or its rule no longer fits |
| Assignment scope | Assign the initiative only to the same sandbox resource group | A first use of deny cannot affect sibling groups or wider scopes | The subscription and management groups are outside this control | A wider scope has its own parameters, owner, and restore plan |
| Enforcement rollout | Start in audit-only `DoNotEnforce`; after review and approval, change the same assignment to enforcing `Default` | The owner sees likely impact before Azure starts denying requests | Policy evaluation takes time, and stale results stop promotion | The operating process can safely support a different rollout |

### Architecture guidance

- [What is Microsoft Foundry?](https://learn.microsoft.com/en-us/azure/foundry/what-is-foundry)
- [Deploy a Foundry resource by using Bicep](https://learn.microsoft.com/en-us/azure/foundry/how-to/create-resource-template)
- [Initiative definition structure](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/initiative-definition-structure)

## Before you start

Use a working branch in the customer-owned repository and run commands from this
`implementation` directory. The deployment operator needs the Contributor role on the approved
sandbox subscription or resource group for the baseline, and a time-bound **Resource Policy
Contributor** assignment on the approved sandbox subscription for the guardrails. That second
assignment covers the policy set definition at subscription scope and the policy assignment on the
same sandbox resource group.

```powershell
$resourceGroup = "rg-rvas-s01-sandbox"
$deployment = "rvas-s01-baseline"
$location = "<approved-region>"

az account show --query "{subscription:name,user:user.name,tenant:tenantDisplayName}" --output table
az bicep version
az provider show --namespace Microsoft.PolicyInsights --query registrationState --output tsv
```
```bash
resource_group="rg-rvas-s01-sandbox"
deployment="rvas-s01-baseline"
location="<approved-region>"

az account show --query '{subscription:name,user:user.name,tenant:tenantDisplayName}' --output table
az bicep version
az provider show --namespace Microsoft.PolicyInsights --query registrationState --output tsv
```

You need:

- Azure CLI 2.47.0 or later with Bicep 0.18.4 or later;
- the Contributor role on the approved sandbox subscription if this session creates the resource
  group, or on the exact sandbox resource group if it already exists;
- the time-bound Resource Policy Contributor assignment described above;
- permission to run deployment what-if at the sandbox resource-group scope and at the subscription
  scope;
- access to review policy assignments inherited from the subscription and management-group
  hierarchy;
- registered `Microsoft.CognitiveServices`, `Microsoft.Insights`, `Microsoft.OperationalInsights`,
  and `Microsoft.PolicyInsights` providers; and
- the Reader role on the approved sandbox subscription only if you will search that subscription
  for Foundry (classic) candidates.

Replace the two sandbox region values in `artifacts/environments/policy-assignment.bicepparam`.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/infra/foundry/main.bicep`](artifacts/infra/foundry/main.bicep) | The platform deployment pipeline |
| Deployment | [`artifacts/environments/sandbox.bicepparam`](artifacts/environments/sandbox.bicepparam) | The platform deployment pipeline |
| Deployment | [`artifacts/policy/initiative.bicep`](artifacts/policy/initiative.bicep) | The subscription policy deployment pipeline |
| Deployment | [`artifacts/policy/assignment.bicep`](artifacts/policy/assignment.bicep) | The sandbox policy deployment pipeline |
| Deployment | [`artifacts/policy/guardrail-settings.json`](artifacts/policy/guardrail-settings.json) | The initiative and assignment parameter builds |
| Deployment | [`artifacts/environments/initiative.bicepparam`](artifacts/environments/initiative.bicepparam) | The subscription policy deployment pipeline |
| Deployment | [`artifacts/environments/policy-assignment.bicepparam`](artifacts/environments/policy-assignment.bicepparam) | The sandbox policy deployment pipeline |

Before creating or tagging the resource group, use read-only commands to inspect the selected
subscription and any existing group:

```powershell
az group show --name $resourceGroup --query "{id:id,location:location,tags:tags}" --output jsonc
```
```bash
az group show --name "$resource_group" --query '{id:id,location:location,tags:tags}' --output jsonc
```

The group lookup may return not found. Continue only when the subscription is approved and an
existing group's location, ownership, and tags allow this use.

Resolve the two current policy built-ins and pass their IDs to Bicep. The resolver returns
implementation inputs to the current shell and does not write a package or log file.

```powershell
$builtIns = .\scripts\resolve-builtins.ps1 | ConvertFrom-Json
$builtIns

$env:RVAS_ALLOWED_LOCATIONS_POLICY_ID = $builtIns.allowedLocations.id
$env:RVAS_REQUIRE_TAG_POLICY_ID = $builtIns.requireTag.id
```
```bash
built_ins="$(./scripts/resolve-builtins.sh)"
printf '%s\n' "$built_ins"

export RVAS_ALLOWED_LOCATIONS_POLICY_ID="$(
  python3 -c 'import json, sys; print(json.load(sys.stdin)["allowedLocations"]["id"])' \
    <<<"$built_ins"
)"
export RVAS_REQUIRE_TAG_POLICY_ID="$(
  python3 -c 'import json, sys; print(json.load(sys.stdin)["requireTag"]["id"])' \
    <<<"$built_ins"
)"
```

Use team aliases and synthetic classifications in tags. Azure tags are plain text. Keep
credentials, tenant and subscription IDs, endpoints, prompts, traces, responses, and customer
data out of this repository. Operational inventory can contain resource IDs and environment
details, so route it to the customer's normal inventory system instead of committing it.

## Decisions and stop conditions

Make these decisions before deployment:

1. **Approved Azure scope.** Name the approved sandbox subscription and exact sandbox resource
   group. Manual removal requires the group tag `implementationSession=01-platform-baseline`. Stop
   if the group is shared and its owner has not approved that marker.
2. **Customer values.** Replace every `__REQUIRED_*__` value in
   `artifacts/environments/sandbox.bicepparam` and
   `artifacts/environments/policy-assignment.bicepparam`. Use an ISO `yyyy-MM-dd` expiry date.
   Stop if any sentinel remains.
3. **Resource model.** Use the current Foundry resource and child-project model for new work.
   Existing confirmed hub-based projects keep their approved controls until the platform owner
   approves separate migration work. Do not mix both models in this deployment.
4. **Foundry network posture.** The `publicNetworkAccess` property controls whether the Foundry
   resource accepts traffic through its public network endpoint. Set it to the approved value. The
   supplied artifact requires an explicit choice. Do not set it to `Disabled` until the approved
   execution host has a working private path. Do not set it to `Enabled` when the landing-zone
   rules prohibit public network access.
5. **Foundry outbound posture.** The baseline sets `restrictOutboundNetworkAccess: false` because
   Session 01 does not yet own the private egress design. Treat this as temporary. Session 03 must
   replace it with the approved outbound-control design before the environment is treated as
   network isolated.
6. **Tracing authentication.** Keep the stable `ApiKey` connection in this baseline. Move to the
   preview
   [`ProjectManagedIdentity` trace-ingestion path](https://learn.microsoft.com/en-us/azure/foundry/observability/how-to/trace-ingestion-entra-authentication)
   only after the platform and monitoring owners accept preview use, plan Application Insights
   local-authentication changes, and approve the required Monitoring Metrics Publisher assignments.
7. **Planned baseline scope.** The first Foundry preview should contain only the documented baseline
   resources. Stop if it targets another group, changes an existing resource unexpectedly, or needs
   a provider registration that the customer has not approved.

| Gate | Continue when | Stop when |
|---|---|---|
| Policy scope | Preflight lists inherited assignments and the cloud platform owner confirms their effects and exemptions | The scope is shared, ownership is missing, the review is not confirmed, or an inherited policy makes the change unsafe |
| Policy enforcement | Both built-ins are current, nondeprecated, and still use the expected `Deny` effect and parameters | A definition changed, is unavailable, or applies more broadly than intended |
| Exemption | The live Azure Policy exemption is limited to the approved scope and policy references, and the customer risk system holds the decision reference | The exemption is broader than the approved exception, has no expiry, or has no customer risk reference |
| Promotion | The cloud platform owner has reviewed live Policy Insights findings and exemptions, restore ownership is ready, and the change authority has approved `Default` | Evaluation is stale, the review is incomplete, or the change authority has not approved `Default` |

Do not add secrets to any parameter file. The Bicep connection reads the Application Insights
connection string during deployment and does not emit it.

## Implement

### 1. Resolve the implementation definitions

Edit the parameter and decision files in place. Keep the single artifact tree listed in
**Implementation files**.

The Bicep uses the stable APIs verified on 2026-08-26:

- `Microsoft.CognitiveServices/accounts@2026-05-01`
- `Microsoft.CognitiveServices/accounts/projects@2026-05-01`
- `Microsoft.CognitiveServices/accounts/projects/connections@2026-05-01`
- `Microsoft.OperationalInsights/workspaces@2023-09-01`
- `Microsoft.Insights/components@2020-02-02`
- `Microsoft.Authorization/policySetDefinitions@2025-03-01`
- `Microsoft.Authorization/policyAssignments@2025-03-01`

Keep `disableLocalAuth: true`. If the project-managed identity tracing path, the resolved built-in
policy IDs, or the approved region have changed since the verification date, stop and recheck the
Microsoft sources recorded in `session.yaml`. The shipped connection remains `ApiKey`; the
project-managed identity path is still preview.

### 2. Prepare the marked resource group

Use the same approved values in the resource group and parameter file.

```powershell
$businessOwner = "<team-alias>"
$technicalOwner = "<team-alias>"
$dataClassification = "<synthetic-classification>"
$criticality = "<approved-nonproduction-value>"
$costCenter = "<sandbox-cost-code>"
$expiryDate = "<yyyy-MM-dd>"

$groupExists = (
  az group exists --name $resourceGroup --output tsv --only-show-errors
).Trim()
if ($LASTEXITCODE -ne 0 -or $groupExists -notin @("true", "false")) {
  throw "Resource-group existence check failed."
}

if ($groupExists -eq "false") {
  az group create `
    --name $resourceGroup `
    --location $location `
    --only-show-errors |
    Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw "Resource-group creation failed."
  }
}
else {
  $existingLocation = (
    az group show `
      --name $resourceGroup `
      --query location `
      --output tsv `
      --only-show-errors
  ).Trim()
  if ($LASTEXITCODE -ne 0 -or $existingLocation -ine $location) {
    throw "The existing resource group is missing or uses a different location."
  }
}

$resourceGroupId = (
  az group show --name $resourceGroup --query id --output tsv --only-show-errors
).Trim()
$sessionTags = @(
  "implementationSession=01-platform-baseline"
  "environment=sandbox"
  "businessOwner=$businessOwner"
  "technicalOwner=$technicalOwner"
  "dataClassification=$dataClassification"
  "criticality=$criticality"
  "costCenter=$costCenter"
  "expiryDate=$expiryDate"
)
az tag update `
  --resource-id $resourceGroupId `
  --operation Merge `
  --tags $sessionTags `
  --only-show-errors |
  Out-Null
if ($LASTEXITCODE -ne 0) {
  throw "Resource-group tag merge failed."
}
```
```bash
business_owner="<team-alias>"
technical_owner="<team-alias>"
data_classification="<synthetic-classification>"
criticality="<approved-nonproduction-value>"
cost_center="<sandbox-cost-code>"
expiry_date="<yyyy-MM-dd>"

if ! group_exists="$(az group exists --name "$resource_group" --output tsv --only-show-errors | tr -d '\r')"; then
  echo "Resource-group existence check failed." >&2
  exit 1
fi
if [[ "$group_exists" != "true" && "$group_exists" != "false" ]]; then
  echo "Resource-group existence check failed." >&2
  exit 1
fi

if [[ "$group_exists" == "false" ]]; then
  az group create \
    --name "$resource_group" \
    --location "$location" \
    --only-show-errors >/dev/null
else
  existing_location="$(az group show \
    --name "$resource_group" \
    --query location \
    --output tsv \
    --only-show-errors | tr -d '\r')"
  if [[ "$existing_location" != "$location" ]]; then
    echo "The existing resource group is missing or uses a different location." >&2
    exit 1
  fi
fi

resource_group_id="$(az group show --name "$resource_group" --query id --output tsv --only-show-errors | tr -d '\r')"
session_tags=(
  "implementationSession=01-platform-baseline"
  "environment=sandbox"
  "businessOwner=$business_owner"
  "technicalOwner=$technical_owner"
  "dataClassification=$data_classification"
  "criticality=$criticality"
  "costCenter=$cost_center"
  "expiryDate=$expiry_date"
)
az tag update \
  --resource-id "$resource_group_id" \
  --operation Merge \
  --tags "${session_tags[@]}" \
  --only-show-errors >/dev/null
```

If the group already exists, inspect its location and tags before running this command. Never
repurpose an unrelated group for the session. The tag update uses `Merge`, so customer tags that are
not listed above remain in place.

### 3. Run preflight

```powershell
.\scripts\preflight.ps1 `
  -ResourceGroupName $resourceGroup `
  -DeploymentName $deployment `
  -DeploymentLocation $location
```
```bash
./scripts/preflight.sh \
  --resource-group-name "$resource_group" \
  --deployment-name "$deployment" \
  --deployment-location "$location"
```

Preflight rejects unresolved decisions and tag-source divergence, confirms that Azure CLI is using
the approved sandbox subscription and resource group, lists inherited policy assignments, checks
provider registrations, builds the Foundry and policy Bicep files, and prints a deployment preview
for each available deployment. If inherited assignments exist, review their effects and exemptions
with the cloud platform owner, then rerun with the explicit confirmation:

```powershell
.\scripts\preflight.ps1 `
  -ResourceGroupName $resourceGroup `
  -DeploymentName $deployment `
  -DeploymentLocation $location `
  -ConfirmInheritedPolicyReview
```
```bash
./scripts/preflight.sh \
  --resource-group-name "$resource_group" \
  --deployment-name "$deployment" \
  --deployment-location "$location" \
  --confirm-inherited-policy-review
```

Inspect every scope and planned resource. Do not continue on an unexpected change.

### 4. Deploy the baseline

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name $deployment `
  --parameters .\artifacts\environments\sandbox.bicepparam `
  --only-show-errors
```
```bash
az deployment group create \
  --resource-group "$resource_group" \
  --name "$deployment" \
  --parameters ./artifacts/environments/sandbox.bicepparam \
  --only-show-errors
```

The deployment returns resource IDs for the Foundry resource, project, Log Analytics workspace,
Application Insights component, and project connection. A failed command is a stop condition.

### 5. Route the baseline to the customer system

Use the customer's normal inventory process for the deployed resource group:

```powershell
az resource list `
  --resource-group $resourceGroup `
  --query "[].{name:name,type:type,location:location,id:id,tags:tags}" `
  --output json
```
```bash
az resource list \
  --resource-group "$resource_group" \
  --query "[].{name:name,type:type,location:location,id:id,tags:tags}" \
  --output json
```

Do not commit the response. Platform operations creates or updates the inventory item in the
customer system, which remains authoritative for live resource details.

Run this subscription query only when classic assets are in scope and the operator has subscription
Reader access:

```powershell
az resource list `
  --resource-type Microsoft.MachineLearningServices/workspaces `
  --query "[].{name:name,resourceGroup:resourceGroup,location:location,id:id}" `
  --output json
```
```bash
az resource list \
  --resource-type Microsoft.MachineLearningServices/workspaces \
  --query "[].{name:name,resourceGroup:resourceGroup,location:location,id:id}" \
  --output json
```

Skip the query otherwise. It returns Azure Machine Learning workspaces that may be Foundry
(classic) hubs. The operator verifies each candidate in Foundry (classic). The platform owner puts each confirmed
hub-based project in the customer migration backlog with an owner and due date.

### 6. Deploy the initiative

Apply the subscription preview that preflight displayed:

```powershell
az deployment sub create `
  --location $location `
  --name rvas-s01-guardrails-initiative `
  --parameters .\artifacts\environments\initiative.bicepparam `
  --only-show-errors

$initiativeId = az deployment sub show `
  --name rvas-s01-guardrails-initiative `
  --query properties.outputs.initiativeDefinitionId.value `
  --output tsv `
  --only-show-errors

if ([string]::IsNullOrWhiteSpace($initiativeId)) {
  throw "The initiative deployment did not return an initiative ID."
}
$env:RVAS_INITIATIVE_DEFINITION_ID = $initiativeId
```
```bash
az deployment sub create \
  --location "$location" \
  --name rvas-s01-guardrails-initiative \
  --parameters ./artifacts/environments/initiative.bicepparam \
  --only-show-errors

initiative_id="$(az deployment sub show \
  --name rvas-s01-guardrails-initiative \
  --query properties.outputs.initiativeDefinitionId.value \
  --output tsv \
  --only-show-errors | tr -d '\r')"

if [[ -z "$initiative_id" ]]; then
  echo "The initiative deployment did not return an initiative ID." >&2
  exit 1
fi
export RVAS_INITIATIVE_DEFINITION_ID="$initiative_id"
```

The initiative contains one `allowed-locations` reference and one tag reference for each name in
`guardrail-settings.json`. Its `implementationSession` metadata marks the state owned by this
session.

### 7. Stage the assignment

Rerun preflight. With `RVAS_INITIATIVE_DEFINITION_ID` set, it also shows the resource-group
assignment preview.

```powershell
.\scripts\preflight.ps1 `
  -ResourceGroupName $resourceGroup `
  -DeploymentName $deployment `
  -DeploymentLocation $location

az deployment group create `
  --resource-group $resourceGroup `
  --name rvas-s01-guardrails-assignment `
  --parameters .\artifacts\environments\policy-assignment.bicepparam `
  --only-show-errors
```
```bash
./scripts/preflight.sh \
  --resource-group-name "$resource_group" \
  --deployment-name "$deployment" \
  --deployment-location "$location"

az deployment group create \
  --resource-group "$resource_group" \
  --name rvas-s01-guardrails-assignment \
  --parameters ./artifacts/environments/policy-assignment.bicepparam \
  --only-show-errors
```

Keep `enforcementMode = 'DoNotEnforce'` for the first deployment.

### 8. Inspect impact before promotion

Request an evaluation and inspect policy state for resources already in the approved scope. Do not
deploy a seed resource.

```powershell
$scope = az group show `
  --name $resourceGroup `
  --query id `
  --output tsv `
  --only-show-errors

$assignmentId = az policy assignment show `
  --name rvas-s01-guardrails `
  --scope $scope `
  --query id `
  --output tsv `
  --only-show-errors

az policy state trigger-scan `
  --resource-group $resourceGroup `
  --no-wait `
  --only-show-errors

az policy state list `
  --resource-group $resourceGroup `
  --filter "PolicyAssignmentId eq '$assignmentId'" `
  --query "[].{state:complianceState,reference:policyDefinitionReferenceId,resource:resourceId}" `
  --output table `
  --only-show-errors
```
```bash
scope="$(az group show \
  --name "$resource_group" \
  --query id \
  --output tsv \
  --only-show-errors | tr -d '\r')"

assignment_id="$(az policy assignment show \
  --name rvas-s01-guardrails \
  --scope "$scope" \
  --query id \
  --output tsv \
  --only-show-errors | tr -d '\r')"

az policy state trigger-scan \
  --resource-group "$resource_group" \
  --no-wait \
  --only-show-errors

az policy state list \
  --resource-group "$resource_group" \
  --filter "PolicyAssignmentId eq '$assignment_id'" \
  --query "[].{state:complianceState,reference:policyDefinitionReferenceId,resource:resourceId}" \
  --output table \
  --only-show-errors
```

New assignments and scans are asynchronous. Follow the wait period in the normal change process,
then inspect again if the state is stale. Keep `DoNotEnforce` while results remain stale, keep the
cloud platform owner and next review date in that process, and stop the session before promotion.
Create any approved exemption in Azure Policy and keep its decision reference in the customer risk
system.

### 9. Promote the approved assignment

The cloud platform owner must finish the live findings and exemption review. The change authority
must then approve enforcement. Without both owner gates, stop and do not enter **Confirm the
result**. After approval, change `enforcementMode` in
`artifacts/environments/policy-assignment.bicepparam` to `Default`, rerun preflight, inspect the
assignment preview, and redeploy the same assignment:

```powershell
.\scripts\preflight.ps1 `
  -ResourceGroupName $resourceGroup `
  -DeploymentName $deployment `
  -DeploymentLocation $location

az deployment group create `
  --resource-group $resourceGroup `
  --name rvas-s01-guardrails-assignment `
  --parameters .\artifacts\environments\policy-assignment.bicepparam `
  --only-show-errors
```
```bash
./scripts/preflight.sh \
  --resource-group-name "$resource_group" \
  --deployment-name "$deployment" \
  --deployment-location "$location"

az deployment group create \
  --resource-group "$resource_group" \
  --name rvas-s01-guardrails-assignment \
  --parameters ./artifacts/environments/policy-assignment.bicepparam \
  --only-show-errors
```

### 10. Commit the operational implementation

Commit the Bicep, parameter files, and scripts. Leave environment inventory, approval details, and
customer-specific command responses in the customer systems that own them.

## Confirm the result

Rerun the preflight and inspect its **final Bicep deployment previews**:

```powershell
.\scripts\preflight.ps1 `
  -ResourceGroupName $resourceGroup `
  -DeploymentName $deployment `
  -DeploymentLocation $location
```
```bash
./scripts/preflight.sh \
  --resource-group-name "$resource_group" \
  --deployment-name "$deployment" \
  --deployment-location "$location"
```

The operational baseline should have no unintended change. The project `AppInsights` connection can
appear as `Modify` or `Deploy` because its credential is write-only. Treat only that exact
connection result as expected platform noise. Stop on any other create, delete, modify, deploy, or
indeterminate result for the Foundry baseline.

Then inspect the **deployed initiative and assignment** once, using Microsoft's
[policy compliance guidance](https://learn.microsoft.com/en-us/azure/governance/policy/how-to/get-compliance-data)
to interpret the live Policy Insights state:

```powershell
$assignment = az policy assignment show `
  --name rvas-s01-guardrails --scope $scope --output json --only-show-errors |
  ConvertFrom-Json

if ($assignment.enforcementMode -ne "Default") {
  throw "The approved assignment must use Default enforcement."
}

[pscustomobject]@{
  Scope = $assignment.scope
  EnforcementMode = $assignment.enforcementMode
  Initiative = $assignment.policyDefinitionId
  ImplementationSession = $assignment.metadata.implementationSession
  AllowedLocations = ($assignment.parameters.allowedLocations.value -join ", ")
  RequiredTags = ($assignment.parameters.requiredTagNames.value -join ", ")
} | Format-List
```
```bash
assignment_json="$(az policy assignment show \
  --name rvas-s01-guardrails \
  --scope "$scope" \
  --output json \
  --only-show-errors)"

python3 -c '
import json
import sys

assignment = json.load(sys.stdin)
if assignment.get("enforcementMode") != "Default":
    raise SystemExit("The approved assignment must use Default enforcement.")
print("Scope: {}".format(assignment.get("scope", "")))
print("EnforcementMode: {}".format(assignment.get("enforcementMode", "")))
print("Initiative: {}".format(assignment.get("policyDefinitionId", "")))
print(
    "ImplementationSession: "
    + (assignment.get("metadata") or {}).get("implementationSession", "")
)
' <<<"$assignment_json"
```

The assignment must show the approved resource-group scope, `Default` enforcement, allowed
locations, required tags, and the session marker. A `DoNotEnforce` assignment fails this check and
means the guardrail rollout is incomplete. You do not need to save any command output.

## After implementation

The **platform owner keeps the deployed baseline** and the **cloud platform owner keeps the
subscription initiative and sandbox assignment** unless the customer chooses to remove them. The
repository keeps the implementation files. Platform operations owns the inventory item and the
customer backlog owns any classic migration work. The change authority approves promotion, restore,
or removal of the policy scope in the customer change system.

The `expiryDate` remains the trigger to keep or remove sandbox resources. This session does not
authorize production use.

If enforcement causes an operational problem, first redeploy the sandbox assignment with
`DoNotEnforce`. That keeps policy visibility while requests recover.

### Remove the marked scope

If the baseline must be removed, the platform owner uses the customer change path to inspect the
current deployment outputs and the `implementationSession=01-platform-baseline` marker. Remove only
the resources listed by the current deployment. Do not delete the resource group from this kit. If a
dedicated group must also be removed, inventory it first and use the customer's normal
resource-group change process after confirming that no unrelated resource remains.

To remove the policy assignment, the cloud platform owner checks the `implementationSession`
marker, verifies that no other assignment uses the initiative, and removes only the marked
assignment and unreferenced initiative through the approved Azure Policy change path.

Deleted Foundry accounts remain recoverable for 48 hours. The same name cannot be reused during
that window unless an authorized operator performs an irreversible purge. This kit does not purge
resources. Use a new resource-group name or prefix, or follow Microsoft's recovery and purge
procedure after an explicit customer decision.
