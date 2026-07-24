# S11 Takeaway Kit: Operate, Monitor & FinOps

This optional, offline kit supports a customer-owned 90-minute operating-review
definition after a preceding operating review or formal deferral. It covers evidence coverage, reliability, risk, quality,
cost ownership, adoption, business outcome, drift hypotheses, escalation,
remediation validation, recurrence, and exceptions. It does not connect to
live data, create a dashboard, calculate metrics, set thresholds, store
customer data, or implement a change.

**Decision:** choose signal source, attribution, alert route, and closure route;
record approve, defer, reject, or route. Default to Azure Monitor/Application
Insights with OpenTelemetry for app paths and use Foundry observability only
where verified and applicable. Hand off evaluation/baseline work to S7,
lifecycle work to S12, and portfolio work to S13. No template approves a
customer-system change or production.

Start with [runbook.md](runbook.md). Copy blank templates to approved records
and retain only approved references in the delivery workspace.

`templates/technical-decision-record.template.md` captures the selected,
deferred, or rejected observability-stack, cost-attribution, and alerting/drift
decision with owners and adoption stage.

`templates/quality-cost-latency-review.template.md` is an optional addendum for
bounded quality trend, latency drift, and token-cost accountability questions.
It complements rather than replaces `templates/operating-review.template.md`.

`templates/performance-telemetry-review.template.md` is an optional addendum for
production agent performance: first-token latency, end-to-end latency,
throughput, and error/saturation from OpenTelemetry, Application Insights, or
Foundry traces, including reconciliation against an approved synthetic baseline as a
drift hypothesis. See the
[agent performance-testing guide](../../docs/reference/performance-testing-guide.md).

`templates/telemetry-alert-operating-model.template.md` maps the
customer-held signal sources, correlation and retention limits, alert-response
ownership, suppression review, remediation validation, and exception handoff.
It defines an operating model; it does not create alerts or query telemetry.
