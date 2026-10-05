# Implementation artifacts

This module keeps one Azure Policy initiative, one assignment template, one custom policy
definition, and one decision record after delivery.

- `policy/guardrail-decisions.json` records the approved scope, owners, effects, diagnostic
  destination, data-residency SKU decision, content-filter minimums, and restore reference.
- `policy/definitions/restrict-foundry-deployment-sku.json` defines the custom deployment-SKU
  policy used by the initiative.
- `policy/initiative.bicep` deploys the custom definition and the policy set.
- `policy/assignment.bicep` assigns the policy set with staged effects and a managed identity for
  diagnostic-log remediation.
- `environments/*.bicepparam` bind the templates to the recorded decisions.

Resolve every `__REQUIRED_*__` value in the approved private configuration path before deployment.
Do not add tenant IDs, subscription IDs, tokens, endpoints, prompt data, or customer data to these
files.
