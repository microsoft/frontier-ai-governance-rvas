# Implementation artifacts

These files define one APIM route for the
[Session 05](../../../05-governed-agent-baseline/implementation/README.md) agent.

| Path | Operational purpose |
|---|---|
| `gateway/main.bicep` | Existing-instance APIM API, APIM named values, backends, product, policy, and diagnostics |
| `gateway/apis/policy-assistant-responses.openapi.json` | Public Responses operation contract |
| `gateway/policies/policy.xml` | Ingress identity, limits, safety, backend identity, retry, telemetry, and response controls |
| `governance/gateway-control.json` | Version-controlled deployment input for limits, identity, safety, routing, ownership, and cache settings |
| `governance/model-routing-decision.md` | Owner-approved routing boundary, reviewed every 90 days and before a secondary-route change |
| `environments/sandbox.json` | Approved nonproduction APIM, Foundry agent, safety, and telemetry coordinates |

Runtime subscription IDs and backend URLs stay outside the repository. Preflight rejects every
`__REQUIRED_*__` value before deployment.
