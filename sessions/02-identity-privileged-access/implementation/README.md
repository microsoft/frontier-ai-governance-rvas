# Implement Entra identity, RBAC, PIM, and workload identities

## Session scope

### What we will do

Configure four customer-owned groups and one workload identity in the approved nonproduction
resource group.

Project managers receive Foundry Project Manager on the Foundry resource. Developers receive
Foundry User on one project, and auditors receive Reader on the Foundry resource. The
platform-administrator group becomes PIM-eligible for Foundry Account Owner on that resource.

Deploy a user-assigned managed identity with no client secret. Its federated credential trusts one
protected GitHub environment. Cognitive Services User applies at the Foundry resource, and Storage
Blob Data Reader applies at the approved storage account. The final check compares this live state
with the approved design.

### Why it matters

Groups handle normal access. PIM limits elevated administration through approval, MFA,
justification, and a two-hour activation. GitHub authenticates without a stored Azure client
secret, and its workload roles stay at two named resources.

### Boundaries

Azure RBAC and Microsoft Entra PIM hold live human-access state. The managed identity and its
federated credential hold the GitHub trust. The repository owns the Bicep definitions and stable
role IDs.

This session changes one approved nonproduction Foundry resource, one project, and one storage
account. The workload path is application-only; it does not carry a signed-in user's authority.
[Session 05](../../05-governed-agent-baseline/implementation/README.md) configures the Foundry
Agent ID and assigns Foundry Agent Consumer when needed. Use the
[delegated OBO module](../../../modules/obo-delegated-access/) when a downstream API must authorize
each signed-in user. Azure DevOps uses its own workload identity service-connection path.

## Architecture

### Architecture at a glance

People receive Azure roles through customer-owned groups. Project managers, developers, and
auditors have standing assignments at the resource or project they need. Platform administrators
activate Foundry Account Owner through PIM.

GitHub presents an OIDC token for one protected environment. Microsoft Entra ID accepts it only
when the issuer, subject, and audience exactly match the federated credential on the user-assigned
managed identity. Azure then applies that identity's two resource-scoped roles.

![Exact GitHub OIDC claims federate to a managed identity with resource-scoped Azure roles.](../assets/diagrams/oidc-trust-scope.svg)

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Normal human access | Customer-owned groups at the Foundry resource or project | Membership changes do not require direct-user role assignments | The identity owner must manage and review membership | A task needs a different role or scope |
| Elevated administration | Foundry Account Owner through PIM | Elevated access expires and requires approval | Requires Entra licensing, approvers, and activation | The emergency-access or approval model changes |
| GitHub authentication | Exact environment OIDC trust on a user-assigned managed identity | No Azure client secret | Repository or environment changes require a trust update | Authority must vary by signed-in user |
| Agent endpoint access | Defer Foundry Agent Consumer to Session 05 | Caller and agent scope are known before assignment | This session does not grant agent endpoint access | Session 05 approves callers |

### Architecture guidance

- [Role-based access control for Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/concepts/rbac-foundry)
- [Configure Azure resource role settings in PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-resource-roles-configure-role-settings)
- [Create trust for a user-assigned managed identity](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust-user-assigned-managed-identity)

## Before you start

Complete [Session 01](../../01-platform-baseline/implementation/README.md). Have these items ready:

- the approved nonproduction subscription, resource group, Foundry resource, project, and storage
  account;
- object IDs for the platform-administrator, project-manager, developer, and auditor groups;
- time-bound Owner or User Access Administrator for the role-assignment operator on the resource
  group;
- Owner or User Access Administrator for the PIM operator on the Foundry resource;
- Microsoft Entra ID P2 or Microsoft Entra ID Governance licensing, a customer-owned PIM approver
  group, and the approved eligibility expiry; and
- the GitHub owner, repository, and protected environment.

