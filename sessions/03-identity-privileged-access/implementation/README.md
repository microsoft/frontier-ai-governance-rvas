# Implementation - Entra identity, RBAC, PIM, and workload identities

## Session scope

### What we will do

Configure **four customer-owned groups and one workload identity** in the approved nonproduction
resource group. Platform administrators become PIM-eligible for Foundry Account Owner on the
Foundry resource. Project managers receive Foundry Project Manager on that resource, developers
receive Foundry User on one project, and auditors receive Reader on the Foundry resource.

We also deploy one user-assigned managed identity with no client secret. Its federated credential
trusts the exact subject for one protected GitHub environment. Cognitive Services User stops at the
Foundry resource recorded for this session, and Storage Blob Data Reader stops at the storage
account recorded for this session. This session owns the matching live group assignments, PIM eligibility and settings, federated
credential, and workload role scopes.

### Why it matters

People get standing access for their normal tasks while elevated account administration has an
activation boundary, expiry, and customer approval. The GitHub workload can authenticate without a
stored Azure client secret, and its authority does not spread beyond those two resources.

### Boundaries

Azure RBAC and Microsoft Entra PIM are authoritative for live human access. The managed identity
and its federated credential are authoritative for workload trust. The repository keeps desired
state, role definitions, and customer decision pointers; it does not mirror live assignments or
eligibility.

No subscription-level role is assigned. The workload path is application-only and does not carry
a signed-in user's delegated authority. It is not the Agent ID used by Microsoft Foundry Agent
Service; [Session 06](../../06-governed-agent-baseline/implementation/README.md) owns that runtime
identity. When a downstream API must authorize each signed-in user, use the
[Delegated API access with OAuth on-behalf-of module](../../../modules/obo-delegated-access/)
instead of widening this workload identity. Allow 270 minutes for this implementation.

## Architecture

### Architecture at a glance

There are two access paths, and they never borrow authority from each other.

A person signs in through Microsoft Entra ID and gets access through one of four customer-owned
groups. Project managers, developers, and auditors receive standing Azure RBAC roles at the
resource or project they need. Platform administrators are only eligible for Foundry Account
Owner through PIM. They must activate that role with approval and MFA, and the activation expires
after two hours.

GitHub uses a workload path with no stored Azure client secret. For one protected environment,
GitHub issues an OpenID Connect (OIDC) token. Microsoft Entra ID accepts it only when the issuer,
subject, and audience exactly match the federated credential on the user-assigned managed
identity. The resulting authority belongs to the workload, not a signed-in person. Cognitive
Services User stops at one Foundry resource, and Storage Blob Data Reader stops at one storage
account.

Azure RBAC and PIM show who can act now and who may activate elevated access. The managed identity
and federated credential define the GitHub trust. The repository keeps the intended assignments
and pointers to customer decisions. Session 04 adds private connectivity. Session 06 owns the
Foundry Agent ID and its runtime authorization path.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Normal human access | Assign roles to customer-owned groups at the Foundry resource or project | Team membership controls access, with no direct user assignments | The customer still owns group membership and its review | A task needs a different role or resource boundary |
| Elevated administration | Make Foundry Account Owner PIM-eligible, with approval, MFA, and a two-hour activation | Platform administration is active only when someone needs it | This needs Entra licensing, named approvers, and an activation step | The emergency-access or approval model changes |
| GitHub authentication | Trust the exact OIDC claims for one protected environment on a user-assigned managed identity | GitHub needs no Azure client secret, and only the named environment can request this authority | The trust is application-only; a repository or environment change requires an update | A downstream API must authorize the signed-in user, or an agent needs its own identity |

### Architecture guidance

- [Role-based access control for Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/concepts/rbac-foundry)
- [Configure Azure resource role settings in PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-resource-roles-configure-role-settings)
- [Create trust for a user-assigned managed identity](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust-user-assigned-managed-identity)

## Before you start

[Session 01](../../01-platform-baseline/implementation/README.md) and
[Session 02](../../02-landing-zone-guardrails/implementation/README.md) must be complete. Use the
approved nonproduction subscription and resource group, the Foundry resource and project recorded
for this session, the storage account recorded for this session, the four customer-owned groups, and
the protected GitHub environment.
You also need:

- Azure CLI with Bicep support, signed in to the approved subscription;
- the time-bound Owner or User Access Administrator role on the exact nonproduction resource group
  that contains the Foundry resource, Foundry project, and storage account;
