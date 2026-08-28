---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Session 06</p>

# Azure API Management as the AI gateway

**210 minutes - One configured APIM route to the governed agent**

<!-- Notes: Session 05 established the agent. Today we configure the controlled APIM route to that endpoint. -->

---

## Control objective

> Configure one API Management route. It checks the client token and product subscription, applies limits and Content Safety policies, and uses managed identity to call the pinned Foundry agent.

### Result check

- The operational APIM API path reaches the pinned [Session 05](../05-governed-agent-baseline/) Responses endpoint.
- Client identity and product subscription are checked before the backend hop.
- Runtime limits, safety, routing, and logs are applied as one policy.
- An invalid identity receives `401 Unauthorized`.

<!-- Notes: The check is deliberately narrow. It proves the authentication boundary without sending a valid request to the agent. -->

---

## Implementation outcomes

1. Expose one governed agent operation through APIM.
2. Separate client authorization from backend identity.
3. Apply token, request-size, timeout, safety, and resiliency controls.
4. Emit correlation and token metrics without prompt or response bodies.
5. Keep a rerunnable APIM definition in the gateway repository and scoped removal guidance.

<!-- Notes: Keep the focus on the deployed control, not a catalog of APIM features. -->

---

## Why it matters

The configured APIM route gives the API product owner one place to manage workload access and limits.

Client authorization stays separate from the managed identity used for the Foundry call.

Operations gets correlation and token metrics without prompt or response logging.

<!-- Notes: The value comes from one owned route, not from claiming universal coverage. -->

---

## Control boundaries

- The control applies to calls sent through the configured nonproduction APIM route.
- The direct Foundry endpoint still exists and remains the live source for agent runtime state.
- This session does not prove that every client path uses APIM.
- Production ingress, semantic caching, secondary-region routing, and write-capable agents are out.
- API Center inventory and MCP controls remain Sessions 07 and 08 review records.

<!-- Notes: Direct endpoint access needs its own owner and control. -->

---

<!-- _class: section-divider -->

# APIM checks calls sent through the configured route

API Center records the API in [Session 07](../07-api-center-ai-mcp-inventory/).

The workload sends its Microsoft Entra token and APIM subscription key to one route. APIM validates
both, applies limits and safety checks, then replaces caller authorization before the Foundry call.

The direct Foundry endpoint still exists. This boundary covers only traffic sent through APIM.

<!-- Notes: Avoid mixing design-time inventory with runtime enforcement. -->

---

## APIM AI gateway is not a separate service

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

The AI gateway is a set of Azure API Management controls for AI traffic.

It covers:

- OpenAI-compatible model APIs and Foundry endpoints
- MCP servers, A2A APIs, and self-hosted backends

The current APIM tier must be **Developer, Basic, Basic v2, Standard, Standard v2, Premium, or Premium v2**.

> Use stable APIM resource APIs and documented LLM policies. Do not use the unified model API preview.
<!-- Notes: Product language matters. Do not imply that the customer needs another gateway service. -->

---

## Architecture overview

<!-- _class: diagram -->

![An ordered APIM request pipeline validates the product subscription and Entra token, applies size, token, and safety controls, then routes with circuit-breaker protection and managed identity to the pinned Foundry endpoint while emitting body-free logs](assets/diagrams/apim-ai-gateway-flow.svg)

<!-- Notes: The boundary covers calls sent through this APIM route. Direct Foundry access remains separate. -->

---

## What this means

Every governed call follows one APIM route. Inbound policy identifies the workload, assigns its
usage, and checks request size, token use, and content. APIM selects a backend only after those
checks pass. It then uses its own managed identity to obtain a Foundry token and call the pinned
agent.

