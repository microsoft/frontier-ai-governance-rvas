---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

# {{SESSION_TITLE}}

Session {{SESSION_ID}} · {{DURATION_MINUTES}} minutes

---

## Control objective

{{CONTROL_OBJECTIVE}}

![Microsoft Foundry](assets/icons/microsoft/azure-ai-foundry.svg)

---

## Why it matters

{{WHY_IT_MATTERS}}

---

## Architecture overview and tradeoffs

{{ARCHITECTURE_OVERVIEW}}

**Control boundary:** {{SCOPE_BOUNDARIES}}

- **Chosen approach:** {{CHOSEN_APPROACH}}
- **Benefit:** {{BENEFITS}}
- **Cost or limit:** {{COSTS_AND_LIMITATIONS}}

---

## Implementation outcomes

- {{OUTCOME_1}}
- {{OUTCOME_2}}
- {{OUTCOME_3}}

---

## Decisions before implementation

- Confirm scope and ownership
- Resolve every required decision
- Stop before any unapproved state change

---

<!-- _class: implementation -->

## Configure the control

Apply the approved change. Keep only files with a named operational consumer.

<!-- Delivery cue: Confirm the delivery lead before any state change. -->

---

## Steps

1. Run preflight
2. Complete the implementation files
3. Inspect the preview, then apply the approved change

---

## Stop conditions

- Check the exact subscription, resource group, or service scope named in the deployment inputs
- Resolve required values
- Inspect the deployment preview

---

## Confirm the result

Run one concise check against the operational implementation.

---

## What remains

The implementation document names the implementation files, the owner, and the restore path.

---

## Handoff

The implementation team leaves the service configured. The operational source files and restore
path have named owners.

---

<!-- _class: closing -->

# Thank you!
