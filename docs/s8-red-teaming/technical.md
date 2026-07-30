# S8 · Authorized Red Teaming & Retest: Technical runbook

!!! info "Freshness"
    Last reviewed: 2026-07-30 · AI Red Teaming Agent cloud, local AI Red Teaming Agent, PyRIT adapters, risk categories, region support, and preview limits vary. Confirm current docs, customer authorization, and support status before any run.

## Microsoft default

Default to a customer-operated, non-production AI Red Teaming Agent run in the
customer's Foundry project when the target and categories are supported. Use
PyRIT, manual expert review, or a third-party engagement only when the support
check, category coverage, target type, or customer policy makes the native route
unsuitable.

## 1. Hard gate before any test

| Gate | Required check | If missing |
|---|---|---|
| Authorization | Written approval, rules of engagement, operators, dates/window, permitted methods, categories, stop conditions, SOC/legal contacts, evidence handling. | Block. Do not test. |
| Non-production target | Customer-owned target alias, version, environment, reset/rollback path, monitoring window, and no production-user impact. | Defer to production-test route; do not test in S8. |
| Support status | Tool supports target type, category, region/project, SDK/API route, and data modality. | Mark unsupported or use approved alternate. |
| Evidence location | Customer system for run records, prompts, outputs, scorecards, findings, retention, export, deletion, and legal hold. | Block. Do not create evidence without owner. |
| Cost/rate boundary | Run size, objective count, concurrency, rate limit, cost cap, and abort owner. | Block or reduce run before start. |
| Retest route | Remediation owner, retest method, comparison rule, and acceptance owner. | Findings cannot close; route before running. |

## 2. Authorized target setup

| Field | Required record |
|---|---|
| Target alias | Safe customer label; no endpoint, tenant ID, secret, or raw URL in this repository. |
| Target type | Foundry project deployment, Azure OpenAI/Foundry Tools deployment, Foundry Agent, PyRIT adapter, manual target, or third-party scope. |
| Version | Agent version, deployment version, prompt/build version, tool/data/policy version, or release candidate. |
| Interfaces | Allowed interface(s), excluded interfaces, and production-impact exclusion. |
| Dependencies | Model, tool/API, data/retrieval, identity, gateway, network, telemetry, and third-party dependencies. |
| Reset/rollback | How the non-production target is paused, reset, rolled back, or cleaned up if a stop condition fires. |
| Monitoring | SOC contact, alert/noise caveat, telemetry owner, start/end window, and escalation route. |

## 3. AI Red Teaming Agent playbook

Use this route when native support fits.

### Support and target check

- Foundry project exists and the operator has **Foundry User** or customer
  approved equivalent.
- Cloud AI Red Teaming Agent supports the selected target type:
  - Foundry project deployment;
  - connected Azure OpenAI/Foundry Tools deployment using
    `connectionName/deploymentName`;
  - Foundry Agent in the project, with agent name and version.
- Local AI Red Teaming Agent/PyRIT routes are confirmed for Python version,
  text-only/single-turn limits where applicable, region support, and preview
  status.
- Target version and target support status are recorded before category
  selection.

### Category selection

Select only categories approved in the rules of engagement. Record the exact
tool category names and excluded categories. Common documented local categories
include `Violence`, `HateUnfairness`, `Sexual`, `SelfHarm`,
`ProtectedMaterial`, `CodeVulnerability`, and `UngroundedAttributes`. Agentic
cloud runs may use configured criteria such as prohibited actions, task
adherence, and sensitive-data leakage. If the required category is unsupported,
stop and route to the unsupported branch.

### Run configuration

| Field | Required value |
|---|---|
| Project endpoint | Safe reference to Foundry project endpoint from **Overview**. |
| Target | Deployment name, connection/deployment name, agent name/version, or approved target object. |
| Categories | Approved category list and excluded list. |
| Sample/objective count | Bounded count approved by ROE and cost/rate owner. |
| Strategy scope | Baseline-only or approved strategy group; no payload text stored here. |
| Taxonomy/source | Taxonomy ID, built-in source, or customer-approved source reference. |
| Stop conditions | Safety, legal, production-impact, cost/rate, instability, SOC alert, or evidence-handling trigger. |
| Monitoring | SOC/legal contact, telemetry, and run window. |

### Run and inspect

1. Create the red-team/evaluation group through the Microsoft Foundry SDK or
   approved customer automation.
2. Create the run with `data_source.type` set to the approved red-team source
   where applicable and the target object set to the authorized target.
3. Poll the run until **completed**, **failed**, or **canceled**.
4. List or open run output in the customer system.
5. Review ASR by category, category/sample limitations, failed run diagnostics,
   not-comparable flags, and target version.
6. Export only to the customer evidence location. Copy only safe references into
   this template.

### Retest

Retest the same category and success condition against the changed target
version. If method, category, target, threshold, or sample changes, record why
the result is comparable or mark it not comparable.

## 4. PyRIT playbook

Use PyRIT when the customer approves repeatable custom testing or the native
route does not fit.

| Area | Required boundary |
|---|---|
| Target adapter | Approved callback, Azure OpenAI/Foundry deployment, PyRIT `PromptChatTarget`, custom HTTP adapter, or customer wrapper. No production endpoint or secret is stored here. |
| Dataset/source | Microsoft-curated objective source, customer-approved synthetic set, or customer-approved seed file. Store content outside this repository. |
| Runtime | Customer-controlled Python environment and dependency approval for `azure-ai-evaluation[redteam]` or PyRIT. |
| Notebook route | Open the customer-approved notebook, load target adapter from customer config, load source by reference, select categories/counts, run scan, write output to customer records. |
| Command route | If a customer wrapper exists, run its documented command using safe references only. Do not invent commands, payloads, or datasets in the workshop. |
| Result storage | Scorecard/run output, raw prompts, outputs, and row-level data remain in customer storage. |

