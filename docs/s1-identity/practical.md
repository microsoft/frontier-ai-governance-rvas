# Practical workshop: trace one agent identity path

**Microsoft default:** Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available.

**Customer decision:** Can this pilot agent run under an owned, auditable,
least-privilege identity path for the bounded scope?

## Facilitation flow

1. **Choose the pilot agent.** Select one bounded pilot or backlog item. Name the
   business sponsor, lifecycle owner, environment, and customer decision owner
   before discussing permissions.
2. **Draw the identity path.** Separate the human sponsor, agent identity, host
   workload identity, delegated user context if any, gateway boundary, target
   resource, audit route, and disable route.
3. **Classify runtime mode.** Record app-only/autonomous, OBO/delegated, or mixed
   mode. Split mixed mode into two authority decisions.
4. **Inspect source coverage.** Check customer-approved records: Entra Agent ID /
   Agent 365 where supported, managed identity, federated credential, app
   registration/service principal, Conditional Access, RBAC/API permission,
   gateway route, audit/sign-in log, or customer control register.
5. **Inspect token and credential control.** Identify who owns the managed
   identity, federated credential, app credential, issuer/subject constraints,
   rotation or revocation path, and retirement trigger. Reject shared accounts
   and unmanaged secrets for production onboarding.
6. **Inspect authorization.** Record the resource scope, Graph/API scopes,
   connector permissions, gateway/JWT boundary, RBAC assignment, Conditional
   Access applicability, and what the agent must not do. Defer broad roles,
   tenant-wide scopes, or missing fail-closed behavior.
7. **Inspect audit and disable.** Confirm which logs distinguish user, host,
   agent, gateway, and backend action. Record which owner can disable the agent
   identity, host credential/federation trust, RBAC/API permission, or gateway
   route.
8. **Record lifecycle outcome and handoff.** Approve only when sponsor, source
   coverage, runtime mode, authorization boundary, credential/federation owner,
   review cadence, disable route, and audit route are complete. Otherwise defer
   with a named owner and target date, reject unsafe patterns, or route to the
   accountable platform owner.

## Workshop artifact

| Artifact field | Capture prompt |
|---|---|
| Pilot scope | Which agent/workload and environment are in scope, and where is the customer record? |
| Identity path | Which sponsor, agent identity, host workload identity, user context, gateway, resource, and audit route are involved? |
| Runtime mode | Is the path app-only, OBO, or mixed? If mixed, where do the two authority paths separate? |
| Token control | Which host can request or exchange tokens, and what issuer/subject, credential, or federation owner constrains it? |
| Authorization boundary | What minimum RBAC/API/Graph/connector/gateway scope is allowed, and what is denied? |
| Audit route | Which records let a reviewer distinguish user, host, agent, gateway, and resource action? |
| Disable route | Which object or route is disabled first, who owns it, and what impact does it have? |
| Decision | Approve, defer, reject, or route with owner, accepted-when condition, target date, and review trigger. |

## Scenario examples

| Scenario | Route | Practical decision cue |
|---|---|---|
| Supported Microsoft agent tooling with complete sponsor and lifecycle fields | Entra Agent ID / Agent 365 path | Approve or route when the Agent ID / Agent 365 record names sponsor, purpose, authority mode, source coverage, lifecycle owner, disable route, and review date. |
| Azure-hosted agent runs background work | App-only managed identity path | Route when the host identity, target resource, RBAC scope, denied actions, Conditional Access applicability, audit route, and retirement path are documented. |
| CI/CD or external host provisions or reconciles identity objects | Workload identity federation backlog | Route when issuer, subject, audience, environment constraint, Graph/identity permission owner, rollback route, and audit reference are recorded. |
| Custom agent host needs OAuth application permissions or a non-Azure identity anchor | App registration / service principal path | Route when app ownership, consent owner, least-privilege API permissions, non-secret credential or federation plan, and review cadence are recorded. |
| Agent acts in the signed-in user's context | OBO-only delegated path | Route when user intent, delegated scopes, audit correlation, prohibited actions, fallback behavior, and no privilege elevation are documented. |
| Same agent has background and user-initiated duties | Mixed-mode path | Split the decision: app-only scopes cannot justify OBO actions, and user consent cannot justify autonomous production changes. |
| Pilot depends on a shared account, unmanaged stored secret, missing sponsor, broad role, or no disable route | Blocker path | Defer only with a named remediation owner and target date; reject for production onboarding if unaudited access, unmanaged credentials, unbounded privilege, or no containment path remains. |

## Decision record

Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, APIM/gateway route, and Agent 365 where available | Identity platform owner | Customer-approved record | Sponsor, source coverage, runtime mode, token path, authorization boundary, denied actions, credential/federation owner, disable route, audit route, lifecycle review, exception status, and handoff are complete | Customer date | Identity operations |

Use this decision tree: if the Microsoft path fits and evidence is complete, approve it; if records are missing, defer with an acceptance test; if the pattern cannot meet the use case safely, reject or route to an exception owner.

For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
