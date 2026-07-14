# Governance capability guide

This guide maps the Microsoft capabilities used in RVAS to the governance question each session addresses. Capability availability changes, so verify the linked Microsoft documentation and tenant licensing before delivery.

## Capabilities by governance domain

| Domain and session | Microsoft capabilities | What the facilitator uses them for | Availability to confirm |
|---|---|---|---|
| Operating model · S0 | Cloud Adoption Framework for AI, Well-Architected Framework for AI, AI Center of Excellence guidance | Ownership model, maturity discussion, and roadmap. | Current guidance. |
| Identity · S1 | Microsoft Entra Agent ID, Conditional Access, Identity Protection, Agent 365 | Agent inventory, sponsorship, lifecycle, and access posture. | Agent-ID feature and Conditional-Access availability. |
| Data · S2 | Microsoft Purview DSPM for AI, DLP, audit, eDiscovery, and information protection | Data exposure findings, DLP testing, and retained compliance evidence. | Licensing and tenant support. |
| Security · S3 | Defender for Cloud AI-SPM, AI Threat Protection, Azure AI Content Safety | Security posture, threat signals, Prompt Shields, and response ownership. | Region, service, and feature availability. |
| Evaluation · S4 | Microsoft Foundry evaluations, tracing, and CI/CD integration | Representative evaluation set, scorecard, and release review. | Individual evaluator availability. |
| Adversarial testing · S5 | PyRIT and the AI Red Teaming Agent | Authorised test scope, findings, and remediation evidence. | Red Teaming Agent availability and approved target. |
| Lifecycle · S6 | Microsoft Agent 365, Entra Agent ID, API Center, platform telemetry | Reconcile agent, identity, ownership, and platform records. | Agent 365 licensing and connector status. |

## Product-status notes

- Microsoft Agent 365 and Microsoft Entra Agent ID have general-availability announcements; some related access-control and connector features remain preview.
- Purview DSPM, Defender AI-SPM, AI Threat Protection, and Prompt Shields have generally available capabilities, while individual detections and integrations may be preview.
- The `azure-ai-evaluation` SDK is generally available, but individual evaluators and continuous-evaluation features can vary.
- PyRIT is open source. The managed AI Red Teaming Agent is preview.
- Foundry Citadel Platform is a reference architecture. AI Hub Gateway and Azure AI Landing Zones are accelerators with their own deployment guidance.

## Framework alignment

The curriculum produces practical evidence that may support NIST AI RMF, ISO/IEC 42001, and EU AI Act work. This mapping is illustrative; the customer remains responsible for risk classification, legal interpretation, and formal conformity assessment.

| Session | NIST AI RMF | ISO/IEC 42001 | EU AI Act |
|---|---|---|---|
| S0 | Govern, Map | Policies and roles | Art. 9, 17 |
| S1 | Govern, Map, Manage | Lifecycle and access | Art. 12, 14, 15 |
| S2 | Map, Manage | Data and impact | Art. 10, 12 |
| S3 | Measure, Manage | Lifecycle and operations | Art. 15 |
| S4 | Measure, Manage | Validation and operations | Art. 9, 12, 15, 72 |
| S5 | Govern, Measure, Manage | Roles, lifecycle, operations | Art. 9, 12, 15 |
| S6 | Govern, Map, Manage | Policies, roles, operations | Art. 72 |

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
