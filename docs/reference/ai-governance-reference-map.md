# Microsoft AI Governance Reference Map

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Verify Microsoft Learn availability, licensing,
    product status, and customer applicability before delivery. This map is
    contextual guidance, not customer evidence or a deployment instruction.

This map connects public Microsoft guidance to the S0-S12 curriculum. It is a
curated reading route: a source can explain a capability or inform a
customer-owned implementation backlog, but it cannot prove that a customer
control is deployed or operating.

## How to use this map

Use the four questions below to interpret the curriculum artifacts:

| Lens | Delivery question | Curriculum consequence |
|---|---|---|
| **Policy** | What is permitted, who owns the decision, and what needs approval? | S0 establishes ownership; S4/S5 record admission and publication decisions. |
| **Control** | Which proportionate boundaries enforce the decision? | S1-S6 and, where applicable, S10 identify identity, data, platform, tool, runtime, and in-process paths. |
| **Visibility** | What signals reveal actual behavior and coverage limits? | S6, S7, and S11 route telemetry, evaluation, and operating-review work to customer owners. |
| **Proof** | Which reviewed references support a bounded decision and improvement? | S7-S12 retain decisions, limitations, exceptions, and the next roadmap. |

The sequence is continuous: S12 portfolio learning informs the next S0
baseline. A policy without a control is aspirational; a control without
visibility is blind; visibility without a reviewed evidence record cannot
support a defensible decision.

## Phase translation

The business journey maps to, but does not rename, the curriculum:

| Business journey | RVAS AI Governance phase | Typical sessions |
|---|---|---|
| Align use case and value | Govern | S0-S2 |
| Establish a safe foundation | Establish | S3-S5 |
| Build and validate | Assure | S6-S8 |
| Operate and scale | Operate | S9-S12 |

Microsoft Responsible AI principles—fairness; reliability and safety; privacy
and security; inclusiveness; transparency; and accountability—are useful
context for these questions. They are not an additional certification or
framework-alignment claim in this curriculum.

## Reference map

### Policy, lifecycle, and runtime enforcement

