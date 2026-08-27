# Implement the Microsoft Foundry platform baseline

## Session scope

### What we will do

Establish one **owned, tagged Microsoft Foundry baseline** connected to workspace-based Application
Insights through a repeatable deployment. In one approved sandbox or nonproduction resource group,
we deploy a current `AIServices` Foundry resource and child project, give both system-assigned
identities, and connect the project to workspace-based Application Insights. The same seven
governance tags cover the resource group and every taggable resource.

This session owns the deployed baseline, a repeat deployment preview with no unintended change, and
a decision record that points to the authoritative customer inventory item. When classic assets
are in scope, that record also points to the customer migration backlog.

### Why it matters

Later controls need a stable Foundry resource and project with clear ownership, reusable desired
state, and a known telemetry connection. Operations also needs one inventory location for the live
resource details instead of competing copies in the repository.

### Boundaries

Live Azure resource state is authoritative. The customer inventory system owns environment
inventory and any migration backlog; the repository keeps deployable desired state and pointers to
those records. The Application Insights connection makes the baseline telemetry-connected, but
this session does not run an application or prove that telemetry is arriving.

The work stays in one approved sandbox or nonproduction resource group. It does not deploy a model,
assign roles, enforce Azure Policy, or create a private network path.
[Session 02](../../02-landing-zone-guardrails/implementation/README.md),
[Session 03](../../03-identity-privileged-access/implementation/README.md), and
[Session 04](../../04-private-networking-dns/implementation/README.md) own those controls. The
connection string is resolved inside Bicep and is neither a parameter nor an output.

## Architecture

### Architecture at a glance

This session creates the Foundry boundary that later controls build on. One deployment places a
Foundry resource of the `AIServices` kind and its child project in the approved resource group,
alongside a Log Analytics workspace and workspace-based Application Insights. Azure Resource
Manager applies the customer-owned Bicep, then connects the project to Application Insights.
Bicep resolves the connection string during deployment; operators never pass it in or receive it
as output.

Azure shows what is deployed now. The repository defines the intended resource shape. The customer
inventory system tells operators where the environment belongs and tracks any classic assets that
still need work. None of these records tries to replace the others.

This session stops at the platform and tracing connection. It does not enforce policy, grant
production access, or prove that traces are arriving. [Session 02](../../02-landing-zone-guardrails/implementation/README.md)
adds policy to this boundary, [Session 03](../../03-identity-privileged-access/implementation/README.md)
adds access, and [Session 04](../../04-private-networking-dns/implementation/README.md) adds private
connectivity.

![The customer-owned repository deploys the Foundry resource hierarchy and Application Insights connection, then hands live inventory ownership to the customer system](../assets/diagrams/session-flow.svg)

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Foundry resource model | Use the current `AIServices` resource with one child project | New work starts within the supported management boundary | Confirmed classic assets remain outside this deployment and need separate migration work | A classic workload is approved for migration |
| Desired state | Keep Bicep and `.bicepparam` in the customer repository | The team can review and repeat the deployment | A portal change creates drift and must be reconciled | The deployment pipeline or ownership model changes |
| Identity and tracing | Give both Foundry resources system-assigned identities and connect the project to workspace-based Application Insights | No stored credential is needed, and the tracing connection is ready | Session 03 adds role assignments; this connection alone does not prove trace delivery | A different identity boundary or tracing store is approved |

### Architecture guidance

