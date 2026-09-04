# Citadel platform foundation and landing-zone guardrails

## Session scope

### What we will do

**Prepare the Azure foundation that Citadel will use.** We will record the hub-and-spoke boundary, deploy or reconcile the dedicated network subnets, and stage required-tag guardrails. The session ends when the approved execution host can use the private network path and Azure Policy previews only the intended scope.

### Why it matters

Citadel can deploy a large set of shared and workload resources. If subscription, network, DNS, ownership, and policy decisions stay unresolved, the accelerator turns those gaps into deployment failures or unsafe defaults. This session fixes that before the hub exists.

### Boundaries

This session changes the approved nonproduction foundation and policy scope. Azure remains authoritative for live network and assignment state; this repository owns the reusable Bicep and parameters. Session 02 deploys the Governance Hub. It does not happen here.

## Architecture

### Architecture at a glance

The customer landing zone provides subscription governance, connectivity, identity, and monitoring ownership. Citadel adds one shared Governance Hub and one or more workload Agent Spokes. This session prepares the network and policy boundary both deployment types inherit.

```text
Management group and subscription guardrails
                    |
         customer platform network
          /                     \
Governance Hub subnets      Agent Spoke subnets
          \                     /
       private DNS and controlled egress
```

The live Azure resources are authoritative. The parameter files record the desired network and policy configuration used by the approved deployment pipeline.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| Network | Reuse the customer platform network when it already meets Citadel requirements | Keeps routing, DNS, and inspection with the platform team | Requires clear subnet delegation and ownership |
| Public access | Private paths for production-shaped work | Reduces direct service exposure | Needs DNS, execution-host, and egress preparation |
| Policy rollout | Preview, then assign in `DoNotEnforce` before enforcement | Shows scope and conflicts before blocking deployments | Requires a later owner-approved enforcement change |
| Upstream source | Pin reviewed Citadel commits | Makes deployments repeatable | The platform owner must plan upgrades |

### Architecture guidance

- [Azure landing zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Policy overview](https://learn.microsoft.com/azure/governance/policy/overview)

## Before you start

Name the subscription, resource groups, region, network owner, DNS owner, policy owner, deployment identity, required tags, and expiry date. Confirm that the address ranges do not overlap existing networks.

### Implementation files

| Type | File | Consumer |
| --- | --- | --- |
| Deployment | `artifacts/environments/network-foundation.bicepparam` | Citadel foundation deployment pipeline |
| Deployment | `artifacts/environments/initiative.bicepparam` | governance deployment pipeline |
| Deployment | `artifacts/environments/policy-assignment.bicepparam` | governance deployment pipeline |
| Deployment | `artifacts/infra/network/main.bicep` | Citadel foundation deployment pipeline |
| Runtime | `artifacts/policy/guardrail-settings.json` | policy initiative and assignment deployments |
| Deployment | `artifacts/policy/initiative.bicep` | governance deployment pipeline |
| Deployment | `artifacts/policy/assignment.bicep` | governance deployment pipeline |

Install Azure CLI with Bicep support, PowerShell 7 when using PowerShell, Git, and Python 3. Sign in to the approved subscription.

## Decisions and stop conditions

| Decision | Record before implementation |
| --- | --- |
| Topology | Shared hub subscription, workload subscription pattern, and owners |
| Network | VNet, subnets, address ranges, firewall next hop, DNS zones, and execution host |
| Governance | Required tags, assignment scope, initial enforcement mode, and exemption owner |
| Release | Citadel upstream repositories, tested commits, and upgrade owner |

Stop when the target subscription is wrong, an address range overlaps, the firewall route is unapproved, private DNS ownership is unclear, inherited policy has not been reviewed, or deployment what-if includes resources outside the recorded scope.

## Implement

### 1. Complete the parameters

Replace every `__REQUIRED_*__` value in the three parameter files and `guardrail-settings.json`. Keep credentials and subscription IDs out of committed files when the deployment system can supply them securely.

### 2. Resolve current built-in policy identifiers

```powershell
.\scripts\resolve-builtins.ps1
```

```bash
./scripts/resolve-builtins.sh
```

Review the resolved identifiers before the initiative is deployed.

### 3. Run foundation preflight and deployment previews

```powershell
.\scripts\preflight.ps1 `
  -ResourceGroupName $resourceGroup `
  -DeploymentLocation $location `
  -ConfirmInheritedPolicyReview
```

```bash
./scripts/preflight.sh \
  --resource-group-name "$resource_group" \
  --deployment-location "$location" \
  --confirm-inherited-policy-review
```

Apply the approved network deployment and policy changes through the customer deployment pipeline. Keep the assignment in `DoNotEnforce` until the governance owner reviews the live result.

### 4. Check the execution path

Run the connectivity check from the host that will deploy and operate Citadel.

```powershell
.\scripts\connectivity-check.ps1 -TargetHostName $privateHostName
```

```bash
./scripts/connectivity-check.sh --target-hostname "$private_host_name"
```

## Confirm the result

Inspect the deployed subnets, route table, private DNS resolution, and policy assignment. The execution host resolves the approved private endpoint path, and policy what-if contains only the intended Citadel scope.

## After implementation

The platform team owns the network and policy definitions. The network owner manages route and DNS changes. The governance owner decides when to move the assignment from audit to enforcement. Restore by reverting the parameter change and using the approved deployment pipeline; remove only resources carrying the session implementation marker.
