# S6 prompt-security response playbook skeleton

Use this skeleton to define how prompt-firewall or runtime-control signals are
routed to a customer SOC, Sentinel process, Defender route, or manual review
owner. It is not an enabled Sentinel analytic rule or Logic App deployment.

## Scope

| Field | Value |
|---|---|
| Session | S6 · Runtime Path Evidence & Response |
| Signal source | APIM diagnostics, Application Insights, Azure Monitor, Defender, Sentinel, or customer SIEM |
| Trigger | Prompt-firewall block, diagnostic-only state, route bypass, partial signal, or repeated no-signal finding |
| Environment | Non-production / customer-approved |
| SOC owner | Customer-supplied |
| Evidence owner | Customer-supplied |

## Trigger assumptions

Before enabling any response workflow, the customer should confirm:

- the signal source and table are available;
- the correlation value joins gateway, app, backend/model, and SOC records;
- severity mapping is agreed by security and SOC owners;
- alert payloads do not include raw prompts, outputs, secrets, or regulated
  data unless customer retention rules explicitly allow it;
- suppression, throttling, and duplicate handling are defined;
- the response owner can close, route, or escalate the finding.

## Suggested signal categories

| Signal | Initial severity | First response | Owner |
|---|---|---|---|
| Prompt-firewall block on approved non-production route | Medium | Confirm expected block and correlate to scoped test. | Security reviewer |
| Diagnostic-only inspection state | Low / Medium | Route to gateway/platform owner to inspect endpoint, schema, timeout, or feature support. | Platform owner |
| No policy signal for correlated request | Medium | Route to telemetry or gateway owner for missing diagnostics or route bypass review. | Telemetry owner |
| Partial signal: gateway trace but no backend/model/tool join | Medium | Route to app/backend owner for correlation propagation gap. | Application owner |
| Repeated route bypass signal | High | Escalate to platform and security owners; review network and direct-backend controls. | Platform / security owner |
| Unsupported control scope | Low / Medium | Record exception, compensating control, target event, and recheck condition. | Governance lead |

## Response flow

1. Receive signal in Sentinel, Defender, workbook, queue, or manual review list.
2. Confirm the signal belongs to the scoped non-production path.
3. Retrieve the correlation value and time window.
4. Run the S6 runtime evidence query pack in the customer workspace.
5. Classify the signal state: signal present, no signal, partial signal,
   diagnostic-only, alert routed, unsupported route, or blocked evidence
   handling.
6. Assign remediation or acceptance to the named customer owner.
7. Record safe references in the customer evidence and decision records.
8. Define the recheck trigger: route change, policy version change, material
   model/tool change, production-promotion request, or recurrence review.

## Evidence fields

| Field | Safe reference only |
|---|---|
| Alert or incident reference | Link or ID in customer system |
| Correlation value | Customer evidence record, not this repo |
| Query reference | Workbook/query name and time window |
| Signal state | Aggregate classification |
| Reviewer decision | Accept, defer, route, block, reject, or diagnostic-only |
| Remediation owner | Customer role/team reference |
| Recheck trigger | Event or date |

## Hard stops

- No approved records location.
- No SOC or manual review owner.
- Alert payload would expose prompts, outputs, secrets, or regulated records
  without customer-approved retention handling.
- No correlation field or query owner.
- Production-only target or unapproved live traffic.
- Component diagnostic is being labeled as runtime-path enforcement proof.

## What this skeleton does not do

This skeleton does not deploy a Sentinel analytic rule, create a Logic App,
change Defender configuration, open incidents, approve production operations, or
prove a control is operating. The customer must adapt and approve any live
response workflow in its own process.
