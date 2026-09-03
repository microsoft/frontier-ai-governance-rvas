# Foundry estate and lifecycle operations

## Session scope

### What we will do

**Objective.** Answer "what AI do we actually run, and where" from one command instead of a portal tour.

Deploy a shared Azure Workbook for live review, then run one Azure Resource Graph query that
returns every Azure AI account across the approved management groups with its kind, SKU, region,
network setting, and tags. The report adds model deployments, checks their live lifecycle and
retirement data, then lists account, model, Service Health, and Advisor findings for the named
owners.

### Why it matters

**Problem.** Azure does not provide one governed, tenant-wide inventory of AI accounts, model
deployments, and retirement signals. An account created outside the approved path can stay
invisible until it appears on an invoice or in an incident.

**Solution.** One report reads the estate, matches deployed models with the live catalog, and gives
the lifecycle owner the signals that need a keep, replace, or retire decision.

### Boundaries

This session extends the operating model from Sessions 01, 03, and 11 across the approved estate.

Azure Resource Manager stays authoritative for the estate and the shared workbook. The repository
holds the scope decision, query definitions, workbook definition, and deployment template. The
report is written to a path the operator chooses outside this repository, or printed to the console.

Resource Graph exposes the account, Service Health, and Advisor records. It does not expose model
deployments, so the report reads them per account. The report reads the regional Models API to
check lifecycle status and retirement dates. Billed cost stays with Microsoft Cost Management, and
runtime telemetry stays with Session 11.

## Architecture

### Architecture at a glance

The workbook gives operators a portal view. The report applies the governance rules and fails while
findings stay open.

**First,** it runs `foundry-accounts.kql` against each approved management group through
`az graph query`. Resource Graph returns every `microsoft.cognitiveservices/accounts` resource the
caller can read, joined to `ResourceContainers` so each row carries its subscription name. Paging
uses `--first` with the returned skip token, so a large tenant returns completely.

**Second,** it classifies each account against `estate-scope.json`. An account whose kind is in
`inScopeAccountKinds` belongs to the AI estate and is checked for the required tags and an approved
region. An account of another Cognitive Services kind is reported as adjacent, and becomes a finding
unless it is a recorded exception. That second list is where unmanaged AI usually shows up.

**Third,** it lists the model deployments on each in-scope account with
`az cognitiveservices account deployment list`, then reads the regional Models API. The report
matches the account kind, model name, format, and version to record lifecycle status and inference
or SKU retirement dates. It creates a finding when the API has no matching entry, a deployment is
deprecated or retired, or a retirement date falls inside the configured warning window.

**Fourth,** it queries `ServiceHealthResources` for Azure AI retirement advisories and
`AdvisorResources` for open service upgrade and retirement recommendations. Service Health signals
what is changing. Advisor can identify affected in-scope accounts and provide the next action.

For cost, the report collects the distinct values of the cost tag across in-scope accounts. Cost
Management is authoritative for the billed amount; those tag values are the filter that makes its
view match this inventory.

The shared workbook uses the same Resource Graph tables and ARM endpoints to show account posture,
deployments, model lifecycle, Foundry projects, retirement advisories, Advisor recommendations, and
resource health. It exposes live state only. Use the report to decide whether a row is compliant
with the recorded estate scope.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
|---|---|---|---|
| Estate read | One Resource Graph query per management group | Crosses subscriptions in one call and needs only Reader | Resource Graph lags Resource Manager by a short interval |
| Model layer | One CLI call per in-scope account | Returns the model, version, SKU, and capacity that Resource Graph omits | Run time grows with account count |
| Scope of the query | Every Cognitive Services account, classified afterwards | Surfaces accounts of an unexpected kind | The adjacent list needs triage, not just reading |
| Exceptions | Named in the scope record with an owner and expiry | A known account stops producing a finding without hiding it | An expired exception still needs a human review |
| Cost | Report the cost tag values, read the amount in Cost Management | Keeps one authoritative source for billed cost | The report cannot show spend on its own |
| Lifecycle | Models API plus Service Health and Azure Advisor | Detects model and service retirement signals after deployment | The lifecycle owner must assess a replacement against the workload |
| Operator view | Shared Workbook deployed with Bicep | Shows current estate and retirement state in the Azure portal | It does not replace the report's scope and exception checks |
| Output | Console summary, optional file outside the repository | No customer resource names enter source control | Trend analysis needs the operator to keep the files |

### Architecture guidance

