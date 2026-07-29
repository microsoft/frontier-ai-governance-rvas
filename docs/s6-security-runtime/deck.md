# S6 · Runtime Path Evidence & Response

**Facilitator deck**

Microsoft default: **Azure API Management AI Gateway, Azure AI Content Safety
Prompt Shields, Defender for Cloud AI posture, Defender XDR, Sentinel,
Application Insights, and Azure Monitor**.

Concrete decision: **Can this non-production request be traced through the
expected runtime path, policy decision points, telemetry, SOC route, and
retention process?**

---

## Runtime path, not product label

- Do not accept "APIM is enabled" or "Content Safety is enabled" as proof.
- Trace one caller, one app, one route, one backend, one tool/API path, one
  response path, and one correlation contract.
- The output is a runtime-path acceptance package, not deployment or production
  approval.

Note:
Start with the path the request actually follows. Product names come second.

---

## Trace the reviewed request

![Runtime-path acceptance requires correlation across request, route, telemetry, reviewer, and response ownership. Diagnostics stay separate from acceptance proof.](../assets/diagrams/s6-security-runtime-correlation-flow.svg)

- Caller identity and workload identity.
- Gateway/APIM or app-only route.
- Backend model/agent and tool/API route.
- Policy decision point and response path.
- Telemetry destination, correlation field, SOC route, retention owner.

Note:
Every acceptance decision should be able to point to this trace.

---

## Gateway proof vs diagnostic

- Gateway-proof package: safe manifest references plus customer telemetry
  correlation and reviewer decision.
- Transport result: request completed, failed, or was blocked; not a security
  decision by itself.
- Diagnostic: direct Content Safety, Prompt Shields, prepared prompt, or
  component smoke test.
- App-only evidence: valid only for the app boundary, not a gateway claim.

Note:
Do not let diagnostic evidence become a production or gateway-proof claim.

---

## Control placement layers

| Layer | Example controls |
|---|---|
| Identity/network | Entra, JWT, managed identity, RBAC, Conditional Access, private route. |
| Gateway | APIM policy, quota, content safety intent, token metrics, diagnostics, backend routing. |
| Model/agent | Foundry/model safety settings, Prompt Shields, content filtering, trace. |
| App/in-process | Prompt assembly, streaming, tool approval, local policy, task adherence. |
| Tool/API | Tool-call inspection, tool-response scanning, least-privilege operation boundary. |
| SOC/operations | Defender posture, XDR/Sentinel, queue, playbook, alert owner, retention. |

Note:
Ask where the control inspects, what action it takes, and what telemetry proves
that action.

---

## Threat-to-control map

- Direct prompt injection: inspect user input/gateway/model input.
- Indirect prompt injection: inspect retrieved documents, connector output, tool
  response.
- Harmful content: inspect input, model output, final response.
- Sensitive data leakage: inspect prompt, context, response, logs.
- Unsupported answers: inspect grounding, citations, evaluator or sampled trace.
- Tool abuse: inspect tool call, parameters, response, local execution boundary.
- Unauthorized access: inspect gateway, backend, identity provider, data service.
- Cost/availability abuse: inspect gateway, model call, token metrics, backend.

Note:
Every risk needs an owner, action, telemetry source, limitation, and hard stop.

---

## Gateway-proof acceptance package

Use safe references for:

- environment and scoped request;
- gateway route and access contract;
- backend model/agent/service;
- policy reference and expected behavior;
- correlation ID;
- request evidence reference;
- telemetry evidence reference;
- transport result;
- customer reviewer decision and limitation.

Note:
The manifest is evidence input. Acceptance is a separate customer reviewer
decision.

---

## Retention and evidence handling

- Runtime logs.
- Alert and incident records.
- Diagnostic notes.
- Decision references.
- Export, deletion, discovery, and hold expectations.
- Evidence owner and approved records location.

Note:
Never copy raw prompts, outputs, logs, policies, endpoints, incident payloads, or
tenant details into this repository.

---

## Failure modes and hard stops

- No approved records location.
- No route owner or reviewer.
- No correlation propagation.
- No telemetry query owner.
- No SOC route for actionable signals.
- No retention/export/deletion owner.
- App-only control mislabeled as gateway proof.
- Direct diagnostic mislabeled as enforcement.
- Gateway blind to local tool-response or app context.
- Unsupported Prompt Shields or product capability scope.

Note:
Defer when fixable with owner and accepted-when condition. Block when evidence
cannot be handled safely.

---

## Decision artifact and handoff

Decision options:

- accept runtime-path evidence;
- defer with owner, accepted-when condition, and target event;
- reject unsafe or unsupported path;
- route to platform, gateway, app, identity, SOC, observability, data, legal, or
  records owner;
- block until safe evidence handling is possible;
- diagnostic-only when useful but not runtime-path proof.

Note:
Close with the acceptance package and backlog, not a meeting summary. S6 changes
no tenant policy, deploys no control, proves no production enforcement, and
approves no production use.
