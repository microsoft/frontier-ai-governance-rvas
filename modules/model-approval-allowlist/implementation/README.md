# Implementation - Model approval decisions and the Foundry deployment allowlist

## Module scope

### What we will do

**Objective.** Turn "which models may we use" from a conversation into a record and a policy that reads
from it.

Fill in a model approval register: for each model, its publisher, asset ID, source category,
hosting route, approved deployment types, processing location, approvers, and review date. Then
assign the two built-in Foundry model-deployment policies at the approved resource group, taking
their parameters straight from that register. The check reads both live assignments and confirms
their effect and allowed values still match.

### Why it matters

**Problem.** Session 03 deploys models that someone already approved, but nothing records who approved
them or why. So the approved list lives in a spreadsheet or in a conversation, the platform can't
read it, and a developer can deploy a partner-hosted preview model that no reviewer ever saw.

**Solution.** One register holds the decision, and Azure Policy evaluates the same values at deployment
time.

### Boundaries

This module sits outside the numbered sequence and follows Sessions 01 and 03.

It changes two policy assignments at one resource group and adds the approval register. Azure
Policy holds the live allowed values; the register holds the reasoning behind them and is the file
the parameter file reads.

The policies evaluate model deployments in Microsoft Foundry. They do not govern what a model is
used for after deployment, and they do not replace the Session 09 evaluation gates or the Session 03
version-pinning and quota decisions. Deployment types stay with Session 03; this module records
which types each approved model may use and leaves their enforcement there.

## Architecture

### Architecture at a glance

A reviewer opens a model card in the Foundry model catalog and copies two values: the publisher
name and the model asset ID. Those values, plus the approval reasoning, become one entry in
`model-approval-register.json`. The Bicep parameter file loads that register, so the assignment
cannot allow a model the register does not list.

Two built-in policies do different jobs:

- **Foundry model deployments should only use approved models** answers "is this exact model on our
  list?" through `allowedPublishers` and `allowedAssetIds`.
- **Foundry model deployments should meet eligibility requirements** answers "does this model meet
  our standards for source and maturity?" through `onlyAllowDirectFromAzure` and
  `denyPreviewModels`.

The second policy is how the hosting question gets a technical answer. Foundry Models split into
two categories. **Models sold by Azure** are hosted and operated by Azure, billed through your Azure
subscription, covered by Azure service-level agreements, and supported by Microsoft under Microsoft
Product Terms. **Models from partners and community** come with license terms and pricing set by
the provider, and the provider supports them. For serverless deployments of these models, Microsoft
hosts the infrastructure and acts as the data processor for the prompts you submit and the content
returned. Setting `onlyAllowDirectFromAzure` to `true` keeps deployments in the first category.

Both policies evaluate at deployment time. The catalog still shows every model; the **Deploy**
action is disabled with a message naming the policy and assignment that blocked it. Asset IDs match
as a **prefix**, so `.../models/gpt-5` also matches `gpt-5.2` and `gpt-5.4`. Preflight rejects any
asset ID that does not end in a trailing slash or an explicit version.

Start in `Audit`, read the compliance results, then move to `Deny` through the approved change path.

### Design choices and tradeoffs

| Decision | Chosen approach | Benefits | Costs and limitations |
|---|---|---|---|
| Approval record | One JSON register that the parameter file reads | The assignment cannot drift from the decision | The register must be updated before the policy, not after |
| Model identity | Built-in approved-models policy with publisher and asset ID | Uses the Microsoft-maintained definition instead of a custom rule | The list needs an owner and a review date, or it goes stale |
| Model source and maturity | Built-in eligibility policy with both toggles on | Covers new partner and preview models without editing the list | A justified partner model needs the toggle relaxed at that scope |
| Asset ID precision | Trailing slash or explicit version, checked by preflight | Stops prefix matching from allowing a successor model | Each new model version needs a register entry |
| Rollout | Audit first, then Deny through the change path | Shows the real blast radius before anything is blocked | An Audit assignment blocks nothing while it runs |
| Scope | Resource group assignment | Keeps the first rollout inside the Session 01 boundary | Deployments outside that resource group are unaffected |

### Architecture guidance

