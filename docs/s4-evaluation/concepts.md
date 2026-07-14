# S4 · Quality & Safety Evaluation Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Confirm individual evaluator availability in the [Governance capability guide](../reference/governance-capability-guide.md).

This page explains the measurement model behind S4. [S4 Prepare](index.md) begins the delivery sequence and evidence checklist.

## Evaluation makes an expectation testable

An evaluation compares an agent's observed behavior with an agreed expectation. That expectation may concern answer quality, safety, groundedness, tool use, or task completion. Repeated evaluation detects whether a prompt, model, retrieval source, or tool change makes a known behavior better or worse.

Microsoft Foundry Evaluations provides SDK-based evaluators across quality, risk and safety, and agent-specific behavior. Individual evaluators and their availability can differ, so the customer should validate the exact capability they intend to rely on.[^foundry]

## A dataset is a governed statement of what good looks like

An evaluation dataset contains representative inputs and, where appropriate, expected outputs or reference facts. It turns a subjective claim such as “the agent should answer correctly” into cases that can be rerun after a change.

The first dataset does not need to be large. It does need to reflect the customer’s real tasks, edge cases, and unacceptable outcomes. Co-deliver starts from a mock-target dataset so the team can learn the workflow without sending live customer traffic.

A high aggregate score may still hide an important failing scenario. Review failed cases and preserve the dataset version with the scorecard.

## Metrics guide a decision; they do not make it

Quality evaluators can measure characteristics such as relevance, coherence, groundedness, similarity, and task or tool-call accuracy. Safety evaluators test different failure modes. A metric is useful only when the team agrees what threshold, variance, and exception process is acceptable for that scenario.[^foundry]

This is why Co-deliver treats thresholds as governance artifacts. A threshold is not a magic constant copied from a sample; it is a decision about acceptable risk that must have an owner.

## CI gates turn evidence into release discipline

When an evaluation runs in a pull request or delivery pipeline, it creates a consistent release checkpoint. A regression can be reported first and only later block a change, once the customer understands false positives and rollback behavior. The `microsoft/ai-agent-evals` action is one way to run this pattern in GitHub workflows.[^aievals]

**Boundary:** a CI gate does not replace production monitoring. It validates known examples before release; it cannot observe unknown real-world behavior.

## Continuous evaluation closes the feedback loop

Production traces can reveal new failure patterns, data conditions, or user intents that were absent from the original dataset. With appropriate privacy and governance review, teams can turn selected observations into future regression cases. Foundry monitoring and OpenTelemetry gen-ai tracing support this operational feedback loop.[^foundry]

Start in observe-only mode. Baseline results, investigate failures, tune thresholds, and document exceptions before enabling a blocking control.

[^foundry]: Microsoft Learn - [Foundry Observability](https://learn.microsoft.com/en-us/azure/foundry/concepts/observability); Azure SDK for Python - [`azure-ai-evaluation` README](https://github.com/Azure/azure-sdk-for-python/blob/main/sdk/evaluation/azure-ai-evaluation/README.md).
[^aievals]: GitHub - [`microsoft/ai-agent-evals`](https://github.com/microsoft/ai-agent-evals).
