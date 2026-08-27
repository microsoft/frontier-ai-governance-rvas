# Implementation artifacts

These files deploy one small sandbox baseline:

- a current Foundry `AIServices` account with local authentication disabled;
- one child project, with a system-assigned identity on each boundary;
- one Log Analytics workspace and workspace-based Application Insights component; and
- one project-level `AppInsights` connection.

The public network setting is parameterized. This tree does not add private endpoints,
model deployments, role assignments, Azure Policy, or customer data.

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

## Build

```powershell
az bicep build --file .\infra\foundry\main.bicep
```

## Operating record

[`decisions/resource-model.md`](decisions/resource-model.md) keeps the current-versus-classic
decision and points to the customer's inventory or migration backlog. Live resource details stay
in that customer system.

## Deploy

```powershell
az deployment group create `
  --resource-group $resourceGroup `
  --name "rvas-s01-baseline" `
  --parameters .\environments\sandbox.bicepparam `
  --only-show-errors
```

Replace every `__REQUIRED_*__` value first. Run `..\scripts\preflight.ps1` so unresolved
decisions, target-scope problems, or an unexpected deployment preview stop the change. Keep
credentials and customer data out of parameters, tags, outputs, and the repository.
