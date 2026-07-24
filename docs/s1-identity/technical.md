# S1 · Identity & Ownership: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Microsoft Entra Agent ID, workload identities, Conditional Access for workload identities, Azure RBAC, and Agent 365 coverage vary by tenant, license, region, workload, and product maturity. Verify official docs and tenant status before delivery.

## Microsoft default

Default to Microsoft Entra Agent ID where supported, backed by Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 records where available. The identity record must name the human sponsor, workload purpose, authority mode, credential/federation owner, and review date.

![S1 illustrative identity pattern: a human sponsor governs agent identity and lifecycle; host workload identity, agent identity, delegated OBO, gateway access, and resource authorization remain separate decisions.](../assets/diagrams/s1-agent-identity-model.svg)

## Decision tree

1. **If the agent is surfaced by supported Microsoft agent tooling**, use Entra Agent ID / Agent 365 records as the primary agent identity reference.
2. **If it runs as an Azure workload**, use managed identity or workload identity federation for resource access and add a separate sponsor/lifecycle record.
3. **If it is a custom service needing OAuth**, use app registration/service principal with least privilege and federated credentials where supported.
4. **If it acts as a user**, record delegated OBO authority and audit route; keep the agent inventory separate from the user's identity.
5. **If no sponsor, lifecycle owner, or auditable identity exists**, route or reject until the identity gap is closed.

| Identity/control choice | Use when | Required owner |
|---|---|---|
| Entra Agent ID / Agent 365 | supported per-agent identity and lifecycle records exist | Identity platform owner + human sponsor |
| Managed identity | Azure-hosted workload needs Azure resource access | Azure platform/resource owner |
| Workload identity federation | CI/CD or external workload should avoid stored secrets | Identity federation owner |
| App registration/service principal | custom app needs OAuth permissions | Application owner + consent owner |
| OBO delegated access | user-context authorization is required | App owner + audit owner |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Agent inventory and sponsor | Entra Agent ID, Agent 365, customer control register |
| Workload credential | Managed identity, federated credential, app registration/service principal record |
| Runtime access control | Conditional Access for workload identities, Entra sign-in/audit logs, Azure RBAC assignment record |
| Gateway access | Azure API Management/API gateway Entra/JWT configuration reference |
| Access review | Entra access review, privileged role review, or customer identity-change ticket |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Agent identity | each in-scope agent has a sponsor, purpose, lifecycle owner, identity type, and source record | Identity governance |
| Credential hygiene | stored secrets are removed or explicitly excepted with owner, target date, and review trigger | Identity/platform engineering |
| Runtime access | Conditional Access, RBAC, gateway auth, or a recorded gap has an owner and validation route | Security/platform |
| Delegated authority | OBO scope, prohibited actions, audit route, and fallback behavior are recorded | Application owner |

## Boundary note

S1 records identity and access decisions; it grants no access and approves no production use.

## Related references

- [S1 Concepts](concepts.md): sponsorship, OBO, and gateway boundary.
- [S9 technical decisions](../s9-control-plane/technical.md): catalog reconciliation.
- [Governance capability guide](../reference/governance-capability-guide.md): Agent ID and Conditional Access availability.
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
