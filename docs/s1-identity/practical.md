# Practical workshop: scenario-driven agent identity

**Microsoft default:** Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available.

**Customer decision:** Approve, defer, reject, or route the identity pattern for the pilot agent.

## Work the decision

1. **Choose the pilot agent.** Select one bounded pilot or backlog item. Name the business sponsor, lifecycle owner, and customer decision owner before discussing permissions.
2. **Classify the identity scenario.** Record whether the pilot needs an agent identity/sponsor record, a workload credential, delegated/OBO authority, or both workload and delegated decisions.
3. **Inspect source coverage and sponsor.** Check the customer-approved inventory source: Entra Agent ID / Agent 365 where supported, managed identity, federated credential, app registration/service principal, gateway record, or customer control register. Defer if sponsor, source, purpose, or review date is missing.
4. **Inspect access boundary.** Record the resource scope, Graph/API scopes, gateway/JWT boundary, RBAC assignment, Conditional Access applicability, and what the agent must not do. Defer broad roles, tenant-wide scopes, or missing fail-closed behavior.
5. **Inspect credential or federation ownership.** Identify who owns the managed identity, federated credential, app credential, issuer/subject constraints, rotation or revocation path, and retirement trigger. Reject shared accounts and unmanaged secrets for production onboarding.
6. **Record lifecycle outcome and handoff.** Approve only when sponsor, source coverage, access boundary, credential/federation owner, review cadence, and retirement route are complete. Otherwise defer with a named owner and target date, reject unsafe patterns, or route to the accountable platform owner.

## Scenario examples

| Scenario | Route | Practical decision cue |
|---|---|---|
| Supported Microsoft agent tooling with complete sponsor and lifecycle fields | Entra Agent ID / Agent 365 path | Approve or route when the Agent ID / Agent 365 record names sponsor, purpose, authority mode, source coverage, lifecycle owner, and review date. |
| Azure-hosted agent accesses Azure resources as a service | Azure managed identity path | Route when the managed identity, hosting resource, RBAC scope, resource owner, Conditional Access applicability, and retirement path are documented. |
| Custom agent host needs OAuth application permissions or a non-Azure identity anchor | App registration / service principal path | Route when app ownership, consent owner, least-privilege API permissions, non-secret credential or federation plan, and review cadence are recorded. |
| Agent only acts in the signed-in user's context | OBO-only delegated path | Route when user intent, delegated scopes, audit correlation, prohibited actions, fallback behavior, and no privilege elevation are documented. |
| Pilot depends on a shared account, unmanaged stored secret, missing sponsor, or broad role | Blocker path | Defer only with a named remediation owner and target date; reject for production onboarding if unaudited access, unmanaged credentials, or unbounded privilege remain. |

## Decision record

Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available | Identity platform owner | Customer-approved record | Sponsor, source coverage, authority mode, access boundary, credential/federation owner, lifecycle review, exception status, and handoff are complete | Customer date | Identity operations |

Use this decision tree: if the Microsoft path fits and evidence is complete, approve it; if records are missing, defer with an acceptance test; if the pattern cannot meet the use case safely, reject or route to an exception owner.

For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
