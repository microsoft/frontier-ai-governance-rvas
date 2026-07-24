# Customer-operated gateway proof evidence manifest

Create one manifest per non-production gateway test. The S6 adapter emits
`rvas.delivery.gateway-proof.v1` with safe references only. Store it with
approved customer governance evidence, never credentials, endpoint values, raw
responses, prompts, documents, or unredacted telemetry. A direct component
test cannot satisfy this gateway-path proof.

## Required fields

| Field | Record |
|---|---|
| `schema`, `pilot_agent_slug`, `environment_label` | Fixed schema name, safe agent identifier, and non-production environment label. |
| `gateway_reference`, `access_contract_reference` | Safe references to the customer platform and contract records; never a URL. |
| `backend_reference`, `policy_reference` | Safe references to the approved backend and runtime policy or configuration record. |
| `correlation_id`, `expected_policy_behavior` | Correlation identifier and a short, non-sensitive expected behavior. |
| `request_evidence_reference`, `telemetry_evidence_reference` | Safe references to the customer request or change record and telemetry record. |
| `result` | `pass`, `fail`, or `blocked`. A pass records transport evidence only. |

## Redacted example

```json
{
  "schema": "rvas.delivery.gateway-proof.v1",
  "pilot_agent_slug": "customer-agent",
  "environment_label": "customer-nonproduction",
  "gateway_reference": "platform-record:gateway-np",
  "access_contract_reference": "contract-record:approved-route",
  "backend_reference": "backend-record:content-safety-np",
  "policy_reference": "policy-record:prompt-shields-v1",
  "correlation_id": "rvas-s6-gateway-20260715T080000Z",
  "request_evidence_reference": "change-record:request-window",
  "telemetry_evidence_reference": "telemetry-record:proof-query",
  "expected_policy_behavior": "Approved gateway route returns a recorded result",
  "result": "pass"
}
```

The adapter writes only this manifest. A platform owner records the
correlation-review decision in the customer records system; a `pass` is not an
accepted control. Keep raw gateway traces, response output, and sensitive
request details in separately approved customer systems.
