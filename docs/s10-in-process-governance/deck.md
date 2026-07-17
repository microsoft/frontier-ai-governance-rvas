# S10 · In-Process Agent Governance

**Facilitator deck**

AI developer / maker · Governance lead · 90-minute offline decision session

Note:
Welcome and set the boundary immediately. This is an **offline illustration** and adoption decision session. It does not install AGT, change customer code, call endpoints, use tenant data, or prove production suitability. Roles: facilitator, AI developer or maker, governance lead / decision owner, evidence owner, and specialist reviewers when their controls apply.

---

## One boundary decision

> **"Does this agent have a useful place to run a policy check just before it calls a tool?"**

By the end, the customer decides whether to investigate, defer, reject, or mark it not applicable.

Note:
Keep the outcome narrow. The session is about one candidate agent-tool boundary and whether an in-process policy check is worth later customer-owned engineering assessment. It is not an approval to install, deploy, or configure anything.

---

## Why this matters

- Gateway controls govern traffic at the platform boundary.
- An in-process policy check can decide inside the agent before a tool call runs.
- You may need both.
- One control does not prove the other is configured or working.

Note:
Frame the difference without creating a hierarchy. The point is to help the customer reason about where a decision is made: outside the process at the gateway, inside the agent before the tool call, both, or neither because the boundary is not applicable.

---

## A different enforcement point

![S10 boundary diagram: the network and API gateway boundary applies shared controls while, inside the agent application, an in-process govern() wraps the tool call with policy evaluation and audit logging before the tool runs; a local hash chain gives internal consistency only, whereas a signed record in immutable external storage provides tamper evidence.](../assets/diagrams/s10-policy-boundary-and-evidence.svg)

AGT's documented `govern()` pattern wraps a tool call with policy evaluation and audit logging.

Note:
Walk the diagram from the gateway boundary to the in-process boundary. Be precise: the offline S10 simulator models the policy-and-audit idea only. It does not import, test, certify, or integrate AGT.

---

## Hash-chain consistency is not tamper evidence

- The simulator links each record to the previous record.
- It checks that supplied hashes are internally consistent.
- A replaceable local record can be recalculated.
- Tamper evidence needs signed records in immutable external storage.

Note:
This is the most important evidence distinction. A passing local hash-chain check is useful for the workshop, but it is not integrity proof against a person who can replace the file. Customer-managed storage, access control, retention, and signing are separate responsibilities.

---

## Decision evidence is not outcome evidence

- A policy-and-audit record can show the policy version checked an attempted action.
- It can show allowed, denied, or approval-required.
- It does not prove the downstream action succeeded.
- It does not prove compliance or production suitability.

Note:
Use the notification example if helpful: allowing a notification tool does not prove an email was delivered. Keep decision evidence, outcome evidence, production validation, and assurance evidence separate throughout the session.

---

## A policy records a governance decision

- Allow lists, deny defaults, and approvals encode delegated authority.
- The policy owner decides allowed tools and actions.
- The owner decides approval routes, policy change, and retention.
- The sample policy is generic and not a customer policy.

Note:
Do not let the room treat the demo policy as a recommendation to copy into code. The customer must separately review engineering fit, security, approval authority, and change control before any implementation.

---

## Applicability becomes a backlog

Typical backlog rows:

- AGT release, API, limitation, language, and runtime fit
- Policy owner, approval route, and delegated authority decision
- Signed immutable audit-retention route
- Gateway, identity, data, runtime, S5, S6, and S9 dependencies

Note:
The recommendation should say investigate AGT further, defer, reject, or not applicable. It does not authorize installation, code change, policy deployment, endpoint access, or production use.

---

## Preview and offline boundary

- AGT is Public Preview at the pinned source revision.
- Current status, APIs, limits, language support, and audit behavior may change.
- S10 complements S1, S2, S4, S5, S6, and S9.
- It does not replace any earlier control or reconciliation step.

Note:
Keep two tracks separate: pinned-source claims explain what this curriculum illustrates at a known revision; current-source research informs any future customer-owned engineering assessment. Do not merge them into an unstated product claim.

---

## Portable controls need pinned assessment

