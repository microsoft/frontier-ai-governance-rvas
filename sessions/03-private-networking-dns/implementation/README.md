# Private networking, DNS, and controlled egress

## Session scope

### What we will do

Connect the approved nonproduction execution host to Microsoft Foundry, Storage, Azure AI Search,
Azure Cosmos DB, and Azure Key Vault over private networking. Session 01 remains the declarative
owner of the VNet, delegated Agent Service subnet, private-endpoint subnet, and firewall route.
This session uses their resource IDs to deploy seven private DNS zones and links plus five private
endpoints. The scripts derive three Foundry endpoint families and four dependency FQDNs from the
approved resource IDs. Record the five public-access states in the approved change system before
you disable public access.

Complete the cutover, then verify that all seven configured endpoint FQDNs resolve to private RFC
1918 addresses and that the approved execution host can reach each endpoint on TCP 443.

### Why it matters

The private endpoint and DNS path gives service owners a tested route before they disable public
endpoints. The prior settings support recovery if the cutover blocks access. Session 01 has already
prepared the Agent Service subnet and firewall route for the agent runtime.

### Boundaries

Azure holds the current network, DNS, private endpoint, and service public-access state. The
customer firewall source holds egress rules. Store cutover and restore details in the approved
change system. The repository's Bicep files define the reusable network configuration.

Session 01 supplies the VNet and subnets as existing resource IDs. This session does not deploy,
tag, or modify that foundation. Before the session, choose this customer-managed BYO VNet path or
Microsoft-managed networking. Stop until the owner makes that choice. Do not combine the two
designs in one deployment.
This session does not modify a hub or Virtual WAN, deploy firewall rules, create missing dependency
services, create an execution host, or replace a Foundry account. An existing account without the
approved BYO VNet injection must complete a separate approved migration before it enters this route.

Private DNS and TCP 443 confirm the approved client path, not agent-runtime traffic.
[Session 05](../../05-governed-agent-baseline/implementation/README.md) runs that check from a
Foundry account created with the delegated subnet.

## Architecture

### Architecture at a glance

Clients keep using each service's normal public name. Inside the approved network, private DNS
follows the name's alias, or CNAME, chain into a linked private DNS zone. It returns the private
endpoint's RFC 1918 address. The client opens TCP 443 to that address over the private network.
Foundry can expose `cognitiveservices.azure.com`,
`openai.azure.com`, and `services.ai.azure.com`; the scripts derive every family from the Foundry
resource ID. Storage, Azure AI Search, Azure Cosmos DB, and Azure Key Vault use the same private
DNS pattern.

Agent Service has a different path. Its dedicated delegated subnet sends the default route to the
customer-managed firewall. Azure configures the route. Firewall administrators maintain outbound
rules in the customer firewall source. A route does not prove that the firewall permits traffic.

Azure shows the current network, DNS, private endpoints, and public-access settings. Before the
cutover, the cutover owner records the previous setting for all five services in the approved
change system. Operators use that record to restore access if needed.

This session confirms private DNS resolution and TCP 443 from the approved client. It does not
grant service access or prove Agent runtime traffic. Session 02 configures identity and access,
[Session 05](../../05-governed-agent-baseline/implementation/README.md) checks the agent path from
the delegated subnet.

![Approved clients use private DNS and endpoints while the delegated Agent Service subnet routes through the customer firewall](../assets/diagrams/private-network-flow.svg)

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Foundry account and Agent subnet | Consume the Session 01 account and its recorded network pattern | Session 01 creates the immutable BYO VNet setting before any agent work starts | An incompatible existing account must migrate outside this series | The selected account or network pattern changes |
| Network ownership | Session 01 owns the customer-managed BYO VNet foundation; these files consume its resource IDs | One deployment owns address space, routing, subnets, and firewall policy | Microsoft-managed networking follows a different architecture and delivery path | The platform owner selects Microsoft-managed networking before delivery |
| Private DNS ownership | Reuse central zones when they are authoritative. Otherwise, create approved local zones and links | Each record has one owner across hub, spoke, or hybrid resolution | Central DNS may need Bicep changes and conditional forwarding | The resolver, hub, or zone owner changes |
| Agent egress | Send the dedicated Agent subnet's default route to the customer firewall | Azure owns the route; firewall administrators own the rules | A route does not prove that a rule exists or that agent-runtime traffic works | Session 05 finds a blocked runtime dependency or the egress design changes |

### Architecture guidance

