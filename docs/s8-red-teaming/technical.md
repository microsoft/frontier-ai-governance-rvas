# S8 · Authorized Red Teaming & Retest: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-27 · AI Red Teaming Agent, PyRIT, Azure AI Content Safety, Prompt Shields, Defender, and related governance features vary by target, region, license, and service status. Verify official docs, authorization, and customer rules of engagement before any run.

## Microsoft default

Default to an authorized, customer-operated, non-production Microsoft AI Red Teaming Agent path where the target and category are supported. Use PyRIT, manual expert testing, or an approved third-party route for unsupported targets or categories. Route findings to Prompt Shields, Azure AI Content Safety, gateway policy, in-process policy, tool/API permissions, data/retrieval controls, identity, evaluation, lifecycle, release/change, or SOC backlog as appropriate.

## Workshop decision route

1. **Choose one authorized target.** Identify the target, version, environment, owner, reset/rollback path, monitoring window, dependencies, and production-impact exclusion.
2. **Complete rules of engagement.** Confirm authorization, operators, methods/tools, categories, excluded categories, data limits, prohibited activity, stop conditions, SOC/legal contacts, evidence handling, and retest criteria.
3. **Choose category and method.** Select AI Red Teaming Agent where supported, or an approved PyRIT/manual/third-party route when support or policy requires it. Identify unsupported-target or production-test request routes honestly.
4. **Define threshold and severity before interpretation.** Set the ASR or qualitative threshold, sample/context note, severity model, threshold owner, accepted-risk authority, and not-comparable handling.
5. **Preserve native or run evidence externally.** Store run records, prompts, outputs, and datasets only in the customer-approved records system; retain only safe references here after the run completes.
6. **Write finding records.** Capture category, technique, affected route, evidence reference, impact, exploitability, exposure, detectability, severity, and limitation.
7. **Map findings to remediation controls.** Name the receiving owner, remediation hypothesis, acceptance test, release/backlog impact, and stop condition.
8. **Define retest closure.** Define the retest method, changed target version, comparison rule, closure evidence reference, acceptance owner, remaining risk, and reopen trigger.
9. **Decide.** Use approve, defer, reject, route, block, remediation-required, retest-required, or accepted-risk for the tested scope only.

## Authorized target card

| Field | Required record |
|---|---|
| Target reference | Customer-owned target label, target type, version, environment, and owner. |
| Scope | Capability, user journey, agent/app boundary, allowed interfaces, excluded dependencies, and production-impact exclusion. |
| Reset/rollback | How the non-production target is reset, rolled back, or paused if the stop condition fires. |
| Monitoring window | Start/end window, SOC monitoring expectation, alert/noise caveat, and contact route. |
| Dependencies | Model, tool/API, data/retrieval, identity, gateway, network, or third-party dependency that affects interpretation. |
| Approved records location | Customer system where native run record, run record, prompts, outputs, and findings are retained. |
| Evidence owner | Owner of retention, access, export, deletion, and legal hold handling for test evidence. |

## Set rules of engagement

| Field | Required record |
|---|---|
| Authorization reference | Written approval reference, approving role, date/window, and scope. |
| Operators | Named operator roles, permitted tools, approval reference, and monitoring window. |
| Methods/tools | AI Red Teaming Agent, PyRIT, manual expert path, third-party path, or blocked route with support caveat. |
| Categories | Approved attack categories, excluded categories, threshold owner, and sample-size note. |
| Data limits | Permitted synthetic/customer-held test data, prohibited data, prompt/output evidence handling, and retention owner. |
| Prohibited activity | Activity excluded by safety, legal, operational, cost, or production-impact constraints. |
| Stop conditions | Safety, legal, operational, SOC, cost, rate, production-impact, or instability triggers that halt testing. |
| Contacts | SOC, legal/risk where required, target owner, red-team lead, remediation owner, escalation route. |
| Evidence handling | Customer record location, native-run-record treatment, visibility limits, retention/export/deletion owner. |
| Retest criteria | Fix owner, retest method, success criterion, acceptance owner, target event, and reopen trigger. |

## Category and method route

