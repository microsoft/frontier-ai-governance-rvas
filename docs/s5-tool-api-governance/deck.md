# S5 · API, Tool & MCP Governance

**Facilitator deck**

Governance lead · Platform owner · Security reviewer · AI developer / maker · 90-minute publication review

Note:
This evidence-first, report-only session reviews a bounded set of APIs, tools,
or MCP services and makes no live change. Do not publish, grant permissions,
create identities, connect to live services, or treat a catalog as safety proof.

---

## One question for every candidate

> **"Can we publish it, hold it, suspend it, or withdraw it safely?"**

The answer must name owner, workspace, classification, caller, authority, version, evidence, and approver.

Note:
This is the whole session. S5 creates the decision record before publication or lifecycle action. It does not publish a service, grant permission, create a caller identity, configure an integration, or test a live connection.

---

## Why this matters

- A tool or API becomes governable when reviewers can say what it is and who owns it.
- They also need where it belongs, who may call it, what it may do, and which version is under review.
- A catalog entry helps find facts; it does not prove runtime safety.

Note:
A catalog supports governance; it does not prove safety, configuration,
authorization, or live behavior. Implementation and runtime verification are
separate processes.

---

## Catalog record, not safety proof

![Publication record fields and system-of-record choices expose governance gaps.](../assets/diagrams/s5-tool-api-governance-record-model.svg)

A catalog records discoverability, owner, version/lifecycle state, and exposure-control intent.

Note:
Walk the diagram from publication record to system of record. The system might be API Center plus API Management products, an existing estate or catalog, or an ad-hoc list/no registry treated as a gap. None of these choices proves runtime safety or publication approval by itself.

---

## Publication decisions become backlog

- Name the next publication path and why alternatives were rejected or deferred.
- Backlog registry, gateway route, caller identity, MCP or connector path, version, authorization, lifecycle, and change ownership.
- S5 records owner and path; it does not execute them.

Note:
Typical handoffs include API Center or catalog registration, Azure API Management or AI Gateway route, MCP or connector implementation path, S6 runtime evidence, S9 lifecycle reconciliation, and customer change or release ownership.

---

## Ownership must be specific

- Catalog owner keeps the record current.
- Technical owner understands behavior and version.
- Decision owner accepts publication readiness, hold, suspension, or withdrawal.
- No accountable owner means not ready.

Note:
One person may hold more than one role only when the record says so. An entry with no accountable owner stays proposed or on hold until someone accepts responsibility.

---

## Names, workspaces, and classification control review depth

- Names should show purpose and boundary without implying unproved safety.
- Workspace, namespace, or collection signals audience and rules.
- Classification states handling limits, data categories, and assumptions.
- Unknown classification means gap or hold, not a guess.

Note:
The decision should state why placement fits the classification, whether another entry could be confused with it, and who approved the choice. The record should not make broad claims that the candidate is compliant or safe.

---

## Caller identity and authority are separate

- Caller identity: who or what invokes the candidate.
- Authority scope: what that caller may cause, under which conditions.
- Minimum authority means allowed actions, boundaries, constraints, prohibited actions, escalation, and exception approval.

Note:
An identity reference without bounded authority is incomplete. A scope without an identifiable caller cannot be reviewed. S5 neither grants authority nor tests it.

---

## Versioning, lifecycle, and runtime boundaries

- Decisions apply to a specific version and configuration boundary.
- Material changes require re-review.
- Lifecycle states include proposed, publish-ready, published, hold, suspended, and withdrawn.
- Suspension and withdrawal need triggers, owners, communication, and verification references.
- S5 identifies runtime boundary and owner; S6 reviews runtime evidence.

Note:
A version label alone does not prove that nothing material changed. Suspension is temporary while the customer investigates, remediates, or decides. Withdrawal removes the candidate from intended discovery or use and retains only required records. Gateway policy can enforce part of an approved publication decision, but it does not replace identity, data, observability, lifecycle, or in-process checks.

---

## The activity: how we'll work

- **Timebox:** 90 minutes · **six steps**
- **Entry condition:** bounded candidates, evidence location, owners, and decision authority.
- Unknown owner, source, classification, caller, authority, or authority to decide? **Stop that candidate.**

Note:
Preview the flow: boundary, ownership/version, naming/workspace, classification/authority, lifecycle criteria, decision and handover. The customer operates its records and makes decisions; the facilitator preserves boundary, timebox, and interpretation.

---

## Step 1: Set boundary and decision question · 10 min

> **"What is in scope, what is out of scope, and what would make us stop?"**

Name the candidate set, intended decision, records location, and authorities.

Note:
Record references and expected signals only. Do not broaden the candidate set to fill time. A missing decision authority or records location blocks the affected review.

---

## Step 2: Establish ownership and identity · 15 min

> **"Who owns the lifecycle decision, and is this the exact version under review?"**

Name catalog owner, technical owner, candidate identifier, version, consumers, and source reference.

Note:
Use the offline catalog template in the customer's approved records system. Unknown ownership or version is a finding. Do not infer it.

---

## Step 3: Decide naming and workspace placement · 15 min

> **"Can a reviewer distinguish this entry from a similarly named service?"**
> **"Does the workspace match the classification and audience?"**

Record name, namespace or workspace, alternatives, confusion risk, and decision owner.

Note:
Do not create or move any workspace item. The point is a reviewable placement decision that does not imply more safety than the evidence supports.

---

## Step 4: Classify and bound authority · 20 min

> **"What is the minimum authority this caller needs for this exact version and use?"**
> **"Can we prove the caller identity separately from the authority scope?"**

Record classification, caller identity, authentication expectation, allowed actions, prohibited actions, and boundary conditions.

Note:
A broad or unknown scope is a finding, not an approval. Include delegated or non-delegated authority, data-handling limits, escalation, and approval references for exceptions.

---

## Step 5: Apply publication and lifecycle criteria · 20 min

> **"Which criterion has evidence?"**
> **"What event triggers suspension or withdrawal?"**

Choose proposed, publish-ready, hold, suspended, or withdrawn.

Note:
Publish-ready is a decision state, not an instruction to publish. The criteria create a reviewable governance decision; they do not prove runtime safety, security effectiveness, legal compliance, availability, or live authorization.

---

## Step 6: Decide and hand over · 10 min

> **"Who owns each next action, and when is the next review?"**

Accept, defer, reject, suspend, or withdraw the stated disposition and assign every gap.

Note:
Read back only safe references, decision, owner, date, remaining risk, due date, required customer change, and next review. A template, facilitator note, or catalog entry is not proof that the candidate can be used safely.

---

## Verification & evidence

- [ ] Each candidate has a customer-held catalog record with owners, version, naming/workspace decision, classification, caller identity, and authority scope.
- [ ] Publication criteria have evidence references or explicitly owned gaps.
- [ ] Lifecycle record identifies state, review date, suspension triggers, withdrawal path, and decision owner.
- [ ] Customer records contain disposition, remaining-risk decision, next action, and next review.

Note:
Reference candidate source, ownership record, classification record, identity and authority references, workspace and naming decision, version record, lifecycle decision, and approval or deferral. Do not copy evidence into this repository.

---

## Change boundary & hand-off

- S5 changes no catalog, workspace, service, identity, permission, integration, or lifecycle state.
- Publication, permission grant, suspension, or withdrawal is customer-owned.
- Re-review when version, authority, ownership, classification, or lifecycle changes.

Note:
Publish-ready hands off to the separate publication process; it is not
publication. Assign each gap to an owner, date, and process.
