# Deploy a Citadel Agent Spoke and governed agent

## Session scope

### What we will do

**Create one workload execution plane and one governed agent.** We will deploy the pinned AI
Landing Zones Bicep pattern into the existing platform network, then create the policy-assistant
reference agent with Entra authorization and one customer-supplied read-only OpenAPI operation. The
result is a versioned workload ready for Citadel contract onboarding.

### Why it matters

The full Agent Spoke reference can deploy more infrastructure than a first workload needs. Choosing the workload boundary first avoids unused compute, ingress, administration VMs, and duplicate shared services.

### Boundaries

This session owns one nonproduction workload environment and agent. The customer profile maps to the
pinned upstream Bicep entry point; it does not fork that source. Foundry owns the live agent version
and endpoint. Session 04 grants access through the Governance Hub.

## Architecture

### Architecture at a glance

AI Landing Zones separates its architecture from its deployable patterns. Session 03 pins the
architecture repository for design context and Bicep release `v2.6.1` for deployment. The spoke
uses the existing platform VNet and the shared Governance Hub. It does not add another APIM gateway.

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

The Foundry Agent Service standard setup creates its own Search, Storage, Cosmos DB, and Key Vault
dependencies. The profile disables the separate workload copies of those services. Add a workload
service only when the agent needs data outside its managed setup.

`spoke-profile.json` records the workload shape. The preflight scripts verify the upstream Git
remote and commit, generate Bicep parameters, and run a resource-group deployment preview. The
deployment scripts apply those exact parameters. Azure owns live infrastructure state, while the
customer pipeline reconciles it from the pin and profile.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| Spoke boundary | One per workload ownership and data boundary | Keeps access, cost, and lifecycle ownership coherent | Large workloads may need further isolation |
| Gateway | Use the shared Governance Hub | Avoids a second policy and routing plane | Requires reliable hub connectivity |
| Deployment path | Pinned Bicep release `v2.6.1` | Gives both shell paths one source and one parameter contract | Terraform needs a separate customer root module and is outside this session |
| Runtime | Foundry Agent Service | Keeps the first agent close to its data and owner | Another runtime needs its own release and network design |
| Optional infrastructure | Exclude Application Gateway, jump/build VMs, self-hosted models, and local APIM unless required | Reduces cost and attack surface | Later requirements need another reviewed deployment |
| Agent endpoint | Fixed approved version | Gives evaluation and promotion a stable target | Version changes require promotion |
| Tool scope | One customer-supplied read-only operation | Keeps the first authorization path understandable | Write actions need a separate threat model and approval path |

### Architecture guidance

