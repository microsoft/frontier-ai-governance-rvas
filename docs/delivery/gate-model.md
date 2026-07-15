# Gate model

Use these gates in addition to the session-specific prerequisites and rollback steps. Record the result in the engagement register.

| Gate | When | Pass condition | If it does not pass |
|---|---|---|---|
| Mobilisation | Before S0 | Sponsor, governance lead, core contacts, evidence location, and escalation route are named. | Run an ownership discussion; do not treat the programme as mobilised. |
| Session readiness | Before each session | Required role, license, access, artifact inputs, and session-specific change conditions are available. | Record an owned prerequisite and move to another ready session or offline work. |
| Non-production hard exit | Before S3 runtime testing, S4 live evaluation, or S5 testing | The requirements in [How to Deliver](../how-to-deliver.md#non-production-hard-exit-gate) are recorded. | Stop live test execution. No production substitute is allowed. |
| Customer change | Before a customer applies a reviewed definition | The customer change owner, approver, change window, safe initial posture, and rollback are documented. | Retain the work as Designed or Reference only. |
| Observation review | Before a production-readiness package | The customer reviewed agreed evidence, impact, false positives, findings, and rollback readiness. | Keep the control in its current safe posture or record an exception. |
| Programme close | Before sponsor close-out | Every in-scope item has an evidence location, control state, owner, decision, and next review date; S6 comparison output is retained. | Keep the programme open with a dated close action. |

## Decision authority

The facilitator verifies the gate and records the result. The customer retains decision authority:

| Decision | Customer decision owner |
|---|---|
| Delivery sequence and residual backlog priority | Governance lead, accepted by executive sponsor |
| Tenant or platform change | Named change approver |
| Risk acceptance or exception | Accountable business or governance owner |
| Security-test authorization and SOC handling | Security/SOC owner and endpoint owner |
| Production promotion | Customer change authority |

## Gate record

Copy this table into the engagement register for a gate that needs a decision.

| Field | Record |
|---|---|
| Gate and session | |
| Decision required | |
| Evidence reviewed | |
| Result: passed, blocked, exception, or deferred | |
| Customer decision owner and approver | |
| Risks, constraints, and rollback reference | |
| Next action, owner, and due date | |
