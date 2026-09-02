# Private networking, DNS, and controlled egress

## Session scope

### What we will do

Connect the existing Foundry account and its Storage, Azure AI Search, Cosmos DB, and Key Vault
dependencies through private endpoints. Deploy seven private DNS zones and links plus five private
endpoints against the Session 01 network foundation.

From the approved nonproduction execution host, check that three Foundry endpoint families and four
dependency FQDNs resolve to RFC 1918 addresses and accept TCP 443. Record all five prior
public-access settings in the approved change system, disable public access, and run the check again.

### Why it matters

The team tests the private client path before closing the public one. That reduces lockout risk and
leaves a usable restore record.

The delegated Agent Service subnet already routes to the customer firewall. Session 04 checks the
agent-runtime path.

### Boundaries

Session 01 owns the VNet, route table, delegated Agent Service subnet, and private-endpoint subnet.
Keep them unchanged. This session owns the private endpoints, DNS configuration, and guarded
public-access cutover in the approved nonproduction resource group.

Azure holds live network and service state. The customer firewall source holds egress rules. The
approved change system holds cutover and restore details.

These files implement the customer-managed BYO VNet path. Stop if the AI platform owner selected
Microsoft-managed networking or if the Foundry account was not created with the approved delegated
subnet. Use a separate approved migration or replacement before continuing.

The connectivity check covers the approved client path. It does not prove agent-runtime traffic.
[Session 04](../../04-governed-agent-baseline/implementation/README.md) runs that check.

## Architecture

### Architecture at a glance

Applications keep using normal service FQDNs. Inside the approved network, DNS follows the CNAME
chain into a linked private DNS zone and returns the private endpoint's RFC 1918 address. The client
then connects on TCP 443.

The delegated Agent Service subnet has a separate default route to the customer firewall. Azure
holds the route; firewall administrators maintain the rules. A route does not prove that the
firewall permits traffic.

Corporate or on-premises identity providers may authenticate users before traffic reaches Azure
API Management. They do not replace Microsoft Entra workload identity for agents and Azure
services. The network owner must keep the user-authentication path separate from the private
service and agent-token paths.

![An approved private host reaches Foundry and data services through private DNS and private endpoints while public access is denied.](../assets/diagrams/private-network-flow.svg)

### Design choices and tradeoffs

| Decision | Chosen approach | Tradeoff |
|---|---|---|
| Network foundation | Consume the Session 01 VNet and subnet resource IDs | Microsoft-managed networking needs a different delivery path |
| Foundry account | Use an account created with the approved delegated subnet | An incompatible account needs approved migration or replacement |
| DNS ownership | Reuse authoritative central zones or deploy approved local zones | Central and hybrid designs need forwarding and Bicep changes |
| Agent egress | Keep the dedicated subnet route to the customer firewall | Session 04 must still test firewall rules and runtime traffic |

### Architecture guidance

