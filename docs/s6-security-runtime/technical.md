# S6 · Security Posture & Runtime Assurance: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Azure API Management AI Gateway, Azure AI Content Safety Prompt Shields, Defender for Cloud AI posture, Defender XDR, Sentinel, Application Insights, and related telemetry capabilities vary by tenant, license, region, workload, and configuration. Verify official docs and customer status before delivery.

## Microsoft default

Default to Entra-authenticated Azure API Management AI Gateway or approved customer gateway routes, Azure AI Content Safety Prompt Shields where supported, Defender for Cloud AI posture, Defender XDR/Sentinel response routes, and Application Insights/Azure Monitor correlation. Application controls are added when the gateway cannot see the needed context.

![S6 illustrative layered-runtime pattern: identity and network, gateway, model or agent, and tool boundaries can produce correlated safe evidence for a customer-owned acceptance decision. A direct diagnostic remains distinct from gateway-path proof.](../assets/diagrams/s6-security-runtime-correlation-flow.svg)

## Decision tree

1. **If traffic uses an approved gateway**, place shared runtime policy, auth, quota, logging, and safety checks there.
2. **If prompt assembly, streaming, tool response, or local action context is only inside the app**, add in-application controls and correlate them with gateway evidence.
3. **If Microsoft Defender/Sentinel routes already handle AI incidents**, attach AI findings to the existing SOC route.
4. **If correlation cannot tie identity, route, policy decision, and telemetry**, hold runtime assurance and backlog the gap.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Runtime safety placement | Azure API Management AI Gateway + Azure AI Content Safety where supported | app-only context requires in-application enforcement |
| Threat response | Defender for Cloud, Defender XDR, Microsoft Sentinel, SOC playbooks | customer SIEM/SOC is authoritative and can ingest the signal |
| Correlation proof | Entra/JWT identity + gateway correlation ID + Application Insights/Azure Monitor record | app correlation is the control of record and gateway claim is not made |

### Runtime guardrail taxonomy

Use this taxonomy to decide where each risk is inspected and which owner accepts
the action. Product names are not proof of coverage; each row needs a route,
owner, correlation method, and feature-availability caveat.

| Risk | Typical inspection points | Candidate controls | Action to record |
|---|---|---|---|
| Hallucination or unsupported answer | Model output, RAG context, final response, sampled production evaluation | Groundedness checks, evaluators, human review, source citation policy | Annotate, block, route to S7 evaluation, or open operating-review hypothesis. |
| Direct prompt injection | User input, gateway policy, model input | Prompt Shields, gateway content-safety policy, app-side prompt validation | Block, annotate, log, escalate to SOC or safety reviewer. |
| Indirect prompt injection | Retrieved documents, tool responses, connector output, model input | Prompt Shields for indirect attacks, tool-response scanning, allow-list/source review | Block tool response, quarantine source, require human review, route to S5/S10. |
| PII or sensitive data leakage | Prompt, retrieval context, tool response, model output, logs | Data classification, masking, PII detection, DLP, retention controls | Block, redact, annotate, route to S2 records/compliance owner. |
| Harmful content | User input, model output, final response | Azure AI Content Safety, Foundry content filtering, gateway moderation | Block, annotate, log, escalate according to severity. |
| Protected material | Model output, code/text generation, release evidence | Protected-material detection, manual review, policy-specific evaluator | Block, hold release, route to S7 or legal/compliance process. |
| Tool abuse or off-task action | Tool call, tool parameters, tool response, local execution boundary | Tool call inspection, task-adherence checks, allow-list, in-process policy, least-privilege API scopes | Deny call, require approval, log, route to S5/S10. |
| Cost or availability abuse | Gateway request, model call, token metrics, backend saturation | Token quota, rate limit, circuit breaker, budget alert, model backend failover | Throttle, reject, fail over, alert S11 operating/FinOps owner. |
| Unauthorized access | Gateway, backend, data service, identity provider | JWT validation, managed identity, RBAC, Conditional Access, private route | Deny closed, log, route to S1/S3/SOC owner. |

### Control placement and diagnostic boundary

The same safety engine can appear in several places. Record where the customer
expects it to operate and what later proof would show.

| Placement | What it can show | What it cannot show by itself |
|---|---|---|
| APIM AI Gateway policy | The approved gateway route can apply caller auth, quota, prompt/response safety, metrics, logging, and backend routing. | That every caller used the route, that downstream tool behavior was safe, or that model-native filters ran. |
| Azure AI Content Safety direct API | A component can classify a sample for configured categories or Prompt Shields behavior. | Gateway enforcement, approved route use, or production control effectiveness. |
| Foundry model or agent settings | Native model/agent content filtering, Prompt Shields, tool-call or tool-response controls where supported. | Gateway policy execution, caller authorization, or external app/tool coverage. |
| Application or in-process control | Local prompt assembly, streaming, tool-call, approval, or policy checks invisible to the gateway. | Shared gateway enforcement unless correlated with gateway telemetry. |
| SOC or posture tool | Security findings, incident routing, posture gaps, and response ownership where enabled. | Request-level policy proof unless tied to a bounded correlation record. |

