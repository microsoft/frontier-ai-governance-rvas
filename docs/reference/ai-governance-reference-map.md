# Microsoft AI Governance Reference Map

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Verify Microsoft Learn availability, licensing,
    product status, and customer applicability before delivery. This map is
    contextual guidance, not customer evidence or a deployment instruction.

This map is a reading route from public Microsoft guidance to the S0-S12 curriculum. Sources can explain a capability or shape a customer-owned backlog; they cannot prove a deployed or operating customer control.

## How to use this map

Use these four questions to read the curriculum artifacts:

| Lens | Delivery question | Curriculum consequence |
|---|---|---|
| **Policy** | What is permitted, who owns the decision, and what needs approval? | S0 establishes ownership; S4/S5 record admission and publication decisions. |
| **Control** | Which boundaries enforce the decision? | S1-S6 identify identity, data, platform, tool, and runtime paths. |
| **Visibility** | What signals show actual behavior and coverage limits? | S6, S7, and S10 route telemetry, evaluation, and operating-review work to customer owners. |
| **Proof** | Which reviewed references support a bounded decision and improvement? | S7-S12 retain decisions, limitations, exceptions, and the next roadmap. |

The sequence is continuous: S12 portfolio learning informs the next S0 baseline. A reviewed evidence record connects policy, controls, visibility, and a defensible decision.

## Phase translation

The business journey maps to the curriculum, but does not rename it:

| Business journey | AI Governance Platform phase | Typical sessions |
|---|---|---|
| Align use case and value | Govern | S0-S2 |
| Establish a safe foundation | Establish | S3-S5 |
| Build and validate | Assure | S6-S8 |
| Operate and scale | Operate | S9-S12 |

Microsoft Responsible AI principles (fairness; reliability and safety; privacy and security; inclusiveness; transparency; and accountability) give context for these questions. They are not an extra certification or framework-alignment claim in this curriculum.

## Reference map

### Policy, lifecycle, and runtime enforcement

