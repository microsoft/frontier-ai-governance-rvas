# S4 · Agent Build Path & Admission lab kit

Use this lab to select one Microsoft build path for a bounded agent candidate
and verify that the route is inspectable enough for engineering to continue.
Work in the customer's approved records system; this repository keeps only blank
templates and safe field shapes.

## Inputs

- One bounded agent candidate and authority/action class.
- Named engineering owner, service owner, release owner, and evidence location.
- Candidate environment and lifecycle state.
- Candidate Microsoft routes: Foundry Agent Service, Copilot Studio, Microsoft
  365 Copilot extensibility, custom Azure app, workflow automation, or
  prototype-only.
- Known stop condition for missing owner, unsupported service, unsafe evidence
  handling, or production-only test target.

## Steps

1. Classify the candidate authority: inform, draft, recommend,
   act-with-approval, autonomous, coordinating, or blocked.
2. Compare Microsoft build paths and name rejected alternatives.
3. Open or identify the selected product surface:
   - Foundry project/agent/model/tool/data/trace/evaluation area;
   - Copilot Studio environment/solution/agent/action/connector/DLP/audit;
   - M365 app/agent metadata/knowledge/action/Graph permission/admin review;
   - custom Azure app/release/gateway/identity/telemetry/rollback route;
   - workflow trigger/steps/connectors/approval/run history;
   - prototype sandbox boundary and expiry.
4. Verify one safe non-production tool/data/action boundary or inspect an
   existing trace/run-history record. If no safe check exists, mark it blocked
   or diagnostic-only.
5. Fill the selected-path package fields in the template.
6. Mark the result state: buildable route, buildable with backlog, wrong path,
   unsupported route, unsafe authority, prototype-only, or blocked.
7. Record only safe references; do not paste customer code, prompts, outputs,
   telemetry, endpoints, secrets, tenant identifiers, or live configuration.

## Required technical fields

- Agent candidate
- Authority/action class
- Selected Microsoft build path
- Rejected alternatives
- Product surface inspected
- Model route
- Tool/API/connector boundary
- Data/knowledge boundary
- Identity mode
- Telemetry/evaluation hook
- Safe boundary check result
- DEV/PRE/PRO gates
- Release/rollback owner
- Material-change trigger
- Result state and backlog owner

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short decision
  wrapper when needed.

## Output

A customer-owned engineering admission result for one selected path. The lab
does not create code, configure products, grant access, connect tools, deploy,
run production behavior, or approve release.
