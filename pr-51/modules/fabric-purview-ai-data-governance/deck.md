---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: Microsoft Fabric and Microsoft Purview governance for AI data
description: Optional implementation module for governing one Fabric AI grounding lakehouse with tenant-setting drift checks, OneLake security, labels, and Purview DLP simulation.
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Optional module</p>

# Microsoft Fabric and Microsoft Purview governance for AI data

**420 minutes - One governed AI grounding lakehouse**

<!--
Frame this as one control path: settings, access, label, DLP simulation, and two identity checks.
-->

---

## Control objective

Record and check Fabric Copilot and AI tenant settings, configure one gold lakehouse access role
and Purview label/DLP decision, then confirm permitted and restricted AI consumer access.

![Microsoft Fabric](assets/icons/microsoft/microsoft-fabric.svg)

<!--
Keep the scope tight. One lakehouse, one consumer group, one restricted group.
-->

---

## Why it matters

**Problem.** AI teams can point agents and retrieval pipelines at Fabric data before settings,
labels, DLP scope, and lakehouse roles agree.

**Solution.** This module puts the data boundary in one path: drift check, narrowed access, label,
DLP simulation, and live identity checks.

**EU AI Act.** Supports Articles 10 and 26(4) for high-risk systems. Engineering mapping, not legal
advice.

<!--
The module is not a data-platform overhaul. It is the control path for a real grounding source.
-->

---

## Architecture at a glance

| Layer | Source of truth | Module record | Check |
|---|---|---|---|
| Tenant settings | Fabric Admin REST | Tenant baseline | Copilot and AI drift |
| Lakehouse access | OneLake security | Role payload | Live role membership |
| Label and DLP | Microsoft Purview | Policy decision | Portal summary and simulation |
| Delivery result | Fabric consumer path | Access-check plan | Allowed and blocked identities |

<!--
Explain that the repository records decisions. Fabric and Purview still own live state.
-->

---

## Control boundary

**In scope:** one Fabric tenant-settings baseline, one gold lakehouse role, one AI consumer group,
one restricted group, one label decision, one Fabric DLP policy in simulation mode.

![Microsoft Purview](assets/icons/microsoft/microsoft-purview.svg)

Agent 365 rollout DLP, data quality, retention, domains, endorsements, and tenant-wide networking
stay outside this module.

<!--
This boundary prevents the four-day data kit from becoming a full data governance program.
-->

---

## Tenant-setting drift

The baseline tracks the Fabric **Copilot and AI** settings group:

- Azure OpenAI-powered features;
- OpenAI as a Microsoft subprocessor;
- cross-geo processing and storage;
- Copilot capacity designation;
- standalone Copilot and approved-item search; and
- data-agent observability export to Foundry.

**Stop on drift without owner approval.**

---

## OneLake access path

The role `AiGroundingConsumerRead` grants `Read` to one Microsoft Entra AI consumer group.

It also records:

- the approved gold table path;
- row and column restrictions;
- the current ETag; and
- restricted principals removed from `DefaultReader`.

![Microsoft Entra ID](assets/icons/microsoft/microsoft-entra-id.svg)

---

<!-- _class: decision -->

## Design tradeoffs

| Choice | Route used here | Limit |
|---|---|---|
| Tenant settings | REST drift check against baseline | An admin still changes settings through Fabric |
| Access | OneLake `Read` role with RLS/CLS | Workspace roles can bypass it |
| Restricted user | Remove from `DefaultReader`, then test | Needs a real restricted identity |
| DLP | Fabric location in simulation mode | Enforcement needs a later Purview change |

<!--
Call out the workspace-role bypass. It is the common failure mode.
-->

---

## What preflight checks

Preflight rejects:

- unresolved Fabric, Purview, or access-check decisions;
- a target scope other than `one-approved-fabric-ai-grounding-lakehouse`;
- mismatched workspace or lakehouse IDs across artifacts;
- a OneLake role without the approved group; and
- any DLP mode other than simulation.

It does not sign in or call Fabric.

---

<!-- _class: implementation -->

## Run the module

1. Complete the four records.
2. Run local preflight.
3. Check Copilot and AI tenant-setting drift.
4. Apply the OneLake role with `dryRun=true` first.
5. Apply the label and create the DLP policy in simulation mode.
6. Verify the live OneLake role.
7. Run the permitted and restricted identity checks.

---

## Confirm the result

| Check | Expected result |
|---|---|
| Intended path | The permitted consumer reads the approved gold path and sees the expected filtered shape |
| Blocked path | The restricted consumer cannot read the same path |
| Delivery-owner checkpoint | Owner observes drift, role, label, DLP simulation, and both identity checks |

Stop if either identity check uses a different item or query path.

---

## Operating state

| Owner | Maintains |
|---|---|
| Fabric administrator | Copilot and AI tenant-setting baseline |
| Data access owner | OneLake role and `DefaultReader` review |
| Information protection owner | Sensitivity label and label policy |
| Purview operator | Fabric DLP policy in simulation and alert review |
| AI application owner | Grounding path and consumer checks |

<!--
Restore starts by removing the lakehouse from grounding use, not by deleting data.
-->

---

<!-- _class: closing -->

# Thank you!

