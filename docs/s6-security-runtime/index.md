# S3 · Security Runtime

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

The customer leaves with one reviewable runtime artifact: a redacted gateway
proof manifest for a customer-operated non-production request. It conforms to
[`contracts/gateway-proof.schema.json`](../../contracts/gateway-proof.schema.json).

The adapter does not deploy a safety platform or prove a direct Content Safety
call. The customer platform and security owners must correlate its
`correlation_id` with gateway telemetry before accepting it as enforcement
evidence.

## 2. Prerequisites

- A deployed customer gateway with an approved non-production route and runtime
  policy.
- A customer operator who can supply authentication without recording it here.
- Customer-owned request and telemetry record locations, and named platform and
  security reviewers.

## 3. Why this session

Runtime evidence must show the path actually used by the agent. S3 records a
redacted request correlation through that path without changing production
traffic.

Read the [S3 Concepts](concepts.md) for the boundary between component
diagnostics and gateway enforcement evidence.

## 4. Co-delivery walkthrough

!!! warning "Report-only / audit-first"
    Do not run against production traffic. A component diagnostic is not
    gateway-path proof.

**Timebox:** 90 minutes. **Entry condition:** the customer has approved a
non-production gateway route, safe test scope and authentication handling,
customer record locations, and named platform, security, evidence, and decision
owners. Stop before the request if any of these are absent.

| Role | Workshop responsibility |
|---|---|
| Facilitator | Keeps the gateway-proof boundary, timebox, and decision wording; does not run the request or accept evidence. |
| Customer platform operator | Runs the approved gateway-path request using `labs/s3-security-runtime/runbook.md`. |
| Security reviewer / evidence owner | Correlates the returned identifier with customer gateway telemetry and cites the authoritative records. |
| Customer decision owner | Accepts, rejects, or defers the proof and owns the S4 handoff. |

1. **Set the room and orient — 20 min.** The facilitator records the pilot
   question, for example: “Did this approved non-production request traverse the
   approved gateway path with a reviewable correlation?” The customer confirms
   the non-production posture, expected policy behavior, stop condition, and
   evidence locations. Ask: *Which gateway route and policy reference are in
   scope? Who can interpret telemetry and accept this proof? What result would
   make us stop rather than infer enforcement?*
2. **Customer-operated gateway request — 30 min.** The platform operator
   performs the one request in the runbook; the facilitator observes the
   boundary without handling credentials or payloads. The customer records only
   safe references to the generated manifest, request record, telemetry record,
   and correlation identifier in its approved system. A direct component call
   is a separately labelled diagnostic and is not a substitute action.
3. **Interpret together — 15 min.** The platform and security reviewers first
   distinguish the adapter transport result from the acceptance decision. Ask:
   *Does the manifest conform to the gateway-proof contract? Does
   `correlation_id` resolve in the approved gateway telemetry? Does the
   observed path support the stated policy behavior, or is this a no-result or
   blocker?* Record the observed fact and reviewer interpretation; do not copy
   prompts, responses, endpoint values, credentials, or telemetry.

   When runtime evidence informs a later governance decision, retain references
   to the bounded agent/workload and initiating context, request correlation,
   applicable tool/model version, policy decision, outcome category, and
   reviewer decision. These references support interpretation; they are not a
   telemetry schema or a requirement to retain raw event data.
4. **Customer decision — 15 min.** A proof is eligible for **accepted** only
   when the manifest conforms to `gateway-proof.schema.json`, has
   `result: "pass"`, contains the required safe references, and both customer
   platform and security reviewers accept the telemetry correlation. A `pass`
   without that acceptance is not enforcement evidence. A `fail`, no
   correlation, or unresolved scope is rejected, deferred, or **blocked**—not
   converted to a pass. The decision owner records the control state and review
   date in the customer system.
5. **Hand over — 10 min.** Read back the manifest reference, telemetry
   reference, correlation identifier, reviewer interpretation, decision
   reference, and next owner. Hand only an accepted `pass` gateway-proof
   reference to S4; the gateway proof remains the canonical runtime artifact.

**Blockers:** no approved non-production route, unsafe authentication handling,
missing telemetry reviewer or evidence location, production-only availability,
or an unresolved correlation. Record the safe stop point, owner, target date,
and impact on S4; do not run a direct diagnostic or fabricate local evidence to
continue.

## 5. Verification & evidence capture

- [ ] The manifest validates against `gateway-proof.schema.json`.
- [ ] It has `result: "pass"` and references the approved gateway, access
  contract, backend, policy, request record, and telemetry record.
- [ ] Customer platform and security owners have accepted it after telemetry
  correlation.
- [ ] The approved evidence system contains the decision and S4 handoff
  reference.

No raw prompt, document, endpoint, credential, response, or telemetry is saved
in the kit or public documentation.

## 6. Customer-owned rollback and handoff

The adapter changes no gateway configuration. If the customer decides to stop
the test, it uses its own approved gateway and evidence-retention processes.
The final customer record contains the acceptance, rejection, or blocked
decision and the S4 handoff reference.

## 7. Facilitator notes

- **Timing:** 90-minute workshop; schedule any customer telemetry retrieval and
  records-system review within or before the interpretation block.
- **RACI:** Platform owner = R, Security/SOC = R, Governance lead = A.
- **Common blockers:**
    - *No approved non-production route* → record blocked; do not test a
      component directly as a substitute.
    - *No telemetry reviewer or record location* → record blocked; no S4 exit is
      possible.
    - *Only production is available* → do not test.
- **Hand-off:** accepted S3 gateway proof is a required S4 assurance input.
