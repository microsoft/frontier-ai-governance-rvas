---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Session 09</p>

# Purview data governance and Agent 365 data controls

**240 minutes - One labelled path, one scoped data control**

<!-- Notes: Session 08 constrained tool authority. Today we govern the data that agents can reach and share. -->

---

## Control objective

> Keep one customer-owned coverage record for the Agent 365 and Foundry split. Confirm the approved label, configure one scoped Agent 365 DLP policy, and query payload-free Agent 365 audit activity.

### Result check

- Agent 365 and Foundry coverage are recorded separately.
- One approved label protects the synthetic source.
- One Agent 365 DLP policy has an approved nonproduction scope.
- The blocked path is blocked or audited as configured.
- Agent activity is visible without retaining content.

<!-- Notes: Keep the session on one data path and the product boundaries that protect it. -->

---

## Implementation outcomes

1. Keep one owned coverage record with live and manual checks separated.
2. Reuse one sensitivity label and confirm explicit encryption rights.
3. Apply one scoped Agent 365 DLP policy.
4. Keep a payload-free Agent 365 unified audit log query.
5. Observe one labelled interaction and record generated-content label behavior.

<!-- Notes: These are operational controls, not a one-off compliance demonstration. -->

---

## Why it matters

The customer-owned coverage record keeps Agent 365 policy coverage separate from Foundry coverage.

It ties the selected label, policy scope, and audit route to the people who maintain them.

<!-- Notes: Purview owns live service state. The review record owns the cross-product decision record. -->

---

## Control boundaries

- One nonproduction Agent 365 instance, one test group, and one approved label ID
- Microsoft Purview is the live source for label, DLP, Audit, and DSPM state
- The customer-owned review record records the Agent 365 and Foundry split
- The Agent 365 DLP policy does not govern Foundry
- Production, additional agents, broad populations, and payload collection are excluded

<!-- Notes: Foundry Purview Data Security and policy prerequisites remain a separate control path. -->

---

<!-- _class: section-divider -->

# Two products, two control paths

Agent 365 policy targeting and Foundry data-security enablement are related. They are not the same control surface.

The customer-owned review record records the split. Purview remains the live source for service state.

<!-- Notes: This distinction prevents a false sense of coverage. -->

---

## Agent 365 and Foundry are separate

<div class="cards">
<div class="card">

![Microsoft Agent 365](assets/icons/microsoft/agent-365.svg)

### Microsoft Agent 365

Include the agent instance in Purview policies like a user. DLP supports agent-to-human and human-to-agent paths in Teams, OneDrive or SharePoint, and email.

</div>
<div class="card">

![Microsoft Foundry](assets/icons/microsoft/azure-ai-foundry.svg)

### Microsoft Foundry

Enable Purview Data Security separately for Audit and DSPM visibility.

Current DLP is narrower. It can block supported sensitive-information-type prompts only when the app uses the current integration with user context and approved pay-as-you-go policy billing.

</div>
</div>

<!-- Notes: Audit and DSPM can see both, but enforcement requirements differ. -->

---

## Architecture overview

<!-- _class: diagram -->

![Agent 365 and Microsoft Foundry share Purview Audit and DSPM paths, while DLP scope, enablement, billing, user context, and manual checks remain product-specific](assets/diagrams/purview-product-coverage-split.svg)

<!-- Notes: Start with the Agent 365 transaction, then show where that policy boundary ends. -->

---

## What this means

Agent 365 and Foundry use separate Purview policy paths. On the Agent 365 path, Purview checks the
agent, group, direction, location, and label before either blocking a matched interaction or
auditing it without interruption.

That DLP boundary does not extend to Foundry. Foundry has a separate enablement path and narrower
current DLP coverage.

Purview owns live label, policy, Audit, and DSPM state. The coverage handoff records who owns each
product path because no single service view does.

---

## What Purview covers for Agent 365

| Capability | Session use |
|---|---|
| DSPM / AI observability | Review data-risk findings |
| Sensitivity labels | Protect the synthetic source |
| DLP | Govern both supported interaction directions |
| Audit | Search current Agent 365 operations |
| eDiscovery | Confirm entitlement and operating route |

The policy scope must list the agent instance. Broad intent is not scope.

<!-- Notes: Other Purview capabilities exist, but this session implements only what supports the control. -->

---

## Foundry coverage has extra prerequisites

![Microsoft Foundry](assets/icons/microsoft/azure-ai-foundry.svg)

- Enable Purview Data Security in Foundry Control Plane or Defender for Cloud.
- Approve pay-as-you-go billing for Purview policy management.
- Record whether the application supplies user context.
- Keep Microsoft Foundry Audit coverage distinct from policy billing.
- Treat the current Foundry DLP path as narrower than Agent 365 DLP.

