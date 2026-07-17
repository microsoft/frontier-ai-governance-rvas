# S1 · Identity & Ownership Review

**Facilitator deck**

Identity admin · Governance lead · 90-minute review-only working session

Note:
Welcome and framing. This is a **review-only** session — it changes nothing in the tenant and creates no policy. Timebox is 90 minutes. Roles in the room: facilitator (you), identity admin (does the customer work), governance lead (makes the decisions), evidence owner, security reviewer. Use arrow keys or the on-screen controls to move; press **S** for speaker notes, **Esc** for the slide overview.

---

## One question, for every agent

> **"Who owns it — and can we prove it?"**

By the end, the customer can answer that for every agent in scope.

Note:
This is the whole session in one line. Everything we do today builds toward being able to answer this question confidently for each agent — and to be honest about the agents we *can't* yet answer it for.

---

## Why this matters

- You can't govern an agent you can't **name** and tie to an **owner**.
- When an incident happens, *"who is responsible for this agent?"* needs a fast, confident answer.
- A quick directory search is **not** an agent inventory — and we won't pretend it is.

Note:
Set the stakes. The failure mode we're preventing is an incident where nobody can say who owns the agent, what list it's on, or what that list actually covers. Be explicit that this session deliberately avoids faking an inventory from a directory query.

---

## Every agent needs an owner you can name

![S1 object model: the Entra Agent ID chain (blueprint, blueprint principal, agent identity, agent user account) sits in the tenant identity plane with an accountable human sponsor, separate from the runtime access controls (Conditional Access and gateway authentication); on-behalf-of identities are recorded as a gap.](../assets/diagrams/s1-agent-identity-model.svg)

**Microsoft Entra Agent ID** gives an agent a real identity — built from a blueprint, a blueprint principal, an agent identity, and an agent user account.

Note:
Walk the diagram left to right, but land the point quickly: the object model isn't the point. The point is that **every agent needs a human sponsor who is accountable for what it does and how long it lives**. An agent identity is more than an app registration — its sponsor and lifecycle belong in the governance record.

---

## The list is your first control

- Agents get identities as makers build them in supported tools — they appear through **normal development**, not a tidy onboarding step.
- A list is only useful evidence when it says **which source** it came from and **which workload** it covers.
- S1 deliberately does **not** export or guess at identity data.

Note:
Reinforce: a general service-principal, managed-identity, app, or OBO view can *back up* a record, but it can't prove an agent's identity or that you've found them all. The customer records the source it trusts, what it covers, its gaps, the sponsor, the lifecycle, and the decision — in their own system.

---

## Seeing an agent isn't controlling it

- An agent acting for a user (**OBO**) can show up in telemetry without its own governable Agent ID → record it as a **gap**, not "handled."
- **Gateway authentication** (JWT validation at API Management) guards *runtime* access.
- **Entra Agent ID + sponsorship** govern the *identity plane*.
- You often need **both** — neither replaces the other.

Note:
This is the most common conceptual trap. Visibility is not control. Make sure the room hears that OBO visibility is a gap to be recorded, and that the gateway boundary and the identity plane are two different controls that coexist.

---

## Conditional Access is the customer's change

- Setting up Conditional Access for workload identities depends on tenant, licensing, supported workloads, scope, exclusions, and the customer's change process.
- A generic policy or break-glass template **can't** stand in for that.
- **In Co-deliver:** S1 finds the missing owners and coverage gaps — the customer's own identity-change process owns any control they decide to add.

Note:
Keep the boundary crisp: we surface findings; we do not design or roll out Conditional Access. If the customer decides to add a control, their identity-change process owns the design, any report-only trial, rollout, rollback, checks, and evidence.

---

## Findings become a short backlog

**A reviewed list can support:** a sponsor decision · a lifecycle review · a "does Entra Agent ID cover more of these?" investigation · RBAC/OBO follow-up · an access review · a blocker.

**It does not:** create an identity · grant access · set up Conditional Access · approve production use.

Note:
Keep two things apart in the recommendation: what you *found*, and what to *build next*. The deliverable is a short, honest backlog with owners — not a set of implemented controls.

---