| Source | Relevant sessions | What it can inform | Stability |
|---|---|---|---|
| [Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/what-is-foundry) | S0, S4, S7 | A customer-owned Foundry lifecycle or setup backlog. | Canonical Learn |
| [Foundry agent setup and network options](https://learn.microsoft.com/en-us/azure/foundry/how-to/configure-managed-network) | S3, S4 | Data-residency, capability-host, and network-isolation review questions. | Canonical Learn; verify availability |
| [Foundry quota and capacity](https://learn.microsoft.com/en-us/azure/ai-services/openai/quotas-limits) | S4, S10 | Capacity, regional allocation, cost owner, and budget questions. | Canonical Learn; verify service applicability |
| [Azure Policy](https://learn.microsoft.com/en-us/azure/governance/policy/overview) | S0, S3, S6 | Resource-governance baseline and ownership questions. | Canonical Learn |
| [Azure API Management AI Gateway](https://learn.microsoft.com/en-us/azure/api-management/genai-gateway-capabilities) | S3, S5, S6, S10 | Boundary enforcement, traffic controls, and telemetry routes. | Canonical Learn |
| [Microsoft Agent 365](https://learn.microsoft.com/en-us/microsoft-agent-365/overview) | S0, S1, S9, S12 | Fleet registry, lifecycle, access, and portfolio-record questions. | Canonical Learn |

Runtime enforcement turns identity, data, tool, API, runtime-safety, and
agent-governance decisions into operating controls. The customer must identify
the boundary and owner, review evidence, reconcile records, and operate the
result through its accountable processes. This material does not deploy,
configure, or prove the services above.

### Data governance and compliance

| Source | Relevant sessions | What it can inform | Stability |
|---|---|---|---|
| [Microsoft Purview](https://learn.microsoft.com/en-us/purview/purview) | S0, S2, S6, S9 | Data-governance and compliance setup questions. | Canonical Learn |
| [Data Security Posture Management](https://learn.microsoft.com/en-us/purview/data-security-posture-management-learn-about) | S2, S10 | Discovery and posture-review scope. `DSPM for AI` is the classic product label. | Canonical Learn |
| [Data Loss Prevention](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp) | S2, S5, S6 | Data-exposure and boundary-control backlog items. | Canonical Learn |
| [Sensitivity labels](https://learn.microsoft.com/en-us/purview/sensitivity-labels) | S2, S5 | Classification references for data-handling decisions. | Canonical Learn |
| [Purview Audit](https://learn.microsoft.com/en-us/purview/audit-solutions-overview) | S2, S9, S10 | Customer-held audit-reference and retention questions. | Canonical Learn |
| [eDiscovery](https://learn.microsoft.com/en-us/purview/edisc) | S2, S12 | Investigation and records-retention route. | Canonical Learn |
| [Compliance Manager](https://learn.microsoft.com/en-us/purview/compliance-manager) | S2, S12 | Compliance-management context; not a legal conclusion. | Canonical Learn |

### Model safety, evaluation, and adversarial learning

| Source | Relevant sessions | What it can inform | Stability |
|---|---|---|---|
| [Azure AI Content Safety](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/overview) | S4, S6, S7 | Safety-control and evaluation planning. | Canonical Learn |
| [Prompt Shields](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection) | S6, S8 | Prompt-injection context and customer-owned testing scope. | Canonical Learn |
| [Microsoft Foundry observability and evaluation](https://learn.microsoft.com/en-us/azure/foundry/concepts/observability) | S7, S10 | Evaluation, trace, monitoring, and coverage-planning context. | Canonical Learn |
| [Agent Evaluators for Generative AI](https://learn.microsoft.com/en-us/azure/foundry/concepts/evaluation-evaluators/agent-evaluators) | S7 | Named evaluator types and specific evaluation questions. | Canonical Learn; check preview status and use a GA or manual fallback for a production decision |
| [Fine-tune Microsoft Foundry models](https://learn.microsoft.com/en-us/azure/foundry/how-to/fine-tune-models) | S4, S7, S10, S12 | Fine-tuning decision criteria, pre/post comparison, and training versus inference-cost questions. | Canonical Learn; verify model and region support |
| [Azure Cost Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/overview-cost-management) | S10, S12 | Subscription-level cost attribution and portfolio planning. | Canonical Learn |
| [ASSERT announcement](https://devblogs.microsoft.com/foundry/build-2026-open-trust-stack-ai-agents/) | S7, S8 | Policy-driven evaluation and before/after mitigation thinking. | Contextual announcement; verify current project status |

ASSERT can inform policy-specific evaluation scenarios. A local result is not release approval, runtime proof, or control-effectiveness evidence; S7 keeps references and a decision, while S8 runs only authorized tests against a customer-owned non-production target.

### Observability, security, and identity

| Source | Relevant sessions | What it can inform | Stability |
|---|---|---|---|
| [Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/fundamentals/overview) | S6, S10 | Operating signal and alert-route planning. | Canonical Learn |
| [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) | S6, S7, S10 | Trace/telemetry correlation and coverage limits. | Canonical Learn |
| [Microsoft Foundry tracing and traces](https://learn.microsoft.com/en-us/azure/foundry/concepts/observability) | S7, S10 | Per-run trace, token usage, latency, and production-evaluation signal planning. | Canonical Learn; requires customer configuration |
| [Log Analytics](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview) | S6, S10 | Customer-owned log-analysis route. | Canonical Learn |
| [Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction) | S6, S8 | Security-posture and threat-protection context. | Canonical Learn |
| [Microsoft Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/microsoft-365-defender) | S6, S8 | Incident and response-owner routing. | Canonical Learn |
| [Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/sentinel-overview) | S6, S10 | SOC review and escalation context. | Canonical Learn |
| [Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/) | S1, S5, S6, S9 | Human and workload identity ownership. | Canonical Learn |
| [Azure RBAC](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview) | S1, S5, S6 | Least-privilege and authority-scope decisions. | Canonical Learn |
| [Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview) | S1, S6 | Conditional access posture and exception questions. | Canonical Learn |

## Maintenance and customer evidence

Review this page with the other `docs/reference/` sources quarterly and after major product announcements. Keep canonical Microsoft Learn links for stable documentation, and record a reviewed release or commit for open-source claims. Before citing a source in an engagement, verify its availability and status.

Documentation, templates, simulator results, and capability pages are not customer evidence. Customer evidence is a reviewed, customer-owned record with scope, owner, limitations, and a decision.
