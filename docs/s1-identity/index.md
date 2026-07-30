# S1 · Agent Identity Path

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Identity admin</span> <span class="rvas-badge rvas-persona">Governance lead</span>

!!! abstract "What is at stake"
    An agent is only accountable when the customer can trace who sponsors it,
    which identity acts, what access it has, and how that access can be stopped.

## 1. Trace the identity path

For one bounded pilot agent or agent-like workload, the customer can answer:
**which host can request tokens, which agent identity is accountable, which
authority mode is allowed, which resource scopes are in bounds, how access can
be disabled, and where audit evidence will be reviewed?**

Work through these checks:

- An **identity architecture card** for the pilot: sponsor, agent identity, host
  workload identity, runtime mode, gateway boundary, target resources, denied
  actions, lifecycle state, and disable owner.
- A **token-flow worksheet** that distinguishes app-only/autonomous operation
  from on-behalf-of user operation.
- A **source coverage result** showing which Microsoft records were inspected:
  Microsoft Entra Agent ID, Agent 365, managed identity, federated credential,
  app registration or service principal, Conditional Access, RBAC/API
  permissions, gateway records, and audit/sign-in logs where available.
- A **least-privilege decision** that names minimum scopes, broad or unknown
  permissions, prohibited actions, and the owner of any narrowing backlog.
- A **disable and audit route** that says how the customer would stop the agent,
  revoke or suspend the relevant access path, and investigate actor evidence.
- The decision and safe references saved in the customer's own records system or
  the generated delivery workspace.

`labs/s1-identity/` holds the runbook and a blank review template. It does **not**
hold real identity data, exports, Conditional Access policies, break-glass
templates, or customer records: those stay in the customer's own systems.

### Plain decision

**Question:** **Can this pilot agent run under an owned, auditable,
least-privilege identity path for the bounded scope?** Default to Microsoft
Entra Agent ID where supported, backed by Entra workload identities, managed
identity or workload identity federation, Conditional Access and RBAC where
applicable, APIM or gateway JWT boundaries where used, and Agent 365 records
where available.

An exception requires a documented coverage limit, owner, Microsoft record
location, accepted-when criterion, target event, and recheck condition. This result
does not create identities, grant access, change tenant policy, or approve
production.

### What happens next

**Next customer action:** give the identity, platform, application, gateway, or
resource owner the exact gap, then start dependent work only when the required
coverage is clear.

S1 produces an identity backlog: close source or owner gaps, assess Entra Agent
ID or Agent 365 coverage where those capabilities apply, replace shared secrets
with managed identity or workload federation, narrow RBAC/API permissions,
separate app-only and OBO decisions, define denied actions, capture audit
correlation, retire unused identities, or block unclear authority paths.

### What the list captures

For the pilot agent or portfolio slice, the review records:

- **Evidence source:** where the record came from, which product or tenant scope
  it covers, and what it explicitly excludes.
- **Human sponsor:** who is accountable for purpose, lifecycle, acceptable use,
  and recheck conditions.
- **Agent identity:** whether there is an Agent ID/Agent 365 record or another
  directory/control-plane record that can represent the agent as an accountable
  runtime actor.
- **Host workload identity:** which managed identity, federated credential, app
  registration, service principal, or host record can request or exchange tokens.
- **Runtime mode:** whether the agent runs app-only/autonomously, on behalf of a
  user, or in two separate paths.
- **Access boundary:** which gateway, API, environment, data zone, or RBAC scope
  limits the runtime action, and which actions are explicitly denied.
- **Audit and disable route:** which owner can stop the agent or credential path,
  and which sign-in, audit, gateway, application, or resource logs preserve the
  actor and correlation path.
- **Lifecycle review:** purpose, current state, recheck condition, reviewer, review
  date, findings, next review date, and retirement condition.

Real IDs, customer identity payloads, tokens, and personal data stay in the
customer's approved system, never in this repo.

## 2. Prerequisites

- A customer identity admin who can open the right admin source for the workload
  in scope (for example, Entra Agent ID).
- A place the customer already trusts to store the list, evidence, and decisions.
- A named governance lead who can accept gaps in coverage and sign off on ownership.

You do **not** need Conditional Access licensing, a break-glass design, Graph
PowerShell, or any particular Entra Agent ID setup to run this session.

## 3. What the identity trace must prove

You cannot govern an agent by finding a row and writing down an owner. A useful
identity workshop traces the actual path:

1. A human sponsor accepts accountability for the agent's purpose and lifecycle.
2. A host workload identity obtains or exchanges tokens without hiding behind
   unmanaged secrets.
3. The agent identity represents the runtime actor where supported.
4. App-only or delegated/OBO authority is constrained to the bounded purpose.
5. Gateways, APIs, RBAC, connectors, and data services enforce resource scope.
6. Sign-in, audit, gateway, application, and resource telemetry support
   investigation.
7. The customer can disable the right object or route without losing audit
   history.

S1 produces a trusted list, named accountability, and an honest coverage
statement. A directory search is not an agent inventory, OBO telemetry is not an
ownership record, and gateway authentication is not production approval.

Use [Technical decisions](technical.md) for the Entra Agent ID object model,
OBO/app-only paths, and gateway boundary checks.

## 4. Change boundary

This kit changes nothing in the tenant. The customer's identity-change process
owns any Conditional Access, break-glass, access remediation, rollback,
verification, and evidence retention.
