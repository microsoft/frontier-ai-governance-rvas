# Configure continuous evaluation and platform alerts

## Module scope

### What we will do

**Objective.** Add operating signals to one governed Foundry project.

Deploy a diagnostic setting, an action group, and three platform metric alerts for the Foundry
account. Then create or update one continuous evaluation rule for the governed agent. The result is
an enabled alert set, a recorded evaluator decision, and a rule that scores sampled agent response
completions.

### Why it matters

**Problem.** Offline evaluation gates catch known release regressions, but they do not watch live
traffic. Operators still need to see throttling, latency, token volume, and quality drift after the
agent is in use.

**Solution.** This module adds those live controls. Azure Monitor routes platform alerts to the
operating owner, and Foundry continuous evaluation scores sampled responses with the approved
evaluators.

**[EU AI Act](https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng).** For high-risk AI systems, this
module supports Article 12 (record-keeping) with diagnostic logs, Article 26(5) (deployer
monitoring) with platform alerts, and Article 72 (post-market monitoring) with continuous
evaluation. This is an engineering mapping, not legal advice.

### Boundaries

This module sits outside the numbered session sequence.

It changes one Foundry account's diagnostic setting, one action group, three Azure Monitor metric
alerts, and one continuous evaluation rule for the approved project and agent. Azure Monitor and
Foundry hold the live state. This repository holds the Bicep definition, parameter contract,
evaluation decision record, operational script, and KQL check.

Agent identity, runtime baseline, release quality gates, incident routing, budgets, and promotion
remain with Sessions 04, 09, 11, and 12.

## Architecture

### Architecture at a glance

The Foundry account emits platform logs and metrics. The diagnostic setting sends them to the
approved Log Analytics workspace. Azure Monitor metric alerts watch three operator-owned signals:
429 throttling, time to last byte, and token volume. The action group routes those alerts.

The Foundry project stores monitoring and evaluation data in Application Insights. The continuous
evaluation script creates an evaluation from the recorded evaluator list, then creates or updates a
rule for `RESPONSE_COMPLETED` events from the governed agent. The rule uses `maxHourlyRuns` as the
sampling cap.

Application Insights, Log Analytics, and Foundry remain authoritative for live telemetry and
evaluation runs. The repository records the intended state and the owner decisions that live
services do not reconstruct later.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
|---|---|---|---|
| Platform diagnostics | `allLogs` and `AllMetrics` to the approved Log Analytics workspace | Gives operators one query surface for platform logs and exported metrics | Workspace access and retention must match the content risk |
| Alert set | 429 throttling, time to last byte, and token volume | Covers the signals the service owner can tune or escalate | Thresholds need baseline traffic and may change after the first operating week |
| Latency signal | `AzureOpenAITTLTInMS`, paired with token volume | Avoids the legacy `Latency` metric that Microsoft warns against for Azure OpenAI | Token-heavy requests can still look slow without being unhealthy |
| Evaluation sampling | Continuous evaluation rule with `maxHourlyRuns` | Bounds evaluation cost and lets the AI quality owner tune traffic sampling | Recurring evaluation surfaces are preview and need an approved preview-use decision |
| Restore | Disable module-owned alerts or the evaluation rule before deleting resources | Keeps telemetry available while owners repair thresholds or evaluators | Removal still needs the approved Azure and Foundry change paths |

### Architecture guidance

