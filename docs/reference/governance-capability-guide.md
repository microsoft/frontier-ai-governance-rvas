# Governance capability guide

This guide maps the Microsoft capabilities used in the AI Governance curriculum to the governance question each session addresses. Capability availability changes, so verify the linked Microsoft documentation and tenant licensing before delivery.

## Capabilities by governance domain

| Domain and session | Microsoft capabilities | What the facilitator uses them for | Availability to confirm |
|---|---|---|---|
| Operating model · S0 | Cloud Adoption Framework for AI, Well-Architected Framework for AI, AI Center of Excellence guidance | Ownership model, maturity discussion, and roadmap. | Current guidance. |
| Identity · S1 | Microsoft Entra Agent ID, Conditional Access, Identity Protection, Agent 365 | Agent inventory, sponsorship, lifecycle, and access posture. | Agent-ID feature and Conditional-Access availability. |
| Data · S2 | Microsoft Purview DSPM for AI, DLP, audit, eDiscovery, and information protection | Data exposure findings, DLP testing, and retained compliance evidence. | Licensing and tenant support. |
| Platform & trust boundaries · S3 | Azure landing-zone, network, gateway, monitoring, and security capabilities | Customer-owned platform-path and trust-boundary decision. | Region, network, feature, and ownership availability. |
| Engineering & admission · S4 | Customer engineering standards, source control, build, evaluation, and deployment capabilities | Agent admission and material-change review. | Customer-supported implementation paths. |
| Tool/API/MCP governance · S5 | API catalog, gateway, identity, and lifecycle capabilities | Controlled publication, authority, and withdrawal decisions. | Connector, protocol, and tenant support. |
| Runtime assurance · S6 | Defender for Cloud AI-SPM, AI Threat Protection, Azure AI Content Safety | Security posture, threat signals, runtime safety, and response ownership. | Region, service, and feature availability. |
| Evaluation & release assurance · S7 | Microsoft Foundry evaluations, tracing, and CI/CD integration | Representative evaluation set, scorecard, and release review. | Individual evaluator availability. |
| Adversarial testing · S8 | PyRIT and the AI Red Teaming Agent | Authorised test scope, findings, and remediation evidence. | Red Teaming Agent availability and approved target. |
| Control plane & lifecycle · S9 | Microsoft Agent 365, Entra Agent ID, API Center, platform telemetry | Reconcile agent, tool, identity, ownership, and lifecycle records. | Agent 365 licensing and connector status. |
| In-process governance · S10 | Agent Governance Toolkit (AGT) | Offline illustration of application-process tool-call policy and audit evidence; adoption decision only. | Applicability, release status, and architecture fit. |
| Operate, monitor & FinOps · S11 | Customer-held operational, security, quality, and cost evidence | Operating review, drift, cost, and remediation cadence. | Evidence coverage and owner availability. |
| Portfolio governance · S12 | Customer-held governance, risk, and portfolio records | Portfolio decision, exception review, and next roadmap. | Decision authority and records availability. |

## The capability map

![Microsoft Entra Agent ID, Microsoft Purview, security controls, evaluations, and adversarial testing records inform Microsoft Agent 365, with the operating model beneath the entire governance view.](../assets/diagrams/landscape.svg)

## Product-status notes

- Microsoft Agent 365 and Microsoft Entra Agent ID have general-availability announcements; some related access-control and connector features remain preview.
- Purview DSPM, Defender AI-SPM, AI Threat Protection, and Prompt Shields have generally available capabilities, while individual detections and integrations may be preview.
- The `azure-ai-evaluation` SDK is generally available, but individual evaluators and continuous-evaluation features can vary.
- PyRIT is open source. The managed AI Red Teaming Agent is preview.
- Foundry Citadel Platform is a reference architecture. AI Hub Gateway and Azure AI Landing Zones are accelerators with their own deployment guidance.
- AGT is open source and Public Preview at the pinned curriculum revision. Its
  audit records governance attempts and decisions, not downstream action
  outcomes; it does not provide data provenance, an SBOM, or a turnkey
  human-approval UI. It is an applicability-based S10 topic, not a required customer
  control.[^agt]

## Framework alignment

The curriculum produces practical evidence that may support NIST AI RMF, ISO/IEC 42001, and EU AI Act work. This mapping is illustrative; the customer remains responsible for risk classification, legal interpretation, and formal conformity assessment.

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
- [Microsoft Agent 365](https://learn.microsoft.com/en-us/microsoft-agent-365/overview)
- [Microsoft Entra Agent ID](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id)
- [Microsoft Purview for AI](https://learn.microsoft.com/en-us/purview/ai-microsoft-purview)
- [Defender AI security posture management](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-security-posture)
- [Azure AI Content Safety Prompt Shields](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection)
- [Microsoft Foundry evaluations](https://learn.microsoft.com/en-us/azure/foundry/concepts/observability)
- [AI Red Teaming Agent](https://learn.microsoft.com/en-us/azure/foundry/concepts/ai-red-teaming-agent)
- [AGT README at pinned commit `b680c49`](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/README.md)
- [AGT known limitations at pinned commit `b680c49`](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/docs/LIMITATIONS.md)

[^agt]: The AGT source describes Public Preview releases and documents these
limitations at the pinned commit; verify product status and applicability before
customer delivery.