<!-- Notes: Do not tell the customer that the Agent 365 policy protects Foundry API calls. -->

---

<!-- _class: decision -->

## Decision 1 - Coverage and entitlement

Stop before configuration when:

- the qualifying Agent 365 license is unconfirmed;
- E5 is neither confirmed nor covered by an approved exception;
- Purview DLP, Audit, DSPM, or eDiscovery entitlement is unknown;
- Foundry pay-as-you-go policy billing is unapproved; or
- the Foundry application has an undocumented user-context gap.

<!-- Notes: Licensing and user context change what the product can enforce. -->

---

<!-- _class: section-divider -->

# Reuse the approved label; grant VIEW and EXTRACT to the agent in scope

Use the approved label taxonomy. A session-specific label is usually the wrong answer.

<!-- Notes: The control should fit the data-governance system the customer already owns. -->

---

## Reuse one sensitivity label

![Microsoft Purview](assets/icons/microsoft/microsoft-purview.svg)

The required decision records:

- label name and stable ID;
- publishing scope;
- SharePoint and OneDrive support;
- encryption decision;
- agent VIEW and EXTRACT rights; and
- generated-content compensating control.

<!-- Notes: A display name is not enough; the stable label ID anchors the policy. -->

---

## Encryption changes agent access

When the selected label encrypts the source:

```text
explicit agent instance
 + VIEW
 + EXTRACT
 + direct source share
 = approved data access
```

“All users in the organization” does not grant an Agent 365 instance the required rights.

<!-- Notes: Stop if the access decision cannot name the agent. -->

---

<!-- _class: decision -->

## Decision 2 - Label and source

Stop when:

- the taxonomy owner has not approved the label;
- SharePoint and OneDrive label support is disabled;
- encrypted access lacks explicit VIEW and EXTRACT rights;
- the source contains real customer data instead of the approved synthetic item; or
- the source owner, review date, or expiry is missing.

<!-- Notes: Do not create a second taxonomy to keep the session moving. -->

---

## Generated content is a known gap

Source label protection does not automatically become output protection for newly created Agent 365 content.

Record the observed output label and choose a control:

- labelled destination library;
- mandatory user labelling; or
- approved auto-labelling policy.

<!-- Notes: Never mark output protected just because its source was labelled. -->

---

<!-- _class: section-divider -->

# One narrow DLP policy

The policy names the agent, people, directions, locations, label, and action.

<!-- Notes: Exact scope is what makes a data policy deployable. -->

---

## The approved DLP scope

| Coordinate | Session 09 boundary |
|---|---|
| Environment | Nonproduction |
| Agent | One Agent 365 instance |
| People | One approved test group |
| Directions | Human-to-agent and agent-to-human |
| Locations | Teams, OneDrive or SharePoint, email |
| Condition | One sensitivity label ID |
| Action | `Block` or `Audit` |

<!-- Notes: Any extra target is a stop condition, not a harmless default. -->

---

## DLP changes workflow behavior

![Microsoft Purview](assets/icons/microsoft/microsoft-purview.svg)

An Agent 365 instance does not understand that Purview blocked a step.

The agent owner must monitor:

- incomplete downstream work;
- repeated attempts;
- user-facing failure behavior; and
- routing to the incident owner.

<!-- Notes: Blocking data can leave an agent workflow half-finished. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Choice | Benefit | Cost or limit | Use when |
|---|---|---|---|
| `Block` | Stops the matched interaction | Can leave an agent workflow incomplete | The workflow has an owned failure route |
| `Audit` | Lets the team observe the scoped match | Does not stop the interaction | Monitoring is the approved nonproduction control |

The data owner records one choice before simulation. The expected runtime result follows that
choice.

<!-- Notes: Do not describe Audit as prevention or Block as operationally free. -->

---

## Preview before turning on the policy

Configuration and simulation happen first. Post-propagation confirmation is a separate delivery window.

```text
Markdown coverage record
   ↓
Purview portal summary
   ↓
TestWithNotifications simulation
   ↓
scope and match review
   ↓
Enable
```

Stop if simulation finds another agent, group, label, location, or direction.

`deployment.propagationAllowanceHours` is the wait time for the enabled policy to reach the agent and test group. Schedule the next window after that wait.

<!-- Notes: The portal summary and simulation are the safe preview for this policy surface. -->

---

## DLP lifecycle across two delivery windows

![The Agent 365 DLP lifecycle confirms label rights, simulates approved scope, enables the policy, waits for propagation, checks one labelled match and one out-of-scope non-match, then reaches the delivery-owner checkpoint with scoped audit operations](assets/diagrams/purview-dlp-lifecycle.svg)