- [What is Microsoft Foundry?](https://learn.microsoft.com/en-us/azure/foundry/what-is-foundry)
- [Deploy a Foundry resource by using Bicep](https://learn.microsoft.com/en-us/azure/foundry/how-to/create-resource-template)
- [Set up tracing for AI agents in Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/observability/how-to/trace-agent-setup)

## Before you start

Use a working branch in the customer-owned repository and run commands from this
`implementation` directory.

```powershell
$resourceGroup = "rg-rvas-s01-sandbox"
$deployment = "rvas-s01-baseline"
$location = "<approved-region>"
```
```bash
resource_group="rg-rvas-s01-sandbox"
deployment="rvas-s01-baseline"
location="<approved-region>"
```

You need:

- Azure CLI 2.47.0 or later with Bicep 0.18.4 or later;
- the Contributor role on the approved sandbox subscription if this session creates the resource
  group, or on the exact sandbox resource group if it already exists;
- permission to run deployment what-if at that exact sandbox resource-group scope;
- registered `Microsoft.CognitiveServices`, `Microsoft.Insights`, and
  `Microsoft.OperationalInsights` providers; and
- the Reader role on the approved sandbox subscription only if you will search that subscription
  for Foundry (classic) candidates.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/infra/foundry/main.bicep`](artifacts/infra/foundry/main.bicep) | The platform deployment pipeline |
| Deployment | [`artifacts/environments/sandbox.bicepparam`](artifacts/environments/sandbox.bicepparam) | The platform deployment pipeline |
| Record | [`artifacts/decisions/resource-model.md`](artifacts/decisions/resource-model.md) | The platform owner and operational inventory process |

Before creating or tagging the resource group, use read-only commands to inspect the selected
subscription and any existing group:

```powershell
az account show --query "{subscription:name,id:id}" --output table
az group show --name $resourceGroup --query "{id:id,location:location,tags:tags}" --output jsonc
```
```bash
az account show --query '{subscription:name,id:id}' --output table
az group show --name "$resource_group" --query '{id:id,location:location,tags:tags}' --output jsonc
```

The group lookup may return not found. Continue only when the subscription is approved and an
existing group's location, ownership, and tags allow this use.

Check the signed-in account before changing Azure:

```powershell
az account show --query "{subscription:name, tenant:tenantDisplayName, user:user.name}" --output table
az bicep version
```
```bash
az account show --query '{subscription:name, tenant:tenantDisplayName, user:user.name}' --output table
az bicep version
```

Use team aliases and synthetic classifications in tags. Azure tags are plain text. Keep
credentials, tenant and subscription IDs, endpoints, prompts, traces, responses, and customer
data out of this repository. Operational inventory can contain resource IDs and environment
details, so route it to the customer's normal inventory system instead of committing it.

## Decisions and stop conditions

Make these decisions before deployment:

1. **Approved Azure scope.** Name the approved sandbox subscription and exact sandbox resource
   group. Manual removal
   requires the group tag `implementationSession=01-platform-baseline`. Stop if the group is
   shared and its owner has not approved that marker.
2. **Customer values.** Replace every `__REQUIRED_*__` value in
   `artifacts/environments/sandbox.bicepparam` and
   `artifacts/decisions/resource-model.md`. Use an ISO `yyyy-MM-dd` expiry date. Stop if any
   sentinel remains.
3. **Resource model.** The platform owner records one required decision: use the current Foundry
   resource and child-project model for new work. Existing confirmed hub-based projects keep their
   approved controls until the platform owner approves separate migration work. Do not mix both
   models in this deployment.
4. **Foundry network posture.** The `publicNetworkAccess` property controls whether the Foundry
   resource accepts traffic through its public network endpoint. Set it to the value approved for
   the Session 01 Foundry resource. The supplied artifact requires an explicit choice. Do not set
   it to `Disabled` until the approved execution host has a working private path. Do not set it to
   `Enabled` when the landing-zone rules prohibit public network access.
5. **Planned scope.** The first preview should contain only the documented baseline resources.
   Stop if it targets another group, changes an existing resource unexpectedly, or needs a
   provider registration that the customer has not approved.

Do not add secrets to the parameter file. The Bicep connection reads the Application Insights
connection string during deployment and does not emit it.

## Implement

### 1. Resolve the implementation definitions

Edit the parameter and decision files in place. Keep the single artifact tree listed in
**Implementation files**.

The Bicep uses the stable APIs verified on 2026-08-24:

- `Microsoft.CognitiveServices/accounts@2026-05-01`
- `Microsoft.CognitiveServices/accounts/projects@2026-05-01`
- `Microsoft.CognitiveServices/accounts/projects/connections@2026-05-01`
- `Microsoft.OperationalInsights/workspaces@2023-09-01`
- `Microsoft.Insights/components@2020-02-02`

Keep `disableLocalAuth: true`. If the project-managed identity tracing path or the approved
region has changed since the verification date, stop and recheck the Microsoft sources recorded
in `session.yaml`.

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
  -DeploymentName $deployment
```
```bash
./scripts/preflight.sh \
  --resource-group-name "$resource_group" \
  --deployment-name "$deployment"
```

Preflight rejects unresolved decisions, confirms that Azure CLI is using the approved sandbox
subscription and exact sandbox resource group, checks provider registrations, builds the Bicep,
and prints a deployment preview. Inspect the scope and planned resources. Do not continue on an
unexpected change.

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

Do not commit the response. Platform operations creates or updates the inventory item and returns
the external reference. Record that pointer in `artifacts/decisions/resource-model.md`; the
customer system remains authoritative for live resource details.

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
(classic) hubs. The operator verifies each candidate in Foundry (classic). The platform owner puts each confirmed hub-based project in the customer migration backlog with an
owner and due date. Record only the backlog reference in
`artifacts/decisions/resource-model.md`.

### 6. Commit the operational implementation

Commit the Bicep, parameter file, combined decision record, and preflight scripts. Leave
environment inventory and other customer-specific command responses in the customer's operational
systems.

## Confirm the result

Rerun the preflight and inspect its **final [Bicep deployment
preview](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if)**:

```powershell
.\scripts\preflight.ps1 `
  -ResourceGroupName $resourceGroup `
  -DeploymentName $deployment
```
```bash
./scripts/preflight.sh \
  --resource-group-name "$resource_group" \
  --deployment-name "$deployment"
```

The operational baseline should have no unintended change. The project `AppInsights` connection can appear as `Modify` or `Deploy` because its credential is
write-only. Treat only that exact connection result as expected platform noise.

Stop on any other create, delete, modify, deploy, or indeterminate result. You do not need to save
the command output.

## After implementation

The **platform owner keeps the deployed baseline** for
[Session 02](../../02-landing-zone-guardrails/implementation/README.md) unless the customer chooses
to remove it. The repository keeps the implementation files. Platform operations owns the inventory
item, while the resource-model record keeps its external reference. The customer backlog owns any
classic migration work.

The `expiryDate` remains the trigger to keep or remove sandbox resources. This session does not
authorize production use.

### Remove the marked scope

If the baseline must be removed, the platform owner uses the customer change path to inspect the
current deployment outputs and the `implementationSession=01-platform-baseline` marker. Remove only
the resources listed by the current deployment. Do not delete the resource group from this kit. If a
dedicated group must also be removed, inventory it first and use the customer's normal
resource-group change process after confirming that no unrelated resource remains.

Deleted Foundry accounts remain recoverable for 48 hours. The same name cannot be reused during
that window unless an authorized operator performs an irreversible purge. This kit does not purge
resources. Use a new resource-group name or prefix, or follow Microsoft's recovery and purge
procedure after an explicit customer decision.
