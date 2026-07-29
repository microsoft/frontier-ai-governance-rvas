# S11 · LLMOps Change Control: Technical decisions

!!! warning "Verify before adopting"
    Last reviewed: 2026-07-24 · This is a Microsoft Learn-aligned LLMOps operating model. Verify current Microsoft Foundry, Azure Monitor, Application Insights, Azure API Management, CI/CD, region, quota, and customer requirements before implementation.

## Workshop route

Default to the Microsoft LLMOps lifecycle:
**data curation → experimentation → evaluation → validate/deploy → inference →
monitor → feedback/data collection**. Preserve the Microsoft Learn inner-loop
and outer-loop model, but make it concrete for one change.

1. Choose one bounded LLMOps change.
2. Create the LLMOps change card.
3. Map the seven lifecycle stages.
4. Build the release manifest and artifact version contracts.
5. Classify model/deployment lifecycle states.
6. Define rollout, fallback, rollback, and retirement authority.
7. Define feedback-to-curation governance.
8. Define automation prerequisites.
9. Decide ready for next customer process, defer, reject, route, or block.

![S11 illustrative LLMOps change control flow: change card, seven-stage lifecycle package, artifact version contracts, release manifest, rollout/fallback/rollback authority, feedback-to-curation gate, automation readiness, blocked gaps, and safe evidence boundary.](../assets/diagrams/s11-llmops-change-control-flow.svg)

## LLMOps change card

| Field | Record |
|---|---|
| Workload / capability | Bounded app, agent, route, or service under review. |
| Change type | Prompt, retrieval, tool/API, model, fine-tuning, dataset, rubric, deployment alias, fallback, feedback, retirement, or automation. |
| Lifecycle question | What next customer process or lifecycle step is being considered? |
| Environment | DEV, PRE, limited preview, expanded preview, production-change readiness, or customer equivalent. |
| Affected artifacts | Safe references to prompt, retrieval config, tool schema, model alias, dataset/scenario, rubric, code release, gateway route, telemetry signal, or feedback queue. |
| Intended stage | Data curation, experimentation, evaluation, validate/deploy, inference, monitor, or feedback/data collection. |
| Decision owner | Customer role or process allowed to accept this lifecycle record. |
| Artifact owners | Data, experiment, engineering, evaluation, platform/change, operations, LLMOps, and governance owners as applicable. |
| Approved records location | Customer-approved location for completed evidence and decision records. |
| Evidence limits | Missing, sampled, unsupported, stale, or out-of-scope evidence that constrains the decision. |
| Stop condition | Condition that halts rollout, automation, feedback reuse, alias movement, fallback, or retirement. |
| Target customer process | Change review, release review, backlog, experiment queue, evaluation queue, operations review, exception review, or portfolio review. |

## Seven-stage lifecycle package

| Stage | Microsoft implementation default | Required record | Accepted when... |
|---|---|---|---|
| Data curation | Customer-governed data source, transformation, retrieval/evaluation asset reference, feedback queue where applicable. | Purpose, source/provenance, transformation, retention, privacy/data owner, quality limit, curation output reference. | Data is fit for the stated experiment or evaluation, or the gap is blocked with owner, acceptance test, and review trigger. |
| Experimentation | Protected source repo, reproducible candidate reference, Microsoft Foundry project or customer experiment record where supported. | Hypothesis, candidate artifact, parameters or prompt-change reference, population, experiment owner, cost/capacity assumption, limitations. | Candidate is worth evaluating, abandoned, or needs a new data/control/engineering action. |
| Evaluation | Microsoft Foundry evaluators/agent evaluators where supported, manual rubric, load/performance evidence where relevant. | Scenario/dataset reference, evaluator or rubric version, threshold owner, baseline/candidate comparison, unsupported slices, result reference. | Candidate meets the defined evidence package, remains diagnostic-only, or is routed for iteration/rejection. |
| Validate/deploy | Customer CI/CD, IaC, release manifest, environment controls, and change review. | Release manifest, environment, alias target, change authority, canary criteria, excluded population, rollback target, release/hold owner. | The receiving process can decide promote, hold, roll back, or reject without reconstructing missing lifecycle facts. |
| Inference | Foundry deployment or approved model route, API Management/gateway/backend contract, managed identity/network route where applicable. | Service/deployment route, identity and gateway/API boundary, dependency/support path, quota/cost/SLA owner, fallback trigger. | Workload route is ready for the approved use, constrained, deferred, or blocked. |
| Monitor | Foundry observability where applicable plus Application Insights, Azure Monitor, Log Analytics, customer alerting, and approved feedback signals. | Signal, population, retention/coverage limit, query owner, interpretation owner, alert/escalation route, operating reference. | Normal, investigate, contain, fall back, roll back, improve, or defer route is recorded. |
| Feedback/data collection | Approved feedback capture and curation pipeline; feedback enters candidate data or scenario queue. | Purpose, consent/privacy route, sampling/quality rule, retention, curation owner, mutation gate, next candidate owner. | Reuse, discard, investigate, or block decision is recorded before any production mutation. |

