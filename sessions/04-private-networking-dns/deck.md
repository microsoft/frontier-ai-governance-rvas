---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 04</p>

# Private networking, DNS, and controlled egress

**300 minutes · Prepare and check the private client path**

<!-- Notes: Frame this as a network control implementation, not a general Azure networking lecture. -->

---

## Control objective

> Connect Foundry and four dependencies through private networking. Disable public access only after private DNS and TCP 443 checks pass from the approved nonproduction host.

### Session result

- Approved clients resolve the current service endpoints to private addresses.
- Those endpoints accept TCP 443 from the approved private execution host.
- The Agent Service subnet routes to the customer firewall; the customer firewall source owns its rules.
- Public access changes only after all five services resolve privately, accept TCP 443, and their prior settings are saved in the restore record.

<!-- Notes: Identity decides who can call a service. Networking decides where the call can come from. -->

---

## Implementation outcomes

1. Deploy a landing-zone-aligned spoke with separate private-endpoint and Agent Service subnets.
2. Connect Foundry, Storage, AI Search, Cosmos DB, and Key Vault through private endpoints and DNS.
3. Route the delegated Agent Service subnet through the approved firewall and record the customer firewall policy source.
4. Disable public access only after a private connectivity check and complete prior-state capture.
5. Confirm the current endpoints still resolve privately and accept TCP 443.

---

<!-- _class: section-divider -->

## Why it matters

Private DNS and endpoint checks reduce lockout risk before public access is disabled.

The separate Agent subnet prepares a later runtime path. It does not claim that an agent has used it yet.

<!-- Notes: One private endpoint does not create end-to-end isolation. -->

---

## Architecture overview

![Authorized clients use private DNS and endpoints while Agent traffic routes through the customer firewall and public access is denied](assets/diagrams/private-network-flow.svg)

The approved client asks for each service by its normal name. Private DNS returns the private
endpoint address, and the client connects on TCP 443. The separate Agent subnet sends its default
route to the customer firewall.

Azure holds live network and service state. The firewall source owns egress rules, while the
operational system keeps the five-service cutover record.

<!-- Notes: Walk left to right. Call out the separate subnets and the Session 06 runtime handoff. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Chosen approach | Tradeoff |
|---|---|---|
| Foundry account | Keep it only when it already uses the exact delegated subnet | Otherwise replacement and configuration replay need separate approval |
| DNS ownership | Reuse authoritative central zones, or create approved local zones | Hybrid and central designs need forwarding and artifact changes |
| Agent egress | Route the dedicated subnet to the customer firewall | The route does not prove firewall rules or runtime traffic |

<!-- Notes: Resolve these choices before network deployment. Session 06 checks the agent runtime path. -->

---

<!-- _class: decision -->

## Decision 1 · Keep or replace the existing Foundry account

Foundry, Storage, Azure AI Search, Cosmos DB, and Key Vault must already exist.

If the Foundry account was not created with the configured subnet, pause here.

The AI platform owner and change authority must complete the approved replacement first. Session 04 then reconciles the Foundry endpoint.

Current BYO VNet injection is configured when the Foundry account is created.

| [Session 01](../01-platform-baseline/) account state | Required action before [Session 06](../06-governed-agent-baseline/) |
|---|---|
| References this Agent subnet | Keep the account and recorded subnet decision |
| Has no `networkInjections` setting | Approve replacement and replay of approved configuration |
| References another subnet | Approve a new account and replay into it |

**Do not attempt an in-place retrofit or claim that Session 06 agent traffic uses this route before Session 06 runs its agent check.**

<!-- Notes: This product constraint must have an owner before deployment. -->

---

## The subnet contract

| Agent Service subnet | Private-endpoint subnet |
|---|---|
| Dedicated to one Foundry resource | Separate from injected compute |
| Delegated to `Microsoft.App/environments` | Private endpoint policies disabled |
| `/27` minimum; `/24` recommended | Sized for five endpoints plus growth |
| RFC 1918 and nonoverlapping | Connected to DNS zones that own these records |
| Default route to customer firewall | No route that bypasses the firewall |

Foundry and the virtual network must be in the same region.

<!-- Notes: Address overlap and subnet reuse are stop conditions. -->

---

## Resolve service FQDNs to private endpoints

```text
service FQDN
    ↓ public CNAME chain
privatelink service zone
    ↓ linked private DNS zone
private endpoint IPv4
```

- Applications keep the normal service FQDN.
- Private DNS supplies the private address inside the approved network.
- Authorization and the public-access setting remain separate controls.

<!-- Notes: A private DNS answer tells us where the client will connect. -->

---

## Seven zones · five endpoints

<div class="cards">
<div class="card">

![Microsoft Foundry icon](assets/icons/microsoft/azure-ai-foundry.svg)

### Foundry

`account` · three zones

</div>
<div class="card">

![Azure AI Search icon](assets/icons/microsoft/azure-ai-search.svg)

### AI Search

`searchService` · one zone

</div>
<div class="card">

![Azure Key Vault icon](assets/icons/microsoft/azure-key-vault.svg)

### Key Vault

`vault` · one zone

</div>
</div>

Storage `blob` and Cosmos DB `Sql` complete the required dependency set.

<!-- Notes: Centralized customers should reference the zones that already own these records. -->

---

<!-- _class: decision -->

## Decision 2 · DNS ownership

1. **Azure-only client:** link the record-owning zone to the client VNet.
2. **Peered spokes:** link the same zone to each approved client or resolver VNet.
3. **Hybrid:** forward the public service zone to an Azure-side forwarder or Private Resolver.
4. **Central DNS:** adapt the artifact to reference existing zones.

> On-premises DNS cannot query Azure's `168.63.129.16` virtual IP directly.