- [Microsoft Foundry Agent Service](https://learn.microsoft.com/azure/foundry/agents/overview)
- [Role-based access control for Microsoft Foundry](https://learn.microsoft.com/azure/foundry/concepts/rbac-foundry)

## Before you start

Use the [upstream AI Landing Zones Bicep documentation](https://github.com/Azure/bicep-ptn-aiml-landing-zone/tree/v2.6.1)
for the full Bicep contract and supported workload shapes. This guide selects one customer path and
owns the network choices, deployment profile, governed agent boundary, and operating handoff.

Choose the workload subscription, resource group, existing VNet, platform-owned route table, two
subnet ranges, Foundry names, model deployment, and Application Insights name. The profile disables
Container Apps, public ingress, separate workload data services, administration VMs, and a spoke
firewall. Change those switches only when an owner and current requirement exist.

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

Install Git, Azure CLI with Bicep, `curl`, `jq`, and Python 3. PowerShell operators need PowerShell
7. The deployment identity needs permission to deploy the profile into the Agent Spoke resource
group and assign the roles created by the upstream pattern.

## Decisions and stop conditions

Stop when the AI Landing Zones checkout does not match the recorded remote and commit, the deployment
preview contains an unapproved resource or deletion, the existing VNet is wrong, the model choice is
unresolved, the tool exposes a write operation, or an optional component lacks an owner.

The Portal deployment is acceptable for bounded exploration. This retained path uses the pinned
Bicep release.

## Implement

### 1. Complete the spoke and agent definitions

Resolve every `__REQUIRED_*__` value under `artifacts/`. Use full resource IDs for the existing VNet
and its platform-owned route table. Set approved, non-overlapping ranges for the Agent Service and
private-endpoint subnets. The model deployment name in `spoke-profile.json` must match `agent.json`.

### 2. Check out the pinned Bicep implementation

Keep the upstream source outside this repository. The preflight rejects another remote, commit, or
a checkout with local changes.

```powershell
git clone https://github.com/Azure/bicep-ptn-aiml-landing-zone.git $sourcePath
git -C $sourcePath checkout 64195c01b70974fa7256c2f54a0035fb06804139
```

```bash
git clone https://github.com/Azure/bicep-ptn-aiml-landing-zone.git "$source_path"
git -C "$source_path" checkout 64195c01b70974fa7256c2f54a0035fb06804139
```

### 3. Preview the Agent Spoke deployment

```powershell
.\scripts\preflight.ps1 `
  -SourcePath $sourcePath `
  -ApprovedSubscriptionId $subscriptionId `
  -DeploymentPrincipalId $deploymentPrincipalId
```

```bash
./scripts/preflight.sh \
  --source-path "$source_path" \
  --approved-subscription-id "$subscription_id" \
  --deployment-principal-id "$deployment_principal_id"
```

Review the resource-group what-if output. Continue only when it matches `spoke-profile.json` and
contains no unexpected deletion.

### 4. Deploy the Agent Spoke

The PowerShell path asks for high-impact confirmation. The Bash path requires `--apply`.

```powershell
.\scripts\deploy-spoke.ps1 `
  -SourcePath $sourcePath `
  -ApprovedSubscriptionId $subscriptionId `
  -DeploymentPrincipalId $deploymentPrincipalId
```

```bash
./scripts/deploy-spoke.sh \
  --source-path "$source_path" \
  --approved-subscription-id "$subscription_id" \
  --deployment-principal-id "$deployment_principal_id" \
  --apply
```

### 5. Check the deployed spoke

Resolve the Application Insights resource ID from the component named in the profile. This check
confirms the Foundry project, model, agent identity prerequisites, telemetry, and read-only tool
boundary before agent creation.

```powershell
$applicationInsightsId = az monitor app-insights component show `
  --app $applicationInsightsName `
  --resource-group $resourceGroup `
  --query id `
  --output tsv

.\scripts\check-spoke.ps1 `
  -ApprovedSubscriptionId $subscriptionId `
  -ResourceGroupName $resourceGroup `
  -FoundryAccountName $foundryAccount `
  -ProjectName $projectName `
  -ReadApiBaseUrl $readApiBaseUrl `
  -ApplicationInsightsResourceId $applicationInsightsId
```

```bash
application_insights_id=$(az monitor app-insights component show \
  --app "$application_insights_name" \
  --resource-group "$resource_group" \
  --query id \
  --output tsv)

./scripts/check-spoke.sh \
  --approved-subscription-id "$subscription_id" \
  --resource-group-name "$resource_group" \
  --foundry-account-name "$foundry_account" \
  --project-name "$project_name" \
  --read-api-base-url "$read_api_base_url" \
  --application-insights-resource-id "$application_insights_id"
```

### 6. Create the governed agent

```powershell
.\scripts\deploy-agent.ps1 `
  -ApprovedSubscriptionId $subscriptionId `
  -ResourceGroupName $resourceGroup `
  -FoundryAccountName $foundryAccount `
  -ProjectName $projectName `
  -ReadApiBaseUrl $readApiBaseUrl
```

```bash
./scripts/deploy-agent.sh \
  --approved-subscription-id "$subscription_id" \
  --resource-group-name "$resource_group" \
  --foundry-account-name "$foundry_account" \
  --project-name "$project_name" \
  --read-api-base-url "$read_api_base_url"
```

## Confirm the result

Inspect the deployed resource group and live Foundry agent. The resources match the approved profile.
The agent has a fixed version selector, Entra authorization, a unique identity, the approved model
deployment, and one read-only policy lookup tool.

## After implementation

The workload team owns the source pin, spoke profile, and agent files. The Foundry project remains
authoritative for live agent versions. Session 04 grants model and tool access through Citadel.
Restore infrastructure by checking out the prior recorded Bicep commit and applying the previous
profile through the same preview and deployment path. Restore the agent by selecting its prior
approved version.
