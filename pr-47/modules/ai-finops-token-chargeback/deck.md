---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: AI cost allocation, budgets, and gateway token chargeback
description: Optional implementation module for AI cost allocation, budget notifications, and API Management token chargeback.
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Optional module</p>

# AI cost allocation, budgets, and gateway token chargeback

**270 minutes - Attribute AI cost before the invoice debate**

<!--
Set the frame: this module adds finance-grade attribution to the existing gateway and cost baseline.
-->

---

## Control objective

Assign cost-allocation tag policy, deploy filtered AI budget notifications, add gateway token
metrics and per-product token quotas, and keep the finance-approved token rate table.

![Azure Cost Management](assets/icons/microsoft/azure-cost-management.svg)

---

## Why it matters

**Problem.** Shared AI routes can hide which product, team, or cost center drove token use.

**Solution.** Tags bind billed cost to owners, and APIM token metrics attribute usage before billed
cost lands.

**EU AI Act.** No article requires cost allocation. Token records can support Article 12 for
high-risk systems. Engineering mapping, not legal advice.

<!--
Budgets notify. They do not stop spend. The quota boundary lives at the gateway.
-->

---

## Architecture at a glance

| Layer | Control | Authoritative state |
|---|---|---|
| Azure Policy | Stage subscription resource-group tag requirements and inherit tags to resources | Policy assignments and remediation tasks |
| Cost Management | Filtered AI budget with actual and forecasted thresholds | Budget resource and action group |
| API Management | Token metrics and per-product token quota | Gateway policy source |
| Application Insights | Token use grouped by finance dimensions | Metrics, gateway logs, and KQL |

---

## Where the module fits

Session 06 owns the API Management AI route.

Session 11 owns the wider observability and budget-notification baseline.

This module adds **finance-grade attribution**: tag inheritance, AI budget filters, token metrics,
token quotas, and the rate table finance accepts.

Fabric capacity, Copilot Credits, FinOps hubs, and PTU reservations stay out.

---

## Implementation tradeoffs

| Choice | Route used here | Limit |
|---|---|---|
| Allocation | Resource-group tags inherited to resources | Existing resources need remediation |
| Budget | Resource group and meter-category filters | Notifications do not stop resources |
| Token metrics | Five trusted low-cardinality dimensions | New values are dropped past metric limits |
| Quota | Per-product monthly quota and rate | Direct model endpoint traffic bypasses it |
| Rate table | Finance-owned JSON | Estimated cost must reconcile to billing |

---

## Token chargeback boundary

![Azure API Management](assets/icons/microsoft/azure-api-management.svg)

APIM emits token metrics with trusted values:

- cost center from product mapping;
- consumer from APIM subscription;
- product;
- API; and
- model route from a static alias.

No request header, user ID, email, prompt text, request ID, or free text becomes a chargeback
dimension.

---

## What preflight checks

Preflight rejects:

- unresolved `__REQUIRED_*__` decisions;
- missing files or invalid JSON or XML;
- a non-subscription target scope or subscription mismatch;
- a tag taxonomy without `CostCenter`;
- user-level or client-supplied token metric dimensions;
- missing APIM product quota or token rate rows.

Then it builds Bicep and runs subscription what-if for policy and budget.

---

<!-- _class: implementation -->

## Run the module

1. Complete the finance, policy, budget, APIM, and query records.
2. Run preflight in PowerShell or Bash.
3. Deploy tag policy and start remediation after owner review.
4. Deploy the filtered AI budget.
5. Merge the APIM token metric and quota policy.
6. Run the chargeback KQL query.

<!--
Make the owner review explicit before remediation and before the APIM policy merge.
-->

---

## Confirm the result

The module passes when:

- policy assignments carry the module marker and approved subscription scope;
- the inherit-tag policy has managed identities and Contributor role assignments;
- the filtered AI budget has approved thresholds and action group;
- APIM emits token metrics with five or fewer trusted dimensions;
- the product quota returns the expected 403 or 429 when exceeded; and
- KQL returns tokens by cost center and consumer, with missing token counts flagged.

---

## Operating state

| Owner | Maintains |
|---|---|
| Policy owner | Tag assignments and remediation |
| Cost owner | Budget filters and notifications |
| Gateway owner | APIM policy and product quotas |
| Observability owner | Metrics, logs, and KQL access |
| Finance owner | Rate table and reconciliation |

Cost Management remains the billed source.

---

## Restore path

1. Restore the previous APIM policy version.
2. Disable or delete only the filtered AI budget.
3. Stop remediation before removing inherit-tag assignments.
4. Remove only policy assignments with the module marker.
5. Keep billing, APIM, and telemetry records under normal retention.

Do not remove the gateway route or the observability baseline to roll back this module.

---

<!-- _class: closing -->

# Thank you!
