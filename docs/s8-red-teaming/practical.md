# Practical workshop: scenario-driven AI red-team route

**Microsoft default:** Microsoft Foundry AI Red Teaming Agent where supported, PyRIT or manual expert testing for authorized alternate paths, Azure AI Content Safety/Prompt Shields, Defender, Sentinel, and SOC remediation routes.

**Customer decision:** Approve, defer, reject, route, or block the AI red-team plan, finding interpretation, remediation, and retest path. Approval accepts a scoped remediation or risk decision; it is not production approval and does not change a customer system.

## Work the decision

1. **Choose the test slice.** Select one non-production target, target version, category set, and decision owner. Name the endpoint owner, red-team operator, SOC contact, legal/risk contact where required, evidence owner, severity owner, remediation owner, and retest owner.
2. **Confirm authorization before method.** Inspect the rules of engagement for target, timing, operators, categories, allowed methods, data limits, prohibited activity, stop conditions, monitoring window, contacts, evidence handling, and approved records location. If incomplete, block or route before testing.
3. **Select the route.** Use AI Red Teaming Agent when supported for the target/category. Use PyRIT or manual expert testing only when the same authorization, safety, evidence, and retest records are complete. Record unsupported target or category reasons.
4. **Interpret findings against customer criteria.** Record the native scorecard or run-record reference, ASR or qualitative result, category threshold, sample-size/context note, severity owner, and limitation. Keep prompts, outputs, scorecards, and datasets in customer-approved systems.
5. **Route remediation.** For each finding, choose a control owner: Prompt Shields/Content Safety, gateway, prompt/design, tool permission, data path, in-process policy, SOC detection, evaluation, lifecycle/catalog, accepted-risk authority, or release blocker.
6. **Set retest and stop conditions.** Record what would prove the fix worked, who accepts retest evidence, when testing must stop, and what happens if the finding remains above threshold.
7. **Record the outcome and handoff.** Approve only when authorization, SOC/legal contact, stop condition, category threshold, severity owner, remediation owner, retest criterion, evidence location, and receiving handoff are complete. Otherwise defer, reject, route, or block with owner and target date.

## Scenario routes

| Scenario | Route | Practical decision cue |
|---|---|---|
| Supported target and category | AI Red Teaming Agent path | Use the customer-operated native path and retain the scorecard unchanged in customer records. The decision record may reference the scorecard and threshold comparison sidecar. |
| Custom target, unsupported category, or service unavailable | PyRIT/manual path | Route to approved PyRIT/manual expert testing with the same ROE, SOC contact, evidence handling, thresholds, severity owner, and retest criteria. Do not use a mock substitute. |
| Unsupported target cannot be safely tested | Unsupported-target route | Reject, defer, or route to architecture/security owner with reason, support caveat, residual risk, target date, and alternate assurance path. |
| Production-test request | Production-test request route | Defer to customer legal, SOC, business, risk, and change process. S8 does not test production or approve production use. |
| Above-threshold finding | Remediation route | Create a backlog item with category, severity, control owner, acceptance test, stop condition if needed, release impact, evidence reference, target date, and retest criterion. |
| Below-threshold finding | Tested-scope support route | Record tested scope, target version, threshold, sample limitations, owner acceptance, and next review trigger. Do not generalize to other versions or production. |
| Retest needed after fix | Remediation/retest route | Use the same method or approved alternate to verify the fix; closure requires owner acceptance and customer-retained evidence. |

## Decision record

Fill this row in the customer-approved records system. Store safe references only.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Adversarial-test decision | AI Red Teaming Agent where supported; PyRIT/manual approved alternate; Azure AI Content Safety/Prompt Shields; Defender/Sentinel; SOC remediation routes | AI red-team / security owner | Customer-approved record reference only | ROE, SOC/legal contact, stop condition, category threshold, severity owner, remediation owner, retest criterion, exception status, backlog, and handoff are complete | Customer date | Remediation / evaluation / SOC owner |

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Rules of engagement | target, environment, version, timing, operators, categories, allowed methods, data limits, prohibited activity, stop conditions, and evidence handling are approved | Security/legal owner |
| SOC/legal contact | SOC contact, monitoring window, escalation path, legal/risk contact if required, and stop condition are named | SOC / legal owner |
| Test method | AI Red Teaming Agent support status or PyRIT/manual alternate is recorded with owner, limitations, cost/coverage note, and safe evidence location | Red-team owner |
| Category threshold | ASR or qualitative threshold, sample/context note, threshold owner, and accepted-risk authority are named | Threshold owner |
| Severity owner | each finding has severity owner, impact rationale, release/backlog impact, and escalation route | Security owner |
| Remediation owner | each finding maps to Prompt Shields/Content Safety, gateway, app/tool, data, SOC, evaluation, lifecycle, accepted-risk, or blocked owner | Remediation owner |
| Retest criterion | closure condition, retest method, evidence owner, target date, and acceptance owner are recorded | Evaluation / release owner |
| Workshop safety | the activity is authorized, non-production, defensive, remediation-oriented, stores no customer evidence in the repo, and makes no production-control claim from synthetic/prepared tests | Facilitator |

## Decision tree

- **Approve** when authorization, method, threshold interpretation, remediation route, retest criterion, evidence location, and handoff are complete for the tested scope.
- **Defer** when records, owners, thresholds, support status, SOC/legal contacts, evidence handling, or retest criteria are missing.
- **Reject** when the target, method, or category cannot be tested safely or cannot meet the customer objective.
- **Route** when legal, SOC, business, risk, platform, app, data, evaluation, lifecycle, or exception owner must decide first.
- **Block** when authorization, non-production scope, stop condition, or approved evidence handling is missing.

For an exception, record: reason, affected target/category, unsupported or unverified method, equivalent customer-owned assurance route if one exists, owner, evidence location reference, acceptance test, target date, release impact, retest criterion, and review trigger.

**Boundary:** Keep customer data and evidence in customer-approved systems; store references only. S8 does not provide attack datasets, run production tests, change tenant policy, prove production enforcement, or approve production use.
