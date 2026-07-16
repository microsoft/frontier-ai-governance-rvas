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

## A decision is explicit

The assurance owner selects `continue` or `hold` only after the S6 acceptance
condition is met. A future customer-owned evaluation or CI gate may supply
additional decision input, but its operating, evidence, and enforcement
ownership remain with that customer process.

[^foundry-eval]: Microsoft Learn - [Run evaluations from the Microsoft Foundry portal](https://learn.microsoft.com/en-us/azure/foundry/how-to/evaluate-generative-ai-app); [Agent Evaluators for Generative AI](https://learn.microsoft.com/en-us/azure/foundry/concepts/evaluation-evaluators/agent-evaluators); [Cloud Evaluation with the Microsoft Foundry SDK](https://learn.microsoft.com/en-us/azure/foundry/how-to/develop/cloud-evaluation).