- the Owner or User Access Administrator role on the existing Foundry resource whose Foundry
  Account Owner settings the PIM operator will change;
- Microsoft Entra ID P2 or Microsoft Entra ID Governance licensing;
- four customer-owned security groups; and
- one protected GitHub environment.

Work from the `implementation` directory. Keep object IDs and tenant coordinates in the shell or the
customer's configuration system.

```powershell
$resourceGroup = Read-Host "Approved resource group"
$foundryAccountName = Read-Host "Existing Foundry resource name"
$foundryProjectName = Read-Host "Existing Foundry project name"
$storageAccountName = Read-Host "Existing storage account name"
$projectManagerGroupObjectId = Read-Host "Project manager group object ID"
$developerGroupObjectId = Read-Host "Developer group object ID"
$auditorGroupObjectId = Read-Host "Auditor group object ID"
$githubOwner = Read-Host "GitHub owner"
$githubRepository = Read-Host "GitHub repository"
$githubEnvironment = Read-Host "Protected GitHub environment"
$expiryDate = Read-Host "Identity operating-until date (YYYY-MM-DD)"
```
```bash
read -r -p "Approved resource group: " resource_group
read -r -p "Existing Foundry resource name: " foundry_account_name
read -r -p "Existing Foundry project name: " foundry_project_name
read -r -p "Existing storage account name: " storage_account_name
read -r -p "Project manager group object ID: " project_manager_group_object_id
read -r -p "Developer group object ID: " developer_group_object_id
read -r -p "Auditor group object ID: " auditor_group_object_id
read -r -p "GitHub owner: " github_owner
read -r -p "GitHub repository: " github_repository
read -r -p "Protected GitHub environment: " github_environment
read -r -p "Identity operating-until date (YYYY-MM-DD): " expiry_date
```

Complete the required values in
[`artifacts/identity/workload-identity.bicep`](artifacts/identity/workload-identity.bicep) and
[`artifacts/pim/pim-change-reference.md`](artifacts/pim/pim-change-reference.md). Preflight rejects
every unresolved `__REQUIRED_*__` value.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/identity/workload-identity.bicep`](artifacts/identity/workload-identity.bicep) | The workload identity deployment pipeline |
| Deployment | [`artifacts/identity/human-role-assignments.bicep`](artifacts/identity/human-role-assignments.bicep) | The human-access deployment pipeline |
| Deployment | [`artifacts/identity/role-definitions.json`](artifacts/identity/role-definitions.json) | The identity Bicep builds and preflight scripts |
| Record | [`artifacts/identity/role-to-task-matrix.md`](artifacts/identity/role-to-task-matrix.md) | The identity owner and access change approver |
| Record | [`artifacts/pim/pim-change-reference.md`](artifacts/pim/pim-change-reference.md) | The identity owner and PIM administrator |

## Decisions and stop conditions

### Approved Azure and identity scope

Confirm the nonproduction Azure subscription and resource group with the customer change owner.
Record the exact Foundry resource, Foundry project, storage account, four customer-owned groups,
and protected GitHub environment that this change may use.

**Stop before any role or identity change** if the subscription, resource group, Foundry resource,
Foundry project, or storage account recorded for this session is production or shared with production. Continue
only after the production owner approves the change through the customer's process and the team
rechecks each assignment scope in the
deployment preview.

Role definitions are resolved at subscription scope because Azure publishes built-in roles there.
That does not justify a subscription-level role assignment. Stop if either deployment preview
creates an assignment above the Foundry resource, project, or storage account recorded for this session.

### Choose the identity flow

Pick the caller boundary before you change any role assignment or trust:

| Situation | Identity flow | Decision in this program |
|---|---|---|
| A signed-in person works directly in the portal, CLI, or SDK | Direct human access | Use group assignment for normal work and PIM for elevation |
| A workflow, daemon, or application should keep the same authority no matter who started it | Workload or application-only | Use the dedicated managed identity in this session |
| A Foundry agent must call tools as its own actor | Agent identity | Use the Agent ID path in [Session 06](../../06-governed-agent-baseline/implementation/README.md) |
| A middle tier must call a downstream API and that API must authorize each signed-in user differently | Delegated OBO | Use the [Delegated API access with OAuth on-behalf-of module](../../../modules/obo-delegated-access/) |

Choose OBO only when downstream authorization must vary by the signed-in user. If the same
workload authority should apply to every request, stay with application-only access.

### Human access and PIM

Use the current tenant-visible names with these stable role IDs:

| Task boundary | Role | Assignment scope |
|---|---|---|
| Account and model administration | Foundry Account Owner | Foundry resource, PIM eligible |
| Project management and publishing | Foundry Project Manager | Foundry resource |
| Work inside one project | Foundry User | Foundry project |
| Configuration inspection | Reader | Foundry resource |

Microsoft's Foundry RBAC documentation says these roles were renamed and that old display names can
still appear while the rename reaches each tool. The role IDs and core permissions are unchanged.
Stop if a role does not resolve or its permissions no longer match the task matrix.

PIM settings belong to one role on one resource. They do not inherit from a subscription to the
same role on a Foundry resource. Stop if:

- the selected role or resource is wrong;
- the eligible principal and operating owner are not recorded;
- approval is disabled or no customer-owned approver group is available;
- the requested change would alter a shared PIM policy or emergency-access path; or
- anyone proposes a permanent active platform-administrator assignment.

The activation duration and eligibility expiry are separate settings. Each approved activation can
last no more than two hours and requires MFA, justification, and approval. The customer PIM change
record names the eligible group, owner, approvers, expiry, and restore decision.
`pim-change-reference.md` stores only the external reference.

### Workload identity and OIDC

Use one user-assigned managed identity for this workload. A federated identity credential on that
managed identity trusts an OIDC token only when GitHub issues it with these exact claims:

| Claim | Required value |
|---|---|
| Issuer | `https://token.actions.githubusercontent.com` |
| Subject | `repo:OWNER/REPOSITORY:environment:ENVIRONMENT` |
| Audience | `api://AzureADTokenExchange` |