- Agent Control Specification is useful vocabulary for future engineering assessment.
- Before relying on an implementation, capture reviewed version or commit.
- Record supported runtime, limitations, and ownership decision.
- The offline boundary still applies.

Note:
Use this slide only to avoid over-reading open-source or specification language. A portable checkpoint idea is not a production decision. The customer still needs a versioned assessment and change path.

---

## The activity — how we'll work

- **Timebox:** 90 minutes · **five activities**
- **To start:** S0-S9 findings, S9 backlog, one bounded tool call, and a decision owner.
- Use no customer code, endpoints, tenant data, credentials, production policy, or raw records.
- Adoption here only authorizes a separate assessment.

Note:
Confirm entry conditions before starting. If the customer cannot describe one bounded agent-tool call or no decision owner is present, record the blocker and do not force the activity. Review the technical boundary menu first.

---

## Step 1 — Choose the boundary option · 20 min

The customer describes one action immediately before a tool invocation and the delegated authority it carries.

> **"Which boundary option fits this tool call — gateway-only, in-process, both, or not applicable — and what delegated authority makes the difference?"**
> **"Which existing control stays in place regardless?"**

Note:
Record the selected option and rationale. Not applicable is a valid decision. Make sure gateway, data, identity, evaluation, and runtime controls remain visible even if an in-process option is selected.

---

## Step 2 — Review the example policy · 15 min

Open `labs/s10-in-process-governance/policies/demo-policy.json` and explain:

- allow choices
- deny-default choices
- approval-required choices

> **"Who owns each delegated authority decision?"**
> **"Which action needs approval, and why?"**

Note:
Emphasize that the file is an example, not a customer policy and not a recommendation to copy into code. The useful output is who would own each decision and what later assessment would need.

---

## Step 3 — Run and check the offline illustration · 20 min

Confirm one simulated:

- allowed attempt
- denied attempt
- approval-required attempt
- hash-chain consistency result

> **"What did the simulator evaluate?"**
> **"What did it not see?"**

Note:
A pass means the local example has expected decisions and internally consistent hashes. It is not AGT execution, production validation, downstream success proof, or tamper evidence.

---

## Step 4 — Review limits and evidence needs · 20 min

Review pinned AGT Public Preview status, known limitations, and customer needs for:

- policy ownership
- change review
- records retention
- tamper evidence

> **"What evidence would a future engineering assessment need?"**
> **"Who owns signed immutable retention if tamper evidence is required?"**

Note:
Be explicit that a local hash chain can be replaced and recalculated. It does not prove integrity, source, immutability, or later tampering. Route unmet assurance needs to the right customer-owned process.

---

## Step 5 — Decide and hand over · 15 min

Choose:

- investigate further
- defer
- reject
- not applicable

> **"What decision can this offline illustration support?"**
> **"What must happen before engineering work starts?"**

Note:
Record fit, limits, remaining risks, owner, due date, review point, and S6 dependencies. The decision can authorize a separate assessment only. It cannot authorize installation, deployment, code change, or policy change.

---

## Verification & evidence

- [ ] The offline run completed without network or tenant access.
- [ ] The record contains allowed, denied, and approval-required decisions.
- [ ] Every record contains policy version, attempt details, timestamp, previous hash, and entry hash.
- [ ] `hash_chain_consistency.status` is `pass`.
- [ ] The record is not described as AGT execution, production validation, downstream success, or tamper evidence.
- [ ] The adoption decision and owner are recorded in the S6 follow-up backlog.

Note:
Reference the boundary, policy review, simulator record, verification result, AGT source and limitations review, and S6 backlog decision in the customer's approved records system. Do not retain customer source code, tool arguments, credentials, tenant data, or production audit records in this kit.

---

## Change boundary & hand-off

- S10 makes no tenant, endpoint, code, or policy change.
- Any AGT assessment or implementation uses a separate engineering and change-review path.
- S10 adds an optional adoption decision to the S6 backlog.
- The illustration does not move into customer code.

Note:
Close with blocker paths: no meaningful in-process boundary means not applicable; requests for installation or code change become separate engineering items; failed illustration or hash verification is recorded as observed, not repaired; tamper evidence, outcome evidence, or certification needs route to the appropriate customer process.
