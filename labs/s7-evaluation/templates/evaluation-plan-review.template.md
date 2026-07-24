# Evaluation plan review

Copy this template into the approved customer records system. S7 references
customer-owned evaluation and release-assurance work; it does not run a live
evaluator, create a CI/CD gate, or store prompts, outputs, datasets, scores, or
telemetry in this repository.

## Evaluation scope

| Field | Record |
|---|---|
| Bounded workload, version, or candidate release | |
| Accepted S6 gateway-proof decision reference | |
| Evaluation plan reference | |
| Assurance owner | |
| Decision owner | |
| Approved records location | |
| Review date and next review | |

## Coverage and interpretation

| Evaluation question | Evidence reference and coverage limit | Interpretation owner | Decision use |
|---|---|---|---|
| Quality or task completion | | | |
| Groundedness / retrieval quality | | | |
| Safety or policy behavior | | | |
| Tool-use or action-boundary behavior | | | |
| Regression or release comparison | | | |
| Human-review or escalation behavior | | | |
| Known unsupported scope or no-result | | | |

## Release-assurance decision prompts

- What decision can this evaluation plan support: continue, hold, defer, or
  block?
- Which evaluator, dataset, trace, or review result is customer-owned and
  approved by reference?
- What does the evaluation not cover: population, version, tool path, data
  source, model behavior, or operating period?
- Which failure, regression, or unsupported result must become an owned finding
  before release progression?
- Which customer process owns any future CI/CD gate, threshold, observation
  period, rollback, and verification?

## Evaluation implementation backlog

| Backlog item | Applies / N/A / unknown / later | Recommendation and confidence | Evidence reference or gap | Owner | Later session or customer process |
|---|---|---|---|---|---|
| Foundry evaluation target, evaluator type (task completion / intent resolution / tool call accuracy / response quality / safety), scorecard, or trace source | | | | | Evaluation process |
| Pre/post fine-tune evaluation comparison, if a fine-tuned model is in scope | | | | | Customer model owner / evaluation process |
| Dataset, scenario coverage, or unsupported population gap | | | | | Customer evaluation owner |
| Release threshold, hold/continue decision, or CI/CD gate owner | | | | | Customer release process |
| Tool-use, action-boundary, safety, or human-review evaluation | | | | | S6 / S8 / customer evaluation process |
| Regression, rollback, observation period, or post-release verification | | | | | Customer SDLC / S11 |
| Operating review, trend, or remediation-validation handoff | | | | | S11 |
| Evaluation suite definition, version, and renewal trigger | | | | | Customer evaluation owner / S11 |
| Continuous evaluation cadence, production sampling scope, and coverage owner | | | | | Customer evaluation / platform process |
| Trace-to-dataset ownership, harvest scope, and curation review | | | | | Customer evaluation owner / S9 |
