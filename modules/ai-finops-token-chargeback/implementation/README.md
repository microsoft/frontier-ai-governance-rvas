# Implement AI cost allocation, budgets, and token chargeback

## Module scope

### What we will do

**Objective.** Make AI spend attributable before finance asks for the monthly split.

Deploy cost-allocation tag policies, a filtered AI budget, and one API Management token chargeback
policy for the approved AI gateway route. Record the token rates agreed with finance. The check
then runs a KQL query that groups tokens by cost center, consumer, product, API, and model.

### Why it matters

**Problem.** Azure Cost Management shows billed cost, but a shared AI gateway can hide which product
or cost center drove token use.

**Solution.** Tags bind billed cost to an owner. The gateway emits token metrics with finance-owned
dimensions. The rate table gives FinOps a clear way to turn attributed token use into showback or
chargeback.

**[EU AI Act](https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng).** No article requires cost
allocation; this module is good practice. For high-risk AI systems, the per-consumer token records
can support Article 12 (record-keeping). This is an engineering mapping, not legal advice.

### Boundaries

This module sits outside the numbered session sequence.

It changes the approved AI FinOps subscription, the filtered AI budget, and the existing API
Management AI gateway policy source. Azure Policy remains authoritative for policy assignments.
Cost Management remains authoritative for billed cost. Application Insights or Log Analytics remains
authoritative for token telemetry and chargeback queries.

Session 06 owns the gateway route. Session 11 owns the wider observability and cost notification
baseline. This module adds finance-grade allocation on top of those controls. Fabric capacity,
Copilot Credits, FinOps hubs, PTU reservations, and reservation chargeback are outside this module.

## Architecture

### Architecture at a glance

The flow has three parts.

First, Azure Policy stages the approved cost-tag requirement on resource groups across the approved
subscription and uses a managed identity to inherit those values to child resources. Second, Cost
Management budget notifications watch the approved AI resource groups and meter categories. Third,
API Management emits token metrics with cost-center and consumer dimensions while a per-product
quota limits token use.

The repository owns the Bicep, APIM policy fragment, rate table, and KQL query. Azure holds the live
policy assignments, budget, APIM policy, token metrics, and billed cost. Finance owns the rate table
and reconciliation cadence.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
|---|---|---|---|
| Allocation anchor | Stage required tags on resource groups and inherit them to resources | Billed cost can be grouped by the same finance tags across services | The tag requirement is subscription-wide and stays in `DoNotEnforce` until approved |
| Budget signal | Filter by resource group and meter category, then notify email and an action group | Cost owners see actual and forecasted spend changes without broad subscription noise | Budgets notify only; they do not stop resources |
| Token signal | Emit APIM token metrics with five low-cardinality dimensions from trusted gateway context | FinOps can attribute token use before billed cost lands | High-cardinality values are dropped by metric limits |
| Quota | Per-product monthly token quota and tokens-per-minute rate | Product owners get a hard gateway boundary for shared routes | Quotas apply at the gateway counter key, not to direct model endpoint calls |
| Rate table | Finance-owned JSON table, used by KQL and reporting | Rates are reviewable and versioned | Estimated cost must be reconciled with Cost Management |

### Architecture guidance

Use [Azure Policy assignment structure](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/assignment-structure)
for assignment identity, metadata, parameters, and enforcement mode.

Use [Create a budget with Bicep](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/quick-create-budget-bicep)
for budget notifications, filters, forecasted thresholds, and the budget boundary.

