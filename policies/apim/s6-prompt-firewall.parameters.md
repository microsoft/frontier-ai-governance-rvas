# S6 prompt firewall APIM parameters

Use this guide when adapting
[`s6-prompt-firewall.policy.xml`](s6-prompt-firewall.policy.xml) to a
customer-owned non-production APIM route.

## Required placeholders

| Placeholder | Meaning | Customer owner |
|---|---|---|
| `{{correlation-header-name}}` | Header used to carry the S6 correlation value, such as `x-correlation-id` or the customer standard. | Telemetry owner |
| `{{content-safety-url}}` | Full prompt-inspection URL, including path and API version, verified against current Microsoft documentation and customer region support. | Security / platform owner |
| `{{content-safety-timeout-seconds}}` | Timeout for the inspection call. Start low enough to protect the route and high enough for the selected control. | Platform owner |
| `{{content-safety-key-header-name}}` | Header required by the selected inspection endpoint, such as `Ocp-Apim-Subscription-Key` when applicable. | Security / platform owner |
| `{{content-safety-key-named-value}}` | APIM named value reference for the credential, stored as a secret in customer APIM. Never paste the secret value into the policy file. | Platform owner |

## Response schema adaptation

The policy skeleton intentionally uses a simple marker check:

- `"attackDetected": true`
- `"block": true`

Replace this with the exact response schema for the customer-approved Prompt
Shields, Azure AI Content Safety, model-native, or equivalent inspection
control. Record the schema reference and reviewer in the customer work package.

## Telemetry dimensions

At minimum, preserve these values in APIM diagnostics, Application Insights, or
the customer telemetry path:

| Dimension | Purpose |
|---|---|
| Correlation value | Joins gateway, app, backend/model, and SOC records. |
| APIM operation/API/backend reference | Confirms the request used the reviewed route. |
| Prompt-firewall decision | Supports allow, block, annotate, or diagnostic-only classification. |
| Inspection status | Distinguishes policy allow/block from inspection outage or unsupported route. |
| Time window | Lets the reviewer reproduce the scoped query. |

## Safe adaptation checklist

1. Confirm the route is non-production and customer-approved.
2. Store credentials only in customer APIM named values or Key Vault references.
3. Verify current endpoint, payload, API version, region, and licensing support.
4. Test one allow case and one block or annotate case with synthetic input.
5. Query telemetry by correlation ID.
6. Route missing or partial signal states to the named owner.
7. Store evidence references, not evidence payloads, in the customer records
   system.

## What this policy does not prove

This policy file does not prove production enforcement, full route coverage,
SOC readiness, compliance, or release approval. It is a non-production reference
starting point until the customer adapts, deploys, observes, and approves it in
their own process.
