# Implementation artifacts

Use these artifacts to deploy the Session 03 network control and check connectivity.

| Path | Operational purpose |
|---|---|
| `infra/network/main.bicep` | Dedicated spoke, Agent subnet, private-endpoint subnet, firewall route, private DNS zones, links, and five private endpoints |
| `environments/sandbox.bicepparam` | Explicit customer decisions and existing resource IDs |

Resolve each `__REQUIRED_*__` value in the customer-owned working copy before deployment.
`scripts/preflight.ps1` rejects unresolved sentinels. The connectivity and cutover scripts derive
the seven service FQDNs from the declared resource IDs, so live endpoint names do not need a
second file.

Keep subscription IDs, resource IDs, FQDNs, private IP addresses, firewall addresses, DNS server
addresses, and cutover state out of this repository. The customer firewall source owns egress
rules. The implementation files use placeholders; approved customer systems hold the live values,
approval, and restore records.
