# Purview data governance and Agent 365 data controls

## Session scope

### What we will do

Use a source-controlled file to assign owners for the Agent 365 and Foundry DLP paths. Configure
an Agent 365 DLP policy for the approved nonproduction scope using current Microsoft Purview state.
Reuse the approved label. Simulate the policy, enable it through the approved change, and wait for
propagation. Then run a payload-free audit query. Confirm a configured match, an out-of-scope
non-match, and current audit activity in Purview.

### Why it matters

Agent 365 and Foundry use separate DLP control paths. `coverage-handoff.md` names the owner for
each path and where the product boundary falls. This distinction avoids treating an Agent 365 DLP
policy as Foundry protection. Purview is the source for policy, label, DSPM, and audit state.

### Boundaries

The DLP change covers the approved nonproduction Agent 365 instance, test group, sensitivity label,
and interaction directions and locations. Operators record policy scope, simulation, enablement,
propagation, and results in Purview and the approved change system. Microsoft Purview stores labels,
policy state, findings, and audit activity.

The Agent 365 policy does not govern Foundry calls. Foundry DLP requires an Entra-app-scoped rule and
an application integration that calls Microsoft Graph `processContent` with signed-in user context.
Record the Foundry owner and application-integration handoff. Foundry Data Security, the Foundry DLP
rule, and application changes belong to that separate path. Keep prompts, responses, identities,
audit exports, findings summaries, screenshots, and portal-state copies out of the repository.

## Architecture

### Architecture at a glance

![Agent 365 and Microsoft Foundry share Purview Audit and DSPM paths, while DLP scope, enablement, billing, user context, and manual checks remain product-specific](../assets/diagrams/purview-product-coverage-split.svg)

Purview evaluates the Agent 365 path against the selected agent, group, direction, location, and
label. It applies the approved `Block` or `Audit` action. The audit script asks Purview for current
activity and prints five payload-free fields.

Foundry Data Security follows a separate path. `coverage-handoff.md` names the Purview operator,
Foundry platform owner, and application developer responsible for its rule and application
integration. `agent-activity-audit-query.json` defines the repeatable audit query for Agent 365.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations | Revisit when |
|---|---|---|---|---|
| Product boundary | Agent 365 DLP and Foundry DLP stay separate. | Avoids a false coverage claim. | Owners manage two paths. | Microsoft adds a shared supported enforcement path. |
| DLP scope | One nonproduction agent and test group. | Limits impact while validating the control. | Broader deployment uses a separate release approval. | The approved scope changes. |
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
- Confirm a qualifying Agent 365 license, E5 or an approved exception, and the Purview DLP, Audit,
  DSPM, and eDiscovery entitlements for the approved path.
- The data owner approves the source, classification, label, encryption rights, and `Block` or
  `Audit` action. The source is synthetic.
- The DLP operator has **Compliance Data Administrator** in the approved Microsoft 365 tenant.
- The audit operator has View-Only Audit Logs in Purview and the Exchange admin center.
- The Microsoft Graph application used for the audit query has
  `AuditLogsQuery.Read.All` with administrator consent.
- The Purview operator, Foundry platform owner, and application developer own the Foundry DLP
  rule and `processContent` handoff separately. If that Foundry path needs pay-as-you-go policy
  billing, its owner obtains approval through the finance process.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Record | [`artifacts/governance/coverage-handoff.md`](artifacts/governance/coverage-handoff.md) | The data, information protection, Agent 365, Foundry, and audit owners |
| Runtime | [`artifacts/operations/agent-activity-audit-query.json`](artifacts/operations/agent-activity-audit-query.json) | The Agent 365 audit-query scripts |

## Decisions and stop conditions

Use aliases and role names in the repository. Keep tenant IDs, source URLs, prompts, responses,
user identities, file names, audit exports, findings, and screenshots in Purview and the approved
change systems.

**Stop before the change** when:

- the qualifying Agent 365 license, E5 or approved exception, or a required Purview entitlement is
  unconfirmed;
- the approved Purview change does not name one Agent 365 instance, group, label, directions,
  locations, action, and restore route;
- the Purview operator, Agent 365 owner, Foundry platform owner, or application developer is
  unnamed for the responsibility they own;
- an encrypted label lacks explicit VIEW and EXTRACT rights for the agent instance;
- the policy summary includes another agent, group, location, label, direction, or action;
- Foundry DLP is represented as active without both the app-scoped rule and `processContent` user
  context; or
- the scope includes production data or payload retention.

Update `coverage-handoff.md` after a product boundary or owner change, and review it quarterly. The
current policy and its approval stay in Purview and the approved change system.

### Approved DLP policy coordinates

The approved change record and Purview policy summary must match every coordinate below. A
coordinate that is absent, broader, or different is a stop condition.

| Coordinate | Required value |
|---|---|
| Environment | Approved nonproduction environment |
| Agent | One approved Agent 365 instance |
| People | The approved test group |
| Directions | Human-to-agent and agent-to-human |
| Locations | Teams, OneDrive or SharePoint, and email |
| Condition | One approved sensitivity-label ID |
| Action | The recorded `Block` or `Audit` choice |
| Initial policy state | `TestWithNotifications` |
| Enablement | Approved change after simulation review and the recorded propagation wait |

