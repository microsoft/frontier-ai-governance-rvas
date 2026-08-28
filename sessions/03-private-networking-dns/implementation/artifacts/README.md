# Implementation artifacts

These artifacts define the Session 04 network deployment and connectivity checks.

| Path | Operational purpose |
|---|---|
| `infra/network/main.bicep` | Dedicated spoke, Agent subnet, private-endpoint subnet, firewall route, private DNS zones, links, and five private endpoints |
| `environments/sandbox.bicepparam` | Explicit customer decisions and existing resource IDs |
| `network/endpoint-matrix.json` | Service aliases and FQDNs used by the private connectivity check |
| `decisions/network-design-record.md` | Topology, DNS, firewall source, immutable injection, scope, and cutover decisions |

Every `__REQUIRED_*__` value is intentional. Resolve it in the customer-owned working copy before
deployment. `scripts/preflight.ps1` rejects every unresolved sentinel.

Do not store subscription IDs, resource IDs, FQDNs, private IP addresses, firewall addresses, DNS
server addresses, or cutover state in this repository. The customer firewall source owns egress
rules. The generalized kit keeps placeholders in the implementation files; approved customer systems hold live values.