- [Configure network isolation for Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/how-to/configure-private-link)
- [Networking options for Foundry Agent Service](https://learn.microsoft.com/en-us/azure/foundry/agents/concepts/networking-options)
- [Azure Private Endpoint DNS integration scenarios](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration)

## Before you start

Confirm these requirements:

- The approved nonproduction VNet, route table, delegated Agent Service subnet, and private-endpoint
  subnet exist in the recorded scope. The landing-zone owner checks their resource IDs and the
  approved execution host reaches the VNet. ([Session 01](../../01-platform-baseline/implementation/README.md).)
- The parameter file has the approved VNet and private-endpoint subnet resource IDs.
- Foundry, Storage, Azure AI Search, Cosmos DB, and Key Vault exist in that exact scope.
- `Microsoft.App`, `Microsoft.CognitiveServices`, `Microsoft.DocumentDB`, `Microsoft.KeyVault`,
  `Microsoft.Network`, `Microsoft.Search`, and `Microsoft.Storage` are registered.
- The network deployment operator has time-bound **Network Contributor** on the exact resource group.
- The DNS operator has time-bound **Private DNS Zone Contributor** on the resource group that holds
  the seven zones, or on every reused zone.
- Preflight has both operator object IDs and every exact DNS assignment scope.
- Each service owner will approve the private endpoint connection on their service. The network
  deployment operator does not receive that approval role through this session.
- The network, DNS, firewall, and landing-zone owners approved the topology, address space, DNS
  pattern, route, and firewall next hop.
- An existing host inside the approved private network can resolve the service FQDNs.
- The approved change record names the cutover owner, restore owner, and record location.

Use the approved execution host for connectivity and cutover. Keep workloads out of the delegated
Agent Service subnet.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/infra/network/main.bicep`](artifacts/infra/network/main.bicep) | The network deployment pipeline |
| Deployment | [`artifacts/environments/sandbox.bicepparam`](artifacts/environments/sandbox.bicepparam) | The network deployment pipeline |

## Decisions and stop conditions

Complete every `__REQUIRED_*__` value in a customer working copy. The parameter file needs the
approved region, VNet, private-endpoint subnet, five service resource IDs, and expiry date.

The owners must also settle these points before deployment:

| Decision | Continue when | Stop when |
|---|---|---|
| Foundry network pattern | The account uses the Session 01 customer-managed delegated subnet | The account uses another subnet, lacks the setting, or Microsoft-managed networking was selected |
| Addressing | The Agent subnet is dedicated, at least `/27`, and all ranges are nonoverlapping RFC 1918 | A range overlaps, the subnet is reused, or the design needs a blanket internet rule |
| DNS | One owner is authoritative for every required zone, with approved links and hybrid forwarding | The deployment would duplicate a central zone or mixed public/private resolution has no fallback path |
| Egress | The default route points to one approved firewall and its policy source is named | The firewall owner has not approved the Microsoft Entra and feature-specific destinations, or TLS inspection injects an untrusted certificate |
| Identity-provider boundary | The corporate identity provider terminates at the approved application or APIM boundary, while agents and Azure services use Microsoft Entra workload identities | A user token is reused as an agent identity, or the design assumes network location grants service access |
| Cutover | Every private endpoint is approved, private DNS and TCP 443 pass, prior states are recorded, and a restore owner is available | Any check fails or the complete restore record is missing |

For central DNS, change `main.bicep` to reference approved zone resource IDs and remove its local
zone and link declarations. Keep the private endpoints and DNS zone groups. The central DNS
deployment owns links, forwarding, and records. On-premises DNS cannot query Azure's
`168.63.129.16` virtual IP directly.

Portal and Agent Playground users must use the approved execution host or the customer-approved
VPN, ExpressRoute, or Bastion path. Their browsers must resolve the same private addresses.

Do not continue after cutover if DNS or TCP 443 fails. Do not remove private connectivity while
public access is disabled or while the Foundry account still uses the injected subnet.

## Implement

### 1. Complete the network definition

Set the five service IDs and the Session 01 network IDs in
`artifacts/environments/sandbox.bicepparam`. Configure these endpoint subresources and zones:

| Service | Subresource | Private DNS zone |
|---|---|---|
| Foundry | `account` | `privatelink.cognitiveservices.azure.com` |
| Foundry | `account` | `privatelink.openai.azure.com` |
| Foundry | `account` | `privatelink.services.ai.azure.com` |
| Storage | `blob` | `privatelink.blob.core.windows.net` |
| Azure AI Search | `searchService` | `privatelink.search.windows.net` |
| Cosmos DB | `Sql` | `privatelink.documents.azure.com` |
| Key Vault | `vault` | `privatelink.vaultcore.azure.net` |

Record the customer firewall repository or policy reference in the approved network design.

### 2. Run preflight and review `what-if`

Set the approved scope and operator IDs:

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$resourceGroup = "approved-session-02-resource-group"
$networkOperatorObjectId = "network-operator-object-id"
$dnsOperatorObjectId = "dns-operator-object-id"
$dnsScopeResourceIds = @(
  "/subscriptions/$approvedSubscriptionId/resourceGroups/approved-dns-resource-group"
)
$cutoverChangeReference = "approved-change-reference"
```
```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID:-}"
resource_group="approved-session-02-resource-group"
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

Repeat the DNS scope argument for separate zone-level assignments. Preflight rejects unresolved
values, wrong scopes, missing roles or providers, mismatched service IDs, Bicep errors, and a failed
resource-group `what-if`.

The preview must leave the Session 01 VNet, route table, and subnets unchanged. Expect seven zones
and links plus five private endpoints. Stop on a delete, replacement, Foundry deployment, hub
change, unexpected resource group, or public-access change.

### 3. Deploy private endpoints and DNS

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

Service owners approve pending private endpoint connections. Public access stays unchanged.

Link the authoritative zones to approved client or resolver VNets. For hybrid DNS, forward the
public service zones through an Azure-side DNS forwarder or Azure Private Resolver.

Firewall administrators update the named customer firewall source. Include the Microsoft Entra
access rule required by Agent Service and the approved feature-specific destinations. Do not add a
blanket internet rule. Bing Grounding, Websearch, and SharePoint Grounding still use public
endpoints in an isolated Foundry environment; use other approved tools when every tool call must
stay private.

### 4. Check the private path and cut over

Run the connectivity check from the approved execution host:

```powershell
.\scripts\connectivity-check.ps1 `
  -ParameterPath .\artifacts\environments\sandbox.bicepparam
```
```bash
./scripts/connectivity-check.sh \
  --parameter-path ./artifacts/environments/sandbox.bicepparam
```

Continue only when all configured FQDNs resolve to RFC 1918 addresses and accept TCP 443.

![The team verifies the private path, saves prior state, disables public access, and then rechecks or restores.](../assets/diagrams/public-access-cutover.svg)

Run the cutover script from the same host:

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

The script validates the five unique resource IDs, checks connectivity, and displays the five prior
public-access states. Copy those states to the approved change record before confirmation. It then
adds `networkControlSession=02-private-networking-dns` without replacing existing tags and requests
`Disabled` on every service.

If an update fails, inspect the change record and identify which services changed. Start the manual
restore procedure instead of rerunning the cutover blindly.

## Confirm the result

Run the connectivity check again from the approved execution host:

```powershell
.\scripts\connectivity-check.ps1 `
  -ParameterPath .\artifacts\environments\sandbox.bicepparam
```
```bash
./scripts/connectivity-check.sh \
  --parameter-path ./artifacts/environments/sandbox.bicepparam
```

Every configured alias must resolve only to RFC 1918 IPv4 addresses and accept TCP 443. The script
prints the result and saves no file.

## After implementation

| What remains | Owner |
|---|---|
| Session 01 VNet, subnets, route, and private endpoints | Network owner |
| Private DNS zones, links, and hybrid forwarding | DNS owner |
| Customer firewall rules and source reference | Firewall owner |
| Service private endpoints and public-access settings | Affected service owners |
| Five-service cutover and restore record | Cutover and restore owners |
| Bicep, parameters, and scripts | Network engineering |

Keep this control in the approved nonproduction scope. Production needs separate address, DNS,
firewall, service-owner, and change-window decisions. Session 04 must still test agent-runtime
traffic.

If access must be restored, the network, DNS, firewall, security, and service owners review the
approved change record with the change authority. Restore each recorded public-access state first,
then rerun the connectivity check.

Restoring public access does not detach the injected subnet. Keep the Agent subnet, route, and VNet
until a separately approved Foundry account retirement and purge is complete. Do not remove a
marked DNS link or private endpoint when a service remains private-only, when a recorded prior
state is not `Enabled`, or when no other approved access path exists.