| Source | Relevant sessions | What it can inform | Stability |
|---|---|---|---|
| [Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/what-is-foundry) | S0, S4, S7 | A customer-owned Foundry lifecycle or implementation-path backlog. | Canonical Learn |
| [Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/overview) | S0, S3, S6 | Resource-governance baseline and ownership questions. | Canonical Learn |
| [Azure API Management AI Gateway](https://learn.microsoft.com/en-us/azure/api-management/genai-gateway-capabilities) | S3, S5, S6, S11 | Boundary enforcement, traffic controls, and telemetry routes. | Canonical Learn |
| [Microsoft Agent 365](https://learn.microsoft.com/en-us/microsoft-agent-365/overview) | S0, S1, S9, S12 | Fleet registry, lifecycle, access, and portfolio-record questions. | Canonical Learn |

Runtime enforcement is cross-cutting, not a separate session. It operationalizes
the decisions made for identity, data, tools, APIs, runtime safety, and agent
governance. S3/S5 identify a boundary and owner; S6 reviews evidence for that
boundary; S9/S11 reconcile and operate the resulting records. None of those
sessions deploys, configures, or proves the services above.

### Data governance and compliance

| Source | Relevant sessions | What it can inform | Stability |
|---|---|---|---|
| [Microsoft Purview](https://learn.microsoft.com/en-us/purview/purview) | S0, S2, S6, S9 | Data-governance and compliance implementation-path questions. | Canonical Learn |
| [DSPM for AI](https://learn.microsoft.com/en-us/purview/data-security-posture-management-learn-about) | S2, S11 | Discovery and posture-review scope. | Canonical Learn |
| [Data Loss Prevention](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp) | S2, S5, S6 | Data-exposure and boundary-control backlog items. | Canonical Learn |
| [Sensitivity labels](https://learn.microsoft.com/en-us/purview/sensitivity-labels) | S2, S5 | Classification references for data-handling decisions. | Canonical Learn |
| [Purview Audit](https://learn.microsoft.com/en-us/purview/audit-solutions-overview) | S2, S9, S11 | Customer-held audit-reference and retention questions. | Canonical Learn |
| [eDiscovery](https://learn.microsoft.com/en-us/purview/edisc) | S2, S12 | Investigation and records-retention route. | Canonical Learn |
| [Compliance Manager](https://learn.microsoft.com/en-us/purview/compliance-manager) | S2, S12 | Compliance-management context; not a conformity conclusion. | Canonical Learn |

### Model safety, evaluation, and adversarial learning

| Source | Relevant sessions | What it can inform | Stability |
|---|---|---|---|
| [Azure AI Content Safety](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/overview) | S4, S6, S7 | Safety-control and evaluation planning. | Canonical Learn |
| [Prompt Shields](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection) | S6, S8 | Prompt-injection context and customer-owned testing scope. | Canonical Learn |
| [Microsoft Foundry observability and evaluation](https://learn.microsoft.com/en-us/azure/foundry/concepts/observability) | S7, S11 | Evaluation, trace, monitoring, and coverage-planning context. | Canonical Learn |
| [ASSERT announcement](https://devblogs.microsoft.com/foundry/build-2026-open-trust-stack-ai-agents/) | S7, S8 | Policy-driven evaluation and before/after mitigation thinking. | Contextual announcement; verify current project status |

ASSERT is useful where a customer wants policy-specific evaluation scenarios,
but it does not turn a local result into release approval, runtime proof, or
control effectiveness. S7 retains references and a decision; S8 performs only
authorized testing in a customer-owned non-production target.

### Observability, security, and identity

| Source | Relevant sessions | What it can inform | Stability |
|---|---|---|---|
| [Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/fundamentals/overview) | S6, S11 | Operating signal and alert-route planning. | Canonical Learn |
| [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) | S6, S7, S11 | Trace/telemetry correlation and coverage limits. | Canonical Learn |
| [Log Analytics](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview) | S6, S11 | Customer-owned log-analysis route. | Canonical Learn |
| [Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction) | S6, S8 | Security-posture and threat-protection context. | Canonical Learn |
| [Microsoft Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender) | S6, S8 | Incident and response-owner routing. | Canonical Learn |
| [Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/sentinel-overview) | S6, S11 | SOC review and escalation context. | Canonical Learn |
| [Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/) | S1, S5, S6, S9 | Human and workload identity ownership. | Canonical Learn |
| [Azure RBAC](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview) | S1, S5, S6 | Least-privilege and authority-scope decisions. | Canonical Learn |
| [Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) | S1, S6 | Conditional access posture and exception questions. | Canonical Learn |

### Agent governance and portable controls

| Source | Relevant sessions | What it can inform | Stability |
|---|---|---|---|
| [Agent Control Specification](https://microsoft.github.io/agent-governance-toolkit/packages/agent-control-specification/) | S5, S10 | Portable control-checkpoint concepts for a future engineering assessment. | Open source; capture a reviewed release or commit before delivery |
| [Agent Governance Toolkit](https://microsoft.github.io/agent-governance-toolkit/) | S10 | In-process policy and audit concepts. | Open source; S10 uses [pinned source `b680c49`](https://github.com/microsoft/agent-governance-toolkit/tree/b680c49cc956727c5249771ddba7ee21a635a676) |

Agent 365 and a portable control layer solve different problems. A fleet control
plane helps discover, inventory, and steward agents; an in-process control can
evaluate a defined checkpoint before a tool action. Neither is proof that the
other is installed or effective, and S10 remains an applicability-based,
offline decision session.

## Maintenance and evidence boundary

Review this page quarterly with the other `docs/reference/` sources and after
material product announcements. Preserve canonical Microsoft Learn links for
stable documentation; record a reviewed release or commit for open-source
claims. Before citing any source in a customer engagement, verify its current
availability and status.

Documentation, a template, a simulator result, or a product capability page is
not customer evidence. Customer evidence remains a reviewed, customer-owned
record with scope, owner, limitations, and a decision.
