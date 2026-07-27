# Lab files: required records and optional helpers

Each session has one required customer-facing record:
`templates/decision-record.template.md`. Copy that record into the customer's
approved records system and complete it there. Optional helpers support
facilitation, offline illustration, automation, or deeper implementation. They
do not deploy services, change a tenant, or make a customer decision.

## Before using a helper

1. Read the matching lab's `README.md` and `runbook.md`.
2. Work on a customer-approved copy outside this repository.
3. Keep customer names, evidence, credentials, endpoint URLs, prompts, and
   outputs out of this repository.

| File | What it is for | What it needs | What it creates | Safe to run here? |
|---|---|---|---|---|
| `s0-foundations/optional/assessment/scorecard.csv` | Blank questionnaire for the S0 maturity baseline. | Customer-agreed scores from `1` to `4`; blank means unanswered. | Nothing by itself. `score.py` reads it. | Yes. It contains no customer data. |
| `s0-foundations/optional/coe/raci.csv` | Blank responsibility map for the 13 curriculum areas. `R` means does the work, `A` is accountable, and `C` is consulted. | Customer role names and agreement on responsibilities. | Nothing by itself. | Yes. Copy it before adding customer names. |
| `s0-foundations/optional/assessment/score.py` | Calculates weighted maturity by domain and suggests which areas need attention first. | A completed copy of `scorecard.csv`. | A terminal report only; it does not modify the CSV. | Yes. Offline only. |
| `s0-foundations/optional/assessment/compare.py` | Compares a baseline scorecard with a later scorecard and lists domains still below a target. | Two scorecard CSV files with the same columns. | A terminal comparison report only. | Yes. Offline only. |
| `s6-security-runtime/optional/scripts/test_gateway_prompt_shield.sh` | Sends one approved non-production test request through the customer's gateway and writes a redacted gateway-proof manifest. | Approved non-production gateway, customer authentication, safe references, and a reviewer-approved test plan. | A JSON manifest with references, a correlation ID, and `pass` or `fail`. | **No, not as supplied.** Run only in the customer environment after the S6 entry conditions are met. |
| `s8-red-teaming/optional/scripts/redteam-airt.py` | Runs a Microsoft Foundry AI Red Teaming Agent scan through a customer-owned target adapter. | Written authorization, SOC notification, non-production target, Foundry access, optional Python packages, and customer adapter code. | Foundry's native scorecard and, optionally, a threshold-comparison sidecar. | **No.** Run only in the authorized customer environment. |
| `s9-control-plane/optional/scripts/reconcile-registry.py` | Compares catalog and identity-inventory records by explicit object ID and reports gaps. It never guesses a match from a name. | Registry JSON, identity-inventory JSON, and lifecycle-state policy JSON. Sample files are supplied. | A reconciliation-report JSON file. It does not change inputs. | Yes with the supplied samples. Use a customer-approved copy for real records. |
| `s10-in-process-governance/optional/pipelines/run_mock.py` | Demonstrates allow, deny, and approval-required decisions using an offline sample policy. It also checks that the example hash chain is internally consistent. | Nothing for the default example; an existing evidence JSON for `--verify`. | `evidence/policy-decision-audit.json` for the illustration. | Yes. Offline illustration only; it does not run AGT or customer code. |

## Commands you can run locally

Run these from the repository root. Replace placeholder paths with copies held
outside the repository when they contain customer information.

```bash
# Score one S0 baseline
python labs/s0-foundations/optional/assessment/score.py path/to/scorecard.csv

# Compare an S0 baseline and a later scorecard
python labs/s0-foundations/optional/assessment/compare.py baseline.csv exit.csv --target 3.0

# Reconcile the supplied S9 samples
python labs/s9-control-plane/optional/scripts/reconcile-registry.py

# Run and verify the S10 offline illustration
python labs/s10-in-process-governance/optional/pipelines/run_mock.py
python labs/s10-in-process-governance/optional/pipelines/run_mock.py \
  --verify labs/s10-in-process-governance/optional/evidence/policy-decision-audit.json
```

The S6 and S8 commands are deliberately not listed here. Their runbooks require
customer credentials, written approval, and a safe non-production target.

## How to read outputs

- A score, report, or `pass` is limited to the input and scope stated in that
  output. It is not production approval.
- A script can identify a missing field, weak score, or unmatched record. The
  customer assigns the follow-up owner and makes the decision.
- Keep completed outputs in the customer's approved records system, not in Git.
