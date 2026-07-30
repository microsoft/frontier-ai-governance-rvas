# S6 · Runtime Path Evidence & Response: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Azure API Management AI Gateway, Azure AI
    Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR,
    Sentinel, Application Insights, and related telemetry capabilities vary by
    tenant, license, region, workload, and configuration. Verify official docs
    and customer status before delivery.

## Microsoft default

Default to Entra-authenticated Azure API Management AI Gateway or approved
customer gateway routes, Azure AI Content Safety Prompt Shields where supported,
Defender for Cloud AI posture, Defender XDR/Sentinel response routes, and
Application Insights/Azure Monitor correlation. Add application or in-process
controls when the gateway cannot see the needed context.

![Runtime-path acceptance requires correlation across request, route, telemetry, reviewer, and response ownership. Diagnostics stay separate from acceptance proof.](../assets/diagrams/s6-security-runtime-correlation-flow.svg)

## Workshop route: trace and verify the runtime path

1. **Choose one non-production runtime path.** Name scenario, environment,
   route, caller, application owner, gateway/platform owner, security owner, SOC
   owner, telemetry owner, retention owner, evidence owner, reviewer, and
   approved records location.
2. **Trace the runtime path.** Identify caller identity,
   application/workload identity, gateway or app-only route, backend model/agent,
   tool/API route, response path, policy decision point, alert path, telemetry
   destination, correlation field, and evidence-retention owner.
3. **Classify threats and place controls.** For each relevant risk, define the
   inspection point, control, action, telemetry, owner, limitation, and hard
   stop.
4. **Separate gateway proof from diagnostics.** Classify completed evidence as
   gateway-path proof, app-only control evidence, model/agent control evidence,
   SOC/posture signal, or diagnostic-only.
5. **Define the correlation/telemetry contract.** Identify correlation creation,
   propagation, joins, query owner, time window, retention/export owner, known
   blind spots, expected signal, and reviewer.
6. **Define SOC and response route.** Name the Defender/Sentinel route, SOC queue,
   severity owner, playbook, monitoring window, escalation path, stop condition,
   and customer response process.
7. **Close the decision.** Accept only when route, policy decision, telemetry,
   correlation, SOC route, retention, and customer reviewer decision are
   complete enough for the receiving owner to act.

## Operator workflow

Use this sequence for the bounded non-production path. If the customer only has
an existing trace, start at step 3 and mark the run source as read-only review.

| Step | Product surface | Action | Result to capture |
|---|---|---|---|
| 1. Select request | Customer app, Foundry app/agent, test client, or approved run record. | Choose one synthetic request or existing run with no customer secrets or live data. | Request reference, environment, owner, stop condition. |
| 2. Check route | APIM/gateway, app route, backend model/agent, tool/API route. | Confirm the request is expected to pass through the named gateway or app-only control point. | Gateway route, backend, tool/API path, bypass risk. |
| 3. Capture correlation | Header, trace ID, request ID, operation ID, session ID, user/app ID, or agent ID. | Verify where correlation is created and where it should propagate. | Correlation field, propagation points, blind spot. |
| 4. Query telemetry | Application Insights, Log Analytics, APIM logs, app logs, Foundry trace, or customer SIEM. | Query the agreed time window for the correlation value. | Signal present, no signal, partial signal, or diagnostic-only. |
| 5. Check policy decision | APIM policy result, Content Safety/Prompt Shields result, app policy, tool authorization, model/agent setting. | Look for block/allow/annotate/log/throttle/fallback behavior. | Expected behavior, observed behavior, owner. |
| 6. Check SOC route | Defender, Defender XDR, Sentinel, SOC queue, workbook, alert rule, or manual review route. | Confirm whether actionable signals route to a queue, alert, incident, or manual review owner. | Alert routed, no route, unsupported, or backlog item. |
| 7. Classify evidence | Customer records system. | Store only safe references and reviewer interpretation. | Accept, defer, route, block, reject, or diagnostic-only. |

## Runtime-path trace card

| Field | What to record |
|---|---|
| Scenario | Non-production request, environment, lifecycle state, request purpose, approved records location. |
| Caller and app | Caller identity, application/workload identity, authority boundary, unresolved permission gap. |
| Route | Ingress, gateway/APIM route, app-only route if applicable, backend model/agent, tool/API route, response path. |
| Policy decision points | Gateway policy, Prompt Shields, Content Safety, model/agent setting, app control, tool authorization, compensating review. |
| Telemetry | Log destination, trace/correlation field, propagation point, query owner, time window, retention/export owner. |
| Response route | Defender posture record, Defender XDR/Sentinel route, SOC queue, severity owner, monitoring window, escalation path. |
| Evidence status | Gateway-path proof, app-only evidence, model/agent evidence, SOC signal, diagnostic-only, planned, unsupported, or blocked. |
| Decision | Accept, defer, reject, route, block, or diagnostic-only with owner, target event, recheck condition, and limitation. |

## Verify gateway-path acceptance

