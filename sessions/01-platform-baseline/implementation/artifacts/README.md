# Implementation artifacts

These files deploy one small sandbox baseline and stage the Azure Policy guardrails on top of it:

- a current Foundry `AIServices` account with local authentication disabled;
- one child project, with a system-assigned identity on each boundary;
- one Log Analytics workspace and workspace-based Application Insights component;
- one project-level `AppInsights` connection;
- a subscription-scope initiative built from the current allowed-locations and required-tag
  built-ins; and
- a resource-group assignment of that initiative, staged in `DoNotEnforce` and promoted to
  `Default` after review.

The public network setting is parameterized. This tree does not add private endpoints, model
deployments, additional role assignments, or a management-group policy definition.

## Design choices

| Choice | Reason |
|---|---|
| Stable `2026-05-01` Foundry APIs | Current non-preview account, project, and connection schemas |
| System-assigned identities | Establish durable principals without adding a credential |
| `disableLocalAuth: true` | Keep Foundry data-plane access on Microsoft Entra authentication |
| Workspace-based Application Insights | Provide the trace destination used by later sessions |
| Connection string resolved inside Bicep | Keep it out of parameter files, outputs, and source control |
| Stable `uniqueString()` suffix | Preserve names across repeat deployments to the same scope |
| Seven common tags | Make ownership, risk, cost, and expiry inspectable |
| Current Microsoft built-ins grouped in one initiative | Reference and parameters stay together; Microsoft still owns the underlying rules |
| Staged `DoNotEnforce` before `Default` | Shows likely impact before Azure starts denying requests |

## Build

```powershell
az bicep build --file .\infra\foundry\main.bicep
az bicep build --file .\policy\initiative.bicep
az bicep build --file .\policy\assignment.bicep
```

## Operational ownership

Azure holds the deployed resource, policy assignment, compliance, and exemption state. Platform
operations keeps live inventory and classic-migration work in the customer systems that own those
records. The cloud platform owner uses the normal change and risk process to approve enforcement
or exemptions. Those one-time decisions do not belong in this repository.

`scripts/resolve-builtins.ps1` resolves current built-ins outside Bicep and returns their IDs,
versions, and effects to the current shell. Re-resolve them before each implementation. The script
does not write a separate output package.

`policy/guardrail-settings.json` is the only required-tag source. Both policy parameter files load
it, and preflight rejects a divergent or malformed reference.

## Deploy

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name "rvas-s01-baseline" `
  --parameters .\environments\sandbox.bicepparam `
  --only-show-errors

az deployment sub create `
  --location $location `
  --name "rvas-s01-guardrails-initiative" `
  --parameters .\environments\initiative.bicepparam `
  --only-show-errors

az deployment group create `
  --resource-group $resourceGroup `
  --name "rvas-s01-guardrails-assignment" `
  --parameters .\environments\policy-assignment.bicepparam `
  --only-show-errors
```

Replace every `__REQUIRED_*__` value first. Run `..\scripts\preflight.ps1` so unresolved
decisions, target-scope problems, or an unexpected deployment preview stop the change. Keep
credentials and customer data out of parameters, tags, outputs, and the repository.
