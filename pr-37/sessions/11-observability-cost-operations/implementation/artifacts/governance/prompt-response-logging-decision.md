# Prompt and response logging decision

## Lifecycle

| Field | Decision |
|---|---|
| Updater | The named data-protection owner with the named observability owner |
| Review cadence | Quarterly, before an exception, and at each exception expiry |
| Consumer | The privacy and observability owners use this record to keep standard content logging disabled or operate an approved exception |

## Standard telemetry

| Field | Decision |
|---|---|
| Standard content logging | Disabled |
| Prompts logged by default | No |
| Responses logged by default | No |
| Tool payloads logged by default | No |
| Query strings logged by default | No |
| Authorization headers logged by default | No |

## Exception path

| Field | Decision |
|---|---|
| Status | `__REQUIRED_EXCEPTION_PATH_STATUS_DISABLED_OR_APPROVED__` |
| Purpose | `N/A` |
| Approved scope | `N/A` |
| Access owner | `N/A` |
| Retention days | `N/A` |
| Expiry date | `N/A` |

When the status is `Approved`, replace every `N/A` value with the approved, bounded exception.
When the status is `Disabled`, leave each value as `N/A`.

| Governance field | Decision |
|---|---|
| Decision owner | `__REQUIRED_DATA_PROTECTION_OWNER__` |