The manifest shape is defined by
[`gateway-proof.schema.json`](../../contracts/gateway-proof.schema.json). Use
safe references only.

| Manifest field | Acceptance question |
|---|---|
| `pilot_agent_slug` / `environment_label` | Does the request belong to the scoped non-production path? |
| `gateway_reference` | Which customer-owned gateway or approved route is being reviewed? |
| `access_contract_reference` | Which caller identity, access contract, and authority boundary apply? |
| `backend_reference` | Which model, agent, service, or backend received the request? |
| `policy_reference` | Which policy decision point was expected to run? |
| `correlation_id` | Where was it created, where did it propagate, and who queried it? |
| `request_evidence_reference` | Which customer-held request record supports the trace without copying payloads? |
| `telemetry_evidence_reference` | Which customer-held telemetry record supports the route and decision? |
| `expected_policy_behavior` | What should the control do: block, deny, annotate, log, throttle, alert, or route? |
| `result` | Transport result only; customer reviewer still records security acceptance separately. |

## Threat-to-control map

| Risk | Inspection points | Candidate controls | Action and evidence |
|---|---|---|---|
| Direct prompt injection | User input, gateway policy, model input | Prompt Shields, gateway content-safety policy, app-side validation | Block/annotate/log/escalate; gateway or app trace plus reviewer. |
| Indirect prompt injection | Retrieved documents, connector output, tool response, model input | Prompt Shields for indirect attacks, tool-response scanning, source allow-list | Block response, quarantine source, require review; tool/app/model trace. |
| Harmful content | User input, model output, final response | Azure AI Content Safety, Foundry content filtering, gateway moderation | Block/redact/annotate/escalate; severity owner and telemetry. |
| PII or sensitive data leakage | Prompt, retrieval context, tool response, final output, logs | Data classification, masking, PII detection, DLP, retention controls | Block/redact/route; data owner and retention record. |
| Unsupported answer | RAG context, model output, final response, sampled operating record | Groundedness checks, evaluators, citations, human review | Annotate/hold/route; evaluation or operating-review reference. |
| Protected material | Model output, code/text generation, release evidence | Protected-material detection, manual review, policy evaluator | Block/hold/route; legal/evaluation owner. |
| Tool abuse | Tool call, parameters, tool response, local execution boundary | Tool-call inspection, task-adherence checks, allow-list, in-process policy | Deny/require approval/log; tool/API or app owner. |
| Unauthorized access | Gateway, backend, data service, identity provider | JWT validation, managed identity, RBAC, Conditional Access, private route | Deny closed/log/route; identity, platform, or SOC owner. |
| Cost or availability abuse | Gateway request, model call, token metrics, backend saturation | Token quota, rate limit, circuit breaker, budget alert, backend failover | Throttle/reject/fail over/alert; operating or FinOps owner. |
| Route bypass | Direct backend call, app-only route, private endpoint, tool shortcut | Network rules, gateway-only access, app telemetry, catalog reconciliation | Block/remediate/route; platform and app owner. |

## Control placement and diagnostic boundary

| Placement | What it can show | What it cannot show by itself |
|---|---|---|
| APIM AI Gateway policy | The approved gateway route can apply caller auth, quota, prompt/response safety, metrics, logging, routing, and backend resilience. | That every caller used the route, that local tool behavior was safe, or that model-native filters ran. |
| Azure AI Content Safety direct API | A component can classify a sample for configured categories or Prompt Shields behavior. | Gateway enforcement, approved route use, or production control effectiveness. |
| Foundry model or agent setting | Native model/agent filtering, Prompt Shields, tool-call or tool-response controls where supported. | Gateway policy execution, caller authorization, or external app/tool coverage. |
| Application or in-process control | Local prompt assembly, streaming, tool-call, approval, or policy checks invisible to the gateway. | Shared gateway enforcement unless correlated with gateway telemetry. |
| SOC or posture tool | Security findings, incident routing, posture gaps, and response ownership where enabled. | Request-level policy proof unless tied to a bounded correlation record. |

## Correlation and telemetry contract

| Join | Required question |
|---|---|
| Request to gateway | Which header, trace ID, request ID, subscription, app ID, user/session, or agent ID joins the request to gateway telemetry? |
| Gateway to app/backend | How does the correlation propagate to app, model/agent, backend, and tool/API logs? |
| Policy decision | Where is block/allow/annotate/log/throttle/fallback visible, and who owns the query? |
| SOC route | Which alert, incident, queue, or playbook receives runtime-security signals? |
| Retention | Which log store, retention/export/deletion/hold rule, and records owner apply? |
| Review | Which reviewer checked which source, time window, expected signal, and blind spots? |

Planned telemetry, empty logs, or a correlation field name are not enough. Record
the expected signal, checked scope, permissions, time range, source, query owner,
and reviewer decision.

## Query placeholders

Replace placeholder field names with the customer's schema. Do not copy raw log
rows, prompts, outputs, endpoints, or tenant identifiers into this repository.

### Application Insights / Log Analytics request trace

