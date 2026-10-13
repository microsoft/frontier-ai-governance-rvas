---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: Claude Code and Desktop through a Foundry AI gateway
description: Optional implementation module for identity-controlled Claude inference through Azure API Management.
---

<!-- _class: cover -->

![RVAP](assets/logos/logo-full.png)

# Claude through a Foundry AI gateway

## Claude Code and Claude Desktop

Route Claude inference through an identity-controlled gateway.

<!-- Notes: Optional module beside Session 06; the numbered session route stays unchanged. -->

---

## Why it matters

Developer-managed provider keys make access and individual spend difficult to control.

**APIM validates the user and applies a model budget.**
Its managed identity calls Foundry.

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

<!-- Notes: The client retains a short-lived gateway token, never a Foundry key. -->

---

<!-- _class: two-column -->

## Architecture: one native protocol

```text
Code / Desktop
  -> optional WAF
  -> APIM
  -> Foundry Claude
```

Anthropic Messages throughout.
Preserve beta headers, body fields, and SSE events.

![Microsoft Foundry](assets/icons/microsoft/azure-ai-foundry.svg)

<!-- Notes: No OpenAI-compatible translation. The backend path ends in /anthropic. -->

---

## Two token contracts

| Client | Credential | Audience |
| --- | --- | --- |
| Code | Entra access token through Azure CLI | Gateway API URI |
| Desktop | Entra ID token through browser PKCE | Desktop client ID |

Both require the approved tenant and `Gateway.Invoke` role.
Code also requires `AiGateway.Invoke`.

![Microsoft Entra ID](assets/icons/microsoft/microsoft-entra-id.svg)

<!-- Notes: The shipped Code contract is v1. Check actual claims before applying it. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Choice | Route used here | Limit |
| --- | --- | --- |
| API | Native Messages passthrough | Separate from Session 06's agent Responses API |
| Budgets | Fragment included at API scope | UPN is mutable |
| Backend | Managed identity | Foundry sees APIM, not the end user |
| Network | Existing approved path | Required WAF needs bypass protection |

<!-- Notes: Model hosting and Global/Data Zone scope need a residency decision. -->

---

## Budget behavior

**User-model override -> model default -> zero**

Zero blocks the model. Unassigned identities never reach this lookup.

One monthly counter per normalized UPN and deployment.
Both clients share it.

Streaming and concurrency make counts approximate.
Token budgets are not hard currency caps.

<!-- Notes: Counters are gateway-local. Reconcile Marketplace billing separately. -->

---

<!-- _class: implementation -->

## Configure the route

1. Confirm Foundry deployments, hosting, and the APIM identity role.
2. Configure separate Entra apps and assigned roles.
3. Complete customer copies and run read-only preflight.
4. Import the budget fragment and apply the API policy.
5. Install Code settings and export Desktop MDM settings.

<!-- Notes: Four and a half facilitated hours assumes resources and approval owners are ready. -->

---

## Safety gates

Stop on an unexpected tenant, audience, or token version.

Stop if the required WAF can be bypassed.

**Log identity and request metadata, with zero body bytes.**

Review the effective policy before saving portal changes.

<!-- Notes: The backend uses one nonbuffering forward-request; reconcile inherited behavior. -->

---

## Client handoff

| Code | Desktop |
| --- | --- |
| `ANTHROPIC_BASE_URL` | Same gateway URL including API suffix |
| Token-only helper stdout | Interactive Entra sign-in |
| Exact deployment names | Explicit model configuration |
| Managed settings merge | Exported MDM profile |

Desktop needs the OIDC configuration as well as interactive credential mode.

<!-- Notes: Use the Desktop export format, not hand-written nested registry or plist keys. -->

---

## Observe both paths

**Permitted:** Code and Desktop stream a response using the same user-model budget.

**Blocked:** Wrong audience returns 401; an unassigned model returns 403.

The delivery owner observes both before wider rollout.

![Application Insights](assets/icons/microsoft/application-insights.svg)

<!-- Notes: Inspect body-free attribution and no backend invocation on the blocked path. -->

---

## Operating state and restore

Gateway owner: policy, budgets, and backend identity.

Identity owner: assigned users and token contracts.

Client owner: settings and supported builds.

Restore the prior API policy and managed client settings.
Keep shared resources; consumed counters do not roll back.

<!-- Notes: Hand billing reconciliation to operations. Do not delete a shared backend or identity role. -->

---

<!-- _class: closing -->

# Thank you!
