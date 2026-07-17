# S7 · Evaluation & Assurance Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Review customer-owned evaluator availability separately from this assurance handoff.

This page explains the sign-off boundary behind S7. [S7 Prepare](index.md) starts the customer-owned review and handoff.

## Evaluation is not a release sign-off

![S7 handoff: the accepted S6 gateway proof is required first, then an evaluation plan (quality, groundedness, safety, tool use, regression, human review) goes to the assurance owner who selects continue or hold; Foundry evaluations inform but do not replace the decision.](../assets/diagrams/s7-evaluation-release-handoff.svg)

Customer teams can use Microsoft Foundry evaluations and agent evaluators to review quality, safety, groundedness, tool use, and task completion. Those results can inform a release decision.

They do not prove runtime gateway enforcement. A fixture result, local scorecard, or proposed CI gate is not enough.

S7 requires the accepted S6 gateway proof first. The sign-off record then rests on a customer-reviewed production-path control, not on an evaluator result alone.

## References keep ownership with the customer

The S7 template records references to the accepted S6 proof, an evaluation plan, an assurance owner, and the decision. The completed record belongs in the customer's approved evidence system.

Do not store raw prompts, outputs, telemetry, credentials, or local evaluator evidence in this repository.

The evaluation-plan review should also say what each result can support. Typical categories are quality, groundedness, safety, tool use, regression, human review, and unsupported scope. Foundry evaluations and agent evaluators can support the customer's process, but S7 records references and decisions rather than operating the evaluator.[^foundry-eval]

## Agent evaluators answer specific questions

Agent evaluators do not produce one universal quality answer. The plan should name the scenario, version, population, evaluator, and limit for each question.

| Evaluator category | Practical question | Limitation to record |
|---|---|---|
| Task completion | Did the agent complete the stated task within the allowed action boundary for these scenarios? | Tasks, paths, and failure modes outside the dataset remain excluded. |
| Intent resolution | Did the agent understand the user's intent for these scenarios and rubric? | A rubric judgment does not apply to all production input. |
| Tool-call accuracy | Did the agent call the right tool with the right parameters for these cases? | Tool or boundary changes require a new evaluation. |
| Response quality | Did the response meet groundedness, relevance, or coherence criteria? | Criteria and population coverage depend on the evaluator. |
| Safety / policy behavior | Did the behavior meet the tested safety policy? | It does not replace S8 authorization or runtime controls. |

## Quality thresholds are customer decisions

A threshold needs an owner, a baseline, a population limit, a regression response, and a decision route. Foundry evaluators can inform the threshold where available. They do not set it or approve it.

Manual annotation and customer scorers are also valid options. Policy-specific guidance such as ASSERT stays contextual and needs current status verification.

## Synthetic load testing is pre-release performance assurance

Performance is an assurance question too. Before release, a bounded synthetic load test can show whether an interaction holds its first-token and end-to-end targets at the expected concurrency. Record the workload model, first-token (TTFT/TTFB), inter-token, end-to-end p50/p95/p99, throughput, and error/saturation targets, plus the per-component attribution the evidence supports.

The load engine — for example Azure Load Testing, or an equivalent such as k6 or JMeter — is customer-run and referenced, not operated by this kit. Record the environment-fidelity limits (quota/PTU ceiling, live versus stubbed tools, data parity) because a synthetic result does not transfer to production without them. A benchmark is not a service-level objective, and production reconciliation of any drift hands off to S11. Use `templates/performance-test-plan.template.md` and the [agent performance-testing guide](../reference/performance-testing-guide.md).

## Fine-tuning changes the baseline

When a fine-tuned model is in scope, record the base version, fine-tuned version, training-data governance reference, capability goal, pre/post comparison, and owner who accepts regressions.

The S4 model-deployment backlog owns the engineering decision. S7 records whether the evaluation plan covers the new version. A fine-tuned evaluation still does not replace accepted S6 gateway proof.

## Evaluation review becomes release backlog

The S7 recommendation should name the next release-sign-off path, confidence, and assumptions. Typical backlog rows include Foundry evaluation target, evaluator or scorecard, dataset or scenario owner, trace source, unsupported population, quality/safety/tool-use threshold, evaluation-suite version, renewal trigger, trace-to-dataset owner, CI/CD or release-gate owner, rollback or observation route, S8 red-team dependency, and S11 operating-review handoff.

The backlog is not a live evaluator, CI/CD gate, or production approval. Those belong to the customer release process.

## A decision is explicit

The assurance owner selects `continue` or `hold` only after the S6 acceptance condition is met. A future customer-owned evaluation or CI gate may add input. The customer still owns how it runs, stores evidence, and enforces the result.

[^foundry-eval]: Microsoft Learn - [Run evaluations from the Microsoft Foundry portal](https://learn.microsoft.com/en-us/azure/foundry/how-to/evaluate-generative-ai-app); [Agent Evaluators for Generative AI](https://learn.microsoft.com/en-us/azure/foundry/concepts/evaluation-evaluators/agent-evaluators); [Cloud Evaluation with the Microsoft Foundry SDK](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/cloud-evaluation).

## Related official references

| Reference | What it can inform |
|---|---|
| [Agent Evaluators for Generative AI](https://learn.microsoft.com/en-us/azure/foundry/concepts/evaluation-evaluators/agent-evaluators) | Evaluator categories and result interpretation. |
| [Run evaluations from the Microsoft Foundry portal](https://learn.microsoft.com/en-us/azure/foundry/how-to/evaluate-generative-ai-app) | Customer-owned evaluation workflow planning. |
| [Cloud Evaluation with the Microsoft Foundry SDK](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/cloud-evaluation) | CI/CD-integrated evaluation backlog planning. |
| [Fine-tune Microsoft Foundry models](https://learn.microsoft.com/en-us/azure/foundry/how-to/fine-tune-models) | Fine-tuning and pre/post comparison planning; verify availability. |

These sources inform customer-owned planning. They do not authorize a CI/CD gate or replace the accepted S6 proof.

## Policy-specific evaluation needs a measured comparison

A policy-driven evaluation approach such as ASSERT can help a customer express safety requirements as targeted scenarios and compare results before and after a mitigation. The customer owns the evaluator, dataset, thresholds, and interpretation.

A score change does not prove runtime enforcement, release readiness, or control effectiveness.

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) for Foundry observability/evaluation guidance and contextual ASSERT material.
