# S7 · Evaluation & Assurance Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Review customer-owned evaluator availability separately from this assurance handoff.

This page explains the assurance boundary behind S7. [S7 Prepare](index.md)
begins the customer-owned review and handoff.

## Evaluation is not an assurance exit

Customer teams may evaluate quality, safety, groundedness, tool use, or task
completion in their own approved process. Those results can inform the
assurance decision, but a fixture result, local scorecard, or proposed CI gate
does not establish runtime gateway enforcement.

S7 requires the accepted S6 gateway proof first. This ensures the assurance
record is based on a customer-reviewed production-path control boundary rather
than a standalone evaluator claim.

## References keep ownership with the customer

The S7 template records references to the accepted S6 proof, an evaluation
plan, an assurance owner, and the decision. The completed record belongs in the
customer's approved evidence system. It must not contain raw prompts, outputs,
telemetry, credentials, or local evaluator evidence.

The evaluation-plan review should also name what each result can and cannot
support: quality, groundedness, safety, tool-use, regression, human-review, or
unsupported scope. Foundry evaluations and agent evaluators can support a
customer-owned evaluation process, but S7 records references and decisions
rather than operating the evaluator.[^foundry-eval]

## Agent evaluators describe bounded measurement questions

Agent evaluators address defined questions rather than producing a universal
quality score. The evaluation plan should name the scenario, version, coverage
population, evaluator, and limitation for each question.

| Evaluator category | Bounded question | Limitation to record |
|---|---|---|
| Task completion | Did the agent complete the stated objective within the permitted action boundary for these scenarios? | Tasks, paths, and failure modes outside the dataset remain excluded. |
| Intent resolution | Did the agent interpret intent correctly for these scenarios and rubric? | A rubric judgment does not generalize to all production input. |
| Tool-call accuracy | Did the agent invoke the right tool and parameters for these cases? | Tool or boundary changes require renewed evaluation. |
| Response quality | Did the response meet groundedness, relevance, or coherence criteria? | Criteria and population coverage are evaluator-specific. |
| Safety / policy behavior | Did behavior meet the tested safety policy? | It does not replace S8 authorization or runtime controls. |

## Quality thresholds are owned decisions, not measurement outputs

A threshold needs a customer owner, baseline comparison, population limit,
regression response, and decision route. Manual annotation and customer
scorers are available alternatives; Foundry evaluators can inform the process
where available but do not set or approve the threshold. Policy-specific
evaluation guidance such as ASSERT remains contextual and requires current
status verification.

## Fine-tuning changes the evaluation baseline

When a fine-tuned model is in scope, record the base and fine-tuned version,
training-data governance reference, capability objective, pre/post comparison,
and owner who accepts regressions. The S4 model-deployment backlog owns the
engineering decision; S7 records whether the evaluation plan covers the new
version. A fine-tuned evaluation does not replace accepted S6 gateway proof.

## Evaluation review becomes release backlog

The S7 recommendation should state the next release-assurance path with
confidence and assumptions. Typical backlog rows include Foundry evaluation
target, evaluator or scorecard, dataset/scenario owner, trace source,
unsupported population, quality/safety/tool-use threshold, evaluation-suite
version and renewal trigger, continuous-evaluation cadence where available,
trace-to-dataset ownership, future CI/CD or release-gate owner,
rollback/observation route, S8 red-team dependency, and S11 operating-review
handoff.

The backlog is not a live evaluator, CI/CD gate, or production approval. Those
belong to the customer release process.

## A decision is explicit

The assurance owner selects `continue` or `hold` only after the S6 acceptance
condition is met. A future customer-owned evaluation or CI gate may supply
additional decision input, but its operating, evidence, and enforcement
ownership remain with that customer process.

[^foundry-eval]: Microsoft Learn - [Run evaluations from the Microsoft Foundry portal](https://learn.microsoft.com/en-us/azure/foundry/how-to/evaluate-generative-ai-app); [Agent Evaluators for Generative AI](https://learn.microsoft.com/en-us/azure/foundry/concepts/evaluation-evaluators/agent-evaluators); [Cloud Evaluation with the Microsoft Foundry SDK](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/cloud-evaluation).

## Related official references

| Reference | What it can inform |
|---|---|
| [Agent Evaluators for Generative AI](https://learn.microsoft.com/en-us/azure/foundry/concepts/evaluation-evaluators/agent-evaluators) | Bounded evaluator categories and result interpretation. |
| [Run evaluations from the Microsoft Foundry portal](https://learn.microsoft.com/en-us/azure/foundry/how-to/evaluate-generative-ai-app) | Customer-owned evaluation workflow planning. |
| [Cloud Evaluation with the Microsoft Foundry SDK](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/cloud-evaluation) | CI/CD-integrated evaluation backlog planning. |
| [Fine-tune Microsoft Foundry models](https://learn.microsoft.com/en-us/azure/foundry/how-to/fine-tune-models) | Fine-tuning and pre/post comparison planning; verify availability. |

These sources inform customer-owned planning; they do not authorize a CI/CD
gate or replace the accepted S6 proof.

## Policy-specific evaluation needs a measured comparison

A policy-driven evaluation approach such as ASSERT can help a customer express
its own safety requirements as targeted scenarios and compare results before
and after a mitigation. It remains contextual design guidance: the customer
owns the evaluator, dataset, thresholds, and interpretation. A score change
does not itself prove runtime enforcement, release readiness, or control
effectiveness.

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
for Foundry observability/evaluation guidance and contextual ASSERT material.
