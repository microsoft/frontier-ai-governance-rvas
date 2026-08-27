# Session 04 network design record

## Decision owners

| Decision | Accountable owner | Required reviewer | Decision |
|---|---|---|---|
| Spoke and hub/Virtual WAN attachment | Network platform owner | Landing-zone architect | `__REQUIRED_TOPOLOGY_DECISION__` |
| Address ranges and route propagation | Network platform owner | Security engineering | `__REQUIRED_ADDRESS_DECISION__` |
| Private DNS zone ownership and links | DNS owner | Network platform owner | `__REQUIRED_DNS_DECISION__` |
| Hybrid conditional forwarding or Private Resolver | DNS owner | On-premises network owner | `__REQUIRED_FORWARDING_DECISION__` |
| Firewall route and policy source | Firewall policy owner | Security reviewer | `__REQUIRED_FIREWALL_DECISION__` |
| Customer firewall repository or policy reference | Firewall policy owner | Network platform owner | `__REQUIRED_FIREWALL_SOURCE_REFERENCE__` |
| Foundry account replacement for Agent VNet injection | AI platform owner | Network and identity owners | `__REQUIRED_FOUNDRY_INJECTION_DECISION__` |
| Public-access cutover window, restore record location, and retrieval owner | Affected service owners | Delivery lead | `__REQUIRED_CUTOVER_DECISION__` |
| Nonproduction subscription, resource group, and production follow-up | Delivery lead | Landing-zone architect | `__REQUIRED_SCOPE_DECISION__` |

## Immutable Foundry decision

Foundry Agent Service BYO VNet injection is configured when the Foundry account is created and
cannot be added to the [Session 01](../../../../01-platform-baseline/implementation/README.md) account later. This session creates and configures the delegated
subnet and controlled route. Before [Session 06](../../../../06-governed-agent-baseline/implementation/README.md), the AI platform owner must either:

1. confirm the existing Foundry account was already created with `networkInjections` for this exact
   subnet; or
2. approve a replacement Foundry account, name the change owner, and approve replay of the approved
   project, connections, identities, role assignments, and model deployments.

After a replacement, the AI platform owner records the new Foundry resource ID. The network owner
updates the Foundry private endpoint to that account, and the service owners reconcile all five
resource IDs before connectivity checks or public-access changes.

Do not describe Agent Service egress as working until an agent runs in the injected subnet.

## Firewall boundary

The Session 04 Bicep routes the delegated Agent Service subnet to the approved firewall. It does
not create firewall rules. The customer firewall repository or policy system listed above owns the
allowed destinations and change history. Session 06 checks agent-runtime traffic through that
path.

## DNS contract

- Use the Microsoft-recommended private zone names.
- Link one authoritative instance of each zone to every VNet containing an approved resolver or
  client.
- If the customer centralizes zones, adapt the Bicep to reference those existing zones rather than
  deploying duplicate zones.
- Hybrid conditional forwarders target the public service zones through an Azure-side resolver;
  they do not point on-premises DNS directly at `168.63.129.16`.
- Store actual FQDNs, IP addresses, resolver addresses, and forwarding rules outside this kit.

## Cutover and restore contract

- Run the private endpoint connectivity check from the approved execution host before cutover.
- Write all five prior public-access states atomically to the approved cutover record before
  changing a service.
- Record the system that stores the cutover file and the person or team responsible for retrieving
  it during restore. Record both in `__REQUIRED_CUTOVER_DECISION__`.
- Restore the recorded prior states before removing any marked Session 04 network resource.
- Keep the private network by default. Restore needs explicit cross-owner approval.
