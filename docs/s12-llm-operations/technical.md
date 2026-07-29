# S12 · LLMOps: Azure implementation blueprint

!!! warning "Verify before adopting"
    Last reviewed: 2026-07-24 · This is a Microsoft Learn-aligned LLMOps operating model. Verify current Microsoft Foundry, Azure Monitor, Application Insights, Azure API Management, CI/CD, region, quota, and customer requirements before implementation.

## Microsoft default

Default to the Microsoft LLMOps lifecycle: **data curation → experimentation → evaluation → validate/deploy → inference → monitor → feedback/data collection**. Preserve the Microsoft Learn inner-loop and outer-loop model: the inner loop improves data, prompts, retrieval, code, and evaluation assets; the outer loop promotes, serves, observes, and feeds governed learning back into the inner loop.

## Lifecycle decision tree

1. **If the change affects data, prompts, retrieval, tools, model behavior, fine-tuning, or evaluation assets**, route it to the inner loop and create a new candidate.
2. **If the candidate is ready for release consideration**, require evaluation evidence and customer validate/deploy controls before PRE or PRO.
3. **If the change introduces a new model version, model family, provider path, fallback, or deployment alias**, record the lifecycle state, comparison evidence, switch authority, rollout plan, and rollback trigger before traffic moves.
4. **If the change affects deployment alias, gateway, identity, quota, capacity, telemetry, or support**, route it to the outer loop platform/change process.
5. **If production monitoring or feedback suggests improvement**, create a hypothesis and curated candidate dataset; never mutate production directly.

## Microsoft Learn LLMOps lifecycle mapping

| Stage | Azure/Microsoft implementation default | Required governance record | Accepted when... |
|---|---|---|---|
| Data curation | customer-governed data source, transformation, retrieval/evaluation asset references | purpose, source/provenance, transformation, retention, owner, S2 decision | data is suitable for the stated experiment/evaluation or the gap is blocked with owner |
| Experimentation | protected source repo and reproducible candidate references for prompts, retrieval, model/deployment choices, and code | hypothesis, candidate/release reference, population, owner, limitations | candidate is worth evaluating, abandoned, or needs new data/control |
| Evaluation | Microsoft Foundry evaluators/agent evaluators where supported plus customer rubrics and versioned scenarios | scorer/rubric, dataset/scenario version, coverage, threshold owner, result reference, evaluation decision | candidate meets the defined gate or is routed for iteration/rejection |
| Validate/deploy | DEV → PRE → PRO through customer CI/CD, IaC, and change control | release manifest with service release, deployment alias, instruction/retrieval release, evaluation evidence, approver, rollback target | promote, hold, rollback, or reject decision is recorded by customer authority |
| Inference | Foundry deployment behind customer-owned alias; API Management/gateway/backend contract and managed identity/network path where applicable | service/deployment route, owner, dependency/support path, performance assumptions | workload route is ready for approved use or constrained/deferred |
| Monitor | Foundry observability where applicable plus Application Insights, Azure Monitor, Log Analytics, and customer alerting | signal, population, retention/coverage limit, interpretation owner, escalation route, operating reference | normal, investigate, contain, or improve route is recorded |
| Feedback/data collection | approved feedback capture and curation pipeline; feedback enters candidate data, not direct production mutation | purpose, consent/privacy route, sampling/quality rule, retention, owner, data and operating handoff | reuse, discard, or investigate decision is recorded |

## Model lifecycle automation contract

| Lifecycle decision | Record before automating | Automation enabled later |
|---|---|---|
| Approved model baseline | safe model/deployment reference, owner, intended workload, evaluation evidence, support and capacity assumptions | reconstructable release manifest and baseline regression comparison |
| Candidate model version | hypothesis, test population, scenario coverage, acceptance thresholds, cost/latency limits, and evaluation evidence route | scheduled comparison runs and gated promotion checks |
| Rollout and switching | traffic stage, alias or gateway change authority, canary criteria, monitoring signals, and rollback target | controlled canary rollout, alias switching, and fallback routing |
| Deprecation and retirement | replacement reference, dependent workloads, support end date, user impact, rollback limits, and removal owner | automated deprecation alerts, migration backlog, and retirement workflow |

## Material-change matrix

| Change | Lifecycle effect | Mandatory route |
|---|---|---|
| New data source, feedback reuse, retention, or transformation | changes data-curation fitness and privacy/compliance assumptions | Data review, then experiment/evaluation owner |
| Prompt, retrieval, tool-use, model, fine-tuning, or configuration behavior change | creates a new inner-loop candidate | experiment record, evaluation evidence, customer change before PRO |
| New model/provider, family, region, version, fallback, or deployment path | changes selection, inference dependencies, lifecycle state, and possibly behavior | agent admission/selection, evaluation, platform/change control, operating review as applicable |
| Deployment alias, fallback, quota, capacity, gateway, or identity change | changes validate/deploy, inference dependencies, or model-switching behavior | platform/change control; evaluation/operating review where behavior or operations change |
| Evaluation dataset, scorer, rubric, or threshold change | changes the evaluation claim | evaluation decision and comparison/coverage impact record |
| Telemetry, alert, retention, cost allocation, or incident route change | changes monitoring and feedback-loop evidence | operating review and customer change route |

