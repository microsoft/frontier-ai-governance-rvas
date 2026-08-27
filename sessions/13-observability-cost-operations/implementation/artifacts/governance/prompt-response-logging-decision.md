# Prompt and response logging decision

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

When the status is `Approved`, replace every `N/A` value with the bounded exception decision.
When the status is `Disabled`, leave those values as `N/A`.

| Governance field | Decision |
|---|---|
| Decision owner | `__REQUIRED_DATA_PROTECTION_OWNER__` |
| Review date | `__REQUIRED_REVIEW_DATE__` |
