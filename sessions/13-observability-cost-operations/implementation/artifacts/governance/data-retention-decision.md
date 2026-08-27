# Data retention decision

| Field | Decision |
|---|---|
| Application Insights resource ID | `__REQUIRED_APPLICATION_INSIGHTS_RESOURCE_ID__` |
| Log Analytics workspace resource ID | `__REQUIRED_LOG_ANALYTICS_WORKSPACE_RESOURCE_ID__` |
| Retention days | `__REQUIRED_RETENTION_DAYS__` |
| Data residency status | `__REQUIRED_DATA_RESIDENCY_STATUS_CONFIRMED__` |
| Private-access boundary status | `__REQUIRED_PRIVATE_ACCESS_STATUS_YES__` |
| Daily cap decision | `__REQUIRED_DAILY_CAP_DECISION__` |
| Owner | `__REQUIRED_DATA_RETENTION_OWNER__` |
| Review date | `__REQUIRED_REVIEW_DATE__` |

A daily cap is a last-resort ingestion control and can create an observability gap. Sampling is the
primary volume control.
