# S8 · Adversarial Testing

!!! info "Freshness"
    Last reviewed: 2026-07-27 · Validate AI Red Teaming Agent availability in the [Governance capability guide](../reference/governance-capability-guide.md) and current Microsoft Learn pages before delivery.

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Legal / risk</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer has an authorized adversarial-test decision for one customer-owned **non-production** agent or endpoint. The decision names the tested scope, rules of engagement, threshold interpretation, each finding owner, remediation or accepted-risk path, stop condition, and re-test criterion.

They leave with:

- A customer-retained native Microsoft Foundry AI Red Teaming Agent scorecard where the target is supported, or an approved PyRIT/manual-test record for an authorized alternate path.
- A customer-approved threshold-comparison sidecar only when the customer performs a threshold review against its own criteria.
- A remediation, accepted-risk, blocked, rejected, or re-test decision with severity owner, target date, and evidence location reference.
- A handoff to S6 for runtime-control gaps, S7 for evaluation/retest evidence, S9/S13 for lifecycle and portfolio blockers, and SOC/legal for monitoring or exception decisions.

`labs/s8-red-teaming/` holds the facilitator runbook and decision-record template. Native scorecards, prompts, outputs, datasets, endpoint details, and customer evidence stay in the approved customer records system. This kit does not hold endpoint clients, credentials, attack datasets, or customer evidence.

### What happens next

**Next customer action:** route each finding to the remediation, accepted-risk, blocked, rejected, or re-test process named in the decision record. No finding is considered closed until the customer-owned owner accepts the fix evidence and retest criterion.

### Plain decision and default path

**Decision question:** *Can the customer authorize, run or review, interpret, remediate, and retest a bounded adversarial-test finding safely?* Approval accepts a remediation or bounded risk decision for the tested non-production scope; it is not production approval and does not change a customer system.

The default is an authorized, customer-operated non-production Microsoft Foundry AI Red Teaming Agent path where the target, region, category, and service status are supported. Use PyRIT, manual expert testing, or a third-party engagement only when support, target type, category coverage, authorization, or customer policy makes the default unsuitable. Record the exception owner, reason, compensating authorization or review, target date, severity owner, and retest criteria.

S8 produces a remediation backlog, not offensive capability. Each recommendation names whether to remediate, accept risk, defer, reject, route, block, or retest. It also names the AI Red Teaming Agent/PyRIT/manual path owner, SOC/legal contact, category threshold owner, severity owner, remediation owner, runtime-assurance handoff, evaluation/retest owner, and release or lifecycle blocker.

!!! warning "Safety / authorization required"
    Run adversarial activity only after approved written authorization, rules of engagement, SOC notification, legal/risk contact where required, stop conditions, and confirmation that the target is a customer-owned **NON-PRODUCTION** test agent/endpoint. Keep activity defensive, authorized, and remediation-oriented.

## 2. Prerequisites

- Written authorization and rules of engagement that name target, timing, permitted operators, categories, data limits, allowed tools, prohibited activity, stop conditions, evidence handling, SOC contact, and legal/risk contact.
- A customer-owned non-production endpoint, endpoint owner, reset or rollback path, monitoring window, and confirmation that testing cannot affect production users or systems.
- Foundry project access and AI Red Teaming Agent availability for supported targets, or an approved PyRIT/manual route. The kit contains no endpoint client, credentials, or attack dataset.
- Customer-approved categories, thresholds, severity model, evidence location, remediation owner model, accepted-risk route, blocked path, and re-test criteria.

### Materials to prepare

- Authorization record and rules of engagement: target, timing, operators, categories, allowed methods, data boundaries, stop conditions, SOC/legal contacts, and evidence handling.
- Target context: non-production endpoint label, version, owner, rollback/reset path, dependencies, monitoring window, and known alert or instability risks.
- Decision aids: approved Attack Success Rate thresholds or qualitative thresholds, category notes, severity owner model, remediation route, accepted-risk authority, blocked path, and re-test criteria.
- Reference sources to validate before delivery: AI Red Teaming Agent concept and run guidance, PyRIT documentation, Azure AI Content Safety/Prompt Shields references, Defender/Sentinel handoff expectations, and customer security/evaluation standards.

## 3. Why this session matters

Red teaming is useful only when the customer agrees on target, authorization, success criteria, safety limits, response path, and retest evidence before the first probe. S8 evidence is accepted only for the exact authorized scope and target version.

A scorecard without a remediation owner is an observation, not governance. A prepared or synthetic test is a diagnostic aid, not proof of production control operation. A below-threshold result supports only the tested scope; it does not approve production release or replace S6/S7/S9 decisions.

Read the [S8 Concepts](concepts.md) for authorization, Attack Success Rate as a decision aid, native-scorecard boundaries, and remediation backlog.

## 4. Change boundary

S8 does not deploy controls, test production, grant production approval, or change customer systems. The customer alone pauses, resets, changes, or cleans up its non-production endpoint and follows its own legal, SOC, incident, and change processes. Handoff to S6 names runtime-control findings, to S7 names evaluation or retest evidence, to S9 names lifecycle/catalog effects, and to S13 names portfolio blockers.