Keep tenant coordinates and object IDs in the shell or the customer's configuration system. Do
not put secrets or customer content in the repository.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/identity/workload-identity.bicep`](artifacts/identity/workload-identity.bicep) | The workload identity deployment pipeline |
| Deployment | [`artifacts/identity/human-role-assignments.bicep`](artifacts/identity/human-role-assignments.bicep) | The human-access deployment pipeline |
| Deployment | [`artifacts/identity/role-definitions.json`](artifacts/identity/role-definitions.json) | The identity Bicep builds and preflight scripts |

## Decisions and stop conditions

Record the approved resources, group object IDs, PIM owner and approvers, eligibility expiry, and
GitHub environment in the customer change system.

| Access | Role | Scope | Assignment |
|---|---|---|---|
| Platform administration | Foundry Account Owner | Foundry resource | PIM eligible |
| Project management | Foundry Project Manager | Foundry resource | Group |
| Project work | Foundry User | One Foundry project | Group |
| Configuration inspection | Reader | Foundry resource | Group |
| Agent endpoint invocation | Foundry Agent Consumer | Project or individual agent | Deferred to Session 05 |

Role names may appear under their earlier Azure AI names while the rename reaches each tool. The
stable IDs and expected names are in `role-definitions.json`; preflight resolves them live. Stop if
a role does not resolve, its type is not `BuiltInRole`, or its permissions no longer fit the task.
Do not replace these assignments with the broader Foundry Owner role.

PIM settings apply to one role on one resource. Set a maximum two-hour activation and require MFA,
justification, and approval. Stop if the principal, resource, owner, approver group, or expiry is
missing; if the change affects shared PIM policy or emergency access; or if anyone proposes a
permanent active Foundry Account Owner assignment.

The GitHub credential must use these exact claims:

| Claim | Value |
|---|---|
| Issuer | `https://token.actions.githubusercontent.com` |
| Subject | `repo:OWNER/REPOSITORY:environment:ENVIRONMENT` |
| Audience | `api://AzureADTokenExchange` |

The subject does not support wildcards. Stop if the trust covers multiple repositories, all
branches, or an unprotected environment. Do not create a client secret as a fallback.

Also stop when:

- the scope is production, shared with production, or not approved;
- a preview creates an assignment above the documented Foundry resource, project, or storage
  account;
- an unexpected direct-user assignment appears on the Foundry resource or project; or
- a check would read model responses, blobs, secrets, or other customer content.

## Implement

### 1. Set inputs and run preflight

Replace the required GitHub environment placeholder in `workload-identity.bicep`, then set the
command variables in the current shell.

```powershell
$resourceGroup = "<approved-resource-group>"
$foundryAccountName = "<foundry-resource>"
$foundryProjectName = "<foundry-project>"
$storageAccountName = "<storage-account>"
$projectManagerGroupObjectId = "<group-object-id>"
$developerGroupObjectId = "<group-object-id>"
$auditorGroupObjectId = "<group-object-id>"
$githubOwner = "<github-owner>"
$githubRepository = "<github-repository>"
$githubEnvironment = "<protected-environment>"
$expiryDate = "<yyyy-MM-dd>"
.\scripts\preflight.ps1 -ResourceGroupName $resourceGroup
```

```bash
resource_group="<approved-resource-group>"
foundry_account_name="<foundry-resource>"
foundry_project_name="<foundry-project>"
storage_account_name="<storage-account>"
project_manager_group_object_id="<group-object-id>"
developer_group_object_id="<group-object-id>"
auditor_group_object_id="<group-object-id>"
github_owner="<github-owner>"
github_repository="<github-repository>"
github_environment="<protected-environment>"
expiry_date="<yyyy-MM-dd>"
./scripts/preflight.sh --resource-group-name "$resource_group"
```

Preflight checks the active subscription and resource group, unresolved sentinels, stable role
definitions, and both Bicep builds. Stop on any failure.

### 2. Preview and deploy standing human roles

```powershell
$humanParameters = @(
  "foundryAccountName=$foundryAccountName"
  "foundryProjectName=$foundryProjectName"
  "projectManagerGroupObjectId=$projectManagerGroupObjectId"
  "developerGroupObjectId=$developerGroupObjectId"
  "auditorGroupObjectId=$auditorGroupObjectId"
)
az deployment group what-if --resource-group $resourceGroup --name rvas-s02-human-rbac-preview --template-file .\artifacts\identity\human-role-assignments.bicep --parameters $humanParameters --only-show-errors
```

```bash
human_parameters=(
  "foundryAccountName=$foundry_account_name"
  "foundryProjectName=$foundry_project_name"
  "projectManagerGroupObjectId=$project_manager_group_object_id"
  "developerGroupObjectId=$developer_group_object_id"
  "auditorGroupObjectId=$auditor_group_object_id"
)
az deployment group what-if --resource-group "$resource_group" --name rvas-s02-human-rbac-preview --template-file ./artifacts/identity/human-role-assignments.bicep --parameters "${human_parameters[@]}" --only-show-errors
```

The preview must show the three documented group assignments and no standing Foundry Account Owner
assignment. After the change owner approves it, deploy:

```powershell
az deployment group create --resource-group $resourceGroup --name rvas-s02-human-rbac --template-file .\artifacts\identity\human-role-assignments.bicep --parameters $humanParameters --only-show-errors
```

```bash
az deployment group create --resource-group "$resource_group" --name rvas-s02-human-rbac --template-file ./artifacts/identity/human-role-assignments.bicep --parameters "${human_parameters[@]}" --only-show-errors
```

### 3. Configure PIM elevation

In Microsoft Entra admin center, open **ID Governance > Privileged Identity Management > Azure
resources**. Select the approved Foundry resource and Foundry Account Owner role. Set the
two-hour activation limit, MFA, justification, approval, approver group, notifications, and
eligibility expiry. Add the platform-administrator group as eligible.

