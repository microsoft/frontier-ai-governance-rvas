# Deploy a Citadel Agent Spoke and governed agent

## Session scope

### What we will do

**Create one workload execution plane and one governed agent.** We will pin the AI Landing Zones source, deploy or connect the smallest useful Agent Spoke, and create the policy-assistant reference agent with Entra authorization and one customer-supplied read-only OpenAPI operation. The result is a versioned workload ready for Citadel contract onboarding.

### Why it matters

The full Agent Spoke reference can deploy more infrastructure than a first workload needs. Choosing the workload boundary first avoids unused compute, ingress, administration VMs, and duplicate shared services.

### Boundaries

This session owns one nonproduction workload environment and agent. The pinned AI Landing Zones source owns the landing-zone implementation. Foundry owns the live agent version and endpoint. Session 04 grants access through the Governance Hub.

## Architecture

### Architecture at a glance

AI Landing Zones provides separate Foundry and AI gateway landing-zone implementations. A Citadel
Agent Spoke normally consumes the Foundry and workload side and uses the shared Governance Hub. It
does not need another APIM gateway unless the workload has a separate ingress or east-west
mediation requirement.

```text
Approved users or application
              |
      workload entry point
              |
   versioned agent or orchestrator
       |                    |
workload data plane     Citadel access contract
Storage | Cosmos DB          |
Search | Key Vault      Governance Hub APIM
                            /       \
                     model route   MCP/A2A route
```

Use one spoke for a workload ownership and data boundary, not automatically one spoke per agent.
Split spokes when subscriptions, networks, data owners, or release authority differ. When Container
Apps is selected, its environment is the administrative and network boundary; individual agents
remain separately versioned applications or revisions inside it.

Private workload data uses VNet integration and private endpoints for services such as Storage,
Cosmos DB, Search, and Key Vault. User-assigned managed identities handle service-to-service
access. Those identities do not constrain tool behavior by themselves. Session 04 still defines
the gateway product, published assets, and backend authorization.

`spoke-profile.json` records the selected workload shape. Azure owns live infrastructure state, and
Foundry owns live agent versions and endpoints. The customer pipeline owns reconciliation from the
pinned source and profile.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| Spoke boundary | One per workload ownership and data boundary | Keeps access, cost, and lifecycle ownership coherent | Large workloads may need further isolation |
| Gateway | Use the shared Governance Hub | Avoids a second policy and routing plane | Requires reliable hub connectivity |
| Runtime | Foundry Agent Service or the selected workload runtime | Keeps the agent close to its data and owner | Runtime choice changes network and release operations |
| Optional infrastructure | Exclude Application Gateway, jump/build VMs, self-hosted models, and local APIM unless required | Reduces cost and attack surface | Later requirements need another reviewed deployment |
| Agent endpoint | Fixed approved version | Gives evaluation and promotion a stable target | Version changes require promotion |
| Tool scope | One customer-supplied read-only operation | Keeps the first authorization path understandable | Write actions need a separate threat model and approval path |

### Architecture guidance

- [Microsoft Foundry Agent Service](https://learn.microsoft.com/azure/foundry/agents/overview)
- [Role-based access control for Microsoft Foundry](https://learn.microsoft.com/azure/foundry/concepts/rbac-foundry)

## Before you start

Choose the workload subscription, resource group, network, Foundry project, model deployment, Key Vault, data services, and runtime. Decide whether Container Apps, Application Gateway, build VM, jump VM, or other optional components have a current owner and requirement.

The policy assistant and its `get_policy` operation are repository examples, not Citadel components.
Replace the sample operation ID, path, audience, and authorization scope with an approved customer
API before deployment.

### Implementation files

| Type | File | Consumer |
| --- | --- | --- |
| Record | `artifacts/citadel/release.json` | Agent Spoke deployment pipeline |
| Runtime | `artifacts/citadel/spoke-profile.json` | workload platform owner and Agent Spoke deployment pipeline |
| Deployment | `artifacts/agents/policy-assistant/agent.json` | Foundry agent deployment scripts |
| Deployment | `artifacts/agents/policy-assistant/instructions.md` | Foundry agent deployment scripts |
| Deployment | `artifacts/agents/policy-assistant/tool-manifest.json` | Foundry agent deployment scripts |

Install the toolchain required by the selected pinned AI Landing Zones implementation. Install Azure CLI, `curl`, `jq`, and Python 3 for the included Foundry agent scripts.

## Decisions and stop conditions

Stop when the AI Landing Zones checkout is unpinned, the portal template would pull moving templates for a production-shaped deployment, the workload network is not approved, the agent identity or model deployment is unknown, the tool exposes a write operation, or an optional component lacks an owner.

The Portal deployment is acceptable for bounded exploration. Use pinned Bicep or Terraform for the retained implementation.

## Implement

### 1. Complete the spoke profile

Resolve the resource group, VNet, subnet, region, runtime, and optional-component choices. Review the source commit and deployment plan with the workload platform owner.

### 2. Deploy or integrate the Agent Spoke

Use the pinned AI Landing Zones implementation through the customer pipeline. Record its release commit and customer parameters beside the workload deployment. Do not copy generated endpoints or credentials into this repository.

### 3. Run agent preflight

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $subscriptionId `
  -ResourceGroupName $resourceGroup `
  -FoundryAccountName $foundryAccount `
  -ProjectName $projectName `
  -ReadApiBaseUrl $readApiBaseUrl
```

```bash
./scripts/preflight.sh \
  --approved-subscription-id "$subscription_id" \
  --resource-group-name "$resource_group" \
  --foundry-account-name "$foundry_account" \
  --project-name "$project_name" \
  --read-api-base-url "$read_api_base_url"
```

### 4. Create the governed agent

```powershell
.\scripts\deploy.ps1 `
  -ApprovedSubscriptionId $subscriptionId `
  -ResourceGroupName $resourceGroup `
  -FoundryAccountName $foundryAccount `
  -ProjectName $projectName `
  -ReadApiBaseUrl $readApiBaseUrl
```

```bash
./scripts/deploy.sh \
  --approved-subscription-id "$subscription_id" \
  --resource-group-name "$resource_group" \
  --foundry-account-name "$foundry_account" \
  --project-name "$project_name" \
  --read-api-base-url "$read_api_base_url"
```

## Confirm the result

Inspect the live Foundry agent. It has a fixed version selector, Entra authorization, a unique identity, the approved model deployment, and one read-only policy lookup tool. The workload owner can name every deployed Agent Spoke component and its operator.

## After implementation

The workload team owns the spoke profile and agent files. The Foundry project is authoritative for live agent versions. Session 04 grants model and tool access through Citadel. Restore by selecting the prior approved agent version and redeploying the previous workload parameters through the customer pipeline.
