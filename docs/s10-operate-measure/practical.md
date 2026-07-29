# Practical workshop: operating review package

**Microsoft default:** Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit.

**Customer decision:** Adopt, defer, reject, route, or block the operating review package for one bounded workload and review period. This makes operating evidence usable for review and handoff; it is not a tenant change, live-control validation, deployment, runtime proof, telemetry export, dashboard build, alert configuration, budget setting, or production approval.

## Work the decision

1. **Choose the workload and review period.** Select one pilot, agent, model route, application, API/tool path, or portfolio slice. Name the decision owner, service operations owner, telemetry owner, FinOps owner, product owner, escalation owner, evidence owner, and approved records location.
2. **Inventory signals without exporting telemetry.** Record safe references for Foundry observability, Azure Monitor metrics/alerts, Application Insights traces, Log Analytics queries, Cost Management scope, FinOps review, and any approved customer telemetry path.
3. **Confirm signal coverage.** Identify which usage, quality, safety, latency, error, dependency, tool/API, identity/security, cost, capacity, feedback, outcome, and control-coverage signals are populated for the slice. Empty or planned signals are not proof.
4. **Define the correlation contract.** Name the key or mapping that joins workload, agent/model, API/tool, request/trace, owner, environment, and cost context. Record where propagation breaks and who can query it.
5. **Check retention and evidence handling.** Record retention expectation, query owner, export owner if any, evidence-reference location, sensitive-data boundary, and known blind spots.
6. **Define alert and response route.** Record threshold owner, severity, action group or SOC route, acknowledgment expectation, suppression review, tuning cadence, escalation path, and validation method.
7. **Define FinOps and capacity allocation.** Record billing source, tags/dimensions, budget/anomaly owner, PTU/committed-capacity or quota owner, shared-cost assumption, action rule, and review cadence.
8. **Classify drift hypotheses.** Record changed signal, population, time window, possible causes, evidence limits, owner, test or observation plan, action route, and next review trigger.
9. **Record validation and handoff.** Adopt only when signal coverage, correlation, retention, alert ownership, FinOps allocation, drift handling, validation route, exception path, recurrence check, and receiving handoff are complete. Otherwise defer, reject, route, or block.

## Scenario routes

| Scenario | Route | Practical decision cue |
|---|---|---|
| Foundry hosts or observes the agent/model path | Foundry observability route | Adopt only when Foundry view, environment/workload reference, signal coverage, trace/correlation key, owner, retention, and review cadence are named. |
| Custom app emits the primary telemetry | Custom app telemetry route | Defer until Application Insights/Log Analytics links requests, traces, failures, dependencies, tool/API calls, and user/workload context through a documented correlation key. |
| End-to-end path lacks a join key | Correlation blocker | Block or defer end-to-end conclusions until propagation points, break points, query owner, and validation reference are recorded. |
| Path is uninstrumented or sampled | Coverage-limit route | Record missing/sampled population, owner, target date, and next review. Do not treat absence as zero incidents or healthy behavior. |
| Cost cannot be attributed to an owner | Cost allocation route | Defer until Cost Management scope, tag/dimension, budget owner, FinOps allocation rule, shared-cost assumption, review cadence, and exception path are recorded. |
| Quota or capacity is saturated | Capacity action route | Route to quota/PTU/committed-capacity owner with action rule, fallback owner, target date, and validation reference. |
| Alert or threshold is missing or unowned | Alert gap route | Create backlog with signal, threshold owner, severity, action group/SOC route, suppression review, target date, and evidence location. |
| Metrics suggest behavior or quality drift | Drift hypothesis route | Route to evaluation baseline owner, model owner, product owner, or incident/problem review with hypothesis, signal, time window, owner, target date, and next review trigger. |
| Export/SIEM path is required | Export route | Record source, buffer, collector/function, destination owner, failure/retry behavior, retention, access owner, and sensitive-data boundary before relying on it. |
| Remediation is marked complete | Validation route | Closure requires validation reference, reviewer, remaining risk, recurrence check, and next review trigger. |

## Decision record

Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Operating review package | Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit | Service operations owner | Customer-approved record reference only | Review card, signal coverage, correlation, retention, alert route, FinOps rule, drift hypothesis, validation route, exception status, backlog, recurrence check, and handoff are complete | Customer date | Service operations, product, telemetry, SOC, and FinOps owners |

Use this decision tree: if the operating package fits and checks are complete, adopt the handoff; if records, signals, owners, or thresholds are missing, defer with an acceptance test; if the path cannot support the scoped review, reject or route to an accountable owner; if no evidence location, correlation, retention, or escalation owner exists, block.

For an exception, record: reason, affected operating signal, unsupported or unverified measurement path, equivalent customer-owned control if one exists, owner, evidence location reference, acceptance test, target date, review impact, recurrence check, and next review trigger.

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Review card | workload, route, population, review period, excluded paths, owners, evidence location, and cadence are recorded | Service operations owner |
| Signal coverage | usage, quality, safety, latency, error, dependency, tool/API, identity/security, cost, capacity, feedback, outcome, and control signals are populated or named as gaps with scope, owner, and review date | Telemetry owner |
| Correlation contract | join key or mapping between workload, agent/model, API/tool, request/trace, owner, environment, and cost is documented with known blind spots | Platform monitoring owner |
| Retention | telemetry, query outputs, alert records, cost reviews, evidence notes, export records, and investigation records have retention or records-management owners | Records owner |
| Alert response | alert, SLO, budget, quality, drift, and escalation thresholds have named owners, action route, suppression review, validation method, and tuning cadence | Service operations owner |
| FinOps rule | cost allocation tag/dimension, budget owner, shared-cost assumption, anomaly route, capacity owner, and review cadence are documented or deferred with target date | FinOps owner |
| Drift hypothesis | signal, population, possible causes, evidence limits, owner, test/observation plan, action route, and next review trigger are recorded | Product or model owner |
| Remediation closure | validation reference, reviewer, remaining risk, recurrence check, exception route, and next review trigger are recorded | Receiving owner |
| Workshop safety | the activity records decisions only, copies no customer telemetry into the repository, changes no tenant policy, creates no dashboard/alert/budget/export, and makes no deployment, live-control-validation, runtime-proof, or production-approval claim | Facilitator |

**Boundary:** Keep customer data and evidence in customer-approved systems; store references only. S10 makes operating evidence usable for customer review and handoff without claiming production approval or live control validation.
