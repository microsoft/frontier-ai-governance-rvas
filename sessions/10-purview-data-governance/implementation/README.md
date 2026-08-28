# Purview data governance and Agent 365 data controls

## Session scope

### What we will do

Keep a source-controlled file that assigns owners for the Agent 365 and Foundry DLP paths.
Configure an Agent 365 DLP policy for the approved nonproduction scope from current Microsoft
Purview state. Then run a payload-free audit query. Confirm a configured match, an out-of-scope
non-match, and current audit activity in Purview.

### Why it matters

Agent 365 and Foundry use separate DLP control paths. `coverage-handoff.md` names the owner for
each path and where the product boundary falls. Purview is the source for policy, label, DSPM, and
audit state.

### Boundaries

The DLP change covers the approved nonproduction Agent 365 instance, test group, sensitivity label,
and interaction directions and locations. Operators record policy scope, simulation, enablement,
propagation, and results in Purview and the approved change system. Microsoft Purview stores labels,
policy state, findings, and audit activity.

The Agent 365 policy does not govern Foundry calls. Foundry DLP requires an Entra-app-scoped rule and
an application integration that calls Microsoft Graph `processContent` with signed-in user context.
That work remains with the Purview operator and application developer. Do not retain prompts,
responses, identities, audit exports, findings summaries, screenshots, or portal-state copies here.

## Architecture

### Architecture at a glance

![Agent 365 and Microsoft Foundry share Purview Audit and DSPM paths, while DLP scope, enablement, billing, user context, and manual checks remain product-specific](../assets/diagrams/purview-product-coverage-split.svg)

Purview evaluates the Agent 365 path against the selected agent, group, direction, location, and
label. It applies the approved `Block` or `Audit` action. The audit script asks Purview for current
activity and prints five payload-free fields.

Foundry Data Security follows a separate path. Operators use Purview and the approved change system
to review both paths. `coverage-handoff.md` names the owners, and
`agent-activity-audit-query.json` defines the repeatable audit query.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Product boundary | Agent 365 DLP and Foundry DLP stay separate. | Avoids a false coverage claim. | Owners manage two paths. | Microsoft adds a shared supported enforcement path. |
| DLP scope | One nonproduction agent and test group. | Limits impact while validating the control. | Does not approve broader deployment. | The approved scope changes. |
| Audit output | Query only metadata fields at runtime. | Supports operations without exporting content. | Investigation detail stays in Purview. | Purview changes Agent 365 audit operations. |
| Coverage handoff file | Name the owner of each Agent 365 and Foundry DLP responsibility in Markdown. | Shows responsibilities that no platform view presents together. | The data owner reviews it quarterly. | A product boundary or owner changes. |

### Architecture guidance

Use the [Purview guidance for Microsoft Agent 365](https://learn.microsoft.com/en-us/purview/ai-agent-365)
for DLP scope, encrypted-label rights, and audit coverage. Use the separate
[Purview guidance for Microsoft Foundry](https://learn.microsoft.com/en-us/purview/ai-azure-foundry)
for its enablement and application-integration boundary. The
[DLP deployment guidance](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy) covers
simulation and enablement.

## Before you start

Confirm these prerequisites:

- The selected Agent 365 instance, test group, label, and restore route are approved for a
  nonproduction change.
- The data owner approves the source, classification, label, encryption rights, and `Block` or
  `Audit` action. The source is synthetic.
- The DLP operator has **Compliance Data Administrator** in the approved Microsoft 365 tenant.
- The audit operator has **View-Only Audit Logs** in Purview and the Exchange admin center.
- The Microsoft Graph application used for the audit query has
  `AuditLogsQuery.Read.All` with administrator consent.
- The Purview operator, Foundry platform owner, and application developer own the Foundry DLP
  rule and `processContent` handoff separately.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Record | [`artifacts/governance/coverage-handoff.md`](artifacts/governance/coverage-handoff.md) | The data, information protection, Agent 365, Foundry, and audit owners |
| Runtime | [`artifacts/operations/agent-activity-audit-query.json`](artifacts/operations/agent-activity-audit-query.json) | The Agent 365 audit-query scripts |

## Decisions and stop conditions

Use aliases and role names in the repository. Keep tenant IDs, source URLs, prompts, responses,
user identities, file names, audit exports, findings, and screenshots in Purview and the approved
change systems.

Stop before the change when:

- the approved Purview change does not name one Agent 365 instance, group, label, directions,
  locations, action, and restore route;
- an encrypted label lacks explicit VIEW and EXTRACT rights for the agent instance;
- the policy summary includes another agent, group, location, label, direction, or action;
- Foundry DLP is represented as active without both the app-scoped rule and `processContent` user
  context; or
- the scope includes production data or payload retention.

Update `coverage-handoff.md` after a product boundary or owner change, and review it quarterly. The
current policy and its approval stay in Purview and the approved change system.

## Implement

### 1. Confirm the current Purview state

In Microsoft Purview, confirm the existing label, publishing scope, encrypted-label rights, and the
approved nonproduction source. Use DSPM and the Foundry Data Security views for current findings and
enablement. Record approvals, simulation, and findings in Purview or the approved change system.

### 2. Run the preflight

Supply the current tenant and agent identifiers through the shell:

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

Preflight checks the supplied tenant and agent scope, the Graph permission, and the query shape.
It does not export or copy Purview state.

A read-only deployment preview is unsupported for this portal-led DLP change. The safe preview is
the current portal summary followed by `TestWithNotifications` simulation.

### 3. Configure the Agent 365 DLP policy for the approved scope

Create a custom Purview DLP policy from the approved change record. Use the exact agent instance,
test group, directions, locations, label, action, notification, incident route, and restore path.
Start in `TestWithNotifications`. Review the portal summary and simulation, then enable the policy
through the approved change. Wait for the propagation period in that change before live confirmation.

### 4. Query current Agent 365 activity

Before running the query, connect Exchange Online and Security & Compliance PowerShell to the
approved Microsoft 365 tenant.

Run the query with the same current agent identifier:

```powershell
.\scripts\query-agent-activity.ps1 -AgentInstanceId $agentInstanceId
```

```bash
./scripts/query-agent-activity.sh --agent-instance-id "$agent_instance_id"
```

The scripts display time, operation, agent ID, agent name, and result status. They do not write an
audit export.

## Confirm the result

### Intended path

After propagation, run the labelled synthetic interaction through the approved path. `Block` stops
the matched interaction. `Audit` allows it and records the match. Inspect the policy result and
scoped audit activity in Purview.

### Blocked or failure path

Run the interaction again with the approved out-of-scope test-group alias. Keep the agent, source,
label, direction, location, and action unchanged. The policy must not report a match. Stop if the
scope is wider than approved, the observed action differs, or audit activity remains absent after
the stated ingestion allowance.

### Delivery-owner checkpoint

The delivery owner observes the propagation wait, intended result, non-match, and scoped audit
activity. Keep the policy in simulation or disable it if a check fails. Record the outcome in
Purview and the approved change system.

## After implementation

Microsoft Purview retains the DLP policy, label state, findings, audit activity, and change history.
`coverage-handoff.md` records who owns each product path, and
`agent-activity-audit-query.json` defines the audit query. The data owner updates the handoff file.
The information protection owner maintains labels. The Agent 365 owner monitors workflow impact,
and the audit owner updates the query.

Restore through the approved Purview change path: return the policy to `TestWithNotifications`,
disable it after dependency review, and remove the scoped instance and group before deleting a
session-created policy. Do not delete a reused label, Foundry coverage, audit records, or source
data as a shortcut.
