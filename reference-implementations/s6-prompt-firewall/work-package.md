# S6 prompt firewall implementation work package

## Scope

| Field | Value |
|---|---|
| Session | S6 · Runtime Path Evidence & Response |
| Maturity level | Secure / Operate |
| Workload or route reference | Customer-owned non-production route reference |
| Customer owner | Security or runtime-control owner |
| Implementation owner | Gateway/platform owner |
| Evidence owner | Customer records-system owner |
| Environment | Non-production / customer-approved |

## Customer-owned prerequisites

- Non-production route approved for a synthetic request.
- APIM or approved gateway owner can update policy in the scoped environment.
- Prompt-inspection control is selected and supported for the route.
- Correlation identifier can be created or propagated.
- Telemetry destination and query owner are known.
- SOC or manual review owner is named.
- Rollback or disable path is documented before testing.

## Implementation artifacts

| Artifact | Repo reference | Customer destination | Owner | Accepted when |
|---|---|---|---|---|
| APIM prompt-firewall policy skeleton | `policies/apim/s6-prompt-firewall.policy.xml` | Customer APIM policy workspace or change package | Gateway/platform owner | Policy is adapted, reviewed, and tested only on the approved non-production route. |
| Policy parameter guide | `policies/apim/s6-prompt-firewall.parameters.md` | Customer implementation notes | Gateway/platform owner | All placeholders have customer-owned values or explicit exceptions. |
| Runtime evidence KQL | `dashboards/azure-monitor/s6-runtime-evidence.kql` | Customer Log Analytics / workbook query store | Telemetry owner | Query can retrieve the scoped run by correlation ID or explains the missing join. |
| Workbook guidance | `dashboards/azure-monitor/s6-runtime-evidence.workbook.md` | Customer Azure Monitor workbook backlog | Telemetry owner | Workbook sections map to S6 signal states and owners. |
| Sentinel response skeleton | `playbooks/sentinel/s6-prompt-security-response.md` | Customer SOC playbook or manual response process | SOC owner | Actionable prompt-security signals have owner, queue, escalation, and recurrence path. |

## Non-production validation path

1. Record the scoped route, backend, owner, and safe request window.
2. Apply the adapted policy through the customer's change process.
3. Send one synthetic request that should be allowed.
4. Send one synthetic request that should be blocked or annotated by the
   selected prompt-inspection control.
5. Capture the correlation value only.
6. Query gateway, app, dependency, and security signals by correlation value.
7. Classify the result as signal present, no signal, partial signal,
   diagnostic-only, alert routed, unsupported route, or blocked evidence
   handling.
8. Record the reviewer decision and next action in the customer's records
   system.

## Evidence boundary

Record only safe references in this work package. Do not paste customer
identifiers, tenant configuration, credentials, prompts, outputs, telemetry
rows, screenshots, logs, APIM exports, Sentinel incident contents, or evidence
payloads into this repository.

## Handoff

| Next action | Owner | Customer process | Recheck trigger |
|---|---|---|---|
| Adapt policy placeholders and named values. | Gateway/platform owner | Gateway change process | Policy version change or route change. |
| Confirm telemetry joins by correlation ID. | Telemetry owner | Observability backlog | New backend, model, tool, or trace provider. |
| Confirm SOC or manual review route. | SOC owner | Incident/response process | New severity, alert rule, or operating window. |
| Decide runtime-control claim for reviewed path. | Security reviewer | Governance decision record | Promotion request, material change, or missing signal. |
