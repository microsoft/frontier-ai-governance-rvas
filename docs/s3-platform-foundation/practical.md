# Practical workshop: platform foundation path

**Microsoft default:** Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway or Citadel-aligned gateway, private networking, and Azure Monitor.

**Customer decision:** Approve, defer, reject, or route the platform foundation for the pilot.

## Work the decision

1. Select one bounded pilot or backlog item and name the customer decision owner.
2. Inspect the Azure landing zone subscription plan, Foundry project boundary, gateway pattern, private networking requirement, and Azure Monitor workspace route.
   - Evidence example: subscription, resource group, Foundry project, gateway, network boundary, and monitoring workspace are named for the pilot.
   - Defer blocker example: the pilot cannot identify its ingress route, private endpoint requirement, or log destination.
   - Acceptance-test cue: platform handoff includes environment boundary, gateway path, telemetry route, and change owner before production approval is requested.
3. Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway or Citadel-aligned gateway, private networking, and Azure Monitor | Cloud platform owner | Customer-approved record | Decision, acceptance test, exception status, and handoff are complete | Customer date | Platform engineering |

4. Use this decision tree: if the Microsoft path fits, approve it; if records are missing, defer with an acceptance test; if the path cannot meet the use case, reject or route to an exception owner.
5. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
