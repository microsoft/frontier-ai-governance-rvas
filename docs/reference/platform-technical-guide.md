# Platform technical guide

Use this guide with the customer platform team. It explains the technical foundation for an integrated AI Governance engagement. It covers the Foundry Citadel Platform, deployable accelerators, and the line between platform work and governance work.

## The Citadel platform model

The [Foundry Citadel Platform](https://github.com/Azure-Samples/foundry-citadel-platform) is a Microsoft reference architecture for enterprise AI security, compliance, and scale. It describes four connected layers and links to deployable accelerators. It is not a deployment package.

| Layer | Platform purpose | Typical technologies |
|---|---|---|
| Governance Hub | Route approved AI calls and apply shared gateway controls. | Azure API Management, Azure API Center, access and backend contracts. |
| AI Control Plane | Observe, trace, and evaluate AI behavior. | Microsoft Foundry, evaluation and observability services. |
| Agent Identity | Link agents to sponsors, lifecycle, and access context. | Microsoft Entra Agent ID, Microsoft Agent 365. |
| Security Fabric | Protect data and respond to security and runtime-safety risk. | Microsoft Defender, Microsoft Purview, Microsoft Entra, Content Safety. |

## What the platform team provides

The [AI Hub Gateway / Citadel Governance Hub](https://aka.ms/ai-hub-gateway) is a deployable accelerator for the Governance Hub. Its `citadel-v1` branch includes an Azure API Management AI gateway, an API Center registry, access contracts, gateway safety and PII-masking patterns, Entra/JWT authentication, telemetry, and private-network options.

Azure AI Landing Zones provide the application landing-zone base for AI workloads. The [Agent Governance Toolkit (AGT)](https://github.com/microsoft/agent-governance-toolkit/tree/b680c49cc956727c5249771ddba7ee21a635a676) provides open-source in-process policy and agent-security capabilities. At the pinned revision used by this curriculum, AGT is a **Public Preview** and may change before general availability.[^agt]

AGT runs inside the application process. It can check a tool-call policy before the call reaches a downstream tool. It can also record the allow, deny, or approval decision. It complements Citadel network and gateway controls. It does not replace them.

This curriculum does not claim an official AGT-Citadel integration. It also does not make AGT required for the integrated platform path.

The platform team owns:

- gateway, private-network, backend-pool, and resiliency design;
- platform pipelines, access and backend contracts, and telemetry plumbing;
- accelerator deployment and its operating support model.

## Where the AI Governance programme uses platform evidence

| Platform record | Programme use |
|---|---|
| Foundry project, model, agent type, tool, identity, observability, and publication records | S4 uses these records to recommend a Microsoft implementation path and create a configuration backlog. It does not deploy or configure Foundry resources. |
| API Center and access-contract records | S5 and S9 review publication, exposure, identity, ownership, and lifecycle records. |
| Gateway authentication and safety configuration | S1 and S6 review the matching identity and runtime-safety evidence. |
| Gateway data-protection configuration | S2 reviews it alongside Purview data and compliance controls. |
| Traces, evaluations, usage, and cost telemetry | S7, S8, S9, and S11 use approved references to this evidence for evaluation-plan review, remediation, reconciliation, operating, and cost decisions. |

The AI Governance programme does not rebuild these capabilities. It assigns owners, reviews evidence, and records the decisions and gaps that follow.

S4 is the path-selection handoff point. It may recommend Copilot Studio, Microsoft Foundry Agent Service, a custom Azure application or service using Foundry models and tools, Microsoft 365 Copilot extensibility, workflow automation, or research/prototype isolation. The platform team still owns deployment, identity configuration, network and gateway setup, telemetry plumbing, and production-readiness work through the customer's approved engineering and change processes.

## Technical handoff checklist

Before an integrated session needs platform evidence, record:

1. the platform owner and the expected deployment or connection path;
2. the gateway and registry locations, if available;
3. the safety configuration and telemetry location;
4. the current platform readiness gaps and their owners.

For accelerator deployment, use the [AI Hub Gateway deployment guidance](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/tree/citadel-v1/guides) and the [Azure AI Landing Zones](https://github.com/Azure/AI-Landing-Zones) documentation. Confirm the selected branch, prerequisites, and product status before customer delivery.

[^agt]: [AGT README at pinned commit `b680c49`](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/README.md), Public Preview notice and `govern()` example.
