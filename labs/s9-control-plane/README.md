# S9 · Control-Plane Reconciliation & Lifecycle lab kit

Use this lab to reconcile one workload across the systems that claim to know it.
Work in the customer's approved records system; this repository keeps only blank
templates and safe field shapes.

## Inputs

- One workload, agent, API/tool route, Foundry project, or portfolio record to
  reconcile.
- Named customer owners for the registry, identity, API/tool, Foundry/platform,
  telemetry, security, portfolio, lifecycle, and evidence locations.
- Safe references to Agent 365 where available, Entra identities, API Center,
  API Management, Foundry, Azure Monitor/Application Insights, Defender/Sentinel,
  and the customer portfolio or CMDB record.
- Known stop condition for missing owner, unsupported service, unsafe evidence
  handling, or unavailable source-system access.

## Steps

1. Open the customer registry or CMDB record and capture the safe workload
   reference, lifecycle state, owner, support contact, and expected API/model
   route.
2. Open Agent 365 or the Microsoft 365 agent inventory where available:
   `admin.microsoft.com` -> **Copilot** -> **Agents & connectors** -> **All
   agents**. Check the agent/workload name, owner, lifecycle state, published
   channels, and referenced identity. If unavailable, record the coverage limit.
3. Open Microsoft Entra admin center. Inspect the Agent ID, managed identity,
   service principal, or app registration. Check sponsor/owner, enabled state,
   credential or federation review reference, and resource assignments.
4. Open Azure API Center and API Management. Check whether the callable API/tool,
   schema or operation, product/backend/route, owner, and lifecycle state match
   the registry.
5. Open Microsoft Foundry. Inspect the project, agent or app, model deployment
   alias, evaluation/run reference, and telemetry link for the same workload.
6. Open Azure Monitor/Application Insights/Log Analytics. Verify the configured
   telemetry pointer, correlation key, query owner, retention, and alert owner.
7. Open Defender for Cloud and Sentinel/SOC queue where used. Check whether
   security posture, alert, or incident handoff exists for the workload or route.
8. Reconcile explicit IDs for one workload: registry ID, Agent 365 reference,
   Entra object/application/agent identity ID, API/API Management route ID,
   Foundry project/deployment alias, telemetry correlation key, and portfolio
   record reference. Do not join on display name alone.
9. Classify signals: matching owner, orphaned identity, uncataloged API,
   unmonitored deployment, stale lifecycle state, missing telemetry, duplicate
   record, unsupported source, or validated no-gap.
10. Assign each gap to the source owner with an acceptance check, next action,
    target event, and recheck condition.

## Required technical fields

- Workload scope and safe registry reference
- Source-system access and coverage limits
- Agent 365 / agent inventory reference where available
- Entra identity reference and owner/enablement state
- API Center and API Management route references
- Foundry project/deployment/evaluation references
- Monitor/Application Insights telemetry pointer
- Defender/Sentinel handoff state
- Portfolio/CMDB/change record reference
- Reconciled join keys for one workload
- Expected signal classification
- Gap owner, next action, acceptance check, and recheck condition

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short decision wrapper when needed.

## Output

A customer-owned reconciliation record that shows which source systems agree,
which source wins each field, what mismatches were found, who fixes them, and how
closure will be verified. The lab does not change identity, catalog, API,
telemetry, security, lifecycle, or production settings.
