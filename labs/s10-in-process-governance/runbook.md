# S10 Runbook — In-Process Agent Governance

Use this runbook with the visible [S10 co-delivery activity](../../docs/s10-in-process-governance/index.md).
It is a customer-led, offline adoption-decision workshop—not an AGT trial or
implementation. Do not retain raw customer source code, tool arguments,
credentials, tenant data, or production audit records in this kit.

## Roles, timebox, and entry condition

- **Timebox:** 90 minutes: applicability and boundary (20 min), illustrative
  policy review (15 min), offline run and verification (20 min), limitations
  and evidence needs (20 min), and adoption decision/handoff (15 min).
- **AI developer/maker:** describes the candidate boundary and reviews the
  illustration. **Governance lead / decision owner:** chooses investigate,
  defer, or reject. **Evidence owner:** references approved records. The
  facilitator protects the boundary and records the handoff; platform and
  security specialists interpret their implications.
- **Entry condition:** relevant S0-S9 findings and the S9 backlog are available by
  reference, one bounded candidate agent-tool action can be described, and a
  decision owner is present or a deferred-decision owner and date are agreed.

- [ ] Confirm an in-process tool-call boundary is meaningful for the selected
  scope and that the relevant S0-S9 findings are available.
- [ ] Confirm no customer source code, endpoint, tenant, or production policy will change.
- [ ] Review the pinned AGT Public Preview notice and known limitations.
- [ ] Identify the governance lead who owns the adoption decision.
- [ ] Review the illustrative deny-by-default policy in `policies/demo-policy.json`.

## Applicability and illustrative-policy review

The customer describes the candidate agent-tool boundary, current gateway,
identity, data, and outcome controls, and the decision S10 could inform.
Facilitator prompts: “Is an in-process decision meaningful here?” “Which
control is not being replaced?” If no boundary exists, record S10 as not
applicable for this pilot and return the rationale to the S6 backlog.

Review `policies/demo-policy.json` as a generic illustration. Ask: “Who owns
each delegated authority decision?” “What needs approval?” Do not copy it to
customer code or edit a production policy. A missing explicit deny default is
a design issue for a separate assessment, not an invitation to make a change.

## Customer-operated offline illustration

1. Run:
   ```bash
   python pipelines/run_mock.py
   ```
2. Confirm the output includes one `allow`, one `deny`, and one
   `approval_required` decision.
3. Verify hash-chain consistency in the generated evidence:
   ```bash
   python pipelines/run_mock.py --verify evidence/policy-decision-audit.json
   ```
4. Review the boundary: audit evidence records attempts and decisions, not
   whether an allowed downstream action succeeded.
5. Interpret a `pass` as internal consistency of the supplied local record and
   expected simulated decisions only. It is not AGT execution, an AGT
   compatibility result, downstream action-success evidence, production
   validation, or tamper evidence.
6. Do not treat the local hash-chain result as tamper evidence. A person able
   to replace a local record can recalculate it. If tamper evidence is required,
   use a signed record in customer-managed immutable external storage under the
   customer's retention and access process.
7. Review the pinned AGT Public Preview and known limitations, then record
   application fit, policy ownership, AGT Preview risk, residual limitations,
   owner, and next review in the S6 follow-up backlog.

## Adoption decision, reference-only evidence, and handoff

- [ ] The run and `--verify` command both exit `0`.
- [ ] Evidence has one allowed, one denied, and one approval-required attempt.
- [ ] Each record contains action, arguments, policy ID/version/hash, timestamp,
  previous hash, and entry hash; `hash_chain_consistency.status` is `pass`.
- [ ] The record remains labelled as an offline illustration, not AGT execution,
  downstream action success, production validation, or tamper evidence.
- [ ] The S6 follow-up backlog records the adoption decision, owner, residual
  risks, and next review. If tamper evidence is needed, it references the
  customer-managed signed/immutable external record.

Choose **investigate further**, **defer**, or **reject** for the current
architecture. “Investigate further” authorizes only a separate customer-owned
engineering and change-review assessment; it does not authorize AGT
installation, deployment, or policy change. Reference the candidate-boundary
description, policy review, offline record, verification result, limitation
review, and decision in the approved records system. Record scope, observed
result or no-result, interpretation, owner, next review, and dependencies.

## Blocker pathways

| If | Then |
|---|---|
| No candidate boundary is meaningful | Record S10 as not applicable for this pilot; return to existing controls and the S6 backlog. |
| A participant asks to install AGT, change customer code, edit a production policy, use credentials, or access an endpoint | Stop the illustration and record a separate engineering and change-review follow-up. |
| The illustration or hash verification fails | Record the failure and scope. Do not repair customer policy or claim tampering; assign an owner to investigate or defer the decision. |
| Tamper evidence, outcome evidence, or compliance certification is required | Record the unmet requirement; use the customer’s signed immutable external-record and assurance paths. The local hash chain does not satisfy it. |
