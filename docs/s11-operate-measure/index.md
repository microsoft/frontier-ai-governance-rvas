# S11 · Operate, Monitor & FinOps

!!! info "Freshness"
    Last reviewed: 2026-07-15

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Service owner</span> <span class="rvas-badge rvas-persona">Cost owner</span>

## 1. Outcome & durable artifact

This operating session follows S9 closeout or an explicit S9 deferral. The
customer leaves with a decision-ready, customer-owned operating-review
definition that identifies:

- the bounded population, cadence, evidence coverage, accountable owners, and
  decision use;
- selected questions for reliability, risk, quality, cost ownership, adoption,
  business outcome, and control coverage; and
- drift hypotheses, escalation, remediation validation, recurrence, and
  exception paths.

Durable artifact: `labs/s11-operate-measure/` contains blank offline
templates and a runbook. It does not connect to live data, create a dashboard,
calculate metrics, set thresholds, store customer data, or implement a change.

### Implementation pathway

S11 produces an operating implementation backlog for later customer-owned
work. The recommendation should state whether to adopt, defer, or reject the
operating review definition, and which Azure Monitor/Application Insights/
OpenTelemetry, Foundry observability, alert route, remediation validation,
review cadence, FinOps/cost-owner, allocation, exception, or S12 portfolio item
must be owned next.

## 2. Prerequisites

- S9 closeout or a documented S9 deferral, including current open findings.
- A governance lead able to assign the review decision and cadence.
- Service, evidence, and cost owners who can describe available records and
  coverage limitations for in-scope questions.
- An approved records location for references and decisions.

## 3. Why this session

Operating governance needs more than observations. It needs a repeatable route
from evidence coverage through interpretation, decision, escalation,
remediation validation, recurrence review, and exception accountability. S11
defines that route without claiming a metric, dashboard, or trace proves a
control operates.

Read the [S11 Concepts](concepts.md) before delivery.

## 4. Co-delivery walkthrough

!!! warning "Reference-only operating review"
    This 90-minute session is evidence-first and customer-owned. Do not query
    live data, copy telemetry, identifiers, prompts, responses, costs, or
    business data into the kit. Do not make a monitoring, remediation,
    exception, policy, identity, or production change.

**Facilitator:** preserves the evidence and decision boundary. **Governance
lead:** owns the review decision. **Service owner:** interprets reliability,
risk, quality, and adoption questions. **Cost owner:** interprets cost
ownership and allocation limits. **Evidence owner:** references approved
records. Include specialists only where their question is in scope.

| Activity | Time | Customer operation | Facilitator prompts and interpretation |
|---|---:|---|---|
| Set the operating question | 10 min | Select one bounded population, review period, decision, owners, and records location. | “What decision can this review support?” “What is explicitly out of scope?” Stop if the question has no owner or authoritative evidence. |
| Map evidence coverage | 15 min | Record evidence references, population and time coverage, exclusions, latency, and attribution limits for each selected question. | “What can this record not support?” For Foundry workloads, ask which project, deployment, agent identifier, token-attribution method, evaluator type, and version the evidence covers. Missing coverage is a finding, not zero risk or cost. |
| Review quality, latency, and cost trends (optional) | Within the 20 min review-question activity | Where in scope, complete the quality-cost-latency addendum using bounded prior/current references instead of duplicating the relevant quality or cost question. | “What alternative explains the change?” “Who owns the spend decision?” A trend is an operating signal, not an assurance exit. |
| Define balanced review questions | 20 min | Select only relevant coverage, reliability, risk, quality, cost ownership, adoption, human-review, and business-outcome questions. | “Who interprets this?” “What decision follows?” Do not turn a category into a mandatory metric or target. |
| Form drift hypotheses and routes | 15 min | Record observable drift hypotheses, alternative explanations, evidence limits, test or observation plan, owner, and escalation trigger. | “What would challenge this hypothesis?” “When does it need escalation?” A hypothesis is not a confirmed cause. |
| Define remediation and exceptions | 15 min | Record finding ownership, target date, validation and recurrence approach, exception expiry, escalation route, and next review. | “What validates the remedy?” “Who accepts an exception?” Completion without validation is not closure. |
| Decide and hand over | 15 min | Approve, defer, or reject the review definition and record limitations and next review. | “Is the coverage explicit?” “What remains unresolved?” Adopting a review method does not authorize enforcement or change. |

Use question examples to enrich, not mandate, the review:

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
references to the bounded workload, review period, relevant version or control
decision, outcome category, allocation context where applicable, and reviewer
decision. These categories are a review aid, not a required event schema.
Do not retain raw payloads, personal data, credentials, identifiers, or
business data in this kit.

## 5. Verification & evidence capture

- [ ] The customer has selected a bounded population, decision, evidence
  location, accountable owners, review cadence, and next review.
- [ ] Every selected reliability, risk, quality, cost, adoption, and
  business-outcome question records coverage limitations and an interpretation
  owner.
- [ ] Every drift hypothesis records alternatives, evidence limitations, a
  test or observation plan, owner, and escalation route.
- [ ] Every finding records owner acceptance, target date, validation,
  recurrence, exception or escalation route, closure reviewer, and status.
- [ ] The operating-review decision and limitations are recorded in approved
  customer records.
- [ ] If quality, latency, or cost questions are in scope, the optional
  quality-cost-latency addendum is referenced in customer records.

## 6. Change boundary

S11 makes no live-data query and no platform, dashboard, metric, threshold,
identity, policy, remediation, exception, or production change. Any action
follows the customer's approved engineering and change process.

## 7. Facilitator notes

- **RACI:** Governance lead = decision owner; service owner = responsible for
  service interpretation; cost owner = responsible for cost ownership and
  attribution interpretation; evidence owner = responsible for approved
  references; specialists = consulted.
- **Blocker path:** no authoritative evidence, accountable owner, or approved
  records location means the affected question is blocked. Record the gap,
  owner, and date rather than creating a substitute measure.
- **Hand-off:** the review definition and remediation references enter the
  customer governance cadence. They do not amend S9 catalog records or certify
  a control.
