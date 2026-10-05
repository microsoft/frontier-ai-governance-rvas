# Implementation artifacts

Session 14 keeps these files after delivery.

- `estate-scope.json` records what the report reads and how it judges the result: the approved
  management groups, the account kinds that belong to the AI estate, the approved regions, the
  required tag keys, the recorded exceptions, the inventory owner, lifecycle owner, and model
  retirement warning period. Azure does not hold this decision anywhere.
- `queries/foundry-accounts.kql` is the Resource Graph query the report runs. Keep it as a file so
  the same query can be pasted into Resource Graph Explorer during an investigation.
- `queries/service-health-retirements.kql` returns retirement advisories relevant to Azure AI and
  machine-learning services.
- `queries/advisor-retirement-findings.kql` returns open service upgrade and retirement
  recommendations. The report keeps only findings for in-scope accounts.
- `infra/deploy-workbook.json` deploys the shared workbook through Azure CLI and supports the
  **Deploy to Azure** portal button. It embeds the workbook definition and tags the resource with
  `implementationSession=14-foundry-estate-inventory`.
- `monitoring/estate-lifecycle-workbook.json` is the editable workbook definition. It shows account
  posture, deployments, model retirement, retirement signals, Advisor, and resource health.

Resolve the `__REQUIRED_*__` values in the approved private configuration path. Do not add tenant
IDs, subscription IDs, account names, or report output to these files.
