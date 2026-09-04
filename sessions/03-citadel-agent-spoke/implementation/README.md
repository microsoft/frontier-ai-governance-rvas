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

The Agent Spoke isolates workload data, runtime, identity, and optional application compute. The governed agent uses its workload identity and calls approved dependencies through the Citadel hub after Session 04.

```text
Users -> workload entry point -> Foundry agent
                                  |       |
                              workload  Citadel hub
                                data    models/tools
```

`spoke-profile.json` records the selected workload shape. The live landing-zone resources and Foundry agent remain authoritative.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| Deployment | Pinned Bicep or Terraform source | Supports review and repeatable promotion | Requires customer pipeline integration |
| Optional components | Off unless the workload needs them | Smaller cost and attack surface | Later requirements need another change |
| Agent endpoint | Fixed approved version | Stable evaluation and release target | Version changes require promotion |
| Tool scope | One read-only operation | Easy to reason about and test | Write actions need a separate design |

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
