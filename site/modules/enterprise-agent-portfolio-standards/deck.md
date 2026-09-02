---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: Enterprise agent portfolio standards
description: Optional implementation module for cross-platform agent admission and lifecycle standards.
---

<!-- _class: cover -->

![RVAP](assets/logos/logo-full.png)

# Enterprise agent portfolio standards

## Optional implementation module

Decide what may enter and remain in the agent estate.

<!-- Notes: This module adds cross-platform decisions without creating another registry. -->

---

## Why it matters

Define one standard for classification, ownership, architecture, API publication, lifecycle, and
retirement.

Apply it to one candidate before production.

<!-- Notes: The result links live records to one checked portfolio decision. -->

---

## Architecture overview

![w:64](assets/icons/microsoft/agent-365.svg) ![w:64](assets/icons/microsoft/azure-api-center.svg) ![w:64](assets/icons/microsoft/azure-api-management.svg)

| System | Authoritative state |
|---|---|
| Microsoft Agent 365 | Enterprise agent inventory and availability |
| Azure API Center | API, MCP, and A2A catalog |
| Azure API Management | Runtime API policy |
| Source platform | Agent version and deployment |

No single system holds the whole operating decision.

<!-- Notes: Keep live state in the platforms. Store only cross-platform decisions here. -->

---

## The portfolio decision

- references to Agent 365 and API Center;
- references to APIM, Entra ID, and the source platform;
- classification and framework decision;
- duplicate and lifecycle decisions; and
- retirement coordinator and plan.

<!-- Notes: Live metadata stays in its owning system. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Normal path | Tradeoff |
|---|---|---|
| Framework | Agent Framework or Semantic Kernel | Another framework needs a support owner |
| Runtime API | Azure API Management | Direct paths need migration |
| Discovery | Azure API Center | Metadata needs maintenance |
| Inventory | Microsoft Agent 365 | Inventory does not replace runtime policy |

<!-- Notes: Prompt and low-code agents can use their native platform path. -->

---

## Duplicate review

Compare purpose, use cases, tools, data sources, and source platform.

Automation may flag a possible match.

**The portfolio owner decides** whether to reuse, approve overlap, or add a new capability.

<!-- Notes: Similarity is useful. It is not an approval authority. -->

---

## Lifecycle and retirement

```text
Proposed -> Design -> Nonproduction -> Production
                         |                |
                         v                v
                      Blocked ------> Deprecated -> Retired
```

Retirement covers user access, API publication, tool and data access, identity, runtime, and audit
retention.

<!-- Notes: A catalog removal alone does not retire the runtime. -->

---

<!-- _class: implementation -->

## Implement the module

1. Review the portfolio standard.
2. Assign stable owner roles.
3. Link the authoritative records.
4. Inspect possible duplicates.
5. Run preflight.
6. Apply the platform handoffs.

<!-- Notes: Keep the candidate outside production until the check passes. -->

---

## Safety gates

- No personal email addresses in retained records.
- No missing authoritative reference.
- No unsupported lifecycle transition.
- No production move without duplicate review.
- No production move without a retirement coordinator and plan.

<!-- Notes: The module validates the contract, not every live platform action. -->

---

## Expected result

```text
PASS: Portfolio decisions are complete.
```

Agent 365, API Center, API Management, and the source platform still own their live state.

<!-- Notes: The portfolio owner compares the record with the live inventory. -->

---

## Operating state

| Owner | Responsibility |
|---|---|
| Portfolio owner | Standard and duplicate decision |
| Platform owners | Live inventory, policy, and runtime |
| Release owner | Production decision |
| Retirement coordinator | Coordinated block and removal |

<!-- Notes: Review after a material purpose, tool, data, runtime, or ownership change. -->

---

<!-- _class: closing -->

# Thank you!
