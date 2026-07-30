# S0 · Technical Intake & Feasibility Triage lab kit

Use this lab to route one AI candidate to the right technical session, or block
it because it is not inspectable. Work in the customer's approved records
system; this repository keeps only blank templates and safe field shapes.

## Inputs

- One candidate workload, agent, capability, change, or prototype.
- Named customer owner who can open the relevant system.
- Customer-approved records location for safe references.
- Candidate environment and lifecycle state.
- Known stop condition for unsafe evidence handling, production-only target, or
  missing owner.

## Steps

1. Name the candidate and environment.
2. Open or identify the primary Microsoft/customer surface: Foundry, Copilot
   Studio, M365 extension, Azure app, Entra, APIM, API Center, Purview,
   Defender, Monitor, Cost Management, or customer backlog/change system.
3. Check identity, data, platform, tool/API, telemetry, and owner
   inspectability without changing configuration.
4. Pick the first technical blocker.
5. Mark the result state: ready for technical session, blocked by access,
   blocked by owner, blocked by evidence handling, unsupported/wrong route, or
   discovery-only.
6. Route to the next session or customer owner with an accepted-when condition
   and recheck trigger.
7. Record only safe references; do not paste customer evidence, prompts,
   outputs, telemetry, exports, endpoints, secrets, tenant identifiers, or live
   configuration.

## Required technical fields

- Candidate reference
- Environment and lifecycle state
- Primary Microsoft/customer surface
- Owner who can inspect it
- Evidence location
- Identity path status
- Data path status
- Platform/runtime path status
- Tool/API path status
- Telemetry/operating path status
- First blocker
- Result state
- Next technical route
- Accepted-when condition
- Recheck trigger

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short decision
  wrapper when needed.

## Output

A customer-owned intake result that routes the candidate to the right next
technical action. The lab does not deploy, configure, grant access, export data,
prove control operation, or approve production.