![GitHub OIDC trust from one protected environment through exact token claims to a user-assigned managed identity with Cognitive Services User on one Foundry resource and Storage Blob Data Reader on one storage account](../assets/diagrams/oidc-trust-scope.svg)

The issuer and subject use exact matching. The standard subject property does not support
wildcards. Stop if the requested trust covers every repository, every branch, or an unprotected
environment. Do not create a client secret as a fallback.

System-assigned managed identities do not support this federated-credential configuration. A
user-assigned managed identity supports up to 20 federated identity credentials, but this
implementation creates one. This path is application-only. It does not carry a signed-in user's
delegated authority to a downstream API.

### Customer data

This session inspects identity configuration only. It does not read model responses, blobs, secrets,
or other customer content. Stop if any step would require customer data to confirm the control.

## Implement

### 1. Complete the required decisions

Update the role-to-task matrix if the customer chooses narrower tasks or scopes. Replace the GitHub
environment sentinel in `workload-identity.bicep`. Confirm that the matrix still points to direct
human access or workload/application-only access for this change. The identity owner records the
customer change pointer and eligible group reference in `pim-change-reference.md`.

Run preflight:

```powershell
.\scripts\preflight.ps1 -ResourceGroupName $resourceGroup
```
```bash
./scripts/preflight.sh --resource-group-name "$resource_group"
```

Preflight confirms that Azure CLI is using the approved nonproduction subscription and resource
group, reads the six stable IDs from `role-definitions.json`, and checks each semantic key against
its immutable built-in role ID, accepted current or rollout display name, and `BuiltInRole` type.
It rejects unresolved decisions and then compiles both Bicep files. Stop on any failure.

Stop here if the customer now needs a downstream API to authorize each signed-in user differently.
That is a delegated OBO design. Hand it to the
[Delegated API access with OAuth on-behalf-of module](../../../modules/obo-delegated-access/)
instead of adding it to this session.

### 2. Preview and deploy standing human roles

Preview the three group assignments:

```powershell
az deployment group what-if `
  --resource-group $resourceGroup `
  --name rvas-s03-human-rbac-preview `
  --template-file .\artifacts\identity\human-role-assignments.bicep `
  --parameters `
    "foundryAccountName=$foundryAccountName" `
    "foundryProjectName=$foundryProjectName" `
    "projectManagerGroupObjectId=$projectManagerGroupObjectId" `
    "developerGroupObjectId=$developerGroupObjectId" `
    "auditorGroupObjectId=$auditorGroupObjectId" `
  --only-show-errors
```
```bash
az deployment group what-if \
  --resource-group "$resource_group" \
  --name rvas-s03-human-rbac-preview \
  --template-file ./artifacts/identity/human-role-assignments.bicep \
  --parameters \
    "foundryAccountName=$foundry_account_name" \
    "foundryProjectName=$foundry_project_name" \
    "projectManagerGroupObjectId=$project_manager_group_object_id" \
    "developerGroupObjectId=$developer_group_object_id" \
    "auditorGroupObjectId=$auditor_group_object_id" \
  --only-show-errors
```

