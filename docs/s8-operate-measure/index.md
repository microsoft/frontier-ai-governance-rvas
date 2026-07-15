# S8 · Operate & Measure

!!! info "Freshness"
    Last reviewed: 2026-07-15

<span class="rvas-badge rvas-persona">Governance lead</span> <span class="rvas-badge rvas-persona">Platform owner</span> <span class="rvas-badge rvas-persona">Service owner</span>

## 1. Outcome & durable artifact

This optional extension follows S6. The customer leaves with a decision-ready,
customer-owned operating-review definition that identifies:

- the review scope, accountable owners, cadence, and evidence location;
- the questions to review across control coverage, reliability, safety and
  risk, quality, cost, adoption, human review, business outcomes, and
  remediation; and
- the escalation, exception, validation, and next-review path for a finding.

Durable artifact: `labs/s8-operate-measure/` - blank, offline templates and a
runbook. The kit does not collect telemetry, create a dashboard, calculate a
metric, set a threshold, or prove that a control is operating.

## 2. Prerequisites

- S6 closeout or a documented S6 deferral, including the current residual-gap
  backlog.
- A governance lead who can assign the operating-review decision and cadence.
- A platform or service owner who can describe the available evidence sources
  and their coverage limits.
- A customer-approved records-system location for references and decisions.

## 3. Why this session

An inventory and a closeout backlog become operational only when the customer
can revisit them with clear questions, evidence limits, owners, and decisions.
S8 establishes that review method without claiming that a dashboard, trace, or
metric establishes a control by itself.

Read the [S8 Concepts](concepts.md) before delivery.

## 4. Co-delivery walkthrough

!!! warning "Reference-only operating review"
    Do not copy telemetry, identifiers, prompts, responses, costs, or customer
    business data into the kit. A proposed metric, empty template, or
    illustrative threshold is not customer evidence.

**Timebox:** 90 minutes. **Facilitator:** preserves the evidence and
decision boundary. **Governance lead:** owns the review decision. **Platform or
service owner:** explains evidence coverage and limitation. **Evidence owner:**
references approved records. Include security, assurance, finance, privacy, or
business specialists only where their question is in scope.

| Activity | Time | Customer operation | Facilitator prompts and interpretation |
|---|---:|---|---|
| Set the operating question | 15 min | Select one bounded agent population, review period, and decision to support. | “What decision can this review make?” “What must remain a separate customer process?” |
| Map evidence coverage | 15 min | Identify the approved records or telemetry references available for each selected question and record known exclusions. | “Which population, time period, and event types does this source actually cover?” Missing coverage is a finding, not zero risk. |
| Define review questions | 25 min | Use the blank review template to select relevant questions: coverage, reliability, safety/risk, quality, cost, adoption, human review, business outcome, and remediation. | “Who owns interpretation?” “What action can follow?” Do not turn a generic category into a required metric. |
| Define escalation and closure | 20 min | Record owners, review cadence, exception route, validation reference, recurrence check, and next review for each open finding. | “Who accepts the risk?” “What proves the remediation was reviewed?” A closed ticket without validation is not closure. |
| Decide and hand over | 15 min | Approve, defer, or reject the operating-review definition and record the next review date. | “Is the scope explicit?” “What is still unknown?” A decision to adopt a review method does not approve enforcement or a production change. |

### Minimum safe event-to-decision reference

When a customer uses runtime evidence to inform a review, retain only
customer-controlled references to the categories needed for interpretation:

- the agent or workload scope and initiating context;
- a run or request correlation reference;
- applicable tool and model/version references;
- the relevant policy or control decision;
- the observed outcome category; and
- the reviewer and decision reference.

These categories are a review aid, not a mandatory event schema. Do not retain
raw payloads, personal data, credentials, or customer identifiers in this kit.

## 5. Verification & evidence capture

- [ ] The customer has selected a bounded population, operating question,
  evidence location, accountable owner, and next review date.
- [ ] Every selected review question records a coverage statement and a
  decision or escalation owner.
- [ ] Open findings identify an owner, target date, validation reference,
  recurrence check, and exception or escalation route where applicable.
- [ ] The customer records the operating-review decision and its limitations
  in the approved records system.

## 6. Change boundary

S8 makes no platform, dashboard, metric, threshold, identity, policy, or
production change. Any monitoring implementation, remediation, exception, or
enforcement change follows the customer's approved engineering and change
process.

## 7. Facilitator notes

- **RACI:** Governance lead = decision owner; platform or service owner = R for
  evidence-coverage interpretation; evidence owner = R for approved-record
  references; specialist reviewers = C.
- **Blocker path:** no authoritative evidence source, review owner, or
  records-system location means the affected question is blocked. Record the
  gap, owner, and date rather than creating a substitute measure.
- **Hand-off:** the approved review definition and remediation references become
  inputs to the customer's normal governance cadence; they do not amend S6
  reconciliation or certify a control.
