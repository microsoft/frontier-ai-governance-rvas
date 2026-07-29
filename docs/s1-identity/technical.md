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

### Entra Agent ID object model

When Microsoft Entra Agent ID is available for the workload, record the object
model explicitly so identity, credential, and lifecycle decisions do not collapse
into one generic service principal:

| Object | Governance question | Evidence to record |
|---|---|---|
| Agent identity blueprint | Which template or governance container provisions and governs the agent identities? | Blueprint reference, manager role, credential or federation owner, Conditional Access or policy applicability, disable route. |
| Blueprint principal | Which tenant service principal represents the blueprint? | Principal reference, owner, consent or permission route, review date. |
| Agent identity | Which runtime actor represents the agent itself? | Agent identity reference, sponsor, purpose, authority mode, lifecycle state, RBAC/API scopes, retirement route. |
| Host workload identity | Which compute identity can request or exchange tokens for the agent path? | Managed identity, workload identity federation, app registration, or service principal reference, issuer/subject constraints, revocation owner. |
| Target resource authorization | Which resource grants access after the agent is identified? | Azure RBAC, API permission, gateway product/subscription, data access policy, or explicit denial record. |

Treat the blueprint and host workload identity as credential and provisioning
mechanisms. Treat the agent identity as the accountable runtime actor. Treat
resource authorization as a separate least-privilege decision.

### Runtime authority modes

Use this matrix when the same workload can run both interactively and in the
background. Record both paths if both exist.

![User-initiated agent flow separates user identity, gateway validation, agent runtime authority, backend authorization, and telemetry correlation.](../assets/diagrams/s1-user-agent-backend-auth-flow.svg)

![Autonomous agent flow separates trigger, host workload identity, token exchange, agent identity, gateway route, target API authorization, and audit/disable route.](../assets/diagrams/s1-autonomous-agent-backend-auth-flow.svg)

| Mode | Typical token path | Use when | S1 decision requirement |
|---|---|---|---|
| Autonomous or app-only | Host workload identity or federated credential obtains agent or resource tokens without a user context | Scheduled work, background processing, service-to-service integration | Sponsor, app-only purpose, non-secret credential path, least-privilege resource scopes, denied actions, incident disable route. |
| On-behalf-of user | User token is exchanged for delegated access through an approved OBO flow | The agent performs user-scoped actions such as reading or writing resources the user may access | User intent trigger, delegated scopes, consent owner, audit correlation between user/app/agent, prohibited privileged actions, fallback behavior. |
| Mixed mode | Separate app-only and delegated flows are both present | The same agent has background duties and user-initiated actions | Two decision records or one record with two clearly separated authority sections; do not let app-only permissions substitute for user-scoped approval. |

### Provisioning and incident routes

For Azure-hosted and CI/CD-managed workloads, prefer managed identity or workload
identity federation over stored credentials. A GitHub Actions OIDC flow can be
recorded as an implementation backlog item when a customer-owned pipeline needs
to provision or reconcile identity objects through approved Graph permissions.
Record the federated credential, issuer and subject constraints, consent owner,
required role, target identity object, rollback route, and audit reference. Do
not treat the pipeline description as proof that identity objects exist or that
access is approved.

Incident and retirement paths should preserve auditability. If an agent must be
stopped, record whether the customer process disables the specific agent identity,
blocks a broader blueprint or Conditional Access path, removes resource RBAC, or
suspends a gateway/API route. Deleting identity objects is usually a separate
records-retention decision; S1 should route that decision rather than assume it.

### Runtime token-exchange reference

For app-only Azure workloads, use this sequence to review the identity design.
The exact SDK, API version, and product support must be verified by the customer
implementation team.

| Stage | Technical event | S1 evidence question |
|---|---|---|
| 1. Host token | The execution host obtains a managed identity or federated workload token without storing a secret. | Which host identity is used, who owns it, and what issuer/subject or resource binding constrains it? |
| 2. Blueprint trust | The host token is accepted by the approved blueprint or identity-management path. | Which blueprint or identity object trusts the host, and who can change that trust? |
| 3. Agent token | The agent identity receives or exchanges for a token that identifies the agent as the runtime actor. | Which agent identity appears in sign-in/audit logs, and how is it tied to sponsor and lifecycle? |
| 4. Resource token | The agent or gateway obtains a token for the target API or Azure resource. | Which scopes, app roles, RBAC assignments, or gateway product permissions constrain the action? |
| 5. Authorization | The backend validates the token and applies resource authorization. | What happens outside scope: 401/403, gateway denial, app denial, or escalation? |
| 6. Audit | Sign-in, gateway, app, and resource telemetry preserve the actor and correlation path. | Can a reviewer distinguish user, host, agent, gateway, and backend records? |

### Provisioning permission checklist

When the identity record depends on CI/CD or automation, record the permissions
as a backlog item. S1 does not request consent or grant roles.

| Permission or role | Why it may be needed | Record before use |
|---|---|---|
| Agent identity read/write permission | Create or reconcile agent identity objects where supported. | Consent owner, scope, environment, expiry/review date. |
| Application read/write permission | Create or update app or service-principal objects used by the identity path. | Object owner, change route, rollback route. |
| App role assignment permission | Assign or consent application permissions for the blueprint or agent path. | Privileged approval owner, least-privilege justification. |
| Agent identity developer/admin role | Allows the platform or identity team to create or manage agent identity objects. | Named operator group, separation of duties, emergency route. |
| Workload identity federation | Lets the pipeline exchange an external workload token without a stored secret. | Issuer, subject, audience, branch/environment constraint, revocation owner. |

### Disable and audit routing

| Scenario | Preferred record | S1 routing note |
|---|---|---|
| Disable one agent | Agent identity account-enabled state, gateway route suspension, or resource RBAC removal. | Preserve object metadata where audit retention requires it. |
| Disable a family of agents | Blueprint, Conditional Access, gateway product, or shared backend route. | Treat as broader impact and route through security/change ownership. |
| Review creation | Entra audit log or customer identity-change record. | Confirm object type, creator, sponsor, and source system. |
| Review sign-in | Agent sign-in, workload identity sign-in, gateway auth log, app trace. | Confirm whether the sign-in proves agent action or only host credential use. |
| Sponsor transfer | Agent identity governance record or customer control register. | Tie owner changes to review trigger and next access recertification. |

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
