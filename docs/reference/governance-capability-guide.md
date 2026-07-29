# Governance capability guide

Map each AI Governance session to Microsoft capabilities with this guide. Before delivery, check the linked documentation, tenant licensing, region support, and customer fit.

## Capabilities by governance domain

| Domain and session | Microsoft capabilities | What the facilitator uses them for | Availability to confirm |
|---|---|---|---|
| Operating model · S0 | Cloud Adoption Framework for AI, Well-Architected Framework for AI, AI Center of Excellence guidance | Ownership model, first blocker, and technical action routing. | Current guidance. |
| Identity · S1 | Microsoft Entra Agent ID, Conditional Access, Identity Protection, Agent 365 | Agent inventory, sponsorship, lifecycle, and access posture. | Agent 365 licensing plus Agent ID and Conditional Access coverage. |
| Data · S2 | Microsoft Purview Data Security Posture Management, DLP, audit, eDiscovery, and information protection | Data exposure findings, DLP testing, and retained compliance evidence. | Licensing and tenant support. |
| Platform & trust boundaries · S3 | Azure landing-zone, network, gateway, monitoring, and security capabilities | Customer-owned platform path and trust-boundary decision. | Region, network, feature, and ownership availability. |
| Engineering & admission · S4 | Microsoft Foundry Agent Service, Copilot Studio / Power Platform governance, Microsoft 365 Copilot declarative agents, Entra identity/RBAC/Agent ID, Foundry evaluation and observability, Azure Monitor / Application Insights, Content Safety, Agent 365, API Center, and customer engineering/change processes | Product-specific implementation path, model choice, fine-tuning governance, latency budget, token-cost estimate, rollout decision, admission, and material-change review. | Tenant licensing, region, feature availability, approved engineering path, and customer change authority. |
| Tool/API/MCP governance · S5 | API catalog, gateway, identity, supplier-interface, and lifecycle capabilities | Controlled publication, authority, third-party interface visibility, and withdrawal decisions. | Connector, protocol, supplier, and tenant support. |
| Runtime assurance · S6 | Defender for Cloud AI-SPM, Agent 365 agent security, Azure AI Content Safety, Azure Monitor / Application Insights | Security posture, threat signals, runtime safety, gateway correlation, and response ownership. | Agent 365 licensing for agent-level posture; region, telemetry, and feature availability. |
| Evaluation & release assurance · S7 | Microsoft Foundry evaluations, agent evaluators, cloud evaluation, tracing, continuous evaluation where applicable, and CI/CD integration | Customer-owned evaluation-plan review, threshold governance, run record interpretation, and release decision. | Individual evaluator status; use a GA evaluator or manual review for a production decision. |
| Adversarial testing · S8 | PyRIT and the AI Red Teaming Agent | Authorized test scope, findings, and remediation evidence. | Supported Foundry target, Azure tool path, region, and approved target. |
| Control plane & lifecycle · S9 | Microsoft Agent 365, Entra Agent ID, API Center, platform telemetry | Reconcile agent, tool, identity, ownership, and lifecycle records. | Agent 365 licensing and connector status. |
| Operate, monitor & FinOps · S10 | Customer-held operational, security, quality, and cost evidence; Azure Monitor / Application Insights; Foundry observability; Azure Cost Management and FinOps Toolkit where used | Operating review, quality/latency/cost drift, cost accountability, and remediation cadence. | Evidence coverage, attribution limits, and owner availability. |
| LLM operations · S11 | Customer-held model, prompt, change, incident, and lifecycle records; Microsoft Foundry model and deployment context where used | Provider-neutral model and prompt lifecycle decisions, material-change routes, operational ownership, and deprecation/retirement backlog. | Provider capability, model availability, region, quota, licensing, contract, and customer-change-process fit. |
| Portfolio governance · S12 | Customer-held governance, risk, supplier, lifecycle, and portfolio records | Portfolio decision, exception review, supplier-governance gaps, decommissioning backlog, and next roadmap. | Decision authority and records availability. |

## Implementation pathway taxonomy

Each session should turn evidence review into an implementation pathway: a customer-owned backlog and decision aid, not an instruction to deploy, configure, publish, grant access, or approve production use.

References should point to customer-held records. Do not store customer prompts, outputs, telemetry, credentials, contracts, audit evidence, or regulated records in the curriculum repository. Record only the customer reference, owner, gap, decision, review date, retention or refresh treatment, and handoff.

Use the same row shape across sessions:

| Field | Purpose |
|---|---|
| Implementation pathway or backlog item | The next setup, configuration, review, operating, or portfolio decision the session enables. |
| Applicability | `applies`, `does not apply`, `unknown`, or `customer process required`. Applicability does not mean the customer must deploy it. |
| Session recommendation | Recommended next path, defer, reject, investigate, accept risk, or route elsewhere. |
| Confidence and assumptions | Why the evidence reviewed in this session supports the recommendation. |
| Evidence reference or gap | Customer-held record reference, nothing found, tool limitation, blocker, or missing prerequisite. |
| Owner | Named business, engineering, platform, security, identity, data, service, cost, or portfolio owner. |
| Later route | Follow-on session or customer architecture, security, supplier-risk, procurement, change, release, support, incident, rollback, retirement, decommissioning, or production-approval process. |
| Boundary | What the session does not configure, deploy, prove, approve, certify, or legally determine. |

