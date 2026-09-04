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

The Governance Hub is the shared runtime control point. APIM fronts approved AI backends and published assets. Foundry supplies models and control-plane functions. API Center catalogs approved assets. Application Insights, Log Analytics, Event Hubs, Cosmos DB, and Logic Apps support operations and usage processing.

```text
Agent Spokes and existing workloads
                 |
        Citadel Governance Hub
  APIM -> safety and routing -> Foundry
    |          |                |
 API Center  identity       model backends
    |
monitoring and usage processing
```

Azure is authoritative for the deployed resources. The pinned upstream commit defines the implementation. `deployment-profile.json` records the customer choices mapped into that implementation.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| Source | Exact upstream commit | Repeatable review and deployment | Upgrades require an explicit pull and test |
| Network | Existing customer VNet by default | Reuses approved routing and DNS | Needs prepared subnets from Session 01 |
| Optional services | Disabled until required | Avoids cost and operating work with no current use | Later enablement needs another preview and approval |
| Prompt bodies | Disabled by default | Reduces sensitive-data retention | Troubleshooting relies on metadata and bounded exceptions |

### Architecture guidance

- [Generative AI gateway capabilities](https://learn.microsoft.com/azure/api-management/genai-gateway-capabilities)
- [Microsoft Foundry control plane](https://learn.microsoft.com/azure/ai-foundry/control-plane/overview)

## Before you start

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
