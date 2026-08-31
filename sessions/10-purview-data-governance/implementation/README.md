# Implement Purview data governance and Agent 365 data controls

## Session scope

### What we will do

Configure one Agent 365 DLP policy for the approved nonproduction scope from current Microsoft
Purview state. After simulation and propagation, confirm the intended result, one out-of-scope
non-match, agent availability, and payload-free audit activity. This path supports agents from
**Microsoft Foundry, Copilot Studio, and Agent Builder**.

Keep a source-controlled ownership record for Agent 365 and the selected source platform. If
`agent.platform` is `foundry`, also record the separate Foundry Data Security DLP path.

### Why it matters

Agent 365 DLP is the common control. The ownership record makes the source-platform boundary
explicit, while Purview remains authoritative for labels, policies, findings, and audit activity.

### Boundaries

The change covers one approved nonproduction Agent 365 instance, test group, sensitivity label,
action, interaction directions, and set of locations. Purview and the approved change system hold
the policy coordinates, simulation, enablement, results, and restore decision.

The selected source platform continues to own the published agent and runtime. For a Foundry agent,
the Agent 365 policy does not govern Foundry calls. Foundry DLP needs an Entra-app-scoped rule and
application integration that calls Microsoft Graph `processContent` with signed-in user context.
That conditional extension remains a separate approved change. Do not apply it to Copilot Studio or
Agent Builder.

Keep tenant IDs, source URLs, prompts, responses, identities, file names, audit exports, findings,
screenshots, and portal-state copies out of the repository.

## Architecture

### Architecture at a glance

![Agent 365 and Microsoft Foundry use separate control paths that feed shared Purview visibility.](../assets/diagrams/purview-product-coverage-split.svg)

On the Agent 365 path, Purview evaluates the agent, group, direction, location, and label. It then
applies the approved `Block` or `Audit` action. The audit scripts query current activity and display
five payload-free fields.

`coverage-handoff.md` names the Agent 365 and source-platform owners.
`agent-activity-audit-query.json` defines the repeatable Agent 365 query. For Foundry, the handoff
also names the separate Foundry Data Security owners.

### Design choices and tradeoffs

| Decision | Chosen approach | Tradeoff |
|---|---|---|
| Product boundary | Keep Agent 365 and the source-platform runtime separate | Foundry adds a second DLP path |
| DLP scope | One nonproduction agent and test group | Broader rollout needs another approval |
| Action | Use the approved `Block` or `Audit` choice | `Block` can interrupt work; `Audit` does not stop it |
| Audit output | Display metadata fields without an export | Investigation detail stays in Purview |

### Architecture guidance

