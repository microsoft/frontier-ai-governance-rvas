# S7 · Evaluation Evidence & Release Readiness: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing availability vary by region, quota, pricing, SDK/version, and workload. Verify official docs and customer status before delivery.

## Microsoft default

Default to Microsoft Foundry evaluations and agent evaluators where supported,
combined with accepted runtime-path evidence, customer-owned thresholds,
customer-owned release gates, CI/CD integration when mature, and Azure Load
Testing or approved telemetry for performance evidence.

![S7 illustrative assurance pattern: runtime-path acceptance precedes scenario-set evaluation, evaluator or rubric selection, baseline comparison, threshold interpretation, finding action, and continue or hold handoff. Diagnostic-only evidence stays separate.](../assets/diagrams/s7-evaluation-release-handoff.svg)

## Workshop route

1. **Choose one candidate change.** Name the workload, capability, model,
   prompt/instruction, retrieval, tool/API, policy/control, orchestration,
   deployment alias, or release-package change.
2. **Confirm the runtime prerequisite.** If accepted runtime-path evidence is
   missing, scope the evaluation as diagnostic-only and do not use it for
   release reliance.
3. **Build the scenario-set package.** Record scenario source, owner,
   population, sampling method, included/excluded slices, data/tool boundary,
   environment assumption, reviewer role, and material-change triggers.
4. **Select the evaluator/rubric route.** Choose Foundry evaluator, agent
   evaluator, manual rubric/scorer, CI/CD cloud evaluation, load/performance
   route, diagnostic-only route, or mixed route.
5. **Define baseline and candidate comparison.** Record baseline reference,
   candidate reference, comparison rule, selected metrics, threshold owner,
   regression tolerance, exception owner, and re-evaluation criterion.
6. **Define gate behavior.** Record manual review, blocking CI/CD, warning
   CI/CD, diagnostic-only, mixed, or not applicable; include identity,
   evidence-storage, raw-evidence handling, failure behavior, and override route.
7. **Add performance and cost evidence where relevant.** Capture workload model,
   latency, throughput, error/saturation, quota/capacity, token cost, fallback,
   and operating reconciliation owner.
8. **Map findings to release or backlog action.** Decide continue, hold, defer,
   reject, route, block, diagnostic-only, accepted exception, or remediation
   backlog.

## Decision tree

1. **If Foundry evaluators cover the scenario**, use them with versioned
   datasets/scenarios, thresholds, baseline comparison, and human interpretation.
2. **If tool-use or agent behavior is material**, use agent evaluators or trace
   review with a versioned rubric.
3. **If domain, policy, or legal judgment is material**, add manual scorer
   review and adjudication owner.
4. **If the release process can consume evidence automatically**, run cloud
   evaluation in CI/CD with owned thresholds, failure behavior, override route,
   and audit trail.
5. **If latency, throughput, quota, saturation, or cost matters**, add Azure Load
   Testing, k6, JMeter, Foundry traces, Application Insights, Azure Monitor, or
   another approved performance evidence route.
6. **If accepted runtime-path evidence is missing**, hold release reliance or
   mark the evaluation diagnostic-only.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Evaluation approach | Foundry evaluations/agent evaluators plus versioned scenario set | Manual or approved external scorer covers unsupported domain/policy needs. |
| Scenario evidence | Customer-owned scenario set with owner, source, exclusions, and reviewer | Diagnostic-only when data/tool boundary, environment assumption, or owner is missing. |
| Thresholds | Customer-owned thresholds with baseline, regression tolerance, and exception route | Manual risk review required until threshold owner and re-entry rule exist. |
| Release gate | Customer release decision using evaluation references and accepted runtime-path evidence | Manual sign-off required until CI/CD automation is governed. |
| Performance evidence | Azure Load Testing plus Application Insights/Azure Monitor/Foundry traces where relevant | Approved telemetry-only path when pre-release load test is not required. |

## Evaluation candidate card

