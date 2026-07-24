# Practical workshop: evaluation gate

**Microsoft default:** Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing where applicable.

**Customer decision:** Approve, defer, reject, or route the evaluation gate.

## Work the decision

1. Select one bounded pilot or backlog item and name the customer decision owner.
2. Inspect the Foundry evaluation plan, agent evaluator selection, cloud evaluation record, CI/CD gate, and Azure Load Testing need.
3. Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing where applicable | Evaluation owner | Customer-approved record | Decision, acceptance test, exception status, and handoff are complete | Customer date | Release engineering |

4. Use this decision tree: if the Microsoft path fits, approve it; if records are missing, defer with an acceptance test; if the path cannot meet the use case, reject or route to an exception owner.
5. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
