# Implementation - Landing-zone guardrails with Azure Policy

## Session scope

### What we will do

At the live assignment on the approved Session 01 sandbox resource group, configure Azure Policy to
**deny evaluated Azure Resource Manager changes** that use disallowed locations or omit required
resource tags. We create the initiative at the approved subscription scope, assign it to that one
resource group in `DoNotEnforce`, review Policy Insights, and move the same assignment to `Default`
after owner review and change approval. This session owns the live initiative and assignment whose
scope, parameters, references, marker, and enforcement mode match the approved design.

### Why it matters

The assignment puts two landing-zone rules on the resource change path before the sandbox expands.
Staging exposes likely impact first, so the cloud platform owner can handle exemptions and the
change authority can decide whether denial is safe.

### Boundaries

Azure Policy is authoritative for the initiative, assignment, enforcement mode, and exemptions.
Policy Insights is authoritative for evaluated compliance. The customer change or risk system owns
approval and risk decisions; the repository owns deployable policy definitions and parameters.

`Default` enforcement applies when Azure Policy evaluates an in-scope ARM request at this live
resource-group assignment. It does not prove that existing resources are compliant, remediate them,
or cover change paths and controls outside these two policy rules. This session does not deploy a
management-group definition, prepare production parameters, move subscriptions, or create a
resource solely to test a rule. Diagnostic settings, network controls, managed identity, Defender
plans, approved SKUs, encryption, and sandbox expiry require their own designs and handoffs.

## Architecture

### Architecture at a glance

Every evaluated Azure Resource Manager change in the Session 01 sandbox resource group passes
through the same two checks. Azure Policy checks the location against the allowed list and looks
for the approved tags. It can deny a request that fails either rule. The boundary is deliberately
narrow. Sibling resource groups and wider scopes remain untouched, and the policy does not repair
resources that already exist.

The rollout begins in audit-only mode. Azure calls this `DoNotEnforce`: Policy Insights evaluates
the rules, but Azure Policy does not deny the change. Once those results are current, the cloud
platform owner reviews the likely impact and any exemptions. The change authority may then approve
`Default`, the mode that enforces the policy and denies a failing in-scope request.

The design uses Microsoft's built-in policy rules instead of maintaining local copies. Before
deployment, a lookup step finds the IDs currently visible in the tenant and confirms that the
rules still have the expected effects. Bicep then groups the allowed-location rule and one
required-tag rule for every approved tag into a custom initiative at subscription scope. A single
assignment limits that initiative to the sandbox resource group.

Azure Policy shows the initiative, its assignment, the active enforcement mode, and any
exemptions. Policy Insights shows the latest evaluated results. The repository defines what can be
deployed, while the customer change or risk system records the decision to enforce. Sessions 03
and 04 pass through these checks whenever they change resources inside this group.

![Azure Policy moves from current built-in resolution through a staged assignment, owner review, approval, and enforcement](../assets/diagrams/policy-promotion.svg)

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Policy packaging | Group the current Microsoft built-ins in one custom initiative | References and parameters stay together; Microsoft still owns the underlying rules | Built-in IDs or behavior can change, so check both before deployment | Microsoft deprecates a built-in or its rule no longer fits |
| Assignment scope | Assign the initiative only to the Session 01 sandbox resource group | A first use of deny cannot affect sibling groups or wider scopes | The subscription and management groups are outside this control | A wider scope has its own parameters, owner, and restore plan |
| Enforcement rollout | Start in audit-only `DoNotEnforce`; after review and approval, change the same assignment to enforcing `Default` | The owner sees likely impact before Azure starts denying requests | Policy evaluation takes time, and stale results stop promotion | The operating process can safely support a different rollout |

### Architecture guidance

