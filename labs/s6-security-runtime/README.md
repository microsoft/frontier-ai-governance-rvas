# S6 · Runtime Path Evidence & Response lab kit

Use this lab to produce one compact technical go/no-go artifact. Work in the customer's approved records system; this repository keeps only blank templates and safe field shapes.

## Inputs

- One bounded scenario, route, workload, change, or portfolio slice.
- Named customer owner for the decision and evidence location.
- Safe references to existing Microsoft records where available.
- Known stop condition for missing owner, unsupported service, or unsafe evidence handling.

## Steps

1. Select the bounded unit of work.
2. Fill the technical package fields in the local template.
3. Mark each field as accepted, blocked, unsupported, not applicable, or needs customer review.
4. Record only safe references; do not paste customer evidence, prompts, outputs, telemetry, exports, endpoints, secrets, or tenant identifiers.
5. Decide proceed, defer, route, reject, or block based on the technical gaps.

## Required technical fields

- Runtime request path
- Gateway/app/model/tool control point
- Threat/control map
- Telemetry correlation
- SOC/retention route
- Acceptance decision

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short decision wrapper when needed.

## Output

A customer-owned artifact that names the Microsoft service path, control boundary, evidence reference, blocker, and next technical action. The lab does not deploy, configure, grant access, export data, prove production control operation, or approve release.
