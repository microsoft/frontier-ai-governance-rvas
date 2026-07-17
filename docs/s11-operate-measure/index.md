# S11 · Operate, Monitor & FinOps

!!! info "Freshness"
    Last reviewed: 2026-07-15

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Service owner</span> <span class="rvas-badge rvas-persona">Cost owner</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer has a repeatable operating review for
Foundry observability, cost, drift, remediation, and exceptions.

They leave with a customer-owned review definition that names:

- the population, cadence, evidence coverage, accountable owners, and decision
  use;
- selected reliability, risk, quality, cost, adoption, business-outcome, and
  control-coverage questions; and
- drift hypotheses, escalation routes, remediation checks, recurrence checks,
  and exception paths.

`labs/s11-operate-measure/` holds blank offline templates and a runbook. It does
**not** connect to live data, create a dashboard, calculate metrics, set
thresholds, store customer data, or implement a change.

### What happens next

S11 creates an operating backlog for later customer-owned work. The
recommendation states whether to adopt, defer, or reject the review definition.
It also names the Azure Monitor, Application Insights, OpenTelemetry, Foundry
observability, alert route, remediation check, review cadence, FinOps/cost owner,
allocation, exception, or S12 portfolio item that needs an owner.

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

## 4. Co-delivery walkthrough

!!! warning "Reference-only operating review"
    This 90-minute session is evidence-first and customer-owned. Do not query
    live data, copy telemetry, identifiers, prompts, responses, costs, or
    business data into the kit. Do not make a monitoring, remediation,
    exception, policy, identity, or production change.

Review the [Technical decisions](technical.md) chapter first: it holds the
observability-stack, cost-attribution, and alerting/drift option menus and
selection criteria this walkthrough decides between.

**Facilitator:** protects the evidence and decision boundary. **Governance
lead:** owns the review decision. **Service owner:** interprets reliability,
risk, quality, and adoption questions. **Cost owner:** interprets spend ownership
and allocation limits. **Evidence owner:** references approved records. Include
specialists only for questions in scope.

| Activity | Time | Customer operation | Facilitator prompts and interpretation |
|---|---:|---|---|
| Set the operating question | 10 min | Select one population, review period, decision, owners, and records location. | **"What decision can this review support?"** **"What is out of scope?"** Stop if the question has no owner or trusted evidence. |
| Map evidence coverage | 15 min | Record evidence references, population and time coverage, exclusions, latency, and attribution limits for each selected question. | **"What can this record not support?"** For Foundry workloads, ask which project, deployment, agent identifier, token-attribution method, evaluator type, and version the evidence covers. Missing coverage is a finding, not zero risk or zero cost. |
| Review quality, latency, and cost trends (optional) | Within the 20 min review-question activity | When in scope, complete the quality-cost-latency addendum using prior and current references. Do not duplicate the quality or cost question. | **"What else could explain the change?"** **"Who owns the spend decision?"** A trend is an operating signal, not sign-off to ship. |
| Define balanced review questions | 20 min | Select only relevant coverage, reliability, risk, quality, cost ownership, adoption, human-review, and business-outcome questions. | **"Who interprets this?"** **"What decision follows?"** Do not turn every category into a required metric or target. |
| Form drift hypotheses and routes | 15 min | Record observable drift hypotheses, other possible explanations, evidence limits, test or observation plan, owner, and escalation trigger. | **"What would challenge this hypothesis?"** **"When does it need escalation?"** A hypothesis is not a confirmed cause. |
| Define remediation and exceptions | 15 min | Record finding owner, target date, validation and recurrence approach, exception expiry, escalation route, and next review. | **"What validates the remedy?"** **"Who accepts an exception?"** Reported completion is not closure until a reviewer checks validation and remaining exceptions. |
| Decide and hand over | 15 min | Approve, defer, or reject the review definition and technical decision. Record limits and next review. | **"Which technical option is selected, deferred, or rejected?"** **"What remains unresolved?"** Adopting a review method does not authorize enforcement or change. |

Use question examples to enrich the review, not to force metrics:

| Category | Example bounded question |
|---|---|
| Control coverage | Which in-scope controls have evidence for the selected period, and which populations are excluded? |
| Reliability | Which incidents, failed runs, latency changes, or dependency failures need owner review? |
| Risk and safety | Which alerts, evaluation regressions, red-team findings, or policy exceptions remain open? |
| Quality | Which release or evaluation signal changed since the prior review, and what alternative explanation exists? |
| Cost ownership | Which workload, agent, or owner is accountable for the spend decision, and what allocation limits remain? |
| Adoption and value | What usage or outcome reference can inform a decision without claiming benefit from adoption alone? |
| Human review | Where did manual review, escalation, or override occur, and who accepted the residual risk? |

### Minimum safe event-to-decision reference

When customer-held runtime evidence informs a review, retain only approved
references to the workload, review period, relevant version or control decision,
outcome category, allocation context where applicable, and reviewer decision.
These categories help the review. They are not a required event schema.

Do not retain raw payloads, personal data, credentials, identifiers, or business
data in this kit.

## 5. Verification & evidence capture

- [ ] The customer selected a population, decision, evidence location,
  accountable owners, review cadence, and next review.
- [ ] Every selected reliability, risk, quality, cost, adoption, and
  business-outcome question records coverage limits and an interpretation owner.
- [ ] Every drift hypothesis records alternatives, evidence limits, a test or
  observation plan, owner, and escalation route.
- [ ] Every finding records owner acceptance, target date, validation,
  recurrence, exception or escalation route, closure reviewer, and status.
- [ ] The operating-review decision and limits are recorded in approved customer
  records.
- [ ] The observability, cost-attribution, and alerting/drift decision is
  recorded or backlogged using
  `templates/technical-decision-record.template.md`.
- [ ] If quality, latency, or cost questions are in scope, the optional
  quality-cost-latency addendum is referenced in customer records.

## 6. Change boundary

S11 makes no live-data query and no platform, dashboard, metric, threshold,
identity, policy, remediation, exception, or production change. Any action uses
the customer's approved engineering and change process.

## 7. Facilitator notes

- **RACI:** Governance lead = decision owner; service owner = service
  interpretation; cost owner = cost ownership and attribution interpretation;
  evidence owner = approved references; specialists = consulted.
- **Blocker path:** no trusted evidence, accountable owner, or approved records
  location means the affected question is blocked. Record the gap, owner, and
  date instead of creating a substitute measure.
- **Official context:** [Microsoft Foundry observability](https://learn.microsoft.com/en-us/azure/foundry/concepts/observability),
  [Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/fundamentals/overview),
  [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview),
  and [Azure Cost Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/overview-cost-management)
  explain the product signals that can inform a future operating review.
- **Hand-off:** the review definition, technical decision record
  (`templates/technical-decision-record.template.md`), and remediation
  references enter the customer governance cadence. They do not amend S9 catalog
  records or certify a control.
