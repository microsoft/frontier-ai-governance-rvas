# S7 · In-Process Agent Governance

!!! info "Freshness"
    Last reviewed: 2026-07-15 · AGT claims in this session are pinned to [commit `b680c49`](https://github.com/microsoft/agent-governance-toolkit/tree/b680c49cc956727c5249771ddba7ee21a635a676). AGT is Public Preview; verify current status before customer delivery.

<span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

This **optional extension** follows the S0–S6 core curriculum. The customer
leaves with an adoption decision for in-process agent governance, supported by
an offline illustration:

- a reviewed example tool-policy definition;
- an offline allowed, denied, and approval-required decision record;
- a hash-chain consistency result; and
- a named owner and backlog decision: investigate AGT further, defer it, or
  reject it for the current architecture.

Durable artifact: `labs/s7-in-process-governance/` - dependency-free policy
simulator, sample policy, and runbook. The local record is not tamper evidence;
tamper evidence requires a customer-managed signed record in immutable external
storage.

!!! warning "Illustrative only — no AGT deployment"
    The kit does not install or execute AGT, modify customer agent code, call a
    tenant or endpoint, or prove production suitability. It is not an AGT
    compatibility test or an official AGT–Citadel integration.

## 2. Prerequisites

- S0–S6 findings and the S6 backlog are available for review.
- An AI developer/maker and governance lead can discuss the customer's agent
  tool-call architecture.
- Python 3.11+ is available for the offline simulator.
- The team has reviewed the pinned AGT Public Preview notice and [known limitations](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/docs/LIMITATIONS.md).

No Azure subscription, AGT installation, customer source code, credentials,
production endpoint, or tenant change is required.

## 3. Why this session

Gateway controls can govern traffic crossing the platform boundary. An
in-process control can make a separate decision just before an agent invokes a
tool. The two enforcement points are complementary; neither proves the other is
configured or effective.

Read the [S7 Concepts](concepts.md) for the offline/Preview boundary,
hash-chain consistency, and the requirements for tamper evidence.

## 4. Co-delivery walkthrough

**Timebox:** 90 minutes. **Facilitator:** maintains the offline boundary,
evidence discipline, and decision wording; does not install AGT, change code,
or accept risk. **AI developer/maker:** explains a candidate agent-tool
boundary. **Governance lead / decision owner:** chooses adoption, deferral, or
rejection. **Evidence owner:** references approved records. Include security,
platform, or records specialists where their control obligations apply.

**Entry condition:** S0–S6 findings and the S6 backlog are available by
reference; an AI developer/maker can describe one bounded candidate
agent-tool call; the governance lead can make or defer an adoption decision.
Confirm no customer code, endpoint, tenant, credential, production policy, or
raw customer record will be used.

| Activity | Time | Customer operation | Facilitator prompts and interpretation |
|---|---:|---|---|
| Establish applicability and stop condition | 20 min | Describe one candidate action immediately before a tool invocation, existing gateway/data/identity controls, and the decision this extension could inform. | “Is an in-process decision point technically and operationally meaningful here?” “Which existing control is not being replaced?” No candidate boundary means S7 is not applicable for this pilot; record that result rather than forcing an adoption decision. |
| Review the illustrative policy | 15 min | Open `labs/s7-in-process-governance/policies/demo-policy.json` and explain the generic allow, deny-default, and approval-required choices. | “Who would own each delegated authority decision?” “What needs approval and why?” The file is an illustration, not a customer policy, configuration, or recommendation to copy into code. A missing explicit deny default is a design question, not a reason to edit a production policy here. |
| Run and verify the offline illustration | 20 min | Run the two commands below and confirm one allowed, denied, and approval-required simulated attempt. | “What did the simulator evaluate?” “What did it not observe?” A pass means only that the supplied local illustration has internally consistent hashes and the expected simulated decisions. It is not AGT execution, an AGT compatibility result, proof of downstream action success, production validation, or tamper evidence. |
| Assess limitations and evidence needs | 20 min | Review the pinned AGT Public Preview and [known limitations](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/docs/LIMITATIONS.md), plus customer requirements for policy ownership, change review, records retention, and tamper evidence. | “What evidence would a future engineering assessment need?” “Who controls signed immutable external retention if tamper evidence is required?” A local hash chain can be recalculated after replacement; it does not establish integrity, provenance, immutability, or later tampering. |
| Decide and hand over | 15 min | Choose investigate further, defer, or reject for the current architecture. Record fit, constraints, residual risks, owner, due date, review point, and dependencies in the S6 follow-up backlog. | “What decision is supportable from this illustration?” “What must happen before an engineering assessment?” Adoption means only that a separate assessment is authorized; it does not authorize installation, deployment, or policy change. |

Run the illustration during the third activity:

```bash
python labs/s7-in-process-governance/pipelines/run_mock.py
python labs/s7-in-process-governance/pipelines/run_mock.py \
  --verify labs/s7-in-process-governance/evidence/policy-decision-audit.json
```

### Reference-only evidence and handoff

Reference the candidate-boundary description, policy review, simulator record,
verification result, AGT source/limitations review, and S6 backlog decision in
the approved customer records system. Record the scope, observed result or
no-result, limitations interpretation, decision, owner, next review, and
dependencies. Do not retain raw customer source code, tool arguments,
credentials, tenant data, or production audit records in this kit. The
simulator output remains labelled **offline illustration—not AGT execution**.

### Blocker pathways

| Blocker | Safe response and handoff |
|---|---|
| No meaningful candidate in-process tool boundary | Mark S7 not applicable for the bounded pilot, record the rationale and owner, and return to the S6 backlog or existing controls. |
| A participant requests AGT installation, customer-code changes, production policy edits, credentials, or endpoint access | Stop the illustration. Create a separate customer-owned engineering and change-review item; do not substitute a demonstration for approval. |
| The policy illustration or hash verification fails | Record the observed failure and its scope. Do not repair customer policy or claim tampering; assign an owner to investigate the offline artifact or defer the decision. |
| Tamper evidence, outcome evidence, or compliance certification is required | Record the unmet requirement. Refer to customer-managed signed immutable external storage and the appropriate assurance process; do not represent the local hash chain as satisfying it. |

## 5. Verification & evidence capture

- [ ] The offline run completed without network or tenant access.
- [ ] The record contains allowed, denied, and approval-required decisions.
- [ ] Every record contains the policy version, attempt details, timestamp,
  previous hash, and entry hash.
- [ ] `hash_chain_consistency.status` is `pass`.
- [ ] The record is not described as AGT execution, downstream action-success
  evidence, production validation, or tamper evidence.
- [ ] The customer recorded an AGT adoption decision and owner in the S6
  follow-up backlog. Tamper-evidence needs reference signed/immutable external
  storage.

## 6. Change boundary

S7 makes no tenant, endpoint, code, or policy change. Any AGT assessment or
customer policy implementation is a separate engineering and change-review
path.

## 7. Facilitator notes

- Follow the [co-delivery facilitation method](../delivery/facilitation-pattern.md):
  the customer performs the review and makes the decision; the facilitator
  never substitutes a product action or evidence.
- **RACI:** AI developer/maker = activity owner; governance lead = decision
  owner; evidence owner = approved-records reference; platform owner and
  Security/SOC = specialist reviewers.
- **Hand-off:** S7 adds an optional adoption decision to the S6 backlog. It
  neither alters S6 reconciliation nor promotes the illustration into customer
  code.
