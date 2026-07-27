# S10 · Conditional In-Process Tool-Call Governance

**Facilitator deck**

Microsoft default: **Gateway controls first; in-process tool-call policy only when a real pre-tool delegated-authority decision exists that gateway controls cannot make**.

Concrete decision: **Gateway-only, in-process, both, or not applicable; then approve, defer, reject, or route the resulting backlog item.**

---

## Start with applicability

- Default control path: gateway-only unless an in-process decision is truly needed.
- Customer inspects: the gateway control decision, the local tool-call boundary, delegated authority, and why gateway controls cannot decide before the tool runs.
- Decision owner: Runtime governance owner.

Note:
Open with the applicability question. AGT is an implementation candidate, not the identity of the session.

---

## Skip when not applicable

- If no real in-process boundary exists, record **not applicable**.
- Continue with S11/S13 or the customer backlog.
- Do not open an AGT adoption task just to complete S10.

Note:
The hard skip path is a valid outcome. It protects the customer from unnecessary implementation work.

---

## Decide with platform records

- Approve when gateway-only, in-process, or both fits and the acceptance test is clear.
- Defer when a required record or owner is missing.
- Reject when the use case cannot meet the control path.
- Route when an exception owner must accept an equivalent control.
- Mark not applicable when there is no local pre-tool delegated-authority decision.

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
- Handoff: S11/S13, customer backlog, or application engineering

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

- Decision: gateway-only, in-process, both, or not applicable; then approve, defer, reject, or route.
- Decision owner: Runtime governance owner.
- Handoff: S11/S13, customer backlog, or application engineering.
- Boundary: customer data stays in approved systems; production changes use customer change approval. S10 does not deploy AGT or prove production suitability.

Note:
End with the decision record and the named handoff.
