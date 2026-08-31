# Implementation artifacts

Use these artifacts to deploy the Session 03 network control and check connectivity.

| Path | Operational purpose |
|---|---|
| `infra/network/main.bicep` | Private DNS zones, links to the Session 01 VNet, and five private endpoints in the Session 01 private-endpoint subnet |
| `environments/sandbox.bicepparam` | Explicit customer decisions, Session 01 network resource IDs, and service resource IDs |

Replace each `__REQUIRED_*__` value in the customer-owned working copy before deployment.
`scripts/preflight.ps1` rejects unresolved sentinels. The connectivity and cutover scripts derive
the seven service FQDNs from the declared resource IDs, so live endpoint names do not need a
second file.

Keep subscription IDs, resource IDs, FQDNs, private IP addresses, firewall addresses, DNS server
addresses, and cutover state out of this repository. The customer firewall source owns egress
rules. The implementation files use placeholders. Approved customer systems hold live values,
approvals, and restore records.