- [Initiative definition structure](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/initiative-definition-structure)
- [Policy assignment structure](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/assignment-structure)
- [Get Azure Policy compliance data](https://learn.microsoft.com/en-us/azure/governance/policy/how-to/get-compliance-data)

## Before you start

The deployment operator needs a time-bound **Resource Policy Contributor** assignment on the
approved sandbox subscription. That assignment covers the policy set definition at subscription
scope and the policy assignment on the exact Session 01 sandbox resource group. Sign in to that
subscription, confirm that `Microsoft.PolicyInsights` is registered, and work from this
`implementation` directory.

```powershell
$resourceGroupName = "<approved-sandbox-resource-group>"
$deploymentLocation = "<approved-deployment-region>"
$assignmentName = "rvas-s02-guardrails"

az account show --query "{subscription:name,user:user.name,tenant:tenantDisplayName}" --output table
az bicep version
az provider show `
  --namespace Microsoft.PolicyInsights `
  --query registrationState `
  --output tsv
```
```bash
resource_group_name="<approved-sandbox-resource-group>"
deployment_location="<approved-deployment-region>"
assignment_name="rvas-s02-guardrails"

az account show --query '{subscription:name,user:user.name,tenant:tenantDisplayName}' --output table
az bicep version
az provider show \
  --namespace Microsoft.PolicyInsights \
  --query registrationState \
  --output tsv
```

Replace the two sandbox region values in `artifacts/environments/sandbox.bicepparam`.

Resolve the two current built-ins and pass their IDs to Bicep. The resolver returns implementation
inputs to the current shell and does not write a package or log file.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/policy/initiative.bicep`](artifacts/policy/initiative.bicep) | The subscription policy deployment pipeline |
| Deployment | [`artifacts/policy/assignment.bicep`](artifacts/policy/assignment.bicep) | The sandbox policy deployment pipeline |
| Deployment | [`artifacts/policy/guardrail-settings.json`](artifacts/policy/guardrail-settings.json) | The initiative and assignment parameter builds |
| Deployment | [`artifacts/environments/initiative.bicepparam`](artifacts/environments/initiative.bicepparam) | The subscription policy deployment pipeline |
| Deployment | [`artifacts/environments/sandbox.bicepparam`](artifacts/environments/sandbox.bicepparam) | The sandbox policy deployment pipeline |
| Record | [`artifacts/governance/change-reference.md`](artifacts/governance/change-reference.md) | The cloud platform owner and change authority |

```powershell
$builtIns = .\scripts\resolve-builtins.ps1 | ConvertFrom-Json
$builtIns

$env:RVAS_ALLOWED_LOCATIONS_POLICY_ID = $builtIns.allowedLocations.id
$env:RVAS_REQUIRE_TAG_POLICY_ID = $builtIns.requireTag.id

.\scripts\preflight.ps1 `
  -ResourceGroupName $resourceGroupName `
  -DeploymentLocation $deploymentLocation
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

./scripts/preflight.sh \
  --resource-group-name "$resource_group_name" \
  --deployment-location "$deployment_location"
```

Preflight must show the intended subscription and exact resource-group scope. It also rejects a
malformed required-tag source or any parameter file that stops loading that source. Resolve every
failure before deployment.

## Decisions and stop conditions

Check these **four conditions before changing enforcement**:

| Gate | Continue when | Stop when |
|---|---|---|
| Scope | The subscription, sandbox resource group, owner, and inherited assignments are understood | The scope is shared, ownership is missing, or an inherited policy makes the change unsafe |
| Policy enforcement | Both built-ins are current, nondeprecated, and still use the expected `Deny` effect and parameters | A definition changed, is unavailable, or applies more broadly than intended |
| Exemption | The live Azure Policy exemption is limited to the approved scope and policy references, and the customer risk system holds the decision reference | The exemption is broader than the approved exception, has no expiry, or has no customer risk reference |
| Promotion | The cloud platform owner has reviewed live Policy Insights findings and exemptions, restore ownership is ready, and the change authority has approved `Default` | Evaluation is stale, the review is incomplete, or the change authority has not approved `Default` |

Management-group or production deployment needs an executable promotion path, its own scope
decision, and change authorization. None is included in this timed core.

## Implement

### 1. Deploy the initiative

Apply the subscription preview that preflight displayed:

