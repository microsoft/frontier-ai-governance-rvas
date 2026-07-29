# Practical workshop: authorized adversarial finding lifecycle

**Microsoft default:** Microsoft Foundry AI Red Teaming Agent where supported, PyRIT or manual expert testing for authorized alternate paths, Azure AI Content Safety/Prompt Shields, Defender, Sentinel, and SOC remediation routes.

**Customer decision:** Approve, defer, reject, route, block, remediate, retest, or accept risk for a bounded non-production target and category. Approval accepts a scoped remediation or risk decision; it is not production approval and does not change a customer system.

## Work the decision

1. **Choose the target and version.** Select one non-production target, target version, category set, and decision owner. Name the target owner, red-team operator, SOC contact, legal/risk contact where required, evidence owner, threshold owner, severity owner, remediation owner, retest owner, and approved records location.
2. **Complete authorization before method.** Inspect the rules of engagement for target, timing, operators, categories, allowed methods/tools, data limits, prohibited activity, stop conditions, monitoring window, contacts, evidence handling, and approved records location. If incomplete, block or route before testing.
3. **Select the category and method route.** Use AI Red Teaming Agent when supported for the target/category. Use PyRIT, manual expert testing, or a third-party route only when the same authorization, safety, evidence, and retest records are complete. Record unsupported target/category reasons instead of forcing mock coverage.
4. **Define threshold and severity before interpreting results.** Record the ASR or qualitative threshold, sample/context note, severity model, threshold owner, accepted-risk authority, and not-comparable/disputed result handling.
5. **Preserve evidence externally.** Keep prompts, outputs, datasets, scorecards, run records, endpoint details, and incident payloads in the customer-approved records system. The S8 record stores safe references only.
6. **Classify each finding.** Record category, technique, affected route, evidence reference, impact, exploitability, exposure, detectability, severity, limitation, and release/backlog impact.
7. **Map each finding to remediation.** Choose a control owner: Prompt Shields/Content Safety, gateway, prompt/design, tool permission, data/retrieval path, identity, in-process policy, SOC detection, evaluation, lifecycle/catalog, accepted-risk authority, release hold, or blocked route.
8. **Set stop condition and retest closure.** Record what halts testing, what proves the fix worked, who accepts retest evidence, and what happens if the finding remains above threshold.
9. **Record outcome and handoff.** Approve only when authorization, SOC/legal contact, stop condition, category threshold, severity owner, remediation owner, retest criterion, evidence location, and receiving handoff are complete. Otherwise defer, reject, route, block, remediate, retest, or accept risk with owner and target date.

## Scenario routes

| Scenario | Route | Practical decision cue |
|---|---|---|
| Supported target and category | AI Red Teaming Agent path | Use the customer-operated native path and retain the scorecard unchanged in customer records. The decision record may reference the scorecard and threshold comparison sidecar. |
| Custom target, unsupported category, or service unavailable | PyRIT/manual path | Route to approved PyRIT/manual expert testing with the same ROE, SOC contact, evidence handling, thresholds, severity owner, and retest criteria. Do not use a mock substitute. |
| Independent or specialist assessment required | Third-party route | Record engagement owner, authorization, scope, evidence boundary, severity model, remediation route, and retest closure before using results. |
| Unsupported target cannot be safely tested | Unsupported-target route | Reject, defer, or route to architecture/security owner with reason, support caveat, residual risk, target date, and alternate assurance path if one exists. |
| Production-test request | Production-test request route | Defer to customer legal, SOC, business, risk, and change process. S8 does not test production or approve production use. |
| Above-threshold injection finding | Remediation route | Create a finding with affected route, severity, remediation owner, stop condition, release impact, and retest criterion. |
| Below-threshold category result | Tested-scope support route | Record tested scope, target version, threshold, sample limitations, owner acceptance, and next review trigger. Do not generalize to other versions or production. |
| Tool-abuse finding | Tool/control route | Route to tool/API, identity, approval-gate, in-process policy, or catalog owner with allowed operation boundary and retest condition. |
| Sensitive-data disclosure finding | Data/privacy route | Route to data owner, privacy/legal owner, minimization/output-safety owner, or investigation route with evidence-handling limit. |
| Missing SOC or legal contact | Block or route | Do not proceed until monitoring, escalation, legal/risk contact where required, and stop condition are accepted. |
| Disputed threshold or sample | Diagnostic-only route | Keep the result as diagnostic, record limitation, and assign threshold/sample review owner. |
| Retest after remediation | Retest closure route | Use the same category and criterion or an approved alternate; closure requires owner acceptance and customer-retained evidence. |

