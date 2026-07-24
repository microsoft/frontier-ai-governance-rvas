# Practical workshop: in-process governance exception path

**Microsoft default:** Agent Governance Toolkit only when gateway controls cannot make the needed in-process decision.

**Customer decision:** Approve, defer, reject, or route the in-process governance exception.

## Work the decision

1. Select one bounded pilot or backlog item and name the customer decision owner.
2. Inspect the gateway control decision, the reason gateway controls cannot decide in process, and the Agent Governance Toolkit policy point proposed for the agent runtime.
3. Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | Agent Governance Toolkit only when gateway controls cannot make the needed in-process decision | Runtime governance owner | Customer-approved record | Decision, acceptance test, exception status, and handoff are complete | Customer date | Application engineering |

4. Use this decision tree: if the Microsoft path fits, approve it; if records are missing, defer with an acceptance test; if the path cannot meet the use case, reject or route to an exception owner.
5. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
