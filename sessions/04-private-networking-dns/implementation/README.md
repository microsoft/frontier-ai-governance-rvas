# Private networking, DNS, and controlled egress

## Session scope

### What we will do

Establish **private connectivity from the approved nonproduction execution host** to Microsoft Foundry,
Storage, Azure AI Search, Azure Cosmos DB, and Azure Key Vault. In the nonproduction subscription
and resource group recorded in the network design record, we deploy or reconcile one spoke, a
private-endpoint subnet, a
dedicated Agent Service subnet, its firewall route, seven private DNS zones and links, and five
private endpoints. We then store all five prior public-access states in the approved operational
system and disable public access.

This session owns the cutover and the observable client result: every configured service FQDN
resolves only to private RFC 1918 addresses and accepts TCP 443 from the approved execution host.

### Why it matters

The private endpoint and DNS path gives service owners a checked route before public endpoints are
disabled. Capturing prior settings first makes lockout recovery possible. The separate Agent
Service subnet and firewall route also prepare the network boundary needed by the agent runtime.

### Boundaries

Live Azure networking, DNS, private endpoint, and service public-access state is authoritative. The
customer firewall source owns egress rules. The approved operational system owns the cutover record;
the repository owns reusable network desired state and decision pointers.

Adapt the Bicep when the landing zone already supplies the VNet or authoritative private DNS zones.
This session does not modify a hub or Virtual WAN, deploy firewall rules, create missing dependency
services, or create an execution host. It does not replace a Foundry account itself. If immutable
`networkInjections` require replacement, the team pauses for a separately approved account
replacement and configuration replay, then returns here to reconcile the Foundry endpoint.

Private DNS and TCP 443 confirm the approved client path, not agent-runtime traffic.
[Session 06](../../06-governed-agent-baseline/implementation/README.md) runs that check from a
Foundry account created with the delegated subnet.

## Architecture

### Architecture at a glance

Clients keep using each service's normal public name. Inside the approved network, private DNS
follows the name's alias, or CNAME, chain into a linked private DNS zone. It returns the private
endpoint's RFC 1918 address, which is reachable only through the private network. The client then
opens TCP 443 to that address. Foundry, Storage, Azure AI Search, Azure Cosmos DB, and Azure Key
Vault all use this path.

Agent Service has a different path. Its dedicated delegated subnet sends the default route to the
customer-managed firewall. Azure owns that route, while the customer firewall source owns the
outbound rules. Keeping those responsibilities apart avoids a false claim that deploying a route
also permits the traffic.

Azure shows the current network, DNS, private endpoints, and public-access settings. Before public
access is disabled, the approved operational system records the previous setting for all five
services. Operators use that record if they need to restore access.

This session proves private DNS resolution and TCP 443 from the approved client. It does not grant
service access or prove Agent runtime traffic. Session 03 supplies the identity boundary, and
[Session 06](../../06-governed-agent-baseline/implementation/README.md) checks the agent path from
the delegated subnet.

![Approved clients use private DNS and endpoints while the delegated Agent Service subnet routes through the customer firewall](../assets/diagrams/private-network-flow.svg)

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Foundry account and Agent subnet | Keep the account only if it was created with the exact delegated subnet. Otherwise, use a separately approved replacement and replay | This respects the network-injection boundary set when the account is created | Replacement needs its own change, configuration replay, and service-owner coordination | Microsoft supports changing network injection in place |
| Private DNS ownership | Reuse authoritative central zones when they exist. Otherwise, create the approved local zones and links | There is one owner for each record, whether resolution is hub, spoke, or hybrid | Central DNS may need artifact changes and conditional forwarding | The resolver, hub, or zone owner changes |
| Agent egress | Send the dedicated Agent subnet's default route to the customer firewall | Azure owns the route; the firewall source owns the rules | A route alone does not prove that a firewall rule exists or that Agent runtime traffic works | Session 06 finds a blocked runtime dependency or the egress design changes |

### Architecture guidance

