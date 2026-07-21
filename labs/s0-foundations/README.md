# S0 Takeaway Kit: Foundations & Operating Model

This kit supports one safe, customer-operated action: establish a governance
maturity baseline and decide the next owned work. It has no tenant connection,
licensing check, policy, deployment, rollback, or evidence-export function.

Start with [runbook.md](runbook.md). Complete all customer records in the
customer's approved records system or generated delivery workspace; never add a
completed scorecard, roadmap, names, or evidence to this repository.

## Included templates and tools

- `assessment/scorecard.csv`: blank 39-question baseline template across the
  thirteen S0-S12 governance domains.
- `assessment/score.py`: offline weighted-score and roadmap generator.
- `assessment/compare.py`: offline S0-to-S12 comparison tool.
- `coe/operating-model.md` and `coe/raci.csv`: blank ownership templates.
- `templates/technical-decision-record.template.md`: blank record for the chosen option, alternatives considered, rationale, owner, and adoption stage.

## Baseline schema

The scorecard is a template, not a customer record. Its rows use the following
schema:

| Field | Meaning |
|---|---|
| `domain`, `domain_name` | Stable domain identifier and display name |
| `question_id`, `question` | Stable assessment question identifier and prompt |
| `concept_explanation` | Guidance for interpreting the question |
| `weight` | Positive relative weight used by the offline scorer |
| `score` | Customer-agreed maturity score: blank or `1`–`4` |

`score.py` requires `domain`, `domain_name`, `question_id`, `weight`, and
`score`; it does not transmit or store the completed baseline. Save a customer
copy before entering scores.

<!-- Verified: static-only: validated in CI (ruff + py_compile + CSV load). -->
