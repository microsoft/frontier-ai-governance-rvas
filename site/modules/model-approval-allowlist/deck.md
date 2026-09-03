---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: Model approval decisions and the Foundry deployment allowlist
description: Optional implementation module that records model approval decisions and assigns the two built-in Foundry model-deployment policies.
---

<!-- _class: cover -->

![RVAP](assets/logos/logo-full.png)

# Model approval and the deployment allowlist

## Optional implementation module

Record why a model is approved. Let policy read the same list.

<!-- Notes: This module sits outside the 13 sessions and follows Sessions 01 and 03. -->

---

## Control objective

Record each approved model with its publisher, asset ID, source, and approvers. Assign the two
built-in Foundry model-deployment policies from that same register.

![Azure Policy](assets/icons/microsoft/azure-policy.svg)

<!-- Notes: The register is the decision. The policy is the enforcement of that decision. -->

---

## Why it matters

**Problem.** Session 03 deploys models someone already approved, but nothing records who approved
them or why. The list lives in a spreadsheet the platform can't read.

**Solution.** One register holds the decision. The parameter file reads it, so the assignment cannot
drift from the approval.

<!-- Notes: Ask the room where their approved model list lives today. -->

---

## Architecture overview

A reviewer copies the publisher and asset ID from the model card into the register. The parameter
file reads that register, so two built-in policies answer two questions:

| Policy | Question it answers |
|---|---|
| Approved models | Is this exact model on our list? |
| Eligibility requirements | Does it meet our standards for source and maturity? |

Both evaluate at deployment time. The catalog still shows the model; **Deploy** is disabled with the
policy name.

<!-- Notes: Developers see why they were blocked and who to ask. -->

---

## Sold by Azure or from a partner

**Sold by Azure:** hosted and operated by Azure, billed through your subscription, Azure SLA,
Microsoft support, Microsoft Product Terms.

**Partners and community:** the provider sets license terms and price and supports the model. For
serverless deployments, Microsoft hosts the infrastructure and acts as data processor for prompts
and responses.

<!-- Notes: This is a contractual difference, not a technical one. Legal and privacy own it. -->

---

## The toggle that answers the hosting question

```json
{
  "onlyAllowDirectFromAzure": true,
  "denyPreviewModels": true
}
```

Both default to `false`. An unconfigured assignment restricts nothing.

<!-- Notes: Relaxing the first toggle is a governance decision recorded in the change system. -->

---

<!-- _class: decision -->

## Decisions and tradeoffs

| Choice | Route used here | Limit |
|---|---|---|
| Approval record | JSON register read by the parameter file | Register first, policy second |
| Asset ID | Trailing slash or explicit version | Each version needs an entry |
| Source and maturity | Both eligibility toggles on | Partner models need a scoped exception |
| Rollout | Audit, then Deny | Audit blocks nothing |
| Scope | One resource group | Deployments elsewhere are unaffected |

<!-- Notes: Prefix matching is the trap. gpt-5 also matches gpt-5.2 and gpt-5.4. -->

---

## What the register holds

- publisher, asset ID, and source category;
- hosting route and approved deployment types;
- processing location and data classification ceiling;
- use-case boundary and evaluation reference; and
- three named approvers and a review date.

<!-- Notes: Azure Policy stores the allowed values. Only the register stores the reasoning. -->

---

<!-- _class: implementation -->

## Implement the module

1. Resolve both built-in definition IDs by display name.
2. Complete the register and run preflight with what-if.
3. Deploy both assignments in Audit.
4. Review compliance and agree migrations.
5. Move the register to Deny and redeploy.
6. Run the live assignment check.

<!-- Notes: Wait 15 minutes after assignment. Compliance data can take up to 24 hours. -->

---

## Safety gates

- Stop on an asset ID that could match a successor model.
- Stop when the register approves a model the toggles would deny.
- Stop when an entry has no named approvers or review date.
- Stop when a partner model has no reviewed license position.
- Stop before Deny while a noncompliant deployment has no owner.

<!-- Notes: Preflight enforces the first three. The others are review decisions. -->

---

## Expected result

```text
PASS: Both assignments use effect Deny with 4 approved model
asset ID(s) and 2 approved publisher(s) from the register.
```

A model outside the register still appears in the catalog with **Deploy** disabled and the blocking
policy named.

<!-- Notes: A mismatch means someone edited the assignment outside the deployment path. -->

---

## Operating state and restore

| Owner | Responsibility |
|---|---|
| Policy owner | Both assignments and the deployment path |
| Model reviewers | Register entries and review dates |
| Data and legal reviewers | Partner license and classification positions |
| Session 03 owner | Version pinning, deployment types, and quota |

Restore by redeploying the recorded previous assignment. Removing the assignments leaves existing
deployments running.

<!-- Notes: Adding a model is a register change followed by a redeployment, in that order. -->

---

<!-- _class: closing -->

# Thank you!
