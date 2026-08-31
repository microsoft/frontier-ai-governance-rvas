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

180 minutes · Approve the exact model version, then deploy it from version-controlled files

<!-- Notes: Frame the session as a deployment control under an existing Foundry resource. -->

---

## Control objective

> Deploy exact approved serverless API model versions through version-controlled deployment profiles, preflight checks, and Bicep. Meet the workload's processing-location requirement.

### Session result

- The JSON file records the approved deployment profile.
- Preflight compares it with current Azure state.
- Bicep creates the listed child deployments.

<!-- Notes: The external decision system remains the source for supporting review detail. -->

The preflight scripts and Bicep files check deployments on this path. An authorized principal can
still deploy through another template, the portal, the CLI, or an API.

---

## Why it matters

Model version and deployment type decide where processing happens and how quota is used.

Before Bicep changes the existing Foundry resource, preflight checks the exact model version,
deployment type, processing location, and quota.

![An approved model choice moves through preflight, deployment, review, and a keep, replace, or retire decision.](assets/diagrams/model-governance-flow.svg)

<!-- Notes: Workload purpose and processing location narrow into exact deployment state. A mismatch stops at preflight. -->

---

<!-- _class: decision -->

## Control boundary

### Covered

Supported serverless API model deployments that `main.bicep` creates under the existing
`AIServices` resource.

### Related paths

- Other templates, the portal, CLI, and API use separately governed deployment paths
- Instant-access models and managed-compute deployments require their own model governance design
- Sessions 01 and 03 own Foundry account, project, connection, network, and content-filter setup

> This path **does not enforce an allowlist across every deployment method**.

<!-- Notes: Separate version-controlled intent from platform-wide prevention. -->

---

## Architecture overview

Each business approval maps to a model deployment. The decision system keeps the full review.
`deployment-profiles.json` keeps the settings Bicep needs. Preflight compares those settings with
current Azure state before Bicep changes a child deployment.

<div class="cards">
<div class="card">

### Deployment choices

`models/deployment-profiles.json`

Records the external approval reference and the model version, SKU, capacity, content filter,
processing-location requirement, review date, quota headroom, and `NoAutoUpgrade` setting that
Bicep applies.

</div>
</div>

Azure holds the live deployment state. Session 05 uses the approved deployment name and model
coordinates. Another template, the portal, the CLI, or an API can bypass these checks.

<!-- Notes: Live service facts stay in Azure and are read again during preflight. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

| Decision | Chosen approach | Benefit | Cost |
|---|---|---|---|
| Where approval lives | Keep the full review in the decision system and deployment configuration in Git | The deployment path stays readable without duplicating the review | The external approval reference must match the change |
| Where service facts come from | Read lifecycle and quota from Azure during preflight | The gate uses the current platform state | A missing field stops the run for a named manual check |
| How versions move | Pin the exact version with `NoAutoUpgrade` | Every version change returns to approval | The owner must start retirement work before support ends |
| What these files check | Deploy approved model versions through the version-controlled profile, preflight, and Bicep path | Operators can preview each change and restore an earlier deployment file | Other authorized methods can still create deployments |

<!-- Notes: Revisit these choices when stable service fields or preventive controls become available. -->

---

<!-- _class: decision -->

## Approval checkpoint

**Pause** until the team records:

1. approved model name, version, and provider format;
2. approved workload purpose and a `global`, `data-zone:us`, `data-zone:eu`, `data-zone:apac`, or `region:<azure-region>` processing requirement;
3. decision authority and external decision reference;
4. lifecycle owner, review date, and change route; and
5. minimum unused quota percentage.

Start a new external decision and update the profile for every model version change.

<!-- Notes: Supporting terms and review detail stay in the referenced customer system. -->

---

## Processing location follows deployment type

