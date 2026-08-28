# AI service operational incident runbook

## Scope and first actions

This runbook covers the Session 12 service, gateway, model, agent, tool, evaluation, and telemetry
route. Use the correlation ID and approved configuration references; do not paste prompt, response,
tool payload, credentials, or personal data into tickets or this repository.

1. Assign an incident commander and record the affected service, environment, model deployment,
   agent version, tool name, time window, and correlation IDs.
2. Preserve Application Insights, Defender, Foundry, APIM, and SOC records under their existing
   retention and access controls.
3. The incident commander orders containment when there is active harm or uncontrolled spend. The
   service owner disables or routes away from the affected agent or model version. The tool owner
   disables an affected tool binding. The credential owner revokes or rotates exposed credentials.
4. Keep telemetry and security routing active unless they are the confirmed source of the incident.

## Unsafe output

- The service owner disables or routes away from the affected immutable agent/model version.
- Keep the [Session 08](../../../../08-mcp-tool-security/implementation/README.md) independent tool authorization boundary enforced.
- Inspect the correlated trace and [Session 10](../../../../10-foundry-evaluations-quality-gates/implementation/README.md)/[Session 11](../../../../11-red-teaming-threat-defense/implementation/README.md) evaluation or red-team records in their governed
  systems.
- Notify the AI safety, service, data-protection, and security operations owners.
- Restore service only through a newly reviewed version and the existing quality gate.

## Runaway token use or cost

- The incident commander directs the gateway owner to apply the existing APIM token/rate limit or
  quota control; do not rely on the budget to stop usage.
- Identify service, model deployment, agent version, tool loop, and caller boundary using approved
  low-cardinality telemetry.
- Check streaming completion, retry, recursion, and tool-loop behavior.
- Compare APIM token telemetry with delayed Cost Management data before declaring billing impact.
- Notify the service and cost owners; change the budget only through the normal cost approval path.

## Tool compromise

- The tool owner disables the affected tool binding and denies the operation independently. The
  credential owner revokes or rotates the backend credential.
- Keep the agent endpoint pinned to the last approved version or disable it.
- Correlate gateway, agent, tool, Defender, and SOC records by time and correlation ID.
- The credential owner uses the approved secret-management process; never place credentials in
  incident notes.
- Reconcile [Session 02](../../../../02-identity-privileged-access/implementation/README.md),
  [Session 06](../../../../06-apim-ai-gateway/implementation/README.md),
  [Session 08](../../../../08-mcp-tool-security/implementation/README.md),
  [Session 09](../../../../09-purview-data-governance/implementation/README.md), and
  [Session 11](../../../../11-red-teaming-threat-defense/implementation/README.md) before restoring the tool.

## Model degradation

- The service owner routes to the last approved model deployment or disables the affected route.
- Compare latency, errors, token behavior, quality, safety, and tool-process metrics separately.
- Run the approved [Session 10](../../../../10-foundry-evaluations-quality-gates/implementation/README.md) evaluation against the candidate replacement.
- Confirm quota, regional health, model version, content-control, and gateway routing changes.
- Restore only after the release owner accepts the evaluation result.

## Closure

The incident commander confirms containment and the current service state. Record the residual
risk, owner actions, and next review date. Detailed prompt, response, tool, security, and
customer-data records stay in their governed source systems.
