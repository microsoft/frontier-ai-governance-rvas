# Technical decision record

[Technical-decisions guidance](../../../docs/s11-operate-measure/technical.md)
gives the observability-stack, cost-attribution, and alerting/drift option
menus and selection criteria.

Copy this blank record into the customer's approved records system. It captures a
customer-owned operating and measurement decision, the options considered, and
the adoption stage. It does not query live telemetry, create a dashboard, set a
threshold, change production, or approve spend.

## Decision

| Field | Record |
|---|---|
| Decision under review | ‹e.g. observability stack / cost attribution / alerting and drift response› |
| Bounded workload, population, and review period | |
| Decision owner and date | |
| Approved records location | |

## Options considered

| Option | Fit for this scope | Key trade-off / limitation | Chosen? (yes / no / deferred) |
|---|---|---|---|
| Observability: OpenTelemetry + Application Insights / Azure Monitor | | | |
| Observability: Foundry observability | | | |
| Observability: both, with sampling and retention policy | | | |
| Cost attribution: Azure Cost Management by subscription/resource | | | |
| Cost attribution: Foundry project/model attribution | | | |
| Cost attribution: tagging + PTU/committed-capacity allocation | | | |
| Alerting: operations-owned route | | | |
| Alerting/drift: governance review route or approved-baseline drift hypothesis | | | |

## Chosen option and rationale

| Field | Record |
|---|---|
| Selected option(s) | |
| Rationale (criteria that decided it) | |
| Alternatives rejected or deferred and why | |
| Named owner(s) for observability, cost, alerting, and drift response | |
| Dependencies (instrumentation, retention, allocation, approved baseline, portfolio governance, customer change process) | |
| Verified-status caveat (availability / licensing / quota / pricing checked on) | |

## Adoption progress

| Field | Record |
|---|---|
| Adoption stage (decided / backlogged / in adoption) | |
| Governance maturity objective supported | |
| Next step and owner (customer operating/change process) | |
| Review date and portfolio-review reference, if any | |