Use [Monitor agents with the Agent Monitoring Dashboard](https://learn.microsoft.com/en-us/azure/foundry/observability/how-to/how-to-monitor-agents-dashboard)
for the continuous evaluation rule, Application Insights dependency, preview status, and Foundry
User role requirement.

Use [Monitoring data reference for Azure OpenAI](https://learn.microsoft.com/en-us/azure/foundry/openai/monitor-openai-reference)
for the metric names, dimensions, token metrics, throttling signal, and latency guidance.

Use [Diagnostic Settings in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/data-collection/diagnostic-settings)
for diagnostic setting behavior and Log Analytics as a destination for resource logs and platform
metrics.

## Before you start

Confirm these prerequisites:

- Session 04 produced one governed Foundry agent in an approved nonproduction project.
- Session 09 selected the evaluator set and thresholds for that same agent.
- Session 11 named the Log Analytics workspace, Application Insights resource, action owner, and
  incident route.
- Session 12 or the approved deployment path can run Bicep what-if and deployment at the exact
  resource group that contains the Foundry account.
- The operator has **Monitoring Contributor** on the approved resource group.
- The project managed identity can receive **Foundry User** through the customer's access process.
- The operating owner has reviewed baseline traffic and approved the initial thresholds.

Keep tenant IDs, subscription IDs, resource IDs, project endpoints, prompts, responses, tokens,
connection strings, and customer data out of this repository. Store resolved values in the approved
private configuration path.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/monitoring/foundry-platform-monitoring.bicep`](artifacts/monitoring/foundry-platform-monitoring.bicep) | The Azure monitoring deployment pipeline |
| Deployment | [`artifacts/monitoring/foundry-platform-monitoring.bicepparam`](artifacts/monitoring/foundry-platform-monitoring.bicepparam) | The Azure monitoring deployment pipeline |
| Record | [`artifacts/evaluation/continuous-evaluation-decision.json`](artifacts/evaluation/continuous-evaluation-decision.json) | The AI quality owner, Foundry operator, and module preflight scripts |
| Runtime | [`artifacts/evaluation/continuous-evaluation-rule.py`](artifacts/evaluation/continuous-evaluation-rule.py) | The Foundry evaluation operator |
| Runtime | [`artifacts/evaluation/requirements.txt`](artifacts/evaluation/requirements.txt) | The Foundry evaluation operator and Python build process |
| Runtime | [`artifacts/queries/foundry-token-and-throttling.kql`](artifacts/queries/foundry-token-and-throttling.kql) | The Azure Monitor operations owner |

## Decisions and stop conditions

Resolve every `__REQUIRED_*__` value before a state change. Use team aliases and role names, not
personal data.

| Gate | Continue when | Stop when |
|---|---|---|
| Scope | `TargetScope`, the Bicep parameter file, and the evaluation decision record name the same approved Foundry account and project boundary | The account, project, workspace, action route, or resource group differs from the approved scope |
| Diagnostic setting | The workspace is the approved Log Analytics destination and `allLogs` is acceptable for the data classification | The workspace has the wrong retention, access model, region decision, or owner |
| Alerts | Thresholds come from baseline telemetry and the action group owner can receive notifications | A threshold lacks an owner, uses the legacy `Latency` metric, or treats token volume as billed cost |
| Throttling dimension | The owner confirms the `StatusCode` value used for 429 throttling in Metrics Explorer | The value is unknown, or the alert would split on user, prompt, response, or free text |
| Continuous evaluation | The evaluator list, `maxHourlyRuns`, and owner roles are recorded | The project managed identity lacks the Foundry User role, the sampling cap is unresolved, or evaluator names are unapproved |
| Preview | The what-if preview contains only the diagnostic setting, action group, and three module-owned alert rules | The preview changes unrelated resources or targets the wrong group |

Do not weaken thresholds or disable sampling to make a result look healthy. Adjust thresholds only
after the service owner and AI quality owner review live behavior.

## Implement

### 1. Complete the retained decisions

Resolve the monitoring parameters and the continuous evaluation decision record in the approved
private configuration path:

- `artifacts/monitoring/foundry-platform-monitoring.bicepparam`
- `artifacts/evaluation/continuous-evaluation-decision.json`

Set the deployment coordinates:

```powershell
$approvedSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$resourceGroupName = $env:FOUNDRY_RESOURCE_GROUP
$targetScope = "<approved Foundry project scope alias>"
$deploymentLocation = $env:AZURE_DEPLOYMENT_LOCATION
```

```bash
approved_subscription_id="${AZURE_SUBSCRIPTION_ID}"
resource_group_name="${FOUNDRY_RESOURCE_GROUP}"
target_scope="<approved Foundry project scope alias>"
deployment_location="${AZURE_DEPLOYMENT_LOCATION}"
```

### 2. Run preflight and review the preview

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroupName `
  -TargetScope $targetScope `
  -DeploymentLocation $deploymentLocation
```

```bash
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --resource-group-name "$resource_group_name" \
  --target-scope "$target_scope" \
  --deployment-location "$deployment_location"
```

Preflight reads the artifacts, rejects unresolved decisions, validates syntax, checks the target
scope, and runs a resource-group what-if preview. It reaches Azure only after every sentinel is
resolved.

### 3. Deploy the monitoring controls

Deploy only after the observability owner approves the what-if preview.

```powershell
az deployment group create `
  --subscription $approvedSubscriptionId `
  --resource-group $resourceGroupName `
  --template-file .\artifacts\monitoring\foundry-platform-monitoring.bicep `
  --parameters .\artifacts\monitoring\foundry-platform-monitoring.bicepparam `
  --only-show-errors
```

```bash
az deployment group create \
  --subscription "$approved_subscription_id" \
  --resource-group "$resource_group_name" \
  --template-file ./artifacts/monitoring/foundry-platform-monitoring.bicep \
  --parameters ./artifacts/monitoring/foundry-platform-monitoring.bicepparam \
  --only-show-errors
```

### 4. Create or update the continuous evaluation rule

Install the runtime dependencies in the approved operator environment. Do not install packages into
this repository.

```powershell
python -m pip install -r .\artifacts\evaluation\requirements.txt
$env:AZURE_AI_PROJECT_ENDPOINT = "<resolved approved project endpoint>"
python .\artifacts\evaluation\continuous-evaluation-rule.py `
  --decision-file .\artifacts\evaluation\continuous-evaluation-decision.json
```

```bash
python -m pip install -r ./artifacts/evaluation/requirements.txt
export AZURE_AI_PROJECT_ENDPOINT="<resolved approved project endpoint>"
python ./artifacts/evaluation/continuous-evaluation-rule.py \
  --decision-file ./artifacts/evaluation/continuous-evaluation-decision.json
```

The script prints the evaluation ID and rule ID. Keep those IDs in the approved operations record,
not in this repository.

### 5. Check telemetry after approved traffic

Run the KQL file against the approved workspace after normal traffic or an approved synthetic call.
The queries check diagnostic rows, token metrics, throttling shape, and latency percentiles.

For evaluation runs, list recent runs with the evaluation ID printed by the setup step:

```powershell
python .\artifacts\evaluation\continuous-evaluation-rule.py `
  --list-runs `
  --evaluation-id "<resolved evaluation id>" `
  --limit 10
```

```bash
python ./artifacts/evaluation/continuous-evaluation-rule.py \
  --list-runs \
  --evaluation-id "<resolved evaluation id>" \
  --limit 10
```

## Confirm the result

The module is complete when:

- the diagnostic setting exists on the Foundry account and points to the approved Log Analytics
  workspace;
- the action group is enabled and owned by the operating team;
- the throttling, latency, and token-volume metric alert rules are enabled, tagged with
  `implementationSession=optional-module-continuous-evaluation-platform-alerts`, and scoped to the
  approved Foundry account;
- the continuous evaluation rule is enabled for the governed agent; and
- recent evaluation runs show status after sampled traffic arrives.

Stop if diagnostic rows never arrive, any alert is disabled, the action group has the wrong owner,
or evaluation runs remain absent after traffic and the sampling cap should allow them.

## After implementation

| What remains | Owner |
|---|---|
| Diagnostic setting, alert rules, action group, and thresholds | Observability owner |
| Continuous evaluation rule, evaluator set, thresholds, and sampling cap | AI quality owner |
| Foundry account, project, managed identity, and role assignment | Platform owner |
| Incident route and restore decision | Service owner |
| KQL checks and alert tuning notes | Azure Monitor operations owner |

Restore through the owning change paths:

1. Disable only the noisy module-owned alert rule while the owner corrects the threshold.
2. Disable the continuous evaluation rule before deleting it if evaluator cost or preview behavior
   becomes a problem.
3. Remove the diagnostic setting only after the observability owner confirms another route keeps
   the required platform logs.
4. Delete the action group only when no alert rule still uses it.
5. Keep Application Insights, Log Analytics, incident records, and release evaluation gates in
   place.
