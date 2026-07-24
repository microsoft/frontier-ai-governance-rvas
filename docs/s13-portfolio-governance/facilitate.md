# Facilitate the decision

**Decision to produce:** Approve, defer, reject, or route the portfolio re-baseline item.

| Step | Prompt | Output |
|---|---|---|
| 1 | Which record did we inspect for Agent 365 and control-plane records, Azure Cost Management, operating evidence, and the S0 re-baseline? | Platform record named. |
| 2 | What is today's decision: approve, defer, reject, or route? | One decision selected. |
| 3 | What acceptance test proves the decision is ready? | Acceptance test written as an observable condition. |
| 4 | Is there an exception; if yes, who owns it and when is it reviewed? | Exception recorded or marked none. |
| 5 | Who receives the handoff: Executive governance forum or another named owner? | Named handoff owner and next meeting/process. |

Default to **Agent 365 and control-plane records, Azure Cost Management, operating evidence, and the S0 re-baseline**. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

Close with this sentence: **“Portfolio governance owner owns the decision record; Executive governance forum receives the handoff when the acceptance test is met.”**

**Boundary:** Keep the session to decision records and customer-approved evidence locations.
