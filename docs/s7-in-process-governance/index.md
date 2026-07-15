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

1. **Set the boundary** *(facilitator + governance lead)* - confirm that S7 is
   an optional adoption-decision workshop. Identify a candidate agent-tool
   boundary without changing it.
2. **Review the policy** *(AI developer/maker)* - open
   `labs/s7-in-process-governance/policies/demo-policy.json`; do not copy it
   into customer code during this session.
3. **Run the offline illustration**:
   ```bash
   python labs/s7-in-process-governance/pipelines/run_mock.py
   ```
4. **Verify hash-chain consistency**:
   ```bash
   python labs/s7-in-process-governance/pipelines/run_mock.py \
     --verify labs/s7-in-process-governance/evidence/policy-decision-audit.json
   ```
5. **Interpret the result** - it verifies consistency within the supplied local
   record. It is not AGT execution, downstream action-success evidence, or
   tamper evidence.
6. **Record the adoption decision** - capture application fit, owner, decision,
   residual risks, and next review in the S6 follow-up backlog. If tamper
   evidence is required, reference the customer-managed signed/immutable
   external record.

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

- **Timing:** ~90 minutes. Boundary and applicability review ~20 min, policy
  review ~15 min, offline illustration + consistency check ~20 min,
  limitations/risk review ~20 min, adoption decision ~15 min.
- **RACI:** AI developer/maker = R, Governance lead = A, platform owner = C,
  Security/SOC = C.
- **Common blockers:** no candidate boundary means S7 is not applicable; AGT
  production requests require a separate assessment; a policy with no explicit
  deny default is a design finding.
- **Hand-off:** S7 adds an optional adoption decision to the S6 backlog. It does
  not alter S6 reconciliation or promote the illustrative policy into customer
  code.
