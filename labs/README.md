# Lab files: required records and shared helpers

Each session lab under `labs/s*/` is now a single-file work package:

- `README.md` is the session entry point and facilitation guide.
- `templates/decision-record.template.md` is the shared required customer-facing record. Copy it into the customer's approved records system and complete it there.
- S1 and S11 include small addendum templates for identity review and model lifecycle details.

Shared helpers under `labs/helpers/` support offline illustration or reusable checks. They do not deploy services, change a tenant, or make a customer decision.

## Before using a helper

1. Read the matching session lab's `README.md`.
2. Work on a customer-approved copy outside this repository when inputs contain customer information.
3. Keep customer names, evidence, credentials, endpoint URLs, prompts, and outputs out of this repository.

| Helper | What it is for | What it needs | What it creates | Safe to run here? |
|---|---|---|---|---|
| `helpers/maturity-assessment/scorecard.csv` | Blank questionnaire for an S0 maturity baseline. | Customer-agreed scores from `1` to `4`; blank means unanswered. | Nothing by itself. `score.py` reads it. | Yes. It contains no customer data. |
| `helpers/maturity-assessment/score.py` | Calculates weighted maturity by domain and suggests which areas need attention first. | A completed copy of `scorecard.csv`. | A terminal report only; it does not modify the CSV. | Yes. Offline only. |
| `helpers/maturity-assessment/compare.py` | Compares a baseline scorecard with a later scorecard and lists domains still below a target. | Two scorecard CSV files with the same columns. | A terminal comparison report only. | Yes. Offline only. |
| `helpers/control-plane-reconciliation/scripts/reconcile-registry.py` | Compares catalog and identity-inventory records by explicit object ID and reports gaps. It never guesses a match from a name. | Registry JSON, identity-inventory JSON, and lifecycle-state policy JSON. Sample files are supplied. | A reconciliation-report JSON file. It does not change inputs. | Yes with the supplied samples. Use a customer-approved copy for real records. |
| `helpers/control-plane-reconciliation/data/agent-registry.sample.json` | Sample S9 catalog input for the reconciliation helper. | Nothing for sample use. | Nothing by itself. | Yes. Sample data only. |
| `helpers/control-plane-reconciliation/data/s1-agent-inventory.sample.json` | Sample S1 identity-inventory input for the reconciliation helper. | Nothing for sample use. | Nothing by itself. | Yes. Sample data only. |
| `helpers/control-plane-reconciliation/policies/lifecycle-states.json` | Lifecycle-state transition policy for the reconciliation helper. | Nothing for sample use. | Nothing by itself. | Yes. Sample policy only. |

## Commands you can run locally

Run these from the repository root. Replace placeholder paths with copies held outside the repository when they contain customer information.

```bash
# Score one S0 baseline
python labs/helpers/maturity-assessment/score.py path/to/scorecard.csv

# Compare an S0 baseline and a later scorecard
python labs/helpers/maturity-assessment/compare.py baseline.csv exit.csv --target 3.0

# Reconcile the supplied S9 samples
python labs/helpers/control-plane-reconciliation/scripts/reconcile-registry.py

```

## How to read outputs

- A score, report, or `pass` is limited to the input and scope stated in that output. It is not production approval.
- A script can identify a missing field, weak score, or unmatched record. The customer assigns the follow-up owner and makes the decision.
- Keep completed outputs in the customer's approved records system, not in Git.
