# S5 · Tool & API Governance

**Facilitator deck**

Microsoft default: **Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls**.

Concrete decision: **Approve, defer, reject, or route the tool/API admission decision.**

---

## Start with the Microsoft path

- Default control path: Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls.
- Customer inspects: Inspect the API Center entry, API Management policy route, Entra/JWT contract, connector approval record, and MCP publication criteria.
- Decision owner: API governance owner.

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
- Handoff: API platform team

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
- Decision owner: API governance owner.
- Handoff: API platform team.
- Boundary: customer data stays in approved systems; production changes use customer change approval.

Note:
End with the decision record and the named handoff.
