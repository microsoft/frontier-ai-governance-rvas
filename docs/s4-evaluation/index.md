# S4 · Evaluation & Assurance

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

The customer leaves with an assurance record that names the accepted S3 gateway
proof, the owner, an evaluation-plan reference, and a customer decision.

Durable artifact: `labs/s4-evaluation/` - an assurance-handoff contract and a
customer-owned outcome template. It is not a live agent evaluator or CI/CD gate.

## 2. Prerequisites

- An S3 manifest conforming to
  [`gateway-proof.schema.json`](../../contracts/gateway-proof.schema.json) with
  `result: "pass"`.
- Customer platform and security review accepting the S3 proof after telemetry
  correlation.
- A named assurance owner and approved customer records system.

## 3. Why this session

Assurance makes the customer decision and its prerequisites reviewable. S4
records references to customer-owned evaluation work but does not claim to run
or gate it.

Read the [S4 Concepts](concepts.md) for the boundary between evaluation results
and an assurance decision.

## 4. Co-delivery walkthrough

!!! warning "Report-only / audit-first"
    A fixture score or a direct component test is not an assurance exit. S4
    requires an accepted S3 gateway proof.

1. **Verify S3 entry evidence** - customer reviewers confirm a `pass` gateway
   proof was accepted after telemetry correlation.
2. **Record the assurance outcome** - the assurance owner copies
   `templates/assurance-outcome.template.json` to the customer records system,
   adds safe references, and chooses `continue` or `hold`.
3. **Validate and hand off** - validate the record against
   `contracts/assurance-handoff.schema.json`; retain the completed record and
   decision in the customer system.

## 5. Verification & evidence capture

- [ ] The referenced S3 proof conforms to the gateway-proof contract and has
  `result: "pass"`.
- [ ] Customer platform and security reviewers accepted the proof.
- [ ] The assurance record conforms to the S4 handoff contract.
- [ ] The customer records system contains the outcome and decision reference.

## 6. Customer-owned rollback and handoff

S4 changes no evaluator, agent, or CI/CD gate. The customer can record `hold`
or supersede its assurance decision through its own change and evidence
process. The completed handoff remains customer owned.

## 7. Facilitator notes

- **Timing:** ~half day, including evidence review and customer decision.
- **RACI:** Assurance owner = R, Governance lead = A, Platform owner and
  Security/SOC = C.
- **Common blockers:**
    - *No accepted S3 proof* → do not exit S4; record `hold`.
    - *No evidence reviewers* → do not create local substitute evidence.
    - *No customer decision reference* → do not exit S4.
- **Hand-off:** the customer-owned assurance decision informs subsequent
  delivery; separate evaluation and gate implementations remain customer owned.
