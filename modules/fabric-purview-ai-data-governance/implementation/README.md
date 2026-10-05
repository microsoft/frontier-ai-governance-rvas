# Govern AI grounding data with Fabric and Purview

## Module scope

### What we will do

**Objective.** Give one AI consumer group controlled access to one gold Fabric lakehouse used for
grounding.

This module records the Fabric Copilot and AI tenant settings baseline, configures one OneLake
security role for the selected lakehouse, applies the selected sensitivity label, and records a
Purview Fabric DLP policy in simulation mode. The observable result is simple: the permitted
consumer can read the approved gold path, and the restricted consumer cannot.

### Why it matters

**Problem.** AI teams often point agents and retrieval pipelines at Fabric data before tenant
settings, labels, DLP scope, and lakehouse roles agree.

**Solution.** This module puts the data boundary in one path: tenant-setting drift is checked,
lakehouse access is narrowed, sensitive data is labelled, and Purview DLP starts in simulation
before the data becomes a grounding source.

**[EU AI Act](https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng).** For high-risk AI systems, this
module supports Article 10 (data and data governance) when the lakehouse holds training or testing
data, and Article 26(4) (deployer control of input data) when it supplies grounding data. This is an
engineering mapping, not legal advice.

### Boundaries

This module sits outside the numbered session sequence.

It changes one Fabric lakehouse access path and one Purview policy decision for AI data. Microsoft
Fabric remains authoritative for tenant settings and OneLake roles. Microsoft Purview remains
authoritative for sensitivity labels, label policies, DLP simulation, alerts, and policy history.
This repository keeps the decisions and read-only checks that those live services do not keep in
one place.

Agent 365 rollout DLP stays with the
[Agent 365 secure rollout guide](../../../sessions/05-agent-365-access-boundary/implementation/README.md).
Data quality, retention, domains, endorsements, and tenant-wide networking are out of scope here.
Move those to the data platform backlog after this module if they are missing.

## Architecture

### Architecture at a glance

The flow starts with live Fabric tenant settings. The Fabric administrator exports the settings
through the Admin REST API and compares the Copilot and AI group with the module baseline.

The data platform owner then applies one OneLake security role to the approved gold lakehouse. The
role grants `Read` to the Microsoft Entra AI consumer group, adds the approved row and column
restrictions, and records the restricted group removal from `DefaultReader`.

The Purview operator applies the selected sensitivity label to the Fabric item and creates the DLP
policy for the Fabric location in simulation mode. The delivery owner then observes the intended
and blocked consumer checks.

| Layer | Authoritative service | Repository record | Check |
|---|---|---|---|
| Tenant settings | Microsoft Fabric Admin REST API | `tenant-settings-baseline.json` | Copilot and AI drift |
| Lakehouse access | OneLake security roles | `onelake-ai-consumer-role.json` | Live role membership |
| Label and DLP | Microsoft Purview | `fabric-label-dlp-decision.json` | Portal summary and simulation |
| Delivery result | Fabric consumer path | `access-check-plan.json` | Permitted and restricted identities |

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
|---|---|---|---|
| Tenant settings | Compare the Copilot and AI group to a recorded baseline | Finds drift before the lakehouse is used for grounding | The check is read-only; an administrator still changes settings through the approved Fabric path |
| Access model | OneLake `Read` role for one AI consumer group | Keeps one access rule across supported Fabric paths | Workspace Admin, Member, and Contributor roles can bypass the role and must stay out of the consumer path |
| Restricted users | Remove restricted principals from `DefaultReader` and test a restricted identity | Confirms the role is not hidden by broad default access | The live user check needs a real restricted identity |
| Purview control | Apply the label and run Fabric DLP in simulation mode first | Shows matches and policy tips without enforcing actions | Full enforcement needs a later Purview change after match review |
| Automation | REST checks for Fabric, portal-led Purview change | Uses documented read paths and avoids unsupported Purview policy APIs | The DLP policy preview is the Purview portal summary and simulation, not a what-if API |

