# Implementation artifacts

- Use `models/deployment-profiles.json` as the desired deployment state for `main.bicep` and
  preflight. It records the external approval reference and the control inputs for the deployment.
- Use `environments/sandbox.bicepparam` to name the existing nonproduction `AIServices` resource.
- Use `infra/models/main.bicep` to create the listed child deployments.

Resolve every `__REQUIRED_*__` value in a customer working copy. Keep live subscription IDs,
endpoints, customer data, prompts, and responses out of the repository.

For `capacity` and `minimumUnusedQuotaPercent`, replace the full quoted placeholder, including
the quotation marks, with a JSON integer such as `20`. Both preflight scripts reject quoted
numbers. Keep the full approval and lifecycle decision in the customer's normal change process.