<!-- Notes: The red break is deliberate. Do not run the live checks before the recorded wait ends. -->

---

## Current audit operations

![Microsoft Purview](assets/icons/microsoft/microsoft-purview.svg)

```text
AIInvokeAgent
AIExecuteTool
AIInferenceCall
AIGuardrail
```

The saved audit query filters to one agent instance and prints no prompt, response, user identity, file name, URL, tool argument, or tool result.

<!-- Notes: Operational visibility does not require a content export. -->

---

<!-- _class: implementation -->

## Apply the Agent 365 data control

**Timebox: 240 minutes**

Review Purview data risk, classify one synthetic source, configure one Agent 365 DLP policy, and confirm the expected result. Do not retain interaction content.

<!-- Notes: Pause before label rights, policy enablement, and any restore. -->

---

## Implementation path

1. Resolve coverage, owner, label, source, action, and audit decisions.
2. Use **Compliance Data Administrator** for label and DLP work, **View-Only Audit Logs** in Purview and Exchange, and **AuditLogsQuery.Read.All** for Microsoft Graph Audit Search.
3. Run preflight against the approved tenant.
4. Enable and review Foundry Purview Data Security separately.
5. Confirm the approved label and explicit rights on the synthetic source.
6. Build the scoped Agent 365 DLP policy in simulation.
7. Review the matched scope, then enable.
8. Run one labelled synthetic interaction.

<!-- Notes: Keep Foundry coverage review separate from the Agent 365 policy deployment. -->

---

<!-- _class: decision -->

## Safety gates

- Every `__REQUIRED_*__` value is resolved.
- A focused route confirms the platform references, assignment scopes, `get_policy` allowlist, backend role ID and scope, successful read result, and denied-write result.
- A Compliance Data Administrator recorded the label resolution and DLP policy-name check.
- The Audit Search Graph token identifies the approved tenant and carries `AuditLogsQuery.Read.All`.
- Agent 365 and Foundry coverage are not conflated.
- The policy summary matches the approved instance and group.
- Simulation finds no unexpected target.
- No prompt, response, user, source, or raw audit content enters the repository.

<!-- Notes: Preflight names these conditions and refuses to pass unresolved decisions. -->

---

<!-- _class: implementation -->

## Intended path, non-match, and owner checkpoint

The synthetic item is already labelled; do not apply the label during the session.

Confirm the intended scoped result, an out-of-scope non-match, and the delivery-owner checkpoint.

Send the labelled synthetic item down the defined blocked interaction path.

**Expected**

- `Block`: the path does not complete.
- `Audit`: the path completes and the match is recorded.

For that interaction, confirm Agent 365 audit activity and record the output's label behavior.

Then replace only the test group with the configured out-of-scope test group alias.

Keep the agent, labelled item, direction, location, and action fixed. The policy must not report a match.

The delivery owner checks the configured propagation wait, both results, and the scoped audit event.

<!-- Notes: One scenario exercises the DLP decision, audit visibility, and label-inheritance gap. -->

---

## Stop on the wrong result

Stop when:

- another agent or group is affected;
- the outcome differs from `Block` or `Audit`;
- protected content appears outside the approved path;
- the audit event remains absent after the explicit Audit wait window recorded by the audit owner in the approved change record; or
- the output is treated as labelled when it is not.

Do not retain the interaction content to explain a failure.

<!-- Notes: Route the failure to the data, agent, and Purview owners. -->

---

## Live state

- One owned coverage record for product boundaries, DSPM, label, source access, and DLP
- Payload-free audit query and preflight

The data, information protection, agent, Foundry, and audit owners maintain their own boundary.

<!-- Notes: Saved summaries exclude customer content and raw activity. -->

---

## Manual restore

1. Return the DLP policy to `TestWithNotifications`.
2. Disable it after dependency review.
3. Remove the scoped agent and group before policy deletion.
4. Remove label rights or source sharing only after the data owner confirms that the current access inventory has no dependent Agent 365 instance or group.
5. Never delete a reused label.
6. Disable Foundry coverage or billing only after a separate dependency decision.

<!-- Notes: There is no broad delete script for shared Purview state. -->

---

## Recap

- Agent 365 and Foundry use distinct Purview control paths.
- The customer-owned review record records that split; the Agent 365 DLP policy does not govern Foundry.
- A label protects source access only when rights and publication are explicit.
- One narrow DLP policy governs the approved interaction.
- Audit visibility stays payload-free.
- Newly generated content needs its own label control.

<!-- Notes: End on the control boundaries the customer now owns. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: Keep the control in operation and carry the labelled data set into Session 10 evaluations. -->
