# S11 Takeaway Kit — Operate, Monitor & FinOps

This optional, offline kit supports a customer-owned 90-minute operating-review
definition after S9. It covers evidence coverage, reliability, risk, quality,
cost ownership, adoption, business outcome, drift hypotheses, escalation,
remediation validation, recurrence, and exceptions. It does not connect to
live data, create a dashboard, calculate metrics, set thresholds, store
customer data, or implement a change.

Start with [runbook.md](runbook.md). Copy blank templates to approved records
and retain only approved references in the delivery workspace.

`templates/quality-cost-latency-review.template.md` is an optional addendum for
bounded quality trend, latency drift, and token-cost accountability questions.
It complements rather than replaces `templates/operating-review.template.md`.

`templates/performance-telemetry-review.template.md` is an optional addendum for
production agent performance — first-token latency, end-to-end latency,
throughput, and error/saturation from OpenTelemetry, Application Insights, or
Foundry traces — including reconciliation against an S7 synthetic baseline as a
drift hypothesis. See the
[agent performance-testing guide](../../docs/reference/performance-testing-guide.md).