The preview should show Foundry Project Manager on the Foundry resource, Foundry User on one
project, and Reader on the Foundry resource. It must not add Foundry Account Owner as a standing
assignment.

After the change owner approves that preview, deploy the same parameters:

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name rvas-s03-human-rbac `
  --template-file .\artifacts\identity\human-role-assignments.bicep `
  --parameters `
    "foundryAccountName=$foundryAccountName" `
    "foundryProjectName=$foundryProjectName" `
    "projectManagerGroupObjectId=$projectManagerGroupObjectId" `
    "developerGroupObjectId=$developerGroupObjectId" `
    "auditorGroupObjectId=$auditorGroupObjectId" `
  --only-show-errors
```
```bash
az deployment group create \
  --resource-group "$resource_group" \
  --name rvas-s03-human-rbac \
  --template-file ./artifacts/identity/human-role-assignments.bicep \
  --parameters \
    "foundryAccountName=$foundry_account_name" \
    "foundryProjectName=$foundry_project_name" \
    "projectManagerGroupObjectId=$project_manager_group_object_id" \
    "developerGroupObjectId=$developer_group_object_id" \
    "auditorGroupObjectId=$auditor_group_object_id" \
  --only-show-errors
```

The template uses deterministic assignment names and declares `principalType: Group`.

### 3. Configure PIM for elevated administration

In Microsoft Entra admin center:

1. Open **ID Governance > Privileged Identity Management > Azure resources**.
2. Select the approved Foundry resource, then open the Foundry Account Owner settings.
3. Set the maximum duration of each activation to two hours. Require MFA, justification, and approval.
4. Select the customer-owned approver group and notification recipients from the customer change
   record.
5. Add the platform-administrator group as eligible through the expiry in that record.

Do not automate a shared PIM policy from this kit. If the role settings affect other eligible
principals, the customer identity owner must handle the change through the existing identity
process.

MFA might not prompt again when the current sign-in session already satisfies it. If the customer
requires reauthentication for each activation, use the approved Conditional Access authentication
context and sign-in frequency.

### 4. Preview and deploy the workload identity

Preview the managed identity, exact GitHub trust, and two role assignments:

```powershell
az deployment group what-if `
  --resource-group $resourceGroup `
  --name rvas-s03-workload-identity-preview `
  --template-file .\artifacts\identity\workload-identity.bicep `
  --parameters `
    "foundryAccountName=$foundryAccountName" `
    "storageAccountName=$storageAccountName" `
    "githubOwner=$githubOwner" `
    "githubRepository=$githubRepository" `
    "githubEnvironment=$githubEnvironment" `
    "expiryDate=$expiryDate" `
  --only-show-errors
```
```bash
az deployment group what-if \
  --resource-group "$resource_group" \
  --name rvas-s03-workload-identity-preview \
  --template-file ./artifacts/identity/workload-identity.bicep \
  --parameters \
    "foundryAccountName=$foundry_account_name" \
    "storageAccountName=$storage_account_name" \
    "githubOwner=$github_owner" \
    "githubRepository=$github_repository" \
    "githubEnvironment=$github_environment" \
    "expiryDate=$expiry_date" \
  --only-show-errors
```

Stop if the preview shows a different identity, GitHub subject, role, or scope. Once approved,
deploy it:

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name rvas-s03-workload-identity `
  --template-file .\artifacts\identity\workload-identity.bicep `
  --parameters `
    "foundryAccountName=$foundryAccountName" `
    "storageAccountName=$storageAccountName" `
    "githubOwner=$githubOwner" `
    "githubRepository=$githubRepository" `
    "githubEnvironment=$githubEnvironment" `
    "expiryDate=$expiryDate" `
  --only-show-errors
```
```bash
az deployment group create \
  --resource-group "$resource_group" \
  --name rvas-s03-workload-identity \
  --template-file ./artifacts/identity/workload-identity.bicep \
  --parameters \
    "foundryAccountName=$foundry_account_name" \
    "storageAccountName=$storage_account_name" \
    "githubOwner=$github_owner" \
    "githubRepository=$github_repository" \
    "githubEnvironment=$github_environment" \
    "expiryDate=$expiry_date" \
  --only-show-errors
```

Set `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID` in the protected GitHub
environment. Keep these identifiers in environment configuration even though they are not
passwords. A customer-owned workflow that uses this trust needs `id-token: write`. It does not need
an Azure client secret.

