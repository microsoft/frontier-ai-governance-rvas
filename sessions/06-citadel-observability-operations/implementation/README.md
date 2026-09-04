# Operate Citadel telemetry, cost, and incidents

## Session scope

### What we will do

**Make the Citadel path operable without creating a content archive.** We will configure the telemetry contract, deploy a workbook, alerts, and budget, then run one synthetic smoke path that separates gateway, model, agent, and tool results.

### Why it matters

Without shared correlation and ownership, every failure looks like an agent problem and cost signals arrive without context. Citadel already provides a telemetry path; this session turns it into a bounded operating control.

### Boundaries

Application Insights and Log Analytics own runtime telemetry. Cost Management owns billed cost. Defender and the SOC platform own security incidents. Standard logging excludes prompts, responses, tool payloads, credentials, and personal data.

## Architecture

### Architecture at a glance

Citadel has several observability pipelines with different purposes and timing. Do not collapse them
into one generic log stream.

```text
Runtime health and tracing
APIM diagnostics -> Application Insights -> alerts and workbook

Request and LLM diagnostics
APIM LLM diagnostics -> Log Analytics -> bounded operational queries

Usage allocation
Application Insights metrics -> scheduled workflow -> Cosmos DB + pricing
                                                   -> Power BI or allocation report

Optional non-LLM export
approved events -> Event Hub -> customer-owned destination
```

Application Insights carries gateway health, correlation, latency, failures, and token metrics.
Because it is workspace-based, operators can join those signals with approved Log Analytics data.
Log Analytics can also store per-request LLM metadata and, when enabled, message content. Message
capture is a separate privacy decision. The pinned upstream template enables message capture unless
the deployment profile overrides it, so Session 02 must set it to `none` for the default path.

Usage processing is delayed. Scheduled workflows read metrics and write allocation records to
Cosmos DB, where pricing data supports product, model, backend, and application views. This is
showback data, not a real-time billing ledger. Azure Cost Management remains authoritative for the
bill, and the budget created here notifies owners rather than blocking spend.

MCP and A2A usage have their own metrics and scheduled processing. Event Hub is an optional export
path for other approved events; it is not the MCP or A2A ingestion mechanism.

Across these paths, APIM, the agent, model, and tool propagate one safe correlation identifier while
retaining separate ownership and failure results.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
| --- | --- | --- | --- |
| Content logging | Off by default | Avoids a prompt and response archive | Debugging uses metadata unless an exception is approved |
| Correlation | W3C trace context plus one safe ID | Joins the path without user identifiers | Every component must propagate it |
| Alert source | Application Insights metrics | Supports near-real-time gateway and backend alerts | Requires stable dimensions and thresholds |
| Cost allocation | Scheduled usage processing into Cosmos DB | Supports product and application allocation | Delayed and dependent on maintained pricing data |
| Authoritative bill | Azure Cost Management | Uses billed Azure cost | Arrives later than runtime metrics |
| Export | Disabled unless filtered and owned | Reduces duplicate sensitive stores | External SIEM use needs a separate decision |

### Architecture guidance

- [Monitor Azure OpenAI](https://learn.microsoft.com/azure/ai-services/openai/how-to/monitoring)
- [Cost Management budgets](https://learn.microsoft.com/azure/cost-management-billing/costs/tutorial-acm-create-budgets)

## Before you start

Name the Application Insights component, Log Analytics workspace, action group, budget scope, workload contract, cost owner, incident owner, retention period, sampling choice, export decision, and synthetic normal and failure routes.

### Implementation files

| Type | File | Consumer |
| --- | --- | --- |
| Runtime | `artifacts/telemetry/telemetry-contract.json` | Citadel telemetry pipeline and smoke scripts |
| Record | `artifacts/governance/data-retention-decision.md` | privacy and operations owners |
| Record | `artifacts/governance/prompt-response-logging-decision.md` | APIM and privacy owners |
| Deployment | `artifacts/infra/main.bicep` | Citadel operations deployment pipeline |
| Deployment | `artifacts/infra/main.bicepparam` | Citadel operations deployment pipeline |
| Deployment | `artifacts/monitoring/workbook.json` | shared Azure Workbook |
| Runtime | `artifacts/queries/request-error-rate-alert.kql` | Azure Monitor alert rules |
| Runtime | `artifacts/queries/tool-failure-alert.kql` | Azure Monitor alert rules |
| Runtime | `artifacts/queries/quality-safety-alert.kql` | Azure Monitor alert rules |
| Deployment | `artifacts/cost/budget.bicep` | Citadel operations deployment pipeline |
| Deployment | `artifacts/cost/budget.bicepparam` | Citadel operations deployment pipeline |
| Record | `artifacts/cost/cost-allocation.md` | FinOps and platform owners |
| Record | `artifacts/operations/incident-runbook.md` | SRE, platform, and security operations teams |

## Decisions and stop conditions

Stop when a telemetry field contains sensitive or unbounded data, prompt-body logging is enabled without a bounded exception, filtering happens after external export, a dimension uses users or free text, the action group has no owner, a budget is presented as spend enforcement, or deployment what-if touches unrelated monitoring resources.

## Implement

### 1. Complete the retained decisions

Resolve every `__REQUIRED_*__` value in the telemetry, Bicep, budget, and operating records. Keep external export disabled unless the destination, filter, retention, owner, and restore path are approved.

### 2. Run preflight

```powershell
.\scripts\preflight.ps1 -ApprovedSubscriptionId $subscriptionId -ApprovedResourceGroupName $resourceGroup -ApprovedApplicationInsightsResourceId $applicationInsightsId -DeploymentLocation $location
```

```bash
./scripts/preflight.sh --approved-subscription-id "$subscription_id" --approved-resource-group-name "$resource_group" --approved-application-insights-resource-id "$application_insights_id" --deployment-location "$location"
```

### 3. Deploy the workbook, alerts, and budget

```powershell
az deployment group create --resource-group $resourceGroup --template-file .\artifacts\infra\main.bicep --parameters .\artifacts\infra\main.bicepparam
az deployment sub create --location $location --template-file .\artifacts\cost\budget.bicep --parameters .\artifacts\cost\budget.bicepparam
```

```bash
az deployment group create --resource-group "$resource_group" --template-file ./artifacts/infra/main.bicep --parameters ./artifacts/infra/main.bicepparam
az deployment sub create --location "$location" --template-file ./artifacts/cost/budget.bicep --parameters ./artifacts/cost/budget.bicepparam
```

Open the workbook and run each alert query. Use the existing authorized action-group test path instead of generating unsafe traffic.

## Confirm the result

Run the paired smoke script against a synthetic successful request and a handled tool failure. The result shows different safe correlation IDs, successful model and tool results for the normal route, an independent tool failure for the failure route, stable ingestion, and no prohibited payload fields.

```powershell
.\scripts\smoke.ps1 -Mode Pipeline -Environment nonproduction -CommitSha $env:RELEASE_COMMIT_SHA -ResultPath (Join-Path $env:RUNNER_TEMP "citadel-smoke.json")
```

```bash
./scripts/smoke.sh --mode pipeline --environment nonproduction --commit-sha "$RELEASE_COMMIT_SHA" --result-path "$RUNNER_TEMP/citadel-smoke.json"
```

## After implementation

The observability owner manages telemetry, sampling, retention, workbook, and alerts. The gateway owner manages APIM correlation. Tool and model owners manage their span accuracy. FinOps owns the budget and cost allocation. The incident commander owns containment and restore. Revert through the previous approved Bicep parameters and APIM policy; do not disable telemetry or security routing to silence a real signal.