## Lifecycle decision tree

| If the change affects... | Treat it as... | Required package before next step |
|---|---|---|
| Data source, feedback reuse, transformation, retention, labeling, or sampling | Data-curation change | Data/privacy review, curation owner, quality limit, candidate dataset/scenario reference, mutation gate. |
| Prompt, retrieval, tool behavior, model behavior, fine-tuning, or application configuration | Inner-loop candidate | Experiment record, artifact version contract, evaluation package, release manifest update if advancing. |
| Evaluation dataset, scorer, rubric, threshold, or unsupported slice | Evidence-claim change | Evaluation baseline owner, comparison impact, threshold owner, limitation, re-evaluation trigger. |
| Model family, provider, region, deployment, capacity, fallback, or deployment alias | Model/deployment lifecycle change | Baseline/candidate/fallback state, switch authority, capacity/cost owner, rollout stage, rollback target, retirement route. |
| Gateway route, identity, quota, capacity, telemetry, support, or alerting | Outer-loop platform/operations change | Platform/change owner, operating signal owner, customer process, rollback or fallback route, evidence limit. |
| Monitoring or feedback signal | Improvement hypothesis | Operating signal reference, hypothesis owner, data/privacy route, curation owner, evaluation route, no-direct-mutation gate. |

## Release manifest reference shape

Use a release manifest to join artifact versions without copying prompts,
datasets, outputs, policy exports, telemetry, tenant configuration, or live
deployment records into the curriculum.

```json
{
  "schema": "safe-reference-release-manifest.v1",
  "releaseRef": "release-id-placeholder",
  "workloadRef": "agent-or-app-placeholder",
  "environment": "pre",
  "changeType": "prompt-or-model-or-retrieval-placeholder",
  "promptRef": "instruction-version-placeholder",
  "retrievalRef": "index-or-query-config-placeholder",
  "toolSchemaRefs": ["tool-schema-version-placeholder"],
  "model": {
    "baselineAlias": "baseline-alias-placeholder",
    "candidateAlias": "candidate-alias-placeholder",
    "fallbackAlias": "fallback-alias-placeholder"
  },
  "evaluationRef": "evaluation-record-placeholder",
  "runtimeControlRef": "runtime-control-record-placeholder",
  "telemetryRef": "operating-record-placeholder",
  "rolloutStage": "limited-preview-placeholder",
  "stopConditionRef": "stop-condition-placeholder",
  "rollbackTarget": "prior-release-placeholder",
  "approverRef": "customer-change-authority-placeholder",
  "evidenceLimitRef": "known-limit-placeholder"
}
```

## Artifact version contracts