- [Configure network isolation for Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/how-to/configure-private-link)
- [Networking options for Foundry Agent Service](https://learn.microsoft.com/en-us/azure/foundry/agents/concepts/networking-options)
- [Azure Private Endpoint DNS integration scenarios](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration)

## Before you start

Confirm these prerequisites:

- Sessions 01 and 02 are complete in the approved nonproduction subscription and resource group.
- The parameter file identifies the Session 01-owned VNet and private-endpoint subnet resource IDs.
- The Foundry account plus its Storage, Azure AI Search, Cosmos DB, and Key Vault dependencies all
  exist; missing dependency services are not created in this session.
- `Microsoft.App`, `Microsoft.CognitiveServices`, `Microsoft.DocumentDB`, `Microsoft.KeyVault`,
  `Microsoft.Network`, `Microsoft.Search`, and `Microsoft.Storage` are registered.
- The network deployment operator has the time-bound Network Contributor role on the exact
  nonproduction resource group where this session deploys private endpoints.
- The DNS operator has the time-bound Private DNS Zone Contributor role on the resource group that
  contains the seven private DNS zones, or on each reused private DNS zone.
- The Entra object IDs for the network and DNS operators are available for preflight.
- The Foundry, Storage, Azure AI Search, Cosmos DB, and Key Vault service owners recorded for this session have each
  accepted responsibility for approving the private endpoint connection on their exact service
  through the existing service change process. This session assigns no service-approval role to
  the network deployment operator.
- The landing-zone owner has approved the topology, address ranges, route behavior, and firewall
  next hop.
- The DNS owner has approved central-zone reuse or local-zone creation and any hybrid forwarding.
- An existing execution host inside the approved private network can resolve the service FQDNs.
- Before public access changes, the approved change record identifies the cutover owner, restore
  owner, and record location.

Do not create a VM, runner, or other resource just for the connectivity check. Do not place any
workload in the delegated Agent Service subnet.

Use the repository Execution environment section in README.md for client setup.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/infra/network/main.bicep`](artifacts/infra/network/main.bicep) | The network deployment pipeline |
| Deployment | [`artifacts/environments/sandbox.bicepparam`](artifacts/environments/sandbox.bicepparam) | The network deployment pipeline |

## Decisions and stop conditions

Complete every `__REQUIRED_*__` value in the parameter file in a customer working copy. Record
approval, topology, firewall, DNS, and restore decisions in their approved systems, not in this
repository.

### Foundry account and subnet

Foundry Agent Service BYO VNet injection is an **account-create setting**. Session 01 records the
selected network pattern and, when applicable, creates the account with the approved delegated
subnet. All five service resources must exist before public-access cutover. Stop if Foundry,
Storage, Azure AI Search, Cosmos DB, or Key Vault is missing, the Foundry account does not match
its Session 01 pattern, or no restore owner is named.

The AI platform owner must also confirm the network architecture before delivery. These deployment
files implement the customer-managed BYO VNet path. Microsoft-managed networking uses managed
private endpoints and different ownership boundaries. If the owner selects it, stop and use that
path instead of changing these deployment files.

### Topology, addressing, DNS, and egress

The network, DNS, and firewall owners must agree on:

- the spoke attachment or approved existing-VNet pattern;
- nonoverlapping RFC 1918 ranges, with an Agent subnet of `/27` or larger;
- one authoritative instance of each required private DNS zone;
- the resolver and conditional-forwarding route for hybrid clients; and
- a default route to one customer-approved firewall and the customer firewall repository or policy
  reference where outbound rules are maintained. That source must include the Microsoft Entra
  access rule required by Agent Service, feature-specific destinations in scope, and confirmation
  that TLS inspection does not inject an untrusted certificate.

Stop if an address overlaps a connected or reserved range. Also stop if the deployment duplicates a
central private DNS zone, reuses the Agent subnet for another workload, or needs a blanket internet
rule. For central zones, update `main.bicep` to reference the approved zone resource IDs and remove
the local zone and link declarations. Keep the private endpoints and DNS zone groups in
`main.bicep`. The DNS operator manages VNet links, forwarding, and zone records through the central
DNS deployment. If a shared zone also serves public resources of the same type, the DNS owner must
record the fallback-to-Internet setting or another resolution path before linking the zone.

Portal and Agent Playground users must use the approved private execution host or the
customer-approved VPN, ExpressRoute, or Bastion access pattern. Their browser must resolve the
same private service addresses as the execution host.

### Public-access cutover

Affected service owners approve the maintenance window. The approved change record identifies where
prior states are stored and who can retrieve them. Run the cutover script from the approved private
execution host. It derives every endpoint from the parameter file, checks private connectivity,
displays the five current public-access states, and adds
`networkControlSession=03-private-networking-dns` without replacing existing tags.

**Stop before cutover** when:

- any private endpoint connection is not approved;
- any of the three in-use Foundry endpoint families or four dependency FQDNs does not resolve only
  to RFC 1918 IPv4 addresses;
- TCP 443 fails for any configured endpoint;
- the displayed prior states have not been recorded in the approved change system; or
- no owner can restore access during the maintenance window.

After cutover, stop all further changes if private DNS or TCP 443 fails. Restoring the recorded
prior states does not detach the injected subnet. Keep the Agent subnet, route, and VNet while the
Foundry account still uses network injection. Do not remove private connectivity while public
access is disabled or the approved execution host cannot reach the services.

## Implement

### 1. Configure the implementation files

Complete the parameter file in the customer working copy. In the approved change record, name the
customer firewall repository or policy system that maintains outbound rules. If the customer uses
central private DNS, change the same Bicep file to reference existing zone IDs and remove local
zone and link declarations. Keep one authoritative zone per service. The Microsoft Foundry
[end-to-end network-isolation sample](https://github.com/microsoft-foundry/foundry-samples/tree/main/infrastructure/infrastructure-setup-bicep/16-private-network-standard-agent-setup)
shows the supported resource relationships. Keep this session's approved names, scopes, and
customer-owned firewall design.

Configure these endpoint subresources and private DNS zones:

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

Set the approved scope, operator object IDs, DNS assignment scope, and existing service IDs in your
shell. Provide every resource-group or private-zone scope where the DNS operator has Private DNS
Zone Contributor for preflight to inspect:

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$resourceGroup = "approved-session-04-resource-group"
$networkOperatorObjectId = "network-operator-object-id"
$dnsOperatorObjectId = "dns-operator-object-id"
$dnsScopeResourceIds = @(
  "/subscriptions/$approvedSubscriptionId/resourceGroups/approved-dns-resource-group"
)
$cutoverChangeReference = "approved-change-reference"
```
```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:-}"
resource_group="approved-session-04-resource-group"
network_operator_object_id="network-operator-object-id"
dns_operator_object_id="dns-operator-object-id"
dns_scope_resource_id="/subscriptions/$approved_subscription_id/resourceGroups/approved-dns-resource-group"
cutover_change_reference="approved-change-reference"
```

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroup `
  -NetworkOperatorObjectId $networkOperatorObjectId `
  -DnsOperatorObjectId $dnsOperatorObjectId `
  -DnsScopeResourceId $dnsScopeResourceIds
```
```bash
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --resource-group-name "$resource_group" \
  --network-operator-object-id "$network_operator_object_id" \
  --dns-operator-object-id "$dns_operator_object_id" \
  --dns-scope-resource-id "$dns_scope_resource_id"
```

Repeat `-DnsScopeResourceId` or `--dns-scope-resource-id` when the DNS operator has separate
assignments on individual reused zones.

Preflight rejects unresolved decisions and parses all five service IDs from the parameter file. It
requires one live resource for each alias in the approved subscription and resource group. It checks
Network Contributor and Private DNS Zone Contributor at the supplied scopes, verifies providers,
builds the Bicep, and runs a resource-group `what-if`.

Review the preview with the network and DNS owners. Expect the approved VNet, route table, two
subnets, seven zones and links, and five private endpoints. Stop on a delete, replacement,
unapproved zone, unexpected resource group, Foundry deployment, hub change, or public-access
change.

### 3. Deploy the network, DNS, and initial private endpoints

```powershell
$artifacts = Resolve-Path .\artifacts

az deployment group create `
  --resource-group $resourceGroup `
  --name rvas-s03-private-network `
  --template-file "$artifacts\infra\network\main.bicep" `
  --parameters "$artifacts\environments\sandbox.bicepparam" `
  --only-show-errors
```
```bash
artifacts_dir="$(cd ./artifacts && pwd)"

az deployment group create \
  --resource-group "$resource_group" \
  --name rvas-s03-private-network \
  --template-file "$artifacts_dir/infra/network/main.bicep" \
  --parameters "$artifacts_dir/environments/sandbox.bicepparam" \
  --only-show-errors
```

Each service owner approves a pending private endpoint connection if the deployment operator lacks
approval rights. Public access stays unchanged.

### 4. Integrate customer DNS and firewall policy

Link the authoritative zones to every approved client or resolver VNet. For hybrid resolution,
forward the public service zones through an Azure-side DNS forwarder or Azure Private Resolver.
On-premises DNS cannot query Azure's `168.63.129.16` virtual IP directly.

Use the customer firewall repository or policy system named in the approved change. The firewall
owner maintains the Microsoft Entra access rule required by Agent Service, reviewed
feature-specific destinations, and tool-specific destinations there. The firewall owner also
confirms that TLS inspection does not inject an untrusted certificate. Session 03 does not copy or
deploy these rules. Do not add a blanket internet rule to make preflight pass. Session 05 confirms
that agent-runtime traffic follows the prepared route.

Bing Grounding, Websearch, and SharePoint Grounding still use public endpoints in an isolated
Foundry environment. If the approved architecture requires every agent-tool call to stay private,
exclude those tools from Session 05 rather than treating this VNet as coverage for them.

### 5. Update five resource IDs and check connectivity

The network owner points the Foundry private endpoint and DNS zone group to the Session 01 account.
Each service owner confirms the current resource ID for Foundry, Storage, Azure AI Search, Cosmos
DB, and Key Vault. Update the parameter file, then run `connectivity-check` from the approved
execution host.

Continue when the three Foundry endpoint-family FQDNs and four dependency FQDNs resolve to RFC 1918
addresses and the approved execution host reaches each endpoint on TCP 443.

### 6. Record prior states and disable public access

Run this command from the same approved private execution host:

![The cutover checks private DNS and TCP 443, stores all five prior public-access states, and passes a confirmation gate before public access is disabled](../assets/diagrams/public-access-cutover.svg)

The left side must finish before the first service update. A failed check or missing approved
change record stops the sequence.

```powershell
.\scripts\public-access-cutover.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroup `
  -CutoverChangeReference $cutoverChangeReference `
  -ConfirmPriorStateRecorded `
  -Confirm
```
```bash
./scripts/public-access-cutover.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --resource-group-name "$resource_group" \
  --cutover-change-reference "$cutover_change_reference" \
  --confirm-prior-state-recorded \
  --confirm
```

The script first confirms that the five unique service IDs use the expected Azure resource types
and belong to the approved subscription and resource group. It then checks private connectivity and
displays the five prior public-access states. Copy them to the approved change system, then rerun
the script with explicit confirmation. The script adds the Session 03 marker and requests
`Disabled` on each service.

If any update fails, do not rerun the command blindly. Inspect the approved change record,
identify which services changed, and start the manual restore procedure.

## Confirm the result

Run the check from the approved private execution host used for cutover:

```powershell
.\scripts\connectivity-check.ps1 `
  -ParameterPath .\artifacts\environments\sandbox.bicepparam
```
```bash
./scripts/connectivity-check.sh \
  --parameter-path ./artifacts/environments/sandbox.bicepparam
```

Each configured service alias must **resolve only to RFC 1918 IPv4 addresses**, and the approved
execution host must reach each endpoint on TCP 443. The script prints the result and exits. It does
not create a resource or save a result file.

## After implementation

Keep the private-network resources and settings in operation: the spoke or approved VNet changes,
Agent Service subnet, private-endpoint subnet, firewall route, private endpoints, DNS
configuration, customer firewall source reference, and disabled public-access settings. The network
owner maintains the subnets and route. DNS and firewall owners maintain their settings. Each service
owner maintains its private endpoint and public-access setting.

Store the public-access cutover record in the approved change system. The cutover owner captures
the displayed prior states there before confirmation, and the restore owner retrieves them there.

Run this implementation only in the approved nonproduction subscription and resource group.
Production needs separate address, DNS, firewall, change-window, and service-owner decisions.
Agent Service runtime traffic remains unconfirmed until
[Session 05](../../05-governed-agent-baseline/implementation/README.md) runs an agent from a
Foundry account created with this subnet.

Keep these network resources and access settings in place by default. If access must be restored,
the network, DNS, firewall, security, and affected service owners review the approved change record
with the change authority first.

Restore each service's recorded public-access state first. Then confirm that the approved execution
host can still reach each service. Restoring access does not release a Foundry account's injected
subnet. Keep the Agent subnet, route, and VNet until a separately approved Foundry account
retirement and purge finishes. Do not remove network resources if a recorded prior state is not
`Enabled`, a VNet link in a marked private DNS zone lacks the Session 03 marker, or a service was
already private-only and has no other approved access path.
