# Operating review definition

| Field | Record |
|---|---|
| Bounded population and review period | |
| Decision this review supports | |
| Governance lead / decision owner | |
| Service owner | |
| Cost owner (if cost is in scope) | |
| Evidence owner and approved evidence location | |
| Review cadence and next review | |
| Overall coverage, attribution, and latency limitations | |
| Decision result: approve / defer / reject / route | |

## Review questions

| Category | Bounded question | Evidence reference and coverage limit | Interpretation owner | Decision or escalation route |
|---|---|---|---|---|
| Control coverage | Which in-scope controls have evidence for this period, and what population is excluded? | | | |
| Reliability | Which incidents, failed runs, latency changes, or dependency failures require review? | | | |
| Risk | Which alerts, evaluation regressions, adversarial findings, or exceptions remain open? | | | |
| Quality | Which release, evaluation, or regression signal changed, and what alternative explanation exists? | | | |
| Cost ownership / attribution | Which workload or owner is accountable for spend, and what allocation limits remain? | | | |
| Adoption | What usage reference can inform the decision without proving value by itself? | | | |
| Human review | Where did manual review, escalation, or override occur, and who accepted residual risk? | | | |
| Business outcome | Which approved outcome reference is relevant, and what causal claim is not supported? | | | |

## Drift hypotheses

| Hypothesis / observed change | Alternative explanation | Evidence reference and limitations | Test or observation plan | Accountable owner | Escalation trigger / next review |
|---|---|---|---|---|---|
| | | | | | |
| | | | | | |

## Findings, remediation, and exceptions

| Finding | Accountable owner / acceptance reference | Target date | Validation reference | Recurrence check | Exception expiry or escalation route | Closure reviewer / status |
|---|---|---|---|---|---|---|
| | | | | | | |
| | | | | | | |

## Operating implementation backlog

| Backlog item | Applies / N/A / unknown / later | Recommendation and confidence | Evidence reference or gap | Owner | Customer follow-up route |
|---|---|---|---|---|---|
| Application Insights/OpenTelemetry, Azure Monitor, or Foundry observability coverage (per-run trace, token usage, latency per turn, or production evaluation score where available; record project, sampling, retention, and population) | | | | | Platform / operations process |
| Alert, SOC route, incident review, or escalation path | | | | | Security/SOC process |
| Remediation validation, recurrence check, or exception expiry | | | | | Service-owner or portfolio-governance process |
| Review cadence, operating owner, or support route | | | | | Operations process |
| FinOps cost owner, allocation, quota type, Azure Cost Management, or FinOps Toolkit view (distinguish inference from fine-tuning training cost and record project, deployment, review-period, and shared-cost assumptions) | | | | | Cost-management process |
| Portfolio risk, investment, or policy question | | | | | Portfolio-governance process |

## Required handoff

| Destination | Item reference | Receiving owner | Acceptance evidence | Target date |
|---|---|---|---|---|
| S7 evaluation/baseline | | | | |
| S12 lifecycle | | | | |
| S13 portfolio | | | | |
