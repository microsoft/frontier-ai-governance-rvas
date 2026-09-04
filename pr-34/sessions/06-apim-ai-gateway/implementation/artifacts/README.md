# Implementation artifacts

| Path | Type | Consumer | Purpose |
|---|---|---|---|
| `gateway-design-record.json` | Record | Gateway deployment operator and preflight scripts | Records the approved scope, design decisions, owners, and readiness gaps. |
| `gateway/main.bicep` | Deployment | Session 06 deployment scripts | Deploys the marked APIM API, product, backends, diagnostics, and policy. |
| `gateway/apis/policy-assistant-responses.openapi.json` | Deployment | API Management API import | Defines the client-facing Responses operation. |
| `gateway/policies/policy.xml` | Deployment | API Management gateway runtime | Applies the client, safety, routing, identity, and telemetry controls. |
| `governance/gateway-control.json` | Deployment | Session 06 preflight and deployment scripts | Supplies the approved gateway settings. |
| `governance/model-routing-decision.md` | Record | Product, platform, safety, and operations owners | Records routing and restore decisions. |
| `environments/sandbox.json` | Deployment | Session 06 preflight and deployment scripts | Binds actions to approved nonproduction resources. |

`preflight-design` checks the record locally. `preflight-implementation` checks the deployment
inputs and live Azure state. `preflight` runs them in that order.
