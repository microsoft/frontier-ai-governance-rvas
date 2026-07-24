# S1 · Identity & Access

**Facilitator deck**

Microsoft default: **Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available**.

Concrete decision: **Approve, defer, reject, or route the identity pattern for the pilot agent.**

---

## Start with the Microsoft path

- Default control path: Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available.
- Customer inspects: Inspect the proposed agent identity record, workload identity inventory, Conditional Access policy scope, Azure RBAC assignments, and Agent 365 record where available.
- Decision owner: Identity platform owner.

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
- Handoff: Identity operations

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
- Decision owner: Identity platform owner.
- Handoff: Identity operations.
- Boundary: customer data stays in approved systems; production changes use customer change approval.

Note:
End with the decision record and the named handoff.
