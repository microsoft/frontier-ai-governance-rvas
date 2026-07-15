# Customer-operated gateway proof evidence manifest

Create one manifest for each non-production gateway test. The adapter emits
schema version `1.0` with safe references only. Store it with the customer's
approved governance evidence, not with credentials, endpoint values, raw
responses, prompts, documents, or unredacted telemetry. A direct Content
Safety component response is useful component evidence, but it must be
recorded as `testMode: component`; it cannot satisfy the gateway-path proof
fields below.

## Required fields

| Field | Record |
|---|---|
| `schemaVersion`, `manifestType`, `capturedUtc` | Fixed version (`1.0`), manifest type, and capture time. |
| `proofId`, `environmentLabel` | Correlation identifier and non-production environment label. |
| `gatewayReference`, `accessContractReference` | Safe references to the customer platform and contract records; never a URL. |
| `backendReference`, `policyReference` | Safe references to the approved backend and runtime policy/configuration record. |
| `expectedBehavior` | Short, non-sensitive statement of the expected gateway behavior. |
| `requestEvidenceReference`, `telemetryEvidenceReference` | Safe references to the customer request/change record and telemetry record. |
| `result.state`, `review.state` | Adapter result (`request-submitted` or `request-failed`) and human review state (`pending`, `reviewed`, `accepted`, or `blocked`). |

## Redacted example

```yaml
schemaVersion: "1.0"
manifestType: rvas.s3.gateway-proof
capturedUtc: 2026-07-15T08:00:00Z
proofId: rvas-s3-gateway-20260715T080000Z
environmentLabel: customer-nonproduction
gatewayReference: platform-record:gateway-np
accessContractReference: contract-record:approved-route
backendReference: backend-record:content-safety-np
policyReference: policy-record:prompt-shields-v1
expectedBehavior: Approved gateway route returns a recorded result
requestEvidenceReference: change-record:request-window
telemetryEvidenceReference: telemetry-record:proof-query
result:
  state: request-submitted
review:
  state: pending
```

The adapter writes this manifest only. A platform owner changes `review.state`
after correlating the proof ID with customer telemetry; a submitted request is
not an accepted control. Keep raw gateway traces, response output, and any
sensitive request details in separately approved customer systems.
