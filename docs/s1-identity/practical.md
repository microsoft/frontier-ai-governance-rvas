# Practical workshop: agent identity pattern

**Microsoft default:** Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available.

**Customer decision:** Approve, defer, reject, or route the identity pattern for the pilot agent.

## Work the decision

1. Select one bounded pilot or backlog item and name the customer decision owner.
2. Inspect the proposed agent identity record, workload identity inventory, Conditional Access policy scope, Azure RBAC assignments, and Agent 365 record where available.
3. Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available | Identity platform owner | Customer-approved record | Decision, acceptance test, exception status, and handoff are complete | Customer date | Identity operations |

4. Use this decision tree: if the Microsoft path fits, approve it; if records are missing, defer with an acceptance test; if the path cannot meet the use case, reject or route to an exception owner.
5. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
