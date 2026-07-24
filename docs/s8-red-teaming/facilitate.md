# Facilitate the decision

**Decision to produce:** Approve, defer, reject, or route the AI red-team plan.

| Step | Prompt | Output |
|---|---|---|
| 1 | Which record did we inspect for AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Defender, and SOC remediation routes? | Platform record named. |
| 2 | What is today's decision: approve, defer, reject, or route? | One decision selected. |
| 3 | What acceptance test proves the decision is ready? | Acceptance test written as an observable condition. |
| 4 | Is there an exception; if yes, who owns it and when is it reviewed? | Exception recorded or marked none. |
| 5 | Who receives the handoff: Security remediation owner or another named owner? | Named handoff owner and next meeting/process. |

Default to **AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Defender, and SOC remediation routes**. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

Close with this sentence: **“AI red-team lead owns the decision record; Security remediation owner receives the handoff when the acceptance test is met.”**

**Boundary:** Keep the session to decision records and customer-approved evidence locations.
