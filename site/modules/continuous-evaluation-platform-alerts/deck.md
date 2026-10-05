---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
title: Continuous evaluation and Foundry platform alerts
description: Optional implementation module for diagnostic settings, Azure Monitor metric alerts, and Microsoft Foundry continuous evaluation.
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation · Optional module</p>

# Continuous evaluation and Foundry platform alerts

**210 minutes - sampled quality checks and platform alerting**

<!--
Set the frame: one governed Foundry project, one account, one agent, one operating route.
-->

---

## Control objective

Configure diagnostic settings, platform metric alerts, and one continuous evaluation rule for a governed
Foundry project.

The check confirms that alerts are enabled and evaluation runs appear after sampled traffic arrives.

![Microsoft Foundry](assets/icons/microsoft/azure-ai-foundry.svg)

---

## Why it matters

**Problem.** Release gates catch known regressions before deployment. They do not watch live
traffic, throttling, latency, or token volume after the model and agent are in use.

**Solution.** Route platform signals to Log Analytics, alert on the few metrics operators can act
on, and sample agent responses through continuous evaluation.

**EU AI Act.** Supports Articles 12, 26(5), and 72 for high-risk systems. Engineering mapping, not
legal advice.

<!--
This module adds production-style operating signals. It does not replace the release gate.
-->

---

## Architecture at a glance

| Component | Job |
|---|---|
| Foundry account | Emits platform logs and metrics |
| Log Analytics and Application Insights | Store platform signals, traces, and evaluation data |
| Azure Monitor | Runs throttling, latency, and token-volume alerts |
| Continuous evaluation rule | Scores sampled agent response completions |
| Action group | Routes alert notifications to the operating owner |

---

## What changes

The Bicep deployment:

- enables `allLogs` and `AllMetrics` diagnostic settings on the Foundry account;
- creates the action group used by this module;
- deploys three enabled metric alerts for 429 throttling, time to last byte, and token volume.

The Python script creates or updates the continuous evaluation rule from the recorded evaluator
decision.

---

## Tradeoffs

| Decision | Route used here | Limit |
|---|---|---|
| Diagnostic logs | `allLogs` plus `AllMetrics` to Log Analytics | Access and retention must match the content risk |
| Alert metrics | `AzureOpenAIRequests`, `AzureOpenAITTLTInMS`, and `TokenTransaction` | Thresholds need baseline telemetry |
| Latency metric | Time to last byte, not legacy `Latency` | Rising token volume can explain slower responses |
| Continuous evaluation | Foundry SDK rule with `maxHourlyRuns` cap | Recurring evaluation surfaces are preview |

---

## What preflight checks

Preflight rejects:

- unresolved `__REQUIRED_*__` decisions;
- a target scope that does not match the artifacts;
- unsafe email, threshold, evaluator, or sampling values;
- invalid JSON, Bicep, or Python syntax; and
- a resource-group what-if that cannot be reviewed.

It reaches Azure only after every required decision is resolved.

---

<!-- _class: implementation -->

## Run the module

1. Complete the monitoring parameters and evaluation decision record.
2. Run preflight and review the what-if preview.
3. Deploy the Bicep file through the approved deployment path.
4. Grant the project managed identity the Foundry User role.
5. Run the continuous evaluation script.
6. Generate approved traffic and list recent evaluation runs.

---

## Confirm the result

The module is complete when:

- the Foundry diagnostic setting sends logs and metrics to the approved workspace;
- all three metric alert rules are enabled and use the module action group;
- the continuous evaluation rule is enabled for the governed agent; and
- recent evaluation runs show a status and report URL after sampled traffic arrives.

Stop on missing telemetry, disabled alerts, or evaluation runs that never start.

---

## Operating state

| Owner | Maintains |
|---|---|
| Observability owner | Diagnostic setting, alert rules, thresholds, and action group |
| AI quality owner | Evaluators, thresholds, sampling cap, and rule health |
| Platform owner | Foundry account, project, managed identity, and RBAC |
| Service owner | Incident route and restore decision |

Keep release gates in place. This module watches what happens after release.

---

<!-- _class: closing -->

# Thank you!
