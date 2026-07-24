# S5 · API, Tool & MCP Governance: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Azure API Center, Azure API Management, Entra/JWT, managed identity, delegated OAuth flows, MCP governance patterns, and connector controls change over time. Verify official docs, tenant support, and customer policy before delivery.

## Microsoft default

Default to Azure API Center for the publication record, Azure API Management for approved exposed routes, Microsoft Entra/JWT for caller identity, and customer connector/MCP publication controls. Use S10 only when the needed decision must happen inside the agent process immediately before a tool call.

![S5 illustrative tool-governance pattern: a publication record connects a tool or API to a selectable gateway-mediated, allow-list, or in-process policy boundary. It records intended controls without approving publication or runtime use.](../assets/diagrams/s5-tool-api-governance-record-model.svg)

## Decision tree

1. **If a tool/API is externally exposed or shared**, register it in Azure API Center or the approved catalog before broad use.
2. **If traffic can route through a gateway**, use Azure API Management products/policies and Entra/JWT authentication.
3. **If tool source trust is the main risk**, use an allow-list with owner, version, review date, and suspension trigger.
4. **If a local pre-call allow/deny/approval decision is required**, route to [S10 technical decisions](../s10-in-process-governance/technical.md).
5. **If caller identity, scope, or withdrawal trigger is unknown**, reject or defer publication.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Registry | Azure API Center entry with owner, lifecycle, version, exposure intent | existing catalog can carry the same fields |
| Exposed route | Azure API Management API/product/policy/backend | existing gateway has equivalent auth, quota, logging, and lifecycle records |
| Caller authority | Entra app/managed identity/OBO with least privilege | customer identity provider is authoritative and auditable |
| MCP/tool governance | gateway-mediated route or reviewed allow-list | in-process decision is required and assigned to S10 |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Publication record | Azure API Center API/tool entry, version, lifecycle state, owner |
| Gateway control | Azure API Management product, subscription, policy, backend, quota, telemetry |
| Identity and consent | Entra app registration/service principal, managed identity, OAuth scopes, consent record, JWT validation |
| Connector/MCP source | Copilot Studio/Power Platform connector policy, MCP server allow-list, package/source review |
| Lifecycle and withdrawal | deprecation notice, suspension trigger, material-change route, S9 catalog entry |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Publication | candidate, version, source trust, owner, consumers, allowed actions, and lifecycle state are recorded | Catalog/API owner |
| Auth and least privilege | caller identity, scopes/RBAC, prohibited actions, consent owner, and review trigger are recorded | Identity/API owner |
| Boundary selection | gateway, allow-list, or S10 in-process route is selected with owner and evidence location | Platform/security |
| Withdrawal | suspension trigger, deprecation path, and affected dependency owner are recorded | S9 lifecycle owner |

## Boundary note

S5 records tool/API governance choices; it publishes nothing and authorizes no runtime use.

## Related references

- [S5 Concepts](concepts.md): catalog decisions, publication backlog, identity/authority boundary, and lifecycle states.
- [S10 technical decisions](../s10-in-process-governance/technical.md): in-process policy boundary.
- [Platform technical guide](../reference/platform-technical-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
