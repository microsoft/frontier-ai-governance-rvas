# S5 · Tool/API Admission & Withdrawal: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Azure API Center, Azure API Management,
    Entra/JWT, managed identity, delegated OAuth/OBO flows, MCP governance
    patterns, connector controls, and APIM AI Gateway policies change over time.
    Verify official docs, tenant support, region, licensing, and customer policy
    before delivery.

## Microsoft default

Default to Azure API Center or the approved catalog for admission,
Azure API Management for approved exposed routes, Microsoft Entra/JWT for caller
identity, and customer connector/MCP publication controls. Use the in-process
governance path only when the needed decision must happen inside the agent
process immediately before a tool call.

![S5 tool/API admission package: trace one consumer through identity, catalog/API Center, gateway or alternative route, operation boundary, audit/correlation, and withdrawal path before admitting the tool.](../assets/diagrams/s5-tool-api-governance-record-model.svg)

## Workshop route: admit or block one tool/API operation

1. **Choose one consumer and one operation.** Name the consuming agent/app,
   operation, data classes, side effects, environment, version, lifecycle state,
   evidence owner, and approved records location.
2. **Classify operation risk.** Mark read-only, write/update, approval-gated,
   admin/destructive, external side effect, bulk/export, sensitive-data, or
   dynamic tool-chaining. Identify blocked operations and hard stops.
3. **Compare admission routes.** Decide whether the route is API Center/APIM,
   allow-list, connector governance, MCP publication, runtime-control referral,
   reject/block, or withdrawal. Compare rejected alternatives and assumptions.
4. **Define the control path.** Identify catalog/API Center fields, APIM or
   equivalent route, identity contract, operation boundary, rate/quota,
   audit/correlation, consumer acceptance, and material-change triggers.
5. **Design withdrawal first.** Define how to disable, revoke, remove,
   unpublish, rotate, notify, verify, preserve investigation references, and
   close or roll back.
6. **Route downstream prerequisites.** Name platform, identity, connector/MCP,
   runtime, evaluation, data/privacy, catalog/control-plane, operations, and
   release owners as needed.
7. **Close the decision.** Approve only when the operation boundary is
   reviewable, observable, withdrawable, consumer-accepted, and ready for the
   customer's separate change process.

## Tool-call trace card

| Field | What to record |
|---|---|
| Consumer | Agent, app, workflow, user population, environment, owner, and lifecycle state. |
| Caller identity | Entra app, managed identity, delegated/OBO path, service principal, JWT issuer/audience, or approved equivalent. |
| Route | API Center/APIM, gateway, connector, MCP server/tool, allow-list, or runtime-control referral. |
| Operation | Method/action/tool name, schema/version, read/write/admin class, data classes, side effects, blocked operations. |
| Boundary | Allowed resources, scopes, target systems, approval requirement, over-scope handling, and exception owner. |
| Controls | Auth, backend auth, quota/rate, cost owner, content-safety or prompt-shield intent, diagnostics, correlation. |
| Consumer acceptance | Accepted operations, failure mode, retry/fallback, review cadence, material-change trigger. |
| Withdrawal | Disable/revoke/remove/unpublish/rotate/notify path, owner, verification reference, and closure decision. |

## Compare admission routes

| Route | Package fields | Do not use when... |
|---|---|---|
| API Center/APIM | API Center or catalog entry, API/product/backend, policy route, JWT validation, backend auth, subscription/product, quota, diagnostics, correlation, owner, lifecycle, withdrawal. | No platform owner, no identity contract, no audit, no revocation path, or consumers bypass the route. |
| Allow-list | Source/package/version, approved operations, consumer list, expiry, review cadence, owner, revocation path, stop condition. | The tool has broad write/admin authority, unknown source, no owner, no expiry, or no consumer boundary. |
| Connector governance | Connector owner, environment, permission model, admin consent, DLP/data boundary, solution/package reference, publication and withdrawal path. | Permission model is unclear, consent owner is missing, DLP boundary is unknown, or withdrawal is not executable. |
| MCP publication | Server/tool schema, version, auth scopes, consumer scope, rate/quota, audit, source trust, publication state, unpublish trigger. | Tool schema or auth is unreviewed, consumers are unknown, actions are unbounded, or no unpublish path exists. |
| Runtime-control referral | Per-call allow/deny/approval need, required runtime evidence, policy owner, telemetry/correlation, stop condition. | The decision can be made statically through admission records and does not need per-call context. |
| Reject/block/withdraw | Unsafe authority, unsupported operation, missing owner, missing audit, no revocation path, expired owner, or unacceptable consumer impact. | A bounded owner-backed route can be completed with clear accepted-when criteria. |

## Operation-risk table

| Operation class | Required admission checks | Hard stop |
|---|---|---|
| Read-only lookup | Data class, caller identity, rate/quota, audit/correlation, consumer acceptance, withdrawal. | Sensitive or bulk data without data-owner route. |
| Write/update | Allowed fields/actions, approval or rollback owner, stronger audit, idempotency/retry behavior, over-scope handling. | Open-ended writes, no rollback, or no business owner acceptance. |
| Admin/destructive | Explicit exception route, break-glass or high-authority review, strict consumer boundary, incident and rollback plan. | Destructive authority without named approver, audit, or revocation. |
| External side effect | Target boundary, notification/compensation path, abuse handling, consumer impact, incident route. | Unknown recipient/target, no reversal path, or unmanaged external dependency. |
| Bulk/export | Data owner, minimization, retention/export handling, DLP/privacy route, quota, audit. | Unknown data class, unrestricted export, or missing retention owner. |
| Dynamic tool chaining | Runtime-control or in-process handoff, consumer review, material-change trigger, negative tests. | Tool selection can expand authority without review. |

