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

The public network setting is a parameter. Private endpoints, model deployments, extra role
assignments, and management-group policy definitions have separate deployments.

## Design choices

| Choice | Reason |
|---|---|
| Stable `2026-05-01` Foundry APIs | Current non-preview account, project, and connection schemas |
| System-assigned identities | Create durable principals without adding a credential |
| `disableLocalAuth: true` | Keep Foundry data-plane access on Microsoft Entra authentication |
| Workspace-based Application Insights | Provides the trace destination used by later sessions |
| Connection string resolved inside Bicep | Exclude it from parameter files, outputs, and source control |
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
operations maintains live inventory and the classic-migration backlog in the customer systems. The
cloud platform owner approves enforcement and exemptions through the customer change and risk process.

`scripts/resolve-builtins.ps1` resolves current built-ins outside Bicep and returns their IDs,
versions, and effects to the current shell. Resolve them again before each implementation.

`policy/guardrail-settings.json` is the required-tag source. Both policy parameter files load it,
and preflight rejects an inconsistent or malformed reference.