| Route | Use when | Required records | Do not claim |
|---|---|---|---|
| AI Red Teaming Agent | Target/category is supported and customer can operate the native route safely. | Foundry project/target reference, support status, categories, native run record reference, limitations. | Do not claim coverage for unsupported targets, excluded categories, or production safety. |
| PyRIT | Customer approves repeatable custom testing or the supported native route does not cover the target/category. | Test plan reference, operator, target adapter boundary, category, run record reference, evidence handling. | Do not ship payloads, endpoint clients, or raw run data in this repository. |
| Manual expert testing | Domain judgment, policy nuance, or unsupported route requires approved human testing. | Operator role, method note, category, success condition, evidence record, reviewer, limitation. | Do not treat notes as a native run record or automated coverage. |
| Third-party engagement | Customer requires an external specialist or independent assessment. | Engagement owner, authorization, evidence boundary, category scope, severity model, retest/closure route. | Do not import third-party artifacts into this repository. |
| Unsupported target/category | No approved method safely covers the target or category. | Reason, support caveat, owner, alternate assurance path if any, target event, exception route. | Do not create mock coverage. |
| Production-test request | Requested scope touches production users, data, systems, or change process. | Deferral route to customer legal, SOC, business, risk, and change owners. | S8 does not authorize or approve production testing. |
| Blocked route | Authorization, non-production scope, evidence handling, SOC/legal contact, stop condition, or retest path is missing. | Blocker, owner, acceptance test, target event, recheck condition. | Do not start or accept adversarial activity. |

## Attack category taxonomy

| Category | Tested behavior | Typical control owner |
|---|---|---|
| Direct prompt injection | User attempts to override task, policy, system instruction, or tool boundary. | Prompt/design, runtime-control, in-process policy |
| Indirect prompt injection | Retrieved or tool-returned content attempts to steer the agent. | Data/retrieval, tool-response, runtime-control, evaluation |
| Sensitive-data disclosure | The target exposes data outside approved purpose, role, or audience. | Data/privacy, output safety, investigation |
| Tool abuse or unsafe action | The target invokes unsafe action, parameter, workflow, or side effect. | Tool/API, identity, in-process policy, catalog |
| Hallucination/grounding failure | The target asserts unsupported content in a risk-bearing scenario. | Evaluation, retrieval/source, product owner |
| Harmful or policy-violating content | The target generates or enables disallowed content. | Content Safety, Prompt Shields, runtime-control, safety owner |
| Protected-material concern | The target produces protected material or unsupported reuse. | Legal/risk, evaluation rubric, model owner |
| Cost/availability abuse | Crafted or repeated requests create quota, cost, or availability risk. | Gateway, platform, FinOps, operations |
| Unauthorized access | The target crosses identity, tenant, data, network, or permission boundary. | Identity, platform, data, SOC |

## ASR, threshold, and severity interpretation

| Field | Required record |
|---|---|
| Category and success condition | What counted as adversarial success for this category. |
| ASR or qualitative result | Native ASR value, qualitative result, not-comparable status, or disputed status. |
| Sample/context note | Sample size, prompt/run set reference, reviewer, method, target version, and limitations. |
| Threshold/tolerance | Customer-approved category threshold or qualitative tolerance, with threshold owner. |
| Interpretation | Above, at, below, disputed, not comparable, diagnostic-only, or blocked. |
| Accepted-risk authority | Owner who can accept residual risk, with expiry and recheck condition where applicable. |

Severity combines impact, exploitability, exposure, detectability, response burden, and release/backlog impact.

| Severity input | Interpretation |
|---|---|
| Impact | User, data, financial, operational, legal, safety, or reputation consequence if behavior occurred in intended scope. |
| Exploitability | Skill, access, repeatability, automation potential, and prerequisite conditions. |
| Exposure | Affected users, channels, tools, data classes, environments, shared dependencies, and blast radius. |
| Detectability | Whether SOC, gateway, app, model, tool, or operating telemetry would observe the behavior. |
| Response burden | Human review, incident handling, rollback, communication, or operational effort required. |
| Release impact | Continue within tested scope, hold, block, route, accepted risk, or emergency containment. |

## Classify and route each finding

Use this shape for the customer-owned decision note that references native run evidence. Do not store prompts, outputs, attack payloads, endpoint details, telemetry exports, or run records here.

```json
{
  "findingRef": "finding-id-placeholder",
  "targetRef": "target-version-placeholder",
  "category": "indirect_prompt_injection",
  "technique": "technique-placeholder",
  "method": "ai-red-teaming-agent-or-approved-alternate",
  "severity": "high",
  "impact": "impact-placeholder",
  "exploitability": "bounded-non-production",
  "exposure": "tested-scope-only",
  "detectability": "telemetry-or-manual-review-placeholder",
  "affectedRoute": "retrieval-or-tool-response-route-placeholder",
  "evidenceRef": "customer-native-run-record-or-run-record",
  "owner": "remediation-owner-placeholder",
  "remediationRoute": "runtime-control",
  "releaseImpact": "hold-pre-until-retest",
  "stopCondition": "stop-condition-placeholder",
  "retestCriterion": "criterion-placeholder",
  "acceptedRiskRef": null
}
```

## Finding-to-control remediation map

