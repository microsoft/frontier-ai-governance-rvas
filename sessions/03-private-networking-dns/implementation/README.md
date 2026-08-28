# Private networking, DNS, and controlled egress

## Session scope

### What we will do

Connect the approved nonproduction execution host to Microsoft Foundry, Storage, Azure AI Search,
Azure Cosmos DB, and Azure Key Vault through private networking. In the nonproduction subscription
and resource group declared in the approved parameter file, deploy or update the spoke,
private-endpoint subnet, dedicated Agent Service subnet, firewall route, seven private DNS zones
and links, and five private endpoints. The scripts derive the three Foundry endpoint families and
four dependency FQDNs from the approved resource IDs. Before cutover, record the five
public-access states in the approved change system, then disable public access.

This session owns the cutover and client result. The seven configured endpoint FQDNs resolve to
private RFC 1918 addresses and accept TCP 443 from the approved execution host.

### Why it matters

The private endpoint and DNS path gives service owners a tested route before public endpoints are
disabled. Capturing prior settings first supports lockout recovery. The separate Agent Service
subnet and firewall route prepare the network boundary needed by the agent runtime.

### Boundaries

Live Azure networking, DNS, private endpoint, and service public-access state is authoritative. The
customer firewall source owns egress rules. The approved change system owns the cutover and restore
record; the repository owns reusable network desired state.

Adapt the Bicep when the landing zone already supplies the VNet or authoritative private DNS zones.
Before this session starts, choose the customer-managed BYO VNet path implemented here or a
Microsoft-managed network. Stop if that architecture decision is open. Do not combine both designs
in one deployment.
This session does not modify a hub or Virtual WAN, deploy firewall rules, create missing dependency
services, or create an execution host. It does not replace a Foundry account itself. If immutable
`networkInjections` require replacement, the team pauses for a separately approved account
replacement and configuration replay, then returns here to update the Foundry endpoint.

Private DNS and TCP 443 confirm the approved client path, not agent-runtime traffic.
[Session 05](../../05-governed-agent-baseline/implementation/README.md) runs that check from a
Foundry account created with the delegated subnet.

## Architecture

### Architecture at a glance

Clients keep using each service's normal public name. Inside the approved network, private DNS
follows the name's alias, or CNAME, chain into a linked private DNS zone. It returns the private
endpoint's RFC 1918 address, which is reachable only through the private network. The client then
opens TCP 443 to that address. Foundry can expose `cognitiveservices.azure.com`,
`openai.azure.com`, and `services.ai.azure.com`; the scripts derive every family from the Foundry
resource ID. Storage, Azure AI Search, Azure Cosmos DB, and Azure Key Vault use the same private
DNS pattern.

Agent Service has a different path. Its dedicated delegated subnet sends the default route to the
customer-managed firewall. Azure owns that route, while the customer firewall source owns the
outbound rules. Keeping those responsibilities apart avoids a false claim that deploying a route
also permits the traffic.

Azure shows the current network, DNS, private endpoints, and public-access settings. Before public
access is disabled, the approved operational system records the previous setting for all five
services. Operators use that record if they need to restore access.

This session confirms private DNS resolution and TCP 443 from the approved client. It does not
grant service access or prove Agent runtime traffic. Session 02 supplies the identity boundary, and
[Session 05](../../05-governed-agent-baseline/implementation/README.md) checks the agent path from
the delegated subnet.

![Approved clients use private DNS and endpoints while the delegated Agent Service subnet routes through the customer firewall](../assets/diagrams/private-network-flow.svg)

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Foundry account and Agent subnet | Keep the account when it was created with the exact delegated subnet. Otherwise, use a separately approved replacement and replay | This respects the network-injection boundary set when the account is created | Replacement needs its own change, configuration replay, and service-owner coordination | Microsoft supports changing network injection in place |
| Network ownership | Use the customer-managed BYO VNet path in this kit | The customer owns address space, routing, DNS integration, and firewall policy | Microsoft-managed networking is a separate architecture and implementation path | The platform owner selects Microsoft-managed networking before delivery |
| Private DNS ownership | Reuse authoritative central zones when they exist. Otherwise, create the approved local zones and links | There is one owner for each record, whether resolution is hub, spoke, or hybrid | Central DNS may need artifact changes and conditional forwarding | The resolver, hub, or zone owner changes |
| Agent egress | Send the dedicated Agent subnet's default route to the customer firewall | Azure owns the route; the firewall source owns the rules | A route alone does not prove that a firewall rule exists or that Agent runtime traffic works | Session 05 finds a blocked runtime dependency or the egress design changes |

### Architecture guidance

