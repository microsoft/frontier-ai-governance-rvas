# S10 · Operating Evidence & FinOps lab kit

Use this lab to inspect whether one workload can be operated from customer-owned
signals. Work in the customer's approved records system; this repository keeps
only blank templates, query placeholders, and safe field shapes.

## Inputs

- One workload, agent, model route, API/tool path, or portfolio slice.
- Review period, time zone, included/excluded populations, and environment.
- Access owners for Application Insights, Log Analytics, Azure Monitor,
  Cost Management exports, quota/capacity views, Defender/Sentinel, and the
  operating review forum.
- Safe references to workspaces, dashboards, workbooks, alerts, budgets, exports,
  quota views, incidents, and cost allocation rules.
- Known stop condition for missing owner, unsupported service, unsafe evidence
  handling, or unavailable source-system access.

## Steps

1. Open Application Insights for the app or agent host. Check requests,
   dependencies, failures, availability, sampling, and whether the `operation_Id`
   or W3C trace context can join gateway, app, model, and tool calls.
2. Open the Log Analytics workspace. Run customer-approved KQL placeholders for
   latency, errors, model/tool route, token or cost proxy, dependency failures,
   and safety/security signals. Record only query references and aggregate
   result states, not raw telemetry.
3. Open Azure Monitor alerts and action groups. Check alert rule state, severity,
   owner, action group/SOC route, suppression rule, and last-fire or test status.
4. Open Azure Monitor workbooks or customer dashboards. Verify population,
   time window, filters, exclusions, query owner, and interpretation owner.
5. Open Cost Management exports, cost analysis, budgets, and FinOps reports.
   Check allocation tags/dimensions, shared-cost assumption, budget/anomaly owner,
   export schedule, and retention.
6. Open quota/capacity views for Azure OpenAI/Foundry/model deployments or the
   relevant service. Check quota owner, PTU/committed-capacity owner, saturation,
   throttling, fallback condition, and request route.
7. Open Defender for Cloud and Sentinel/SOC queues where used. Check security
   findings, incidents, playbooks, handoff owner, and accepted no-result scope.
8. Run the operating review. Classify each signal as normal, investigate,
   missing, sampled, delayed, unsupported, blocked, or route-to-owner.
9. Assign each remediation, alert tuning, cost action, capacity action, telemetry
   gap, or drift hypothesis to a named owner with an acceptance check.

## Required technical fields

- Workload, route, review period, and population
- Application Insights / Log Analytics workspace references
- KQL query references and aggregate states
- Azure Monitor alert/workbook states
- Cost Management export, budget, and allocation rule
- Quota/capacity state and owner
- Defender/Sentinel handoff state
- Correlation method and break points
- Expected state classification
- Remediation owner, next action, acceptance check, and recurrence

## Files

- `templates/decision-record.template.md`
- `../templates/decision-record.template.md` for the shared short decision wrapper when needed.

## Output

A customer-owned operating review record that shows which signals exist, which
queries or dashboards support them, which signals are missing or sampled, who
owns action, and when the review recurs. The lab does not create dashboards,
alerts, budgets, exports, live queries, or production changes.
