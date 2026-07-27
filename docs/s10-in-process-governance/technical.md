# S10 · Conditional In-Process Tool-Call Governance: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Use Agent Governance Toolkit (AGT) only as one candidate implementation when gateway controls cannot make the needed in-process tool-call decision. AGT status and limitations can change; verify official docs, customer code ownership, and support posture before assessment.

## Microsoft default

Default to Azure API Management/gateway controls for route-level authentication, policy, quota, and telemetry. Choose an in-process tool-call policy check only when a real allow/deny/approval/route decision must happen immediately before a local tool call and the customer owns the code path. AGT is an implementation candidate for assessment, not a mandatory adoption target.

## Decision tree

1. **If the gateway can make the meaningful decision**, use gateway-only and send evidence to S6.
2. **If the decision requires prompt/tool/user context inside the process**, assess an AGT-style `govern()` boundary with engineering ownership.
3. **If the action is high-authority**, consider defense in depth: gateway plus in-process decision, with correlation ownership.
4. **If there is no local tool decision point or delegated authority**, record **not applicable**, stop S10 work, and route to S11/S13 or the customer backlog.

| Boundary | Use when | Accepted when... |
|---|---|---|
| Gateway-only | API Management/governance hub is the control point | route, policy, telemetry, and owner are recorded in S6 |
| In-process AGT-style check | local tool call needs immediate allow/deny/approval | code owner, policy owner, approval route, audit record, and support caveat are recorded |
| Defense in depth | high-authority action needs both controls | gateway and in-process decisions have correlation and conflict-review owners |
| Not applicable | no real in-process control point exists | rationale and alternate S5/S6/S11/S13 or customer-backlog path are recorded |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Gateway alternative | Azure API Management API/product/policy/backend and telemetry record |
| In-process applicability | customer architecture/code owner, tool-call location, delegated authority, policy decision point |
| AGT readiness | AGT version/status, official limitation note, installation assessment backlog |
| Audit/tamper evidence | in-process audit record design, signed immutable external storage plan, retention owner |
| Runtime correlation | S6 correlation ID plan, reviewer, and retention location |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Applicability | the team can point to the exact pre-tool decision and delegated authority it governs | Engineering owner |
| Boundary choice | gateway-only, in-process, defense-in-depth, or not-applicable is selected with rationale | S6 runtime owner |
| Audit need | simulator, audit, or signed immutable external record requirement is chosen with owner | Security/compliance |
| Implementation backlog | any AGT assessment is routed as a separate customer code/security task | Customer engineering |
| Hard skip | no real in-process boundary exists, **not applicable** is recorded, and no AGT action is opened | S11/S13 or customer backlog owner |

## Boundary note

S10 authorizes only an applicability decision or separate engineering assessment; it installs nothing and changes no policy.

## Related references

- [S10 Concepts](concepts.md): offline Preview boundary, hash-chain consistency, and tamper-evidence requirements.
- [S5 technical decisions](../s5-tool-api-governance/technical.md): tool publication and gateway boundary.
- [S6 technical decisions](../s6-security-runtime/technical.md): runtime correlation.
- [Platform technical guide](../reference/platform-technical-guide.md).
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
