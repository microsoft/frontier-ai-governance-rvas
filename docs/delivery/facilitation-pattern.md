# Facilitate a working session

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Confirm current capability availability in the [Governance capability guide](../reference/governance-capability-guide.md) before using a product in a pilot.

Use this 90-minute method for any selected S0-S12 working session. The facilitator runs the method; the customer acts, keeps evidence, and decides.

Run the session against one bounded pilot question. Do not turn it into a configuration workshop or a product tour.
Complete [Check whether a session is ready](session-readiness.md) before booking
the session.

## How the session tabs work

Use the session cards in this order:

| Card | Use it for |
|---|---|
| Prepare | Confirm the outcome, prerequisites, and records the customer keeps. |
| Concepts | Explain the terms and product context the room needs. |
| Technical decisions | Start with the Azure/Microsoft default, agree on its acceptance evidence, and record any equivalent-control exception. |
| Practical workshop | Run the customer activity and record the decision, evidence references, ownership, and next review. |

Observe the customer-led practical workshop, then focus the room on what the
result means and what to decide.

## Activity model

| Step | Time | Facilitate | Customer does | Leave with |
|---|---:|---|---|---|
| Set the room | 10 min | State the pilot question, Azure/Microsoft default, evidence location, decision owner, and stop condition. Confirm the roles below. | Confirm scope, safe posture, and who can make or accept the decision. | A shared working agreement. |
| Orient on the pilot | 10 min | Restate the use case, representative input or scenario, expected signal, and evidence needed to answer the question. | Show the approved pilot context and identify the evidence source. | A testable question and evidence plan. |
| Customer-led action and review | 30 min | Read the agreed question aloud. Keep the work in the safe posture. Ask for the output and its context. | Perform the action or retrieve the existing result in the customer environment. Review it with the relevant specialist. | A result, a verified no-result, or a recorded blocker. |
| Interpret together | 15 min | Separate fact, inference, and recommendation. Compare the result with the expected signal and evidence boundary. | Explain operational meaning, constraints, and impact. | A shared interpretation and control state. |
| Decide | 15 min | Present the available decisions and record the chosen one, exception if any, owner, due date, acceptance evidence, and review point. | Accept, defer, reject, or route the next action through the right customer authority. | A customer-owned decision artifact. |
| Hand over | 10 min | Read back the evidence reference, decision, open items, acceptance owner, and next session dependency. | Keep the record and confirm the next owner. | A handoff with a dated next action. |

## Roles in the room

| Role | During the session | Cannot be delegated to the facilitator |
|---|---|---|
| Facilitator | Runs the timebox, protects the evidence boundary, tests the decision wording, and records the handoff. | Performing customer actions, approving changes, accepting risk, or claiming a control is deployed. |
| Customer activity owner | Performs or retrieves the pilot action and explains its operational context. | Giving decision authority to an observer. |
| Evidence owner | Points to the customer record, verifies retention and classification, and captures references. | Replacing missing evidence with a template, decontextualized screenshot, or facilitator notes. |
| Decision owner | Chooses the next action and accepts a residual risk, exception, or deferral where applicable. | Treating an unresolved dependency as a pass. |
| Specialist reviewer | Interprets identity, data, security, platform, or assurance implications for the pilot. | Making a customer decision outside their authority. |

One person may hold several roles. If no decision owner is present, complete only the action and interpretation steps. Mark the decision **deferred** and assign the owner and review date.

## Evidence boundary

Capture what a later reviewer needs to verify the decision:

- pilot question, scope, safe posture, and date;
- customer evidence reference, observed result or no-result, and the reviewer who interpreted it;
- control state: `designed`, `report_only_deployed`, `observed`, `approved_for_enforcement`, `enforced`, `accepted_risk`, or `blocked`;
- decision, owner, next action, and review date.

Keep customer data, credentials, raw exports, and tenant-specific configuration in the customer's approved records system. Samples, offline mocks, product demonstrations, and facilitator notes are preparation aids, not operating-control proof. This method neither applies a change nor promotes a control to enforcement.

## Outcome handling

| Outcome | Say and record | Next move |
|---|---|---|
| Result supports the question | Record the evidence reference, interpretation, control state, and decision. | Hand over observation, remediation, or production-readiness work to the customer owner. |
| No result | Record the completed action or review, source and scope checked, date, and interpretation. Do not call absence of a result a pass without expected-signal context. | Observe longer, adjust the pilot question, or close with stated residual risk. |
| Unsupported | Record the product or capability limit as observed or documented. Do not invent a workaround or product commitment. | Choose another customer control, defer pending product review, or add an owned backlog item. |
| Blocked | Record the missing dependency, safe stop point, owner, target event, and effect on sequence. | Stop the dependent action; continue only with unblocked work or reschedule. Do not substitute a production action or fabricated evidence. |

## Product guidance as supporting source

Use official product guidance to confirm terminology, feature availability, and supported patterns before the customer chooses an action. It supports the pilot. It does not replace customer evidence or prescribe portal click paths.

- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md)
- [Microsoft Entra Agent ID guidance](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id)
- [Microsoft Purview for AI guidance](https://learn.microsoft.com/en-us/purview/ai-microsoft-purview)
- [Defender AI security posture management guidance](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-security-posture)
- [Microsoft Foundry observability and evaluation guidance](https://learn.microsoft.com/en-us/azure/foundry/concepts/observability)
- [Azure AI Content Safety Prompt Shields guidance](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection)

## Facilitator close-out check

- [ ] The pilot question, safe posture, and stop condition were explicit.
- [ ] The customer performed or reviewed the action. The facilitator did not substitute an action or evidence.
- [ ] The record separates result, no-result, unsupported, and blocked.
- [ ] A customer decision owner accepted the next action, or a deferred decision has an owner and review date.
- [ ] The handoff names the evidence reference, control state, next owner, and session dependency.
