# Implementation artifacts

These files define the APIM route for the
[Session 05](../../../05-governed-agent-baseline/implementation/README.md) agent.

| Path | Operational purpose |
|---|---|
| `gateway/main.bicep` | Defines the API, named values, backends, product, policy, and diagnostics in the existing APIM instance |
| `gateway/apis/policy-assistant-responses.openapi.json` | Defines the public Responses operation |
| `gateway/policies/policy.xml` | Validates ingress identity and applies limits, safety, backend identity, retry, telemetry, and response controls |
| `governance/gateway-control.json` | Records deployment values for limits, identity, safety, routing, ownership, and cache settings |
| `governance/model-routing-decision.md` | Records the approved routing boundary. Owners review it every 90 days and before changing a secondary route |
| `environments/sandbox.json` | Names the approved nonproduction APIM, Foundry agent, safety, and telemetry resources |

Keep runtime subscription IDs and backend URLs outside the repository. Resolve every
`__REQUIRED_*__` value before deployment. Preflight rejects unresolved values.
