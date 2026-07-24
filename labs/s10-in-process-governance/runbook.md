# S10 Runbook: In-Process Agent Governance

This is a customer-led, offline adoption-decision workshop, not an AGT trial or
implementation. Do not retain raw customer source code, tool arguments,
credentials, tenant data, or production audit records in this kit.

## Roles, timebox, and entry condition

- **Timebox:** 90 minutes: applicability and boundary (20 min), illustrative
  policy review (15 min), offline run and verification (20 min), limitations
  and evidence needs (20 min), and adoption decision and agreed follow-up (15 min).
- **AI developer/maker:** describes the candidate boundary and reviews the
  illustration. **Governance lead / decision owner:** chooses investigate,
  defer, or reject. **Evidence owner:** references approved records. The
  facilitator protects the boundary and records agreed actions; platform and
  security specialists interpret their implications.
- **Entry condition:** relevant prior findings are available by reference where
  they exist, one bounded candidate agent-tool action can be described, and a
  decision owner is present or a deferred-decision owner and date are agreed.

- [ ] Confirm an in-process tool-call boundary is meaningful for the selected
  scope and record any relevant prior findings by reference.
- [ ] Confirm no customer source code, endpoint, tenant, or production policy will change.
- [ ] If AGT is under consideration, record the source, date, and stated
  release status and limitations in approved records. This kit does not verify
  those claims.
- [ ] Identify the governance lead who owns the adoption decision.
- [ ] Review the illustrative deny-by-default policy in `policies/demo-policy.json`.

## Applicability and illustrative-policy review

The customer describes the candidate agent-tool boundary, current gateway,
identity, data, and outcome controls, and the decision S10 could inform.
Facilitator prompts: “Is an in-process decision meaningful here?” “Which
control is not being replaced?” If no boundary exists, record the activity as
not applicable for this scope and return the rationale to the customer's
existing governance backlog.

The default is gateway-only. Choose in-process or both only where a genuine
pre-tool decision carries delegated authority that the gateway cannot make.
Record gateway-only, in-process, both, or not applicable, then record
approve, defer, reject, or route with owner, evidence, acceptance evidence,
target date, and S6/S9/S11 handoff.

Copy `templates/applicability-review.template.md` into the approved customer
records system and capture the applicability decision before running the
illustration.

| Question | Record |
|---|---|
| Candidate tool action and delegated authority | |
| Existing gateway/API, identity, data, evaluation, and runtime controls | |
| Policy owner and approval route | |
| Audit-record owner, retention need, and tamper-evidence need | |
| Evidence needed before any future engineering assessment | |
| Applicable, deferred, rejected, or not applicable rationale | |

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
7. If AGT is under consideration, record its source, date, stated release
   status, limitations, application fit, policy ownership, residual risk,
   owner, and next review in the customer's governance backlog. Do not treat
   the workshop as verification of any AGT claim.
8. Record the in-process governance implementation backlog in the applicability
   review: AGT release/API/limitation assessment, runtime/framework fit,
   policy owner, approval route, delegated authority, signed immutable audit
   retention route, gateway/identity/data/runtime dependencies, rollback,
   verification, recommendation, confidence, assumptions, owner, and customer
   SDLC/change process.

## Adoption decision and reference-only evidence

- [ ] The run and `--verify` command both exit `0`.
- [ ] Evidence has one allowed, one denied, and one approval-required attempt.
- [ ] Each record contains action, arguments, policy ID/version/hash, timestamp,
  previous hash, and entry hash; `hash_chain_consistency.status` is `pass`.
- [ ] The record remains labelled as an offline illustration, not AGT execution,
  downstream action success, production validation, or tamper evidence.
- [ ] The customer governance backlog records the adoption decision, owner,
  residual risks, and next review. If tamper evidence is needed, it references
  the customer-managed signed/immutable external record.

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
| No candidate boundary is meaningful | Record the activity as not applicable for this scope; retain the rationale with the existing controls and governance backlog. |
| A participant asks to install AGT, change customer code, edit a production policy, use credentials, or access an endpoint | Stop the illustration and record a separate engineering and change-review follow-up. |
| The illustration or hash verification fails | Record the failure and scope. Do not repair customer policy or claim tampering; assign an owner to investigate or defer the decision. |
| Tamper evidence, outcome evidence, or compliance certification is required | Record the unmet requirement; use the customer’s signed immutable external-record and assurance paths. The local hash chain does not satisfy it. |
