# S10 · In-Process Tool-Call Controls: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Use Agent Governance Toolkit (AGT) only as one candidate implementation when gateway controls cannot make the needed in-process tool-call decision. AGT status and limitations can change; verify official docs, customer code ownership, and support posture before assessment.

## Microsoft default

Default to Azure API Management/gateway controls for route-level authentication, policy, quota, and telemetry. Choose an in-process tool-call policy check only when a real allow/deny/approval/route decision must happen immediately before a local tool call and the customer owns the code path. AGT is an implementation candidate for assessment, not a mandatory adoption target.

## Decision tree

1. **If the gateway can make the meaningful decision**, use gateway-only and send evidence to the runtime-assurance owner.
2. **If the decision requires prompt/tool/user context inside the process**, assess an AGT-style `govern()` boundary with engineering ownership.
3. **If the action is high-authority**, consider defense in depth: gateway plus in-process decision, with correlation ownership.
4. **If there is no local tool decision point or delegated authority**, record **not applicable**, stop S10 work, and route to operating review, portfolio governance, or the customer backlog.

| Boundary | Use when | Accepted when... |
|---|---|---|
| Gateway-only | API Management/governance hub is the control point | route, policy, telemetry, and owner are recorded in the runtime-control evidence |
| In-process AGT-style check | local tool call needs immediate allow/deny/approval | code owner, policy owner, approval route, audit record, and support caveat are recorded |
| Defense in depth | high-authority action needs both controls | gateway and in-process decisions have correlation and conflict-review owners |
| Not applicable | no real in-process control point exists | rationale and alternate tool/API, runtime, operating, portfolio, or customer-backlog path are recorded |

## Checkpoint taxonomy

| Checkpoint | Decision context | Typical owner |
|---|---|---|
| Pre-tool selection | Candidate tool/action list, user/session context, task intent, authority limit. | Policy owner and engineering owner. |
| Pre-parameter binding | Proposed parameters, data class, target system, identity mode, prohibited fields. | Data/security owner and code owner. |
| Pre-execution | Final tool/action, resource target, approval requirement, break-glass condition, correlation ID. | Runtime/control owner. |
| Post-tool response | Returned status/data class, unexpected fields, failure mode, redaction/minimization route. | Engineering and data owner. |
| Pre-final response | User-visible content, sensitive data, action summary, required disclosure or hold-for-review. | Product/runtime owner. |
| Human approval | Reviewer role, approval scope, expiry, escalation route, audit retention. | Business/process owner. |

## Policy decision event shape

Use this as a reference shape for a customer-owned event design. It is not a
deployment instruction.

```json
{
  "eventType": "in_process_policy_decision",
  "eventVersion": "1.0",
  "decisionUtc": "2026-01-01T00:00:00Z",
  "correlationId": "operation-id-placeholder",
  "agentRef": "agent-registry-id-placeholder",
  "sessionRef": "session-ref-placeholder",
  "checkpoint": "pre_execution",
  "tool": {
    "name": "approved-tool-name",
    "version": "tool-schema-version-placeholder",
    "targetRef": "target-system-placeholder"
  },
  "policy": {
    "policyId": "policy-id-placeholder",
    "policyVersion": "policy-version-placeholder"
  },
  "decision": "approve",
  "allowedOutcomes": ["allow", "deny", "approve", "escalate", "defer", "break_glass"],
  "reasonCode": "human-approval-required",
  "reviewerRef": "reviewer-role-placeholder",
  "downstreamOutcomeKnown": false,
  "evidenceRef": "customer-record-reference"
}
```

Decision values should be explicit:

| Decision | Meaning |
|---|---|
| `allow` | Policy permits the action without additional human approval. |
| `deny` | Policy blocks the action and records a reason. |
| `approve` | A named reviewer or role approved the action. |
| `escalate` | A higher authority must decide before execution. |
| `defer` | Missing context prevents a safe decision. |
| `break_glass` | Emergency path invoked under a separately governed procedure. |

## Gateway correlation and conflict handling

| Case | Record |
|---|---|
| Gateway allows, in-process denies | Local policy reason, gateway route reference, conflict reviewer, user-facing behavior, runtime and operating evidence route. |
| Gateway denies, in-process allows | Gateway denial wins for runtime; local policy owner reviews why the local rule was less restrictive. |
| Gateway not in path | Reason gateway cannot observe or decide, compensating control, telemetry/correlation route. |
| In-process audit missing | Treat as control evidence gap; do not claim in-process decision effectiveness. |
| Correlation mismatch | Record operation/trace mismatch, affected time range, owner, and investigation route. |

## Tamper-evidence boundary

Local hash-chain consistency shows only that a copied record is internally
consistent. It is not immutable proof. A production design that needs tamper
evidence should record external signed storage, append-only retention, access
control, key owner, time-source assumption, export route, and reviewer cadence.
S10 records the need and owner; it does not configure or certify storage.

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Gateway alternative | Azure API Management API/product/policy/backend and telemetry record |
| In-process applicability | customer architecture/code owner, tool-call location, delegated authority, policy decision point |
| AGT readiness | AGT version/status, official limitation note, installation assessment backlog |
| Audit/tamper evidence | in-process audit record design, signed immutable external storage plan, retention owner |
| Runtime correlation | correlation ID plan, reviewer, and retention location |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Applicability | the team can point to the exact pre-tool decision and delegated authority it governs | Engineering owner |
| Boundary choice | gateway-only, in-process, defense-in-depth, or not-applicable is selected with rationale | Runtime owner |
| Audit need | simulator, audit, or signed immutable external record requirement is chosen with owner | Security/compliance |
| Implementation backlog | any AGT assessment is routed as a separate customer code/security task | Customer engineering |
| Hard skip | no real in-process boundary exists, **not applicable** is recorded, and no AGT action is opened | Operating, portfolio, or customer backlog owner |

## Boundary note

S10 authorizes only an applicability decision or separate engineering assessment; it installs nothing and changes no policy.

## Related references

- [S10 Concepts](concepts.md): offline Preview boundary, hash-chain consistency, and tamper-evidence requirements.
- [S5 technical decisions](../s5-tool-api-governance/technical.md): tool publication and gateway boundary.
- [S6 technical decisions](../s6-security-runtime/technical.md): runtime correlation.
- [Platform technical guide](../reference/platform-technical-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
