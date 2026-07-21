# S12 · Portfolio Governance & Continuous Improvement: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Portfolio governance, reporting, analytics,
    and AI-governance capabilities change over time. Verify current status,
    availability, licensing, and limitations in the [Governance capability guide](../reference/governance-capability-guide.md)
    and official product documentation before delivery.

Choose portfolio reporting, prioritization, and review cadence. S12 produces a
roadmap of decisions, deferrals, owners, and review evidence, not a dashboard or
policy change.

## Decision 1: Portfolio system of record & reporting

Choose the reporting pattern against the executive audience, review cadence,
data sources, effort, and auditability required for the portfolio decision.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Executive scorecard or dashboard** | Leaders need a concise view of roadmap status, recurring exceptions, investment priorities, and maturity movement | Can hide evidence limits if it becomes a summary without references; any reporting product or feature must be verified for current availability and fit | Good for governance rhythm and decisions, if every score links back to customer-held evidence and coverage limits |
| **Control-register rollup from S9** | The portfolio question is mainly about control coverage, exception concentration, and reconciliation across cataloged agents | May over-focus on controls and miss investment, maturity, or policy-evolution decisions | Keeps auditability close to the governed control record; record what S9 covers and what it excludes |
| **BI on governance evidence references** | The customer already has governed evidence, cost, quality, or operating-review references that can be analyzed without copying raw records | Higher data-model and ownership effort; analytics can imply precision that the evidence does not support | Useful for trends and prioritization only when scope, freshness, lineage, and interpretation ownership remain visible |
| **No new portfolio system yet** | The immediate need is a one-cycle roadmap decision and the approved records system is sufficient | Less automation and repeatability; future reviews may take more manual effort | Valid if recorded deliberately, with a backlog item for reporting ownership and next cadence |

## Decision 2: Prioritization & reinvestment model

Choose the next-roadmap model against portfolio size, strategic goals, risk
appetite, and how the review re-baselines against the S0 maturity assessment.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Risk-weighted prioritization** | The portfolio contains material exceptions, high-authority agents, regulatory exposure, or shared control weaknesses | Can under-prioritize adoption blockers or business-value enablers | Routes investment toward risk reduction, owner readiness, and assurance gaps with explicit remaining-risk disposition |
| **Value- and adoption-weighted prioritization** | The roadmap must improve adoption, operating usefulness, or repeatable governance outcomes across many teams | Can overstate benefit if value evidence is weak or not yet measured | Makes expected governance value and adoption dependency explicit; funding remains a separate customer decision |
| **Maturity-gap-driven prioritization** | S12 is closing the S0→S12 loop and the next roadmap should target domains that did not move or remain unsupported | Can miss urgent exceptions if used alone | Directly re-baselines against S0 and identifies which domains, questions, and evidence must be reassessed next |
| **Hybrid portfolio triage** | The portfolio has mixed risk, value, maturity, and dependency pressures that no single model can rank fairly | Requires clear weighting, owner agreement, and visible assumptions | Best fit for executive roadmap selection when the chosen weighting and rejected alternatives are recorded |

## Decision 3: Continuous-improvement cadence & metrics

Choose the operating rhythm, portfolio KPIs, governance review cadence, and
maturity re-measurement approach against staffing and regulatory reporting needs.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Quarterly portfolio review** | The organization needs a regular executive cadence for roadmap decisions, exception patterns, and owner follow-up | May be too slow for fast-moving or high-risk portfolios | Sets a predictable governance rhythm; record the decision owner, inputs, and S0 questions to revisit |
| **Event-driven review** | Material changes, major exceptions, regulatory deadlines, or new high-authority agents should trigger review | Can become reactive and inconsistent without a minimum cadence | Keeps escalation close to risk events; define triggers and what evidence must be refreshed |
| **Metric-led continuous improvement** | Portfolio KPIs such as exception aging, evidence freshness, adoption progress, maturity movement, and roadmap throughput are available | Metrics can become theatre if definitions, owners, and evidence limits are weak | Supports trend review only when every metric has a customer owner, source reference, and interpretation rule |
| **Regulatory-reporting-aligned cadence** | External reporting, audit, or assurance cycles drive the review calendar | May optimize for reporting dates rather than operational learning | Aligns evidence refresh and decision records to assurance needs without turning S12 into certification |

## Decisions made & adoption progress

S12 closes the S0→S12 thread by aggregating the per-session technical-decision
records, adoption-progress rows, exceptions, and evidence references into the
portfolio roadmap and next S0 re-baseline.

| Adoption stage | What "done" looks like at S12 |
|---|---|
| **Decided** | The portfolio reporting pattern, prioritization model, and continuous-improvement cadence are chosen with scope, rationale, assumptions, and rejected alternatives recorded |
| **Backlogged** | Reporting ownership, reinvestment actions, policy questions, exception concentrations, and S0 re-baseline evidence needs are routed to named customer processes |
| **In adoption** | Prior-session decisions and adoption-progress rows are being executed outside this session; S12 tracks portfolio progress and sets the next roadmap review |

Capture the portfolio choice, alternatives, and adoption stage in the technical
decision record (`labs/s12-portfolio-governance/templates/technical-decision-record.template.md`);
it is the customer-owned rollup of the decisions feeding the next roadmap.

## Related references

- [S12 Concepts](concepts.md): portfolio evidence limits, exception concentration, prioritization, maturity movement, and the S0 feedback loop.
- [Governance capability guide](../reference/governance-capability-guide.md): current availability and limitation context for Microsoft governance capabilities.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md): policy, control, visibility, and proof sources that support portfolio learning.
- [Quality, cost, latency & rollout guide](../reference/quality-cost-latency-guide.md): criteria for interpreting model and roadmap investment proposals.
