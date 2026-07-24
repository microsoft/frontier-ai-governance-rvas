# S12 · LLMOps

**Facilitator deck**

Microsoft default: **Microsoft Learn LLMOps inner/outer-loop lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection**.

Concrete decision: **Approve, defer, reject, or route the next LLMOps lifecycle gate.**

---

## Start with the Microsoft path

- Default control path: Microsoft Learn LLMOps inner/outer-loop lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection.
- Customer inspects: Inspect the Microsoft Learn LLMOps lifecycle record: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection.
- Decision owner: ML platform owner.

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
- Handoff: MLOps release team

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
- Decision owner: ML platform owner.
- Handoff: MLOps release team.
- Boundary: customer data stays in approved systems; production changes use customer change approval.

Note:
End with the decision record and the named handoff.
