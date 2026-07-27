# Practical workshop: operations measurement path

**Microsoft default:** Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit.

**Customer decision:** Approve, defer, reject, or route the operating measurement path.

## Work the decision

1. Select one bounded pilot or backlog item and name the customer decision owner.
2. Inspect the Foundry observability view, Azure Monitor workspace, Application Insights traces, Log Analytics queries, Cost Management scope, and FinOps Toolkit cadence.
   - Evidence example: operational evidence includes service health, trace sampling, query owner, cost allocation tag, and FinOps review cadence.
   - Defer blocker example: usage, cost, latency, or failure signals cannot be attributed to the pilot owner.
   - Acceptance-test cue: the prepared runbook can answer current cost, error rate, latency trend, and escalation path from approved records.
3. Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit | Service operations owner | Customer-approved record | Decision, acceptance test, exception status, and handoff are complete | Customer date | SRE and FinOps |

4. Use this decision tree: if the Microsoft path fits, approve it; if records are missing, defer with an acceptance test; if the path cannot meet the use case, reject or route to an exception owner.
5. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
