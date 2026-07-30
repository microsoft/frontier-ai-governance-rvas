# S6 · Runtime Path Evidence & Response lab kit

Use this lab to verify whether one bounded non-production request path produces
reviewable runtime evidence. Work in the customer's approved records system;
this repository keeps only blank templates and safe field shapes.

## Inputs

- One non-production synthetic request or approved read-only trace.
- Named application, gateway/platform, identity, security, SOC, telemetry,
  retention, evidence, and reviewer owners.
- Known correlation field or owner for creating one.
- Customer-approved telemetry and records locations.
- Known stop condition for unsupported route, unsafe evidence handling, or
  production-only testing.

## Steps

1. Name the request path: caller, app/workload identity, gateway or app route,
   backend model/agent, tool/API route, and response path.
2. Capture the correlation value and expected propagation points.
3. Query the agreed telemetry source and time window by correlation value.
4. Check whether the expected policy decision appears: block, allow, annotate,
   log, throttle, fallback, or no decision observed.
5. Check whether the signal reaches Defender, Sentinel, SOC queue, workbook,
   alert, incident, or manual review owner.
6. Classify the signal state: signal present, no signal, partial signal,
   diagnostic-only, alert routed, unsupported route, or blocked evidence
   handling.
7. Decide accept, defer, route, reject, block, or diagnostic-only for the
   reviewed path only.
8. Record only safe references; do not paste customer prompts, outputs, logs,
   telemetry rows, policies, endpoints, secrets, tenant identifiers, or live
   configuration.

## Required technical fields

- Request/run reference
- Runtime request path
- Gateway/app/model/tool control point
- Correlation value
- Telemetry source and time window
- Query owner
- Expected signal
- Actual signal state
- Policy decision observed
- SOC/retention result
- Reviewer decision
- Gap owner and recheck trigger

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short decision
  wrapper when needed.

## Output

A customer-owned runtime evidence result for one reviewed path. The lab does
not deploy, configure, grant access, export data, prove production enforcement,
or approve release.
