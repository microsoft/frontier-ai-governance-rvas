# S12 · LLMOps

**Facilitator deck**

Microsoft default: **Microsoft Learn LLMOps inner/outer-loop lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection**.

Concrete decision: **Approve, defer, reject, or route the next LLMOps lifecycle gate.**

Model lifecycle focus: **make the customer decide how model versions are
approved, tested, rolled out, switched, rolled back, and retired.**

---

## Start with the Microsoft path

- Default control path: Microsoft Learn LLMOps inner/outer-loop lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection.
- Customer inspects: Inspect the Microsoft Learn LLMOps lifecycle record: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection.
- Decision owner: ML platform owner.

Note:
Open with the default platform path and the decision the customer must make.

---

## Make model lifecycle explicit

- Name the approved baseline model or deployment alias.
- Name candidate, fallback, deprecated, and retired model states.
- Decide who can approve tests, promote versions, switch traffic, and roll back.
- Record the evidence needed for automated regression tests, canary rollout,
  alias switching, fallback routing, and retirement.

Note:
The point is not to choose a model in the room. The point is to make the
lifecycle and authority clear enough that future model updates can be automated.

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
- Model lifecycle state and switch authority
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
