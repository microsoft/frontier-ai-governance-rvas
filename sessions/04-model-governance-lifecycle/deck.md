---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Session 04</p>

# Model governance, data residency, quota, and lifecycle

**180 minutes · Approve a model version, then deploy it through a controlled path**

<!-- Notes: Frame the session as a deployment control under an existing Foundry resource. -->

---

## Control objective

> Deploy exact approved serverless API model versions through a versioned path that meets the workload's processing-location requirement.

### Session result

- The JSON file defines the desired deployment state.
- Preflight compares the desired deployment state with current Azure state.
- Bicep creates the listed child deployments.

<!-- Notes: The external decision system remains the source for supporting review detail. -->

Use this control for one deployment path. A principal with access can still use another path.

---

## Why it matters

Model version and deployment type decide where processing happens and how quota is used.

The controlled path checks those facts before changing the existing Foundry resource.

![Approval funnel and model lifecycle loop](assets/diagrams/model-governance-flow.svg)

<!-- Notes: Workload purpose and processing location narrow into exact deployment state. A mismatch stops at preflight. -->

---

<!-- _class: decision -->

## Control boundary

### Covered

Supported serverless API model deployments created by `main.bicep` under the existing `AIServices` resource.

### Outside this control

- Deployments created through another template, the portal, CLI, or API
- Instant-access models
- Managed-compute deployments
- Foundry account, project, connection, network, and content filter creation

> This path does not create a platform-enforced allowlist.

<!-- Notes: Separate version-controlled intent from platform-wide prevention. -->

---

## Architecture overview

Each business approval leads to a model deployment. The decision system keeps the full review; Git
carries the choices needed for deployment. Preflight checks those choices against current Azure
state before Bicep changes the child deployment.

<div class="cards">
<div class="card">

### Deployment choices

`models/deployment-profiles.json`

Records the external approval reference, model version, SKU, capacity, content filter,
processing-location requirement, review date, quota headroom, and `NoAutoUpgrade` setting that
Bicep will apply.

</div>
</div>

Azure owns live state. Session 05 receives the approved deployment name and model coordinates.
Portal, CLI, API, and template changes made elsewhere stay outside this boundary.

<!-- Notes: Live service facts stay in Azure and are read again during preflight. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Chosen approach | Why it works | Tradeoff |
|---|---|---|---|
| Where approval lives | Full review in the decision system; deployment configuration in Git | The deployment path stays readable without copying the review | The external approval reference must match the change |
| Where service facts come from | Read lifecycle and quota from Azure during preflight | The gate uses current platform state | A missing field stops the run for a named manual check |
| How versions move | Pin the exact version with `NoAutoUpgrade` | Each version change returns to approval | The owner must start retirement work before support ends |
| What this path controls | Use this versioned path to deploy approved model versions | Operators get a defined preview and restore boundary | Other authorized paths can still create deployments |

<!-- Notes: Revisit these choices when stable service fields or preventive controls become available. -->

---

<!-- _class: decision -->

## Approval checkpoint

Pause until the customer has recorded:

1. approved model name, version, and provider format;
2. approved workload purpose and a `global`, `data-zone:us`, `data-zone:eu`, `data-zone:apac`, or `region:<azure-region>` processing requirement;
3. decision authority and external decision reference;
4. lifecycle owner, review date, and change route; and
5. minimum unused quota percentage.

Start a new external decision and profile change for every model version change.

<!-- Notes: Supporting terms and review detail stay in the referenced customer system. -->

---

## Processing location follows deployment type

| Requirement | Deployment family |
|---|---|
| Global processing | `GlobalStandard`, `GlobalProvisionedManaged`, `GlobalBatch` |
| Data-zone processing | `DataZoneStandard`, `DataZoneProvisionedManaged`, `DataZoneBatch` |
| Regional processing | `Standard`, `ProvisionedManaged` where supported |

Data-zone approvals use only `data-zone:us`, `data-zone:eu`, or `data-zone:apac`. `DeveloperTier`
is excluded because it is a 24-hour fine-tuned-model evaluation tier with no SLA or
data-residency guarantee.

The approved model and SKU must be available to the existing Foundry resource.

<!-- Notes: Resource location alone is not the inference processing boundary. -->

---