| Artifact | Version contract | Reapproval trigger |
|---|---|---|
| Prompt/instruction | Safe reference, semantic version or release ID, owner, intended use, prompt-change rationale, rollback target, excluded content boundary. | Behavior-changing system, developer, tool, safety, or user-facing instruction change. |
| Model/deployment | Deployment alias, model family/version, provider path, region/residency assumption, capacity/quota owner, cost owner, fallback, deprecation date, support owner. | Alias target, fallback, model version/family/provider/region, quota/capacity, support boundary, or cost-allocation change. |
| Dataset/scenario | Dataset or scenario reference, source provenance, split, transformation, retention, rubric coverage, privacy route, sampling rule. | New source, transformation, retention, label/rubric change, feedback reuse, or excluded-slice change. |
| Evaluation rubric | Evaluator/scorer version, threshold owner, unsupported dimensions, manual review route, baseline comparison, limitation. | Threshold, scorer, rubric wording, evaluator version, coverage, or interpretation-owner change. |
| Retrieval config | Source list, permission boundary, filter, ranking/query config, refresh cadence, cache behavior, data owner. | Source, filter, ranking, refresh, cache, or permission-boundary change. |
| Tool schema | Tool/API schema version, gateway route, allowed operation, consumer owner, permission scope, tool-governance reference. | New parameter, action, target, connector, permission scope, response contract, or route change. |
| Deployment alias | Alias owner, target release, traffic stage, switch authority, monitoring signal, stop condition, rollback target. | Traffic movement, failover, rollback, emergency switch, or excluded-population change. |
| Feedback queue | Source, purpose, consent/privacy route, triage owner, sampling/quality rule, curation owner, mutation gate. | New feedback source, purpose, retention, sampling, privacy route, or direct-mutation risk. |
| Rollout plan | Stage names, population, entry conditions, monitoring signals, stop conditions, fallback trigger, rollback target, review date. | Stage expansion, traffic population, monitoring signal, stop condition, fallback, rollback, or authority change. |

## Model/deployment lifecycle state record

| State | Required fields | Not enough |
|---|---|---|
| Approved baseline | Workload, alias or model reference, evaluation baseline, operating signal, owner, support/capacity assumption, rollback target. | "Current production model" without manifest, owner, or comparison evidence. |
| Candidate | Hypothesis, artifact references, experiment lineage, scenario/evaluation route, threshold owner, cost/latency/capacity assumption, excluded slices. | New model ID or prompt branch with no comparison question. |
| Fallback | Target alias/route, activation trigger, switch authority, monitoring signal, compatibility/dependency check, capacity owner, recovery owner. | "Previous version" with no capacity, support, or trigger. |
| Deprecated | Replacement reference, dependent workloads, support end date, user impact, exception owner, retirement target date. | Old artifact kept because nobody knows who uses it. |
| Retired | Removal owner, dependency review, retained-record location, rollback limitation, closure evidence reference, reopen trigger. | Deleted artifact with no dependency or investigation trail. |
| Blocked | Missing owner, evidence, lineage, support, legal/privacy route, switch authority, rollback target, or approved record location. | Silent deferral without owner or acceptance test. |

## Rollout, fallback, and rollback package

| Field | Record |
|---|---|
| Stage plan | DEV, PRE, limited preview, expanded preview, production-change readiness, or customer-equivalent stages. |
| Entry conditions | Required references before entering each stage: manifest, evaluation, runtime-control, operating signal, exception, rollback target. |
| Traffic population | Included users, excluded users, tenant/workload boundary, region/capacity assumptions, and preview limits. |
| Switch authority | Role or process allowed to move traffic, change alias target, activate fallback, roll back, or retire a version. |
| Monitoring signal | Metric, query, alert, review, or customer operating record that informs stop, fallback, rollback, or promotion. |
| Stop condition | Threshold, incident route, quality/safety/cost/capacity signal, evidence gap, or owner decision that pauses advancement. |
| Fallback trigger | Condition that permits fallback plus target route, owner, compatibility note, and recovery route. |
| Rollback target | Prior release, alias, gateway route, prompt/retrieval bundle, tool schema, model deployment, or manual hold state. |
| Review date | Date or trigger for re-checking stage, exception, capacity, retired artifacts, or automation eligibility. |

The rollout package can align to `contracts/rollout-decision.schema.json`, whose
stage names are `dev`, `pre`, `limited_preview`, `expanded_preview`, and `pro`.
S11 uses those fields as safe references only; it does not move traffic or
change aliases.

