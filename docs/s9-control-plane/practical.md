# Practical workshop: control-plane record

**Microsoft default:** Microsoft Agent 365, Microsoft Entra Agent ID, Azure API Center, and platform telemetry.

**Customer decision:** Approve, defer, reject, or route the control-plane record.

## Work the decision

1. Select one bounded pilot or backlog item and name the customer decision owner.
2. Inspect the Agent 365 record where available, Entra Agent ID or workload identity record, API Center dependencies, and platform telemetry fields.
3. Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | Microsoft Agent 365, Microsoft Entra Agent ID, Azure API Center, and platform telemetry | Control-plane owner | Customer-approved record | Decision, acceptance test, exception status, and handoff are complete | Customer date | Operations governance |

4. Use this decision tree: if the Microsoft path fits, approve it; if records are missing, defer with an acceptance test; if the path cannot meet the use case, reject or route to an exception owner.
5. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
