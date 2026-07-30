# S6 prompt firewall and runtime evidence package

This package is a non-production reference implementation for
S6 · Runtime Path Evidence & Response. It shows how a customer can adapt an
approved gateway route to:

- carry a correlation identifier through the runtime path;
- call a customer-approved prompt-security inspection point;
- record an allow, block, annotate, or diagnostic-only decision shape;
- query runtime evidence by correlation ID; and
- route actionable signals to a SOC or manual review owner.

It is a starting point, not a deployed control. Customer administrators must
adapt, test, approve, deploy, operate, and retain evidence in their own systems.

## Assets

| Asset | Purpose |
|---|---|
| [`../../policies/apim/s6-prompt-firewall.policy.xml`](../../policies/apim/s6-prompt-firewall.policy.xml) | APIM policy skeleton for correlation, prompt-inspection callout, deny/annotate behavior, and telemetry headers. |
| [`../../policies/apim/s6-prompt-firewall.parameters.md`](../../policies/apim/s6-prompt-firewall.parameters.md) | Customer-supplied parameter and named-value guide for the policy skeleton. |
| [`../../dashboards/azure-monitor/s6-runtime-evidence.kql`](../../dashboards/azure-monitor/s6-runtime-evidence.kql) | Correlation-first KQL query pack for APIM, app, dependency, and security signals. |
| [`../../dashboards/azure-monitor/s6-runtime-evidence.workbook.md`](../../dashboards/azure-monitor/s6-runtime-evidence.workbook.md) | Azure Monitor workbook layout guidance. |
| [`../../playbooks/sentinel/s6-prompt-security-response.md`](../../playbooks/sentinel/s6-prompt-security-response.md) | Sentinel/SOC response playbook skeleton for prompt-security signals. |
| [`work-package.md`](work-package.md) | Adaptation and handoff work package for a customer-owned implementation. |

## Minimum customer prerequisites

- One approved non-production request path.
- Named gateway/platform, application, security, SOC, telemetry, retention, and
  evidence owners.
- Approved records location for evidence references.
- Customer-approved Azure AI Content Safety, Prompt Shields, gateway policy, or
  equivalent inspection point.
- Correlation header or operation ID that can join gateway, app, backend/model,
  and SOC records.
- Stop condition and rollback owner before any live route change.

## Adaptation workflow

1. Copy the work package into the customer records system.
2. Confirm the non-production route, backend, and correlation contract.
3. Configure APIM named values and policy placeholders in a customer-owned
   gateway workspace.
4. Run one synthetic non-production request with no customer secrets, regulated
   data, or live user traffic.
5. Query telemetry by correlation ID using the KQL pack.
6. Classify the signal state and route any gap to the named owner.
7. Record only safe references in the customer's evidence and decision records.

## What acceptance means

Acceptance is scoped to the reviewed non-production path. It means the customer
reviewer found enough route, policy-decision, telemetry, and response evidence
to accept or route the runtime-control claim for that path.

Acceptance does not mean the control is deployed everywhere, production-ready,
certified, compliant, or approved for release.

## Evidence boundary

Do not commit customer identifiers, APIM exports, named values, credentials,
prompts, outputs, telemetry rows, screenshots, Sentinel incidents, tenant
configuration, or evidence payloads to this repository.