APIM owns the route and runtime policy. Foundry owns the agent. Application Insights receives
correlation and token metrics without request or response bodies. Session 07 receives the API
definition and runtime location.

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Chosen approach | Why it works | Tradeoff |
|---|---|---|---|
| Client access | Entra app token plus one APIM subscription per workload | Identity and usage allocation can be revoked separately | Each client manages two credentials |
| Backend access | Scope the APIM managed identity to one agent | APIM stores no backend key | Direct Foundry access needs a separate control |
| Safety | Run APIM Content Safety before the Foundry RAI policy | APIM can stop unsafe input before the agent call | The check adds latency, cost, and another data path |
| Routing | Use the primary backend with one read-safe retry | The failure path stays bounded | This session provides no regional failover |

<!-- Notes: The client bearer token is replaced before the backend call. Revisit routing in Session 14. -->

---

<!-- _class: decision -->

## Decision 1 - Client authorization

The workload-specific controlled product subscription is issued before the session.

Resolve before deployment:

1. Microsoft Entra tenant.
2. Calling application ID.
3. API audience.
4. Required application role.
5. Product owner and one-subscription-per-workload process.

Stop if the workload uses a shared key or an ambiguous audience.

<!-- Notes: A subscription key is an allocation and revocation control. The Entra token carries application identity and role. -->

---

## Ingress policy order

```text
1  Set or preserve X-Correlation-ID
2  Validate tenant, client app, audience, and app role
3  Reject oversized request bodies
4  Apply token rate and daily quota per subscription
5  Run Prompt Shields and harm-category checks
6  Select the backend pool
7  Acquire the APIM managed-identity token
```

Identity fails before safety processing or a Foundry call.

<!-- Notes: Policy order is part of the security design. -->

---

## Workload limits

| Control | Approved default |
|---|---:|
| Token rate | 20,000 TPM per APIM subscription |
| Token quota | 500,000 tokens per day |
| Request body | 65,536 bytes |
| Backend timeout | 120 seconds |
| Retry | One retry for 429 and 5xx |

Limits are starting values. Each APIM gateway keeps its own counters.

The API product owner divides the workload allowance into per-region budgets. The platform owner configures them in Session 14.

<!-- Notes: Token counters are gateway-local. Session 14 must budget them per region. -->

---

<!-- _class: decision -->

## Decision 2 - Retry and routing

The primary backend is the pinned Session 05 agent.

- Circuit opens after five 429/5xx responses in one minute.
- The circuit remains open for one minute.
- One buffered retry is allowed because the agent has a read-only tool.
- Secondary routing stays disabled until a distinct compatible endpoint is approved.

Stop if a retry could repeat a write or other consequential action.

<!-- Notes: Do not pull multi-region design forward just to fill a backend pool. -->

---

## Apply safety policy at APIM and the agent

<div class="cards">
<div class="card">

### Foundry model policy

The RAI policy from Session 05 remains attached to the agent.

</div>
<div class="card">

### APIM safety policy

Prompt Shields plus request and completion checks through Azure AI Content Safety.

</div>
</div>

APIM checks Hate, SelfHarm, Sexual, and Violence at threshold 4 on the eight-level scale.

For a streaming completion violation, APIM stops forwarding later events. The client can receive a
truncated stream instead of a normal `403`.

<!-- Notes: The safety owner approves the threshold and Content Safety data path. -->

---

<!-- _class: decision -->

## Decision 3 - Content Safety backend

Stop unless all are true:

- The APIM backend points to the approved Content Safety resource.
- Backend authorization uses APIM managed identity.
- APIM has **Cognitive Services User** on that approved resource.
- The network path and resource location are approved.
- The APIM threshold does not weaken the workload's safety decision.

<!-- Notes: The policy sends content to the Content Safety resource. Treat that as a real data path. -->

---

## Logs without content capture

![Application Insights](assets/icons/microsoft/application-insights.svg)

Application Insights receives:

- W3C operation correlation
- APIM request, dependency, latency, and error logs
- LLM token metrics by API, product, and subscription

Request body bytes, response body bytes, and client IP logging are set to zero or disabled.

Streaming clients set `stream_options.include_usage=true`. Interrupted streams can leave token
counts incomplete, and token-limit counts are estimated. Cost Management and invoices remain the
billing record.