Filter these Microsoft capability categories to the session:

| Category | Typical implementation questions |
|---|---|
| Operating model and change process | Who owns the decision, cadence, roadmap, exception route, change process, and production approval? |
| Entra identity and Agent ID | Which human sponsor, Agent ID, workload identity, RBAC, Conditional Access, OBO, or lifecycle review is needed? |
| Purview and data governance | Which DSPM, DLP, label, audit, eDiscovery, retention, or investigation capability applies? |
| Platform, gateway, and API Center | Which landing-zone, network, gateway, API Center, access-contract, telemetry, or platform-owner backlog item is needed? |
| Third-party and supplier governance | Which model, tool, connector, data source, managed service, contract, supplier-risk, security, procurement, material-change, incident, or withdrawal route needs customer review? |
| Copilot Studio and Power Platform | Which environment, Managed Environment, DLP, connector, solution, ALM, publication, or monitoring decision applies? |
| Microsoft Foundry Agent Service | Which project, model, agent type, instructions/code package, tools, identity, observability, evaluation, or publication item applies? |
| Model selection and fine-tuning | Which model fits capability, cost, latency, and data-residency needs? Is fine-tuning justified, who owns training-data review, and which comparison is required? |
| Model and prompt operations | Which approved model/provider and prompt or system-instruction references, versioning method, human approval point, material-change route, lifecycle owner, incident/rollback path, and deprecation route apply? |
| Quality measurement and threshold governance | Which dimensions and evaluators apply, which option works everywhere or requires Foundry, and who approves thresholds and owns regressions? |
| Latency budgeting | Which component targets, attribution limits, regression owner, and telemetry reference apply? |
| Token cost and FinOps | Which tier, cost owner, allocation approach, quota or capacity consideration, and spend-decision route apply? |
| Staged rollout governance | Which agent-engineering, runtime, evaluation, red-team, and control-plane references are assembled, and who is the customer change authority for promotion? |
| Microsoft 365 Copilot extensibility | Which declarative-agent instructions, knowledge, actions, capabilities, metadata, distribution, or tenant-governance item applies? |
| Runtime safety and SOC operations | Which Content Safety, prompt shield, gateway policy, runtime-control, alert, SOC contact, or remediation route applies? |
| Evaluation and observability | Which Foundry evaluation, evaluator, run record, trace, release threshold, or Application Insights/OpenTelemetry item applies? |
| Catalog and lifecycle | Which Agent 365, Entra Agent ID, API Center, registry, steward, material-change, retirement, or recurrence item applies? |
| FinOps and operating evidence | Which cost owner, allocation, Azure Cost Management, FinOps Toolkit, operational review, or remediation-validation item applies? |
| Customer SDLC and release | Which architecture/security review, CI/CD gate, release, rollback, verification, incident, decommissioning, or production-approval process owns execution? |

Supplier governance is an optional or future gap unless the customer already has the process and records ready. For now, route supplier questions through agent admission, interface governance, provider/model lifecycle, and portfolio exceptions. Do not present this curriculum as a substitute for legal, procurement, compliance, privacy, or formal supplier-risk review.

## The capability map

![Microsoft Entra Agent ID, Microsoft Purview, security controls, evaluations, and adversarial testing records inform Microsoft Agent 365, with the operating model beneath the entire governance view.](../assets/diagrams/landscape.svg)

## Product-status notes

- Microsoft Agent 365 licensing is an early identity, runtime, and control-plane check. Agent-level security posture and some Entra agent-governance capabilities require it; availability varies by workload and tenant.
- Use Microsoft Purview Data Security Posture Management. `DSPM for AI` is the classic product label and should not be the default delivery path.
- The `azure-ai-evaluation` SDK is generally available. Individual agent evaluators, cloud evaluation, and continuous-evaluation features can vary. Do not use a preview-only evaluator as the sole automated production gate; use a GA evaluator or a customer-owned manual review. Evaluation references customer-owned evaluation work. They do not run a live evaluator or create a CI/CD gate.
- Foundry fine-tuning is available for supported models and can vary by model, region, and feature. Verify support before you recommend a fine-tuning path or evaluation integration.
- Foundry billing and project-level cost attribution may have scope limits. Confirm available views before you use them in a FinOps recommendation.
- ASSERT policy-driven evaluation is contextual Build 2026 guidance. Verify its current project and preview status before you cite it in a customer backlog.
- Microsoft Foundry Agent Service supports prompt agents, hosted agents, and existing external agents through the Responses API. S4 uses this only for implementation-path and backlog planning, not agent creation or deployment.
- Copilot Studio agents are governed through Power Platform and Microsoft 365 controls such as environments, data policies, publication controls, audit, and tenant administration. Confirm environment, DLP, connector, ALM, and licensing requirements before you recommend that path.
- Microsoft 365 Copilot declarative agents are configured through instructions, knowledge, actions, capabilities, and app metadata. Confirm the selected authoring tool, admin distribution route, and tenant controls before delivery.
- PyRIT is open source. Before selecting the AI Red Teaming Agent, confirm that the target is a supported Foundry workload, its tools are supported, and the region supports the required cloud run. Use PyRIT or manual testing where it does not fit.
- Foundry Citadel Platform is a reference architecture. AI Hub Gateway and Azure AI Landing Zones are accelerators with their own deployment guidance.

