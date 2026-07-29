# S8 · Authorized Red Teaming & Retest

!!! info "Freshness"
    Last reviewed: 2026-07-27 · Validate AI Red Teaming Agent availability in the [Governance capability guide](../reference/governance-capability-guide.md) and current Microsoft Learn pages before delivery.

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Legal / risk</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer has an **authorized red-team remediation package** for one customer-owned **non-production** agent, application, or endpoint. The package names the target, rules of engagement, category and method route, safe evidence references, ASR or qualitative interpretation, severity owner, finding owner, remediation route, stop condition, and retest criterion.

They leave with:

- An **authorized target card**: target, version, environment, owner, reset or rollback path, monitoring window, dependencies, production-impact exclusion, and approved records location.
- A **rules-of-engagement package**: authorization reference, operators, methods/tools, categories, excluded categories, timing, data limits, prohibited activity, stop conditions, SOC/legal contacts, evidence handling, and retention owner.
- A **category and method package**: AI Red Teaming Agent where supported, PyRIT or manual expert path where approved, unsupported-target route, production-test request route, or blocked route.
- A **threshold and severity interpretation**: ASR or qualitative result, sample/context note, target version, threshold owner, severity rationale, accepted-risk authority, and limitation.
- A **finding-to-remediation map**: each finding has a receiving control owner, release/backlog impact, stop condition if risk remains active, and retest criterion.
- A **retest closure record**: retest method, changed target version, comparison rule, closure evidence reference, acceptance owner, remaining risk, and reopen trigger.

Native scorecards, prompts, outputs, datasets, endpoint details, attack payloads, incident payloads, and customer evidence stay in the approved customer records system. This kit does not hold endpoint clients, credentials, attack datasets, raw scorecards, or customer evidence.

### What happens next

**Next customer action:** route each finding to the remediation, accepted-risk, blocked, rejected, or retest process named in the decision record. No finding is closed until the receiving owner accepts the fix evidence and retest criterion in the customer system.

### Plain decision and default path

**Decision question:** *Can this specific non-production target be tested or reviewed under written rules of engagement, with known attack categories, safe evidence handling, owned thresholds, a defensible finding record, a remediation owner, a stop condition, and a retest criterion?*

The default is an authorized, customer-operated, non-production Microsoft Foundry AI Red Teaming Agent path where the target, region, category, and service status are supported. Use PyRIT, manual expert testing, or a third-party engagement only when support, target type, category coverage, authorization, or customer policy makes the default unsuitable. Record the exception owner, reason, support caveat, target date, severity owner, remediation owner, and retest criterion.

S8 produces a remediation package, not offensive capability. Each recommendation names whether to remediate, accept risk, defer, reject, route, block, or retest. It also names the red-team lead, target owner, SOC/legal contact, threshold owner, severity owner, remediation owner, retest owner, evidence owner, and release or lifecycle blocker where relevant.

!!! warning "Safety / authorization required"
    Run adversarial activity only after approved written authorization, rules of engagement, SOC notification, legal/risk contact where required, stop conditions, and confirmation that the target is a customer-owned **NON-PRODUCTION** test agent, application, or endpoint. Keep activity defensive, authorized, and remediation-oriented.

## 2. Prerequisites

- Written authorization and rules of engagement that name target, version, timing, permitted operators, categories, data limits, allowed tools, prohibited activity, stop conditions, evidence handling, SOC contact, and legal/risk contact where required.
- A customer-owned non-production target, target owner, reset or rollback path, monitoring window, and confirmation that testing cannot affect production users or systems.
- Foundry project access and AI Red Teaming Agent availability for supported targets, or an approved PyRIT/manual/third-party route. The kit contains no endpoint client, credentials, payload library, or attack dataset.
- Customer-approved category thresholds or qualitative tolerances, severity model, accepted-risk authority, evidence location, remediation owner model, blocked path, and retest criteria.

### Materials to prepare

- Authorization record and rules of engagement: target, timing, operators, categories, allowed methods, data boundaries, stop conditions, SOC/legal contacts, and evidence handling.
- Target context: non-production endpoint label, target version, owner, rollback/reset path, dependencies, monitoring window, and known alert or instability risks.
- Decision aids: approved ASR thresholds or qualitative tolerances, category notes, sample-size assumptions, severity owner model, remediation route, accepted-risk authority, blocked path, and retest criteria.
- Reference sources to validate before delivery: AI Red Teaming Agent concept and run guidance, PyRIT documentation, Azure AI Content Safety/Prompt Shields references, Defender/Sentinel handoff expectations, and customer security/evaluation standards.

## 3. Why this session matters

Red teaming is useful only when the customer agrees on target, authorization, category, success criteria, safety limits, response path, and retest evidence before the first probe. Adversarial-test evidence is accepted only for the exact authorized scope, category, target version, sample, method, and threshold.

A scorecard without a remediation owner is an observation, not governance. A prepared or synthetic test is a diagnostic aid, not proof of production control operation. A below-threshold result supports only the tested scope; it does not approve production release or replace runtime, evaluation, control-plane, release, or legal decisions.

Read the [S8 Concepts](concepts.md) for authorization, ASR interpretation, native-scorecard boundaries, finding-to-remediation ownership, and retest closure.

## 4. Change boundary

S8 does not deploy controls, test production, grant production approval, create attack payloads, run endpoint clients, or change customer systems. The customer alone pauses, resets, changes, or cleans up its non-production target and follows its own legal, SOC, incident, risk, and change processes. Runtime handoff names control findings, evaluation handoff names retest evidence, catalog handoff names lifecycle effects, and portfolio handoff names unresolved blockers.
