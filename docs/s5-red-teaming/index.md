# S5 · Adversarial Testing

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

Durable artifact: `labs/s5-red-teaming/` - the customer-operated Foundry
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

## 3. Why this session

Adversarial testing is useful only when the target, success criteria, safety
limits, and response path are agreed before the first probe. S5 produces
evidence for the agreed scope, not a general claim that an agent is secure.

Read the [S5 Concepts](concepts.md) for authorization, ASR as a decision aid,
and the native-scorecard boundary.

## 4. Co-delivery walkthrough

!!! danger "Authorized test endpoint only"
    Stop if alerts, instability, or scope questions arise. Do not test
    third-party systems, production agents, user-facing workloads, or endpoints
    outside the written scope.

1. **Pre-flight** *(facilitator + <span class="rvas-badge rvas-persona">Security / SOC</span>)* -
   use `labs/s5-red-teaming/runbook.md` to confirm SOC notification,
   authorization, rules of engagement, target URI/name, time window, and
   endpoint owner.
2. **Run the customer-operated path** - the customer implements
   `customer_redteam_adapter:target(prompt, endpoint)` in its approved codebase
   and runs:
   ```bash
   python labs/s5-red-teaming/scripts/redteam-airt.py \
     --azure-ai-project "$AZURE_AI_PROJECT_ENDPOINT" \
     --target-endpoint "https://<customer-non-production-endpoint>" \
     --target-adapter customer_redteam_adapter:target
   ```
   Foundry owns `evidence/airt-native-scorecard.json`; the kit does not rewrite
   it.
3. **Review thresholds separately** - if the customer has an approved review
   that transcribes category ASRs from the native scorecard, pass it with
   `--threshold-review`. The kit writes only the ignored
   `airt-threshold-comparison.json` sidecar; it never substitutes that sidecar
   for the Foundry scorecard.
4. **Triage and hand off** - assign remediation owners and due dates for
   above-threshold results, complete the SOC de-brief, and record the governance
   decision in the approved decision register.

## 5. Verification & evidence capture

- [ ] The native scorecard and run metadata are referenced in the approved
  customer records system.
- [ ] If a threshold review occurred, the comparison sidecar is retained with
  the native scorecard and above-threshold categories have owners and due dates.
- [ ] SOC de-brief records authorized alerts/incidents and any endpoint cleanup.
- [ ] The decision register records remediation, accepted risk, blocked status,
  or a re-test date.

## 6. Change boundary

S5 does not deploy a production control. The customer alone pauses, resets, or
changes its non-production endpoint and follows its own cleanup, incident, and
change processes.

## 7. Facilitator notes

- **Timing:** ~half day. Authorization + pre-flight ~45 min, scan execution
  ~60 min, scorecard review and remediation planning ~60 min, SOC de-brief
  ~30 min.
- **RACI:** Security/SOC = R, Governance lead = A, AI developer/maker = C,
  endpoint owner = C.
- **Common blockers:** missing authorization/SOC notification, a production-only
  target, unavailable Preview capability, or unapproved thresholds all stop the
  run and become owned backlog items.
- **Hand-off:** the scorecard and decision feed the S6 residual-gap backlog.