- [Configure network isolation for Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/how-to/configure-private-link)
- [Networking options for Foundry Agent Service](https://learn.microsoft.com/en-us/azure/foundry/agents/concepts/networking-options)
- [Azure Private Endpoint DNS integration scenarios](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration)

## Before you start

Confirm these prerequisites:

- Sessions 01-02 are complete in the approved nonproduction subscription and resource group.
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
- The Entra object IDs for the network and DNS operators are available. Record the exact
  resource-group or private-zone scope for every Private DNS Zone Contributor assignment that
  preflight must inspect.
- The Foundry, Storage, Azure AI Search, Cosmos DB, and Key Vault service owners recorded for this session have each
  accepted responsibility for approving the private endpoint connection on their exact service
  through the existing service change process. This session assigns no service-approval role to
  the network deployment operator.
- The landing-zone owner has approved the topology, address ranges, route behavior, and firewall
  next hop.
- The DNS owner has approved central-zone reuse or local-zone creation and any hybrid forwarding.
- An existing execution host inside the approved private network can resolve the service FQDNs.
- The approved change process names the cutover owner, restore owner, and record location before
  public access changes.

Do not create a VM, runner, or other resource just for the connectivity check. Do not place any
workload in the delegated Agent Service subnet.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/infra/network/main.bicep`](artifacts/infra/network/main.bicep) | The network deployment pipeline |
| Deployment | [`artifacts/environments/sandbox.bicepparam`](artifacts/environments/sandbox.bicepparam) | The network deployment pipeline |

Set the approved scope and existing service IDs in the current shell:

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

## Decisions and stop conditions

Complete every `__REQUIRED_*__` value in the parameter file in a customer working copy. Keep
approval, topology, firewall, DNS, and restore decisions in their customer-owned systems.

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

The AI platform owner must also confirm the network architecture before delivery. This kit
implements the customer-managed BYO VNet path. A Microsoft-managed network is a valid alternative,
but it uses managed private endpoints and a different ownership model. Stop and use that approved
design instead of adapting this kit during the session.

### Topology, addressing, DNS, and egress

The network, DNS, and firewall owners must agree on:

- the spoke attachment or approved existing-VNet pattern;
- nonoverlapping RFC 1918 ranges, with an Agent subnet of `/27` or larger;
- one authoritative instance of each required private DNS zone;
- the resolver and conditional-forwarding route for hybrid clients; and
- a default route to one customer-approved firewall and the customer firewall repository or policy
  reference that owns outbound rules, including the Microsoft Entra access rule required by Agent
  Service, any feature-specific destinations in scope, and a no-untrusted-TLS-inspection decision.

Stop if an address overlaps a connected or reserved range. Stop if the proposed deployment
duplicates a central private DNS zone, uses the Agent subnet for another workload, or needs a
blanket internet rule. For existing central zones, keep one implementation tree: replace the local
zone declarations and links in `main.bicep` with references to the approved zone resource IDs.
Keep the private endpoints and DNS zone groups in that same file. The central DNS deployment keeps
ownership of VNet links, forwarding, and zone records. When the shared zone also serves public
resources of the same type, the DNS owner must record the approved fallback-to-Internet setting or
another resolution path before linking the zone.

Portal and Agent Playground users must use the approved private execution host or the
customer-approved VPN, ExpressRoute, or Bastion access pattern. Their browser must resolve the
same private service addresses as the execution host.

### Public-access cutover

The affected service owners approve the maintenance window. The approved change process names
where prior states are stored and who can retrieve them. The cutover script must run from the
approved private execution host. It derives every endpoint from the parameter file, checks private
connectivity, displays the five current public-access states, and adds
`networkControlSession=03-private-networking-dns` without replacing existing tags.

Stop before cutover when:

- any private endpoint connection is not approved;
- any of the three in-use Foundry endpoint families or four dependency FQDNs does not resolve only
  to RFC 1918 IPv4 addresses;
- TCP 443 fails for any configured endpoint;
- the displayed prior states have not been recorded in the approved change system; or
- no owner can restore access during the maintenance window.

After cutover, stop all further changes if private DNS or TCP 443 connectivity fails. Restoring the
recorded prior states does not detach the injected subnet. Keep the Agent subnet, route, and VNet
while the Foundry account still uses network injection. Never remove private connectivity while
public access is still disabled or the approved execution host cannot reach the services.

## Implement

### 1. Resolve the implementation files

Complete the parameter file in the customer working copy. Point the approved change process to the
customer firewall source that owns outbound rules. If the customer uses central private DNS, change
the same Bicep file to reference the existing zone IDs and remove its local zone and link
declarations. Keep one **authoritative zone per service**. The Microsoft Foundry
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
requires a unique live resource for each alias in the approved subscription and exact resource
group, checks Network Contributor and Private DNS Zone Contributor at the supplied exact scopes,
verifies required providers, builds the Bicep, and runs a resource-group `what-if`.

Review the preview with the network and DNS owners. Expect the approved VNet, route table, two
subnets, seven zones and links, and five private endpoints. Stop on any delete, replacement,
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

Approve pending private endpoint connections through each service owner when the deployment
operator lacks approval rights. Public access stays unchanged. If Foundry replacement is required,
the dependency endpoints can remain, but the Foundry endpoint must be updated after replacement.

### 4. Replace and replay the Foundry account when approved

Skip this step when the existing account already uses the exact Agent Service subnet. Otherwise,
the change owner recorded in the approved change process replaces the Foundry account through the
separately approved change and
replays the approved project, connections, identities, role assignments, and model deployments.
This kit does not create the replacement account or dependency services.

### 5. Integrate customer DNS and firewall policy

Link the authoritative zones to every approved client or resolver VNet. For hybrid resolution,
forward the public service zones through an Azure-side DNS forwarder or Azure Private Resolver.
On-premises DNS cannot query Azure's `168.63.129.16` virtual IP directly.

Use the customer firewall repository or policy system named in the approved change. That source
owns the Microsoft Entra access rule required by Agent Service, reviewed feature-specific
destinations, and any tool-specific destinations. It must also confirm that TLS inspection does
not inject an untrusted certificate. Session 03 does not copy or deploy these rules. Do not add a
blanket internet rule to make preflight pass. Session 05 confirms that agent-runtime traffic
follows the prepared route.

Bing Grounding, Websearch, and SharePoint Grounding still use public endpoints in an isolated
Foundry environment. If the approved architecture requires every agent-tool call to stay private,
exclude those tools from Session 05 rather than treating this VNet as coverage for them.

### 6. Update five resource IDs and check connectivity

The AI platform owner confirms that the existing account needed no replacement or that the approved
replacement and replay completed. The network owner then points the Foundry private endpoint and
DNS zone group at the existing or replacement account. Each service owner confirms the current
resource ID for Foundry, Storage, Azure AI Search, Cosmos DB, and Key Vault. Update the parameter
file, then run `connectivity-check` from the approved execution host.

Continue only when the three Foundry endpoint-family FQDNs and four dependency FQDNs resolve to
RFC 1918 addresses and accept TCP 443.

### 7. Record prior states and disable public access

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
and belong to the approved subscription and resource group. It then checks private connectivity
and displays the five prior public-access states. Copy them to the approved change system, then
rerun with the explicit confirmation. The script adds the Session 03 marker and requests
`Disabled` on each service.

If any update fails, do not rerun the command blindly. Inspect the approved change record,
identify which services changed, and start the manual restore procedure.

## Confirm the result

Run the required check from the approved private execution host used for cutover, using the
parameter file:

```powershell
.\scripts\connectivity-check.ps1 `
  -ParameterPath .\artifacts\environments\sandbox.bicepparam
```
```bash
./scripts/connectivity-check.sh \
  --parameter-path ./artifacts/environments/sandbox.bicepparam
```

Each configured service alias must resolve only to RFC 1918 IPv4 addresses and accept TCP 443. The
script prints the result and exits. It does not create a resource or save a result file.

## After implementation

Keep the **approved private network path in operation**: the spoke or approved VNet changes, Agent
Service subnet, private-endpoint subnet, firewall route, private endpoints, DNS configuration,
customer firewall source reference, and disabled public-access settings. The network owner owns
the subnets and route. DNS and firewall owners own their configurations. Each service owner owns
its private endpoint and public-access setting.

Store the public-access cutover record in the approved change system. The cutover owner captures
the displayed prior states there before confirmation, and the restore owner retrieves them there.

Run this implementation only in the approved nonproduction subscription and resource group.
Production needs its own address, DNS, firewall, change-window, and service-owner decisions. Agent Service runtime traffic remains unconfirmed until
[Session 05](../../05-governed-agent-baseline/implementation/README.md) runs an agent from a
Foundry account created with this subnet.

Keep the operational control in place by default. If access must be restored, the network, DNS,
firewall, security, and affected service owners review the approved change record with the change
authority before any change.

Restore each service's recorded public-access state first. Then confirm that the approved execution
host can still reach each service. Restoring access does not release a Foundry account's injected
subnet. Keep the Agent subnet, route, and VNet until a separately approved Foundry account
retirement and purge has completed. Do not remove network resources when any recorded prior state
is not `Enabled`, when a VNet link in a marked private DNS zone lacks the Session 03 marker, or
when a service was already private-only before this session and has no other approved access path.
