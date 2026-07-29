# S6 · Security Runtime Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Confirm runtime-control availability in the
    [Governance capability guide](../reference/governance-capability-guide.md).

This page explains S6's evidence boundary. Use [S6 Prepare](index.md) for the
customer validation steps.

## The runtime path is the evidence unit

Runtime assurance is not a product label. Reviewers need to trace one request
through the selected path: caller, app, gateway or app-only route, backend
model/agent, tool/API route, response path, telemetry, SOC route, and records
location.

The useful question is:

> Did this request travel through the expected path, did the expected control
> points see it, and did a named customer reviewer accept the interpretation?

## Gateway evidence is different from a component diagnostic

A direct call to a Content Safety endpoint can diagnose that component. It cannot
prove the agent request used the customer gateway, access contract, backend, or
policy. Prompt Shields tests, prepared prompts, and direct component smoke tests
are diagnostic unless they are tied to the approved runtime path and accepted by
customer reviewers.

The S6 artifact is a
[`gateway-proof`](../../contracts/gateway-proof.schema.json) manifest from the
gateway adapter. It holds safe references and a correlation identifier, not raw
payloads, endpoints, policies, logs, or incident content.

## Correlation is a contract, not just a field

![Runtime-path acceptance requires correlation across request, route, telemetry, reviewer, and response ownership. Diagnostics stay separate from acceptance proof.](../assets/diagrams/s6-security-runtime-correlation-flow.svg)

A `correlation_id` is useful only when the customer knows where it is created,
where it propagates, which sources record it, which query finds it, which time
window applies, which blind spots remain, and who accepts the result.

For delivery, keep six questions separate:

1. Did the request complete?
2. Does the correlation appear in approved telemetry?
3. Does the route match the approved path?
4. Did the expected policy decision point run or fail closed?
5. Does the SOC or response route receive the right signal?
6. Who accepted the interpretation and retention boundary?

## Control placement comes before product claims

Runtime safety remains layered. A control may inspect user input, gateway
traffic, model input, retrieved content, tool calls, tool responses, final
output, telemetry, or sampled operating records. The action may be block, deny,
annotate, redact, log, throttle, fail over, escalate, hold for review, or route
to another owner.

Keep these distinctions visible:

- APIM AI Gateway policy can enforce a shared route, but may not see local
  prompt assembly, streaming behavior, tool-response context, or in-process
  approval decisions.
- Foundry model or agent controls can inspect model/agent behavior where
  supported, but do not prove gateway policy execution.
- App-only controls can be valid controls when honestly recorded as app-only;
  they are not gateway proof.
- Tool-call and tool-response controls are separate from final-response safety.
- SOC or posture tooling can route findings and incidents, but request-level
  proof still needs correlation to the bounded path.

## Threats need inspection points and actions

Runtime records should connect each risk to where it is inspected, what action
is taken, which telemetry proves the action, and who reviews it.

| Risk | Inspection point | Typical action |
|---|---|---|
| Direct prompt injection | User input, gateway policy, model input | Block, annotate, log, escalate. |
| Indirect prompt injection | Retrieved documents, connector output, tool response | Block response, quarantine source, require human review. |
| Harmful content | User input, model output, final response | Block, redact, annotate, escalate by severity. |
| PII or sensitive data leakage | Prompt, context, tool response, model output, logs | Redact, block, route to data owner. |
| Unsupported or hallucinated answer | RAG context, model output, final response, sampled trace | Annotate, hold, route to evaluation owner. |
| Tool abuse or off-task action | Tool call, parameters, tool response, local execution boundary | Deny, require approval, log, route to tool/API or app owner. |
| Unauthorized access | Gateway, backend, identity provider, data service | Deny closed, log, route to identity/platform/SOC owner. |
| Cost or availability abuse | Gateway request, model call, token metrics, backend saturation | Throttle, reject, fail over, alert operating owner. |

If the record says only that a product is enabled, ask what it inspected, what it
did, what telemetry shows it, and who accepted the result.

## Acceptance requires a customer reviewer

The adapter can produce a request result and safe references. It cannot interpret
customer telemetry or decide that enforcement occurred. Acceptance belongs to
named customer platform and security reviewers who can inspect the customer
records and record the decision in the approved records system.

Typical outcomes:

- **Accept** when route, control point, telemetry, correlation, SOC/response, and
  retention are reviewable.
- **Defer** when a gap has an owner and accepted-when condition.
- **Reject** when the runtime path cannot meet the required control expectation.
- **Route** when another owner must decide first.
- **Block** when authorization, records location, safe evidence handling, or
  ownership is missing.
- **Diagnostic-only** when the evidence is useful but not runtime-path proof.

## SOC route and retention are part of runtime readiness

Runtime security is incomplete if blocked prompts, suspicious tool calls,
unauthorized access, or model-risk alerts cannot reach a monitored queue with
severity owner, monitoring window, escalation route, stop condition, and records
owner.

Retention also matters. The record should say where runtime logs, alert records,
diagnostic notes, and decision references live; which export, deletion, or hold
expectations apply; and which owner can preserve investigation references.

## Material changes reopen acceptance

Re-review the runtime-path package when any material field changes: route,
gateway policy, model/agent setting, prompt assembly, tool schema, tool-response
handling, identity, scopes/RBAC, telemetry destination, correlation field, SOC
route, severity threshold, retention policy, owner, environment, or lifecycle
state.

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
for the cross-cutting runtime-enforcement route and current Microsoft safety,
security, identity, gateway, and observability sources.
