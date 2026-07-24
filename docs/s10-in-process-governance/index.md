# S10 · In-Process Agent Governance

!!! info "Freshness"
    Last reviewed: 2026-07-15 · AGT claims in this session are pinned to [commit `b680c49`](https://github.com/microsoft/agent-governance-toolkit/tree/b680c49cc956727c5249771ddba7ee21a635a676). AGT is Public Preview; verify current status before customer delivery.

<span class="rvas-badge rvas-persona">AI developer / maker</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & what the customer keeps

By the end of this session the customer decides whether an in-process tool-call
policy check makes sense for one agent boundary.

They leave with:

- a reviewed example tool-policy definition;
- one offline allowed, denied, and approval-required decision record;
- a hash-chain consistency result; and
- a named owner and backlog decision: investigate AGT further, defer it, reject
  it for this architecture, or mark it not applicable.

`labs/s10-in-process-governance/` holds a dependency-free policy simulator, a
sample policy, and a runbook. It does **not** hold customer code, production
policies, tenant data, credentials, or real tool arguments.

The local simulator record is not tamper evidence. Tamper evidence needs a
customer-managed signed record in immutable external storage.

### What happens next

**Next customer action:** send the applicability decision and any engineering
assessment to the policy owner and the customer's normal SDLC or change process.

S10 creates a backlog item for later customer-owned engineering work. The
recommendation states whether to investigate AGT further, defer, reject, or mark
not applicable. It also names the policy owner, engineering assessment, audit
retention route, tool-call boundary, S5/S6/S9 dependency, and customer SDLC or
change process that owns next steps.

!!! warning "Illustrative only: no AGT deployment"
    The kit does not install or execute AGT, modify customer agent code, call a
    tenant or endpoint, or prove production suitability. It is not an AGT
    compatibility test or an official AGT–Citadel integration.

## 2. Prerequisites

- S0-S9 findings and the S9 backlog are ready to review.
- An AI developer or maker can explain the customer's agent tool-call path.
- A governance lead can make or defer the adoption decision.
- Python 3.11+ is available for the offline simulator.
- The team has reviewed the pinned AGT Public Preview notice and [known limitations](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/docs/LIMITATIONS.md).

You do **not** need an Azure subscription, AGT installation, customer source
code, credentials, production endpoint, or tenant change.

### Applicability worksheet

Use S10 only when the customer can point to a real decision just before an agent
invokes a tool. Capture:

- the candidate tool action and delegated authority;
- the gateway, identity, data, evaluation, and runtime controls that still apply;
- the policy owner, approval route, audit-record owner, and retention need;
- the evidence a future engineering assessment needs before installation or code
  change; and
- the reason S10 is not applicable if no in-process boundary exists.

## 3. Why this session matters

Gateway controls govern traffic at the platform boundary. An in-process policy
check can make a separate decision inside the agent before a tool call runs.

You may need both. One control does not prove the other is configured or working.

Read the [S10 Concepts](concepts.md) for the offline Preview boundary,
hash-chain consistency, and what real tamper evidence requires.

## 4. Co-delivery walkthrough

Review the [Technical decisions](technical.md) chapter first: it holds the
boundary option menu (gateway-only, in-process policy, defense in depth, or not
applicable) and the selection criteria this walkthrough decides between.

**Timebox:** 90 minutes. **Facilitator:** keeps the work offline and keeps the
evidence wording honest. The facilitator does not install AGT, change code, or
accept risk. **AI developer/maker:** explains one candidate agent-tool boundary.
**Governance lead / decision owner:** chooses investigate, defer, reject, or not
applicable. **Evidence owner:** references approved records. Include security,
platform, or records specialists when their controls apply.

**Entry condition:** S0-S9 findings and the S9 backlog are available by
reference. An AI developer or maker can describe one bounded agent-tool call.
The governance lead can decide or defer. Confirm that you will not use customer
code, endpoints, tenant data, credentials, production policy, or raw records.

| Activity | Time | Customer operation | Facilitator prompts and interpretation |
|---|---:|---|---|
| Choose the boundary option | 20 min | Describe one action immediately before a tool invocation and the delegated authority it carries. Name the existing gateway, data, identity, evaluation, and runtime controls. Then pick from the boundary menu. | **"Which boundary option fits this tool call: gateway-only, in-process, both, or not applicable, and what delegated authority makes the difference?"** **"Which existing control stays in place regardless?"** Record the choice and rationale; "not applicable" is a valid recorded decision. Do not force adoption. |
| Review the example policy | 15 min | Open `labs/s10-in-process-governance/policies/demo-policy.json` and explain the allow, deny-default, and approval-required choices. | **"Who owns each delegated authority decision?"** **"Which action needs approval, and why?"** The file is an example, not a customer policy or a recommendation to copy into code. |
| Run and check the offline illustration | 20 min | Run the two commands below. Confirm one allowed, denied, and approval-required simulated attempt. | **"What did the simulator evaluate?"** **"What did it not see?"** A pass means the local example has expected decisions and internally consistent hashes. It is not AGT execution, production validation, downstream success proof, or tamper evidence. |
| Review limits and evidence needs | 20 min | Review the pinned AGT Public Preview and [known limitations](https://github.com/microsoft/agent-governance-toolkit/blob/b680c49cc956727c5249771ddba7ee21a635a676/docs/LIMITATIONS.md). Review customer needs for policy ownership, change review, records retention, and tamper evidence. | **"What evidence would a future engineering assessment need?"** **"Who owns signed immutable retention if tamper evidence is required?"** A local hash chain can be replaced and recalculated. It does not prove integrity, source, immutability, or later tampering. |
| Decide and hand over | 15 min | Choose investigate further, defer, reject, or not applicable for the current architecture. Record fit, limits, remaining risks, owner, due date, review point, and S6 dependencies. | **"What decision can this offline illustration support?"** **"What must happen before engineering work starts?"** Adoption here only authorizes a separate assessment. It does not authorize installation, deployment, or policy change. |

Before the decision, keep the evidence types separate:

| Evidence type | What it can support | What it cannot support |
|---|---|---|
| Gateway or API policy record | A boundary control decision outside the agent process. | Proof that an in-process tool-call policy checked the action. |
| Offline simulator record | Understanding policy decisions and hash-chain consistency. | AGT execution, production validation, or tamper evidence. |
| In-process audit record from a future assessment | Which policy checked an attempted tool action. | Downstream action success, data source proof, or compliance certification by itself. |
| Signed immutable external record | Tamper-evidence needs when the customer owns and retains it correctly. | A replacement for policy ownership, approval, or technical validation. |

A future customer policy review should separate action on behalf of a user from
action under agent-operated authority. Treat a new tool or action scope,
privilege expansion, owner change, or material behavior change as a reapproval
question. This session does not define or approve that answer.

Run the illustration during the third activity:

```bash
python labs/s10-in-process-governance/pipelines/run_mock.py
python labs/s10-in-process-governance/pipelines/run_mock.py \
  --verify labs/s10-in-process-governance/evidence/policy-decision-audit.json
```

### Reference-only evidence and handoff

Reference the candidate boundary, policy review, simulator record, verification
result, AGT source and limitations review, and S6 backlog decision in the
customer's approved records system. Record the boundary choice and rationale in
`templates/technical-decision-record.template.md`. Record the scope, observed
result or no-result, limits, decision, owner, next review, and dependencies.

Do not retain raw customer source code, tool arguments, credentials, tenant data,
or production audit records in this kit. The simulator output remains labelled
**offline illustration, not AGT execution**.

### Blocker pathways

| Blocker | Safe response and handoff |
|---|---|
| No meaningful candidate in-process tool boundary | Mark S10 not applicable for the bounded pilot. Record the reason and owner, then return to the S6 backlog or existing controls. |
| A participant requests AGT installation, customer-code changes, production policy edits, credentials, or endpoint access | Stop the illustration. Create a separate customer-owned engineering and change-review item. Do not use a demonstration as approval. |
| The policy illustration or hash verification fails | Record the observed failure and its scope. Do not repair customer policy or claim tampering. Assign an owner to investigate the offline artifact or defer the decision. |
| Tamper evidence, outcome evidence, or compliance certification is required | Record the unmet requirement. Route it to customer-managed signed immutable external storage and the right assurance process. Do not describe the local hash chain as enough. |

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

S10 makes no tenant, endpoint, code, or policy change. Any AGT assessment or
customer policy implementation uses a separate engineering and change-review
path.
