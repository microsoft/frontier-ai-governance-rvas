# Implementation artifacts

These artifacts deploy a sandbox baseline and stage Azure Policy guardrails:

- a current Foundry `AIServices` account with local authentication disabled;
- one child project, with a system-assigned identity on each resource;
- one Log Analytics workspace and workspace-based Application Insights component;
- one project-level `AppInsights` connection;
- a subscription-scope initiative that uses the current allowed-locations and required-tag
  built-ins; and
- a resource-group assignment of that initiative, first staged in `DoNotEnforce` and changed to
  `Default` after review.

The public network setting is a parameter. This tree does not add private endpoints, model
deployments, extra role assignments, or a management-group policy definition.

## Design choices

| Choice | Reason |
|---|---|
| Stable `2026-05-01` Foundry APIs | Current non-preview account, project, and connection schemas |
| System-assigned identities | Create durable principals without adding a credential |
| `disableLocalAuth: true` | Keep Foundry data-plane access on Microsoft Entra authentication |
| Workspace-based Application Insights | Provides the trace destination used by later sessions |
| Connection string resolved inside Bicep | Keep it out of parameter files, outputs, and source control |
| Stable `uniqueString()` suffix | Keeps names stable across repeat deployments to the same scope |
| Seven common tags | Makes ownership, risk, cost, and expiry easy to inspect |
| Current Microsoft built-ins grouped in one initiative | Keeps references and parameters together; Microsoft still owns the underlying rules |
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
records. The cloud platform owner approves enforcement or exemptions through the normal change and
risk process. Keep those decisions out of this repository.

`scripts/resolve-builtins.ps1` resolves current built-ins outside Bicep and returns their IDs,
versions, and effects to the current shell. Resolve them again before each implementation. The
script does not write an output package.

`policy/guardrail-settings.json` is the required-tag source. Both policy parameter files load it,
and preflight rejects an inconsistent or malformed reference.

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

Replace every `__REQUIRED_*__` value first. Run `..\scripts\preflight.ps1`. It stops the change
when decisions are unresolved, the target scope is wrong, or a deployment preview is unexpected.
Keep credentials and customer data out of parameters, tags, outputs, and the repository.