### Layered guardrail model

Use this model when deciding whether runtime safety coverage is complete enough
for the reviewed path. Each layer can fail or be bypassed; the record should say
which next layer contains the risk and how the event is visible.

| Layer | What it controls | Typical failure action | Evidence to route |
|---|---|---|---|
| Identity and network | Who can reach the route and whether traffic can bypass approved private/gateway paths. | Deny closed, block route, or route to S1/S3. | Entra sign-in, gateway auth, private route record, NSG/firewall logs. |
| Gateway | Shared auth, quotas, prompt/response safety, logging, routing, backend resilience. | 403, 429, block/annotate, fallback, or alert. | APIM policy reference, gateway log, correlation ID, token metrics. |
| Model | Native content filtering, protected material, Prompt Shields, groundedness where available. | Block, annotate, controlled error, or route to S7. | Foundry model/agent safety setting, trace, evaluation reference. |
| Agent and tools | Tool selection, tool parameters, tool response handling, task adherence, source trust. | Deny call, require approval, quarantine response, route to S5/S10. | Tool-call trace, allow-list, in-process audit, gateway/tool log. |
| Governance and operations | Alerting, incident route, retention, evaluation, drift review, threshold tuning. | Escalate, hold release, open remediation, update backlog. | S6 acceptance record, S7 evaluation, S11 operating review, SOC ticket. |

### Foundry content-filter intervention points

When Foundry-native controls are part of the design, record which intervention
points are enabled and which are unavailable or preview for the workload.

| Point | Review question |
|---|---|
| User input | Are user prompts inspected before model or agent processing, and how is a blocked prompt represented to the caller? |
| Tool call | Are proposed tool invocations inspected for off-task or unauthorized behavior before execution? |
| Tool response | Are retrieved documents, connector outputs, and API responses inspected for indirect injection or unsafe content before reuse? |
| Output | Are final responses inspected for harmful content, protected material, PII, or unsupported claims before delivery? |

For harmful-content filtering, record the categories, threshold owner, action
mode, exception path, and review cadence. For groundedness, protected-material,
PII, tool-call inspection, or task-adherence features, record product status and
fallback review if the feature is preview or unavailable.

### Runtime-control rollout checklist

| Phase | Minimum technical backlog item | Handoff |
|---|---|---|
| Baseline | Enable or record model content-filtering posture, gateway content-safety intent, token limits, logging, and managed identity use where supported. | Platform/security/identity. |
| Agent guardrails | Record Prompt Shields, indirect-injection coverage, tool-call/tool-response inspection, PII detection, and task-adherence applicability. | Security, agent owner, S5/S10. |
| Quality and groundedness | Record groundedness, protected material, risk/safety evaluations, and threshold owners. | S7 assurance owner. |
| Operations | Record alert rules, SOC route, telemetry correlation, threshold review, and monthly or release-based policy review. | S11 operating/SOC owner. |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Gateway route | Azure API Management API/product/policy/backend, Entra/JWT validation, correlation ID behavior |
| Safety controls | Azure AI Content Safety Prompt Shields/configuration, Foundry safety settings, gateway safety policy, app/in-process controls where applicable |
| Posture and detection | Defender for Cloud AI posture, Defender XDR incidents, Sentinel analytic rules/workbooks |
| Telemetry | Application Insights trace/request, Azure Monitor diagnostic settings, Log Analytics query, retention policy |
| Response route | SOC queue, severity/SLA rule, incident playbook, escalation owner |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Safety placement | each risk has a gateway, app, model/agent, or tool boundary owner and action type: block, annotate, log, or escalate | Security/platform |
| Threat response | Defender/Sentinel/SOC route, severity, SLA, reviewer, and escalation path are recorded | SOC owner |
| Correlation evidence | one reviewed request can tie identity, approved route, policy decision, telemetry record, and retention owner | Runtime assurance owner |
| Coverage gap | unsupported Prompt Shields, Defender, telemetry, or route coverage has owner, target date, and release impact | S13 portfolio owner |

## Boundary note

S6 accepts or routes runtime-assurance evidence for the reviewed path only; it changes no traffic or product configuration.

## Related references

- [S6 Concepts](concepts.md): gateway proof, correlation, layered runtime safety, and backlog routing.
- [S7 technical decisions](../s7-evaluation/technical.md): release assurance inputs.
- [S11 technical decisions](../s11-operate-measure/technical.md): operating telemetry and alerting.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
