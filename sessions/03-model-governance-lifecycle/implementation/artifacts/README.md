# Implementation artifacts

- `models/deployment-profiles.json` defines the approved deployment profile for `main.bicep` and
  preflight. It records the external approval reference and deployment settings.
- `environments/sandbox.bicepparam` names the existing nonproduction `AIServices` resource.
- `infra/models/main.bicep` creates the listed child deployments.

Resolve every `__REQUIRED_*__` value in a working copy. Keep live subscription IDs, endpoints,
customer data, prompts, and responses out of the repository.

For `capacity` and `minimumUnusedQuotaPercent`, replace the quoted placeholder, including its
quotation marks, with a JSON integer such as `20`. Both preflight scripts reject quoted numbers.
Keep the full approval and lifecycle decision in the normal change process.
