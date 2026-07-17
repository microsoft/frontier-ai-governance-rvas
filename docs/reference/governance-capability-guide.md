# Governance capability guide

Use this guide to map each AI Governance session to concrete Microsoft capabilities. Check the linked Microsoft documentation, tenant licensing, region support, and customer fit before delivery.

## Capabilities by governance domain

| Domain and session | Microsoft capabilities | What the facilitator uses them for | Availability to confirm |
|---|---|---|---|
| Operating model · S0 | Cloud Adoption Framework for AI, Well-Architected Framework for AI, AI Center of Excellence guidance | Ownership model, maturity discussion, and roadmap. | Current guidance. |
| Identity · S1 | Microsoft Entra Agent ID, Conditional Access, Identity Protection, Agent 365 | Agent inventory, sponsorship, lifecycle, and access posture. | Agent-ID feature and Conditional-Access availability. |
| Data · S2 | Microsoft Purview DSPM for AI, DLP, audit, eDiscovery, and information protection | Data exposure findings, DLP testing, and retained compliance evidence. | Licensing and tenant support. |
| Platform & trust boundaries · S3 | Azure landing-zone, network, gateway, monitoring, and security capabilities | Customer-owned platform path and trust-boundary decision. | Region, network, feature, and ownership availability. |
| Engineering & admission · S4 | Microsoft Foundry Agent Service, Copilot Studio / Power Platform governance, Microsoft 365 Copilot declarative agents, Entra identity/RBAC/Agent ID, Foundry evaluation and observability, Azure Monitor / Application Insights, Content Safety, Agent 365, API Center, and customer engineering/change processes | Product-specific implementation path, model choice, fine-tuning governance, latency budget, token-cost estimate, rollout decision, admission, and material-change review. | Tenant licensing, region, feature availability, approved engineering path, and customer change authority. |
| Tool/API/MCP governance · S5 | API catalog, gateway, identity, and lifecycle capabilities | Controlled publication, authority, and withdrawal decisions. | Connector, protocol, and tenant support. |
| Runtime assurance · S6 | Defender for Cloud AI-SPM, AI Threat Protection, Azure AI Content Safety, Azure Monitor / Application Insights | Security posture, threat signals, runtime safety, gateway correlation, and response ownership. | Region, service, telemetry, and feature availability. |
| Evaluation & release assurance · S7 | Microsoft Foundry evaluations, agent evaluators (task completion, intent resolution, tool-call accuracy, response quality, safety), cloud evaluation, tracing, continuous evaluation where applicable, and CI/CD integration | Customer-owned evaluation-plan review, threshold governance, scorecard interpretation, and release decision. | Individual evaluator availability, test-data ownership, and integration path. |
| Adversarial testing · S8 | PyRIT and the AI Red Teaming Agent | Authorized test scope, findings, and remediation evidence. | Red Teaming Agent availability and approved target. |
| Control plane & lifecycle · S9 | Microsoft Agent 365, Entra Agent ID, API Center, platform telemetry | Reconcile agent, tool, identity, ownership, and lifecycle records. | Agent 365 licensing and connector status. |
| In-process governance · S10 | Agent Governance Toolkit (AGT) | Offline example of application-process tool-call policy and audit evidence; adoption decision only. | Applicability, release status, and architecture fit. |
| Operate, monitor & FinOps · S11 | Customer-held operational, security, quality, and cost evidence; Azure Monitor / Application Insights; Foundry observability; Azure Cost Management and FinOps Toolkit where used | Operating review, quality/latency/cost drift, cost accountability, and remediation cadence. | Evidence coverage, attribution limits, and owner availability. |
| Portfolio governance · S12 | Customer-held governance, risk, and portfolio records | Portfolio decision, exception review, and next roadmap. | Decision authority and records availability. |

## Implementation pathway taxonomy

Each session should turn its evidence review into a clear implementation pathway. The pathway is a customer-owned backlog and decision aid. It is not an instruction to deploy, configure, publish, grant access, or approve production use during the session.

Use the same row shape across sessions:

| Field | Purpose |
|---|---|
| Implementation pathway or backlog item | The next setup, configuration, review, operating, or portfolio decision the session enables. |
| Applicability | `applies`, `does not apply`, `unknown`, or `later session / customer process`. Applicability does not mean the customer must deploy it. |
| Session recommendation | Recommended next path, defer, reject, investigate, accept risk, or route elsewhere. |
| Confidence and assumptions | Why the evidence reviewed in this session supports the recommendation. |
| Evidence reference or gap | Customer-held record reference, nothing found, tool limitation, blocker, or missing prerequisite. |
| Owner | Named business, engineering, platform, security, identity, data, service, cost, or portfolio owner. |
| Later route | Follow-on session or customer architecture, security, change, release, support, or production-approval process. |
| Boundary | What this session does not configure, deploy, prove, or approve. |

Filter these Microsoft capability categories to the session:

