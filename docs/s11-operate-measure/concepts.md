# S11 · Operate, Monitor & FinOps Concepts

## An operating review turns evidence into a decision

![Scoped observability review yields operating decisions and S7-baseline drift hypotheses with owner or escalation routes.](../assets/diagrams/s11-operating-review-flow.svg)

An operating review is not a dashboard tour. It defines the population, review
period, coverage limit, accountable owner, and decision for each selected
question.

## Coverage comes before a result

Reliability, risk, quality, cost, adoption, and business-outcome observations
must say which population and time period they cover. An unavailable,
uninstrumented, or excluded population is a coverage limit. It is not a zero
result or a pass.

A question without trusted evidence or an accountable owner is blocked.

## Foundry observability supplies operating signals

For Foundry-based workloads, **Microsoft Foundry observability** can provide
traces, token usage, latency, and evaluation scores where the customer enables
tracing. Record the project, model deployment, agent or run identifier where
available, review period, sampling, retention, evaluator type and version, and
interpretation owner.

A production evaluation score is an operating signal. It is not sign-off to ship
and is accepted only for the signal, scope, and time period it records.

## Production performance telemetry is a distinct operating signal

Operating review also covers how fast the agent responds under real traffic.
OpenTelemetry, Application Insights, and Foundry traces can supply first-token
latency (TTFT/TTFB), end-to-end percentiles, throughput, and error/saturation
signals where the customer enables instrumentation. For a streaming agent,
first-token latency is a separate signal from end-to-end p95 and should be
recorded on its own.

Every production performance number carries a sampling, retention, and
population limit; an uninstrumented path is a coverage gap, not a zero result.
Reconcile production percentiles against any S7 synthetic baseline: a gap is a
drift hypothesis: workload mix, configuration, model version, quota pressure,
or evidence coverage, not confirmed drift. Use the shared
`labs/templates/decision-record.template.md` required considerations section,
the S11 lab README's performance-telemetry guidance, and the [agent
performance-testing guide](../reference/performance-testing-guide.md).

## FinOps is operating accountability

Cost review asks who owns the spend decision, which service or workload is in
scope, what allocation limits apply, and which decision the evidence can support.
The customer sets each metric, target, chargeback method, and threshold.

FinOps evidence should travel with an owner and a limit. A subscription total,
model bill, token count, trace sample, or allocation view helps only when the
workload scope, shared-cost assumptions, latency, exclusions, and decision owner
are recorded.

For Foundry workloads, cost evidence should identify the project, model
deployment, agent or run identifier where available, review-period token counts,
and shared-subscription assumptions. Subscription billing and project-level
attribution can have different scope. Fine-tuning training cost is separate from
inference cost, so both owners and review periods need to be recorded when a
fine-tuned model is in scope.

## Drift is a hypothesis to test

A change in reliability, risk, quality, cost, adoption, or outcome can suggest
drift. The cause might be behavior, workload mix, configuration, usage, evidence
coverage, or an external condition.

Record the hypothesis, evidence limits, owner, and test or observation plan. Do
not call drift confirmed without a clear review basis.

## Escalation and closure preserve accountability

Every finding needs an owner, target date, validation reference, recurrence
check, exception or escalation route, and next review.

Remediation is not closed because someone reports the work complete. Closure
requires a reviewer to check validation and remaining exceptions. S11 records
this operating method. Live queries, fixes, and configuration changes stay in
production.

Useful sources include Foundry traces and evaluations, Azure Monitor or
Application Insights, Security/SOC records, release scorecards, cost-management
views, and FinOps Toolkit outputs. S11 records references and limits, not raw
telemetry or a dashboard.

## Operating review becomes a work list

The S11 recommendation should turn the review design into owned operating work.
Typical work-list rows include Application Insights/OpenTelemetry coverage,
Foundry observability, alert route, remediation validation, recurrence check,
operating cadence, FinOps/cost owner, allocation limit, exception escalation,
S13 portfolio handoff, and customer support or change process.

The backlog does not create a dashboard, query live data, set a threshold, change
a control, or close a finding without validation.

## Related official references

| Reference | What it can inform |
|---|---|
| [Microsoft Foundry observability](https://learn.microsoft.com/en-us/azure/foundry/concepts/observability) | Trace, token, latency, and evaluation-score coverage planning. |
| [Azure Monitor overview](https://learn.microsoft.com/en-us/azure/azure-monitor/fundamentals/overview) | Operating signal and alert-route backlog. |
| [Application Insights overview](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) | Trace and telemetry correlation planning. |
| [Azure Cost Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/overview-cost-management) | Subscription-level attribution starting point. |
| [Fine-tune Microsoft Foundry models](https://learn.microsoft.com/en-us/azure/foundry/how-to/fine-tune-models) | Training versus inference-cost boundary; verify availability. |

## Visibility must be designed before it is needed

Logs, metrics, traces, and alerts show different parts of AI behavior. They help
only when population, sampling, retention, and interpretation owner are known.

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
for Azure Monitor, Application Insights, Log Analytics, Purview Audit, and
Foundry observability sources that can inform an operating-review backlog.