<!-- Notes: Ask the DNS owner to name the record-owning zones, resolver, and forwarding rules. -->

---

## The customer firewall owns egress rules

**Owned here:** `0.0.0.0/0 → customer firewall`

**Owned by the customer firewall source:** destinations, ports, review history, and deployment.

Session 04 records the external firewall repository or policy reference. It does not copy firewall rules into this kit.

Session 06 checks agent-runtime traffic through the prepared path.

<!-- Notes: Do not claim that a route proves the firewall rule or the agent-runtime path. -->

---

<!-- _class: compact -->

## Implementation sequence

This kit does not deploy missing dependency services.

1. **Decide and approve** whether the Foundry account stays or must be replaced.
2. **Deploy** the network, DNS links, and initial private endpoints.
3. **Pause for replacement and replay** through the separate approved change when required.
4. **Reconcile** the Foundry endpoint and all five current resource IDs.
5. **Check** private DNS and TCP 443 from the approved execution host.
6. **Record and disable** all prior public-access settings, then request `Disabled`.
7. **Confirm** private DNS and TCP 443 again.

<!-- Notes: The cutover script checks private DNS and TCP 443 before the first public-access change. -->

---

<!-- _class: implementation -->

## Build and test private connectivity

**Timebox:** 300 minutes

| Time | Work |
|---:|---|
| 70 min | Scope decisions, implementation files, preflight, and `what-if` |
| 75 min | Network deployment and private endpoint approvals |
| 45 min | DNS and firewall integration |
| 35 min | Guarded public-access cutover and result check |
| 15 min | Ownership, scope limits, and restore procedure |

<!-- Notes: Confirm the delivery owner before the first state change. -->

---

## Preflight checks

Preflight stops on:

- an unresolved `__REQUIRED_*__` decision;
- the wrong Azure subscription or resource group;
- a missing, duplicate, wrong-type, or out-of-scope service resource ID;
- missing Network Contributor on the approved network resource group, or missing Private DNS Zone Contributor on the reused or deployed zone scope;
- a missing provider, file, or invalid JSON document;
- a Bicep build failure; or
- a failed resource-group `what-if`.

The planned change should contain one approved VNet pattern, two subnets, one route table, seven zones and links, and five private endpoints.

<!-- Notes: Stop on any delete, replacement, hub change, Foundry deployment, or public-access change. -->

---

## Stop conditions

- Address space overlaps a connected or reserved range.
- The deployment would duplicate a central private DNS zone.
- A private endpoint connection remains pending.
- A configured endpoint fails private DNS or TCP 443.
- The firewall needs a blanket internet rule.
- The complete cutover record cannot be written outside the repository.
- A service update fails during cutover.
- The AI platform owner has not decided on replacement or the change authority has not approved required replay.

<!-- Notes: These stops protect scope and prevent lockout. -->

---

<!-- _class: decision -->

## Store restore settings before cutover

![Private DNS and TCP 443 checks plus stored prior states happen before the public-access cutover](assets/diagrams/public-access-cutover.svg)

<!-- Notes: Read the timeline from left to right. Stop at the gate unless every check passed and the complete external record exists. -->

---

## Confirm the result

From the approved private execution host:

```powershell
.\scripts\connectivity-check.ps1 `
  -EndpointMatrixPath .\artifacts\network\endpoint-matrix.json
```

**Expected:** each configured alias resolves only to RFC 1918 IPv4 addresses and accepts TCP 443. The script prints the result and saves no file.

<!-- Notes: This is the one standard-mode result check. -->

---

## Boundaries

<div class="cards">
<div class="card">

### Configured now

Private client connectivity, dependency endpoints, DNS links, and the Agent subnet route.

</div>
<div class="card">

### Still pending

An agent has not run through the delegated subnet or called a governed tool.

</div>
<div class="card">

### Next decision

Confirm the existing account uses the delegated subnet, or complete the approved replacement, before [Session 06](../06-governed-agent-baseline/).

</div>
</div>

<!-- Notes: The nonproduction implementation does not authorize production connectivity. -->

---

## Live state and ownership

| Operational control | Owner |
|---|---|
| VNet, subnets, route table, and private endpoints | Network platform owner |
| Private DNS zones, links, and hybrid forwarding | DNS owner |
| Customer firewall policy and source reference | Firewall policy owner |
| Public-access settings and service private endpoints | Affected service owners |
| Public-access cutover record | Stored in the system listed in the network design record; retrievable by the restore owner |

The cutover record stays outside the repository. Connectivity check output is not retained.

<!-- Notes: Production needs separate address, DNS, firewall, and change-window decisions. -->

---

## Guarded restore

1. Review the cutover record against the five approved service IDs and resource group.
2. Restore each state from the cutover record.
3. Confirm the approved execution host can reach each service.
4. Remove only allowed network resource types carrying the Session 04 marker.

Automated network removal stops unless every recorded prior state is `Enabled`.

When a service was already private-only, its owner must confirm another approved way to reach it first.

<!-- Notes: Keep the operational control in place by default. Restore needs cross-owner approval. -->

---

## Recap and next dependency

- **Connectivity:** normal service FQDN, private DNS answer, approved private endpoint.
- **Egress preparation:** dedicated Agent subnet, customer firewall route, and external policy source.
- **Safety:** private connectivity and stored prior settings before cutover.
- **Result:** configured endpoints resolve privately and accept TCP 443.
- **Pending work:** [Session 06](../06-governed-agent-baseline/) runs an agent through the delegated subnet.

Next: **[Session 05 · Models, residency, quota, and lifecycle](../05-model-governance-lifecycle/)**

<!-- Notes: Close on the operational control and the account-level dependency. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: End after naming the operational-control and restore owners. -->
