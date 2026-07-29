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

### APIM AI Gateway governance checklist

When Azure API Management is the selected gateway route, S5 records the intended
publication and policy boundary. It does not configure policies or prove runtime
behavior.

| Control | Decision to record | Evidence or owner |
|---|---|---|
| Caller authentication | Whether caller JWT validation, product subscription, or another approved identity path is required. | APIM API/product/policy reference, Entra app or issuer/audience owner, S1 identity handoff. |
| Backend authentication | Whether APIM uses managed identity, credential manager, or another approved route to reach the backend. | Managed identity or credential owner, backend record, rotation/revocation path. |
| Token and rate quotas | Which consumer key drives quota: subscription, team, application, user/session, or agent identity. | `llm-token-limit`, rate-limit policy, quota owner, exception process, S11 cost owner. |
| Prompt/response safety | Whether gateway-level Content Safety, Prompt Shields, blocklists, or response moderation are intended. | APIM policy owner, Content Safety resource owner, S6 runtime-safety handoff. |
| Semantic cache | Whether semantic caching is allowed for this data class and use case. | Cache owner, embeddings backend, privacy/retention decision, S2 data route. |
| Token metrics | Which dimensions should be emitted for cost and operations review. | `llm-emit-token-metric` dimensions, Application Insights or Log Analytics owner, S11 handoff. |
| Resilience | Whether load balancing, circuit breaker, retry, PTU overflow, or fallback backends are part of the publication route. | Backend pool, capacity owner, failure behavior, S11 operating route. |
| Diagnostics | Which logs, correlation fields, and retention/export paths support later runtime proof. | Diagnostic settings, correlation header, retention owner, S6/S11 reviewer. |

Example policy names such as `validate-jwt`, `llm-token-limit`,
`llm-content-safety`, `llm-semantic-cache-lookup`, and
`llm-emit-token-metric` can be useful checklist anchors. Record the customer
policy reference and owner; do not paste live endpoints, secrets, payloads, or
customer evidence into this repository.

#### Sanitized APIM policy reference snippets

These examples are placeholders for discussion with the platform owner. They are
not customer policy, deployment instructions, or runtime proof.

```xml
<!-- Caller JWT validation: replace issuer, audience, and policy owner in the customer record. -->
<validate-jwt header-name="Authorization" failed-validation-httpcode="403">
  <openid-config url="https://identity.example/.well-known/openid-configuration" />
  <audiences>
    <audience>api://agent-platform</audience>
  </audiences>
</validate-jwt>
```

```xml
<!-- Token quota: choose a counter key that matches the governance and FinOps decision. -->
<llm-token-limit
  counter-key="@(context.Subscription.Id)"
  tokens-per-minute="5000"
  estimate-prompt-tokens="true"
  remaining-tokens-variable-name="remainingTokens" />
```

```xml
<!-- Content Safety at the gateway: thresholds and blocklists are customer policy decisions. -->
<llm-content-safety
  backend-id="content-safety-backend"
  shield-prompt="true"
  enforce-on-completions="false">
  <categories output-type="EightSeverityLevels">
    <category name="Hate" threshold="4" />
    <category name="Violence" threshold="4" />
    <category name="Sexual" threshold="2" />
    <category name="SelfHarm" threshold="2" />
  </categories>
</llm-content-safety>
```

```xml
<!-- Token metrics: choose dimensions that support S11 operations and FinOps. -->
<llm-emit-token-metric namespace="llm-metrics">
  <dimension name="ApiId" value="@(context.Api.Id)" />
  <dimension name="SubscriptionId" value="@(context.Subscription.Id)" />
  <dimension name="TeamId" value="@(context.Request.Headers.GetValueOrDefault('x-team-id','unknown'))" />
  <dimension name="AgentId" value="@(context.Request.Headers.GetValueOrDefault('x-agent-id','unknown'))" />
</llm-emit-token-metric>
```

```xml
<!-- Semantic cache: record privacy, retention, data-class, and invalidation decisions first. -->
<llm-semantic-cache-lookup
  score-threshold="0.85"
  embeddings-backend-id="embeddings-backend"
  embeddings-model-name="text-embedding-3-small" />
```

#### Model-consumption governance reference

| Level | Quota or route question | Owner to record |
|---|---|---|
| Tenant/subscription | What overall model quota, PTU, pay-as-you-go, or capacity limit applies? | Platform/capacity owner. |
| Product or department | Which APIM product, subscription, tag, or allocation rule maps spend to an accountable owner? | FinOps and platform owner. |
| Application or agent | Which API route, `x-agent-id`, subscription, or managed identity identifies the workload? | App/agent sponsor and gateway owner. |
| User or session | Does the use case require per-user, per-session, or delegated-context limits? | Product owner and identity/data owner. |
| Critical reserve | Is capacity reserved for operational or high-priority workflows? | Platform and business owner. |

For resilience, record whether backends use priority, weight, circuit breaker,
retry, fallback, or regional failover. A fallback path can change cost,
latency, data residency, and evaluation assumptions; route those changes to
S7/S11 where relevant.

### MCP and API publication lifecycle

For an agent, API, tool, connector, or MCP server, record the lifecycle stage
and transition authority before broad use.

| Stage | S5 record | Handoff |
|---|---|---|
| Proposed | Candidate name, version, owner, intended consumers, allowed actions, classification, and source-trust assumptions. | Catalog/API owner. |
| Review or certification | Gateway route, identity path, quota, safety, data handling, observability, and withdrawal conditions. | Platform, security, identity, data, and S6/S7 owners as needed. |
| Publish-ready | Approved publication boundary, known exceptions, lifecycle owner, material-change trigger, and runtime-proof prerequisite. | Customer change/release process. |
| Published | Catalog/API Center entry, route status, version, consumer communication, support owner, and operating review route. | S9 lifecycle and S11 operating owners. |
| Suspended or withdrawn | Trigger, affected consumers, disable route, evidence-retention route, reconsideration owner, and closure decision. | S9 lifecycle owner and incident/change route. |

Publication through APIM can make a tool discoverable and enforce selected
policies. It does not prove the tool is safe, that every consumer uses the
route, or that downstream effects are acceptable. S6 reviews runtime evidence
for a bounded path; S9 reconciles catalog and lifecycle state.

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Publication record | Azure API Center API/tool entry, version, lifecycle state, owner |
| Gateway control | Azure API Management product, subscription, policy, backend, quota, safety policy, semantic cache, telemetry |
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
