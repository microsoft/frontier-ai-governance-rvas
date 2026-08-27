# Cost allocation decision

## Required resource tags

| Tag | Value |
|---|---|
| `application` | `__REQUIRED_APPLICATION_TAG__` |
| `environment` | `nonproduction` |
| `costCenter` | `__REQUIRED_COST_CENTER__` |
| `owner` | `__REQUIRED_COST_OWNER__` |
| `dataClassification` | `__REQUIRED_DATA_CLASSIFICATION__` |

## Ownership and interpretation

| Field | Decision |
|---|---|
| Pricing source owner | `__REQUIRED_COST_OWNER__` |
| Usage interpretation | Token telemetry is usage, not an invoice. Model and provider pricing, cached or reasoning tokens, streaming behavior, and delayed Cost Management data can change the estimate. |

The machine-enforced telemetry dimensions and prohibited attributes are defined once in
`../telemetry/telemetry-contract.json`.