Use [Built-in policies for model deployment in Microsoft Foundry
portal](https://learn.microsoft.com/azure/foundry/how-to/model-deployment-policy) for both policy
display names, their parameters, prefix matching on asset IDs, the required Owner or Resource Policy
Contributor role, and what a developer sees when a deployment is blocked.

Use [Overview of Microsoft Foundry
Models](https://learn.microsoft.com/azure/foundry/concepts/foundry-models-overview) for the split
between models sold by Azure and models from partners and community, and for who sets license terms
and acts as data processor in a serverless deployment.

Use [Foundry Models sold by
Azure](https://learn.microsoft.com/azure/foundry/foundry-models/concepts/models-sold-directly-by-azure)
to confirm whether a specific model is in the sold-by-Azure category before you record its source.

## Before you start

Confirm these prerequisites:

- The Session 01 Foundry baseline exists in the approved nonproduction resource group, and that
  resource group is the assignment scope.
- The policy owner holds **Owner** or **Resource Policy Contributor** at that exact resource group.
- The reviewers who sign each model entry are named people or named roles, not a team mailbox.
- Session 03 has recorded the workload's processing-location requirement, so each register entry can
  name the deployment types that meet it.
- Any earlier model-deployment policy assignment at this scope is recorded in the approved change
  system, and its reference goes into `previousAssignmentReference`.
- Azure CLI with Bicep support is installed and signed in to the approved subscription.

### Implementation files

| Type | File | Consumer |
|---|---|---|
| Record | [`artifacts/model-approval-register.json`](artifacts/model-approval-register.json) | The model reviewers, the policy owner, and the policy parameter file |
| Deployment | [`artifacts/policy/model-governance.bicep`](artifacts/policy/model-governance.bicep) | The platform deployment pipeline |
| Deployment | [`artifacts/policy/model-governance.bicepparam`](artifacts/policy/model-governance.bicepparam) | The platform deployment pipeline |

Resolve the register values in the approved private configuration path, then run preflight in
**Implement › 2. Check the register and preview the assignment**. It rejects every unresolved
decision, rejects an asset ID that could match a successor model, rejects a register entry the
eligibility toggles would deny anyway, and runs `az deployment group what-if` as the deployment
preview.

## Decisions and stop conditions

### What counts as an approved model

A model enters the register only when three reviewers agree: the platform owner, the security
owner, and the data owner. Each entry records the use-case boundary and the highest data
classification the model may process. `evaluationReference` points to the Session 09 evaluation run
that produced the quality result behind the approval.

Stop if an entry has no named approvers, no review date, or an evaluation reference that points to
a run against a different model version.

### Model source and hosting

Record `sourceCategory` as `SoldByAzure` or `PartnersAndCommunity`, taken from the model catalog and
confirmed against the sold-by-Azure model list. Record `hostingRoute` so the entry says whether the
model runs as an Azure-hosted serverless API or on managed compute in your own subscription.

For a partner or community model, the provider sets the license terms and the support level, and
Microsoft acts as the data processor for serverless prompts and responses. That is a different
contractual position from a model sold by Azure. The legal and privacy reviewers decide whether it
is acceptable for the recorded data classification.

Stop if a partner or community model is proposed without a reviewed license position, or if the
register claims `SoldByAzure` for a model that the sold-by-Azure list does not contain.

### Eligibility toggles

Both toggles start at `true`: deny models that are not sold by Azure, and deny preview models. That
is the default posture for a governed nonproduction estate.

Relaxing `onlyAllowDirectFromAzure` is a governance decision, not a deployment convenience. Take it
at the assignment scope where the partner model is actually needed, and record the decision in the
change system.

Preflight stops when the register approves a model that the toggles would deny. Resolve that
contradiction in the register, not by editing the parameter file.

### Asset ID precision

Asset IDs match as a prefix. `azureml://registries/azure-openai/models/gpt-5` also matches GPT-5.2
and GPT-5.4. Add a trailing slash to allow every version of one model, or use the full asset ID with
`versions/<n>` to allow one version.

Stop if any asset ID lacks a trailing slash and lacks an explicit version. Preflight rejects it.

### Effect and rollout

Deploy with `assignmentEffect` set to `Audit`. Read the compliance results, contact the owners of
any noncompliant deployment, then change the register to `Deny` and redeploy through the approved
change path.

Stop if a noncompliant deployment found during Audit has no owner, or if moving to Deny would block
a running workload that has no approved replacement model.

### Model router

If this scope uses model router, include `Microsoft` in `allowedPublishers`, because Microsoft
publishes model router. Also include the publisher of every model the router may select. Without
those names, the policy blocks the model router deployment.

Stop if model router is in use and its routed publishers are not in the register.

## Implement

### 1. Resolve the built-in policy definition IDs

Look up both definitions by display name and export them for the parameter file:

```powershell
$env:RVAS_APPROVED_MODELS_POLICY_ID = az policy definition list `
    --query "[?displayName=='Foundry model deployments should only use approved models'].id | [0]" `
    --output tsv
$env:RVAS_MODEL_ELIGIBILITY_POLICY_ID = az policy definition list `
    --query "[?displayName=='Foundry model deployments should meet eligibility requirements'].id | [0]" `
    --output tsv
```

```bash
export RVAS_APPROVED_MODELS_POLICY_ID=$(az policy definition list \
  --query "[?displayName=='Foundry model deployments should only use approved models'].id | [0]" \
  --output tsv)
export RVAS_MODEL_ELIGIBILITY_POLICY_ID=$(az policy definition list \
  --query "[?displayName=='Foundry model deployments should meet eligibility requirements'].id | [0]" \
  --output tsv)
```

If a lookup returns nothing, confirm the display names in the Azure Policy definitions blade. The
approved-models definition was previously named *Cognitive Services Deployments should only use
approved Registry Models*, and its definition ID did not change.

### 2. Check the register and preview the assignment

Complete one register entry per approved model in the approved private configuration path. Keep
`allowedAssetIds` and `allowedPublishers` identical to the values in `approvedModels`.

```powershell
$targetScope = "<approved model policy scope alias>"
$resourceGroup = "<approved nonproduction resource group>"
.\scripts\preflight.ps1 -TargetScope $targetScope -ResourceGroup $resourceGroup
```

```bash
target_scope="<approved model policy scope alias>"
resource_group="<approved nonproduction resource group>"
./scripts/preflight.sh --target-scope "$target_scope" --resource-group "$resource_group"
```

Read the what-if output. It must create exactly the two assignments and change nothing else.

### 3. Deploy the assignments in Audit

```powershell
az deployment group create `
    --resource-group $resourceGroup `
    --template-file .\artifacts\policy\model-governance.bicep `
    --parameters .\artifacts\policy\model-governance.bicepparam
```

```bash
az deployment group create \
  --resource-group "$resource_group" \
  --template-file ./artifacts/policy/model-governance.bicep \
  --parameters ./artifacts/policy/model-governance.bicepparam
```

Wait at least 15 minutes. A new assignment does not take effect immediately.

### 4. Review compliance, then move to Deny

Open **Policy › Compliance** in the Azure portal and find both assignments. Noncompliant
deployments appear within one evaluation cycle, typically up to 24 hours.

For each noncompliant deployment, either add the model to the register through the approval review,
or agree a migration with its owner. When the list is clear, set `assignmentEffect` to `Deny` in the
register, rerun preflight, and redeploy through the approved change path.

## Confirm the result

Run the live check against the approved resource group:

```powershell
.\scripts\check-model-policy.ps1 -ResourceGroup $resourceGroup
```

```bash
./scripts/check-model-policy.sh --resource-group "$resource_group"
```

The script reports both assignments using the register's effect, with the same allowed asset IDs,
allowed publishers, and eligibility toggles. In the Foundry portal, a model outside the register
still appears in the catalog with its **Deploy** action disabled and a message naming the policy.

## After implementation

Both policy assignments stay in place at the approved resource group. The policy owner owns them.
The model reviewers own the register and its review dates.

Run the live check after any register change, after a redeployment, and at each scheduled review.
A mismatch means someone edited the assignment outside the deployment path; restore it by
redeploying from the register rather than editing parameters in the portal.

Adding a model is a register change followed by a redeployment, in that order. Removing a model is
the same, plus a migration agreement with the owner of any deployment that used it.

To restore the earlier state, redeploy the assignment recorded in `previousAssignmentReference`, or
remove both assignments at the exact resource group scope:

```powershell
az policy assignment delete --name "rvas-mod-approved-models" --resource-group $resourceGroup
az policy assignment delete --name "rvas-mod-model-eligibility" --resource-group $resourceGroup
```

```bash
az policy assignment delete --name "rvas-mod-approved-models" --resource-group "$resource_group"
az policy assignment delete --name "rvas-mod-model-eligibility" --resource-group "$resource_group"
```

Removing the assignments leaves every existing model deployment running. Keep the register; it is
the record of what was approved and by whom.
