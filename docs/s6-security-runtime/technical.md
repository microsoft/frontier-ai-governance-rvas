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

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Gateway route | Azure API Management API/product/policy/backend, Entra/JWT validation, correlation ID behavior |
| Safety controls | Azure AI Content Safety Prompt Shields/configuration, Foundry safety settings where applicable |
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