Record method, target/run ID, categories, support caveat, ASR/threshold verdict,
finding route, and retest result. Do not copy payloads or raw row data.

## 5. Manual expert and third-party branch

Use this branch for domain/legal judgment, unsupported tooling, independent
assessment, or specialist testing.

Minimum record set:

| Record | Required fields |
|---|---|
| Authorization | Approval reference, approver role, timing, operators, methods, categories, and stop conditions. |
| Target | Alias, version, non-production environment, owner, reset/rollback, dependencies, and monitoring window. |
| Method | Manual expert, third-party, table-top, approved customer tool, or blocked route. |
| Category scope | Included/excluded categories and success condition. |
| Threshold/severity | ASR threshold if measured, qualitative tolerance, severity model, threshold owner, accepted-risk authority. |
| Evidence handling | Customer location, retention/export/deletion owner, visibility limit, and legal hold route. |
| Finding handoff | Receiving owner, remediation route, release/lifecycle impact, stop condition, retest method, and closure owner. |

Do not import third-party reports, raw notes, prompts, outputs, screenshots,
endpoint details, or payload content into this repository.

## 6. Unsupported and production-test deferral

Use this branch before any test starts.

| Case | Required record | Next action |
|---|---|---|
| Unsupported target | Target type, service/SDK limit, owner, and alternate assurance path if any. | Route to target owner or approved alternate method. |
| Unsupported category | Category name, tool limit, evaluator gap, threshold owner, and possible alternate. | Route to risk/security owner. |
| Unsupported data modality | Non-text, multi-turn, tool side effect, production data, or other unsupported mode. | Defer or redesign test scope. |
| Production-test request | Production users/data/systems/change process would be touched. | Route to customer legal, SOC, business, risk, and change process. S8 does not approve it. |
| Evidence unsafe | No approved storage, retention owner, or visibility limit. | Block until evidence handling exists. |

## 7. ASR, threshold, and result review

| Field | Required record |
|---|---|
| Category and success condition | What counted as success for the approved category. |
| Method | AI Red Teaming Agent, PyRIT, manual expert, third-party, or blocked/unsupported. |
| Target/run ID | Target alias/version and run ID or safe evidence reference. |
| ASR or qualitative result | Overall and category result; not-comparable or diagnostic-only when applicable. |
| Threshold | Customer-approved category threshold or qualitative tolerance. |
| Support status | Supported / unsupported / preview / diagnostic-only / blocked. |
| Interpretation | Below threshold, ASR above threshold, not comparable, blocked, or retest required. |
| Remaining risk | Residual limitation, accepted-risk reference, expiry, and reopen trigger. |

## 8. Finding route and retest

| Finding signal | Route to inspect/fix | Retest check |
|---|---|---|
| Direct injection succeeds | Prompt/instruction hierarchy, local policy, refusal/redirect behavior, runtime control. | Same category and target route after fix. |
| Indirect injection succeeds | Retrieval hygiene, tool-response trust, context assembly, post-tool inspection. | Same data/tool route or approved alternate. |
| Sensitive data appears | Source permissions, minimization, output filter, telemetry/log handling. | Data/privacy owner accepts data-path fix and retest. |
| Unsafe tool action occurs | Tool scope, parameter validation, approval gate, identity permission, side-effect boundary. | Tool/API or identity owner accepts operation-boundary retest. |
| Unsafe content appears | Content Safety, Prompt Shields, threshold setting, unsupported category, policy ambiguity. | Safety owner accepts category retest. |
| Unauthorized access appears | Identity, tenant, network, source permission, route bypass, or SOC investigation. | Identity/platform/data owner accepts containment and retest. |
| Cost or availability abuse appears | Quota, rate limit, retry/fallback, budget guard, saturation alert. | Platform/FinOps owner accepts operating guard and abuse/load retest. |
| Result not comparable | Method, target version, category, sample, or threshold changed. | Re-run with comparable settings or mark diagnostic-only. |

Close a finding only when the remediation/severity owner accepts the retest
result and remaining risk. Reopen on material target, category, method,
threshold, route, or control change.

## 9. Expected signals

| Signal | Accepted when... | Handoff |
|---|---|---|
| Target supported | Support status, target version, category list, and method are verified before run. | Red-team lead |
| Category unsupported | Unsupported category and alternate path/owner are recorded before run. | Security/risk owner |
| Run blocked by authorization | Missing authorization/ROE/SOC/legal/evidence/non-production check is recorded and no test starts. | Customer risk/change owner |
| ASR above threshold | Finding route, severity, remediation owner, release impact, stop condition, and retest trigger are recorded. | Remediation owner |
| Result not comparable | Difference in method/target/category/sample/threshold is recorded and result is diagnostic-only. | Red-team lead |
| Finding retested | Retest run ID/result, changed target version, comparison rule, and remaining risk are accepted by owner. | Retest owner |

## Boundary note

S8 defines and records authorized defensive testing. It does not test production,
approve production, grant access, change tenant policy, ship payload libraries,
or store raw red-team evidence in this repository.

## Related references

- [Run AI Red Teaming Agent in the cloud](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/run-ai-red-teaming-cloud)
- [Run AI Red Teaming Agent locally](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/run-scans-ai-red-teaming-agent)
- [PyRIT documentation](https://microsoft.github.io/PyRIT/latest/)
- [S6 runtime security decisions](../s6-security-runtime/technical.md)
- [S7 evaluation runbook](../s7-evaluation/technical.md)
