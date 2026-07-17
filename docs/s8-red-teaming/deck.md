# S8 · Adversarial Testing

**Facilitator deck**

Security / SOC · AI developer / maker · 90-minute authorized non-production test review

Note:
Welcome and framing. This is an authorized misuse-test review for a customer-owned non-production target only. It does not approve production release, authorize testing outside scope, or supply test data, credentials, endpoint clients, or replacement scorecards. Roles in the room: facilitator, customer security/SOC lead, endpoint owner or operator, evidence owner, and decision owner.

---

## The safety-test outcome

> **"What did this authorized test show for this exact non-production target?"**

The customer leaves with a native scorecard or approved run evidence, plus owners for findings.

Note:
Keep the scope narrow. The output is an authorized misuse-test result for one non-production agent or endpoint, and a remediation, accepted-risk, blocked, or re-test decision with an owner and date. It is not a broad security certification.

---

## Why this matters

- Red teaming is useful only with agreed scope and safety limits.
- The customer defines target, categories, success criteria, and response path.
- S8 gives evidence for that exact scope.
- It does **not** claim the agent is secure everywhere.

Note:
Set the stakes. Testing without written authorization, SOC awareness, target ownership, and stop conditions is unsafe and out of scope. The goal is to find weaknesses while the customer can observe, contain, and fix them.

---

## Red teaming tests a defined safety objective

- Authorized misuse test.
- Customer-owned **non-production** endpoint only.
- Written rules of engagement before testing starts.
- SOC notified with contact and monitoring window.
- Customer chooses and keeps test data and success criteria.

Note:
This is the boundary slide. If target ownership, non-production status, authorization, or SOC monitoring is uncertain, stop. S8 is limited to the written scope and the customer's approved environment.

---

## Attack Success Rate is a decision aid

![S8 decision aid: a setup chain (target, attack categories, sample size, target version, approved threshold) parameterises the comparison; authorized attempts yield an Attack Success Rate compared to the threshold — above tolerance becomes a remediation item with an owner, below tolerance supports the tested scope; the Foundry native scorecard is preserved with an optional comparison sidecar.](../assets/diagrams/s8-red-teaming-asr-decision.svg)

ASR only makes sense with category, sample size, target version, and threshold.

Note:
Walk the diagram from setup to authorized attempts to ASR comparison. Lower is better, but the number is not meaningful without the agreed success condition. Above tolerance becomes remediation with owner; below tolerance supports only the tested scope.

---

## Four questions for each category

> **"What behavior did we test?"**
> **"What counted as success?"**
> **"Why would that response be unacceptable?"**
> **"What would prove the fix worked?"**

Keep the scorecard tied to the rules of engagement.

Note:
Use these questions during interpretation. They prevent the room from treating ASR as an abstract score. Every category needs a behavior, success condition, unacceptable outcome, and validation path.

---

## Findings become remediation backlog

- Recommend remediation, accepted risk, blocked status, or re-test.
- State confidence and assumptions.
- Name authorization, SOC window, threshold, owner, and validation reference.
- Include S6 / S7 / S11 handoff where needed.
- Do not approve testing outside written scope.

Note:
The backlog may include AI Red Teaming Agent or PyRIT adapter path, rules of engagement, category thresholds, above-threshold remediation owner, validation reference, re-test criteria, operating alert update, and production-release blocker.

---

## Native scorecard and threshold review differ

- Foundry AI Red Teaming Agent produces the native scorecard.
- Preserve native output unchanged.
- Optional comparison sidecar references the native scorecard.
- The sidecar is not an alternate scorecard.
- It does not transform Foundry evidence.

Note:
This distinction matters during evidence capture. If the customer reviews native ASR values against approved thresholds, the kit may write a comparison sidecar. Keep that sidecar clearly secondary to the native scorecard.

---

## Managed testing does not remove governance

- AI Red Teaming Agent is a Preview capability.
- Customer still owns authorization, scope, safe data, alerts, evidence, and remediation.
- No fallback mock or alternate test path when unavailable.
- PyRIT paths require the same written scope and governance.