```powershell
az deployment sub create `
  --location $deploymentLocation `
  --name rvas-s02-initiative `
  --parameters .\artifacts\environments\initiative.bicepparam `
  --only-show-errors

$initiativeId = az deployment sub show `
  --name rvas-s02-initiative `
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
  --location "$deployment_location" \
  --name rvas-s02-initiative \
  --parameters ./artifacts/environments/initiative.bicepparam \
  --only-show-errors

initiative_id="$(az deployment sub show \
  --name rvas-s02-initiative \
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

### 2. Stage the assignment

Rerun preflight. With `RVAS_INITIATIVE_DEFINITION_ID` set, it also shows the resource-group
assignment preview.

```powershell
.\scripts\preflight.ps1 `
  -ResourceGroupName $resourceGroupName `
  -DeploymentLocation $deploymentLocation

az deployment group create `
  --resource-group $resourceGroupName `
  --name rvas-s02-assignment `
  --parameters .\artifacts\environments\sandbox.bicepparam `
  --only-show-errors
```
```bash
./scripts/preflight.sh \
  --resource-group-name "$resource_group_name" \
  --deployment-location "$deployment_location"

az deployment group create \
  --resource-group "$resource_group_name" \
  --name rvas-s02-assignment \
  --parameters ./artifacts/environments/sandbox.bicepparam \
  --only-show-errors
```

Keep `enforcementMode = 'DoNotEnforce'` for the first deployment.

### 3. Inspect impact before promotion

Request an evaluation and inspect policy state for resources already in the approved scope. Do not
deploy a seed resource.

![Azure Policy promotion state machine with separate configured enforcement and observed compliance](../assets/diagrams/policy-promotion.svg)

```powershell
$scope = az group show `
  --name $resourceGroupName `
  --query id `
  --output tsv `
  --only-show-errors

$assignmentId = az policy assignment show `
  --name $assignmentName `
  --scope $scope `
  --query id `
  --output tsv `
  --only-show-errors

az policy state trigger-scan `
  --resource-group $resourceGroupName `
  --no-wait `
  --only-show-errors

az policy state list `
  --resource-group $resourceGroupName `
  --filter "PolicyAssignmentId eq '$assignmentId'" `
  --query "[].{state:complianceState,reference:policyDefinitionReferenceId,resource:resourceId}" `
  --output table `
  --only-show-errors
```
```bash
scope="$(az group show \
  --name "$resource_group_name" \
  --query id \
  --output tsv \
  --only-show-errors | tr -d '\r')"

assignment_id="$(az policy assignment show \
  --name "$assignment_name" \
  --scope "$scope" \
  --query id \
  --output tsv \
  --only-show-errors | tr -d '\r')"

az policy state trigger-scan \
  --resource-group "$resource_group_name" \
  --no-wait \
  --only-show-errors

az policy state list \
  --resource-group "$resource_group_name" \
  --filter "PolicyAssignmentId eq '$assignment_id'" \
  --query "[].{state:complianceState,reference:policyDefinitionReferenceId,resource:resourceId}" \
  --output table \
  --only-show-errors
```

New assignments and scans are asynchronous. Read the wait period from the customer change record,
then inspect again if the state is stale. Keep `DoNotEnforce` while results remain stale, record the
cloud platform owner and next review date in that customer record, and stop the session before
promotion. Create any approved exemption in Azure Policy and put its decision reference in the
customer risk system; do not mirror the exemption in this repository.

### 4. Promote the approved assignment

The cloud platform owner must finish the live findings and exemption review. The change authority
must then approve enforcement. Without both owner gates, stop and do not enter **Confirm the
result**. After approval, change `enforcementMode` in
`artifacts/environments/sandbox.bicepparam` to `Default`, rerun preflight, inspect the assignment
preview, and redeploy the same assignment:

```powershell
.\scripts\preflight.ps1 `
  -ResourceGroupName $resourceGroupName `
  -DeploymentLocation $deploymentLocation

az deployment group create `
  --resource-group $resourceGroupName `
  --name rvas-s02-assignment `
  --parameters .\artifacts\environments\sandbox.bicepparam `
  --only-show-errors
```
```bash
./scripts/preflight.sh \
  --resource-group-name "$resource_group_name" \
  --deployment-location "$deployment_location"

az deployment group create \
  --resource-group "$resource_group_name" \
  --name rvas-s02-assignment \
  --parameters ./artifacts/environments/sandbox.bicepparam \
  --only-show-errors
```

