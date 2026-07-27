# Practical workshop: LLMOps lifecycle gate

**Microsoft default:** Microsoft Learn LLMOps inner/outer-loop lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection.

**Customer decision:** Approve, defer, reject, or route the next LLMOps lifecycle gate.

## Work the decision

1. Select one bounded pilot or backlog item and name the customer decision owner.
2. Inspect the Microsoft Learn LLMOps lifecycle record: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection.
3. Identify the model lifecycle state for the workload: approved baseline,
   candidate versions, fallback model, deprecated versions, retirement
   condition, switch authority, and rollback trigger.
4. Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot model lifecycle decision | Microsoft Learn LLMOps inner/outer-loop lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection | ML platform owner | Customer-approved record | Model baseline, candidate/fallback/retirement states, acceptance test, switch authority, exception status, and handoff are complete | Customer date | MLOps release team |

5. Use this decision tree: if the Microsoft path fits, approve it; if records are missing, defer with an acceptance test; if the path cannot meet the use case, reject or route to an exception owner.
6. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

Future automation prompt: **What evidence must pass before the team can
automate testing, canary rollout, alias switching, fallback routing, or
retirement of a model version?**

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
