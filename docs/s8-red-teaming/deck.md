# S8 · Red Teaming

**Facilitator deck**

Microsoft default: **AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Defender, and SOC remediation routes**.

Concrete decision: **Approve, defer, reject, or route the AI red-team plan.**

---

## Start with the Microsoft path

- Default control path: AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Defender, and SOC remediation routes.
- Customer inspects: Inspect the AI Red Teaming Agent or PyRIT test plan, Content Safety checks, Defender signal route, and SOC remediation queue.
- Decision owner: AI red-team lead.

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
- Handoff: Security remediation owner

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
- Decision owner: AI red-team lead.
- Handoff: Security remediation owner.
- Boundary: customer data stays in approved systems; production changes use customer change approval.

Note:
End with the decision record and the named handoff.
