# S6 · Security Runtime

**Facilitator deck**

Microsoft default: **Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Sentinel, and Application Insights**.

Concrete decision: **Approve, defer, reject, or route the runtime security control path.**

---

## Start with the Microsoft path

- Default control path: Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Sentinel, and Application Insights.
- Customer inspects: Inspect the gateway policy route, Prompt Shields coverage, Defender for Cloud AI posture finding, Defender XDR/Sentinel routing, and Application Insights telemetry plan.
- Decision owner: Security operations owner.

Note:
Open with the default platform path and the decision the customer must make.

---

## Decide with platform records

- Approve when the Microsoft path fits and the acceptance test is clear.
- Defer when a required record or owner is missing.
- Reject when the use case cannot meet the control path.
- Route when an exception owner must accept an equivalent control.

Note:
Keep the discussion on records, owners, and acceptance tests.

---

## Acceptance test

The decision is ready when the record names:

- Microsoft control path
- Owner
- Evidence location
- Accepted-when condition
- Target date
- Handoff: SOC

Note:
The acceptance test should be observable by the team that receives the handoff.

---

## Exception, if any

An exception needs:

- Reason and equivalent control
- Owner and evidence location
- Acceptance test and target date
- Review trigger

Note:
Use an exception for a documented equivalent control with an owner and review trigger.

---

## Close the session

- Decision: approve, defer, reject, or route.
- Decision owner: Security operations owner.
- Handoff: SOC.
- Boundary: customer data stays in approved systems; production changes use customer change approval.

Note:
End with the decision record and the named handoff.