- [Configure network isolation for Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/how-to/configure-private-link)
- [Networking options for Foundry Agent Service](https://learn.microsoft.com/en-us/azure/foundry/agents/concepts/networking-options)
- [Azure Private Endpoint DNS integration scenarios](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration)

## Before you start

Confirm these prerequisites:

- Sessions 01-03 are complete in the nonproduction subscription and resource group recorded in the
  network design record.
- The Foundry account plus its Storage, Azure AI Search, Cosmos DB, and Key Vault dependencies all
  exist; missing dependency services are not created in this session.
- The AI platform owner has approved any required account replacement and replay of account,
  project, connection, identity, and role configuration.
- Azure CLI with Bicep support is installed and signed in to the approved subscription.
- `Microsoft.App`, `Microsoft.CognitiveServices`, `Microsoft.DocumentDB`, `Microsoft.KeyVault`,
  `Microsoft.Network`, `Microsoft.Search`, and `Microsoft.Storage` are registered.
- The network deployment operator has the time-bound Network Contributor role on the exact
  nonproduction resource group where this session deploys the VNet, subnets, route table, and
  private endpoints.
- The DNS operator has the time-bound Private DNS Zone Contributor role on the resource group that
  contains the seven private DNS zones, or on each reused private DNS zone.
- The Foundry, Storage, Azure AI Search, Cosmos DB, and Key Vault service owners recorded for this session have each
  accepted responsibility for approving the private endpoint connection on their exact service
  through the existing service change process. This session assigns no service-approval role to
  the network deployment operator.
- The landing-zone owner has approved the topology, address ranges, route behavior, and firewall
  next hop.
- The DNS owner has approved central-zone reuse or local-zone creation and any hybrid forwarding.
- An existing execution host inside the approved private network can resolve the service FQDNs.
- The network design record names where the public-access cutover record is stored and who can
  retrieve it during restore. Restore depends on that file.

Do not create a VM, runner, or other resource just for the connectivity check. Do not place any
workload in the delegated Agent Service subnet.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/infra/network/main.bicep`](artifacts/infra/network/main.bicep) | The network deployment pipeline |
| Deployment | [`artifacts/environments/sandbox.bicepparam`](artifacts/environments/sandbox.bicepparam) | The network deployment pipeline |
| Deployment | [`artifacts/network/endpoint-matrix.json`](artifacts/network/endpoint-matrix.json) | The connectivity and public-access cutover scripts |
| Record | [`artifacts/decisions/network-design-record.md`](artifacts/decisions/network-design-record.md) | The network, DNS, firewall, and affected service owners |

Set the approved scope and existing service IDs in the current shell:

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$resourceGroup = "approved-session-04-resource-group"
$foundryResourceId = "from-approved-configuration-system"
$storageResourceId = "from-approved-configuration-system"
$searchResourceId = "from-approved-configuration-system"
$cosmosResourceId = "from-approved-configuration-system"
$keyVaultResourceId = "from-approved-configuration-system"
$cutoverRecordPath = "C:\approved-operations\session-04\public-access-cutover.json"

$resourceIds = @(
  $foundryResourceId
  $storageResourceId
  $searchResourceId
  $cosmosResourceId
  $keyVaultResourceId
)
```
```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:-}"
resource_group="approved-session-04-resource-group"
foundry_resource_id="from-approved-configuration-system"
storage_resource_id="from-approved-configuration-system"
search_resource_id="from-approved-configuration-system"
cosmos_resource_id="from-approved-configuration-system"
key_vault_resource_id="from-approved-configuration-system"
cutover_record_path="/approved-operations/session-04/public-access-cutover.json"

resource_ids=(
  "$foundry_resource_id"
  "$storage_resource_id"
  "$search_resource_id"
  "$cosmos_resource_id"
  "$key_vault_resource_id"
)
```

## Decisions and stop conditions

Complete the
[`network-design-record.md`](artifacts/decisions/network-design-record.md) and every
`__REQUIRED_*__` value in a customer working copy. Do not commit live values to this kit.

### Foundry account and subnet

**Foundry Agent Service BYO VNet injection is an account-create setting.** It cannot be added to an
existing account or moved to another delegated subnet. The AI platform owner must make one
decision:

1. confirm that the existing account already references this exact Agent Service subnet; or
2. approve a controlled replacement, name the change owner, and approve replay of the approved
   project, connections, identities, role assignments, and model deployments.

All five service resources must exist before public-access cutover. Stop when Foundry, Storage,
Azure AI Search, Cosmos DB, or Key Vault is missing. Stop if the AI platform owner has not decided
whether to keep or replace the Foundry account, the change authority has not approved required
replacement and replay, or the restore owner is missing. This session configures networking; it
does not create a missing dependency service.

### Topology, addressing, DNS, and egress

The network, DNS, and firewall owners must agree on:

- the spoke attachment or approved existing-VNet pattern;
- nonoverlapping RFC 1918 ranges, with an Agent subnet of `/27` or larger;
- one authoritative instance of each required private DNS zone;
- the resolver and conditional-forwarding route for hybrid clients; and
- a default route to one customer-approved firewall and the customer firewall repository or policy
  reference that owns outbound rules.

Stop if an address overlaps a connected or reserved range. Stop if the proposed deployment
duplicates a central private DNS zone, uses the Agent subnet for another workload, or needs a
blanket internet rule.

### Public-access cutover

The affected service owners approve the maintenance window. The network design record names where
the restore record is stored and who can retrieve it. The cutover script must run from the
approved private execution host. It checks every configured endpoint
before changing public access, writes all five prior states atomically to the external cutover
record, and adds `networkControlSession=04-private-networking-dns` without replacing existing tags.

Stop before cutover when:

- any private endpoint connection is not approved;
- a configured FQDN does not resolve only to RFC 1918 IPv4 addresses;
- TCP 443 fails for any configured endpoint;
- the complete cutover record cannot be written outside the repository; or
- no owner can restore access during the maintenance window.

After cutover, stop all further changes if private DNS or TCP 443 connectivity fails. Restore the
recorded prior states before considering network removal. Never remove private connectivity while
public access is still disabled or the approved execution host cannot reach the services.

## Implement

### 1. Resolve the implementation files

Complete the parameter file, endpoint matrix, and network design record in the customer working
copy. The design record must point to the customer firewall source that owns outbound rules. If the
customer uses central private DNS, change the Bicep to reference the existing zones. Keep one
**authoritative zone per service**. The Microsoft Foundry
[end-to-end network-isolation sample](https://github.com/microsoft-foundry/foundry-samples/tree/main/infrastructure/infrastructure-setup-bicep/15-private-network-standard-agent-setup)
shows the supported resource relationships; keep this session’s approved names, scopes, and
customer-owned firewall design.

The endpoint contract is:

| Service | Subresource | Private DNS zone |
|---|---|---|
| Foundry | `account` | `privatelink.cognitiveservices.azure.com` |
| Foundry | `account` | `privatelink.openai.azure.com` |
| Foundry | `account` | `privatelink.services.ai.azure.com` |
| Storage | `blob` | `privatelink.blob.core.windows.net` |
| Azure AI Search | `searchService` | `privatelink.search.windows.net` |
| Cosmos DB | `Sql` | `privatelink.documents.azure.com` |
| Key Vault | `vault` | `privatelink.vaultcore.azure.net` |

Applications keep using their normal service FQDNs. Inside the approved network, DNS follows the
service CNAME into the private zone and returns the private-endpoint address.

### 2. Run preflight and inspect `what-if`

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroup
```
```bash
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --resource-group-name "$resource_group"
```

Preflight rejects unresolved decisions and parses all five service IDs from the parameter file. It
requires a unique live resource for each alias in the approved subscription and exact resource
group, checks its expected Azure resource type, verifies required providers, builds the Bicep, and
runs a resource-group `what-if`.

Review the preview with the network and DNS owners. Expect the approved VNet, route table, two
subnets, seven zones and links, and five private endpoints. Stop on any delete, replacement,
unapproved zone, unexpected resource group, Foundry deployment, hub change, or public-access
change.

### 3. Deploy the network, DNS, and initial private endpoints

```powershell
$artifacts = Resolve-Path .\artifacts

az deployment group create `
  --resource-group $resourceGroup `
  --name rvas-s04-private-network `
  --template-file "$artifacts\infra\network\main.bicep" `
  --parameters "$artifacts\environments\sandbox.bicepparam" `
  --only-show-errors
```
```bash
artifacts_dir="$(cd ./artifacts && pwd)"

az deployment group create \
  --resource-group "$resource_group" \
  --name rvas-s04-private-network \
  --template-file "$artifacts_dir/infra/network/main.bicep" \
  --parameters "$artifacts_dir/environments/sandbox.bicepparam" \
  --only-show-errors
```

Approve pending private endpoint connections through each service owner when the deployment
operator lacks approval rights. Public access stays unchanged. If Foundry replacement is required,
the dependency endpoints can remain, but the Foundry endpoint must be updated after replacement.

### 4. Replace and replay the Foundry account when approved

Skip this step when the existing account already uses the exact Agent Service subnet. Otherwise,
the change owner listed in the network design record replaces the Foundry account through the separately approved change and
replays the approved project, connections, identities, role assignments, and model deployments.
This kit does not create the replacement account or dependency services.

### 5. Integrate customer DNS and firewall policy

Link the authoritative zones to every approved client or resolver VNet. For hybrid resolution,
forward the public service zones through an Azure-side DNS forwarder or Azure Private Resolver.
On-premises DNS cannot query Azure's `168.63.129.16` virtual IP directly.

Use the customer firewall repository or policy system listed in the network design record. That
source owns reviewed Microsoft Entra destinations and any tool-specific destinations. Session 04
does not copy or deploy those rules. Do not add a blanket internet rule to make preflight pass.
Session 06 confirms that agent-runtime traffic follows the prepared route.

### 6. Reconcile five resource IDs and check connectivity

The AI platform owner confirms that the existing account needed no replacement or that the approved
replacement and replay completed. The network owner then points the Foundry private endpoint and
DNS zone group at the existing or replacement account. Each service owner confirms the current
resource ID for Foundry, Storage, Azure AI Search, Cosmos DB, and Key Vault. Update the runtime
variables and endpoint matrix, then run `connectivity-check` from the approved execution host.

Continue only when all five FQDNs resolve to RFC 1918 addresses and accept TCP 443.

### 7. Record prior states and disable public access

Run this command from the same approved private execution host:

![The cutover checks private DNS and TCP 443, stores all five prior public-access states, and passes a confirmation gate before public access is disabled](../assets/diagrams/public-access-cutover.svg)

The left side must finish before the first service update. A failed check or incomplete cutover
record stops the sequence.

```powershell
.\scripts\public-access-cutover.ps1 `
  -FoundryResourceId $foundryResourceId `
  -StorageResourceId $storageResourceId `
  -SearchResourceId $searchResourceId `
  -CosmosResourceId $cosmosResourceId `
  -KeyVaultResourceId $keyVaultResourceId `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroup `
  -EndpointMatrixPath .\artifacts\network\endpoint-matrix.json `
  -CutoverRecordPath $cutoverRecordPath `
  -Confirm
```
```bash
./scripts/public-access-cutover.sh \
  --foundry-resource-id "$foundry_resource_id" \
  --storage-resource-id "$storage_resource_id" \
  --search-resource-id "$search_resource_id" \
  --cosmos-resource-id "$cosmos_resource_id" \
  --key-vault-resource-id "$key_vault_resource_id" \
  --approved-subscription-id "$approved_subscription_id" \
  --resource-group-name "$resource_group" \
  --endpoint-matrix-path ./artifacts/network/endpoint-matrix.json \
  --cutover-record-path "$cutover_record_path" \
  --confirm
```

The script first confirms that the five unique service IDs use the expected Azure resource types,
belong to the approved subscription and resource group, and correspond to the five current endpoint
aliases. It then checks private connectivity and records all five prior public-access states in the
restore record store. The script merges the Session 04 marker and requests `Disabled` on each
service. Each record update replaces the file atomically. `<cutover-record>.previous` keeps the
prior valid version. Keep both files where the restore owner can retrieve them.

If any update fails, do not rerun the command blindly. Inspect the cutover record, identify which
services changed, and start the manual restore procedure.

## Confirm the result

From the **same approved private execution host**, run one check against the current endpoint matrix:

```powershell
.\scripts\connectivity-check.ps1 `
  -EndpointMatrixPath .\artifacts\network\endpoint-matrix.json
```
```bash
./scripts/connectivity-check.sh \
  --endpoint-matrix-path ./artifacts/network/endpoint-matrix.json
```

Each configured service alias must resolve only to RFC 1918 IPv4 addresses and accept TCP 443. The
script prints the result and exits. It does not create a resource or save a result file.

## After implementation

Keep the **approved private network path in operation**, including the spoke or approved VNet
changes, Agent Service subnet, private-endpoint subnet, firewall route, private endpoints, DNS
configuration, customer firewall source reference, and disabled public-access settings.
The network owner owns the subnets and route. DNS and firewall owners own their respective
configuration. Each service owner owns its private endpoint and public-access setting.

Store the external public-access cutover record in the system listed in the network design record.
Keep both the current file and the `.previous` copy where the restore owner can retrieve them. The
record exists only to restore the exact prior state.

Run this implementation only in the nonproduction subscription and resource group recorded in the
network design record.
Production needs its own address, DNS, firewall, change-window, and service-owner decisions. Agent Service runtime traffic remains unconfirmed until
[Session 06](../../06-governed-agent-baseline/implementation/README.md) runs an agent from a
Foundry account created with this subnet.

Keep the operational control in place by default. If access must be restored, the network owner,
DNS owner, firewall owner, affected service owners, security owner, and change authority review the
cutover record before any change.

Restore each service's recorded public-access state first. Then confirm that the approved execution
host can still reach each service. Remove marked Session 04 network resources only after those
checks pass. Do not remove network resources when any recorded prior state is not `Enabled`, when a
VNet link in a marked private DNS zone lacks the Session 04 marker, or when a service was already
private-only before this session and has no other approved access path.
