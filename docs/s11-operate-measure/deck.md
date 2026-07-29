# S11 · Operate & Measure

**Facilitator deck**

Microsoft default: **Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit**.

Concrete decision: **Adopt, defer, reject, route, or block the operating review package for one bounded workload and review period.**

---

## Operating review, not dashboard tour

- A dashboard is a view.
- An operating review is a decision package.
- The package names population, period, coverage, correlation, retention, owners, action route, validation, and recurrence.

Note:
Start by making the workshop practical: the customer is not admiring charts; they are deciding what can be operated from evidence.

---

## Operating review card

- Workload and route.
- Review period and cadence.
- Included population and excluded paths.
- Decision use: operating, incident, product, cost, drift, exception.
- Owners: operations, telemetry, FinOps, product, escalation, evidence.
- Approved records location.

Note:
If the workload or period is not bounded, the review cannot produce an accountable decision.

---

## Signal families

- Usage.
- Quality.
- Safety.
- Latency.
- Errors and dependency health.
- Tool/API behavior.
- Identity and security.
- Cost and capacity.
- Feedback and business outcome.
- Control coverage.

Note:
Select only signals that answer the review question. More metrics are not automatically better governance.

---

## Coverage limits are not passes

- Missing signal.
- Planned signal.
- Sampled signal.
- Unavailable source.
- Excluded path.
- Retention gap.
- Unsupported query.

Note:
An empty chart is not zero incidents. It may be an uninstrumented route.

---

## End-to-end correlation contract

- Gateway request ID.
- Trace context or Application Insights operation ID.
- Agent/run identifier.
- Tool call or dependency identifier.
- Model deployment alias.
- Cost allocation tag or dimension.
- Documented time-window join when no stronger key exists.

Note:
Correlation must say where the join appears, where it breaks, who can query it, and what blind spots remain.

---

## Retention and safe evidence boundary

- Raw telemetry stays in customer systems.
- Repository records safe references and field shapes only.
- Name retention owner, query owner, export owner, and records-management owner.
- Record deletion, legal hold, sensitive-data, and prompt/output handling boundaries.

Note:
The review is allowed to reference evidence, not become a telemetry dump.

---

## Alert route and response ownership

- Signal and population.
- Threshold owner.
- Action group or SOC route.
- Severity and acknowledgment expectation.
- Suppression rule and tuning cadence.
- Validation method and escalation path.

Note:
An alert without owner, suppression review, and validation route is not an operating control.

---

## FinOps and capacity ownership

- Billing source and scope.
- Tag, dimension, project, deployment, or cost-center rule.
- Shared-subscription or committed-capacity assumption.
- Inference, training, evaluation, gateway, telemetry, or support cost boundary.
- Budget/anomaly owner.
- Quota/PTU/capacity owner.

Note:
Cost evidence is actionable only when attribution and ownership are explicit.

---

## Drift hypothesis, not instant root cause

- Changed signal.
- Population and period.
- Possible causes.
- Evidence limits.
- Owner and observation/test plan.
- Action route and next review.

Note:
Production signal variance is a hypothesis until tested. Avoid declaring drift from a chart alone.

---

## Remediation validation and recurrence

- Finding or action.
- Owner and target date.
- Validation reference.
- Reviewer acceptance.
- Remaining risk.
- Exception route if needed.
- Recurrence check and reopen trigger.

Note:
Work complete is not closure. Closure requires validation accepted by a reviewer.

---

## Export and SIEM boundaries

- Source workspace or diagnostic setting.
- Event Hub or stream buffer.
- Collector/function and retry behavior.
- Destination and destination owner.
- Retention/access owner.
- Sensitive-data and legal-hold handling.

Note:
Export design is not proof that every event arrived. Failure modes need owners.

---

## Failure modes and hard stops

- Dashboard-only review.
- Aggregate metric hides excluded path.
- No correlation key.
- Trace does not reach tool/API.
- Sampled telemetry treated as full coverage.
- Alert has no owner.
- Suppression is never reviewed.
- Budget has no action rule.
- Export drops events.
- Remediation closes without validation.

Note:
These become defer, route, or block decisions.

---

## Workshop artifact and handoff

- Artifact: operating review package.
- Decision: adopt, defer, reject, route, or block.
- Handoff: operations, telemetry, FinOps, product, SOC/incident, platform, evaluation baseline, portfolio, release/change.
- Boundary: no live query, dashboard build, alert setup, budget setting, telemetry export, runtime proof, or production approval.

Note:
End with owners, target dates, evidence references, validation, and recurrence.
