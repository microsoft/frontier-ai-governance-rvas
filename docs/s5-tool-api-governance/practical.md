# Practical workshop: tool and API admission path

**Microsoft default:** Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls.

**Customer decision:** Approve, defer, reject, or route the tool/API admission decision.

## Work the decision

1. Select one bounded pilot or backlog item and name the customer decision owner.
2. Inspect the API Center entry, API Management policy route, Entra/JWT contract, connector approval record, and MCP publication criteria.
3. Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls | API governance owner | Customer-approved record | Decision, acceptance test, exception status, and handoff are complete | Customer date | API platform team |

4. Use this decision tree: if the Microsoft path fits, approve it; if records are missing, defer with an acceptance test; if the path cannot meet the use case, reject or route to an exception owner.
5. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