## Confirm the result

Inspect the **deployed initiative and assignment** once. Use Microsoft’s
[policy compliance guidance](https://learn.microsoft.com/en-us/azure/governance/policy/how-to/get-compliance-data)
to interpret the live Policy Insights state:

```powershell
$scope = az group show --name $resourceGroupName --query id --output tsv --only-show-errors
$assignment = az policy assignment show `
  --name $assignmentName --scope $scope --output json --only-show-errors |
  ConvertFrom-Json

if ($assignment.enforcementMode -ne "Default") {
  throw "Session 02 is incomplete: the approved assignment must use Default enforcement."
}

[pscustomobject]@{
  Scope = $assignment.scope
  EnforcementMode = $assignment.enforcementMode
  Initiative = $assignment.policyDefinitionId
  ImplementationSession = $assignment.metadata.implementationSession
  AllowedLocations = ($assignment.parameters.allowedLocations.value -join ", ")
  RequiredTags = ($assignment.parameters.requiredTagNames.value -join ", ")
} | Format-List

$initiativeName = ([string]$assignment.policyDefinitionId).Split("/")[-1]
az policy set-definition show `
  --name $initiativeName `
  --query "{implementationSession:metadata.implementationSession,references:policyDefinitions[].{referenceId:policyDefinitionReferenceId,definitionId:policyDefinitionId,parameters:parameters}}" `
  --output jsonc `
  --only-show-errors
```
```bash
scope="$(az group show --name "$resource_group_name" --query id --output tsv --only-show-errors | tr -d '\r')"
assignment_json="$(az policy assignment show \
  --name "$assignment_name" \
  --scope "$scope" \
  --output json \
  --only-show-errors)"

python3 -c '
import json
import sys

assignment = json.load(sys.stdin)
if assignment.get("enforcementMode") != "Default":
    raise SystemExit(
        "Session 02 is incomplete: the approved assignment must use Default enforcement."
    )
print("Scope: {}".format(assignment.get("scope", "")))
print("EnforcementMode: {}".format(assignment.get("enforcementMode", "")))
print("Initiative: {}".format(assignment.get("policyDefinitionId", "")))
print(
    "ImplementationSession: "
    + (assignment.get("metadata") or {}).get("implementationSession", "")
)
print(
    "AllowedLocations: "
    + ", ".join(
        (((assignment.get("parameters") or {}).get("allowedLocations") or {}).get("value"))
        or []
    )
)
print(
    "RequiredTags: "
    + ", ".join(
        (((assignment.get("parameters") or {}).get("requiredTagNames") or {}).get("value"))
        or []
    )
)
' <<<"$assignment_json"

initiative_name="$(
  python3 -c 'import json, sys; print(json.load(sys.stdin).get("policyDefinitionId", "").rsplit("/", 1)[-1])' \
    <<<"$assignment_json"
)"
az policy set-definition show \
  --name "$initiative_name" \
  --query "{implementationSession:metadata.implementationSession,references:policyDefinitions[].{referenceId:policyDefinitionReferenceId,definitionId:policyDefinitionId,parameters:parameters}}" \
  --output jsonc \
  --only-show-errors
```

The assignment must show the approved resource-group scope, `Default` enforcement, allowed
locations, required tags, and Session 02 marker. A `DoNotEnforce` assignment fails this check and
means the session is incomplete. The initiative has the same marker, one `allowed-locations`
reference, and one `require-tag-*` reference for each name in `guardrail-settings.json`. Their
definition IDs match the current resolver output. Azure Policy and Policy Insights are the live
truth.

## After implementation

The **cloud platform owner owns the subscription initiative and sandbox assignment**, along with
their settings and parameter files. It reviews live Policy Insights findings and Azure Policy
exemptions. The change authority approves promotion, restore, or removal in the customer change
system.

If enforcement causes an operational problem, first redeploy the sandbox assignment with
`DoNotEnforce`. That keeps policy visibility while requests recover. To remove the Session 02
assignment, the cloud platform owner checks the `implementationSession` marker, verifies that no
other assignment uses the initiative, and removes only the marked assignment and unreferenced
initiative through the approved Azure Policy change path.
