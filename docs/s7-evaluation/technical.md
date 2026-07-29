# S7 · Quality, Safety Evaluation & Release Assurance: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing availability vary by region, quota, pricing, SDK/version, and workload. Verify official docs and customer status before delivery.

## Microsoft default

Default to Microsoft Foundry evaluations and agent evaluators where supported, combined with accepted runtime-control evidence, customer-owned release gates, CI/CD integration when mature, and Azure Load Testing or production telemetry for performance evidence.

![S7 illustrative assurance pattern: accepted runtime-control evidence precedes an evaluation plan covering selected quality, safety, groundedness, tool-use, regression, and human-review dimensions. The customer-owned assurance decision remains continue or hold.](../assets/diagrams/s7-evaluation-release-handoff.svg)

## Decision tree

1. **If Foundry evaluators cover the scenario**, use them with versioned datasets/scenarios, thresholds, and human interpretation.
2. **If domain judgment or unsupported behavior is material**, add manual rubric/scorer review.
3. **If the release process can consume evidence automatically**, run cloud evaluation in CI/CD with owned thresholds and audit trail.
4. **If performance matters before release**, use Azure Load Testing or an approved synthetic test, then reconcile with S11 production telemetry.
5. **If accepted runtime-control evidence is missing**, hold the release-gate decision or scope the evaluation as diagnostic only.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Evaluation approach | Foundry evaluations/agent evaluators + scenario datasets | manual or third-party scorer covers unsupported domain/policy needs |
| Release gate | customer release decision using Foundry result references and accepted runtime proof | manual sign-off is required until CI/CD automation is governed |
| Performance evidence | Azure Load Testing plus Application Insights/Azure Monitor/Foundry traces | production telemetry only when pre-release test is not required |

### Evaluation dimension matrix

Select only the dimensions that match the scenario and the release question.
Each dimension needs a population, dataset or scenario version, evaluator or
rubric version, threshold owner, interpretation owner, and unsupported-coverage
statement.

| Dimension | What it asks | Candidate evidence |
|---|---|---|
| Quality and relevance | Does the answer meet the task, audience, and response-quality rubric for the selected scenarios? | Foundry evaluation, manual scorer, rubric review, regression comparison. |
| Groundedness | Is the answer supported by the provided context or source material? | Groundedness evaluator or manual citation/source review; data-source scope and owner. |
| Context relevance | Did retrieval or tool output supply relevant context for the task? | RAG/context evaluator, retrieval trace, tool output review. |
| Safety and harmful content | Does tested behavior meet the selected safety policy and severity threshold? | Foundry safety evaluation, Content Safety result reference, manual review, runtime-control caveat. |
| Prompt-injection resilience | Does the agent resist direct or indirect manipulation in the authorized test set? | Prompt Shields result reference, authorized adversarial-test result, PyRIT/manual red-team evidence. |
| PII and sensitive data handling | Does the flow avoid exposing prohibited or excessive data in prompts, tool outputs, responses, and logs? | PII/sensitive data review, DLP/Purview reference, manual sample review. |
| Protected material | Does generated text or code avoid protected material concerns for the selected scenarios? | Protected-material detection reference, manual review, legal/compliance route where required. |
| Tool use and task adherence | Does the agent call approved tools with correct parameters and stop when outside authority? | Agent evaluator, trace review, tool-call accuracy rubric, tool-boundary reference. |
| Regression | Did a model, prompt, tool, data, or policy change preserve accepted baseline behavior? | Before/after evaluation run, versioned dataset, threshold-change record. |
| Performance and cost | Does the release meet latency, throughput, error, saturation, and token-cost expectations? | Synthetic load result, trace metrics, quota/capacity record, operating reconciliation route. |

Do not use a preview-only evaluator as the sole automated production gate. If a
needed evaluator is preview, unsupported, or unavailable in the tenant, pair it
with a GA evaluator or a customer-owned manual review and record the limitation.

### CI/CD evaluation backlog pattern

