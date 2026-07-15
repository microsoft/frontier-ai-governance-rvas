# Facilitate a co-delivery working session

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Confirm current capability availability in the [Governance capability guide](../reference/governance-capability-guide.md) before using a product in a pilot.

Use this 90-minute method for any core S0–S6 working session and the optional
S7 adoption workshop. It keeps the
facilitator in charge of the method and the customer in charge of actions,
evidence, and decisions. Run the session against one bounded pilot question;
do not turn it into a configuration workshop or an unbounded product tour.

## Activity model

| Step | Time | Facilitate | Customer does | Leave with |
|---|---:|---|---|---|
| Set the room | 10 min | State the pilot question, intended control state, evidence location, decision owner, and stop condition. Confirm the roles below. | Confirm scope, safe posture, and who can make or accept the decision. | A shared working agreement. |
| Orient on the pilot | 10 min | Restate the use case, representative input or scenario, expected signal, and the evidence needed to answer the question. | Show the approved pilot context and identify the evidence source. | A testable question and evidence plan. |
| Customer-led action and review | 30 min | Read the agreed question aloud; keep the work to the safe posture; ask for the output and its context. | Perform the action or retrieve the existing result in the customer environment; review it with the relevant specialist. | A result, a verified no-result, or a recorded blocker. |
| Interpret together | 15 min | Separate observed fact, inference, and recommendation. Compare the result with the expected signal and evidence boundary. | Explain operational meaning, constraints, and impact. | A shared interpretation and control state. |
| Decide | 15 min | Present the available decisions and record the chosen one, owner, due date, and review point. | Accept, defer, or reject the next action through the appropriate customer authority. | A customer-owned decision record. |
| Hand over | 10 min | Read back the evidence reference, decision, open items, and next session dependency. | Retain the record and confirm the next owner. | A handoff with a dated next action. |

## Roles in the room

| Role | During the session | Cannot be delegated to the facilitator |
|---|---|---|
| Facilitator | Runs the timebox, maintains the evidence boundary, tests the decision wording, and records the handoff. | Performing customer actions, approving changes, accepting risk, or claiming a control is deployed. |
| Customer activity owner | Performs or retrieves the pilot action and explains its operational context. | Giving decision authority to an observer. |
| Evidence owner | Points to the authoritative record, verifies its retention and classification, and captures references. | Replacing missing evidence with a template, screenshot without context, or facilitator notes. |
| Decision owner | Chooses the next action and accepts a residual risk, exception, or deferral where applicable. | Treating an unresolved dependency as a pass. |
| Specialist reviewer | Interprets identity, data, security, platform, or assurance implications for the pilot. | Making a customer decision outside their authority. |

One person may hold several roles. If no decision owner is present, complete only
the action and interpretation steps; mark the decision **deferred** and assign
the owner and review date.

## Evidence boundary

Capture only what allows a later reviewer to understand and verify the
decision:

- pilot question, scope, safe posture, and date;
- authoritative evidence reference, observed result or no-result, and the
  reviewer who interpreted it;
- control state: `designed`, `report_only_deployed`, `observed`,
  `approved_for_enforcement`, `enforced`, `accepted_risk`, or `blocked`;
- decision, owner, next action, and review date.

Keep customer data, credentials, raw exports, and tenant-specific configuration
in the customer's approved records system. A sample, offline mock, product
demonstration, or facilitator-created note is preparation material, not proof
that a customer control is operating. This method neither applies a change nor
promotes a control to enforcement.

## Outcome handling

| Outcome | Say and record | Next move |
|---|---|---|
| Result supports the question | Record the evidence reference, interpretation, control state, and decision. | Hand over any observation, remediation, or production-readiness work to the customer owner. |
| No result | Record that the agreed action or review completed, the source and scope checked, the date, and the reviewer’s interpretation. Do not label absence of a result as a pass without the expected-signal context. | Decide whether to observe longer, adjust the pilot question, or close the item with the stated residual risk. |
| Unsupported | Record the product or capability limitation as observed or documented, without inventing a workaround or product commitment. | Choose an alternative customer control, defer pending product review, or add an owned backlog item. |
| Blocked | Record the missing dependency, safe stop point, owner, target date, and effect on the session sequence. | Stop the dependent action; continue only with an unblocked activity or reschedule. Do not substitute a production action or fabricated evidence. |

## Product guidance as supporting source

Use the official product guidance to validate terminology, feature availability,
and supported patterns before the customer chooses an action. It is supporting
context for the pilot; it does not replace customer evidence or prescribe
portal click paths.

- [Microsoft Entra Agent ID guidance](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id)
- [Microsoft Purview for AI guidance](https://learn.microsoft.com/en-us/purview/ai-microsoft-purview)
- [Defender AI security posture management guidance](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-security-posture)
- [Microsoft Foundry observability and evaluation guidance](https://learn.microsoft.com/en-us/azure/foundry/concepts/observability)
- [Azure AI Content Safety Prompt Shields guidance](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection)

## Facilitator close-out check

- [ ] The pilot question, safe posture, and stop condition were explicit.
- [ ] The customer performed or reviewed the action; the facilitator did not substitute an action or evidence.
- [ ] The record distinguishes result, no-result, unsupported, and blocked.
- [ ] A customer decision owner accepted the next action, or a deferred decision has an owner and review date.
- [ ] The handoff names the evidence reference, control state, next owner, and session dependency.
