# Evaluation control artifacts

The repository keeps the definitions that run and govern the release gate:

| Path | Purpose | Consumer |
|---|---|---|
| `eval/evaluation-spec.json` | Versioned evaluator and data-mapping contract. | Evaluation runner and release gate |
| `eval/data/golden-v1.jsonl` | Versioned synthetic cases. | Evaluation runner |
| `eval/thresholds.yaml` | Version-controlled gate thresholds and non-overridable boundaries. | Release gate and promotion workflow |
| `release/release-policy.json` | Version-controlled support, ownership, and exception policy. | Release gate, preflight, and promotion workflow |
| `operations/disable-and-restore.md` | Operating disable and restore procedure. | Release owner and incident operator |

Microsoft Foundry retains detailed evaluations and row-level results. The approved release platform
retains aggregate runs, gate activation, and promotion decisions. The runner accepts an approved
external output path and refuses to write run results in the repository.