| Category | Typical implementation questions |
|---|---|
| Operating model and change process | Who owns the decision, cadence, roadmap, exception route, change process, and production approval? |
| Entra identity and Agent ID | Which human sponsor, Agent ID, workload identity, RBAC, Conditional Access, OBO, or lifecycle review is needed? |
| Purview and data governance | Which DSPM, DLP, label, audit, eDiscovery, retention, or investigation capability applies? |
| Platform, gateway, and API Center | Which landing-zone, network, gateway, API Center, access-contract, telemetry, or platform-owner backlog item is needed? |
| Copilot Studio and Power Platform | Which environment, Managed Environment, DLP, connector, solution, ALM, publication, or monitoring decision applies? |
| Microsoft Foundry Agent Service | Which project, model, agent type, instructions/code package, tools, identity, observability, evaluation, or publication item applies? |
| Model selection and fine-tuning | Which model fits capability, cost, latency, and data-residency needs? Is fine-tuning justified, who owns training-data review, and which comparison is required? |
| Quality measurement and threshold governance | Which dimensions and evaluators apply, which option works everywhere or requires Foundry, and who approves thresholds and owns regressions? |
| Latency budgeting | Which component targets, attribution limits, regression owner, and telemetry reference apply? |
| Token cost and FinOps | Which tier, cost owner, allocation approach, quota or capacity consideration, and spend-decision route apply? |
| Staged rollout governance | Which S4/S6/S7/S8/S9 references are assembled, and who is the customer change authority for promotion? |
| Microsoft 365 Copilot extensibility | Which declarative-agent instructions, knowledge, actions, capabilities, metadata, distribution, or tenant-governance item applies? |
| Runtime safety and SOC operations | Which Content Safety, prompt shield, gateway policy, runtime-control, alert, SOC contact, or remediation route applies? |
| Evaluation and observability | Which Foundry evaluation, evaluator, scorecard, trace, release threshold, or Application Insights/OpenTelemetry item applies? |
| Catalog and lifecycle | Which Agent 365, Entra Agent ID, API Center, registry, steward, material-change, retirement, or recurrence item applies? |
| FinOps and operating evidence | Which cost owner, allocation, Azure Cost Management, FinOps Toolkit, operational review, or remediation-validation item applies? |
| Customer SDLC and release | Which architecture/security review, CI/CD gate, release, rollback, verification, or production-approval process owns execution? |

## The capability map

![Microsoft Entra Agent ID, Microsoft Purview, security controls, evaluations, and adversarial testing records inform Microsoft Agent 365, with the operating model beneath the entire governance view.](../assets/diagrams/landscape.svg)

## Product-status notes

- Microsoft Agent 365 and Microsoft Entra Agent ID have general-availability announcements. Some related access-control and connector features remain preview.
- Purview DSPM, Defender AI-SPM, AI Threat Protection, and Prompt Shields have generally available capabilities. Individual detections and integrations may be preview.
- The `azure-ai-evaluation` SDK is generally available. Individual evaluators, agent evaluators, cloud evaluation, and continuous-evaluation features can vary. Verify the named evaluator categories before delivery. S7 references customer-owned evaluation work. It does not run a live evaluator or create a CI/CD gate.
- Foundry fine-tuning is available for supported models and can vary by model, region, and feature. Verify support before you recommend a fine-tuning path or evaluation integration.
- Foundry billing and project-level cost attribution may have scope limits. Confirm available views before you use them in a FinOps recommendation.
- ASSERT policy-driven evaluation is contextual Build 2026 guidance. Verify its current project and preview status before you cite it in a customer backlog.
- Microsoft Foundry Agent Service supports prompt agents, hosted agents, and existing external agents through the Responses API. S4 uses this distinction only for implementation-path and backlog planning. It does not create or deploy an agent.
- Copilot Studio agents are governed through Power Platform and Microsoft 365 controls such as environments, data policies, publication controls, audit, and tenant administration. Confirm environment, DLP, connector, ALM, and licensing requirements before you recommend that path.
- Microsoft 365 Copilot declarative agents are configured through instructions, knowledge, actions, capabilities, and app metadata. Confirm the selected authoring tool, admin distribution route, and tenant controls before delivery.
- PyRIT is open source. The managed AI Red Teaming Agent is preview.
- Foundry Citadel Platform is a reference architecture. AI Hub Gateway and Azure AI Landing Zones are accelerators with their own deployment guidance.
- AGT is open source and Public Preview at the pinned curriculum revision. Its audit records governance attempts and decisions, not downstream action outcomes. It does not provide data provenance, an SBOM, or a ready-made human-approval UI. It is an applicability-based S10 topic, not a required customer control.[^agt]

## Framework alignment

The curriculum produces practical evidence that may support NIST AI RMF, ISO/IEC 42001, and EU AI Act work. This mapping is illustrative. The customer remains responsible for risk classification, legal interpretation, and formal conformity assessment.

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
| S10 | Govern, Measure, Manage | Operational controls and evidence | Art. 9, 12, 15 |
| S11 | Measure, Manage | Monitoring, measurement, and improvement | Art. 12, 15, 72 |
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
- [Azure API Center overview](https://learn.microsoft.com/en-us/azure/api-center/overview)
- [Defender AI security posture management](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-security-posture)
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
- [AGT README at pinned commit `b680c49`](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/README.md)
- [AGT known limitations at pinned commit `b680c49`](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/docs/LIMITATIONS.md)

[^agt]: The AGT source describes Public Preview releases and documents these limitations at the pinned commit. Verify product status and fit before customer delivery.