| Finding signal | Likely cause to investigate | Receiving owner and closure evidence |
|---|---|---|
| Direct injection succeeds | Instruction hierarchy, prompt design, missing local policy, weak refusal/redirect behavior. | Prompt/design or runtime-control owner accepts revised behavior and retest evidence. |
| Indirect injection succeeds | Retrieval source hygiene, tool-response trust, context assembly, missing post-tool inspection. | Data/retrieval, tool/API, or runtime-control owner accepts mitigated route and retest result. |
| Sensitive data appears | Over-broad source access, missing minimization, output leak, telemetry handling gap. | Data/privacy owner accepts data-path fix, evidence handling, and retest note. |
| Unsafe tool action occurs | Authority model, tool scope, parameter validation, approval gate, or identity permission gap. | Tool/API, identity, or in-process policy owner accepts operation-boundary fix and retest. |
| Unsafe content appears | Missing content safety action, threshold mismatch, unsupported category, or policy ambiguity. | Safety owner accepts threshold/control update and category retest. |
| Unauthorized access appears | Identity, network, source permission, route bypass, or tenant boundary gap. | Identity/platform/data/SOC owner accepts containment and investigation reference. |
| Cost or availability abuse appears | Missing quota, rate limit, budget guard, saturation alert, or retry/fallback control. | Gateway/platform/FinOps owner accepts operating guard and load/abuse retest. |
| Not comparable result | Sample, method, target version, category, or threshold cannot support decision. | Red-team lead records diagnostic-only/backlog route and re-entry criterion. |

## Retest and close findings

| Field | Required record |
|---|---|
| Retest method | Same method/category or approved alternate with reason. |
| Changed target version | Prompt, model, tool, data, identity, gateway, policy, or app change being retested. |
| Comparison rule | Same success condition, ASR threshold, qualitative rubric, or manual adjudication rule. |
| Evidence reference | Customer-owned retest run/run record/reference, not copied into the repository. |
| Closure owner | Severity/remediation owner who accepts closure. |
| Remaining risk | Residual limitation, accepted-risk reference, or blocked/reopen condition. |
| Reopen trigger | Material target, method, category, threshold, route, or control change. |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Tooling fit | AI Red Teaming Agent target support, PyRIT test plan, manual/third-party approval, Foundry project/target reference. |
| Authorization | Rules of engagement, SOC notification, legal/risk contact, permitted operators, stop conditions, evidence handling. |
| Target safety | Non-production target, owner, version, reset/rollback path, dependencies, monitoring window, no production-user impact. |
| Category threshold | Customer-approved ASR/category threshold, qualitative tolerance, sample-size note, threshold owner. |
| Safety controls | Azure AI Content Safety, Prompt Shields, APIM/gateway policy, in-process policy, tool-permission boundary if applicable. |
| Detection/response | Defender for Cloud, Defender XDR, Sentinel, SOC ticket/playbook, severity owner, escalation contact. |
| Remediation lifecycle | Catalog/lifecycle state, material-change trigger, retest/evaluation reference, release or portfolio blocker. |
| Evidence handling | native run record or run record retained by customer; sidecar references only; retention/export/deletion owner named. |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Authorized target card | target, version, owner, non-production environment, reset/rollback path, monitoring window, dependencies, and approved records location are recorded. | Target owner |
| Rules of engagement | target, timing, operators, categories, data limits, stop conditions, SOC/legal contacts, evidence handling, and prohibited activity are approved. | Security/legal owner |
| Test approach | method, operator, target, categories, support-status caveat, cost/coverage limits, and safe evidence location are recorded. | Red-team owner |
| Unsupported target route | unsupported target/category, reason, alternate method if any, exception owner, approval path, and retest plan are recorded. | Security/risk owner |
| Production-test request | request is deferred or routed to customer legal, SOC, business, risk, and change process without S8 testing or approval claims. | Customer change owner |
| Threshold interpretation | category threshold, sample size, ASR or qualitative result, limitation, decision owner, and accepted-risk authority are recorded. | Threshold owner |
| Findings route | each finding has category, severity, control owner, remediation path, release impact, stop condition if needed, and retest criterion. | Remediation owner |
| Retest closure | fix evidence and retest result are retained in customer systems and accepted by severity/remediation owner. | Retest owner |
| Lifecycle impact | unresolved blockers and accepted risks are visible to release/lifecycle/portfolio owners with owner and review date. | Release or portfolio owner |

## Boundary note

S8 defines and records authorized testing and remediation. Workshop activity never attacks production systems, changes tenant policy, ships attack datasets, stores customer prompts/outputs/run records in this repository, or claims production control operation from synthetic or prepared tests.

## Related references

- [S6 technical decisions](../s6-security-runtime/technical.md): runtime control placement.
- [S7 technical decisions](../s7-evaluation/technical.md): retest and release assurance.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
