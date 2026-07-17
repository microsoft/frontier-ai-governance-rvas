# Quality, cost, latency, and rollout governance

!!! info "Freshness"
    Last reviewed: 2026-07-17. Verify capability, model, region, pricing, and
    availability before delivery.

Use this guide with S4, S7, and S11 to turn quality, model, latency, cost, and
rollout questions into customer-owned records. It does not select a model, run
an evaluation, set a service-level objective, approve spend, or authorize a
production change.

## Model selection and fine-tuning

Model selection is a governance decision as well as an engineering choice.
Record capability fit, cost, latency, data residency, licensing, deployment
availability, version ownership, and the customer process that can make a
change. A fine-tuning proposal needs a stated capability gap, an alternative
considered, training-data governance, a base-versus-fine-tuned comparison, and
an owner for the resulting model version.

Foundry fine-tuning availability varies by supported model and region. A
customer may use Foundry or another engineering path; S4 records the backlog
and decision route rather than prescribing either one.

## Quality measurement

Quality dimensions should have customer-owned definitions, coverage populations,
exclusions, evaluators or reviewers, threshold references, and regression
owners. Manual annotation and customer-designed scorers are universally
available. Foundry evaluators and agent evaluators may inform a plan where
available, but individual evaluator status and scope must be verified.

An evaluation score is not a threshold decision. The customer owns the baseline,
dataset and scenario version, threshold approval, interpretation, and release
or escalation route. ASSERT is contextual policy-scenario guidance; verify
current status before using it in a customer backlog.

## Latency governance

A latency budget describes a bounded interaction and its customer-owned
expectation. Attribute the budget across model inference, retrieval, tools,
orchestration, and network path, then record what the evidence cannot
attribute. Model benchmarks are not an operating service-level objective.

Application Insights and OpenTelemetry can provide general telemetry routes.
Foundry traces can be an additional project-gated source where enabled. In
either case, sampling, retention, population, and interpretation limits remain
part of the record.

For synthetic load testing, first-token latency, throughput, and production
telemetry measurement, see the
[agent performance-testing guide](performance-testing-guide.md).

## Token cost and FinOps

Token estimates should name input composition, output assumptions, volume,
model tier, cost owner, allocation method, shared-cost assumptions, and the
review period. Inference and fine-tuning training costs are different
boundaries and need separate ownership when both are in scope.

Azure Cost Management can inform subscription-level attribution. Foundry
project or model attribution may be available depending on configuration and
service capability. Neither view by itself proves value, causality, or an
allocation decision.

## Rollout governance

Staged rollout assembles S4 admission, S6 gateway proof, S7 assurance, S8
finding disposition where applicable, and S9 lifecycle references. Each stage
needs its own population, entry and exit conditions, rollback reference, owner,
and status. Production promotion always remains a separate customer
change-authority decision.

## Product-status notes

- Foundry evaluator, agent-evaluator, cloud-evaluation, and continuous-
  evaluation availability can vary. Verify the precise feature status.
- Foundry fine-tuning support varies by model and region.
- Foundry tracing requires a configured project and customer-owned telemetry
  choices.
- Azure Cost Management and Application Insights are broadly available Azure
  services, but their customer deployment and data coverage must be confirmed.

## Related official references

- [Microsoft Foundry model catalog](https://learn.microsoft.com/en-us/azure/foundry/how-to/model-catalog-overview)
- [Fine-tune Microsoft Foundry models](https://learn.microsoft.com/en-us/azure/foundry/how-to/fine-tune-models)
- [Run evaluations from the Microsoft Foundry portal](https://learn.microsoft.com/en-us/azure/foundry/how-to/evaluate-generative-ai-app)
- [Agent Evaluators for Generative AI](https://learn.microsoft.com/en-us/azure/foundry/concepts/evaluation-evaluators/agent-evaluators)
- [Cloud Evaluation with the Microsoft Foundry SDK](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/cloud-evaluation)
- [Microsoft Foundry observability](https://learn.microsoft.com/en-us/azure/foundry/concepts/observability)
- [Azure Cost Management](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/overview-cost-management)
- [FinOps Toolkit](https://microsoft.github.io/finops-toolkit/)
- [Application Insights overview](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