Note:
Do not let managed capability language soften the customer's responsibilities. If the managed capability is unavailable, S8 does not invent a replacement. If the customer uses PyRIT, the same authorization and evidence rules apply.

---

## The activity — how we'll work

- **Timebox:** 90 minutes inside the approved monitoring window.
- **Entry:** written authorization, rules of engagement, SOC notified.
- **Target:** customer-owned, non-production, stoppable by endpoint owner.
- Missing or expired condition? **Stop** and record the blocker.

Note:
Confirm the entry condition before any scan or review. The room also needs approved categories, thresholds if used, evidence location, and decision owner. Review the technical-decision menus for red-team approach, authorized scope, and remediation routing.

---

## Step 1 — Set the room and orient · 20 min

> **"Is this exact target customer-owned and non-production?"**
> **"Who can stop the run?"**
> **"Which red-team approach, scope, and remediation route are being decided?"**

Confirm authorization, SOC window, target label, stop conditions, and evidence boundary.

Note:
Use `labs/s8-red-teaming/runbook.md` to run pre-flight. Also ask which scorecard, decision record, and remediation backlog the customer will keep. Stop if any answer is missing or uncertain.

---

## Step 2 — Customer runs the authorized test · 30 min

- Endpoint owner runs the approved adapter only in the authorized window.
- Customer operates credentials, target access, categories, and test data.
- Preserve Foundry `airt-native-scorecard.json` unchanged.
- No mock target, attack dataset, or replacement scorecard.

Note:
The facilitator does not operate the target or supply test data. If the scan cannot complete during the workshop, the customer retrieves the completed run's native scorecard for review later. Pause if alerts, instability, or scope drift appears.

---

## Step 3 — Interpret the findings together · 15 min

> **"Was the run authorized and contained?"**
> **"What does each ASR mean for this category and sample?"**
> **"Did an alert, instability, or scope change require a stop?"**

Compare scorecard, written scope, target version, categories, and threshold review.

Note:
The SOC lead and endpoint owner interpret the native scorecard against the approved scope. Above-threshold categories need remediation, owner, validation reference, and re-test date. Incomplete runs, alerts, instability, or scope drift may need blocked, stopped, or re-run status.

---

## Step 4 — Make the customer decision · 15 min

- Assign owner and due date for each above-threshold category.
- Record accepted risk, **blocked**, or re-test where authorized.
- Below threshold supports only the tested scope.
- Unauthorized, production, incomplete, or out-of-scope results cannot support a decision.

Note:
Keep authority with the customer decision owner. A sidecar alone cannot support a decision. Missing thresholds or category owners pause interpretation until the customer approves decision criteria.

---

## Step 5 — Hand over · 10 min

- Reference authorization and rules of engagement.
- Reference SOC window and debrief.
- Reference native scorecard, run metadata, and optional sidecar.
- Record decision register and technical-decision output.
- Send remediation and gaps to customer backlog.

Note:
Endpoint cleanup and incident actions stay with customer owners. The handoff captures safe references only. Do not put scorecards, prompts, attack data, endpoint details, credentials, or customer evidence in Git.

---

## Verification & evidence

- [ ] Native scorecard and run metadata are referenced in approved customer records.
- [ ] Any threshold sidecar is retained with the native scorecard.
- [ ] Above-threshold categories have owners and due dates.
- [ ] SOC debrief records authorized alerts, incidents, and cleanup.
- [ ] Decision register records remediation, accepted risk, blocked status, or re-test date.

Note:
Save only safe references in `04-operate/evidence-register.json` and the decision in `04-operate/decision-register.json`, in the generated delivery workspace. Never store scorecards, prompts, attack data, endpoint details, credentials, or customer evidence in this repository.

---

## Change boundary & hand-off

- S8 does not deploy a production control.
- Customer alone pauses, resets, or changes the non-production endpoint.
- Cleanup, incident, and change processes stay customer owned.
- Scorecard and decision feed S6 residual gaps and S11 operating review.

Note:
When stuck: missing authorization, SOC notification, non-production target, Preview capability, or approved thresholds stops the run. Record the blocker with owner and date. RACI: Security/SOC is responsible, Governance lead accountable, AI developer/maker and endpoint owner consulted.
