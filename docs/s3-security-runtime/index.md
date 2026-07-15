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

1. **Pre-flight** - the customer confirms a non-production route, secure
   authentication handling, safe test scope, and evidence reviewers.
2. **Customer-operated request** - run
   `labs/s3-security-runtime/scripts/test_gateway_prompt_shield.sh` as described
   in the S3 runbook.
3. **Evidence review** - the platform and security owners validate the
   normalized manifest against customer telemetry using its `correlation_id`.
4. **Handoff** - record accept, reject, or blocked in the customer evidence
   system. Only an accepted `pass` proof can be used as the S4 assurance input.

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

- **Timing:** ~half day, including customer telemetry review.
- **RACI:** Platform owner = R, Security/SOC = R, Governance lead = A.
- **Common blockers:**
    - *No approved non-production route* → record blocked; do not test a
      component directly as a substitute.
    - *No telemetry reviewer or record location* → record blocked; no S4 exit is
      possible.
    - *Only production is available* → do not test.
- **Hand-off:** accepted S3 gateway proof is a required S4 assurance input.