Use [llm-emit-token-metric](https://learn.microsoft.com/en-us/azure/api-management/llm-emit-token-metric-policy)
for token metrics, custom-dimension limits, Application Insights prerequisites, and streaming
token-count caveats.

## Before you start

Confirm these prerequisites:

- The approved Azure subscription is recorded as a full Azure subscription resource ID.
- Session 06 has a working APIM route, and the gateway owner controls the policy source.
- Session 11 has the approved Application Insights or Log Analytics telemetry boundary and action
  group.
- The APIM instance is integrated with Application Insights and custom metrics with dimensions are
  enabled.
- API Management diagnostic settings can support the chargeback query. Response-body logging can
  capture sensitive data, so enable it only under the approved telemetry boundary.
- Finance has approved the cost-center taxonomy, APIM product mapping, monthly token quotas,
  budget filters, token rates, reconciliation cadence, and restore reference.
- The deployment operator has time-bound access to assign policy, deploy subscription budgets, and
  preview subscription-scope Bicep.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Deployment | [`artifacts/policy/tag-allocation.bicep`](artifacts/policy/tag-allocation.bicep) | The subscription policy deployment pipeline |
| Deployment | [`artifacts/policy/tag-allocation.bicepparam`](artifacts/policy/tag-allocation.bicepparam) | The subscription policy deployment pipeline |
| Deployment | [`artifacts/cost/ai-budget-with-filters.bicep`](artifacts/cost/ai-budget-with-filters.bicep) | The subscription budget deployment pipeline and cost owner |
| Deployment | [`artifacts/cost/ai-budget-with-filters.bicepparam`](artifacts/cost/ai-budget-with-filters.bicepparam) | The subscription budget deployment pipeline |
| Runtime | [`artifacts/apim/token-chargeback-policy.xml`](artifacts/apim/token-chargeback-policy.xml) | The API Management gateway policy repository |
| Runtime | [`artifacts/queries/token-chargeback.kql`](artifacts/queries/token-chargeback.kql) | The FinOps analyst and Application Insights or Log Analytics operator |
| Record | [`artifacts/finance/chargeback-decisions.json`](artifacts/finance/chargeback-decisions.json) | The cost owner, gateway owner, and module preflight scripts |
| Record | [`artifacts/finance/token-rate-table.json`](artifacts/finance/token-rate-table.json) | The FinOps analyst and chargeback reporting pipeline |

Resolve every `__REQUIRED_*__` value in the approved private implementation path before deployment.
Keep subscription IDs, resource IDs, tenant IDs, prompts, responses, tokens, customer names, and
raw usage exports out of this repository.

## Decisions and stop conditions

### Allocation scope

Use one approved AI subscription. The Bicep deployment runs at subscription scope, and the tag
assignments also land at that subscription scope. Preflight rejects resource-group or narrower
target scopes.

The resource-group tag requirement is staged in `DoNotEnforce` first. It reaches `Default` only
after the policy owner reviews current findings, exemptions, and the subscription-wide effect.

Stop if the subscription is production without approval, if the subscription holds unrelated
resource-group creation paths that have not accepted the tag requirement, or if the tag taxonomy
does not include `CostCenter`.

### Budget filters

The cost owner approves the budget name, amount, start and end dates, actual and forecasted
thresholds, notification email, action group, resource group filters, and meter-category filters.

Stop if a meter category is guessed. Confirm it in Cost analysis or the price sheet before you
deploy. A budget notification is not a spend cap and must not be described as one.

### Gateway dimensions and quota

Use at most five custom dimensions in the APIM token metric. Keep them low-cardinality. This module
uses cost center, consumer, product, API, and model route. Cost center comes from the approved APIM
product mapping. Consumer comes from the APIM subscription ID. Model route is a static alias set by
the gateway owner. Unknown products map to one fixed value.

Do not use request headers, user ID, email, prompt text, conversation ID, request ID, or free text
as a chargeback metric dimension.

Stop if traffic can bypass the gateway route, if a product has no owner, if a quota would block a
shared product without an approved response path, if a caller can set its own cost center, or if
streaming clients cannot supply token usage where the backend needs `include_usage`.

### Rate table

Finance owns the token-to-cost table. Record the currency, effective date, model alias, token-rate
basis, owner, and reconciliation cadence. Cost Management remains the billed source.

Stop if rates are not approved, if the model alias in the query does not match logged model names,
or if someone wants to treat estimated token cost as the invoice.

## Implement

### 1. Complete the retained records

Update:

- `artifacts/finance/chargeback-decisions.json`
- `artifacts/finance/token-rate-table.json`
- `artifacts/policy/tag-allocation.bicepparam`
- `artifacts/cost/ai-budget-with-filters.bicepparam`
- `artifacts/apim/token-chargeback-policy.xml`
- `artifacts/queries/token-chargeback.kql`

Use the same target scope, APIM product IDs, token quota, and model aliases across the files.

### 2. Run preflight

```powershell
$targetScope = "/subscriptions/<approved-subscription-id>"
$deploymentLocation = "<approved-region>"

.\scripts\preflight.ps1 `
  -TargetScope $targetScope `
  -DeploymentLocation $deploymentLocation
```

```bash
target_scope="/subscriptions/<approved-subscription-id>"
deployment_location="<approved-region>"

./scripts/preflight.sh \
  --target-scope "$target_scope" \
  --deployment-location "$deployment_location"
```

Preflight rejects unresolved decisions, missing files, invalid JSON, invalid XML, a non-subscription
target scope, a mismatch between `TargetScope` and `approvedSubscriptionId`, user-level or
client-supplied token dimensions, a missing `CostCenter` tag, a missing product quota, and a missing
rate row. After those checks pass, it builds the Bicep files and runs subscription what-if for the
tag policy and budget deployments.

### 3. Deploy the tag policies

Deploy the policy assignments after the policy owner approves the what-if result.

```powershell
az deployment sub create `
  --location $deploymentLocation `
  --name "ai-finops-tag-allocation" `
  --parameters .\artifacts\policy\tag-allocation.bicepparam `
  --only-show-errors
```

```bash
az deployment sub create \
  --location "$deployment_location" \
  --name "ai-finops-tag-allocation" \
  --parameters ./artifacts/policy/tag-allocation.bicepparam \
  --only-show-errors
```

After the assignments exist, the policy owner reviews scope, identity, and current policy findings.
The resource-group tag requirement is still staged in `DoNotEnforce`. Promote it to `Default` only
through the approved policy change after the subscription-wide effect is accepted.

Then create remediation tasks for existing AI resources. Use one remediation task per inherit-tag
assignment. Do not start remediation until the resource owner accepts the tag effect on existing
resources.

### 4. Deploy the filtered AI budget

Deploy the budget after the cost owner approves the filters and action group.

```powershell
az deployment sub create `
  --location $deploymentLocation `
  --name "ai-finops-filtered-budget" `
  --parameters .\artifacts\cost\ai-budget-with-filters.bicepparam `
  --only-show-errors
```

```bash
az deployment sub create \
  --location "$deployment_location" \
  --name "ai-finops-filtered-budget" \
  --parameters ./artifacts/cost/ai-budget-with-filters.bicepparam \
  --only-show-errors
```

Confirm that the action-group owner knows what automation or notification receives the budget
event. The budget does not stop model use.

### 5. Merge the APIM policy

The gateway owner merges `artifacts/apim/token-chargeback-policy.xml` into the customer-owned APIM
policy source for the route created in
[Session 06](../../../sessions/06-apim-ai-gateway/implementation/README.md). Preserve existing
authentication, routing, safety, backend, rate-limit, and token-limit controls.

Apply the change through the approved gateway promotion path. If the APIM route already has a
product quota, update the existing quota branch instead of creating a second counter for the same
product.

### 6. Run the chargeback query

Open the approved Application Insights or Log Analytics workspace and run
`artifacts/queries/token-chargeback.kql`. Use the same time range that finance approved for the
first check.

The query uses `ApiManagementGatewayLlmLog` token columns and joins `ApiManagementGatewayLogs` on
`CorrelationId` for APIM product, subscription, API, and operation fields. It flags rows with
missing token counts instead of turning them into zero usage. It must not return prompts, responses,
headers, raw request bodies, caller IP, or user identifiers.

## Confirm the result

The module is complete when these checks pass:

1. Azure Policy shows the staged resource-group tag requirement and inherit-tag assignments at the
   approved subscription scope with the module marker.
2. The inherit-tag assignments have system-assigned managed identities and Contributor role
   assignments for remediation.
3. Cost Management shows the filtered budget with the approved actual and forecasted thresholds,
   email, and action group.
4. API Management emits the `ai-finops-chargeback` token metric with no more than five trusted
   custom dimensions, and the product quota returns the expected 403 or 429 response when exceeded.
5. The KQL query returns token rows grouped by cost center and consumer for the approved period and
   shows zero `MissingTokenRows` or a named owner reviewing them.
6. Finance accepts the rate table as the source for estimates and reconciles the estimate with Cost
   Management.

Stop if any result uses the wrong scope, a missing tag, an unapproved product, a client-supplied or
user-level metric dimension, a missing token count with no owner review, or an unapproved rate.

## After implementation

| What remains | Owner |
|---|---|
| Tag assignments, managed identities, and remediation tasks | Policy owner |
| Resource-group tag values and ownership changes | Resource owners |
| Filtered AI budget and notification recipients | Cost owner |
| APIM token metric and quota policy | Gateway owner |
| Application Insights metrics and gateway logs | Observability owner |
| Token rate table and reconciliation | Finance owner |
| Chargeback query and reports | FinOps analyst |

Restore through the owning paths:

1. Return the APIM policy to the last approved version if token metrics or quota behavior break the
   route.
2. Disable or delete only the filtered AI budget after the cost owner confirms no automation depends
   on it.
3. Remove remediation tasks before removing inherit-tag assignments.
4. Remove only policy assignments whose metadata contains `optional-module-ai-finops-token-chargeback`.
5. Keep Cost Management, APIM, and telemetry records for their normal retention period.

Do not remove the Session 06 gateway route or the Session 11 observability baseline to roll back
this module.