## Release manifest reference shape

Use a release manifest to join artifact versions without copying prompts,
datasets, outputs, or tenant configuration into the curriculum.

```json
{
  "releaseRef": "release-id-placeholder",
  "workloadRef": "agent-or-app-placeholder",
  "environment": "pre",
  "promptRef": "instruction-version-placeholder",
  "retrievalRef": "index-or-query-config-placeholder",
  "toolSchemaRefs": ["tool-schema-version-placeholder"],
  "model": {
    "deploymentAlias": "model-alias-placeholder",
    "fallbackAlias": "fallback-alias-placeholder"
  },
  "evaluationRef": "evaluation-record-placeholder",
  "runtimeControlRef": "runtime-control-record-placeholder",
  "telemetryRef": "operating-record-placeholder",
  "rollbackTarget": "prior-release-placeholder",
  "approverRef": "customer-change-authority-placeholder"
}
```

## Version contracts

| Artifact | Version contract | Reapproval trigger |
|---|---|---|
| Prompt/instruction | Safe reference, semantic version or release ID, owner, intended use, prompt-change rationale, rollback target. | Any behavior-changing instruction, system prompt, tool instruction, or safety instruction change. |
| Model/deployment | Deployment alias, model family/version, region/residency assumption, capacity/quota owner, fallback, deprecation date. | Alias target, fallback, model version/family/provider/region, or quota/capacity change. |
| Dataset/scenario | Dataset reference, source provenance, split, transformation, retention, rubric coverage, privacy route. | New source, transformation, retention, label/rubric change, or feedback reuse. |
| Evaluation rubric | Evaluator/scorer version, threshold owner, unsupported dimensions, manual review route, evaluation reference. | Threshold, scorer, rubric wording, evaluator version, or coverage change. |
| Retrieval index/config | Source list, filter, ranking/query config, refresh cadence, cache behavior, data owner. | Source, filter, ranking, refresh, or permission-boundary change. |
| Tool schema | Tool/API schema version, gateway route, allowed action, owner, tool-governance reference. | New parameter, action, target, connector, or permission scope. |
| Deployment alias | Alias owner, target release, traffic stage, switch authority, monitoring signal, rollback target. | Traffic movement, failover, rollback, or emergency switch. |

## Alias, fallback, and canary governance record

| Field | Record |
|---|---|
| Switch authority | Role or process allowed to move traffic or change alias target. |
| Traffic stage | DEV/PRE/PRO, canary percentage or population, start/end time, excluded users. |
| Failover trigger | Availability, latency, quality, safety, cost, quota, or incident signal that permits fallback. |
| Monitoring signal | Metric/query/alert reference and interpretation owner. |
| Rollback target | Prior release, model alias, gateway route, prompt/retrieval bundle, and owner. |
| Stop condition | Threshold or incident route that halts rollout. |

## Feedback curation path

Production feedback is a candidate input, not a direct production mutation.

1. Operating signal or feedback queue identifies a hypothesis.
2. Data governance reviews privacy, retention, consent, and data-use limits.
3. Curation owner creates a candidate dataset or scenario reference.
4. Experiment owner creates a candidate prompt/retrieval/model/tool change.
5. Evaluation owner evaluates the candidate against baseline and known risks.
6. Customer change authority decides whether the manifest can advance.

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Candidate provenance | source repository/release reference, prompt/retrieval/model config reference, Foundry project |
| Evaluation gate | Foundry evaluation/agent evaluator result, rubric/scenario dataset version, evaluation decision |
| Release reconstruction | CI/CD run, IaC reference, deployment alias, approval, rollback target |
| Inference route | Foundry deployment, API Management backend/gateway route, managed identity/RBAC, network record |
| Monitoring and feedback | Foundry traces, Application Insights/Azure Monitor/Log Analytics, feedback pipeline, privacy/retention record |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Seven-stage map | one workload has owner, record location, and decision state for every lifecycle stage | LLMOps/service owner |
| Model lifecycle map | approved, candidate, fallback, deprecated, and retired model states have owners, evidence requirements, switch authority, rollout stage, and rollback target | LLMOps/platform owner |
| Inner-loop reproducibility | data, prompt/retrieval, code, model/deployment, evaluation, and outcome references can be reconstructed safely | Engineering owner |
| Outer-loop promotion | DEV/PRE/PRO gate, release manifest, approval, and rollback target are recorded | Platform/change owner |
| Feedback loop | monitoring/feedback signals have privacy route, curation owner, quality rule, and next inner-loop action | Operating, data, or service owner |

## Boundary note

S12 joins prior decisions into an LLMOps workflow; it selects no model, configures no Azure resource, and approves no production release.

## Related references

- [S2 technical decisions](../s2-data-compliance/technical.md), [S4 technical decisions](../s4-agent-engineering/technical.md), [S7 technical decisions](../s7-evaluation/technical.md), and [S11 technical decisions](../s11-operate-measure/technical.md).
- [Platform technical guide](../reference/platform-technical-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
