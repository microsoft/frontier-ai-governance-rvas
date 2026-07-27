# Microsoft platform governance playbook

Use this playbook to keep every S0-S13 module practical. A module should start
with the Microsoft platform path, not with abstract governance language.

## The module shape

Every session must answer these four questions:

1. **Which Microsoft control is the default?**
2. **What decision does the customer make?**
3. **What proves the decision is ready to hand off?**
4. **Who implements or operates it next?**

Use this structure in session pages, decks, runbooks, and templates.

| Part | Required content |
|---|---|
| Microsoft default | The recommended Microsoft product, control, or record source for the session. |
| Decision tree | Simple if/then choices that lead to approve, defer, reject, or route. |
| Platform checks | The records, settings, signals, or support limits the customer must inspect. |
| Acceptance tests | The conditions that must be true before the decision can move forward. |
| Exception | Equivalent control, owner, evidence location, reason, target date, and review trigger. |
| Handoff | The named customer process or team that implements, operates, or reviews the next step. |

## Default Microsoft paths

| Session | Lead with this Microsoft path |
|---|---|
| S0 | Cloud Adoption Framework for AI, Well-Architected Framework for AI, and AI Center of Excellence guidance. |
| S1 | Microsoft Entra Agent ID, Entra workload identities, Conditional Access, Azure RBAC, and Agent 365 where available. |
| S2 | Microsoft Purview Data Security Posture Management, Data Loss Prevention, sensitivity labels, audit, and eDiscovery. |
| S3 | Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway or Citadel-aligned gateway, private networking, and Azure Monitor. |
| S4 | Microsoft Foundry Agent Service, Copilot Studio, Microsoft 365 Copilot extensibility, or a custom Azure app path. |
| S5 | Azure API Center, Azure API Management, Entra/JWT, access contracts, connector governance, and MCP publication controls. |
| S6 | Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Sentinel, and Application Insights. |
| S7 | Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing where applicable. |
| S8 | AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Defender, and SOC remediation routes. |
| S9 | Microsoft Agent 365, Microsoft Entra Agent ID, Azure API Center, and platform telemetry. |
| S10 | Agent Governance Toolkit only when gateway controls cannot make the needed in-process decision. |
| S11 | Microsoft Foundry observability, Azure Monitor, Application Insights, Log Analytics, Azure Cost Management, and FinOps Toolkit. |
| S12 | Microsoft LLMOps lifecycle: data curation, experimentation, evaluation, validate/deploy, inference, monitor, and feedback/data collection. |
| S13 | Agent 365 and control-plane records, Azure Cost Management, operating evidence, and the S0 re-baseline. |

## Editing rules

Write less about limits and more about action.

| Replace | With |
|---|---|
| "This does not prove..." | "Accepted when..." |
| "Record the gap." | "Create this backlog item: owner, acceptance test, target date." |
| "Customer-owned evidence reference." | The specific record: Entra record, Purview finding, Foundry evaluation, API Center entry, Azure Monitor alert, and so on. |
| Repeated boundary warnings | One short boundary note per page. |
| Generic options | Microsoft default first, then exception criteria. |

## Exception rule

An exception is valid only when all fields are present:

| Field | Meaning |
|---|---|
| Reason | Why the Microsoft default does not fit. |
| Equivalent control | The control or process replacing the default. |
| Owner | The person or team accountable for the exception. |
| Evidence location | Where the customer keeps proof of the exception. |
| Acceptance test | What must be true for the exception to be accepted. |
| Target date | When the exception is resolved or reviewed. |
| Review trigger | The event that forces re-review, such as production promotion, product availability, material change, or audit. |

## Acceptance-test pattern

Every template should include this row shape:

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| | | | | | | |

Keep sensitive data out of this repository. Store customer identifiers,
credentials, prompt text, model outputs, telemetry exports, and configuration in
customer-approved systems only.
