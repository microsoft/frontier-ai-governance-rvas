# Facilitate the decision

**Decision to produce:** Approve, defer, reject, or route the first AI governance backlog item.

| Step | Prompt | Output |
|---|---|---|
| 1 | Which record did we inspect for Cloud Adoption Framework for AI, Well-Architected Framework for AI, and AI Center of Excellence guidance? | Platform record named. |
| 2 | What is today's decision: approve, defer, reject, or route? | One decision selected. |
| 3 | What acceptance test proves the decision is ready? | Acceptance test written as an observable condition. |
| 4 | Is there an exception; if yes, who owns it and when is it reviewed? | Exception recorded or marked none. |
| 5 | Who receives the handoff: Architecture review board or another named owner? | Named handoff owner and next meeting/process. |

Default to **Cloud Adoption Framework for AI, Well-Architected Framework for AI, and AI Center of Excellence guidance**. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

Close with this sentence: **“Governance lead owns the decision record; Architecture review board receives the handoff when the acceptance test is met.”**

**Boundary:** Keep the session to decision records and customer-approved evidence locations.
