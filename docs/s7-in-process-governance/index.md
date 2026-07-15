# S7 · In-Process Agent Governance

!!! info "Freshness"
    Last reviewed: 2026-07-15 · AGT claims in this session are pinned to [commit `b680c49`](https://github.com/microsoft/agent-governance-toolkit/tree/b680c49cc956727c5249771ddba7ee21a635a676). AGT is Public Preview; verify current status before customer delivery.

<span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

This **optional extension** follows the S0–S6 core curriculum. The customer leaves with an adoption decision for in-process agent governance, supported by an offline illustration:

- a reviewed example tool-policy definition;
- an offline allowed, denied, and approval-required decision record;
- a tamper-evident audit-chain integrity result; and
- a named owner and backlog decision: investigate AGT further, defer it, or reject it for the current architecture.

Durable artifact: `labs/s7-in-process-governance/` - dependency-free policy simulator, sample policy, audit evidence schema, runbook, rollback, and verification steps.

!!! warning "Illustrative only — no AGT deployment"
    The kit does not install or execute AGT, modify customer agent code, call a tenant or endpoint, or prove production suitability. It illustrates the in-process policy-and-audit pattern described by AGT; it is not an AGT compatibility test or an official AGT–Citadel integration.

## 2. Prerequisites

- S0–S6 findings and the S6 backlog are available for review.
- An AI developer/maker and governance lead can discuss the customer's agent tool-call architecture.
- Python 3.11+ is available for the offline simulator.
- The team has reviewed the pinned AGT Public Preview notice and [known limitations](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/docs/LIMITATIONS.md).

No Azure subscription, AGT installation, customer source code, credentials, production endpoint, or tenant change is required.

## 3. Why this session

Gateway controls can govern traffic crossing the platform boundary. An
in-process control can make a separate decision just before an agent invokes a
tool. The two enforcement points are complementary: Citadel remains the
gateway/platform path, while AGT-style policy evaluation is inside the agent
application.

Read the [S7 Concepts](concepts.md) for the enforcement-plane boundary,
decision evidence, and limitations that prevent this session from being treated
as a production-control deployment.

## 4. Co-delivery walkthrough

1. **Set the boundary** *(facilitator + governance lead)* - confirm that S7 is an optional adoption-decision workshop. Review the current Citadel/platform path and identify the candidate agent-tool boundary without changing it.
2. **Review the policy** *(AI developer/maker)* - open `labs/s7-in-process-governance/policies/demo-policy.json`; agree which example action is allowed, denied, or routed for approval. Do not copy the example into customer code during this session.
3. **Run the offline illustration** - execute:
   ```bash
   python labs/s7-in-process-governance/pipelines/run_mock.py
   ```
   It writes `evidence/policy-decision-audit.json` with a policy version,
   attempted action, decision, timestamp, previous hash, and entry hash.
4. **Verify integrity** - execute:
   ```bash
   python labs/s7-in-process-governance/pipelines/run_mock.py \
     --verify labs/s7-in-process-governance/evidence/policy-decision-audit.json
   ```
5. **Interpret the result** - confirm that the decision record is evidence of
   the governance decision, **not** proof that an allowed downstream action
   succeeded.
6. **Record the adoption decision** - capture application fit, owner, decision,
   residual risks, and next review in the S6 follow-up backlog.

## 5. Verification & evidence capture

- [ ] The offline run completed without network or tenant access.
- [ ] `evidence/policy-decision-audit.json` contains allowed, denied, and approval-required decisions.
- [ ] Every record contains the policy version, attempt details, timestamp, previous hash, and entry hash.
- [ ] The integrity verifier reports `pass`.
- [ ] The customer recorded an AGT adoption decision and owner in the S6 follow-up backlog.
- [ ] The evidence record is not described as a downstream action-success log or production validation.

See `labs/s7-in-process-governance/verify.md` for the complete capture checklist.

## 6. Rollback

S7 does not change a tenant, endpoint, agent, or production policy. If the
customer does not retain the local illustrative artifact, preserve the adoption
decision first and then remove only the generated evidence file according to
`labs/s7-in-process-governance/rollback.md`.

## 7. Facilitator notes

- **Timing:** ~90 minutes. Boundary and applicability review ~20 min, policy review ~15 min, offline illustration + integrity check ~20 min, limitations/risk review ~20 min, adoption decision ~15 min.
- **RACI:** AI developer/maker = R, Governance lead = A, platform owner = C, Security/SOC = C.
- **Common blockers:**
    - *No candidate agent-tool boundary exists* → record S7 as not applicable; do not invent a code-integration target.
    - *AGT is requested as a production baseline* → stop and open a separate engineering assessment; AGT is Public Preview at the pinned revision.
    - *A customer wants AGT to replace Citadel, Purview, or Foundry evaluation* → clarify the layer boundary and retain the existing session evidence.
    - *A policy has no explicit deny default* → treat it as a design finding; the example uses deny-by-default.
- **Hand-off:** S7 adds an optional adoption decision to the S6 backlog. It does not alter S6 registry reconciliation or promote an illustrative policy into customer code.