```kusto
let correlationId = "<correlation-id-placeholder>";
let lookback = 2h;
union isfuzzy=true requests, traces, dependencies, customEvents
| where timestamp > ago(lookback)
| where tostring(operation_Id) == correlationId
    or tostring(customDimensions["correlation_id"]) == correlationId
    or tostring(customDimensions["request_id"]) == correlationId
| project timestamp, itemType, name, resultCode, success, operation_Id,
          cloud_RoleName, target, customDimensions
| order by timestamp asc
```

### APIM or gateway policy signal

```kusto
let correlationId = "<correlation-id-placeholder>";
AzureDiagnostics
| where TimeGenerated > ago(2h)
| where CorrelationId == correlationId
    or requestId_s == correlationId
    or tostring(properties_s) has correlationId
| project TimeGenerated, Resource, OperationName, responseCode_d,
          backendUrl_s, policyName_s, properties_s
| order by TimeGenerated asc
```

### Security or SOC route signal

```kusto
let correlationId = "<correlation-id-placeholder>";
SecurityAlert
| where TimeGenerated > ago(24h)
| where tostring(ExtendedProperties) has correlationId
    or tostring(Entities) has correlationId
| project TimeGenerated, AlertName, Severity, ProviderName, SystemAlertId,
          ExtendedProperties, Entities
| order by TimeGenerated asc
```

If the customer uses Sentinel incidents, Defender XDR advanced hunting, or a
different SIEM table, keep the same shape: time window, correlation value,
source table, expected signal, reviewer, and limitation.

## Signal result states

| State | Meaning | Required next action |
|---|---|---|
| Signal present | The expected telemetry and policy/SOC signal appears in the scoped time window. | Reviewer decides whether the claim is accepted for this path. |
| No signal | Query ran but the expected event is absent. | Route to telemetry, gateway, app, or SOC owner with recheck condition. |
| Partial signal | Some route evidence exists, but policy decision, backend/tool trace, or SOC route is missing. | Accept only the observed claim; route the missing claim. |
| Diagnostic-only | Evidence comes from a component test, prepared prompt, or direct API check, not the runtime path. | Do not use as gateway/path proof. |
| Alert routed | Actionable signal reached alert, incident, queue, workbook, or manual review route. | Confirm severity owner, SLA, and response process. |
| Unsupported route | Selected feature does not cover the workload, region, modality, route, or service. | Route to alternate control or mark unsupported. |
| Blocked evidence handling | Evidence cannot be retained, reviewed, or referenced safely. | Stop until customer records and retention route exist. |

## SOC and response route

| Field | What to record |
|---|---|
| Posture source | Defender for Cloud AI posture record or explicit gap. |
| Detection route | Defender XDR, Sentinel analytic rule/workbook, customer SIEM, or manual review route. |
| Queue/playbook | SOC queue, incident type, severity owner, SLA, monitoring window, and escalation contact. |
| Stop condition | What condition blocks release, pauses operation, or routes to incident/change process. |
| Feedback loop | Which owner receives remediation, threshold tuning, route change, or evaluation backlog. |

## Lab capture fields

Every S6 lab record should capture the actual check, not just the intended
control.

| Field | Why it matters |
|---|---|
| Request/run reference | Keeps the review bounded to one non-production request or read-only trace. |
| Correlation value | Lets the reviewer reproduce the telemetry join. |
| Query source and time window | Prevents "no signal" from being confused with the wrong log source or period. |
| Expected signal | States what should appear before the query is run. |
| Actual signal state | Signal present, no signal, partial signal, diagnostic-only, alert routed, unsupported, or blocked. |
| Policy decision observed | Block, allow, annotate, log, throttle, fallback, or no decision observed. |
| SOC/retention result | Confirms whether the signal can be operated and retained. |
| Reviewer decision | Accept, defer, route, block, reject, or diagnostic-only. |

## Hard stops

| Hard stop | Why it blocks acceptance |
|---|---|
| No approved records location | Evidence cannot be retained or reviewed safely. |
| No route owner | Runtime path cannot be interpreted or remediated. |
| No correlation propagation | Request cannot be tied to telemetry or policy decision. |
| No telemetry query owner | Evidence cannot be independently reviewed. |
| No SOC route for actionable signals | Runtime events cannot be operated. |
| No retention/export/deletion owner | Evidence handling is unowned. |
| App-only control mislabeled as gateway proof | The claim overstates what the evidence shows. |
| Direct diagnostic mislabeled as enforcement | Component behavior is being treated as path proof. |
| Unsupported Prompt Shields or feature scope | The selected control may not apply to the route, language, modality, region, or service. |

## Boundary note

S6 accepts or routes runtime-path evidence for the reviewed non-production path
only. It changes no traffic or product configuration and approves no production
use.

## Related references

- [Evaluation technical decisions](../s7-evaluation/technical.md): downstream
  release-assurance inputs.
- [Operating and measurement decisions](../s10-operate-measure/technical.md):
  operating telemetry and alerting.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
