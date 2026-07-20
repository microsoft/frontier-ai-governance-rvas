# S10 · In-Process Agent Governance

**Facilitator deck**

AI developer / maker · Governance lead · 90-minute offline decision session

## One boundary decision

> **"Does this agent have a useful place to run a policy check just before it calls a tool?"**

Choose investigate, defer, reject, or not applicable.

Note:
This offline illustration neither installs AGT nor changes customer code, endpoints, tenant data, or policies.

---

## Boundary and evidence

![In-process governance logs tool calls with local hash-chain consistency; signed immutable external records provide tamper evidence.](../assets/diagrams/s10-policy-boundary-and-evidence.svg)

- Gateway and in-process checks make different decisions; either, both, or neither may fit.
- The simulator models AGT's policy-and-audit idea. It does not import, test, certify, or integrate AGT.
- A local hash chain is an internal-consistency check, not tamper evidence.
- Tamper evidence requires customer-managed signed immutable external records.

---

## Entry and stop condition

- **Entry:** S0–S9 findings and S9 backlog, one bounded agent-tool call, AI developer/maker, governance decision owner, and approved references.
- **Stop:** no meaningful in-process boundary; request for installation, source-code change, tenant access, credentials, or production policy; failed illustration; or unmet tamper-evidence requirement.

Record the blocker and route it to the customer engineering, assurance, or change process.

---

## Step 1 — Choose the boundary · 20 min

Describe the action immediately before the tool invocation, its delegated authority, and existing gateway, identity, data, evaluation, and runtime controls.

> **"Gateway-only, in-process, both, or not applicable—and why?"**

---

## Step 2 — Review the example policy · 15 min

Open `labs/s10-in-process-governance/policies/demo-policy.json`. Review allow, deny-default, and approval-required decisions and name the owner of each delegated authority decision.

---

## Step 3 — Run the illustration · 20 min

```bash
python labs/s10-in-process-governance/pipelines/run_mock.py
python labs/s10-in-process-governance/pipelines/run_mock.py \
  --verify labs/s10-in-process-governance/evidence/policy-decision-audit.json
```

Confirm allowed, denied, and approval-required attempts and `hash_chain_consistency.status: pass`.

Note:
This is neither AGT execution nor production, downstream-success, or tamper evidence.

---

## Step 4 — Review limits and decide · 35 min

Review the pinned AGT Preview and limitations, policy ownership, approval route, retention, and needed signed immutable evidence. Record fit, limits, risks, owner, due date, review point, and S6 dependency.

---

## Verification and handoff

- [ ] Run remained offline with no tenant access.
- [ ] Record includes allowed, denied, and approval-required decisions; policy version; attempt details; timestamp; and hashes.
- [ ] The decision and owner are in the S6 follow-up backlog.

S10 makes no tenant, endpoint, code, or policy change. Any assessment or implementation uses a separate engineering and change-review path.
