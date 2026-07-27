# S8 Red Teaming Runbook

Use this runbook to guide the required lab path. The customer authorizes and operates or reviews its own adversarial-testing records, records safe references in its approved system, and decides whether findings are ready for remediation, acceptance, routing, blocking, or retest.

> **Safety boundary:** Use safe references only. Do not place customer identifiers, secrets, prompt text, model outputs, telemetry exports, live configuration, endpoint clients, credentials, attack datasets, native scorecards, incident payloads, or production approval claims in this repository. Do not run production tests or change tenant configuration during the lab.

## Entry gate

Confirm the customer has a bounded customer-owned non-production target, target owner, decision owner, red-team operator, SOC contact, legal/risk contact where required, evidence owner, category-threshold owner, severity owner, remediation owner model, retest owner, approved records location, written authorization, rules of engagement, and stop condition. If any are missing, stop the decision and create a blocker backlog item with the missing owner, record, or approval path.

## Required review flow

1. **Set the adversarial-testing question.** Record the decision: for example, whether to run a supported AI Red Teaming Agent test, route an unsupported target, remediate an above-threshold finding, accept tested-scope risk, or retest a fix.
2. **Confirm authorization and rules of engagement.** Record safe references for target, version, environment, timing, operators, categories, allowed methods, data limits, prohibited activity, monitoring window, SOC/legal contacts, evidence handling, and stop condition.
3. **Confirm target safety.** Verify the scope is customer-owned and non-production, has an owner, reset/rollback path, dependency awareness, and no production-user impact. If production testing is requested, route to customer legal, SOC, business, risk, and change process; do not continue as S8 testing.
4. **Select method.** Record one outcome:
   - `ai-red-teaming-agent`: supported target/category and customer-operated native scorecard path;
   - `pyrit`: approved customer-operated PyRIT route for custom/repeatable testing;
   - `manual`: approved manual expert route for bounded category review;
   - `third-party`: customer-approved engagement route with equivalent ROE and evidence handling;
   - `unsupported`: target/category/service status cannot be tested with the proposed method;
   - `blocked`: authorization, owner, evidence location, or safety boundary prevents review.
5. **Preserve evidence boundary.** Keep native scorecards, run records, prompts, outputs, datasets, endpoint details, and incident payloads in the customer's approved records system. Record only safe references and decision metadata.
6. **Interpret threshold.** Record category, ASR or qualitative result, sample/context note, threshold owner, approved threshold or tolerance, severity owner, limitation, and whether the result is above, at, below, disputed, or not comparable to threshold.
7. **Route each finding.** Map each finding to a remediation or decision owner: Prompt Shields/Content Safety, gateway, app/prompt design, tool permission, data path, in-process policy, SOC detection, evaluation, lifecycle/catalog, accepted-risk authority, blocked path, or release owner.
8. **Set stop condition and retest.** Record when testing must pause or stop, what mitigation or containment is required, what retest method will verify closure, who accepts retest evidence, and target date.
9. **Set decision state.** Use one state:
   - `approve`: authorized method, threshold interpretation, owner, evidence reference, acceptance test, and handoff are complete;
   - `defer`: a gap has a named owner and target date;
   - `reject`: the target, method, or category cannot meet the objective safely;
   - `route`: another owner or governance process must decide first;
   - `blocked`: authorization, non-production scope, SOC/legal contact, stop condition, evidence handling, threshold, severity owner, or retest path prevents a decision;
   - `accepted-risk`: the customer-owned authority accepts residual risk for the tested scope;
   - `retest-required`: remediation cannot close until retest evidence is accepted.
10. **Create blocker and backlog path.** For each gap, record blocker category, receiving owner, acceptance test, target date, evidence location, release or backlog impact, and next review trigger.
11. **Handoff.** Send the completed decision record and backlog references to red-team lead, security owner, SOC, legal/risk owner, remediation owner, evaluation owner, product owner, release manager, and lifecycle/catalog owner.

## Blocker categories

Use the smallest accurate category: `authorization-missing`, `roe-incomplete`, `non-production-scope-unconfirmed`, `soc-contact-missing`, `legal-risk-contact-missing`, `stop-condition-missing`, `evidence-location-missing`, `method-unsupported`, `target-unsupported`, `category-threshold-missing`, `severity-owner-missing`, `remediation-owner-missing`, `accepted-risk-authority-missing`, `retest-criterion-missing`, `production-test-request`, `safe-evidence-boundary-missing`, or `scope-unclear`.

## Completion check

The lab is complete when the customer-owned decision record includes authorization, method, target safety, evidence boundary, threshold interpretation, severity owner, remediation route, stop condition, retest criterion, decision state, blockers or backlog, and receiving handoff. Store final evidence only in the customer-approved records system.
