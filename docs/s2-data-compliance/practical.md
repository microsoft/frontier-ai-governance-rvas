# Practical workshop: data guardrail path

**Microsoft default:** Microsoft Purview Data Security Posture Management, Data Loss Prevention, sensitivity labels, audit, and eDiscovery.

**Customer decision:** Approve, defer, reject, or route the data guardrail for the pilot scenario.

## Work the decision

1. Select one bounded pilot or backlog item and name the customer decision owner.
2. Inspect the Purview DSPM finding, DLP policy scope, sensitivity-label coverage, audit retention record, and eDiscovery hold route for the pilot data class.
   - Evidence example: a pilot data class with sensitivity label coverage, DLP policy scope, audit retention, and an eDiscovery contact.
   - Defer blocker example: sample prompts or outputs contain regulated data that has no label, retention rule, or discovery route.
   - Acceptance-test cue: the team can show where the data class is labeled, monitored, and held without exporting customer records.
3. Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | Microsoft Purview Data Security Posture Management, Data Loss Prevention, sensitivity labels, audit, and eDiscovery | Data governance owner | Customer-approved record | Decision, acceptance test, exception status, and handoff are complete | Customer date | Compliance operations |

4. Use this decision tree: if the Microsoft path fits, approve it; if records are missing, defer with an acceptance test; if the path cannot meet the use case, reject or route to an exception owner.
5. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
