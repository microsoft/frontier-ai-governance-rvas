# Telemetry and alert operating model

Copy this blank model into the approved customer records system. It defines how
customer-held telemetry can support a decision and response. It does not query
live data, set thresholds, create alerts, or prove an alert was received.

## Scope and telemetry contract

| Field | Record |
|---|---|
| Bounded workload, environment, and review period | |
| Correlation method / join key | |
| Population, sampling, retention, and privacy limits | |
| Evidence owner and approved records location | |
| Operations, security/SOC, service, and cost owners | |
| Review cadence and next review | |

## Signal coverage and attribution

| Signal source | Intended signals / decision use | Population and coverage limit | Correlation or attribution limit | Retention/privacy limit | Source owner | Interpretation owner |
|---|---|---|---|---|---|---|
| Gateway / API Management | | | | | | |
| Agent host / OpenTelemetry / Application Insights | | | | | | |
| Model or Foundry traces/evaluation signals | | | | | | |
| Tool, API, data, or dependency telemetry | | | | | | |
| Identity, network, or security records | | | | | | |
| Cost / quota / capacity record | | | | | | |

## Alert and response catalogue

| Signal or condition | Severity and decision use | Threshold / detection reference | Initial responder | Escalation route | Required correlation/evidence | Suppression or false-positive review | Remediation validation and recurrence check |
|---|---|---|---|---|---|---|---|
| Gateway error, latency, or throttling | | | | | | | |
| Guardrail or policy detection | | | | | | | |
| Agent/tool/dependency failure | | | | | | | |
| Identity or authorization anomaly | | | | | | | |
| Quality, safety, or evaluation regression | | | | | | | |
| Token, quota, or cost anomaly | | | | | | | |

## Operating handoff and exceptions

| Finding, drift hypothesis, or exception | Evidence limit / alternative explanation | Accountable owner | Customer change or response process | Validation reference | Expiry / next review | S12 portfolio handoff |
|---|---|---|---|---|---|---|
| | | | | | | |