- [Purview guidance for Microsoft Agent 365](https://learn.microsoft.com/en-us/purview/ai-agent-365)
- [Purview guidance for Microsoft Foundry](https://learn.microsoft.com/en-us/purview/ai-azure-foundry)
- [Create and deploy a DLP policy](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)

## Before you start

Confirm:

- Session 06 records one approved `foundry`, `copilot-studio`, or `agent-builder` platform value,
  the exact Agent 365 instance, test group, host product, and validation aliases.
- For `foundry` only, the Sessions 01-07 records identify the responsible-AI and model-evaluation
  records, Entra application ID, user-context authentication flow, and exact APIM `get_policy`
  path.
- The data owner approved the nonproduction Agent 365 instance, test group, synthetic labelled
  item, label and encryption rights, DLP action and locations, generated-content control, and
  restore route.
- The required Purview, Agent 365, Audit, and DLP entitlements are confirmed. Agent 365 needs a
  qualifying license; Microsoft recommends E5. For the Foundry Data Security extension, also
  confirm its pay-as-you-go requirement.
- The DLP and label operator has **Compliance Data Administrator** in the approved Microsoft 365
  tenant.
- The audit operator has **View-Only Audit Logs** in both Microsoft Purview and the Exchange admin
  center.
- The Microsoft Graph application used for Audit Search has the
  `AuditLogsQuery.Read.All` application permission with administrator consent.
- The Purview operator, Agent 365 owner, source-platform owner, information protection owner, data
  owner, and audit owner accept their recorded responsibilities. For Foundry, include the Foundry
  platform owner and application developer.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Record | [`artifacts/governance/coverage-handoff.md`](artifacts/governance/coverage-handoff.md) | The data, information protection, Agent 365, source-platform, and audit owners |
| Runtime | [`artifacts/operations/agent-activity-audit-query.json`](artifacts/operations/agent-activity-audit-query.json) | The Agent 365 audit-query scripts |

## Decisions and stop conditions

The approved change and Purview policy summary must match these coordinates:

| Coordinate | Required value |
|---|---|
| Environment | Approved nonproduction environment |
| Agent | One approved Agent 365 instance |
| Origin | `foundry`, `copilot-studio`, or `agent-builder` from the Session 06 contract |
| People | Approved test group |
| Directions | Human-to-agent and agent-to-human |
| Locations | Teams, OneDrive or SharePoint, and email |
| Condition | One approved sensitivity-label ID |
| Action | Recorded `Block` or `Audit` choice |
| Initial state | `TestWithNotifications` |
| Enablement | Approved change after simulation review and the recorded propagation wait |

The DLP operator also records the notification route, incident route, output-label control, and
restore path.

**Stop before the change** if a license, entitlement, owner, role, coordinate, or restore route is
missing; if the live summary is broader than the approved scope; or if production data or payload
retention enters the path.

For an encrypted label, the named Agent 365 instance needs explicit **VIEW** and **EXTRACT** rights
plus a direct share to the selected SharePoint or OneDrive source. “All users in the organization”
does not grant those rights to the agent.

Source labels do not automatically protect new Agent 365 content. Choose a labelled destination
library, mandatory user labelling, or an approved auto-labelling policy before live confirmation.

For `foundry`, do not report Foundry DLP as active without both the app-scoped rule and
`processContent` with user context. Skip that extension for Copilot Studio and Agent Builder.
Update `coverage-handoff.md` after an owner or boundary change and review it quarterly.

## Implement

### 1. Confirm current state and ownership

Read `agent.platform` from the Session 06 contract. Check the approved label, publishing scope,
encrypted-label rights, generated-content control, and synthetic source. Confirm that
`coverage-handoff.md` names the Agent 365 and source-platform owners. For `foundry`, also confirm
the Foundry rule owner and application developer. Keep the current policy and approval in Purview
and the approved change system.

### 2. Run preflight

```powershell
$approvedTenantId = $env:MICROSOFT365_TENANT_ID
$agentInstanceId = $env:AGENT365_INSTANCE_ID

.\scripts\preflight.ps1 `
  -ApprovedTenantId $approvedTenantId `
  -AgentInstanceId $agentInstanceId
```

```bash
approved_tenant_id="${MICROSOFT365_TENANT_ID:?Set MICROSOFT365_TENANT_ID.}"
agent_instance_id="${AGENT365_INSTANCE_ID:?Set AGENT365_INSTANCE_ID.}"

./scripts/preflight.sh \
  --approved-tenant-id "$approved_tenant_id" \
  --agent-instance-id "$agent_instance_id"
```

Preflight checks the supplied tenant and agent scope, Graph permission, retained artifacts, and
payload-free query contract. This portal-led change has no read-only deployment preview. Use the
portal summary and `TestWithNotifications` simulation.

### 3. Configure, simulate, and enable the policy

Create a custom Purview DLP policy from the approved change. Enter the recorded coordinates,
notification and incident routes, and restore path. Start in `TestWithNotifications`.

Review the policy summary and simulation. It must contain the selected agent, group, label,
directions, locations, and nothing else. Enable the policy through the approved change, then wait
for its recorded propagation allowance. Keep it in simulation or restore it if the scope differs.

### 4. Install the approved agent after propagation

Open the Session 06 deployment contract at
`sessions/06-agent-365-access-boundary/implementation/artifacts/agent-deployment.json`. Confirm the
agent, test group, host product, and consent decision. Install that agent for the recorded group and
host product, with the recorded consent.

The included member must find the agent. The excluded user must not. Remove the installation and
stop if either result differs. Use the labelled synthetic source for the later interaction.

For a Foundry agent, confirm the separate app-scoped rule and user-context `processContent`
enforcement path. For Copilot Studio or Agent Builder, keep runtime controls with the named
source-platform owner and continue.

### 5. Query current Agent 365 activity

For PowerShell, connect Exchange Online and Security & Compliance PowerShell to the approved
tenant. For Bash, sign in to Azure CLI as the approved Microsoft Graph application.

```powershell
.\scripts\query-agent-activity.ps1 -AgentInstanceId $agentInstanceId
```

```bash
./scripts/query-agent-activity.sh --agent-instance-id "$agent_instance_id"
```

The scripts filter the current Agent 365 operations to one instance and display creation time,
operation, agent ID, agent name, and result status. They write no audit export.

## Confirm the result

### Intended path

After propagation, run the labelled synthetic interaction through the approved path. `Block` stops
the matched interaction. `Audit` allows it and records the match. Inspect the DLP result, scoped
audit activity, and generated content's label behavior in Purview.

### Blocked or failure path

Repeat the interaction with the approved out-of-scope test-group alias. Keep the agent, source,
label, direction, location, and action unchanged. The policy must **not report a match**.

Stop if the policy reaches a wider scope, the action differs, the output is treated as protected
without the chosen output control, or audit activity remains absent after the recorded ingestion
allowance.

### Delivery-owner checkpoint

The delivery owner observes the propagation wait, included-user availability, excluded-user
denial, intended policy result, non-match, and scoped audit activity. Keep the policy in simulation
or disable it if a check fails. Record both results in Purview and the approved change system.

## After implementation

| What remains | Owner |
|---|---|
| DLP policy, simulation and enablement state, findings, and change history | Purview operator and Agent 365 owner |
| Label, encryption rights, and generated-content control | Information protection owner |
| Agent 365 and source-platform ownership record | Data owner |
| Published agent and native runtime controls | Source-platform owner |
| Payload-free query definition and audit operation | Audit owner |
| Conditional Foundry Data Security, app-scoped rule, and `processContent` integration | Foundry platform owner, Purview operator, and application developer |

Restore through the approved Purview change path:

1. Return the policy to `TestWithNotifications`.
2. Disable it after reviewing dependencies.
3. Remove the scoped agent and group before deleting a policy created for this session.
4. Remove label rights or source sharing only after the data owner confirms that no Agent 365
   dependency remains.

Do not delete a reused label, audit records, or source data. For a Foundry agent, change Foundry
coverage or billing only through its separate dependency review.
