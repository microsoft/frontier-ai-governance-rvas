# Facilitate the decision

| Phase | Time | Concrete output | Facilitator prompt |
|---|---:|---|---|
| Curation | 10 min | Data purpose, owner, provenance/limit, and S2 route. | "What data is fit for the next learning step, and who approved that use?" |
| Experimentation | 10 min | Hypothesis, candidate reference, population, and experiment owner. | "What are we trying to improve, and what result would change our mind?" |
| Evaluation | 10 min | Scenario/rubric, coverage, threshold owner, and S7 gate. | "What does this result prove, and what does it not prove?" |
| Deploy and inference | 15 min | DEV/PRE/PRO path, release manifest, service route, and rollback target. | "What evidence is required before this candidate can advance?" |
| Monitor and feedback | 15 min | Signal/coverage, response owner, feedback purpose, and curation rule. | "Who interprets this signal, and how does feedback become governed learning?" |
| Decide and hand over | 30 min | Change decisions, implementation backlog, limitations, target dates, and review date. | "Where can the lifecycle bypass a gate today?" |

Keep the discussion practical. Every stage must end with a named owner, approved
record, one artifact, one gate, acceptance evidence, target date, and handoff.

**Decision question:** Does this bounded workload have a controlled inner and
outer loop? Record **approve, defer, reject, or route**. The Azure/Microsoft
default is protected source and customer change control, Microsoft Foundry
evaluation/observability where supported, and Azure Monitor/Application
Insights for operations. An exception needs a documented customer service,
coverage, owner, and acceptance criterion. Verify current availability.

The release manifest must reconstruct the active route: service release,
candidate artifact, deployment alias, evaluation decision, change decision, and
rollback target. S12 hands off to S2, S4, S7, and S11; it approves neither a
customer-system change nor production.
