# S10 · Operating Evidence & FinOps

**Facilitator deck**

Microsoft default: **Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit**.

Concrete decision: **Inspect one bounded workload and review period, then adopt, defer, reject, route, or block the operating action.**

---

## Operating review, not dashboard tour

- A dashboard is a view.
- Inspect population, period, coverage, correlation, retention, owners, action route, validation, and recurrence.

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

## Open the operating sources

- Application Insights: requests, dependencies, failures, sampling, operation ID.
- Log Analytics: run approved KQL placeholders for latency, errors, model/tool
  route, token/cost proxy, dependency failures, and safety/security signals.
- Azure Monitor: alert rules, action groups, workbooks, suppression, owners.
- Cost Management: exports, budgets, cost analysis, tags/dimensions, anomalies.
- Quota/capacity: quota, PTU/commitment, throttling, fallback, owner.
- Defender/Sentinel: security signal, incident/playbook route, SOC owner.

Note:
Record query references and aggregate states. Do not paste raw telemetry,
endpoints, tenant IDs, exports, or customer content into the lab record.

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

## Expected operating states

- Normal.
- Investigate.
- Missing telemetry.
- Sampled or aggregate-only.
- Delayed export or ingestion.
- Unsupported route, connector, region, SKU, or security handoff.
- Blocked by owner, access, records location, or evidence handling.

Note:
Every non-normal state needs owner, next action, acceptance check, and recheck
condition.

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

## Decide and hand over

- Complete: operating action, validation, and recurrence check.
- Decision: adopt, defer, reject, route, or block.
- Handoff: operations, telemetry, FinOps, product, SOC/incident, platform, evaluation baseline, portfolio, release/change.
- Boundary: no live query, dashboard build, alert setup, budget setting, telemetry export, runtime proof, or production approval.

Note:
End with the decision, receiving owner, next operating action, accepted-when
condition, and customer-owned evidence reference.