The DLP operator also records the notification and incident route with the policy. Use the policy's
explicit coordinates, not its name, a broad group, or an intended use case, to confirm scope.

### Label and generated-content gates

Confirm that the approved label is published to and supports the selected SharePoint or OneDrive
source. If the label encrypts the source, the named Agent 365 instance needs explicit VIEW and
EXTRACT rights and a direct share to that source. "All users in the organization" does not grant
those rights to the agent instance.

The source label does not automatically protect newly created Agent 365 content. Before live
confirmation, choose a labelled destination library, mandatory user labelling, or an approved
auto-labelling policy. Inspect and record the output label behavior in Purview or the approved
change system. Source labels alone do not prove generated content is protected.

### Audit constraints

The saved query filters one Agent 365 instance and uses these unified audit operations:
`AIInvokeAgent`, `AIExecuteTool`, `AIInferenceCall`, and `AIGuardrail`. It displays only creation
time, operation, agent ID, agent name, and result status.

Keep prompts, responses, tool arguments, tool results, user identities, file names, and resource
URLs in Purview. The query does not export them to the repository or to a separate audit file.

## Implement

### 1. Confirm entitlement, ownership, and current Purview state

Confirm the entitlement, named owners, and approved nonproduction source. Then confirm the existing
label, publishing scope, and encrypted-label rights. Check that `coverage-handoff.md` names the
Foundry DLP rule owner and application developer. Record the approved decisions, simulation, and
findings in Purview or the approved change system. The Foundry owner handles Data Security,
app-scoped rules, and `processContent` on its separate path.

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

A read-only deployment preview is unsupported for this portal-led DLP change. The safe preview is
the current portal summary followed by `TestWithNotifications` simulation.

### 3. Configure the Agent 365 DLP policy for the approved scope

Create a custom Purview DLP policy from the approved change record. Enter the coordinates in
Approved DLP policy coordinates exactly, then add the recorded notification, incident route, and
restore path. Start in `TestWithNotifications`.

Review the Purview policy summary and simulation. Confirm that the simulation includes the selected
agent, group, label, directions, and locations, and nothing else. Then enable the policy through the
approved change. Wait for the propagation period recorded in that change before any live
confirmation. Keep the policy in simulation or restore it if the summary or simulation is outside
scope.

### 4. Install the approved agent after DLP propagation

After the approved DLP policy is enabled and its recorded propagation period has elapsed, open the
Session 06 deployment contract at
`sessions/06-agent-365-access-boundary/implementation/artifacts/agent-deployment.json`.
Confirm it still names the approved agent, test group, host product, and consent decision. Install
that agent in Microsoft 365 admin center for the recorded group and host product. Grant only the
recorded approved consent.

Confirm that the recorded group member can find the agent and that the excluded user cannot. Remove
the installation and stop if either result differs. Do not run a business-data interaction; the
following validation uses the labelled synthetic source only.

### 5. Query current Agent 365 activity

Before running the query, connect Exchange Online and Security & Compliance PowerShell to the
approved Microsoft 365 tenant.

Run the query with the same current agent identifier:

```powershell
.\scripts\query-agent-activity.ps1 -AgentInstanceId $agentInstanceId
```

```bash
./scripts/query-agent-activity.sh --agent-instance-id "$agent_instance_id"
```

The scripts display time, operation, agent ID, agent name, and result status. They write no audit
export or interaction content.

## Confirm the result

### Intended path

After propagation, run the labelled synthetic interaction through the approved path. `Block` stops
the matched interaction. `Audit` allows it and records the match. Inspect the policy result and
scoped audit activity in Purview. Before confirmation, inspect the generated content's label
behavior and apply the selected output control.

### Blocked or failure path

Run the interaction again with the approved out-of-scope test-group alias. Keep the agent, source,
label, direction, location, and action unchanged. The policy must **not report a match**. Stop if the
scope is wider than approved, the observed action differs, generated content is treated as
protected without the selected output control, or audit activity remains absent after the stated
ingestion allowance.

### Delivery-owner checkpoint

The delivery owner observes the propagation wait, intended result, non-match, and scoped audit
activity. Keep the policy in simulation or disable it if a check fails. Record the outcome in
Purview and the approved change system.

## After implementation

Microsoft Purview retains the DLP policy, label state, findings, audit activity, and change history.
`coverage-handoff.md` records who owns each product path, and
`agent-activity-audit-query.json` defines the audit query. The data owner updates the handoff file.
The information protection owner maintains labels and the generated-content control. The Agent 365
owner monitors workflow impact, and the audit owner updates the query. The Foundry owner and
application developer manage their separate handoff.

Restore through the approved Purview change path: return the policy to `TestWithNotifications`,
disable it after dependency review, and remove the scoped instance and group before deleting a
session-created policy. Do not delete a reused label, Foundry coverage, audit records, or source
data as a shortcut.
