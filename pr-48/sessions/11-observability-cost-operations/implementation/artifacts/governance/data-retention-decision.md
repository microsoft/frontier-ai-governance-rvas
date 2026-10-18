# Data retention decision

## Lifecycle

| Field | Decision |
|---|---|
| Updater | The named observability owner with the named data-protection owner |
| Review cadence | Annually, and before a retention, legal-hold, or data-residency change |
| Consumer | The observability owner uses this record to apply the approved retention boundary |

| Field | Decision |
|---|---|
| Application Insights resource ID | `__REQUIRED_APPLICATION_INSIGHTS_RESOURCE_ID__` |
| Log Analytics workspace resource ID | `__REQUIRED_LOG_ANALYTICS_WORKSPACE_RESOURCE_ID__` |
| Retention days | `__REQUIRED_RETENTION_DAYS__` |
| Data residency status | `__REQUIRED_DATA_RESIDENCY_STATUS_CONFIRMED__` |
| Private-access boundary status | `__REQUIRED_PRIVATE_ACCESS_STATUS_YES__` |
| Daily cap decision | `__REQUIRED_DAILY_CAP_DECISION__` |
| Owner | `__REQUIRED_DATA_RETENTION_OWNER__` |

A daily cap is a last-resort ingestion control. It can create an observability gap. Use sampling
as the primary volume control.
