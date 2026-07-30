# NIST AI RMF delivery map

!!! info "Freshness"
    Last reviewed: 2026-07-27 · This page maps the AI Governance Platform workshops to the NIST AI Risk Management Framework functions for delivery planning. It is contextual guidance, not customer evidence, certification, legal advice, or a conformity assessment.

Use this map when a customer starts with NIST AI RMF terminology. It connects
each function to a customer question, a tangible outcome, and the smallest
useful set of workshops.

| NIST function | Customer question | Tangible outcome | Relevant workshops |
|---|---|---|---|
| **Govern** | Who owns the decision, exception, and operating cadence? | Named ownership, decision route, lifecycle responsibility, and review cadence. | [Governance baseline](../s0-foundations/index.md), [agent identity](../s1-identity/index.md), [control-plane reconciliation](../s9-control-plane/index.md), [portfolio roadmap](../s12-portfolio-governance/index.md) |
| **Map** | Which agents, data, identities, tools, platform boundaries, and lifecycle records are in scope? | A defined scope, evidence references, dependencies, and gaps that must be resolved before a decision. | [Identity](../s1-identity/index.md), [data path](../s2-data-compliance/index.md), [platform route](../s3-platform-foundation/index.md), [tool and API governance](../s5-tool-api-governance/index.md), [LLMOps change control](../s11-llm-operations/index.md) |
| **Measure** | Is safety, quality, runtime behavior, cost, or performance evidence strong enough to support the decision? | An evaluation, observation, or assurance result with its limitations and acceptance criteria. | [Agent admission](../s4-agent-engineering/index.md), [runtime assurance](../s6-security-runtime/index.md), [evaluation readiness](../s7-evaluation/index.md), [authorized red teaming](../s8-red-teaming/index.md), [operating evidence](../s10-operate-measure/index.md) |
| **Manage** | How do findings become remediation, accepted risk, an owned backlog item, or an operating decision? | A named next action, owner, due date, and customer process for change, risk, or backlog management. | [Data path](../s2-data-compliance/index.md), [platform route](../s3-platform-foundation/index.md), [runtime assurance](../s6-security-runtime/index.md), [evaluation readiness](../s7-evaluation/index.md), [control-plane reconciliation](../s9-control-plane/index.md), [portfolio roadmap](../s12-portfolio-governance/index.md) |

## Use the map

1. Start with the NIST function behind the customer's question.
2. Select the smallest workshops that can produce the stated outcome.
3. Confirm a decision owner, evidence reference, and next customer route before
   scheduling the work.

One workshop can support more than one NIST function. Do not use the map as a
coverage score or a claim that a control is deployed or operating. Completed
artifacts stay in the customer-approved records system with scope, owner,
limitations, review date, and decision route.
