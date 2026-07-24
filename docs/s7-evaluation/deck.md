# S7 · Evaluation

**Facilitator deck**

Microsoft default: **Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing where applicable**.

Concrete decision: **Approve, defer, reject, or route the evaluation gate.**

---

## Start with the Microsoft path

- Default control path: Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing where applicable.
- Customer inspects: Inspect the Foundry evaluation plan, agent evaluator selection, cloud evaluation record, CI/CD gate, and Azure Load Testing need.
- Decision owner: Evaluation owner.

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
- Handoff: Release engineering

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
- Decision owner: Evaluation owner.
- Handoff: Release engineering.
- Boundary: customer data stays in approved systems; production changes use customer change approval.

Note:
End with the decision record and the named handoff.