## Decision record

Fill this row in the customer-approved records system. Store safe references only.

| Work item | Microsoft control path | Owner | Evidence location | Accepted when | Target date | Handoff |
|---|---|---|---|---|---|---|
| Authorized red-team remediation package | AI Red Teaming Agent where supported; PyRIT/manual approved alternate; Azure AI Content Safety/Prompt Shields; Defender/Sentinel; SOC remediation routes | AI red-team / security owner | Customer-approved record reference only | Target card, ROE, method route, threshold/severity interpretation, finding record, remediation owner, stop condition, retest criterion, exception status, backlog, and handoff are complete | Customer date | Remediation / SOC / retest owner |

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Authorized target | target, version, owner, non-production environment, reset/rollback path, monitoring window, dependencies, and approved records location are recorded | Target owner |
| Rules of engagement | target, environment, version, timing, operators, categories, allowed methods, data limits, prohibited activity, stop conditions, and evidence handling are approved | Security/legal owner |
| SOC/legal contact | SOC contact, monitoring window, escalation path, legal/risk contact if required, and stop condition are named | SOC / legal owner |
| Method route | AI Red Teaming Agent support status or PyRIT/manual/third-party alternate is recorded with owner, limitations, cost/coverage note, and safe evidence location | Red-team owner |
| Category threshold | ASR or qualitative threshold, sample/context note, threshold owner, disputed/not-comparable handling, and accepted-risk authority are named | Threshold owner |
| Severity owner | each finding has severity owner, impact rationale, exploitability, exposure, detectability, release/backlog impact, and escalation route | Security owner |
| Remediation owner | each finding maps to Prompt Shields/Content Safety, gateway, app/tool, data, identity, SOC, evaluation, lifecycle, accepted-risk, release hold, or blocked owner | Remediation owner |
| Retest closure | closure condition, retest method, evidence owner, target date, remaining risk, reopen trigger, and acceptance owner are recorded | Retest owner |
| Workshop safety | the activity is authorized, non-production, defensive, remediation-oriented, stores no customer evidence in the repo, and makes no production-control claim from synthetic/prepared tests | Facilitator |

## Decision tree

- **Approve** when the authorized target, method, threshold interpretation, severity owner, remediation route, retest criterion, evidence location, and handoff are complete for the tested scope.
- **Remediation required** when a finding exceeds tolerance or has severity requiring action before continued release/change activity.
- **Retest required** when a fix, threshold change, target change, or disputed result requires rerun or manual adjudication.
- **Accepted risk** when the customer-authorized risk owner accepts residual risk with expiry, review trigger, and compensating action where required.
- **Defer** when records, owners, thresholds, support status, SOC/legal contacts, evidence handling, or retest criteria are missing but recoverable.
- **Reject** when the target, method, or category cannot be tested safely or cannot meet the bounded objective.
- **Route** when legal, SOC, business, risk, platform, app, data, evaluation, lifecycle, release, or exception owner must decide first.
- **Block** when authorization, non-production scope, stop condition, or approved evidence handling is missing.

For an exception, record: reason, affected target/category, unsupported or unverified method, equivalent customer-owned assurance route if one exists, owner, evidence location reference, acceptance test, target date, release impact, retest criterion, and review trigger.

**Boundary:** Keep customer data and evidence in customer-approved systems; store references only. S8 does not provide attack datasets, run production tests, change tenant policy, prove production enforcement, or approve production use.