## Preflight checks live control inputs

- Deployment profile matches the approved change
- Review date has not passed
- Existing resource ID and `AIServices` kind
- **Cognitive Services Contributor** at the approved resource scope
- Live approved model, version, format, SKU, and capacity bounds
- Live `raiPolicyName` under the exact Foundry resource
- Match between a regional requirement and the Foundry account location
- Live lifecycle state and deprecation fields when Azure returns them
- Live quota metric and approved headroom when Azure returns a safe mapping
- Bicep build and resource-scoped what-if

<!-- Notes: The script rejects unrelated what-if resource IDs. -->

---

## Manual gates stay visible

Azure can omit `lifecycleStatus` or a quota `usageName`.

It also does not expose a stable region-to-data-zone mapping. Quota permissions can block the usage lookup.

When that happens:

1. preflight stops;
2. the operator checks current model details, retirement notices, the Foundry **Quota** page, or the current data-zone region list, as referenced by the stop;
3. the operator reruns with only the needed manual-confirmation switch.

The switch confirms a human check for that run. It does not claim that the CLI supplied missing data.

<!-- Notes: Never turn missing API data into a false pass. -->

---

## Complementary policy control

This session deploys models through the versioned path. Azure Policy can separately deny selected
deployment SKU names across other authorized paths.

[Microsoft guidance](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types#restrict-deployment-types-with-azure-policy)
shows the `Microsoft.CognitiveServices/accounts/deployments/sku.name` restriction pattern.

<!-- Notes: Do not add that policy to this session. Route it through the platform policy owner. -->

---

<!-- _class: implementation -->

## Implementation path

**Timebox:** 210 minutes

1. Complete `deployment-profiles.json` after the normal change approval.
2. Name the existing Foundry resource in `sandbox.bicepparam`.
3. Run preflight with the operator object ID.
4. Resolve every stop and inspect the scoped what-if.
5. Deploy `main.bicep`.
6. Confirm every live child deployment.

<!-- Notes: Session time starts with the external decision already made. -->

---

## Run preflight

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -ResourceGroupName $resourceGroup `
  -FoundryAccountName $foundryAccount `
  -OperatorObjectId $operatorObjectId
```

```bash
./scripts/preflight.sh \
  --approved-subscription-id "$approved_subscription_id" \
  --resource-group-name "$resource_group" \
  --foundry-account-name "$foundry_account" \
  --operator-object-id "$operator_object_id"
```

<!-- Notes: Add a manual switch only after completing the portal check listed by preflight. -->

---

## What-if is tightly scoped

Preflight requests `FullResourcePayloads` output and permits changes only to:

```text
.../Microsoft.CognitiveServices/accounts/<foundry>/deployments/<listed-name>
```

It rejects:

- another resource ID;
- Ignore, Delete, or Unsupported;
- any change type other than Create, Modify, or NoChange; or
- a deployment name missing from desired state.

<!-- Notes: The template uses incremental mode and an existing parent resource. -->

---

## Confirm the live deployment

For every approved profile, inspect the matching child resource.

Expected result:

- provisioning state is `Succeeded`;
- approved model name, version, and format match;
- SKU and capacity match; and
- `modelApprovalId` matches the deployment profile's `approvalId`.

No inference request is needed for this check.

<!-- Notes: Session 05 consumes the resulting live deployment. -->

---

## Live state and removal

<div class="cards">
<div class="card">

### Lifecycle owner

Review date, replacement work, and change notification route.

</div>
<div class="card">

### Platform owner

Live availability, quota, deployment capacity, and removal.

</div>
<div class="card">

### Decision authority

Supporting detail stays in the approved customer change system.

</div>
</div>

Remove a deployment only when it carries the Session 04 marker.

<!-- Notes: Other deployments and the parent Foundry resource remain in place. -->

---

## Recap

- The desired-state file feeds Bicep.
- Live lifecycle, availability, and quota stay in Azure.
- Manual checks are explicit when stable CLI data is missing.
- This control applies to the deployment path in this kit. It does not cover every path into the platform.
- [Session 05](../05-governed-agent-baseline/) consumes the approved live deployment.

<!-- Notes: Close on the review record that Session 05 consumes. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: Confirm the current owner and next review date. -->
