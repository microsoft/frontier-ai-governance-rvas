# Platform technical guide

Use this guide with the customer platform team when they need to understand the technical foundation that supports an integrated AI Governance engagement. It explains the Foundry Citadel Platform, the deployable accelerators, and the boundary between platform delivery and governance delivery.

## The Citadel platform model

The [Foundry Citadel Platform](https://github.com/Azure-Samples/foundry-citadel-platform) is a Microsoft reference architecture for enterprise AI security, compliance, and scale. It describes four connected layers and points to deployable accelerators; it is not itself a deployment package.

| Layer | Platform purpose | Typical technologies |
|---|---|---|
| Governance Hub | Route approved AI calls and apply shared gateway controls. | Azure API Management, Azure API Center, access and backend contracts. |
| AI Control Plane | Observe, trace, and evaluate AI behavior. | Microsoft Foundry, evaluation and observability services. |
| Agent Identity | Associate agents with sponsors, lifecycle, and access context. | Microsoft Entra Agent ID, Microsoft Agent 365. |
| Security Fabric | Protect data and respond to security and runtime-safety risk. | Microsoft Defender, Microsoft Purview, Microsoft Entra, Content Safety. |

## What the platform team provides

The [AI Hub Gateway / Citadel Governance Hub](https://aka.ms/ai-hub-gateway) is a deployable accelerator for the Governance Hub. Its `citadel-v1` branch includes an APIM AI gateway, API Center registry, access contracts, gateway safety and PII-masking patterns, Entra/JWT authentication, telemetry, and private-networking options.

Azure AI Landing Zones provide the application landing-zone foundation for AI workloads. The [Agent Governance Toolkit (AGT)](https://github.com/microsoft/agent-governance-toolkit/tree/b680c49cc956727c5249771ddba7ee21a635a676) provides open-source in-process policy and agent-security capabilities. At the pinned revision used by this curriculum, AGT is a **Public Preview** and may have breaking changes before GA.[^agt]

AGT is an application-process control: it can evaluate a tool-call policy before
the call reaches a downstream tool and record the allow, deny, or approval
decision. It complements, rather than integrates with or replaces, Citadel's
network/gateway controls. This curriculum does not assert an official
AGT–Citadel integration, and it does not make AGT a prerequisite for the
integrated platform path.

The platform team owns:

- gateway, private-networking, backend-pool, and resiliency design;
- platform pipelines, access and backend contracts, and telemetry plumbing;
- accelerator deployment and its operational support model.

## Where the AI Governance programme uses platform evidence

| Platform record | Programme use |
|---|---|
| API Center and access-contract records | S5 and S9 review publication, exposure, identity, ownership, and lifecycle records. |
| Gateway authentication and safety configuration | S1 and S6 review the corresponding identity and runtime-safety evidence. |
| Gateway data-protection configuration | S2 considers it alongside Purview data and compliance controls. |
| Traces, evaluations, usage, and cost telemetry | S7, S8, S9, and S11 use it as evidence for review, remediation, and operating decisions. |

The AI Governance programme does not rebuild these capabilities. It assigns owners, reviews the evidence, and records the decisions and gaps that follow.

## Technical handoff checklist

Before an integrated session needs platform evidence, record:

1. the platform owner and the expected deployment or connection path;
2. the gateway and registry locations, if available;
3. the safety configuration and telemetry location;
4. the current platform readiness gaps and their owners.

For accelerator deployment, use the [AI Hub Gateway deployment guidance](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/tree/citadel-v1/guides) and the [Azure AI Landing Zones](https://github.com/Azure/AI-Landing-Zones) documentation. Confirm the selected branch, prerequisites, and product status before customer delivery.

[^agt]: [AGT README at pinned commit `b680c49`](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/README.md), Public Preview notice and `govern()` example.