## APIM AI Gateway admission checklist

When Azure API Management is the selected gateway route, S5 records intended
publication and policy boundaries. It does not configure policies or prove
runtime behavior.

| Control | Decision to record | Evidence or owner |
|---|---|---|
| Caller authentication | JWT validation, product subscription, managed identity, delegated/OBO flow, or approved equivalent. | API/product/policy reference, issuer/audience owner, identity handoff. |
| Backend authentication | Managed identity, credential manager, certificate, key vault-backed credential, or other approved route. | Backend record, credential owner, rotation/revocation path. |
| Product/subscription | Which APIM product/subscription maps consumer, owner, environment, and allocation. | Product owner, subscription owner, consumer mapping. |
| Rate and quota | Counter key: subscription, team, app, user/session, agent identity, or custom header. | `rate-limit`, `quota`, `llm-token-limit`, quota owner, abuse owner, exception process. |
| Token/cost metrics | Which dimensions support cost and operations review. | `llm-emit-token-metric`, Application Insights or Log Analytics owner, cost allocation owner. |
| Prompt/response safety | Whether Content Safety, Prompt Shields, blocklists, or response moderation are intended. | APIM policy owner, Content Safety owner, runtime-safety handoff. |
| Semantic cache | Whether caching is allowed for the data class, task, retention, and invalidation model. | Cache owner, embeddings backend, privacy/retention decision, data-governance route. |
| Diagnostics | Logs, correlation fields, retention/export path, investigation route, and blind spots. | Diagnostic settings, correlation header, retention owner, runtime and operations reviewers. |
| Resilience | Backend pool, load balancing, circuit breaker, retry, PTU overflow, fallback, regional failover. | Capacity owner, failure behavior owner, evaluation and operating-review handoff. |

Example policy names such as `validate-jwt`, `rate-limit`, `quota`,
`llm-token-limit`, `llm-content-safety`, `llm-semantic-cache-lookup`,
`llm-emit-token-metric`, `set-backend-service`, and `retry` can be useful
checklist anchors. Record the customer policy reference and owner; do not paste
live endpoints, secrets, payloads, or customer evidence into this repository.

### Sanitized APIM policy reference snippets

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
<!-- Token metrics: choose dimensions that support operations and FinOps. -->
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

## Model-consumption and quota reference

| Level | Quota or route question | Owner to record |
|---|---|---|
| Tenant/subscription | What overall model quota, PTU, pay-as-you-go, capacity, or rate limit applies? | Platform/capacity owner. |
| Product or department | Which APIM product, subscription, tag, or allocation rule maps spend to an accountable owner? | FinOps and platform owner. |
| Application or agent | Which API route, `x-agent-id`, subscription, or managed identity identifies the workload? | App/agent sponsor and gateway owner. |
| User or session | Does the use case require per-user, per-session, or delegated-context limits? | Product owner and identity/data owner. |
| Critical reserve | Is capacity reserved for operational or high-priority workflows? | Platform and business owner. |

Fallback can change cost, latency, data residency, and evaluation assumptions.
Record fallback behavior, owner, review cadence, and downstream handoff.

## Consumer acceptance checklist

| Check | Consumer must accept |
|---|---|
| Operation boundary | Allowed and blocked operations, fields, resources, data classes, and side effects. |
| Failure behavior | Timeout, retry, idempotency, fallback, manual route, and error surface. |
| Over-scope handling | What happens when the agent asks for an unapproved operation or data class. |
| Audit/correlation | Which request, tool call, agent/app, user/session, owner, and environment fields are joinable. |
| recheck conditions | Schema, route, scope, data, quota, owner, consumer, connector, MCP, policy, or lifecycle change. |

## Material-change triggers

| Trigger | Re-review question |
|---|---|
| Schema or operation change | Does the admitted operation boundary still match the actual tool/API? |
| Auth or scope change | Does least privilege still hold and is consent still valid? |
| Caller or consumer change | Does the new consumer accept the same boundary and withdrawal path? |
| Data-class change | Does data governance, privacy, retention, or DLP review change? |
| Gateway or policy change | Does the intended control path, diagnostics, quota, or evidence owner change? |
| Connector or MCP change | Does permission, tool schema, publication state, or unpublish path change? |
| Quota/cost change | Does rate limiting, abuse control, capacity, or FinOps ownership change? |
| Owner/lifecycle change | Does support, review cadence, withdrawal, or catalog state change? |

## Withdrawal execution table

| Withdrawal step | Required owner / reference |
|---|---|
| Disable route | APIM product/API/backend, connector, MCP publication, allow-list, or catalog owner. |
| Remove permission | Entra app, managed identity, delegated consent, scope, RBAC, or credential owner. |
| Rotate credential | Secret/certificate/key vault or backend credential owner. |
| Notify consumers | Consuming-agent/app owner, release owner, and communication route. |
| Preserve investigation references | Audit/correlation, diagnostic logs, retention/export owner, and incident route. |
| Verify withdrawal | Customer-owned verification reference and reviewer. |
| Close or reconsider | Lifecycle owner, backlog/change process, and next recheck condition. |

## Boundary note

S5 records tool/API admission choices. It publishes nothing, configures nothing,
grants no permission, proves no runtime enforcement, and authorizes no production
use.

## Related references

- Runtime-control implementation should have a named policy owner, evidence route, and enforcement boundary before use.
  per-call policy boundary.
- [Platform technical guide](../reference/platform-technical-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
