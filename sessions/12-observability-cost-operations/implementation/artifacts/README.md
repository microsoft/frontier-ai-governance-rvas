# Observability and operations control

These artifacts hold the Session 12 desired-state configuration and retained Markdown records.

| Path | Type | Updater and cadence | Consumer and operational purpose |
|---|---|
| `telemetry/telemetry-contract.json` | Runtime | Observability owner with the gateway and application owners; before instrumentation or APIM policy changes and quarterly | Application developers and preflight scripts use the correlation, sampling, and privacy contract |
| `infra/main.bicep` and `main.bicepparam` | Deployment | Observability owner; before deployment and quarterly | Azure deployment pipeline deploys the workbook and alert rules |
| `monitoring/workbook.json` and `queries/*.kql` | Deployment and runtime | Observability owner; quarterly and after the relevant SLO, tool, or evaluation-policy change | Workbook deployment and scheduled-query alerts use the definitions |
| `cost/budget.bicep` and `budget.bicepparam` | Deployment | Cost owner; before deployment and monthly | Subscription deployment pipeline deploys budget notifications |
| `cost/cost-allocation.md` | Record | Cost owner; monthly after billing data settles and before a tag or billing-scope change | Cost owner maintains allocation tags and interprets estimates against billed cost |
| `governance/data-retention-decision.md` | Record | Observability owner with data-protection owner; annually and before a retention, legal-hold, or data-residency change | Observability owner applies the approved retention boundary |
| `governance/prompt-response-logging-decision.md` | Record | Data-protection owner with observability owner; quarterly, before an exception, and at expiry | Privacy and observability owners keep standard content logging disabled or operate an approved exception |
| `operations/incident-runbook.md` | Record | Incident commander with service owner; quarterly and after an incident changes recovery steps | Incident commander and service operators use it for containment and recovery |

Replace every `__REQUIRED_*__` value with a customer decision. Do not put credentials, connection
strings, prompts, responses, tool payloads, user identifiers, or customer data in this tree.
For a `Disabled` prompt/response logging exception, keep every exception detail as `N/A`. An
`Approved` exception requires explicit values.

The observability owner configures error spans, exception records, and approved security events to
bypass normal trace sampling. They test the rule with existing safe records. If the approved
synthetic route emits no evaluation or security reference, mark that correlation check as not
applicable in the live operating view.

Treat the Application Insights connection string as runtime configuration. The approved synthetic
request uses the customer's existing client and agent. This tree creates no test resource or fixture.

The gateway owner keeps the APIM policy in the customer policy repository. The workbook embeds the
operator and correlation queries. The named Session 13 GitHub promotion workflow runs the paired
smoke scripts. They read live telemetry and write a payload-free check result only to the runner's
temporary workspace for immediate workflow use. This tree keeps no Session 12 runtime record.
