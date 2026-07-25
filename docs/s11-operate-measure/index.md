# S11 · Operate, Monitor & FinOps

!!! info "Freshness"
    Last reviewed: 2026-07-15

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Service owner</span> <span class="rvas-badge rvas-persona">Cost owner</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer has a repeatable operating review for
Foundry observability, cost, drift, remediation, and exceptions.

**Plain decision question:** For this workload and period, which signal source,
attribution method, alert route, and closure route should the review use?
Record **approve, defer, reject, or route**. Default to Azure
Monitor/Application Insights with OpenTelemetry for customer application paths;
use Microsoft Foundry observability where verified and applicable. Any exception
needs documented coverage, attribution, retention, owner, and acceptance
criteria.

They leave with a customer-owned review definition that names:

- the population, cadence, evidence coverage, accountable owners, and decision
  use;
- selected reliability, risk, quality, cost, adoption, business-outcome, and
  control-coverage questions; and
- drift hypotheses, escalation routes, remediation checks, recurrence checks,
  and exception paths.
- Where alert operations are in scope, a telemetry-and-alert operating model
  that maps signal coverage, retention, response ownership, suppression review,
  remediation validation, and exception handoff.

`labs/s11-operate-measure/` holds blank offline templates and a runbook. It does
**not** connect to live data, create a dashboard, calculate metrics, set
thresholds, store customer data, or implement a change.

### What happens next

**Next customer action:** put the adopted review on the customer operating
cadence, then assign its alerts, remediation checks, exceptions, and cost
actions to named owners.

S11 creates an operating backlog for customer-owned work. The recommendation
states whether to adopt, defer, or reject the review definition.
It also names the Azure Monitor, Application Insights, OpenTelemetry, Foundry
observability, alert route, remediation check, review cadence, FinOps/cost owner,
allocation, exception, or S13 portfolio item that needs an owner.

## 2. Prerequisites

- S9 is closed out, or the S9 deferral is documented with current open findings.
- A governance lead can assign the review decision and cadence.
- Service, evidence, and cost owners can describe available records and coverage
  limits for the in-scope questions.
- The customer has an approved records location for references and decisions.

## 3. Why this session matters

Operating governance needs a cadence, not just a dashboard. The customer needs a
clear path from evidence coverage to interpretation, decision, escalation,
remediation validation, recurrence review, and exception accountability.

**Microsoft Foundry observability** can provide traces, token usage, latency, and
evaluation signals when the customer enables and retains them. FinOps evidence
can show spend ownership and allocation limits. Neither one closes a finding by
itself.

Read the [S11 Concepts](concepts.md) before delivery.

## 4. Change boundary

S11 makes no live-data query and no platform, dashboard, metric, threshold,
identity, policy, remediation, exception, or production change. Any action uses
the customer's approved engineering and change process.
