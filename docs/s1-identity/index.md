# S1 · Identity & Ownership Review

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Identity admin</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer can answer one question for every agent
in scope: **who owns it, and can we prove it?**

They leave with:

- A list of the agents in scope, taken from an admin source they trust —
  usually **Microsoft Entra Agent ID** — with a plain note of what the list
  covers and what it misses.
- A named human sponsor and a lifecycle decision (keep, review, retire) for each
  agent on the list.
- The list reference and each decision saved in the customer's own records system
  or the generated delivery workspace.

`labs/s1-identity/` holds the runbook and a blank review template. It does **not**
hold real identity data, exports, Conditional Access policies, break-glass
templates, or customer records — those stay in the customer's own systems.

### What happens next

S1 produces a short identity backlog for the customer to work on later. The
recommendation says which path to take: keep the current setup, fix missing
owners or gaps in the source, look into whether Entra Agent ID covers more
agents, send RBAC / on-behalf-of (OBO) / Conditional Access work to the
customer's identity-change process, or pause dependent sessions until every
agent has an owner and a trusted source.

### What the list captures

For each agent, the review records: where the record came from, what the source
covers and excludes, the identity type, the agent it maps to, the human sponsor,
its lifecycle and purpose, how it gets access and how far that access reaches,
any related access or risk notes, and review details (who reviewed it, when, what
they found, the decision, and the next review date). Real IDs and personal data
stay in the customer's approved system, never in this repo.

## 2. Prerequisites

- A customer identity admin who can open the right admin source for the workload
  in scope (for example, Entra Agent ID).
- A place the customer already trusts to store the list, evidence, and decisions.
- A named governance lead who can accept gaps in coverage and sign off on ownership.

You do **not** need Conditional Access licensing, a break-glass design, Graph
PowerShell, or any particular Entra Agent ID setup to run this session.

## 3. Why this session matters

You can't govern an agent you can't name and can't tie to an owner. If an
incident happens, "who is responsible for this agent?" needs a fast, confident
answer. S1 gets you there: a trusted list, a human sponsor per agent, and an
honest note of what the list still misses. A quick directory search is **not**
the same as a real agent inventory, and this session is careful not to pretend it is.

Read the [S1 Concepts](concepts.md) for how Entra Agent ID, ownership, OBO, and
the gateway boundary fit together.

## 4. Co-delivery walkthrough

!!! warning "Review-only boundary"
    This session changes nothing in the tenant and creates no policy. Don't treat
    a service-principal name or tag match as a real agent inventory, and don't
    copy any identity data into this repository.

**Timebox:** 90 minutes. **Roles:** facilitator, identity admin (does the
customer work), governance lead (makes the decisions), evidence owner, security
reviewer. **To start:** you need one clear workload, an admin source the customer
can open, a place to store results, and a governance lead in the room. If there's
no source or no decision-maker, stop that part and write down what's blocking it —
don't fall back to a directory query.

**What the customer actually does:** the identity admin opens a real list of
their agents and reviews it; then the governance lead decides how to handle any
missing owners or gaps.

1. **Agree what the list can and can't tell you** *(15 min)* — the facilitator
   asks: **"Which agents does this source actually cover, and which does it
   miss?"** The customer names the workload, the source, what it covers, what it
   excludes, where the evidence lives, and when to stop. A useful answer is a
   clear coverage statement. "Nothing found" only counts if you also record what
   you checked and when. If a supported source won't open, that's blocked — not
   permission to guess an agent's status.
2. **Customer reviews the list** *(35 min)* — the identity admin copies
   `labs/s1-identity/templates/identity-inventory-review.template.md` into the
   customer's records system and reviews each agent using the fields above. The
   facilitator asks: **"Who owns this agent's purpose and lifecycle?"**, **"What
   proves this identity belongs to this workload?"**, and **"When do we review it
   again?"** A good row has an identity type, a sponsor, a lifecycle state, a
   source reference, and a finding. If there's no record for the scope you
   declared, note it with the source, date, and reviewer. If the source can't
   show a field you need, write that down as a coverage gap. If you can't get
   access or there's no owner, stop that part and assign the follow-up.
3. **Read the signals correctly** *(15 min)* — the customer can compare
   service-principal, managed-identity, OBO, or app context to back up a record,
   but the facilitator asks: **"Does this prove the agent's identity, or just
   hint at it?"** and **"Is this the user acting, or the agent acting on its
   own?"** Record what you found, how far its authority reaches, its limits, the
   backlog item, your confidence, the owner, and where it goes next (S4, S6, S9,
   or the customer's identity-change process). OBO visibility is not its own
   inventory entry unless the supported source says so.
4. **Make the ownership call** *(15 min)* — the governance lead decides for each
   gap: assign a missing sponsor, accept a small known risk, defer, or mark the
   source's coverage as blocked. Base it on how well the source covers the agent,
   whether there's a clear owner, how clear the lifecycle is, the access risk, and
   who has authority. Record the list/source reference, the decision, the owner,
   the approver, and the review date. Never copy real IDs or exports here.
5. **Hand off without designing controls** *(10 min)* — the facilitator reads
   back the control state (`observed`, `accepted_risk`, or `blocked`), the
   evidence reference, the next owner, and the S6 dependency. Any Conditional
   Access, break-glass, or remediation request goes to the customer's
   identity-change process. If no decision-maker was there, mark the decision
   deferred with an owner and date.

## 5. Verification & evidence capture

- [ ] The list names its source, what it covers, what it excludes, and the review date.
- [ ] Every agent reviewed has an identity type, a sponsor, a lifecycle state, an
  access note, how far that access reaches, and a finding or decision.
- [ ] Every ownership, accepted-risk, and coverage-gap decision has an owner, an
  approver, and a next review date.
- [ ] Every "nothing found", missing capability, and blocker records what you
  checked, the evidence reference, the owner, and the review date.

Save only the list reference and its retention/classification note in
`04-operate/evidence-register.json`, and the decision in
`04-operate/decision-register.json`, in the generated delivery workspace. Don't
put list data, object IDs, exports, or policy evidence in Git.

## 6. Change boundary

This kit changes nothing in the tenant. The customer's identity-change process
owns any Conditional Access, break-glass, access remediation, rollback,
verification, and evidence retention.

## 7. Facilitator notes

- **When you're stuck:** no trusted source → record the coverage gap; no sponsor
  → raise an ownership finding; OBO → mark it as visibility only, unless the
  supported source says otherwise. Assign an owner and date, and resume once
  it's resolved.
- **Official context:** [manage agent identities](https://learn.microsoft.com/en-us/entra/agent-id/manage-agent-identities-admin)
  and [manage owners and sponsors](https://learn.microsoft.com/en-us/entra/agent-id/manage-owners-sponsors-agents)
  describe what the product can do. They back up the terms here; they don't
  replace the customer's own coverage evidence.
- **Hand-off:** the customer's list reference and coverage note feed S6
  reconciliation; remediation decisions stay with the customer.

[^entra]: Microsoft Learn - [What is Microsoft Entra Agent ID?](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id); [Agent ID governance overview](https://learn.microsoft.com/en-us/entra/id-governance/agent-id-governance-overview).
