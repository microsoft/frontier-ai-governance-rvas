# Practical workshop: AI red-team route

**Microsoft default:** AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Defender, and SOC remediation routes.

**Customer decision:** Approve, defer, reject, or route the AI red-team plan.

## Work the decision

1. Select one bounded pilot or backlog item and name the customer decision owner.
2. Inspect the AI Red Teaming Agent or PyRIT test plan, Content Safety checks, Defender signal route, and SOC remediation queue.
   - Evidence example: the plan names abuse cases, test harness, Content Safety checks, signal destination, severity owner, and retest date.
   - Defer blocker example: high-risk prompts have no remediation owner, no retest trigger, or no SOC intake path.
   - Acceptance-test cue: prepared findings show exploit class, expected control response, severity, remediation queue, and closure evidence.
3. Fill this row in the customer-approved records system:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Pilot decision | AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Defender, and SOC remediation routes | AI red-team lead | Customer-approved record | Decision, acceptance test, exception status, and handoff are complete | Customer date | Security remediation owner |

4. Use this decision tree: if the Microsoft path fits, approve it; if records are missing, defer with an acceptance test; if the path cannot meet the use case, reject or route to an exception owner.
5. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

**Boundary:** Keep customer data in customer-approved systems; production changes require customer change approval.