| Requirement | Deployment family |
|---|---|
| Global processing | `GlobalStandard`, `GlobalProvisionedManaged`, `GlobalBatch` |
| Data-zone processing | `DataZoneStandard`, `DataZoneProvisionedManaged`, `DataZoneBatch` |
| Regional processing | `Standard`, `ProvisionedManaged` where supported |

For data-zone approvals, use `data-zone:us`, `data-zone:eu`, or `data-zone:apac`.
`DeveloperTier` is excluded. It is a 24-hour fine-tuned-model evaluation tier with no SLA or
data-residency guarantee.

The approved model and SKU must be available to the existing Foundry resource.

<!-- Notes: Resource location alone is not the inference processing boundary. -->

---

## Preflight checks live deployment inputs

- Deployment profile matches the approved change
- Review date has not passed
- Existing resource ID and `AIServices` kind
- Cognitive Services Contributor at the approved resource scope
- Live approved model, version, format, SKU, and capacity bounds
- Live `raiPolicyName` under the exact Foundry resource
- Match between a regional requirement and the Foundry account location
- Live lifecycle state and deprecation fields when Azure returns them
- Live quota metric and approved headroom when Azure returns a safe mapping
- **Bicep build and resource-scoped what-if**

<!-- Notes: The script rejects unrelated what-if resource IDs. -->

---

## Manual gates stay visible

Azure can omit `lifecycleStatus` or a quota `usageName`. It also does not expose a stable
region-to-data-zone mapping. Quota permissions can block the usage lookup.

When that happens:

1. Preflight stops.
2. The operator checks the source named in the stop message.
3. The operator reruns with the needed manual-confirmation switch.

The switch records a human check for that run. It does not claim that the CLI supplied the missing data.

<!-- Notes: Never turn missing API data into a false pass. -->

---

## Complementary policy control

This session deploys models through the version-controlled profiles, preflight scripts, and Bicep
files. Azure Policy can separately deny selected deployment SKU names across other authorized
methods.

[Microsoft guidance](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/concepts/deployment-types#restrict-deployment-types-with-azure-policy)
shows the `Microsoft.CognitiveServices/accounts/deployments/sku.name` restriction pattern.

<!-- Notes: Route Azure Policy deployment restrictions through the platform policy owner. -->

---

<!-- _class: implementation -->

## Implementation path

Timebox: 180 minutes

1. Complete `deployment-profiles.json` after normal change approval.
2. Name the existing Foundry resource in `sandbox.bicepparam`.
3. Run preflight with the operator object ID.
4. Resolve every stop and inspect the scoped what-if.
5. Deploy with `main.bicep`.
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
- a deployment name missing from the deployment profile.

<!-- Notes: The template uses incremental mode and an existing parent resource. -->

---

## Confirm the live deployment

For each approved profile, inspect the matching child resource.

Expected result:

- The provisioning state is `Succeeded`.
- The approved model name, version, and format match.
- The SKU and capacity match.
- `modelApprovalId` matches the deployment profile's `approvalId`.

No inference request is needed for this check.

<!-- Notes: Session 05 consumes the resulting live deployment. -->

---

## Live deployment and removal

<div class="cards">
<div class="card">

### Lifecycle owner

Owns the review date, replacement work, and change notification route.

</div>
<div class="card">

### Platform owner

Owns live availability, quota, deployment capacity, and removal.

</div>
<div class="card">

### Decision authority

Keeps the supporting detail in the approved change system.

</div>
</div>

Remove a deployment only when it carries the Session 04 marker.

<!-- Notes: Other deployments and the parent Foundry resource remain in place. -->

---

## Recap

- Bicep reads `deployment-profiles.json` as deployment input.
- Azure remains the live source for lifecycle, availability, and quota.
- Preflight names each required manual check when stable CLI data is missing.
- Separately governed deployment methods remain available.
- [Session 05](../05-governed-agent-baseline/) uses the approved live deployment.

<!-- Notes: Close on the review record that Session 05 consumes. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: Confirm the current owner and next review date. -->
