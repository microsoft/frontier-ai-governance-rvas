# Quality measurement plan

Copy this blank plan into the customer's approved records system. It extends
the evaluation-plan review with bounded quality questions. It does not run an
evaluator, set a threshold, or create a release gate.

Use `quality-threshold-decision.template.json` only after every selected
dimension has a threshold reference, an evaluator reference, an accountable
threshold owner, and a stated coverage limit. Otherwise record `provisional`
or `blocked`; do not treat an empty or unreviewed dimension as approved.

## Quality dimensions and coverage

| Dimension | Customer-owned definition | Measurement method | Evaluator or reviewer | Threshold reference | Coverage population | Exclusions |
|---|---|---|---|---|---|---|
| Task completion | | | | | | |
| Groundedness / retrieval quality | | | | | | |
| Coherence / fluency | | | | | | |
| Safety / policy compliance | | | | | | |
| Tool-use accuracy | | | | | | |
| Latency at quality | | | | | | |
| Human-review agreement | | | | | | |

Manual annotation and customer-designed scorers are universal options. Foundry
evaluators, agent evaluators, cloud evaluation, and continuous evaluation may
be project-gated or vary by capability; verify current status before use.

## Threshold and baseline governance

| Field | Record |
|---|---|
| Threshold proposer and approver | |
| Regression owner and hold / escalation route | |
| Baseline version, evaluator, dataset, and scenario references | |
| Current version and comparison reference | |
| Dataset owner, version, sampling approach, and known gaps | |
| Quality-threshold decision reference | |

## Implementation backlog

| Backlog item | Applies / N/A / unknown / later | Recommendation and confidence | Evidence reference or gap | Owner | Later session or customer process |
|---|---|---|---|---|---|
| Evaluator type and bounded question | | | | | Customer evaluation process |
| Dataset, scenario coverage, and excluded population | | | | | Customer evaluation owner |
| Evaluation suite definition, version, and renewal trigger | | | | | Customer SDLC / S9 |
| Continuous evaluation cadence and production-sampling scope | | | | | Customer platform process / S11 |
| Trace-to-dataset ownership and curation review | | | | | Customer evaluation owner / S9 |
| Threshold approval, regression response, and release-gate owner | | | | | Customer release process |