| Field | Record |
|---|---|
| Candidate change | Model, prompt/instruction, retrieval, tool/API, policy/control, orchestration, deployment alias, or release package. |
| Release question | What decision this evaluation must inform, and what would continue or hold. |
| Environment and lifecycle | Dev/test/pre-release environment, lifecycle state, version, and scope limit. |
| Owners | Model/agent owner, scenario owner, evaluation owner, threshold owner, evidence owner, release/hold owner, rollback/remediation owner. |
| Approved records location | Customer system that stores completed evidence and safe references. |
| Runtime prerequisite | Accepted runtime-path evidence reference or diagnostic-only boundary. |
| Material-change triggers | Prompt, model, dataset, retrieval, tool schema, policy, deployment alias, route, threshold, evaluator, or scenario-set change. |

## Scenario-set package

| Field | Record |
|---|---|
| Scenario-set reference | Versioned reference in the customer records system. |
| Source and population | How scenarios were selected and what population they represent. |
| Sampling method | Risk-based, regression, production-derived reference, synthetic, SME-selected, red-team-derived, or mixed. |
| Included slices | Quality, relevance, groundedness, retrieval/context, safety, prompt injection, PII, protected material, tool use, task adherence, regression, performance/cost, human-review cases. |
| Excluded slices | Unsupported behavior, unapproved data, unavailable tool path, unsupported evaluator, missing runtime prerequisite, or out-of-scope environment. |
| Data/tool boundary | What source data, retrieval context, tool output, and response surfaces are in scope. |
| Reviewer role and time window | Who reviewed scenario fitness and when. |
| Re-entry trigger | Change that requires scenario-set review before release reliance. |

## Evaluation dimension matrix

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
with a generally available evaluator or a customer-owned manual review and
record the limitation.

## Evaluator and rubric route comparison

| Route | Package fields | Hard limit |
|---|---|---|
| Foundry evaluator | evaluator name/version, configuration reference, scenario set, metric, limitation, owner, run reference, interpretation rule | Not release reliance without runtime prerequisite and customer threshold owner. |
| Agent evaluator | agent behavior dimension, tool-use/task rubric, trace reference, evaluator version, tool boundary, unsupported paths | Does not generalize beyond the scenario set and tool versions. |
| Manual rubric / SME scorer | rubric version, reviewer role, sampling method, adjudication rule, evidence reference, bias/coverage limitation | Slow or subjective review must not be hidden behind a numeric score. |
| CI/CD cloud evaluation | trigger, pipeline identity, secretless/federated route, inputs, thresholds, evidence storage, failure behavior, override owner | A pipeline check is not production approval. |
| Load/performance route | workload model, concurrency, latency targets, quota/capacity, cost metric, error/saturation, fallback/cache, run reference | Synthetic results require environment-fidelity limits and operating reconciliation. |
| Diagnostic-only | missing prerequisite, diagnostic question, owner, accepted limitation, backlog target | Cannot be used as release reliance. |

## Baseline, threshold, and exception package

| Field | Record |
|---|---|
| Baseline reference | Prior accepted run, pre-change run, gold scenario result, manual score, or accepted behavior record. |
| Candidate reference | Run/reference for the proposed change and exact version. |
| Comparison rule | Pass/fail, delta threshold, non-regression, risk-weighted slice, manual adjudication, or mixed. |
| Selected metrics | Groundedness, safety, task success, tool accuracy, latency, cost, regression, or selected custom metric. |
| Threshold owner | Customer owner for threshold setting and changes. |
| Regression tolerance | What decline is acceptable, where it is not acceptable, and why. |
| Exception owner | Owner, expiry, compensating review, re-entry criterion, and release/hold impact. |
| Re-evaluation criterion | What change or finding requires a repeat evaluation. |

## CI/CD evaluation backlog pattern

If the release process can consume evaluation results, record the automation
decision before relying on it:

| Field | Record |
|---|---|
| Trigger | Pull request, prompt/model change, tool/API change, scheduled regression, release candidate, or manual rerun. |
| Identity and secrets | Pipeline identity, federation/managed identity route, secretless design or exception owner. |
| Inputs | Dataset/scenario version, evaluator/rubric version, model or prompt version, tool/API version. |
| Thresholds | Metric, threshold owner, change route, failure behavior, override/exception owner. |
| Evidence | Run reference, storage location, retention owner, raw prompt/output handling boundary. |
| Release behavior | Continue, hold, require human review, rollback route, remediation owner. |

