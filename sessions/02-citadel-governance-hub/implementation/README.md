# Deploy the Citadel Governance Hub

## Session scope

### What we will do

**Deploy one shared Citadel Governance Hub from a pinned source.** We will approve a lean deployment profile, run preflight against the exact upstream commit, and deploy the hub through Citadel's Azure Developer CLI and Bicep path. The session ends when the core resources are running on the approved network and monitoring boundary.

### Why it matters

A quick deployment can silently create services, public paths, model capacity, and telemetry stores the customer did not plan to operate. The pinned release and deployment profile make those choices visible before Azure changes.

### Boundaries

This session deploys the central hub. It does not onboard workload access, models, MCP tools, or agents; Session 04 owns those contracts. The upstream Citadel repository owns the platform implementation. This repository keeps the approved release pin, customer profile, and safe command wrapper.

## Architecture

### Architecture at a glance

The Governance Hub separates the runtime request path from Azure and Foundry management. APIM is
the shared runtime boundary. Foundry projects, Azure Resource Manager, and the contract deployment
modules remain control-plane paths and should not carry application traffic.

```text
Runtime data path
Agent Spoke or workload
        |
   APIM API and product policy
        |
 shared policy fragments
 safety | authorization | limits | routing
        |
 backend or backend pool -> Foundry / Azure OpenAI / approved provider

Control and operations
contract deployments -> APIM configuration
APIM diagnostics -> Application Insights and Log Analytics
usage workflows -> Cosmos DB pricing and allocation records
```

The pinned deployment creates or binds the hub network and private DNS, then deploys APIM, Foundry,
Key Vault, monitoring, storage, Event Hubs, Cosmos DB, a usage-processing Logic App, and managed
identities. API Center and Managed Redis are optional. Other optional switches cover Foundry
network injection, dashboards, Realtime API, AI Search exposure, and PII processing.

Identity duties are split. The APIM user-assigned identity calls AI backends. APIM's system identity
resolves Key Vault-backed named values. A separate usage identity writes processed usage records to
Cosmos DB. Keep these roles separate; one broad hub identity makes access review and incident
containment harder.

APIM diagnostics and usage processing are also separate. Application Insights and Log Analytics
support runtime health and request analysis. Scheduled workflows create delayed usage and cost
allocation records in Cosmos DB. Neither path is the Foundry control plane.

Azure is authoritative for deployed state. The pinned upstream commit defines the implementation,
and `deployment-profile.json` records the customer choices mapped into it. The gateway governs only
workloads that use its endpoints and cannot bypass it through direct backend credentials or network
paths.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| APIM tier and ingress | Production-capable tier with private inbound access for production-shaped use | Supports scale and removes direct public ingress | Costs more and needs prepared networking |
| Backend identity | APIM user-assigned identity | Gives backend access a stable, reviewable principal | Requires exact backend role assignments |
| Secrets | Key Vault-backed APIM named values | Keeps provider keys out of policies and source | APIM system identity needs Key Vault access |
| Optional services | Disabled until required | Avoids cost and operating work with no owner | Later enablement needs another preview and approval |
| Message capture | Override upstream message capture to `none` by default | Avoids retaining prompts and completions | Troubleshooting uses metadata unless privacy approves an exception |
| API Center | Enable only with a catalog owner and lifecycle process | Makes published assets discoverable | Unowned metadata becomes stale |

### Architecture guidance

- [Generative AI gateway capabilities](https://learn.microsoft.com/azure/api-management/genai-gateway-capabilities)
- [Microsoft Foundry control plane](https://learn.microsoft.com/azure/ai-foundry/control-plane/overview)

## Before you start

Use the [upstream Governance Hub documentation](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/tree/citadel-v1)
for the full parameter reference and component behavior. This guide owns the customer deployment
profile, source pin, safety checks, and operating handoff around that implementation.

Clone the Citadel Governance Hub into the customer implementation workspace and check out the commit recorded in `release.json`. Do not modify the upstream checkout during this session. Put customer changes in the deployment profile or in a customer-owned overlay reviewed through source control.

### Implementation files

| Type | File | Consumer |
| --- | --- | --- |
| Record | `artifacts/citadel/release.json` | Citadel deployment and promotion pipelines |
| Runtime | `artifacts/citadel/deployment-profile.json` | Citadel deployment scripts and platform owner |

Install Git, Azure CLI, Azure Developer CLI, and `jq`. The deployment identity needs the roles stated by the pinned Citadel release at the exact approved scopes.

## Decisions and stop conditions

Approve the APIM SKU, regions, model capacity, existing or new network, private DNS, monitoring workspace, API Center, PII redaction, optional AI Search, optional Document Intelligence, optional Managed Redis, and prompt-body logging.

Stop when the checkout does not match the pinned commit, the selected region lacks required capacity, a subnet or private DNS zone is unavailable, telemetry retention is undecided, the deployment identity has broader standing access than approved, or the profile enables a service with no owner.

## Implement

### 1. Complete the deployment profile

Resolve every `__REQUIRED_*__` value. Keep optional services false unless the use case needs them now. Review the resulting Azure cost and quota request with the platform and FinOps owners.

### 2. Run preflight

```powershell
.\scripts\preflight.ps1 `
  -CitadelPath $citadelPath `
  -SubscriptionId $subscriptionId
```

```bash
./scripts/preflight.sh \
  --citadel-path "$citadel_path" \
  --subscription-id "$subscription_id"
```

### 3. Deploy the pinned hub

The command maps the approved profile to Citadel's environment settings, then runs `azd provision` and `azd deploy`.

```powershell
.\scripts\deploy.ps1 `
  -CitadelPath $citadelPath `
  -SubscriptionId $subscriptionId `
  -Confirm
```

```bash
./scripts/deploy.sh \
  --citadel-path "$citadel_path" \
  --subscription-id "$subscription_id"
```

Do not respond to a failed complex deployment by changing several flags at once. Read the failed Azure deployment, fix the specific prerequisite or parameter, and rerun the same pinned release.

The upstream `azd` path does not expose one complete read-only preview for the full hub. **Record preview as unsupported for this path**, and review the generated Azure deployment operations before confirming the state change. Use direct Bicep `what-if` instead when the customer deployment process supports the complete template and parameter mapping.

## Confirm the result

Inspect the Citadel deployment outputs and Azure resources. APIM, Foundry, Key Vault, monitoring, and usage-processing components report `Succeeded`; managed identities are present; expected private endpoints resolve from the approved host; and no unapproved optional service was created.

## After implementation

The platform owner manages the pinned release and deployment profile. API, model, security, network, privacy, and operations owners manage their service boundaries. Use Session 07 for upgrades. Restore by redeploying the previous approved commit and profile. Remove the hub only through the upstream removal guidance after dependent contracts and workloads have been disconnected.
