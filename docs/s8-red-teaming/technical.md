# S8 · Adversarial Testing & Remediation — Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Red-teaming products, Prompt Shields, Content
    Safety, and related governance features change over time. Verify current
    status and availability in the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
    before delivery.

S8 is not only a red-team run. It forces three **technical decisions** that are
also governance decisions: *how adversarial testing is performed*, *what scope
and rules of engagement authorize it*, and *how findings are routed and retested*.

These are decision **menus**, not deployment steps: S8 changes nothing in
production, and the customer owns authorization, evidence, remediation, and any
future implementation.

## Decision 1 — Red-team approach & tooling

Choose against authorization, repeatability and coverage, in-house skill,
evidence needs, cost, and cadence. Named products and features require a
current-status check before use.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Automated Microsoft path** (AI Red Teaming Agent / PyRIT) | Repeatable category coverage is needed for an authorized non-production target | Availability, supported scenarios, and adapter work must be verified; automation does not replace judgment | Record approved tool path, operator, evidence owner, and what the run does not cover |
| **Manual expert red-teaming** | Novel behaviors, high-risk workflows, or business-context attacks need expert exploration | Less repeatable; depends on scarce skill and careful scope control | Record expert role, authorization boundary, notes retained, and how findings become backlog |
| **Third-party engagement** | Independence, specialist depth, regulatory expectation, or surge capacity is required | Cost, procurement, data handling, and evidence-sharing constraints | Record provider scope, legal approval, evidence location, and customer owner for remediation |
| **Mixed approach** | Baseline repeatability and expert depth are both needed | More coordination and duplicated evidence paths | Record which method owns which category and how results reconcile |

## Decision 2 — Scope & rules of engagement

The governing test is whether the target, timing, operators, categories, stop
conditions, evidence handling, and legal/SOC authorization are explicit before
testing begins.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Non-production bounded test** | The customer can name the endpoint, version, owner, monitoring window, and rollback/reset path | Findings support only the tested scope | Default S8 path; record target, categories, SOC contact, stop conditions, and evidence references |
| **Production-like staging scope** | Risk tier or regulatory expectation needs realistic integrations without customer-facing production impact | Higher blast-radius planning and monitoring are required | Record dependencies, alert handling, data limits, and explicit authorization |
| **Production exception assessment** | A customer authority requires limited testing of a live system under formal process | Not a workshop run; legal, SOC, business, and change approvals are mandatory | Record as deferred to the customer process; S8 may define criteria but does not execute it |
| **Blocked / not authorized** | Authorization, target ownership, non-production status, or rules of engagement are missing | No test evidence is produced | Valid decision; record blocker, owner, target date, and S12 portfolio impact |

## Decision 3 — Remediation routing & retest

Choose the response path against finding severity, technical owner, verification
evidence, and whether the fix belongs in prompt, gateway, runtime, tool, or
lifecycle controls.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Safety filter / shielding control** (Content Safety / Prompt Shields) | Findings map to supported harmful-content, prompt-injection, or input/output filtering controls | Feature availability and coverage must be verified; filters do not prove the agent is safe | Record control owner, configured scope, residual risk, and retest evidence |
| **Prompt or system-instruction hardening** | The weakness is caused by role framing, refusal criteria, grounding, or response policy | Can be brittle; needs regression tests and version ownership | Record prompt owner, change route, before/after evidence, and retest date |
| **Gateway or in-process policy control** | Tool calls, data access, or high-authority actions need enforcement before execution | Adds platform or code ownership; verify relevant S10 capability status before adoption | Route to S6/S10 backlog with owner, approval path, and evidence requirement |
| **Tool-permission reduction / lifecycle block** | Excessive agency, data exfiltration, or tool abuse shows the agent has too much authority | May reduce functionality or delay release | Record permission owner, S9 lifecycle impact, accepted-risk or release-block decision, and retest criteria |

## Decisions made & adoption progress

S8 should move the customer from the adversarial and security part of the **S0
maturity baseline** toward the **S12 portfolio** view with an adversarial-testing
decision and remediation backlog.

| Adoption stage | What "done" looks like at S8 |
|---|---|
| **Decided** | The red-team approach, authorized scope/rules of engagement, and remediation-routing path are chosen for the bounded target |
| **Backlogged** | Findings, blockers, retest needs, and S6/S10 controls or S9 lifecycle updates are routed with owners and evidence references |
| **In adoption** | Customer teams remediate and retest outside this session; portfolio owners track status and residual risk through S12 |

Record the choice, alternatives considered, authorization caveat, and adoption
stage in `labs/s8-red-teaming/templates/technical-decision-record.template.md`.
What S8 leaves behind is the decision plus the remediation backlog, not a
production change.

## Related references

- [S8 Concepts](concepts.md) — authorization, Attack Success Rate, native scorecard boundaries, and remediation backlog.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) — Prompt Shields, Defender, and ASSERT context.
- [Governance capability guide](../reference/governance-capability-guide.md) — current availability context for governance and testing capabilities.
- [Platform technical guide](../reference/platform-technical-guide.md) — gateway and in-process control boundaries.