## The activity — how we'll work

- **Timebox:** 90 minutes · **five steps**
- **To start you need:** one clear workload · an admin source the customer can open · a place to store results · a governance lead in the room.
- No source or no decision-maker? **Stop that part and record what's blocking it** — don't fall back to a directory query.

Note:
Confirm you actually have the preconditions before diving in. If a precondition is missing, that itself is a finding. Introduce the five steps you're about to walk: agree coverage, review the list, read the signals, make the call, hand off.

---

## Step 1 — Agree what the list can and can't tell you · 15 min

> **"Which agents does this source actually cover, and which does it miss?"**

The customer names the workload, the source, what it covers, what it excludes, where evidence lives, and when to stop.

Note:
A useful answer is a clear coverage statement. "Nothing found" only counts if you also record what you checked and when. If a supported source won't open, that's **blocked** — not permission to guess an agent's status.

---

## Step 2 — Customer reviews the list · 35 min

The identity admin copies `labs/s1-identity/templates/identity-inventory-review.template.md` into the customer's records system and reviews each agent.

> **"Who owns this agent's purpose and lifecycle?"**
> **"What proves this identity belongs to this workload?"**
> **"When do we review it again?"**

Note:
A good row has an identity type, a sponsor, a lifecycle state, a source reference, and a finding. No record for the declared scope? Note it with source, date, and reviewer. Source can't show a field you need? That's a coverage gap. No access or no owner? Stop that part and assign the follow-up. This is the longest step — protect the time.

---

## Step 3 — Read the signals correctly · 15 min

Service-principal, managed-identity, OBO, or app context can **back up** a record — but:

> **"Does this prove the agent's identity, or just hint at it?"**
> **"Is this the user acting, or the agent acting on its own?"**

Note:
Record what you found, how far its authority reaches, its limits, the backlog item, your confidence, the owner, and where it goes next (S4, S6, S9, or the customer's identity-change process). OBO visibility is not its own inventory entry unless the supported source says so.

---

## Step 4 — Make the ownership call · 15 min

For each gap, the **governance lead** decides:

- **Assign** a missing sponsor
- **Accept** a small known risk
- **Defer**
- Mark the source's coverage as **blocked**

Record the source reference, decision, owner, approver, and review date. Never copy real IDs or exports here.

Note:
Base the call on how well the source covers the agent, whether there's a clear owner, how clear the lifecycle is, the access risk, and who has authority. Where the identity path or runtime access is undecided, choose from the Technical decisions menus and record it in `templates/technical-decision-record.template.md`.

---

## Step 5 — Hand off without designing controls · 10 min

- Read back the control state: `observed`, `accepted_risk`, or `blocked`.
- Name the evidence reference, the next owner, and the **S6 dependency**.
- Any Conditional Access, break-glass, or remediation request goes to the customer's identity-change process.

Note:
If no decision-maker was present, mark the decision **deferred** with an owner and a date. The point of this step is a clean, honest hand-off — not a control design.

---

## Verification & evidence

- [ ] The list names its **source, coverage, exclusions, and review date**.
- [ ] Every agent has an identity type, sponsor, lifecycle state, access note + reach, and a finding.
- [ ] Every ownership / accepted-risk / coverage-gap decision has an **owner, approver, and next review date**.
- [ ] Every "nothing found", missing capability, and blocker records what you checked, the evidence reference, the owner, and the review date.

Note:
Save only the list *reference* and its retention/classification note in `04-operate/evidence-register.json`, and the decision in `04-operate/decision-register.json`, in the generated delivery workspace. Don't put list data, object IDs, exports, or policy evidence in Git.

---

## Change boundary & hand-off

- This kit **changes nothing** in the tenant.
- The customer's identity-change process owns any Conditional Access, break-glass, access remediation, rollback, verification, and evidence retention.
- The customer's list reference and coverage note feed **S6 reconciliation**.

Note:
Close by restating the boundary and where the work goes next. When you're stuck: no trusted source → record the coverage gap; no sponsor → raise an ownership finding; OBO → mark it visibility-only unless the supported source says otherwise. Assign an owner and date, and resume once it's resolved.
