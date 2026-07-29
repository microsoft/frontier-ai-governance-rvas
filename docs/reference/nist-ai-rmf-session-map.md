# NIST AI RMF session map

!!! info "Freshness"
    Last reviewed: 2026-07-27 · This page maps the S0-S13 curriculum to the NIST AI Risk Management Framework functions for delivery planning. It is contextual guidance, not customer evidence, certification, legal advice, or a conformity assessment.

Use this map when a customer starts from the NIST AI RMF nomenclature instead of the S0-S13 sequence. It shows which working sessions can help frame, inspect, measure, or route a customer-owned governance decision.

The mapping is based on the session outcomes and handoffs in this curriculum:

- **Govern** sessions establish ownership, accountability, policy routes, lifecycle decisions, or operating cadence.
- **Map** sessions identify the system, data, identity, platform, model, tool, lifecycle, or portfolio context that must be understood before a decision.
- **Measure** sessions evaluate quality, safety, runtime behavior, cost, drift, performance, or assurance evidence.
- **Manage** sessions turn findings into remediations, accepted risks, backlog items, operating reviews, or improvement routes.

## Session coverage matrix

| Session | Govern | Map | Measure | Manage |
|---|:---:|:---:|:---:|:---:|
| [S0 · Governance Baseline & Operating Model](../s0-foundations/index.md) | ✓ | ✓ |  |  |
| [S1 · Agent Identity Path](../s1-identity/index.md) | ✓ | ✓ |  | ✓ |
| [S2 · Data-Path Trace & Control Map](../s2-data-compliance/index.md) |  | ✓ |  | ✓ |
| [S3 · Platform Route & Trust Boundaries](../s3-platform-foundation/index.md) | ✓ | ✓ |  | ✓ |
| [S4 · Agent Build Path & Admission](../s4-agent-engineering/index.md) | ✓ | ✓ | ✓ |  |
| [S5 · Tool/API Admission & Withdrawal](../s5-tool-api-governance/index.md) | ✓ | ✓ |  | ✓ |
| [S6 · Runtime Path Evidence & Response](../s6-security-runtime/index.md) |  |  | ✓ | ✓ |
| [S7 · Evaluation Evidence & Release Readiness](../s7-evaluation/index.md) |  |  | ✓ | ✓ |
| [S8 · Authorized Red Teaming & Retest](../s8-red-teaming/index.md) | ✓ |  | ✓ | ✓ |
| [S9 · Control-Plane Reconciliation & Lifecycle](../s9-control-plane/index.md) | ✓ | ✓ |  | ✓ |
| [S10 · In-Process Tool-Call Controls](../s10-in-process-governance/index.md) | ✓ |  | ✓ | ✓ |
| [S11 · Operating Evidence & FinOps](../s11-operate-measure/index.md) | ✓ |  | ✓ | ✓ |
| [S12 · LLMOps Change Control](../s12-llm-operations/index.md) | ✓ | ✓ | ✓ | ✓ |
| [S13 · Portfolio Evidence & Roadmap](../s13-portfolio-governance/index.md) | ✓ | ✓ | ✓ | ✓ |

## How to use this map

Start with the function the customer is asking about, then pick the smallest session set that can produce a named decision owner, evidence reference, and next route.

| If the customer asks... | Start with... | Then check... |
|---|---|---|
| Who owns AI-agent decisions and exceptions? | S0, S1, S9, S13 | Whether S11 needs an operating cadence. |
| What systems, data, tools, and lifecycle records are in scope? | S1, S2, S3, S5, S9, S12 | Whether S13 needs a portfolio-level view. |
| How do we evaluate safety, quality, runtime behavior, or cost? | S4, S6, S7, S8, S10, S11, S12 | Whether S4 or S7 owns release thresholds. |
| How do findings become action? | S2, S3, S5, S6, S7, S8, S9, S10, S11, S12, S13 | Whether the customer has an approved change, risk, or backlog route. |

This page does not prove that a customer control is deployed or operating. Completed session artifacts should stay in the customer-approved records system with scope, owner, limitations, review date, and decision route.
