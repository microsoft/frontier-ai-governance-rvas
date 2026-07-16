# S8 · Adversarial Testing

!!! info "Freshness"
    Last reviewed: 2026-07-15 · Validate AI Red Teaming Agent availability in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">AI developer / maker</span>

## 1. Outcome & durable artifact

The customer leaves with a decision-ready, authorized test of one
customer-owned non-production agent/endpoint:

- the native Microsoft Foundry AI Red Teaming Agent scorecard;
- a customer-approved threshold-comparison sidecar, when a threshold review is
  performed; and
- a remediation, accepted-risk, blocked, or re-test decision with an owner.

Durable artifact: `labs/s8-red-teaming/` - the customer-operated Foundry
adapter contract and runbook. Native scorecards and comparison sidecars remain
ignored customer evidence in the approved records system.

!!! warning "Safety / authorization required"
    Do not run adversarial activity unless the SOC has been notified, written
    authorization and rules of engagement are approved, and the target is a
    customer-owned **NON-PRODUCTION** test agent/endpoint only.

## 2. Prerequisites

- Written authorization, rules of engagement, and a named SOC contact and
  monitoring window.
- A customer-owned non-production endpoint and an available endpoint owner.
- Foundry project access, the AI Red Teaming Agent <span class="rvas-badge rvas-preview">Preview</span>,
  and a customer-owned async target adapter. The kit contains no endpoint client
  or credentials.
- Customer-approved test categories, thresholds, evidence location, and decision
  owner. This kit deliberately does not ship a test dataset or threshold policy.

### Materials to prepare

- Authorization record and rules of engagement: target, timing, categories,
  permitted operators, stop conditions, monitoring contact, and evidence
  handling.
- Target context: non-production endpoint label, version, owner, rollback or
  reset path, and any dependencies that could create alerts or instability.
- Decision aids: approved ASR thresholds, category interpretation notes,
  remediation owner model, accepted-risk route, blocked path, and re-test
  criteria.
- Reference sources to validate before delivery: the AI Red Teaming Agent
  concept page, Foundry red-teaming run guidance, PyRIT documentation, and
  customer safety/evaluation standards.

## 3. Why this session

Adversarial testing is useful only when the target, success criteria, safety
limits, and response path are agreed before the first probe. S8 produces
evidence for the agreed scope, not a general claim that an agent is secure.

Read the [S8 Concepts](concepts.md) for authorization, ASR as a decision aid,
and the native-scorecard boundary.

## 4. Co-delivery walkthrough

!!! danger "Authorized test endpoint only"
    Stop if alerts, instability, or scope questions arise. Do not test
    third-party systems, production agents, user-facing workloads, or endpoints
    outside the written scope.

**Timebox:** 90 minutes within the approved monitoring window. **Entry
condition:** written authorization and rules of engagement are approved; the
SOC is notified with a contact and window; the target is confirmed
customer-owned and non-production; an endpoint owner can stop it; and customer
test categories, thresholds (if used), evidence location, and decision owner
are approved. Do not start or resume a scan if any condition expires or changes.

| Role | Workshop responsibility |
|---|---|
| Facilitator | Enforces the authorization and non-production boundary, timebox, and handoff; never operates the target or supplies test data. |
| Customer security/SOC lead | Confirms authorization, monitors the window, calls a stop, and leads the de-brief. |
| Customer endpoint owner / operator | Runs the customer adapter against the authorized target and pauses or resets it when required. |
| Evidence owner and decision owner | Retain native evidence references, interpret the agreed scope, and choose remediation, accepted risk, blocked status, or re-test. |

1. **Set the room and orient — 20 min.** Use
   `labs/s8-red-teaming/runbook.md`
   to confirm authorization, rules of engagement, SOC window, target label,
   stop conditions, and evidence boundary. The facilitator asks: *Is this
   exact target customer-owned and non-production? Who may stop the run? Which
   native scorecard and decision records will be authoritative?* Stop at
   pre-flight if any answer is absent or uncertain.
2. **Customer-operated authorized action — 30 min.** The endpoint owner runs
   the approved adapter only in the authorized window, or retrieves the
   completed run’s native scorecard for review if the scan cannot complete in
   this workshop. The customer operates credentials, target access, categories,
   and test data in its approved environment. Foundry’s
   `airt-native-scorecard.json` is preserved unchanged; this kit does not create
   a mock target, attack dataset, or replacement scorecard.
3. **Interpret together — 15 min.** The SOC lead and endpoint owner compare the
   native scorecard with the written scope, target version, categories, sample
   context, and any approved threshold review. Ask: *Was the run authorized and
   contained? What does each ASR mean for this category and sample? Did an alert,
   instability, or scope change require a stop?* An optional
   `airt-threshold-comparison.json` is a sidecar decision aid that references
   the native scorecard; it is not native evidence and does not establish
   security.

   Interpret each category as a bounded finding:

   | Result pattern | Decision prompt |
   |---|---|
   | Above threshold in an approved category | What remediation, owner, validation reference, and re-test date are required? |
   | Below threshold in all approved categories | What tested scope does this support, and what remains untested? |
   | Incomplete run, alert, instability, or scope drift | Should the result be blocked, stopped, or re-run under new authorization? |
   | Missing threshold or category owner | Who must approve the decision criteria before interpretation resumes? |
4. **Customer decision — 15 min.** The decision owner assigns a remediation
   owner and due date for each above-threshold category, or records accepted
   risk, **blocked**, or a re-test date through customer authority. A
   below-threshold result supports only the tested scope. No decision is
   available from a sidecar alone, an incomplete run, or an unauthorized,
   production, or out-of-scope target.
5. **Hand over — 10 min.** The evidence owner records safe references to the
   engagement authorization, rules of engagement, SOC window/de-brief, native
   scorecard and run metadata, optional comparison sidecar, and decision
   register. Hand remediation and residual gaps to the customer-owned backlog;
   retain endpoint cleanup and incident actions with their customer owners.

**Blockers:** missing or expired authorization, no SOC monitoring, production or
third-party target, unavailable endpoint owner, unavailable managed capability,
unapproved categories or thresholds, alerts, instability, or scope drift. Stop
the dependent action, retain only safe references and the stop rationale, assign
an owner and target date, and never replace the native path with a mock or
unapproved test.

## 5. Verification & evidence capture

- [ ] The native scorecard and run metadata are referenced in the approved
  customer records system.
- [ ] If a threshold review occurred, the comparison sidecar is retained with
  the native scorecard and above-threshold categories have owners and due dates.
- [ ] SOC de-brief records authorized alerts/incidents and any endpoint cleanup.
- [ ] The decision register records remediation, accepted risk, blocked status,
  or a re-test date.

## 6. Change boundary

S8 does not deploy a production control. The customer alone pauses, resets, or
changes its non-production endpoint and follows its own cleanup, incident, and
change processes.

## 7. Facilitator notes

- **Timing:** 90-minute workshop inside the monitoring window. The customer may
  schedule an authorized scan or SOC de-brief outside the workshop; do not
  compress, simulate, or continue an incomplete scan to fit the timebox.
- **RACI:** Security/SOC = R, Governance lead = A, AI developer/maker = C,
  endpoint owner = C.
- **Common blockers:** missing authorization/SOC notification, a production-only
  target, unavailable Preview capability, or unapproved thresholds all stop the
  run and become owned backlog items.
- **Hand-off:** the scorecard and decision feed the S6 residual-gap backlog.
