# Implementation artifacts

This module keeps these files after delivery.

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
- `infra/main.bicep` deploys the shared workbook. It uses the workbook definition stored beside
  the module and tags the resource with `implementationModule=foundry-estate-inventory`.
- `monitoring/estate-lifecycle-workbook.json` defines the live operator views for account posture,
  deployments, model lifecycle, Foundry projects, retirement signals, Advisor, and resource health.

Resolve the `__REQUIRED_*__` values in the approved private configuration path. Do not add tenant
IDs, subscription IDs, account names, or report output to these files.
