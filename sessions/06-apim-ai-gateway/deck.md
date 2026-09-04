---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 06</p>

# Azure API Management AI gateway design and implementation

270 minutes · Record the design, deploy one controlled route, and check its ingress boundary

<!-- Notes: Work on one nonproduction Foundry Agent Service policy-assistant route. -->

---

## Why it matters

**Problem.** An unrecorded gateway change can drift from what was approved, and forwarding the
caller's own credential to Foundry would let a compromised client reach the agent directly.

**Solution.**

- The design record locks scope, backend, identity, network, safety, and restore decisions before
  deployment.
- APIM calls Foundry with its own managed identity, never the caller's credential.
- Deployment preflight and ARM `what-if` confirm the preview touches only the marked scope.
- APIM returns `401 Unauthorized` for an invalid bearer token before Content Safety or Foundry ever
  sees it.

<!-- Notes: The invalid-token check is the one standard-mode result. -->

---

<!-- _class: two-column -->

## Architecture and control boundary

<div class="columns">
<div>

The caller sends an Entra application token and APIM subscription key. APIM validates both, applies
limits and Content Safety, then uses its managed identity for the pinned Foundry agent.

Application Insights receives correlation and token metrics. No request or response body is logged.

</div>
<div>

![An approved client passes APIM identity, limit, safety, and routing gates before reaching the Foundry agent.](assets/diagrams/apim-ai-gateway-flow.svg)

</div>
</div>

<!-- Notes: APIM owns the live route. Foundry owns the agent. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Required answer |
|---|---|
| Scope | Approved nonproduction APIM resource group and change record |
| Backend | Pinned Foundry agent, endpoint reference, and managed-identity access |
| Network | APIM, Foundry, and Content Safety paths agree with the design record |
| Safety | Approved Content Safety backend and threshold |
| Restore | Named route disable or rollback path |

**Keep the current APIM route when a decision or readiness gap is open.**

<!-- Notes: Design preflight runs before Azure preflight. -->

---

<!-- _class: implementation -->

## Working path

**Total session: 270 minutes. Guided work: about 210 minutes.**

1. Complete `gateway-design-record.json` and the deployment inputs.
2. Run combined preflight. It checks the record before Azure and ARM `what-if`.
3. Review the preview and stop if it reaches APIM itself or an unrelated resource.
4. Deploy the marked API, product, backend pool, policy, and diagnostics.
5. Send the synthetic invalid-token request once.

Reserve time for decisions, preview review, and the operating handoff.

<!-- Notes: Do not enter endpoint URLs, keys, tokens, prompts, responses, or customer data in source control. -->

---

## Required controls and access

| Control | Required value |
|---|---|
| Operator | Time-bound Contributor on the exact APIM resource group |
| APIM identity | Foundry Agent Consumer on the individual agent |
| Content Safety identity | Cognitive Services User on the exact resource |
| Client | Approved Entra application identity and workload subscription |
| Telemetry | Correlation and token metrics; zero body logging |
| Retry | One read-safe retry; secondary backend disabled |

<!-- Notes: Stop if the retry can repeat a consequential action. -->

---

<!-- _class: implementation -->

## Confirm, operate, and hand off

### Confirm once

Use a valid workload subscription key with an invalid bearer token. APIM must return `401` before
Content Safety or Foundry receives the request.

### Keep in operation

The delivery owner maintains the design record. The platform owner maintains the deployment
configuration. The product, identity, safety, and operations owners maintain their controls.

[API Center and MCP inventory guide](../07-api-center-ai-mcp-inventory/) records the route in API Center. [MCP tool security guide](../08-mcp-tool-security/) adds the MCP tool boundary.

<!-- Notes: Restore through the approved APIM path. Remove only marked APIM gateway child resources. -->

---

<!-- _class: closing -->

# Thank you!
