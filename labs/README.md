# Lab files: required records and shared helpers

Each session lab under `labs/s*/` is a compact technical work package:

- `README.md` is the session entry point and facilitation guide.
- `templates/decision-record.template.md` is the shared required customer-facing record. Copy it into the customer's approved records system and complete it there.
- S1 and S11 include small addendum templates only where the session artifact
  needs extra technical fields.

Shared helpers under `labs/helpers/` support offline illustration or reusable checks. They do not deploy services, change a tenant, or make a customer decision.

## Before using a helper

1. Read the matching session lab's `README.md`.
2. Work on a customer-approved copy outside this repository when inputs contain customer information.
3. Keep customer names, evidence, credentials, endpoint URLs, prompts, and outputs out of this repository.

| Helper | What it is for | What it needs | What it creates | Safe to run here? |
|---|---|---|---|---|
| `helpers/control-plane-reconciliation/scripts/reconcile-registry.py` | Compares catalog and identity-inventory records by explicit object ID and reports gaps. It never guesses a match from a name. | Registry JSON, identity-inventory JSON, and lifecycle-state policy JSON. Sample files are supplied. | A reconciliation-report JSON file. It does not change inputs. | Yes with the supplied samples. Use a customer-approved copy for real records. |
| `helpers/control-plane-reconciliation/data/agent-registry.sample.json` | Sample S9 catalog input for the reconciliation helper. | Nothing for sample use. | Nothing by itself. | Yes. Sample data only. |
| `helpers/control-plane-reconciliation/data/s1-agent-inventory.sample.json` | Sample S1 identity-inventory input for the reconciliation helper. | Nothing for sample use. | Nothing by itself. | Yes. Sample data only. |
| `helpers/control-plane-reconciliation/policies/lifecycle-states.json` | Lifecycle-state transition policy for the reconciliation helper. | Nothing for sample use. | Nothing by itself. | Yes. Sample policy only. |

## Commands you can run locally

Run these from the repository root. Replace placeholder paths with copies held outside the repository when they contain customer information.

```bash
# Reconcile the supplied S9 samples
python labs/helpers/control-plane-reconciliation/scripts/reconcile-registry.py

```

## How to read outputs

- A report or `pass` is limited to the input and scope stated in that output. It is not production approval.
- A script can identify a missing field or unmatched record. The customer assigns the follow-up owner and makes the decision.
- Keep completed outputs in the customer's approved records system, not in Git.
