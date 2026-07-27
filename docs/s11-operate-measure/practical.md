# Practical workshop: operating measurement review path

**Microsoft default:** Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit.

**Customer decision:** Approve, defer, reject, route, or block the operating measurement review for one bounded workload. This makes operating evidence usable for review and handoff; it is not a tenant change, live-control validation, deployment, runtime proof, or production approval.

## Work the decision

1. **Choose the operating review slice.** Select one pilot, agent, model route, application, API/tool path, or portfolio slice. Name the decision owner, service operations owner, telemetry owner, FinOps owner, escalation owner, evidence owner, and approved records location.
2. **Inventory signals without exporting telemetry.** Record safe references for Foundry observability, Azure Monitor metrics/alerts, Application Insights traces, Log Analytics queries, Cost Management scope, and FinOps review cadence.
3. **Confirm signal population and correlation.** Identify which usage, quality, latency, error, safety, cost, and capacity signals are populated for the slice. Name the correlation key or record that joins product, tenant, workload, agent, API, model, and cost context. Empty or planned signals are not proof.
4. **Check retention and ownership.** Record retention expectation, query owner, threshold owner, escalation path, evidence-reference location, and known blind spots. If a threshold exists but no owner can tune or respond, defer.
5. **Classify operating gaps.** Route the review through the best scenario below: Foundry observability, custom app telemetry, cost allocation, alert gap, or drift hypothesis.
6. **Record operating review outcome.** Approve only when signal population, correlation key, retention, threshold owner, FinOps rule, escalation path, drift/review trigger, acceptance checks, and receiving handoff are complete. Otherwise defer, reject, route, or block.

## Scenario routes

| Scenario | Route | Practical decision cue |
|---|---|---|
| Foundry hosts or observes the agent/model path | Foundry observability | Approve only when Foundry view, environment/workload reference, signal population, trace/correlation key, owner, retention, and review cadence are named. |
| Custom app emits the primary telemetry | Custom app telemetry | Defer until Application Insights/Log Analytics links requests, traces, failures, dependencies, tool/API calls, and user/workload context through a documented correlation key. |
| Cost cannot be attributed to an owner | Cost allocation | Defer until Cost Management scope, tag/dimension, budget owner, FinOps allocation rule, review cadence, and exception path are recorded. |
| Alert or threshold is missing or unowned | Alert gap | Create backlog with signal, threshold owner, severity, escalation path, target date, and evidence location. Do not claim operational readiness from dashboards alone. |
| Metrics suggest behavior or quality drift | Drift hypothesis | Route to evaluation, model owner, product owner, or incident/problem review with hypothesis, signal, time window, owner, target date, and next review trigger. |
| Signals are planned, empty, sampled, or unavailable | Signal population blocker | Block or defer until the scope, time window, source, population status, limitations, and reviewer are recorded. |

## Decision record

Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot operating measurement review | Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit | Service operations owner | Customer-approved record reference only | Signal population, correlation key, retention, threshold owner, FinOps rule, escalation path, drift/review trigger, exception status, backlog, and handoff are complete | Customer date | Service operations, product owner, and FinOps |

Use this decision tree: if the measurement path fits and operating checks are complete, approve the handoff; if records, signals, owners, or thresholds are missing, defer with an acceptance test; if the path cannot support the scoped review, reject or route to an accountable owner; if no evidence location, correlation, or escalation owner exists, block.

For an exception, record: reason, affected operating signal, unsupported or unverified measurement path, equivalent customer-owned control if one exists, owner, evidence location reference, acceptance test, target date, review impact, and next review trigger.

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Signal population | usage, quality, latency, error, safety, cost, and capacity signals are populated or named as gaps with scope, owner, and review date | Telemetry owner |
| Correlation key | the join key or mapping between workload, agent/model, API/tool, request/trace, owner, and cost is documented with known blind spots | Platform monitoring |
| Retention | telemetry, query outputs, alert records, cost reviews, evidence notes, and investigation records have retention or records-management owners | Records owner |
| Threshold owner | alert, SLO, budget, quality, drift, and escalation thresholds have named owners and tuning cadence | Service operations |
| FinOps rule | cost allocation tag/dimension, budget owner, anomaly route, and review cadence are documented or deferred with target date | FinOps owner |
| Escalation path | severity, owner, review forum, incident/problem route, and product or evaluation handoff are named | Operations governance |
| Workshop safety | the activity records decisions only, copies no customer telemetry into the repository, changes no tenant policy, and makes no deployment, live-control-validation, runtime-proof, or production-approval claim | Workshop facilitator |

**Boundary:** Keep customer data and evidence in customer-approved systems; store references only. S11 makes operating evidence usable for customer review and handoff without claiming production approval or live control validation.
