# S3 · Enterprise Platform & Trust Boundaries: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Azure landing zones, Microsoft Foundry, Azure API Management AI Gateway, Azure API Center, private networking, and Azure Monitor capabilities vary by tenant, region, license, SKU, and service maturity. Verify official docs and customer platform status before delivery.

## Microsoft default

Default to an Azure landing-zone-aligned platform using Microsoft Foundry for AI workloads, Azure API Management AI Gateway or a Citadel-aligned gateway where supported, private networking where risk requires it, Azure API Center for registry, and Azure Monitor/Application Insights for telemetry.

![S3 illustrative Azure platform pattern: callers cross an optional gateway trust boundary to orchestration or hosted execution, private data access, identity, and observability layers. The pattern identifies decisions and evidence expectations without claiming a deployed topology.](../assets/diagrams/s3-gateway-trust-boundary.svg)

## Decision tree

1. **If the customer has a governed Azure landing zone**, integrate the AI workload and backlog AI-specific deltas.
2. **If the workload needs shared AI governance at scale**, use a Foundry/Citadel-aligned platform pattern with API Management gateway and Azure Monitor telemetry.
3. **If sensitive data or policy requires private routing**, require Private Link/VNet/DNS design and owner validation.
4. **If no gateway, registry, or telemetry path exists**, route to platform backlog before S6/S7 release assurance can rely on it.

| Platform decision | Microsoft default | Exception criteria |
|---|---|---|
| Topology | Azure landing zone with Foundry project/workspace boundaries | approved non-Azure platform carries equivalent identity, network, telemetry, and catalog records |
| Trust boundary | Azure API Management AI Gateway or customer-adopted Citadel pattern | existing gateway is authoritative and can enforce AI route contracts |
| Network isolation | Private endpoints/VNet integration where sensitivity requires | public endpoints are policy-approved and gateway/telemetry evidence is sufficient |
| Registry/telemetry | Azure API Center + Azure Monitor/Application Insights | existing catalog/observability estate maps required fields |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Landing zone fit | Azure landing-zone subscription/resource group policy, Azure Policy assignments, CAF/Well-Architected review |
| Foundry workspace/project | Foundry project, model deployment, agent/tool configuration references |
| Gateway route | Azure API Management API/product/policy/backend record, gateway logs, Citadel accelerator docs if used |
| Private connectivity | Private Endpoint, private DNS zone, VNet integration, network security group, route table records |
| Observability | Azure Monitor, Application Insights, Log Analytics workspace, diagnostic settings, correlation ID plan |
| Registry | Azure API Center API/tool entry and lifecycle owner |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Topology | target Azure landing-zone or exception topology has owner, assumptions, and backlog route | Architecture/platform |
| Trust boundary | expected ingress, egress, gateway, identity, and telemetry path are recorded with validation owner | Platform/security |
| Private route | selected private endpoints/DNS/VNet dependencies have owners and official support status checked | Network owner |
| Runtime proof prerequisites | S6 can identify the gateway route, correlation source, retention owner, and reviewer | Security/runtime owner |

## Boundary note

S3 creates a platform decision and work list; it deploys no resources and grants no production approval.

## Related references

- [S3 Concepts](concepts.md): trust boundaries, gateway boundary, private-connectivity assumptions, telemetry coverage, and platform backlog.
- [S6 technical decisions](../s6-security-runtime/technical.md): runtime proof and gateway correlation.
- [S9 technical decisions](../s9-control-plane/technical.md): catalog handoff.
- [Platform technical guide](../reference/platform-technical-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
