# Quality, cost, and latency review addendum

Use this optional addendum with the operating-review template when bounded
quality trends, latency drift, or token-cost accountability are in scope. It
references customer-held evidence only; it does not query live data or draw a
conclusion from an incomplete trend.

## Scope and accountability

| Field | Record |
|---|---|
| Bounded population and review period | |
| Evidence location | |
| Quality owner | |
| Latency owner | |
| Cost owner / spend decision owner | |
| Review cadence | |

## Quality trend review

| Dimension | Prior-period reference | Current-period reference | Observation | Alternative explanation | Interpretation owner | Decision or escalation |
|---|---|---|---|---|---|---|
| Task completion | | | | | | |
| Groundedness | | | | | | |
| Safety | | | | | | |
| Tool-use accuracy | | | | | | |

## Latency drift review

For first-token, throughput, and error-saturation review under real traffic, or
reconciliation against an approved synthetic baseline, use the
`performance-telemetry-review.template.md` addendum.

| Component | Prior p95 reference | Current p95 reference | Observation | Drift hypothesis | Alternative | Test plan | Owner | Escalation trigger |
|---|---|---|---|---|---|---|---|---|
| Time to first token | | | | | | | | |
| Model inference | | | | | | | | |
| Retrieval | | | | | | | | |
| Tool calls | | | | | | | | |
| End-to-end | | | | | | | | |

## Token-cost accountability

| Workload / agent | Prior-period cost reference | Current-period cost reference | Observation | Attribution limit | Spend decision owner | Escalation |
|---|---|---|---|---|---|---|
| | | | | | | |

## Model-version change

| Question | Record |
|---|---|
| Has the model, version, or fine-tuning configuration changed? | |
| What evaluation evidence covers the change? | |
| What population or attribution limit prevents a conclusion? | |

## Implementation backlog

| Backlog item | Applies / N/A / unknown / later | Recommendation and confidence | Evidence reference or gap | Owner | Customer follow-up route |
|---|---|---|---|---|---|
| Quality-trend coverage or regression investigation | | | | | Evaluation / operations process |
| Latency-drift observation or component-attribution gap | | | | | Platform operations |
| Cost attribution, spend decision, or fine-tuning cost boundary | | | | | FinOps or portfolio-governance process |
