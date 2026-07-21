# S6 · Security Posture & Runtime Assurance: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Runtime safety, threat-protection, identity,
    gateway, and telemetry capabilities change over time. Verify current
    product status, availability, and limitations in the
    [Platform technical guide](../reference/platform-technical-guide.md) and
    official product docs before delivery.

S6 decides where runtime safety controls are enforced, how threat response is
routed, and what correlation evidence supports a gateway decision. It changes
no production traffic or product configuration; implementation remains with the
customer's security, platform, SOC, identity, and change processes.

![S6 illustrative layered-runtime pattern: identity and network, gateway, model or agent, and tool boundaries can produce correlated safe evidence for a customer-owned acceptance decision. A direct diagnostic remains distinct from gateway-path proof.](../assets/diagrams/s6-security-runtime-correlation-flow.svg)

## Decision 1: Where are runtime safety controls enforced?

Choose against the streaming and latency budget, where prompts and outputs are
inspected, and how untrusted input is covered. Verify current Azure AI Content
Safety feature status, including Prompt Shields, groundedness detection, and
protected-material detection, before relying on an option.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Gateway enforcement** | Traffic already passes through the approved gateway and policy needs one shared inspection point for untrusted input | Adds gateway latency and may not see application-only context | Strong shared boundary; record route, policy owner, and evidence retention |
| **In-application enforcement** | The app has the needed context, prompt assembly, or output handling before streaming to users | Harder to standardize; depends on each app team to implement and evidence | Record app owner, inspection points, and how decisions are logged |
| **Defense in depth** (gateway and application) | Higher-risk workloads where boundary and app-context controls should reinforce each other | More owners, latency, and correlation work | Strongest setup; record which control decides what and how conflicts are reviewed |
| **Deferred / diagnostic only** | Capability availability, latency, or route coverage is not ready for a control decision | A component check is not gateway enforcement evidence | Record the gap, owner, target date, and dependency before S7 or rollout |

### Azure implementation track: layer controls and prove only the path reviewed

**Control chain to decide.** Assign each relevant risk to an identity/network,
gateway, model or agent, and tool-call boundary. For example, a gateway can
enforce selected route-level identity, quota, or input policy; model/agent
features can address supported safety or tool-use checks; and an application
boundary can decide local tool use. Name which layer blocks, annotates, logs, or
escalates each risk and who resolves conflicts between layers.

**Failure modes to test in the customer design.** A direct component call may
pass while the gateway path is unproven; a gateway may not see local tool calls;
tool responses can be untrusted inputs; correlation can be dropped between
components; a safety result can be logged without an owned response; and
over-retaining prompts or responses can create a separate privacy risk.

**Evidence and record.** Retain safe references to the approved non-production
route, access contract, backend and policy, correlation identifier, request
record, telemetry record, reviewers, and decision. Keep policy expectations
separate from observed behavior. Current capability status for prompt, tool,
tool-response, or groundedness controls must be verified before any is relied
upon.

**Backlog sequence.** Close route, identity, telemetry, and reviewer gaps before
asking S7 to rely on a gateway proof. Send policy, detection, and incident-route
work to the security/platform process; send retention and operating alert work
to S11. A passing manifest is transport evidence until customer reviewers accept
the correlation.

## Decision 2: How are threat detection and response routed?

Choose against existing SOC maturity, incident ownership, and response SLAs.
Verify current Microsoft Defender for Cloud AI workload threat-protection,
Defender XDR, and integration availability before recording the decision.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Defender for Cloud plus Defender XDR / SOC integration** | The customer already operates Defender-based triage, incident queues, and response playbooks | Depends on enabled plans, coverage, licensing, and SOC readiness | Route findings to existing incident ownership, severity, and SLA records |
| **Gateway telemetry-based alerting** | The gateway is the strongest evidence source and the SOC needs alerts tied to route or policy decisions | May miss workload-internal signals; alert quality depends on telemetry design | Record alert owner, thresholds, escalation route, and retained correlation evidence |
| **Custom detection pipeline** | The customer has a mature data platform or regulated detection workflow needing bespoke joins | Highest engineering and maintenance burden | Treat as customer-owned security engineering backlog with response and audit owners |
| **Manual review only for pilot** | Early non-production pilot where automated response is not yet in scope | Not scalable and not a production response model | Record as a temporary adoption gap with owner, review cadence, and escalation path |

## Decision 3: What correlation evidence proves runtime assurance?

Choose against the ability to tie one request to the enforced control decision
that governed it, and against evidence-retention requirements. Verify current
Entra/JWT, gateway, and telemetry capabilities before relying on an evidence
route.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Gateway correlation record** (Entra/JWT, correlation ID, policy decision, telemetry reference) | The gateway can authenticate, assign or preserve a correlation ID, and log the control decision | Proves only the reviewed gateway path, not every downstream component | Best S6 proof; retain safe references and the reviewer acceptance decision |
| **Application correlation record** | The app can bind user/workload identity, prompt context, and safety decisions better than the gateway | Does not prove the approved gateway path by itself | Useful supporting evidence; pair with gateway proof when gateway enforcement is claimed |
| **Defense in depth correlation** | Both gateway and app controls must be reviewable for higher-risk workloads | Requires consistent IDs, retention, and ownership across teams | Strongest evidence; record the join key, retention owner, and conflict-review rule |
| **Insufficient correlation** | IDs, telemetry, or retention are missing or disputed | Transport success cannot be accepted as enforcement evidence | Record blocked or deferred status, owner, and S7/S12 impact |

## Decisions made & adoption progress

S6 advances the **S0 maturity baseline** for security/runtime assurance and
feeds the **S12 portfolio** with runtime evidence, response ownership, and the
gateway proof that S7 can reference.

| Adoption stage | What "done" looks like at S6 |
|---|---|
| **Decided** | Runtime safety placement, threat-response route, and gateway-correlation evidence are selected with rationale and verified-status caveats |
| **Backlogged** | Control, telemetry, SOC, identity, retention, and route gaps are assigned to customer-owned processes with owners |
| **In adoption** | Accepted runtime assurance evidence is retained in customer records and later S7/S9/S11/S12 work reconciles the proof |

Record the choices, alternatives, rationale, and adoption stage in
`labs/s6-security-runtime/templates/technical-decision-record.template.md`.
The record captures the S6 decision; the kit remains offline.

## Related references

- [S6 Concepts](concepts.md): gateway proof, correlation, layered runtime safety, and backlog routing.
- [Platform technical guide](../reference/platform-technical-guide.md): platform boundary and verify-status context.
- [Governance capability guide](../reference/governance-capability-guide.md): runtime-control and governance capability context.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md): current safety, security, identity, gateway, and observability sources.