Use the customer identity process for any setting shared with other eligible principals. If the
customer requires reauthentication on every activation, use its approved Conditional Access
authentication context and sign-in frequency.

### 4. Preview and deploy the workload identity

```powershell
$workloadParameters = @(
  "foundryAccountName=$foundryAccountName"
  "storageAccountName=$storageAccountName"
  "githubOwner=$githubOwner"
  "githubRepository=$githubRepository"
  "githubEnvironment=$githubEnvironment"
  "expiryDate=$expiryDate"
)
az deployment group what-if --resource-group $resourceGroup --name rvas-s02-workload-identity-preview --template-file .\artifacts\identity\workload-identity.bicep --parameters $workloadParameters --only-show-errors
```

```bash
workload_parameters=(
  "foundryAccountName=$foundry_account_name"
  "storageAccountName=$storage_account_name"
  "githubOwner=$github_owner"
  "githubRepository=$github_repository"
  "githubEnvironment=$github_environment"
  "expiryDate=$expiry_date"
)
az deployment group what-if --resource-group "$resource_group" --name rvas-s02-workload-identity-preview --template-file ./artifacts/identity/workload-identity.bicep --parameters "${workload_parameters[@]}" --only-show-errors
```

The preview must show the named identity, exact GitHub subject, Cognitive Services User on the
Foundry resource, and Storage Blob Data Reader on the storage account. After approval, deploy:

```powershell
az deployment group create --resource-group $resourceGroup --name rvas-s02-workload-identity --template-file .\artifacts\identity\workload-identity.bicep --parameters $workloadParameters --only-show-errors
```

```bash
az deployment group create --resource-group "$resource_group" --name rvas-s02-workload-identity --template-file ./artifacts/identity/workload-identity.bicep --parameters "${workload_parameters[@]}" --only-show-errors
```

Set `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID` in the protected GitHub
environment. The workflow needs `id-token: write`; it does not need an Azure client secret.

## Confirm the result

Confirm the three group assignments and no standing Foundry Account Owner assignment. In PIM,
check the eligible platform-administrator group, two-hour activation, MFA, justification,
approval, approver group, and expiry.

Inspect the workload identity:

```powershell
$identity = az identity show --resource-group $resourceGroup --name id-rvas-s02-workload --output json | ConvertFrom-Json
$identity | Select-Object name, clientId, @{Name="implementationSession";Expression={$_.tags.implementationSession}}
az identity federated-credential list --resource-group $resourceGroup --identity-name $identity.name --query "[].{name:name,issuer:issuer,subject:subject,audience:audiences[0]}" --output table
az role assignment list --assignee-object-id $identity.principalId --all --query "[].{role:roleDefinitionName,scope:scope}" --output table
```

```bash
identity_json="$(az identity show --resource-group "$resource_group" --name id-rvas-s02-workload --output json --only-show-errors)"
python3 -c 'import json,sys; i=json.load(sys.stdin); print(i["name"], i["clientId"], (i.get("tags") or {}).get("implementationSession",""))' <<<"$identity_json"
az identity federated-credential list --resource-group "$resource_group" --identity-name id-rvas-s02-workload --query "[].{name:name,issuer:issuer,subject:subject,audience:audiences[0]}" --output table
principal_id="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["principalId"])' <<<"$identity_json")"
az role assignment list --assignee-object-id "$principal_id" --all --query "[].{role:roleDefinitionName,scope:scope}" --output table
```

The marker must be `02-identity-privileged-access`. One credential must show the exact issuer,
environment subject, and audience. The two workload roles must use the approved Foundry resource
and storage account, with no subscription-level assignment. Read the console and stop.

## After implementation

| What remains | Owner |
|---|---|
| Three group-based human assignments | Customer identity and Foundry owners |
| Foundry Account Owner eligibility, settings, and access reviews | Customer identity owner in Microsoft Entra PIM |
| Managed identity, GitHub credential, and two workload roles | Workload and platform owners |
| Bicep, role definitions, and preflight scripts | Customer repository owner |

Keep this state in the approved nonproduction scope. Production needs a separate change.

To restore the prior state, the identity owner first removes PIM eligibility and restores any role
settings changed by this session. Remove a group assignment only after the Foundry owner confirms
that Session 02 created it and no operating task needs it. Do not change emergency access.

For the workload identity, first confirm that no workflow uses the protected GitHub environment.
Check the `implementationSession` marker and verify that the identity has only the two documented
role assignments. Remove those assignments, then remove the marked identity; deleting it also
removes its federated credential. Use the approved identity change path for every removal.

The identity owner also creates or updates the recurring
[PIM access review](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-create-roles-and-resource-roles-review)
for eligible and active privileged assignments.