If the release process can consume evaluation results, record the automation
decision before relying on it:

| Field | Record |
|---|---|
| Trigger | Pull request, prompt/model change, tool/API change, scheduled regression, or release candidate. |
| Identity and secrets | Pipeline identity, federation/managed identity route, secretless design or exception owner. |
| Inputs | Dataset/scenario version, evaluator/rubric version, model or prompt version, tool/API version. |
| Thresholds | Metric, threshold owner, change route, failure behavior, override/exception owner. |
| Evidence | Run reference, storage location, retention owner, raw prompt/output handling boundary. |
| Release behavior | Continue, hold, require human review, rollback route, remediation owner. |

### Evaluation triage outcomes

Evaluation results should produce a named decision or backlog item, not a loose
score. Keep S7 focused on the release-assurance question: what did the result
show, who owns the next decision, and what evidence would close it?

| Finding type | Typical technical cause to investigate | S7 decision outcome |
|---|---|---|
| Low groundedness | Retrieval scope, missing context, stale source, prompt assembly, unsupported user request. | Open a data or engineering backlog item with source owner, scenario owner, and re-evaluation criterion. |
| Unsafe or blocked content | Threshold too strict/loose, prompt injection, unsafe source material, missing runtime or model control. | Hold release or require safety review with severity owner, threshold owner, and retest condition. |
| Tool-call inaccuracy | Tool schema ambiguity, missing allow-list, wrong parameter mapping, overbroad tool authority. | Open a tool-contract or agent-engineering backlog item with trace reference and accepted parameter behavior. |
| Task failure | Agent plan, model capability, missing tool, latency timeout, dependency failure. | Defer release reliance until the product or engineering owner records a fix hypothesis and validation path. |
| Regression after change | Model version, prompt/system instruction, tool/API version, dataset drift, guardrail change. | Require change-owner review, baseline comparison, rollback option, and repeat evaluation before promotion. |
| Latency or cost miss | Token budget, model choice, PTU/capacity, cache behavior, tool latency, retry/failover. | Treat as an operating or capacity hypothesis with performance owner, budget/capacity owner, and monitoring reference. |

For each finding, record whether the result is a release blocker, accepted
exception, diagnostic-only observation, operating hypothesis, or portfolio
pattern. If the next owner maps to another session, capture that in the customer
backlog or decision record rather than turning this page into the routing map.
Include the validation reference needed to close remediation.

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Evaluation | Foundry evaluation run, evaluator/agent evaluator version, dataset/scenario version, rubric record, unsupported evaluator caveat |
| Runtime prerequisite | accepted gateway/app correlation record and route coverage |
| CI/CD | pipeline run, identity/secret design, threshold owner, audit trail, rollback route |
| Performance | Azure Load Testing run, Foundry traces, Application Insights/Azure Monitor metrics, quota/PTU/capacity record |
| Release decision | customer change/release record, approver, hold/continue decision, next review date |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Evaluation plan | dimensions, population, evaluator/rubric version, threshold owner, and unsupported coverage are recorded | Assurance owner |
| Release gate | decision owner has runtime-proof reference, evaluation result, threshold interpretation, outcome, and next action | Release/change owner |
| CI/CD integration | pipeline owner, failure behavior, audit trail, threshold-change route, and rollback owner are recorded | Engineering/release |
| Performance | workload model, targets, environment limits, run evidence, and production-reconciliation owner are recorded | Operating owner |

## Boundary note

S7 records assurance decisions and evidence locations; customer release authority makes any production decision.

## Related references

- [S7 Concepts](concepts.md): evaluation boundaries, threshold ownership, performance assurance, and release-sign-off limits.
- [Runtime security decisions](../s6-security-runtime/technical.md): runtime evidence prerequisite.
- [Operating and measurement decisions](../s11-operate-measure/technical.md): production telemetry reconciliation.
- [Quality, cost, latency & rollout guide](../reference/quality-cost-latency-guide.md).
- [Performance-testing guide](../reference/performance-testing-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
