# Implementation artifacts

These files form the durable module outputs.

- `monitoring/foundry-platform-monitoring.bicep` deploys the diagnostic setting, action group, and metric alerts.
- `monitoring/foundry-platform-monitoring.bicepparam` supplies the approved scope and thresholds.
- `evaluation/continuous-evaluation-decision.json` records the evaluation rule and owner decisions.
- `evaluation/continuous-evaluation-rule.py` creates or updates the continuous evaluation rule and can list recent runs.
- `evaluation/requirements.txt` lists the Python packages used by the script.
- `queries/foundry-token-and-throttling.kql` gives operators a quick post-deployment telemetry check.

Resolve every `__REQUIRED_*__` value in the approved private configuration path before deployment.
Do not place prompts, responses, tokens, tenant IDs, subscription IDs, endpoints, or customer data in
this repository.
