# Enable AI threat protection and shadow AI discovery

## Module scope

### What we will do

**Objective.** Turn on threat protection for one approved AI scope and give the SOC a focused AI detection path.

Enable the Defender for Cloud AI services plan in the approved subscription, deploy one Copilot
jailbreak analytics rule and one hunting query to the approved Sentinel workspace, and record the
Defender for Cloud Apps shadow AI sanction decisions. The observable result is a `Standard`
Defender `AI` plan, an enabled Sentinel rule, and Unsanctioned tags applied to the recorded
generative AI apps after a monitor-first review.

### Why it matters

**Problem.** AI attacks and unmanaged AI app use can bypass normal SOC tuning. Prompt injection,
credential leakage, wallet attacks, and unsanctioned AI tools need named owners before alerts or
blocks start.

**Solution.** This module turns on the AI services plan, deploys the first Copilot detection path,
and records shadow AI decisions before portal changes. **The SOC gets a scoped signal, not a broad
new queue.**

**[EU AI Act](https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng).** For high-risk AI systems, this
module supports Article 15 (cybersecurity) with Defender threat protection and Sentinel detections,
and Article 73 (serious incidents) with early detection. Shadow AI discovery extends the Article 5
(prohibited practices) screen to AI apps nobody approved. This is an engineering mapping, not legal
advice.

### Boundaries

This module sits outside the numbered session sequence.

It changes three surfaces: the subscription-level Defender for Cloud AI services plan, two
Sentinel content items in one workspace, and Defender for Cloud Apps sanction tags for recorded
generative AI apps. Azure and Microsoft Defender hold live plan, alert, rule, and app-tag state.
The repository holds the Bicep definitions, KQL, and decision records.

Red teaming and the Defender alert-to-SOC route remain with the
[red teaming and threat defense guide](../../../sessions/10-red-teaming-threat-defense/implementation/README.md).
Operational alert thresholds and incident paths remain with the
[observability guide](../../../sessions/11-observability-cost-operations/implementation/README.md).
Purview DLP for Agent 365 remains with the
[Agent 365 access boundary guide](../../../sessions/05-agent-365-access-boundary/implementation/README.md).

## Architecture

### Architecture at a glance

The subscription plan is the first control boundary. Defender for Cloud analyzes supported AI
service activity, raises AI alerts, and sends them to Defender XDR. Sentinel receives AI-related
signals from its connectors and the Log Analytics workspace.

The module deploys two reusable definitions:

| Surface | Repository definition | Live authority |
|---|---|---|
| Defender for Cloud AI services plan | `defender-ai-plan.bicep` and `defender-ai-plan-decisions.json` | Microsoft Defender for Cloud |
| Copilot jailbreak analytics rule | `copilot-threat-detections.bicep` and `copilot-jailbreak-analytics.kql` | Microsoft Sentinel |
| Copilot external-IP hunting query | `copilot-threat-detections.bicep` and `copilot-external-ip-hunting.kql` | Log Analytics saved searches surfaced in Sentinel |
| Shadow AI decisions | `shadow-ai-sanction-decisions.json` | Defender for Cloud Apps portal tags and policies |

The workflow runs Bicep what-if for the two deployable surfaces. Shadow AI tagging is portal-led:
the security owner starts in monitor mode, applies Sanctioned or Unsanctioned tags, and moves to
blocking only through the approved change path.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
|---|---|---|---|
| Defender plan rollout | Subscription-scope Bicep for `Microsoft.Security/pricings` name `AI` | Repeatable plan state and extension decisions | Prompt evidence and Purview sharing need a privacy decision |
| Sentinel content | Bicep for a scheduled analytics rule and saved search | The SOC can deploy and review as code | Connectors and tables must already produce data |
| Hunting query | Log Analytics saved search | Matches how Sentinel hunting queries are stored | The starter private-range filter must be tuned |
| Shadow AI | Monitor-first portal path with a JSON decision record | Avoids blocking a business app before review | The portal remains authoritative for app tags and enforcement |

