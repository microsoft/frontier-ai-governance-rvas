# Implementation artifacts

- `governance/model-approval-record.json` keeps only the approval state that Foundry and ARM do not
  hold.
- `models/deployment-profiles.json` is the deployment desired state read by `main.bicep`.
- `environments/sandbox.bicepparam` names the existing nonproduction `AIServices` resource.
- `infra/models/main.bicep` creates only the listed child deployments.

Resolve every `__REQUIRED_*__` value in a customer working copy. Do not commit live subscription
IDs, endpoints, customer data, prompts, or responses.

For `capacity` and `minimumUnusedQuotaPercent`, replace the entire quoted placeholder, including
the quotation marks, with a JSON integer such as `20`. Both preflight scripts reject quoted
numbers.