## Performance and cost package

| Field | Record |
|---|---|
| Workload model | User journey, request mix, concurrency, burst assumption, tool/data dependency, and environment fidelity. |
| Latency targets | First-token/TTFB, inter-token, end-to-end p50/p95/p99, timeout, retry, and fallback expectation. |
| Throughput and reliability | Requests per interval, error rate, saturation signal, dependency failures, queueing, and circuit-breaker behavior. |
| Quota and capacity | PTU/capacity, rate limit, model deployment limit, backend limit, and owner for quota/capacity change. |
| Cost | Token cost, tool/API cost, cache effect, retry cost, and budget owner. |
| Evidence and reconciliation | Load-test run or telemetry reference, limitations, and operating owner who reconciles drift. |

## Finding-to-action map

Evaluation results should produce a named decision or backlog item, not a loose
score. Keep S7 focused on the release-readiness question: what did the result
show, who owns the next decision, and what evidence would close it?

| Finding type | Typical technical cause to investigate | S7 decision outcome |
|---|---|---|
| Low groundedness | Retrieval scope, missing context, stale source, prompt assembly, unsupported user request. | Open a data or engineering backlog item with source owner, scenario owner, and re-evaluation criterion. |
| Unsafe or blocked content | Threshold too strict/loose, prompt injection, unsafe source material, missing runtime or model control. | Hold release or require safety review with severity owner, threshold owner, and retest condition. |
| Tool-call inaccuracy | Tool schema ambiguity, missing allow-list, wrong parameter mapping, overbroad tool authority. | Open a tool-contract or agent-engineering backlog item with trace reference and accepted parameter behavior. |
| Task failure | Agent plan, model capability, missing tool, latency timeout, dependency failure. | Defer release reliance until the product or engineering owner records a fix hypothesis and validation path. |
| Regression after change | Model version, prompt/system instruction, tool/API version, dataset drift, guardrail change. | Require change-owner review, baseline comparison, rollback option, and repeat evaluation before promotion. |
| Latency or cost miss | Token budget, model choice, PTU/capacity, cache behavior, tool latency, retry/failover. | Treat as an operating or capacity hypothesis with performance owner, budget/capacity owner, and monitoring reference. |
| Missing prerequisite | No accepted runtime path, no scenario owner, no release/hold owner, no approved records location. | Block or mark diagnostic-only until the missing owner and evidence route are accepted. |

For each finding, record whether the result is a release blocker, accepted
exception, diagnostic-only observation, operating hypothesis, or portfolio
pattern. Capture the validation reference needed to close remediation.

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
| Candidate card | change, release question, owners, approved records location, runtime prerequisite, and material-change triggers are recorded | Evaluation owner |
| Scenario set | scenario source, owner, included/excluded slices, data/tool boundary, reviewer, time window, and re-entry trigger are recorded | Scenario owner |
| Evaluation package | evaluator/rubric route, version, limitation, fallback, baseline, threshold owner, and interpretation owner are recorded | Assurance owner |
| Release gate | decision owner has runtime-path reference, evaluation result, threshold interpretation, outcome, and next action | Release/change owner |
| CI/CD integration | pipeline owner, failure behavior, audit trail, threshold-change route, and rollback owner are recorded | Engineering/release |
| Performance | workload model, targets, environment limits, run evidence, and production-reconciliation owner are recorded | Operating owner |
| Diagnostic-only | missing prerequisite and release-reliance prohibition are explicit | Evaluation owner |

## Boundary note

S7 records evaluation evidence packages and release-readiness handoffs; customer
release authority makes any production decision.

## Related references

- [S7 Concepts](concepts.md): evaluation boundaries, threshold ownership,
  performance assurance, and release-readiness limits.
- [Runtime security decisions](../s6-security-runtime/technical.md): runtime
  evidence prerequisite.
- [Operating and measurement decisions](../s10-operate-measure/technical.md):
  production telemetry reconciliation.
- [Quality, cost, latency & rollout guide](../reference/quality-cost-latency-guide.md).
- [Performance-testing guide](../reference/performance-testing-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
