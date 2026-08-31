---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 10</p>

# Purview data governance and Agent 365 data controls

180 minutes · Configure, simulate, and confirm one labelled data path

<!-- Notes: Session 09 constrained tool authority. This session governs the data path. -->

---

## Why it matters

> Keep an ownership record for the separate Agent 365 and Foundry DLP paths, configure one scoped Agent 365 DLP policy from current Purview state, and query payload-free audit activity.

By the end of the session:

- `coverage-handoff.md` names the owners on both product paths.
- The approved label and any VIEW and EXTRACT rights are confirmed.
- One nonproduction Agent 365 policy is simulated, enabled, and checked after propagation.
- The included user finds the agent; the excluded user does not.
- Purview shows the intended result, the out-of-scope non-match, and scoped audit activity.

<!-- Notes: Keep live policy and label state in Purview. -->

---

<!-- _class: two-column -->

## Architecture and control boundary

<div class="columns">
<div>

![Agent 365 and Microsoft Foundry use separate control paths that feed shared Purview visibility.](assets/diagrams/purview-product-coverage-split.svg)

</div>
<div>

**Agent 365**

Purview evaluates the agent, group, direction, location, and label. It applies the approved
`Block` or `Audit` action.

**Microsoft Foundry**

Foundry DLP needs an Entra-app-scoped rule plus application integration that calls
`processContent` with signed-in user context.

The Agent 365 policy does not govern Foundry calls.

</div>
</div>

<!-- Notes: One Purview view does not replace the ownership handoff. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Required answer | Limit |
|---|---|---|
| Scope | One nonproduction agent and test group | Broader rollout needs another change |
| Label | Approved label ID and publishing scope | Encrypted sources need agent VIEW and EXTRACT rights |
| Action | `Block` or `Audit` | `Block` can interrupt work; `Audit` does not stop it |
| Output | Labelled library, user labelling, or auto-labelling | Source labels do not transfer automatically |
| Restore | Named route and owner | Shared labels and Foundry coverage stay outside this restore |

The DLP operator uses **Compliance Data Administrator**. The audit operator needs **View-Only Audit
Logs** in Purview and Exchange. The Graph application needs `AuditLogsQuery.Read.All` with
administrator consent.

<!-- Notes: Exact roles, scopes, and label rights are stop conditions. -->

---

<!-- _class: implementation -->

## Implementation path

**Total session: 180 minutes.**

1. Confirm entitlements, owners, Session 01-07 control state, and the synthetic source.
2. Run preflight against the approved tenant and Agent 365 instance.
3. Create the custom policy with the approved coordinates in `TestWithNotifications`.
4. Review simulation, enable through the approved change, and wait outside the facilitated work
   for the recorded propagation allowance.
5. Resume after propagation. Install the Session 06-approved agent for its group and host product.
6. Confirm availability, run the labelled interaction and non-match, then query audit activity.

<!-- Notes: The published duration excludes the asynchronous propagation wait. -->

---

<!-- _class: decision -->

## Safety gates

Stop before or during the change when:

- a required license, entitlement, owner, role, permission, or restore route is missing;
- the policy summary differs from the approved agent, group, label, directions, locations, or action;
- the prior-session inventory, `get_policy` allowlist, backend role scope, read result, or denied-write result is unresolved;
- an encrypted source lacks explicit agent VIEW and EXTRACT rights plus a direct share;
- Foundry DLP is called active without the app-scoped rule, `processContent`, and user context;
- production data, prompts, responses, identities, raw audit content, or portal copies enter the repository.

<!-- Notes: The portal summary and simulation are the preview for this portal-led change. -->

---

<!-- _class: implementation -->

## Confirm the extended checks

**Intended path**

Run the labelled synthetic interaction after propagation. `Block` stops the match. `Audit` allows
it and records the match. Inspect the output label behavior and scoped audit activity.

**Out-of-scope path**

Repeat with the approved excluded-group alias. Keep every other coordinate unchanged. The policy
must not report a match.

**Delivery-owner checkpoint**

The owner checks the propagation wait, included-user availability, excluded-user denial, both DLP
results, and the audit event. Keep the policy in simulation or disable it if a check fails.

<!-- Notes: Record results in Purview and the approved change system, not the repository. -->

---

<!-- _class: two-column -->

## Payload-free audit and operating state

<div class="columns">
<div>

### Query contract

Operations:

- `AIInvokeAgent`
- `AIExecuteTool`
- `AIInferenceCall`
- `AIGuardrail`

Output: time, operation, agent ID, agent name, and result status.

</div>
<div>

### Keep in operation

- Data owner: cross-product handoff
- Information protection owner: labels and output control
- Agent 365 owner: workflow impact
- Audit owner: query definition and operation names
- Foundry owner, Purview operator, and developer: separate Foundry path

</div>
</div>

<!-- Notes: The scripts write no audit export or interaction content. -->

---

## Restore and handoff

If the policy causes a problem:

1. Return it to `TestWithNotifications`.
2. Disable it after dependency review.
3. Remove the scoped agent and group before deleting a session-created policy.
4. Remove label rights or source sharing only after the data owner confirms no dependency remains.

Do not delete a reused label, Foundry coverage, audit records, or source data. Review
`coverage-handoff.md` quarterly and after an owner or product-boundary change.

Session 11 can use this labelled, governed path for evaluation work.

<!-- Notes: Foundry coverage and billing have their own restore decision. -->

---

<!-- _class: closing -->

# Thank you!
