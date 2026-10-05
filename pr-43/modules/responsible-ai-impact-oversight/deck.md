---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: Responsible AI impact assessment, transparency, and human oversight
description: Optional implementation module for responsible AI records and human oversight on one governed Foundry agent.
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Optional module</p>

# Responsible AI impact assessment, transparency, and human oversight

**300 minutes - Responsible-AI record and approval gate**

<!--
Set the frame: one governed Foundry agent, one decision file, one consequential tool.
-->

---

## Control objective

Record the responsible-AI decision file for one governed Foundry agent, add a human approval gate to one consequential tool, and confirm approved and rejected tool-call paths.

![Foundry Agent Service](assets/icons/microsoft/foundry-agent-service.svg)

---

## Why it matters

**Problem.** A governed agent can pass deployment checks and still lack a clear record of why it is acceptable, what users must be told, and who can stop a consequential action.

**Solution.** The module records those decisions and makes one write or irreversible tool wait for a human decision before execution.

**EU AI Act.** Supports Articles 5, 6 and Annex III, 9, 13, 14, 26(2), 27, and 50. Engineering mapping, not legal advice.

<!--
Keep this practical. The module is about an operating decision, not a legal opinion.
-->

---

## Architecture at a glance

| Step | Durable record | Runtime result |
|---|---|---|
| Classify the system | Inventory JSON with enum-checked values | One selected Foundry agent is in scope |
| Explain impact and transparency | Impact assessment and transparency note | Owners can explain use, limits, and notice |
| Gate the tool | Oversight decision JSON | Approval pauses the tool call |
| Check both paths | Verify scripts | Approved executes; rejected does not |

---

## Decision file shape

The module keeps three records:

- `ai-system-inventory-entry.json` for use case, risk class, Article 5, and Article 50.
- `impact-assessment.md` for harms, affected groups, data, and human role.
- `transparency-note.md` for user notice, limits, and review cadence.

The schema rejects drift before runtime deployment.

---

## Human oversight gate

The selected tool must be `write` or `irreversible`.

The gate returns `awaiting_approval`, then resumes with the approver's decision:

- `approved` calls the configured tool route once.
- `rejected` returns without tool execution.

The requester and approver come from App Service authentication headers and claims, not from the request body.

**No rejection can become a tool call.**

---

## Implementation tradeoffs

| Choice | Approach | Limit |
|---|---|---|
| Scope | One governed Foundry agent | Estate-wide review stays with lifecycle operations |
| Approval pattern | Foundry hosted-agent pause and resume | Long-running agents are preview |
| Approver identity | App Service authentication headers plus role or group claim | The gate rejects unauthenticated, unauthorized, and self-approval calls |
| Pending state | In-memory store for this nonproduction check | Production needs the approved durable store |
| Legal boundary | Record classification and stop conditions | Counsel owns the legal decision |
| Verification | Approved and rejected runtime checks | A live gate is required |

---

## What preflight checks

Preflight rejects:

- unresolved `__REQUIRED_*__` decisions;
- target scope other than `one-approved-foundry-agent`;
- invalid enum values or a prohibited risk class;
- a blocked Article 5 screen;
- oversight settings that allow rejected execution.

It also states that no read-only deployment preview exists for the approval code.

---

<!-- _class: implementation -->

## Run the module

1. Complete the inventory, impact, transparency, and oversight records.
2. Run preflight in PowerShell or Bash.
3. Review classification, disclosure, and stop path with the owners.
4. Deploy the approval gate through the runtime pipeline.
5. Run the approved and rejected tool-call checks.

---

## Confirm the result

| Check | Expected result |
|---|---|
| Intended path | Approved call returns `approved-executed`, `toolExecuted: true`, and a correlation ID |
| Blocked path | Rejected call returns `rejected-not-executed`, `toolExecuted: false`, and a correlation ID |
| Owner checkpoint | The delivery owner sees both results and keeps the tool disabled if either fails |

---

## Operating state

| Owner | Maintains |
|---|---|
| Responsible-AI inventory owner | System record and risk class |
| Product owner | Impact assessment and intended-use changes |
| Transparency owner | Disclosure text and review cadence |
| Runtime owner | Approval gate, tool binding, and stop mechanism |
| Operations owner | Decision-store retention |

---

<!-- _class: closing -->

# Thank you!
