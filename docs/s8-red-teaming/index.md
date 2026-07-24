# S8 · Adversarial Testing

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Validate AI Red Teaming Agent availability in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">AI developer / maker</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer has an authorized misuse-test result for one non-production agent or endpoint, plus an owner for each finding.

They leave with:

- The native Microsoft Foundry AI Red Teaming Agent scorecard, or the approved PyRIT run evidence for the authorized path.
- A customer-approved threshold-comparison sidecar when the customer performs a threshold review.
- A remediation, accepted-risk, blocked, or re-test decision with an owner and date.

`labs/s8-red-teaming/` holds the customer-operated Foundry adapter contract and runbook. Native scorecards and comparison sidecars stay as customer evidence in the approved records system. This kit does not hold endpoint clients, credentials, attack datasets, or customer evidence.

### What happens next

**Next customer action:** route the selected remediation, accepted-risk, or
re-test work through the customer security and non-production change process.

S8 produces a remediation backlog. The recommendation says whether to remediate,
accept risk, block, or re-test. It names the owner for the AI Red Teaming Agent
or PyRIT adapter path, SOC authorization, category threshold, remediation,
runtime assurance, evaluation, operating review, or non-production change
process.

!!! warning "Safety / authorization required"
    Do not run adversarial activity unless the SOC has been notified, written authorization and rules of engagement are approved, and the target is a customer-owned **NON-PRODUCTION** test agent/endpoint only.

## 2. Prerequisites

- Written authorization, rules of engagement, and a named SOC contact and monitoring window.
- A customer-owned non-production endpoint and an available endpoint owner.
- Foundry project access, the AI Red Teaming Agent <span class="rvas-badge rvas-preview">Preview</span>, and a customer-owned async target adapter. The kit contains no endpoint client or credentials.
- Customer-approved test categories, thresholds, evidence location, and decision owner. This kit deliberately does not ship a test dataset or threshold policy.

### Materials to prepare

- Authorization record and rules of engagement: target, timing, categories, permitted operators, stop conditions, monitoring contact, and evidence handling.
- Target context: non-production endpoint label, version, owner, rollback or reset path, and dependencies that could create alerts or instability.
- Decision aids: approved ASR thresholds, category notes, remediation owner model, accepted-risk route, blocked path, and re-test criteria.
- Reference sources to validate before delivery: the AI Red Teaming Agent concept page, Foundry red-teaming run guidance, PyRIT documentation, and customer safety/evaluation standards.

## 3. Why this session matters

Red teaming is useful only when the customer agrees on the target, success criteria, safety limits, and response path before the first probe. S8 gives the customer evidence for that exact scope. It does not claim the agent is secure everywhere.

Read the [S8 Concepts](concepts.md) for authorization, Attack Success Rate as a decision aid, and the native-scorecard boundary.

## 4. Detailed facilitation reference

!!! danger "Authorized test endpoint only"
    Stop if alerts, instability, or scope questions arise. Do not test third-party systems, production agents, user-facing workloads, or endpoints outside the written scope.

Read [Technical decisions](technical.md) first. It covers red-team approach,
scope and authorization, and remediation-routing options and selection criteria.

**Timebox:** 90 minutes inside the approved monitoring window. **Entry condition:** written authorization and rules of engagement are approved; the SOC is notified with a contact and window; the target is confirmed customer-owned and non-production; an endpoint owner can stop it; and customer test categories, thresholds if used, evidence location, and decision owner are approved. Do not start or resume a scan if any condition expires or changes.

| Role | Workshop responsibility |
|---|---|
| Facilitator | Enforces the authorization and non-production boundary, timebox, and handoff. Never operates the target or supplies test data. |
| Customer security/SOC lead | Confirms authorization, monitors the window, calls a stop, and leads the debrief. |
| Customer endpoint owner / operator | Runs the customer adapter against the authorized target and pauses or resets it when required. |
| Evidence owner and decision owner | Retain native evidence references, interpret the agreed scope, and choose remediation, accepted risk, blocked status, or re-test. |

1. **Set the room and orient** *(20 min)*: use `labs/s8-red-teaming/runbook.md` to confirm authorization, rules of engagement, SOC window, target label, stop conditions, evidence boundary, and the technical-decision record. The facilitator asks: **"Is this exact target customer-owned and non-production?"**, **"Who can stop the run?"**, **"Which scorecard, decision record, and remediation backlog will the customer keep?"**, and **"Which red-team approach, authorized scope, and remediation-routing option are being decided today?"** Stop at pre-flight if any answer is missing or uncertain.
2. **Customer runs the authorized test** *(30 min)*: the endpoint owner runs the approved adapter only in the authorized window. If the scan cannot complete during the workshop, the customer retrieves the completed run's native scorecard for review later. The customer operates credentials, target access, categories, and test data in its approved environment. Foundry's `airt-native-scorecard.json` is preserved unchanged. This kit does not create a mock target, attack dataset, or replacement scorecard.
3. **Interpret the findings together** *(15 min)*: the SOC lead and endpoint owner compare the native scorecard with the written scope, target version, categories, sample context, and any approved threshold review. Ask: **"Was the run authorized and contained?"**, **"What does each ASR mean for this category and sample?"**, and **"Did an alert, instability, or scope change require a stop?"** An optional `airt-threshold-comparison.json` is a sidecar that references the native scorecard. It is not native evidence and does not prove the system is secure.

   Interpret each category as a practical finding:

   | Result pattern | Decision prompt |
   |---|---|
   | Above threshold in an approved category | What remediation, owner, validation reference, and re-test date are required? |
   | Below threshold in all approved categories | What tested scope does this support, and what remains untested? |
   | Incomplete run, alert, instability, or scope drift | Should the result be blocked, stopped, or re-run under new authorization? |
   | Missing threshold or category owner | Who must approve the decision criteria before interpretation resumes? |
4. **Make the customer decision** *(15 min)*: the decision owner assigns a remediation owner and due date for each above-threshold category. They can also record accepted risk, **blocked**, or a re-test date through customer authority. A below-threshold result supports only the tested scope. A sidecar alone, incomplete run, unauthorized target, production target, or out-of-scope target cannot support a decision.
5. **Hand over** *(10 min)*: the evidence owner records safe references to the authorization, rules of engagement, SOC window and debrief, native scorecard and run metadata, optional comparison sidecar, decision register, and `templates/technical-decision-record.template.md` output. Remediation and remaining gaps go to the customer's backlog. Endpoint cleanup and incident actions stay with their customer owners.

**Blockers:** missing or expired authorization, no SOC monitoring, production or third-party target, unavailable endpoint owner, unavailable managed capability, unapproved categories or thresholds, alerts, instability, or scope drift. Stop the dependent action, retain safe references and the stop rationale, assign an owner and target date, and never replace the native path with a mock or unapproved test.

## 5. Verification & evidence capture

- [ ] The native scorecard and run metadata are referenced in the approved customer records system.
- [ ] If a threshold review occurred, the comparison sidecar is retained with the native scorecard and above-threshold categories have owners and due dates.
- [ ] SOC debrief records authorized alerts/incidents and any endpoint cleanup.
- [ ] The decision register records remediation, accepted risk, blocked status, or a re-test date.

Save only safe references in `04-operate/evidence-register.json` and the decision in `04-operate/decision-register.json`, in the generated delivery workspace. Do not put scorecards, prompts, attack data, endpoint details, credentials, or customer evidence in Git.

## 6. Change boundary

S8 does not deploy a production control. The customer alone pauses, resets, or changes its non-production endpoint and follows its own cleanup, incident, and change processes.
