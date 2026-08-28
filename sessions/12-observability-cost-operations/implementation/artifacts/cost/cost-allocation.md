# Cost allocation decision

## Lifecycle

| Field | Decision |
|---|---|
| Updater | The named cost owner |
| Review cadence | Monthly after Cost Management billing data settles, and before a tag or billing-scope change |
| Consumer | The cost owner uses this record to maintain the required tags and interpret the operational estimate against billed cost |

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
| Usage interpretation | Token telemetry is usage, not an invoice. API Management tracks at most 100 unique values per dimension and 1,000 active time series per metric namespace, then silently discards data for new values or series beyond those limits. Model and provider pricing, cached or reasoning tokens, streaming behavior, and reporting delay can change the estimate. Cost Management billed cost is authoritative. |

The machine-enforced telemetry dimensions and prohibited attributes are defined once in
`../telemetry/telemetry-contract.json`.
