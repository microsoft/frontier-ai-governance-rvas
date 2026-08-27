# Evaluation control

These artifacts define the Session 11 release-evaluation control.

| Path | Operational purpose |
|---|---|
| `eval/evaluation-spec.json` | Versioned agent target, evaluator set, data mappings, and result-handling contract |
| `eval/data/golden-v1.jsonl` | Synthetic golden cases used for both approved and candidate versions |
| `eval/thresholds.yaml` | Baseline-derived release thresholds, metric layers, and exception rules |
| `gate-tests/cases/tool-process-regression.json` | Payload-free sample case proving that a tool-process regression blocks release |
| `governance/evaluation-governance-decision.md` | Owner approval boundary for draft thresholds, baseline review, and exception limits |
| `release/release-policy.json` | Target, current manual support gate, capability decisions, owners, exception boundary, and gate state |
| `release-records/release-record-template.json` | Payload-free release evaluation record shape retained outside Foundry |
| `operations/disable-and-restore.md` | Immediate disable switch and ordered restore route |

Detailed queries, responses, tool arguments, tool results, evaluator reasons, and personal data stay in
Microsoft Foundry. A release record contains only target identifiers, dataset hash, aggregate counts,
and the Foundry report URL.

Resolve every `__REQUIRED_*__` decision before running the corresponding evaluation phase. The
threshold policy includes draft starter values for relevance, tool process, and safety. The owners
listed in the governance decision must review them against the approved baseline before the gate is enabled. After the approved
version runs, enter its run ID and confirm or replace the numeric thresholds before candidate
evaluation.
`test_release_gate.py --mode blocked-tool-process` generates its payload-free aggregate records in
memory and runs them against the same decision code used by `release-gate.py`.

Session 11 produces a callable `PASS` or `BLOCK` gate. The Session 14 controlled-promotion workflow
enforces it with the approved evaluation specification, threshold policy, release policy, approved
baseline record, and candidate record. Session 14 must use `--require-enabled`; the callable then
requires an enabled gate, an approved dated decision, active thresholds, and matching baseline and
candidate run IDs.
