# S7 · Quality, Safety Evaluation & Release Assurance: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Microsoft Foundry evaluations, agent evaluators, cloud evaluation, CI/CD integration, and Azure Load Testing availability vary by region, quota, pricing, SDK/version, and workload. Verify official docs and customer status before delivery.

## Microsoft default

Default to Microsoft Foundry evaluations and agent evaluators where supported, combined with accepted S6 runtime evidence, customer-owned release gates, CI/CD integration when mature, and Azure Load Testing or production telemetry for performance evidence.

![S7 illustrative assurance pattern: accepted S6 runtime evidence precedes an evaluation plan covering selected quality, safety, groundedness, tool-use, regression, and human-review dimensions. The customer-owned assurance decision remains continue or hold.](../assets/diagrams/s7-evaluation-release-handoff.svg)

## Decision tree

1. **If Foundry evaluators cover the scenario**, use them with versioned datasets/scenarios, thresholds, and human interpretation.
2. **If domain judgment or unsupported behavior is material**, add manual rubric/scorer review.
3. **If the release process can consume evidence automatically**, run cloud evaluation in CI/CD with owned thresholds and audit trail.
4. **If performance matters before release**, use Azure Load Testing or an approved synthetic test, then reconcile with S11 production telemetry.
5. **If accepted S6 evidence is missing**, hold the release-gate decision or scope the evaluation as diagnostic only.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Evaluation approach | Foundry evaluations/agent evaluators + scenario datasets | manual or third-party scorer covers unsupported domain/policy needs |
| Release gate | customer release decision using Foundry result references and accepted S6 proof | manual sign-off is required until CI/CD automation is governed |
| Performance evidence | Azure Load Testing plus Application Insights/Azure Monitor/Foundry traces | production telemetry only when pre-release test is not required |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Evaluation | Foundry evaluation run, evaluator/agent evaluator version, dataset/scenario version, rubric record |
| Runtime prerequisite | accepted S6 gateway/app correlation record and route coverage |
| CI/CD | pipeline run, identity/secret design, threshold owner, audit trail, rollback route |
| Performance | Azure Load Testing run, Foundry traces, Application Insights/Azure Monitor metrics, quota/PTU/capacity record |
| Release decision | customer change/release record, approver, hold/continue decision, next review date |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Evaluation plan | dimensions, population, evaluator/rubric version, threshold owner, and unsupported coverage are recorded | Assurance owner |
| Release gate | decision owner has S6 reference, evaluation result, threshold interpretation, outcome, and next action | Release/change owner |
| CI/CD integration | pipeline owner, failure behavior, audit trail, threshold-change route, and rollback owner are recorded | Engineering/release |
| Performance | workload model, targets, environment limits, run evidence, and production-reconciliation owner are recorded | S11 operating owner |

## Boundary note

S7 records assurance decisions and evidence locations; customer release authority makes any production decision.

## Related references

- [S7 Concepts](concepts.md): evaluation boundaries, threshold ownership, performance assurance, and release-sign-off limits.
- [S6 technical decisions](../s6-security-runtime/technical.md): runtime evidence prerequisite.
- [S11 technical decisions](../s11-operate-measure/technical.md): production telemetry reconciliation.
- [Quality, cost, latency & rollout guide](../reference/quality-cost-latency-guide.md).
- [Performance-testing guide](../reference/performance-testing-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
