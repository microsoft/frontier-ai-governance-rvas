# Platform technical guide

Use this guide with the customer platform team for the technical foundation of an integrated AI Governance engagement: Foundry Citadel Platform, deployable accelerators, and the boundary between platform and governance work.

## The Citadel platform model

The [Foundry Citadel Platform](https://github.com/Azure-Samples/foundry-citadel-platform) is a Microsoft reference architecture for enterprise AI security, compliance, and scale. It describes four connected layers and links to deployable accelerators; it is not a deployment package.

| Layer | Platform purpose | Typical technologies |
|---|---|---|
| Governance Hub | Route approved AI calls and apply shared gateway controls. | Azure API Management, Azure API Center, access and backend contracts. |
| AI Control Plane | Observe, trace, and evaluate AI behavior. | Microsoft Foundry, evaluation and observability services. |
| Agent Identity | Link agents to sponsors, lifecycle, and access context. | Microsoft Entra Agent ID, Microsoft Agent 365. |
| Security Fabric | Protect data and respond to security and runtime-safety risk. | Microsoft Defender, Microsoft Purview, Microsoft Entra, Content Safety. |

## Azure agent platform reference pattern

An Azure agent platform commonly separates the route into six reviewable planes.
The pattern helps S3, S5, S6, and S10 ask the right evidence questions; it is
not a deployable topology and does not prove that a customer environment is
configured this way.

![Azure agent platform reference pattern showing entry, orchestration, execution, data, identity, catalog, and observability planes.](../assets/diagrams/azure-agent-platform-reference.svg)

| Plane | Purpose | Typical Azure records to identify |
|---|---|---|
| Entry and governance | Route caller, agent, model, and tool traffic through an accountable policy boundary. | Azure API Management API/product/policy/backend, gateway owner, API Center record, access contract. |
| Orchestration | Host or coordinate model and agent execution. | Microsoft Foundry project, model deployment, agent record, tool configuration, observability settings. |
| Execution | Run custom or external agent logic outside the managed orchestration surface. | App Service, Application Service Environment, Functions, Container Apps, AKS, workload identity, deployment owner. |
| Data | Provide retrieval, storage, search, and document-processing dependencies. | Cosmos DB, Azure AI Search, Storage, Document Intelligence, Private Endpoint, data owner, classification record. |
| Identity | Distinguish user, host workload, agent, delegated, gateway, and resource identities. | Entra Agent ID, Agent 365, managed identity, workload identity federation, app registration, RBAC/API permissions. |
| Observability | Preserve request, policy, tool, data, cost, and safety signals with correlation and retention. | Azure Monitor, Application Insights, Log Analytics, diagnostic settings, trace/correlation method, export owner. |

For a private or high-sensitivity route, the platform team should also identify
the expected network segmentation: VNet/subnet ownership, private endpoint
placement, private DNS zones, NSGs, route tables or firewalls, peering or
hybrid-connectivity conditions, and known public-endpoint exceptions. The
programme records those references and owners; it does not test reachability or
change network policy.

For operations, the same platform profile should say how a reviewer connects the
gateway request, orchestration trace, execution-host dependency call, data/tool
record, safety event, token metric, and cost view. If telemetry is exported to a
SIEM or external observability platform, record the approved export path and data
handling boundary before S10 relies on it.

## Where the AI Governance programme uses platform evidence

| Platform record | Programme use |
|---|---|
| Foundry project, model, agent type, tool, identity, observability, and publication records | S4 uses these records to recommend a Microsoft implementation path and create a configuration backlog. It does not deploy or configure Foundry resources. |
| API Center and access-contract records | S5 and S9 review publication, exposure, identity, ownership, and lifecycle records. |
| Gateway authentication and safety configuration | S1 and S6 review the matching identity and runtime-safety evidence. |
| Gateway data-protection configuration | S2 reviews it alongside Purview data and compliance controls. |
| Traces, evaluations, usage, and cost telemetry | S7, S8, S9, and S10 use approved references to this evidence for evaluation-plan review, remediation, reconciliation, operating, and cost decisions. |

The AI Governance programme does not rebuild these capabilities; it assigns owners, reviews evidence, and records resulting decisions and gaps.

S4 is the path-selection handoff. It may recommend Copilot Studio, Microsoft Foundry Agent Service, a custom Azure application or service using Foundry models and tools, Microsoft 365 Copilot extensibility, workflow automation, or research/prototype isolation. The platform team still owns deployment, identity, network and gateway setup, telemetry, and production-readiness through approved engineering and change processes.

## Technical handoff checklist

Before an integrated session needs platform evidence, record:

1. the platform owner and the expected deployment or connection path;
2. the gateway and registry locations, if available;
3. the safety configuration and telemetry location;
4. the current platform readiness gaps and their owners.

For accelerator deployment, use the [AI Hub Gateway deployment guidance](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/tree/citadel-v1/guides) and the [Azure AI Landing Zones](https://github.com/Azure/AI-Landing-Zones) documentation. Confirm the selected branch, prerequisites, and product status before customer delivery.