### Architecture guidance

Use [Tenants - List Tenant Settings](https://learn.microsoft.com/en-us/rest/api/fabric/admin/tenants/list-tenant-settings)
for the Fabric Admin REST endpoint, paging, and caller requirements.

Use [OneLake security roles: create and manage](https://learn.microsoft.com/en-us/fabric/onelake/security/create-manage-roles)
for role behavior, RLS/CLS, member assignment, and `DefaultReader` review.

Use [Get started with DLP for Fabric and Power BI](https://learn.microsoft.com/en-us/purview/dlp-powerbi-get-started)
for Fabric DLP supported locations, actions, custom-policy limits, and capacity requirements.

## Before you start

Confirm these requirements:

- One approved nonproduction Fabric workspace contains the gold lakehouse used for grounding.
- The Fabric workspace runs on a Fabric or Premium capacity that supports the planned Fabric DLP
  scope.
- The Fabric administrator can read tenant settings and operate OneLake security roles for the
  selected lakehouse.
- The Microsoft Entra AI consumer group and restricted consumer group are known and approved.
- The Purview operator can apply the selected sensitivity label and create a Fabric DLP policy in
  simulation mode.
- The delivery owner can observe a permitted consumer identity and a restricted consumer identity.
- PowerShell operators use PowerShell 7 or later for the module scripts.

Use group aliases in the artifacts. Keep tenant IDs, object IDs, live query output, prompts,
responses, access tokens, and customer data in the approved customer system.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Record | [`artifacts/fabric/tenant-settings-baseline.json`](artifacts/fabric/tenant-settings-baseline.json) | The Fabric administrator and tenant-settings drift check scripts |
| Deployment | [`artifacts/fabric/onelake-ai-consumer-role.json`](artifacts/fabric/onelake-ai-consumer-role.json) | The Fabric administrator and OneLake access verification scripts |
| Record | [`artifacts/purview/fabric-label-dlp-decision.json`](artifacts/purview/fabric-label-dlp-decision.json) | The Purview operator and data product owner |
| Record | [`artifacts/verification/access-check-plan.json`](artifacts/verification/access-check-plan.json) | The delivery owner and AI application owner |

Resolve every `__REQUIRED_*__` value before a service change. The preflight scripts reject each
unresolved value and stop before any Fabric or Purview call.

## Decisions and stop conditions

### Scope and ownership

Record one target scope: `one-approved-fabric-ai-grounding-lakehouse`. The lakehouse, workspace,
tenant, AI consumer group, restricted group, Purview label, DLP policy, and delivery owner must all
refer to that same scope.

Stop if the workspace is production, the lakehouse is shared with other grounding projects without
owner approval, or the Fabric administrator cannot confirm the current tenant and item.

### Tenant setting baseline

The baseline covers the Fabric **Copilot and AI** tenant settings group. The Fabric administrator
checks it before applying the OneLake role.

Stop if any setting differs from the recorded baseline and the baseline owner has not approved the
change. Also stop if the customer wants to enable OpenAI as a Microsoft subprocessor, cross-geo
processing, cross-geo storage, standalone Copilot, or Foundry observability export without a named
owner decision.

### OneLake role and DefaultReader

Create one role named `AiGroundingConsumerRead`. It grants `Read` on the approved gold table path,
uses the row predicate and allowed columns in the artifact, and includes one Microsoft Entra group:
the AI consumer group.

Before saving the role, inspect `DefaultReader`. Remove the restricted consumer group and any other
principal that would make the blocked-path check meaningless.

Stop if a consumer identity is Workspace Admin, Member, or Contributor, if the role includes a user
instead of the approved group, or if the role payload would replace unrelated roles because the
current ETag was not reviewed.

### Label and DLP mode

Apply the selected sensitivity label to the Fabric item through the approved Fabric or Purview
path. Then create a custom Purview DLP policy for the Fabric location in simulation mode. Use the
selected label as the condition and start with policy tips and alerts.

Stop if the label is unpublished for the relevant operators, if the DLP location is broader than
the approved workspaces, if the policy is set to full enforcement, or if the Purview summary does
not match the record.

### Access checks

The permitted and restricted checks use the same lakehouse, table, label, DLP policy, and consumer
path. The only difference is the identity.

Stop if the restricted identity can read the gold data path, if the permitted identity cannot read
the approved path, or if either check uses a different data path.

## Field reference

| Artifact field | What it means |
|---|---|
| `implementationSession` | Must be `optional-module-fabric-purview-ai-data-governance` in every artifact. |
| `targetScope` | Must be `one-approved-fabric-ai-grounding-lakehouse` in every artifact and script call. |
| `watchList[].title` | The Fabric tenant setting title returned by the Admin REST API. |
| `rolePayload` | The REST body for `PUT /workspaces/{workspaceId}/items/{itemId}/dataAccessRoles`. |
| `currentDataAccessRoleEtag` | The ETag reviewed before applying the role. Send it in `If-Match`. |
| `restrictedPrincipalsRemovedFromDefaultReader` | The restricted principal review that makes the blocked-path check meaningful. |
| `dlpPolicy.mode` | Must stay `simulation` for this module. Enforcement needs a later Purview change. |
| `checks[].name` | Must include `intended-path` and `blocked-path`. |

## Implement

### 1. Complete the records

Fill in every required value under `artifacts/`. Use the customer-owned private copy for tenant
and object IDs. Keep this repository version as the reusable template.

### 2. Run local preflight

```powershell
.\scripts\preflight.ps1 -TargetScope "one-approved-fabric-ai-grounding-lakehouse"
```

```bash
./scripts/preflight.sh --target-scope "one-approved-fabric-ai-grounding-lakehouse"
```

Preflight checks the artifact files, target scope, implementation marker, matching Fabric item
coordinates, OneLake role member, DLP simulation mode, and the two access checks. It does not sign
in or call Fabric.

### 3. Check tenant-setting drift

Run the drift check before changing access:

```powershell
.\scripts\check-tenant-settings.ps1 -TargetScope "one-approved-fabric-ai-grounding-lakehouse"
```

```bash
./scripts/check-tenant-settings.sh --target-scope "one-approved-fabric-ai-grounding-lakehouse"
```

The script reads `GET https://api.fabric.microsoft.com/v1/admin/tenantsettings`, follows paging,
and compares the Copilot and AI group to `tenant-settings-baseline.json`. It reports setting drift
without writing the export to the repository.

### 4. Apply the OneLake role with a dry run first

Run the Fabric REST dry run from the approved operator shell. Use the artifact's `rolePayload` as
the body and the recorded ETag as `If-Match`.

```powershell
$roleRecord = Get-Content .\artifacts\fabric\onelake-ai-consumer-role.json -Raw | ConvertFrom-Json
$fabricToken = az account get-access-token --resource "https://api.fabric.microsoft.com" --query accessToken --output tsv --only-show-errors
$uri = "https://api.fabric.microsoft.com/v1/workspaces/$($roleRecord.fabric.workspaceId)/items/$($roleRecord.fabric.lakehouseItemId)/dataAccessRoles?dryRun=true"
$body = $roleRecord.rolePayload | ConvertTo-Json -Depth 100
Invoke-RestMethod -Method Put -Uri $uri -Headers @{
  Authorization = "Bearer $fabricToken"
  "If-Match" = $roleRecord.fabric.currentDataAccessRoleEtag
} -ContentType "application/json" -Body $body
```

```bash
role_file="./artifacts/fabric/onelake-ai-consumer-role.json"
workspace_id="$(jq -r '.fabric.workspaceId' "$role_file")"
item_id="$(jq -r '.fabric.lakehouseItemId' "$role_file")"
etag="$(jq -r '.fabric.currentDataAccessRoleEtag' "$role_file")"
fabric_token="$(az account get-access-token --resource "https://api.fabric.microsoft.com" --query accessToken --output tsv --only-show-errors)"
jq '.rolePayload' "$role_file" | curl -fsS -X PUT \
  -H "Authorization: Bearer $fabric_token" \
  -H "If-Match: $etag" \
  -H "Content-Type: application/json" \
  --data-binary @- \
  "https://api.fabric.microsoft.com/v1/workspaces/${workspace_id}/items/${item_id}/dataAccessRoles?dryRun=true"
```

Review the dry-run response. If it matches the role decision, repeat the same command with
`dryRun=false` or without the query parameter through the approved change path.

### 5. Apply the label and create the DLP policy

The Purview operator applies the selected sensitivity label to the lakehouse item through the
approved Fabric or Purview path. Then the operator creates a custom Purview DLP policy:

| Setting | Module value |
|---|---|
| Location | Fabric |
| Scope | The approved workspace or item scope in `fabric-label-dlp-decision.json` |
| Condition | The selected sensitivity label |
| Actions | Policy tip and alert |
| State | Simulation mode |

Use the Purview policy summary as the change review. Save only when the summary matches
`fabric-label-dlp-decision.json`. Keep the policy in simulation mode after this module.

### 6. Read the live OneLake role

```powershell
.\scripts\verify-access.ps1 -TargetScope "one-approved-fabric-ai-grounding-lakehouse"
```

```bash
./scripts/verify-access.sh --target-scope "one-approved-fabric-ai-grounding-lakehouse"
```

The scripts call the read-only OneLake role list endpoint. They confirm the approved AI consumer
group is present in `AiGroundingConsumerRead`, the restricted group is not present, and the
`DefaultReader` review is recorded.

### 7. Delivery-owner checkpoint

Before the identity checks, the delivery owner reviews:

- the tenant-setting drift result;
- the OneLake dry-run result and applied role;
- the `DefaultReader` restricted-principal review;
- the label and DLP policy summary in simulation mode; and
- the exact permitted and restricted consumer identities.

Do not continue if any owner cannot explain the restore path.

## Confirm the result

### Intended path

Sign in as the permitted consumer identity from `access-check-plan.json`. Run the approved
read-only query through the selected consumer path, such as the lakehouse, SQL endpoint, semantic
model, or Fabric data agent. The result must match the expected allowed result shape recorded in
the customer-owned copy of the plan.

### Blocked path

Sign in as the restricted consumer identity. Run the same read-only path. The result must match
the blocked result recorded in the customer-owned copy of the plan.

### Delivery-owner checkpoint

The delivery owner observes both checks. Keep the DLP policy in simulation mode and leave the
lakehouse out of AI grounding use if the restricted identity can read the gold path, if the
permitted identity fails, or if either check uses a different item or query path.

## After implementation

| What remains | Owner |
|---|---|
| Copilot and AI tenant settings baseline and drift response | Fabric administrator and baseline owner |
| OneLake security role, ETag review, and `DefaultReader` restricted-principal review | Data access owner |
| Sensitivity label assignment and label policy | Information protection owner |
| Fabric DLP policy in simulation mode, alerts, and match review | Purview operator and policy owner |
| Permitted and restricted access plan | Delivery owner and AI application owner |

Run the tenant-setting drift check after any Fabric tenant-setting change. Run the OneLake role
check after any lakehouse role update, group change, or workspace role review.

Restore through the owning service paths:

1. Remove the lakehouse from AI grounding configuration if an access check fails.
2. Return the DLP policy to **Keep it off** or keep it in simulation while the Purview operator
   corrects the scope.
3. Reapply the previous OneLake role set with the reviewed ETag if the new role grants too much
   access.
4. Add the restricted group back to `DefaultReader` only if the data access owner approves that
   broader access outside this module.
5. Keep sensitivity labels and Purview alerts that other approved controls use.

Do not delete the lakehouse, workspace, label taxonomy, audit records, or unrelated OneLake roles
as part of this module's restore path.