## Framework alignment

The curriculum produces practical evidence that may support NIST AI RMF, ISO/IEC 42001, and EU AI Act work. This illustrative mapping does not replace customer responsibility for risk classification, legal interpretation, supplier due diligence, compliance decisions, or formal conformity assessment.

| Session | NIST AI RMF | ISO/IEC 42001 | EU AI Act |
|---|---|---|---|
| S0 | Govern, Map | Policies and roles | Art. 9, 17 |
| S1 | Govern, Map, Manage | Lifecycle and access | Art. 12, 14, 15 |
| S2 | Map, Manage | Data and impact | Art. 10, 12 |
| S3 | Govern, Map, Manage | Resources, operations, and controls | Art. 9, 12, 15 |
| S4 | Govern, Map, Measure | Lifecycle, competence, and operations | Art. 9, 12, 15 |
| S5 | Govern, Map, Manage | Supplier, interface, and lifecycle controls | Art. 12, 14, 15 |
| S6 | Measure, Manage | Security and operations | Art. 15 |
| S7 | Measure, Manage | Validation and operations | Art. 9, 12, 15, 72 |
| S8 | Govern, Measure, Manage | Roles, lifecycle, operations | Art. 9, 12, 15 |
| S9 | Govern, Map, Manage | Policies, roles, operations | Art. 12, 72 |
| S10 | Govern, Measure, Manage | Monitoring, measurement, and improvement | Art. 12, 15, 72 |
| S11 | Govern, Map, Measure, Manage | Operational planning and lifecycle change | Art. 9, 12, 15 |
| S12 | Govern, Map, Measure, Manage | Leadership, performance, and improvement | Art. 9, 17, 72 |

## Sources

- [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework)
- [ISO/IEC 42001](https://www.iso.org/standard/81230.html)
- [EU AI Act](https://eur-lex.europa.eu/eli/reg/2024/1689/oj)
- [Cloud Adoption Framework for AI strategy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ai/strategy)
- [Microsoft Agent 365](https://learn.microsoft.com/en-us/microsoft-agent-365/overview)
- [Microsoft Entra Agent ID](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id)
- [Manage owners and sponsors for agent identities](https://learn.microsoft.com/en-us/entra/agent-id/manage-owners-sponsors-agents)
- [Microsoft Purview for AI](https://learn.microsoft.com/en-us/purview/ai-microsoft-purview)
- [Microsoft Purview Data Security Posture Management](https://learn.microsoft.com/en-us/purview/data-security-posture-management-learn-about)
- [Azure API Center overview](https://learn.microsoft.com/en-us/azure/api-center/overview)
- [Defender AI security posture management](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-security-posture)
- [Transition agent security to Agent 365](https://learn.microsoft.com/en-us/defender-xdr/security-for-ai/transition-agent-security-to-agent-365)
- [Azure AI Content Safety Prompt Shields](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection)
- [Application Insights OpenTelemetry observability overview](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [Microsoft Foundry Agent Service](https://learn.microsoft.com/en-us/azure/foundry/agents/overview)
- [Run evaluations from the Microsoft Foundry portal](https://learn.microsoft.com/en-us/azure/foundry/how-to/evaluate-generative-ai-app)
- [Agent Evaluators for Generative AI](https://learn.microsoft.com/en-us/azure/foundry/concepts/evaluation-evaluators/agent-evaluators)
- [Cloud Evaluation with the Microsoft Foundry SDK](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/cloud-evaluation)
- [Microsoft Foundry observability](https://learn.microsoft.com/en-us/azure/foundry/concepts/observability)
- [Security and governance in Microsoft Copilot Studio](https://learn.microsoft.com/en-us/microsoft-copilot-studio/security-and-governance)
- [Implement a zoned governance strategy for Microsoft Copilot Studio](https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/sec-gov-phase2)
- [Declarative agents for Microsoft 365 Copilot](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/overview-declarative-agent)
- [Best practices for declarative agents in Microsoft 365 Copilot](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/declarative-agent-best-practices)
- [AI Red Teaming Agent](https://learn.microsoft.com/en-us/azure/foundry/concepts/ai-red-teaming-agent)
- [PyRIT](https://github.com/microsoft/PyRIT)
- [FinOps documentation](https://learn.microsoft.com/en-us/cloud-computing/finops/)
- [FinOps Toolkit](https://microsoft.github.io/finops-toolkit/)
