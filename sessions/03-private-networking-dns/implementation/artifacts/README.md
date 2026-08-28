# Implementation artifacts

These artifacts define the Session 03 network deployment and connectivity checks.

| Path | Operational purpose |
|---|---|
| `infra/network/main.bicep` | Dedicated spoke, Agent subnet, private-endpoint subnet, firewall route, private DNS zones, links, and five private endpoints |
| `environments/sandbox.bicepparam` | Explicit customer decisions and existing resource IDs |

Every `__REQUIRED_*__` value is intentional. Resolve it in the customer-owned working copy before
deployment. `scripts/preflight.ps1` rejects every unresolved sentinel. The connectivity and cutover
scripts derive the seven service FQDNs from the declared resource IDs, so live endpoint names are
not copied into a second file.

Do not store subscription IDs, resource IDs, FQDNs, private IP addresses, firewall addresses, DNS
server addresses, or cutover state in this repository. The customer firewall source owns egress
rules. The generalized kit keeps placeholders in the implementation files; approved customer
systems hold live values, approval, and restore records.