## Production-readiness boundary

`contracts/production-readiness.schema.json` uses the decision value
`ready_for_separate_change_review`. That wording is intentional. S11 may record
that the lifecycle package is ready for a separate customer change or release
review. It must not record production approval.

| Decision | Meaning in S11 |
|---|---|
| Ready for next process | The safe references, owners, blockers, rollback/fallback route, evidence limits, and review trigger are complete enough for the customer process to decide. |
| Not ready | Required artifact, owner, evidence reference, route, or stop condition is missing. |
| Accepted risk | Residual risk is owned by the customer's accepted-risk authority, with expiry, evidence reference, and review trigger. |

## Feedback-to-curation package

| Step | Required record |
|---|---|
| Signal or feedback source | Operating signal, user feedback queue, incident/problem record, cost/capacity signal, quality signal, safety signal, or support pattern reference. |
| Hypothesis | What might need to change and which population/time window supports the hypothesis. |
| Data/privacy route | Privacy, retention, consent, legal hold, or data-use owner and limitation. |
| Curation rule | Sampling, deduplication, labeling, exclusion, quality, and reviewer requirements. |
| Candidate artifact | Dataset, scenario, prompt, retrieval, model, or tool-change reference created from the curated input. |
| Evaluation route | Baseline/candidate comparison, threshold owner, unsupported slices, and interpretation owner. |
| Mutation gate | Customer process that must accept the candidate before production prompt, data, model, retrieval, or tool behavior changes. |

## Automation readiness package

| Automation area | Evidence required before enablement | Manual override |
|---|---|---|
| Regression test or scenario comparison | Versioned scenario set, baseline, candidate artifact, threshold owner, result location, failure behavior. | Evaluation owner and release/change owner. |
| Canary or phased rollout | Stage plan, population, monitoring signal, stop condition, fallback trigger, rollback target, switch authority. | Platform/change owner and operations owner. |
| Alias switching | Manifest, alias owner, target release, excluded population, traffic stage, rollback target, emergency stop condition. | Switch authority and incident/change owner. |
| Fallback routing | Fallback target, activation trigger, compatibility note, capacity assumption, operating signal, recovery path. | Operations owner and platform/change owner. |
| Feedback-to-curation | Feedback source, privacy route, curation rule, candidate artifact owner, evaluation route, mutation gate. | Data/privacy owner and LLMOps owner. |
| Retirement/removal | Dependency review, replacement reference, support end date, retained-record location, rollback limitation, closure evidence. | Lifecycle steward and service owner. |

## Hard stops

| Stop condition | Required outcome |
|---|---|
| No approved records location | Block. Do not complete a lifecycle package. |
| Unknown artifact owner | Defer or block until the owner accepts the record. |
| Missing baseline/candidate/fallback state | Defer rollout, switching, fallback, or automation. |
| No switch authority or rollback target | Block alias movement, canary, fallback, or retirement readiness. |
| Feedback can mutate production directly | Block until a data/privacy route, curation gate, and evaluation/change route exist. |
| Monitoring cannot inform stop/fallback/rollback | Defer rollout readiness or mark operating evidence as insufficient. |
| Unsupported evaluator, feature, region, SKU, or connector path | Route to the product/platform owner and record limitation; do not treat as proof. |
| Automation prerequisite missing | Keep the step manual and create backlog with owner, acceptance test, and review trigger. |

## Related references

- [S2 data path controls](../s2-data-compliance/technical.md), [S4 build-path package](../s4-agent-engineering/technical.md), [S7 evaluation evidence package](../s7-evaluation/technical.md), and [S10 operating review package](../s10-operate-measure/technical.md).
- [Platform technical guide](../reference/platform-technical-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).

## Boundary note

S11 joins safe references into an LLMOps change control package. It selects no
model, changes no prompt, mutates no data, moves no traffic, switches no alias,
activates no fallback, retires no deployment, enables no automation, configures
no Azure resource, proves no runtime enforcement, and approves no production
release.
