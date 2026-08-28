# Observability and operations control

These artifacts define the Session 12 observability and operations control.

| Path | Operational purpose |
|---|---|
| `control-definition.json` | Approved scope, owners, and observable result |
| `telemetry/telemetry-contract.json` | Span, correlation, content, sampling, and cardinality contract |
| `infra/main.bicep` and `main.bicepparam` | Workbook and three scheduled-query alerts |
| `monitoring/workbook.json` | Shared operational workbook definition |
| `queries/*.kql` | Alert queries consumed by the Bicep deployment |
| `cost/budget.bicep` and `budget.bicepparam` | Subscription budget with actual and forecast notifications |
| `cost/cost-allocation.md` | Required tags, pricing-source ownership, and cost interpretation |
| `governance/data-retention-decision.md` | Data-retention and access-boundary decision |
| `governance/prompt-response-logging-decision.md` | Prompt and response logging decision and exception expiry |
| `operations/incident-runbook.md` | Unsafe output, runaway usage, tool compromise, and model degradation response |

Replace every `__REQUIRED_*__` value with a customer decision. Do not put credentials, connection
strings, prompts, responses, tool payloads, user identifiers, or customer data in this tree.
For a `Disabled` prompt/response logging exception, keep every exception detail as `N/A`. An
`Approved` exception requires explicit values.

The observability owner configures error spans, exception records, and approved security events to
bypass normal trace sampling, then tests the rule with existing safe records. If the approved
synthetic route emits no evaluation or security reference, record that correlation check as
`not-applicable`.

The Application Insights connection string remains a runtime secretless configuration value. The
approved synthetic request uses the customer's existing client and agent; this tree creates no test
resource or fixture.

The gateway owner keeps the APIM policy in the customer policy repository, and the operational control
points to that source. Operator and correlation queries are embedded in the workbook. The paired
smoke scripts call the normal route and a dedicated handled-failure route. They require a failed
tool dependency, an independent successful model result, and no fixed marker across the five
documented Application Insights tables before writing a payload-free result for Session 12. They
poll both correlation IDs for no more than 180 seconds by default and report a failed check when ingestion misses the bounded
window. Before querying, they resolve the live component-to-workspace binding. Both correlated
request records must carry the exact CLI commit SHA in `release.commit.sha`. PowerShell holds the
bearer header in memory; Bash passes it to curl through standard input without writing the token to
disk. Normal and failure correlation IDs must remain valid and distinct after response overrides.
After readiness, three identical watermark summaries are required; the last query must still show
no marker, prohibited telemetry-contract property, or commit mismatch.
