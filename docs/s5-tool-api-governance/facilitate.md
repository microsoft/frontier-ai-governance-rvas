# Facilitate the decision

**Decision to produce:** Approve, defer, reject, or route the tool/API admission decision.

| Step | Prompt | Output |
|---|---|---|
| 1 | Which record did we inspect for Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls? | Platform record named. |
| 2 | What is today's decision: approve, defer, reject, or route? | One decision selected. |
| 3 | What acceptance test proves the decision is ready? | Acceptance test written as an observable condition. |
| 4 | Is there an exception; if yes, who owns it and when is it reviewed? | Exception recorded or marked none. |
| 5 | Who receives the handoff: API platform team or another named owner? | Named handoff owner and next meeting/process. |

Default to **Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls**. For an exception, record: reason, equivalent control, owner, evidence location, acceptance test, target date, and review trigger.

Close with this sentence: **“API governance owner owns the decision record; API platform team receives the handoff when the acceptance test is met.”**

**Boundary:** Keep the session to decision records and customer-approved evidence locations.
