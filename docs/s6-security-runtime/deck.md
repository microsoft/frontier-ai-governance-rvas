# S6 · Security Runtime

**Facilitator deck**

Security / SOC · Governance lead · 90-minute report-only runtime evidence review

Note:
This report-only, audit-first runtime-evidence session does not run against
production traffic. A component diagnostic is not gateway-path proof; the
customer operates the approved request and records its evidence.

---

## One runtime artifact

> **"Did this approved non-production request go through the approved gateway path with a correlation we can review?"**

The customer keeps a redacted gateway proof and acceptance decision.

Note:
By the end, the customer should have one reviewable runtime artifact: a gateway proof manifest with safe references and a correlation_id. Platform and security owners must match that correlation_id to gateway telemetry before accepting it as enforcement evidence.

---

## Why this matters

- Runtime evidence must show the path the agent actually used.
- A component diagnostic can troubleshoot part of the stack.
- It does not prove the gateway path.
- S6 records correlation without changing production traffic.

Note:
A direct Content Safety call can diagnose that component, but cannot prove the
agent used the customer gateway, access contract, backend, or policy.

---

## Gateway proof is not a component diagnostic

- Direct component testing is labeled diagnostic.
- Gateway proof comes from the gateway adapter.
- The manifest holds safe references and a correlation identifier.
- It does not store raw payloads or endpoints.

Note:
Name the artifact precisely: gateway-proof manifest from the gateway adapter. It conforms to the gateway-proof contract and contains safe references plus correlation_id. Never treat direct component testing as gateway enforcement evidence.

---

## Correlation makes the request reviewable

![Gateway correlation determines runtime acceptance.](../assets/diagrams/s6-security-runtime-correlation-flow.svg)

Transport result and security acceptance are different decisions.

Note:
Walk the flow: adapter request, manifest, correlation_id, approved gateway telemetry, platform/security interpretation, acceptance decision. A completed adapter request is not enough by itself. The customer reviewers decide whether the observed telemetry supports the expected policy behavior.

---

## Runtime safety remains layered

- Prompt injection and harmful-content detection are only part of the boundary.
- Gateway policy, identity, scoped tools, data controls, telemetry, and human review may also apply.
- Defender and posture capabilities can support broader review where enabled.
- They do not replace S6 gateway proof.

Note:
Keep five questions separate: did the request complete, does the correlation appear, does the route match, does the observed path support expected policy behavior, and who accepted the interpretation. Prompt Shields results or component diagnostics may add context, but not gateway-path proof by themselves.

---

## Runtime evidence becomes backlog

- Recommend the next runtime path with confidence and assumptions.
- Backlog gateway route remediation, policy review, telemetry correlation, SOC route, identity/data dependencies, and later-session handoffs.
- The recommendation does not deploy controls or prove production effectiveness.

Note:
Route work to customer platform, security, SOC, identity, data, change, or operating processes. S6 can block S7, S9, or S11 dependencies until correlation is accepted.

---

## Technical decisions stay customer-owned

- Runtime safety placement: gateway, application, defense in depth, or deferred.
- Threat response route: Defender/SOC, gateway telemetry alerting, custom pipeline, or manual pilot review.
- Correlation evidence: gateway, application, defense in depth, or insufficient.

Note:
These are decision menus, not deployment steps. S6 changes no production traffic, configures no product, and leaves implementation with the customer's security, platform, SOC, identity, and change processes.

---

## The activity: how we'll work

- **Timebox:** 90 minutes · **five steps**
- **Entry condition:** approved non-production route, safe authentication handling, record locations, and named platform/security/evidence/decision owners.
- Missing any of these? **Stop before the request.**

Note:
Preview the five steps: orient, customer-operated gateway request, interpret together, customer decision, hand over. The facilitator keeps the boundary and wording; the customer platform operator runs the approved request; platform and security reviewers interpret telemetry.

---

## Step 1: Set the room and orient · 20 min

> **"Which gateway route, policy, and runtime-control option are in scope?"**
> **"Who can interpret telemetry and accept this proof?"**
> **"What result makes us stop instead of guessing enforcement?"**

Confirm this run is non-production, the expected policy behavior, stop condition, and evidence locations.

Note:
Record the pilot question and scope. Do not proceed without the approved route, safe test scope, authentication handling, and reviewers who can interpret telemetry.

---

## Step 2: Customer-operated gateway request · 30 min

The platform operator performs one approved gateway-path request using the runbook.

> **"Are we still inside the approved non-production route and safe evidence boundary?"**

Note:
The facilitator observes the boundary without handling credentials or payloads. The customer records only safe references to the generated manifest, request record, telemetry record, and correlation identifier in its approved system. A direct component call is a separate diagnostic, not a substitute.

---

## Step 3: Interpret together · 15 min

> **"Does the manifest match the gateway-proof contract?"**
> **"Does `correlation_id` appear in approved gateway telemetry?"**
> **"Does the observed path support expected policy behavior, or are we missing proof?"**

Record observed fact and reviewer interpretation.

Note:
Separate adapter transport result from acceptance decision. Do not copy prompts, responses, endpoint values, credentials, or telemetry. Use the gateway correlation review template in the customer's records system.

---

## Step 4: Customer decision · 15 min

Accepted proof requires:

- conforming manifest
- `result: "pass"`
- required safe references
- platform and security acceptance of telemetry correlation

Note:
A pass without reviewer acceptance is not enforcement evidence. A fail, missing correlation, or unresolved scope is rejected, deferred, or blocked. Do not convert it to a pass. The decision owner records control state and review date.

---

## Step 5: Hand over · 10 min

Read back safe references:

- manifest and telemetry references
- correlation identifier
- reviewer interpretation
- decision reference and next owner

Note:
Hand only an accepted pass gateway-proof reference to S4. The gateway proof remains the runtime artifact. Record selected option, rationale, and adoption stage with the technical decision record.

---

## Verification & evidence

- [ ] Manifest validates against `gateway-proof.schema.json`.
- [ ] It has `result: "pass"` and approved gateway, access contract, backend, policy, request, and telemetry references.
- [ ] Platform and security owners accepted it after telemetry correlation.
- [ ] Evidence system contains the decision and S4 handoff reference.
- [ ] Technical decision record captures runtime-safety, threat-response, and gateway-correlation options, if decided.

Note:
No raw prompt, document, endpoint, credential, response, or telemetry is saved in the kit or public documentation. Keep the evidence in customer-approved systems and reference it safely.

---

## Change boundary & hand-off

- The adapter changes no gateway configuration.
- If the customer stops the test, customer gateway and evidence-retention processes apply.
- Final record contains acceptance, rejection, or blocked decision and the S4 handoff reference.

Note:
For no approved non-production route, unsafe authentication, missing reviewer or
record location, production-only availability, or unresolved correlation, record
the stop point, owner, date, and S4 impact. Do not substitute a diagnostic.