<!-- Notes: Correlation and consumption data are enough for this control. Prompt logging is not a default. -->

---

## Semantic caching stays off

Semantic caching can reduce latency and token use. It can also return stale or cross-context content when its boundaries are wrong.

Keep it off until:

- the data owner approves eligible content;
- the identity owner approves tenant and workload cache keys;
- the API product owner sets maximum age and invalidation events; and
- operations owns access, purge, retention, and incident handling.

<!-- Notes: A feature being available is not an implementation decision. -->

---

## Operational control tree

```text
gateway/
  main.bicep
  apis/policy-assistant-responses.openapi.json
  policies/policy.xml
governance/
  gateway-control.json
environments/sandbox.json
scripts/
  preflight.ps1
  deploy.ps1
  manual removal guidance
```

Runtime backend URLs, subscription IDs, product keys, and bearer tokens stay out of source control.

---

<!-- _class: implementation -->

## Deploy the APIM runtime policy

**Timebox: 270 minutes**

1. Resolve identity, ownership, limits, safety, and routing decisions.
2. Run preflight and inspect the APIM `what-if`.
3. Deploy the API, product, policy, pool, and diagnostics.
4. Use the workload-specific product subscription issued before the session.
5. Call the gateway once with an invalid bearer token.

<!-- Notes: Existing identities, Content Safety, logs, and the Session 05 agent are prerequisites. -->

---

## Preflight safety gates

- Every required decision sentinel is resolved.
- The operator has time-bound **Contributor** on the approved APIM resource group.
- APIM is in the approved resource group and on a supported tier.
- APIM has a system-assigned managed identity.
- Agent-scoped Foundry Agent Consumer is present.
- Content Safety backend, resource, and role assignment match.
- Application Insights logger exists.
- Agent base URL matches the existing account, project, and agent.
- Existing API ID is absent or carries the Session 06 marker.

<!-- Notes: Preflight ends with an ARM what-if. Any unrelated delete or replacement is a stop. -->

---

## Apply the control

```powershell
.\scripts\deploy.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -PrimaryAgentBaseUrl $primaryAgentBaseUrl `
  -SecondaryAgentBaseUrl $secondaryAgentBaseUrl
```

Expected state: one governed API and product, a primary-first backend pool, fail-closed identities, the deployed LLM policies, and body-free Application Insights diagnostics.

<!-- Notes: Deployment changes child resources in the existing APIM instance. -->

---

## Confirm the result

The invalid bearer check proves only that APIM blocks that identity before Content Safety or Foundry is called.

Call the APIM path with:

- A valid workload product subscription key
- `Authorization: Bearer invalid-session06-token`
- A synthetic request body

Expected result: `401 Unauthorized`.

The request stops at APIM. Content Safety and the Foundry agent are not called.

<!-- Notes: Do not retain the response, key, or headers. One visible standard-mode check is enough. -->

---

## Live state and ownership

| Live state | Owner |
|---|---|
| Product subscriptions and workload limits | API product owner |
| Entra app role and APIM identity access | Identity owner |
| APIM capacity, backend pool, and circuit breaker | Platform owner |
| Content Safety backend and threshold | Safety owner |
| Correlation, metrics, retention, and alerts | Operations owner |

Removal deletes only the marked Session 06 APIM child resources.

<!-- Notes: Foundry, Content Safety, Application Insights, and role assignments remain. -->

---

## Recap

- Require an APIM product subscription and a valid Entra application token.
- Use APIM managed identity for the pinned Foundry agent.
- Apply per-workload token limits, Prompt Shields, and harm checks.
- Emit correlation and token metrics without body logging.

Next: register the AI API and its required metadata in [Session 07](../07-api-center-ai-mcp-inventory/).

<!-- Notes: APIM now checks requests on the configured route. The design-time inventory comes next. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: Close on the owned runtime control and the next dependency. -->