## Confirm the result

Use this one confirmation section to inspect the human assignments, live Entra PIM configuration,
and workload identity. First confirm the three standing Azure RBAC group assignments. In Entra PIM,
confirm that Foundry Account Owner eligibility names the approved platform-administrator group and
that the live role settings match the approved two-hour activation, MFA, justification, approval,
approver, and expiry decisions. Compare the customer change reference, not a repository mirror.

Observe the **workload identity configuration**. Compare the exact issuer, subject, and audience with
Microsoft’s [workload identity federation
guidance](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust-user-assigned-managed-identity):

```powershell
$identity = az identity show `
  --resource-group $resourceGroup `
  --name id-rvas-s03-workload `
  --output json | ConvertFrom-Json

[pscustomobject]@{
  Name = $identity.name
  ImplementationSession = $identity.tags.implementationSession
  ClientId = $identity.clientId
} | Format-List

az identity federated-credential list `
  --resource-group $resourceGroup `
  --identity-name $identity.name `
  --query "[].{name:name,issuer:issuer,subject:subject,audience:audiences[0]}" `
  --output table

az role assignment list `
  --assignee-object-id $identity.principalId `
  --all `
  --query "[].{role:roleDefinitionName,scope:scope}" `
  --output table
```
```bash
identity_json="$(az identity show \
  --resource-group "$resource_group" \
  --name id-rvas-s03-workload \
  --output json \
  --only-show-errors)"

python3 -c '
import json
import sys

identity = json.load(sys.stdin)
print("Name: {}".format(identity.get("name", "")))
print(
    "ImplementationSession: "
    + (identity.get("tags") or {}).get("implementationSession", "")
)
print("ClientId: {}".format(identity.get("clientId", "")))
' <<<"$identity_json"

az identity federated-credential list \
  --resource-group "$resource_group" \
  --identity-name id-rvas-s03-workload \
  --query "[].{name:name,issuer:issuer,subject:subject,audience:audiences[0]}" \
  --output table

az role assignment list \
  --assignee-object-id "$(
    python3 -c 'import json, sys; print(json.load(sys.stdin).get("principalId", ""))' \
      <<<"$identity_json"
  )" \
  --all \
  --query "[].{role:roleDefinitionName,scope:scope}" \
  --output table
```

The human assignments must match the three group scopes in the task matrix; no standing Foundry
Account Owner assignment may exist. The PIM eligible principal and activation settings must match the live Entra configuration and
customer change decision. The workload identity shows `implementationSession` as
`03-identity-privileged-access`. One federated
credential shows the exact GitHub issuer, repository environment subject, and Azure token-exchange
audience. The direct assignments are Cognitive Services User on the Foundry resource recorded for
this session and Storage Blob Data Reader on the storage account recorded for this session. There is no subscription-level assignment.

Read the console and stop there. Do not redirect, export, or save this command output.

## After implementation

The following **operating state remains**:

| Operating state | Operating owner |
|---|---|
| Three group-based human role assignments | Customer identity and Foundry owners |
| Foundry Account Owner eligibility and activation settings | Microsoft Entra PIM; customer identity owner |
| Marked user-assigned identity, exact GitHub credential, and two role assignments | Workload and platform owners |
| Bicep definitions, role source, task matrix, PIM change pointer, and support scripts | Customer repository owner |

The workload identity and its federated credential stay in the nonproduction subscription and
resource group recorded for this session. Its roles end at the recorded Foundry resource and storage
account. The credential accepts tokens only from the protected GitHub environment recorded for this
session. Moving any part into production is a separate change.

If a later design needs user-specific downstream authorization, keep this managed identity for the
application-only path and use the
[Delegated API access with OAuth on-behalf-of module](../../../modules/obo-delegated-access/)
instead of widening this session.

The identity owner coordinates removal. First, the workload owner confirms that no workflow uses
the protected GitHub environment credential. Then the platform owner confirms that no approved task
needs either role assignment. Use the approved identity change path to check the
`implementationSession` marker, reject unexpected role assignments, remove the two documented
assignments, and remove the managed identity last. Removing the identity also removes its child
federated credential.

Human group assignments and PIM changes are separate. The identity owner first removes PIM
eligibility, then restores prior role settings if this session changed them. Remove an exact group
assignment only after its Foundry owner confirms that this session created it and no operating task
depends on it. Never disable an emergency-access path from this kit.
