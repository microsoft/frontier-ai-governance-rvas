# S6 · Security Runtime

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & what the customer keeps

The customer leaves with one reviewable runtime artifact: **a redacted gateway
proof for an approved non-production request.**

The proof is a gateway proof manifest that conforms to
[`contracts/gateway-proof.schema.json`](../../contracts/gateway-proof.schema.json).
It contains safe references and a `correlation_id`.

The adapter does not deploy a safety platform or prove a direct Content Safety
call. The customer platform and security owners must match the `correlation_id`
to gateway telemetry before they accept it as enforcement evidence.

Where a customer needs to map defence-in-depth before adoption, the
customer-owned runtime control matrix records the selected identity/network,
gateway, model/agent, and tool boundaries, along with response ownership and
evidence limits. It does not replace the accepted gateway proof.

### Implementation pathway

S6 produces a runtime-control backlog: accept, defer, or reject the proof;
remediate route, policy, or telemetry gaps; route safety work; or block
S7/S9/S11 dependencies until correlation is accepted.

Security reviewers may use Microsoft Defender for Cloud and AI security posture
capabilities for broader security and threat context where the customer has them
enabled. See [Defender AI security posture management](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-security-posture)
for product context. The S6 artifact is still the gateway proof and reviewed
correlation.

## 2. Prerequisites

- A deployed customer gateway with an approved non-production route and runtime policy.
- A customer operator who can supply authentication without recording it here.
- Customer-owned request and telemetry record locations.
- Named platform and security reviewers who can interpret the telemetry.

## 3. Why this session matters

Runtime evidence must show the path the agent used. S6 records a redacted
request correlation without changing production traffic. A component diagnostic
can troubleshoot part of the stack, but it does not prove the gateway path.

## 4. Co-delivery walkthrough

!!! warning "Report-only / audit-first"
    Do not run against production traffic. A component diagnostic is not
    gateway-path proof.

Review the [Technical decisions](technical.md) chapter first: it holds the content-safety, threat-detection, and gateway-correlation option menus and selection criteria this walkthrough decides between.

**Timebox:** 90 minutes. **Entry condition:** the customer has an approved
non-production gateway route, safe test scope and authentication handling,
customer record locations, and named platform, security, evidence, and decision
owners. Stop before the request if any of these are absent.

| Role | Workshop responsibility |
|---|---|
| Facilitator | Keeps the gateway-proof boundary, timebox, and decision wording; does not run the request or accept evidence. |
| Customer platform operator | Runs the approved gateway-path request using `labs/s6-security-runtime/runbook.md`. |
| Security reviewer / evidence owner | Matches the returned identifier with customer gateway telemetry and cites the approved records. |
| Customer decision owner | Accepts, rejects, or defers the proof and owns the S4 handoff. |

1. **Set the room and orient: 20 min.** The facilitator records the pilot
   question: **"Did this approved non-production request go through the approved
   gateway path with a correlation we can review, and which runtime-control
   decision does that evidence support?"** The customer confirms this run is
   non-production, the expected policy behavior, stop condition, and evidence
   locations. Ask: **"Which gateway route, policy, and runtime-control option are
   in scope?"** **"Who can interpret telemetry and accept this proof?"** **"What
   result makes us stop instead of guessing enforcement?"**
2. **Customer-operated gateway request: 30 min.** The platform operator performs
   the one request in the runbook. The facilitator observes the boundary without
   handling credentials or payloads. The customer records only safe references to
   the generated manifest, request record, telemetry record, and correlation
   identifier in its approved system. A direct component call is a separate
   diagnostic. It is not a substitute for the gateway request.
3. **Interpret together: 15 min.** The platform and security reviewers first
   separate the adapter transport result from the acceptance decision. Ask:
   **"Does the manifest match the gateway-proof contract?"** **"Does
   `correlation_id` appear in the approved gateway telemetry?"** **"Does the
   observed path support the expected policy behavior, or are we missing proof?"**
   Record the observed fact and reviewer interpretation. Do not copy prompts,
   responses, endpoint values, credentials, or telemetry. Use
   `labs/s6-security-runtime/templates/gateway-correlation-review.template.md` to
   structure the review in the customer records system.

   | Observed pattern | Decision |
   |---|---|
   | Conforming `pass` manifest and accepted telemetry correlation by both reviewers | Accepted gateway proof. |
   | `pass` manifest but missing or disputed telemetry correlation | Deferred or blocked; transport success is not enforcement evidence. |
   | `fail` manifest | Rejected or deferred with owner, target date, and reviewed scope. |
   | Unsafe route, production-only target, missing reviewer, or missing record location | Blocked; stop dependent assurance work. |
   | Direct Content Safety or component diagnostic only | Reference separately as a diagnostic; do not use as S6 gateway proof. |

   When runtime evidence informs a later governance decision, retain references
   to the bounded agent or workload, initiating context, request correlation,
   applicable tool or model version, policy decision, outcome category, and
   reviewer decision. These references support interpretation. They are not a
   telemetry schema or a requirement to retain raw event data.
4. **Customer decision: 15 min.** A proof is eligible for **accepted** only when
   the manifest conforms to `gateway-proof.schema.json`, has `result: "pass"`,
   contains the required safe references, and both customer platform and security
   reviewers accept the telemetry correlation. A `pass` without that acceptance
   is not enforcement evidence. A `fail`, missing correlation, or unresolved
   scope is rejected, deferred, or **blocked**. Do not convert it to a pass.
   The decision owner records the control state and review date in the customer
   system.
5. **Hand over: 10 min.** Read back the manifest reference, telemetry reference,
   correlation identifier, reviewer interpretation, decision reference, and next
   owner. Hand only an accepted `pass` gateway-proof reference to S4. The gateway
   proof remains the runtime artifact. Record the selected option, rationale,
   and adoption stage with
   `labs/s6-security-runtime/templates/technical-decision-record.template.md`.

**Blockers:** no approved non-production route, unsafe authentication handling,
missing telemetry reviewer or evidence location, production-only availability, or
an unresolved correlation. Record the safe stop point, owner, target date, and
impact on S4. Do not run a direct diagnostic or fabricate local evidence to
continue.

## 5. Verification & evidence capture

- [ ] The manifest validates against `gateway-proof.schema.json`.
- [ ] It has `result: "pass"` and references the approved gateway, access
  contract, backend, policy, request record, and telemetry record.
- [ ] Customer platform and security owners accepted it after telemetry
  correlation.
- [ ] The approved evidence system contains the decision and S4 handoff reference.
- [ ] The technical decision record captures selected runtime-safety,
  threat-response, and gateway-correlation options, if decided.

No raw prompt, document, endpoint, credential, response, or telemetry is saved in
the kit or public documentation.

## 6. Rollback and handoff

The adapter changes no gateway configuration. If the customer stops the test, it
uses its own approved gateway and evidence-retention processes. The final
customer record contains the acceptance, rejection, or blocked decision and the
S4 handoff reference.