Use [Microsoft Foundry Models lifecycle and support policy](https://learn.microsoft.com/azure/foundry/openai/concepts/model-retirements)
for the Models API fields and Azure OpenAI Service retirement notifications.

Use [Identify impacted resources for service retirements by using Azure Resource Graph](https://learn.microsoft.com/azure/service-health/service-retirement-unified-impact-queries)
for the Service Health, Resource Graph, and Advisor handoff.

Use [Quickstart: Run Resource Graph query using Azure CLI](https://learn.microsoft.com/azure/governance/resource-graph/first-query-azurecli)
for the `resource-graph` extension and management-group scope arguments.

## Before you start

Confirm these prerequisites:

- The management group IDs in the estate scope record are the ones the governance team is
  accountable for.
- The operator has the **Reader** role at each of those management groups. Resource Graph returns
  only what the caller can read, so a missing assignment shows up as a smaller estate, not as an
  error.
- Session 01 has recorded the owner, cost, and environment tag keys used across the AI estate, and
  those exact keys go into `requiredTagKeys`.
- The approved regions match the processing-location decision recorded in Session 03.
- The Azure CLI is installed and signed in, and the `resource-graph` extension is available:
  `az extension add --name resource-graph`.
- Python 3 is installed. The paired PowerShell and Bash entry points use the same local report
  helper.
- The workbook deployment operator has **Workbook Contributor** or **Contributor** on the approved
  workbook resource group.
- The operator has a path outside this repository for the report file, if one is kept.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Record | [`artifacts/estate-scope.json`](artifacts/estate-scope.json) | The platform inventory owner and the estate report scripts |
| Runtime | [`artifacts/queries/foundry-accounts.kql`](artifacts/queries/foundry-accounts.kql) | The estate report scripts and Azure Resource Graph Explorer |
| Runtime | [`artifacts/queries/service-health-retirements.kql`](artifacts/queries/service-health-retirements.kql) | The estate report scripts and Azure Resource Graph Explorer |
| Runtime | [`artifacts/queries/advisor-retirement-findings.kql`](artifacts/queries/advisor-retirement-findings.kql) | The estate report scripts and Azure Resource Graph Explorer |
| Deployment | [`artifacts/infra/main.bicep`](artifacts/infra/main.bicep) | The workbook deployment operator |
| Deployment | [`artifacts/monitoring/estate-lifecycle-workbook.json`](artifacts/monitoring/estate-lifecycle-workbook.json) | The shared Azure Workbook |

Resolve the scope values in the approved private configuration path, then run preflight in
**Implement › 1. Complete the estate scope record**. It rejects every unresolved decision, checks
that the owner and cost tag keys also appear in the required tag list, checks that every recorded
exception has an owner and expiry, and confirms Resource Graph read access at each management group.
When you pass the workbook subscription and resource group, preflight also runs a resource-group
what-if. It must contain only the tagged `Microsoft.Insights/workbooks` resource.

## Decisions and stop conditions

### Estate scope

Choose management groups, not a list of subscriptions. A subscription list goes stale the moment
someone creates a subscription, which is the case this session exists to catch.

Stop if the accountable governance team does not own every listed management group, or if a
management group is listed that the operator cannot read.

### In-scope account kinds

`inScopeAccountKinds` starts with `AIServices` and `OpenAI`. Those are the account kinds behind
Microsoft Foundry and Azure OpenAI. Every other Cognitive Services kind lands in the adjacent list.

Do not widen this list to silence the adjacent report. Widening it says those accounts are part of
the governed AI estate and must carry the required tags.

Stop if a kind is added without an owner accepting the tag and region requirements for those
accounts.

### Required tags

Use the exact tag keys from Session 01. The owner tag and the cost tag must both appear in
`requiredTagKeys`; preflight rejects a record where they do not, because the report depends on both.

Stop if the tag keys differ from the Session 01 policy, since the report would then disagree with
the guardrail assignment.

### Lifecycle review

Set `lifecycleOwner` to the role that can start a model replacement or service-retirement response.
Set `modelRetirementWarningDays` to the minimum lead time needed to evaluate and deploy a
replacement. The default is 90 days.

The Models API is authoritative for a deployed model's catalog lifecycle and retirement data.
Service Health announces affected-service retirement advisories. Azure Advisor can identify
affected resources. These are live signals, not approval records.

Stop the review when a deployment is absent from the regional Models API response, is deprecated
or retired, or retires inside the warning period. Also stop when the report returns a matching
Service Health advisory or Advisor recommendation. The lifecycle owner records the replacement,
retirement, or accepted exception through the customer change process.

### Exceptions

A recorded exception needs an account name, a reason, a named owner, and an expiry date. It stops
one account from producing a finding. It does not remove the account from the report.

Stop if an exception has no expiry, or if the exception list is growing faster than the findings
list is shrinking. That pattern means the scope record is wrong, not the estate.

### What a finding means

A finding is an account that needs a human decision: tag it, move it, bring it into the approved
path, or record an exception. The report exits with a failure while any finding is open.

Stop the review, rather than the report, when a finding has no owner. An unowned Azure AI account is
the finding.

## Implement

### 1. Complete the estate scope record

Resolve every `__REQUIRED_*__` value in the approved private configuration path. Set the approved
workbook deployment scope, then run preflight:

```powershell
$targetScope = "<approved estate scope alias>"
$workbookSubscriptionId = $env:AZURE_SUBSCRIPTION_ID
$workbookResourceGroup = "approved-estate-workbook-resource-group"
.\scripts\preflight.ps1 `
  -TargetScope $targetScope `
  -WorkbookSubscriptionId $workbookSubscriptionId `
  -WorkbookResourceGroup $workbookResourceGroup
```

```bash
target_scope="<approved estate scope alias>"
workbook_subscription_id="${AZURE_SUBSCRIPTION_ID}"
workbook_resource_group="approved-estate-workbook-resource-group"
./scripts/preflight.sh \
  --target-scope "$target_scope" \
  --workbook-subscription-id "$workbook_subscription_id" \
  --workbook-resource-group "$workbook_resource_group"
```

Preflight confirms read access to each management group with a counting query and previews the
shared workbook. A management group that fails here is a missing role assignment, not a missing
estate.

### 2. Deploy the estate and lifecycle workbook

After the workbook operator approves the preview:

```powershell
.\scripts\deploy-workbook.ps1 `
  -TargetScope $targetScope `
  -SubscriptionId $workbookSubscriptionId `
  -ResourceGroup $workbookResourceGroup
```

```bash
./scripts/deploy-workbook.sh \
  --target-scope "$target_scope" \
  --subscription-id "$workbook_subscription_id" \
  --resource-group "$workbook_resource_group"
```

Open **Azure AI estate and lifecycle review** in Azure Workbooks. Select only subscriptions within
the approved management groups. The dashboard is for live triage. It does not add a subscription
to the governed estate.

### 3. Run the estate report

```powershell
.\scripts\build-estate-report.ps1
```

```bash
./scripts/build-estate-report.sh
```

The console summary shows the account counts, model deployment count, Service Health signals, Azure
Advisor recommendations, and every finding. The JSON report includes the lifecycle fields and
account owner tag for each deployment. To keep the full record for a review, pass a path outside
this repository:

```powershell
.\scripts\build-estate-report.ps1 -OutputPath "<path outside this repository>\estate-report.json"
```

```bash
./scripts/build-estate-report.sh --output-path "<path outside this repository>/estate-report.json"
```

### 4. Give every finding an owner

Work through account findings with the platform team. Each one ends in one of four places: the
account gets its tags, it moves to an approved region, it joins the Session 01 approved path, or it
becomes a recorded exception with an owner and expiry.

Triage the adjacent list separately. An unexpected account kind is often a team using an Azure AI
service outside the governed path.

The lifecycle owner handles deployment and service-retirement findings. Assess the suggested or
available replacement against the workload, use Session 03 to approve and deploy it, then remove
the old deployment only after its consumers have moved. Service Health and Advisor findings close
through their linked service-owner change path.

### 5. Connect the cost view

Open Microsoft Cost Management for the same subscriptions and filter by the cost tag key, using the
tag values the report printed. The amounts come from Cost Management; the inventory comes from this
report. Together they answer which AI accounts exist and what each one costs.

## Confirm the result

Open the workbook and confirm it returns the selected account, deployment, model catalog, Foundry
project, service-retirement, Advisor, and resource-health views. Then run the estate report against
the approved scope with no findings outstanding.

The report reads every approved management group, prints the in-scope account count, adjacent
account count, model deployment count, Service Health signals, and Advisor retirement findings. It
passes only when each in-scope account has the required tags, an approved region, a recorded kind,
and no lifecycle finding.

## After implementation

The estate scope record and the query stay with the platform inventory operating configuration. The
platform inventory owner named in the record owns both.

Run the report on the recorded review cadence, after a subscription joins the tenant, after a
management group is restructured, and before any AI governance review. A rising adjacent count
means teams are creating Azure AI accounts outside the approved path.

The lifecycle owner reviews each model and service-retirement finding before its warning deadline.
Review the exception list at each run. An expired exception is a finding again.

The platform inventory owner keeps the workbook deployment in the approved resource group. Update
the definition through this session and deploy it again. Remove the tagged workbook only after the
owner confirms no review process still uses it. To stop running the session, remove the report from
the review schedule and delete any report files kept outside this repository. Keep the scope record;
it defines the estate the team agreed to watch.
