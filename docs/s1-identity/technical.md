# S1 · Identity & Ownership: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Microsoft Entra Agent ID, workload identities, Conditional Access for workload identities, Azure RBAC, and Agent 365 coverage vary by tenant, license, region, workload, and product maturity. Verify official docs and tenant status before delivery.

## Microsoft default

Default to Microsoft Entra Agent ID where supported, backed by Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 records where available. The identity record must name the human sponsor, workload purpose, authority mode, credential/federation owner, and review date.

![S1 illustrative identity pattern: a human sponsor governs agent identity and lifecycle; host workload identity, agent identity, delegated OBO, gateway access, and resource authorization remain separate decisions.](../assets/diagrams/s1-agent-identity-model.svg)

## Scenario decision route

Use this route during workshop scenarios. Record the selected route, the evidence used, and the owner of any gap. Do not create identities, grant permissions, approve exceptions, or change tenant policy from this page.

1. **Identify the agent record.** If the agent is surfaced by supported Microsoft agent tooling, route to Entra Agent ID / Agent 365 as the primary inventory and lifecycle reference. If tenant, region, license, or workload support is unavailable, defer to the customer control register and record the platform check needed before migration.
2. **Name the human sponsor.** If a business sponsor and lifecycle owner are named, continue. If the sponsor is missing, defer intake to the accountable product/service owner. If no accountable owner can be identified, reject production onboarding.
3. **Separate workload identity from delegated authority.** If the agent accesses resources as a service, route to managed identity, workload identity federation, or app registration/service principal. If it acts for a user, route to OBO delegated access and record audit/prohibited-action controls. If both are needed, record two separate decisions.
4. **Prefer non-secret credentials.** If the workload can use managed identity or workload identity federation, route there. If a stored secret is proposed, defer for a no-secret design or record a time-bound exception with owner and retirement trigger. Reject shared accounts, unmanaged credentials, and credentials without a rotation or federation owner.
5. **Constrain authorization.** Route least-privilege RBAC, Graph/API permissions, Conditional Access for workload identities where available, and gateway/JWT checks to the owning platform. Defer broad RBAC, tenant-wide permissions, or missing resource scope until narrowed. Reject standing privileged access without review and break-glass rationale.
6. **Close lifecycle.** If source coverage, review cadence, retirement route, and audit evidence are recorded, accept the decision record. Otherwise defer with a named owner and target date.

### Identity pattern matrix

| Pattern | Use when | Decision evidence to record | Required owner(s) | Route / defer / reject guidance |
|---|---|---|---|---|
| Entra Agent ID / Agent 365 | The agent is represented by supported Microsoft agent tooling and tenant availability checks pass | Agent record/source ID, sponsor, purpose, authority mode, lifecycle owner, review date, platform availability check | Identity platform owner + human sponsor | **Route** when supported and source fields are complete. **Defer** when availability is tenant/license/region/workload dependent. **Reject** as the sole control if the scenario needs resource authorization that is not separately recorded. |
| Managed identity | Azure-hosted workload needs Azure resource access without stored credentials | Managed identity type, hosting resource, target resources, RBAC scopes, Conditional Access applicability, resource owner approval route | Azure platform owner + resource owner + human sponsor | **Route** for Azure-native service access. **Defer** if RBAC scope is broad or resource ownership is unclear. **Reject** when used to hide an unnamed agent sponsor or shared runtime. |
| Workload identity federation | CI/CD, Kubernetes, GitHub Actions, or external workload should exchange tokens instead of storing secrets | Issuer, subject/audience constraints, federated credential owner, target app/managed identity, token lifetime expectations, revocation path | Identity federation owner + workload owner | **Route** for non-secret authentication with constrained issuer/subject. **Defer** if issuer claims or ownership are not documented. **Reject** wildcard subjects, unmanaged issuers, and designs that keep stored secrets as the primary credential. |
| App registration / service principal | Custom service or agent host needs OAuth application permissions or a non-Azure identity anchor | App ID, service principal, API permissions, consent owner, credential/federation design, redirect/issuer constraints, review cadence | Application owner + consent owner + identity platform owner | **Route** when least privilege and non-secret credential plan are recorded. **Defer** tenant-wide consent, broad Graph/API scopes, or missing credential owner. **Reject** shared app registrations across unrelated agents. |
| OBO delegated access | The agent acts in user context and authorization must reflect the user's entitlements | Delegated scopes, triggering user action, audit correlation, prohibited actions, fallback behavior, consent route | App owner + audit owner + data/resource owner | **Route** when user intent, scope, and audit route are explicit. **Defer** if logs cannot distinguish user, app, and agent action. **Reject** OBO for autonomous production changes, privilege elevation, or actions outside the user's approved scope. |
| Shared account, stored secret, broad RBAC, or missing sponsor | A proposed design lacks individual accountability, non-secret credential ownership, least privilege, or lifecycle accountability | Gap description, risk owner, target remediation path, decision date | Accountable product/service owner + identity governance | **Defer** only with a named owner and dated remediation. **Reject** for production onboarding when the gap enables unaudited access, unmanaged credentials, or unbounded privilege. |

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
| Owner/sponsor | every in-scope agent or workload has a named human sponsor, lifecycle owner, business purpose, and review date; missing sponsor cases are routed to a product/service owner or rejected for production onboarding | Identity governance |
| Source coverage | each decision cites an inventory source: Entra Agent ID / Agent 365 where available, managed identity record, federated credential, app registration/service principal, gateway record, or customer control register with availability caveat | Identity governance + platform owner |
| Least privilege | RBAC assignments, Graph/API permissions, gateway scopes, and Conditional Access for workload identities where available are scoped to the named resource/action; broad roles or tenant-wide permissions have a deferral owner and narrowing route | Security/platform |
| Denied outside scope | the record names what the agent must not do, how out-of-scope requests fail closed, and who reviews denied or attempted actions | Application owner + security owner |
| Credential/federation owner | managed identity, federated credential, app credential, or exception has an owner, rotation/revocation path, retirement trigger, and explicit rejection of shared accounts or unmanaged stored secrets | Identity/platform engineering |
| OBO audit and prohibited actions | delegated access records user intent, OBO scopes, audit correlation between user/app/agent, prohibited production actions, fallback behavior, and denial of privilege elevation outside the user's approved scope | Application owner + audit owner |
| Lifecycle/review/retire route | onboarding, periodic review, ownership transfer, incident response, and retirement/removal routes are recorded with evidence owners and target dates for gaps | Identity governance + service owner |

## Boundary note

S1 records identity and access decisions; it grants no access and approves no production use.

## Related references

- [S1 Concepts](concepts.md): sponsorship, OBO, and gateway boundary.
- [S9 technical decisions](../s9-control-plane/technical.md): catalog reconciliation.
- [Governance capability guide](../reference/governance-capability-guide.md): Agent ID and Conditional Access availability.
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