### Architecture guidance

Use [AI threat protection in Microsoft Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-threat-protection)
for the plan scope, supported services, Defender XDR integration, and availability limits.

Use [Enable threat protection for AI services](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-onboarding)
for the AI services plan components, prompt-evidence behavior, Purview-sharing boundary, and role
requirements.

Use [Manage generative AI apps for your organization](https://learn.microsoft.com/en-us/microsoft-365/copilot/manage-generative-ai-apps)
for Defender for Cloud Apps discovery, Generative AI filtering, and Sanctioned or Unsanctioned
tagging.

## Before you start

Confirm these requirements:

- The approved subscription, target scope alias, deployment location, Sentinel resource group, and
  Sentinel workspace name are recorded in the private implementation parameters.
- The operator can run Bicep what-if at subscription scope and at the Sentinel workspace resource
  group.
- The Defender for Cloud owner has approved the `AI` plan and the prompt-evidence and Purview
  sharing decisions.
- The Sentinel owner confirms the Microsoft Copilot connector path and accepts the jailbreak rule
  and hunting query.
- The Defender for Cloud Apps owner can open Cloud Discovery, filter **Category = Generative AI**,
  and apply Sanctioned or Unsanctioned tags.
- The privacy owner accepts that suspicious prompt evidence can include redacted prompt and
  response snippets when that extension is enabled.

Keep tenant IDs, subscription IDs, resource IDs, user names, app exports, alert exports, prompts,
responses, IP exports, tokens, and credentials out of this repository.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/defender/defender-ai-plan.bicep`](artifacts/defender/defender-ai-plan.bicep) | The subscription security deployment pipeline |
| Deployment | [`artifacts/defender/defender-ai-plan.bicepparam`](artifacts/defender/defender-ai-plan.bicepparam) | The subscription security deployment pipeline |
| Record | [`artifacts/defender/defender-ai-plan-decisions.json`](artifacts/defender/defender-ai-plan-decisions.json) | The Defender for Cloud owner, privacy owner, SOC owner, and preflight scripts |
| Runtime | [`artifacts/defender/defender-ai-alerts.kql`](artifacts/defender/defender-ai-alerts.kql) | The SOC reporting owner |
| Deployment | [`artifacts/sentinel/copilot-threat-detections.bicep`](artifacts/sentinel/copilot-threat-detections.bicep) | The Sentinel-as-code deployment pipeline |
| Deployment | [`artifacts/sentinel/copilot-threat-detections.bicepparam`](artifacts/sentinel/copilot-threat-detections.bicepparam) | The Sentinel-as-code deployment pipeline |
| Runtime | [`artifacts/sentinel/copilot-jailbreak-analytics.kql`](artifacts/sentinel/copilot-jailbreak-analytics.kql) | The Copilot jailbreak scheduled analytics rule |
| Runtime | [`artifacts/sentinel/copilot-external-ip-hunting.kql`](artifacts/sentinel/copilot-external-ip-hunting.kql) | The Sentinel hunting library |
| Record | [`artifacts/shadow-ai/shadow-ai-sanction-decisions.json`](artifacts/shadow-ai/shadow-ai-sanction-decisions.json) | The Defender for Cloud Apps owner and security operations owner |

Resolve every `__REQUIRED_*__` value in a private copy before deployment. Preflight rejects
unresolved decisions before it calls Azure.

## Decisions and stop conditions

### Defender for Cloud AI plan

Decide whether to enable suspicious prompt evidence and Purview sharing. Prompt evidence helps
triage alerts, but it can include redacted snippets of suspicious prompts or responses. Purview
sharing requires the right Purview capability and does not cover Foundry agents through this
Defender setting.

**Stop** if the privacy decision is missing, if the target subscription is wrong, if the plan is
being enabled in an unsupported cloud, or if the owner treats Purview sharing as Foundry agent DLP.

### Sentinel detections

Deploy the Copilot jailbreak analytics rule only to the approved Sentinel workspace. The Microsoft
Copilot connector must produce `CopilotActivity`. Defender for Cloud alerts need the Defender for
Cloud connector or Defender XDR route before `defender-ai-alerts.kql` returns AI alert rows.

**Stop** if the workspace is not the approved workspace, if the connector path is not accepted by
the SOC owner, or if the analytics rule would create incidents in a queue nobody owns.

### Shadow AI decisions

Use Defender for Cloud Apps Cloud Discovery. Filter **Category = Generative AI**, review risk,
record the decision, and start with `enforcementMode` set to `monitor`. Apply Unsanctioned tags in
the portal only after the owner accepts the recorded app list.

**Stop** if the app list is an export from an unmanaged source, if an app is blocked without a
restore reference, or if business-critical apps are moved straight to block mode.

## Implement

### 1. Complete the records and run preflight

Resolve the Defender, Sentinel, and shadow AI decisions in the private implementation copy.

```powershell
$targetScope = "<approved scope alias>"
$targetSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$sentinelResourceGroupName = "<approved Sentinel resource group>"
$sentinelWorkspaceName = "<approved Sentinel workspace>"
$deploymentLocation = "<approved Azure region>"

.\scripts\preflight.ps1 `
  -TargetScope $targetScope `
  -TargetSubscriptionId $targetSubscriptionId `
  -SentinelResourceGroupName $sentinelResourceGroupName `
  -SentinelWorkspaceName $sentinelWorkspaceName `
  -DeploymentLocation $deploymentLocation
```

```bash
target_scope="<approved scope alias>"
target_subscription_id="${AZURE_SUBSCRIPTION_ID}"
sentinel_resource_group_name="<approved Sentinel resource group>"
sentinel_workspace_name="<approved Sentinel workspace>"
deployment_location="<approved Azure region>"

./scripts/preflight.sh \
  --target-scope "$target_scope" \
  --target-subscription-id "$target_subscription_id" \
  --sentinel-resource-group-name "$sentinel_resource_group_name" \
  --sentinel-workspace-name "$sentinel_workspace_name" \
  --deployment-location "$deployment_location"
```

Preflight checks required files, every decision sentinel, JSON syntax, Bicep and bicepparam syntax,
the approved target scope, the Sentinel workspace binding, and both read-only deployment previews.
It does not preview Defender for Cloud Apps portal changes; shadow AI remains portal-led and
monitor-first.

### 2. Deploy the Defender and Sentinel definitions

Deploy only after the owners approve both what-if results.

```powershell
az deployment sub create `
  --subscription $targetSubscriptionId `
  --location $deploymentLocation `
  --template-file .\artifacts\defender\defender-ai-plan.bicep `
  --parameters .\artifacts\defender\defender-ai-plan.bicepparam `
  --only-show-errors

az deployment group create `
  --subscription $targetSubscriptionId `
  --resource-group $sentinelResourceGroupName `
  --template-file .\artifacts\sentinel\copilot-threat-detections.bicep `
  --parameters .\artifacts\sentinel\copilot-threat-detections.bicepparam `
  --only-show-errors
```

```bash
az deployment sub create \
  --subscription "$target_subscription_id" \
  --location "$deployment_location" \
  --template-file ./artifacts/defender/defender-ai-plan.bicep \
  --parameters ./artifacts/defender/defender-ai-plan.bicepparam \
  --only-show-errors

az deployment group create \
  --subscription "$target_subscription_id" \
  --resource-group "$sentinel_resource_group_name" \
  --template-file ./artifacts/sentinel/copilot-threat-detections.bicep \
  --parameters ./artifacts/sentinel/copilot-threat-detections.bicepparam \
  --only-show-errors
```

### 3. Apply shadow AI monitor-mode decisions

In the Microsoft Defender portal, open **Cloud apps > Cloud discovery > Discovered apps**. Filter
**Category = Generative AI**. Compare the portal list with
`artifacts/shadow-ai/shadow-ai-sanction-decisions.json`.

Apply the recorded Sanctioned or Unsanctioned tag. Keep enforcement in monitor mode until the
security operations owner approves block or warn behavior through the change path. If an
Unsanctioned tag automatically blocks on Defender for Endpoint-onboarded devices in this tenant,
stop and use the recorded restore reference before tagging business-critical apps.

### 4. Share the operating queries

Give the SOC owner `artifacts/defender/defender-ai-alerts.kql` for weekly alert-family reporting.
Tune `artifacts/sentinel/copilot-external-ip-hunting.kql` to the organization's egress ranges
before using it for recurring review.

## Confirm the result

Check the Defender plan and the Sentinel rule:

```powershell
az resource show `
  --ids "/subscriptions/$targetSubscriptionId/providers/Microsoft.Security/pricings/AI" `
  --query "{name:name,tier:properties.pricingTier,extensions:properties.extensions}" `
  --output jsonc `
  --only-show-errors

az rest `
  --method get `
  --url "https://management.azure.com/subscriptions/$targetSubscriptionId/resourceGroups/$sentinelResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$sentinelWorkspaceName/providers/Microsoft.SecurityInsights/alertRules/e5f6a7b8-c9d0-41e2-f3a4-b5c6d7e8f9a0?api-version=2025-09-01" `
  --query "{displayName:properties.displayName,enabled:properties.enabled,severity:properties.severity}" `
  --output jsonc `
  --only-show-errors
```

```bash
az resource show \
  --ids "/subscriptions/${target_subscription_id}/providers/Microsoft.Security/pricings/AI" \
  --query '{name:name,tier:properties.pricingTier,extensions:properties.extensions}' \
  --output jsonc \
  --only-show-errors

az rest \
  --method get \
  --url "https://management.azure.com/subscriptions/${target_subscription_id}/resourceGroups/${sentinel_resource_group_name}/providers/Microsoft.OperationalInsights/workspaces/${sentinel_workspace_name}/providers/Microsoft.SecurityInsights/alertRules/e5f6a7b8-c9d0-41e2-f3a4-b5c6d7e8f9a0?api-version=2025-09-01" \
  --query '{displayName:properties.displayName,enabled:properties.enabled,severity:properties.severity}' \
  --output jsonc \
  --only-show-errors
```

The Defender plan shows `pricingTier` as `Standard`. The extension states match the approved
decision record. The Sentinel rule is enabled and named `Copilot - Jailbreak Attempt Detected`.
The Defender for Cloud Apps owner confirms that every Unsanctioned app in the JSON record carries
the Unsanctioned tag in the portal.

**Stop the module** if the plan is not `Standard`, if an extension differs from the privacy
decision, if the analytics rule is disabled, if the workspace is wrong, or if a portal tag differs
from the recorded decision.

## After implementation

| What remains | Owner |
|---|---|
| Defender for Cloud AI services plan and extension decisions | Defender for Cloud owner and privacy owner |
| Defender XDR routing and AI alert triage | SOC owner |
| Sentinel Copilot jailbreak rule and hunting query | Sentinel owner |
| Defender for Cloud Apps generative AI app tags and policy state | Defender for Cloud Apps owner |
| Shadow AI monitor-to-block promotion decision | Security operations owner |
| KQL reporting and runbook links | SOC reporting owner |

Restore through the owning change paths:

1. Redeploy `defender-ai-plan.bicep` with the approved extension values, or turn the AI services
   plan off only when the Defender for Cloud owner approves that change.
2. Disable or remove only the module-owned Sentinel analytics rule and saved search when the SOC
   owner approves it.
3. Revert Sanctioned or Unsanctioned tags in Defender for Cloud Apps through the portal using the
   restore reference in `shadow-ai-sanction-decisions.json`.
4. Keep existing alerts and Sentinel data for the workspace retention period. Do not delete
   incident records to undo this module.
