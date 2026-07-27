# Practical workshop: foundations decision route

**Microsoft default:** Cloud Adoption Framework for AI, Well-Architected Framework for AI, and AI Center of Excellence guidance.

**Customer decision:** Approve, defer, reject, or route one bounded AI-governance foundation decision. This is an operating-model and handoff decision only; it does not change tenant policy, prove runtime enforcement, or approve production use.

## Work the decision

1. **Choose the foundation question.** Select one bounded pilot, portfolio slice, or backlog item. Name the decision owner, implementation owner, evidence owner, receiving forum, and customer-approved records location before reviewing evidence.
2. **Map the baseline.** Reference the customer's current governance charter, AI CoE or equivalent forum, RACI, risk appetite, control-framework baseline, exception path, and decision register. If there is no baseline, record a baseline-gap backlog item instead of approving the decision.
3. **Classify the route.** Pick the route that best fits the scenario before discussing acceptance:

| Scenario | Route | Practical decision cue |
|---|---|---|
| No accountable owner or decision forum | Ownership blocker | Defer until the accountable owner, approval forum, receiving process, and target review date are named. |
| Split ownership across CoE, security, data, platform, or business teams | Split-ownership route | Route the decision to the forum that can resolve accountability. Record interim owners, affected controls, and who accepts the handoff. |
| Missing baseline framework or operating-model record | Baseline gap | Defer until the chosen Microsoft baseline, customer policy mapping, scope, evidence location, owner, target date, and recheck trigger are recorded. |
| Exception path is unclear | Exception-route gap | Route to the risk or governance forum that can accept residual risk. Record reason, equivalent control, owner, acceptance test, and review trigger. |
| Backlog item lacks acceptance criteria | Handoff gap | Defer until the backlog item names the gap owner, accepted-when check, target date, evidence reference, and receiving owner. |
| Baseline exists but needs later re-baseline | Re-baseline trigger | Approve only the bounded handoff, and record which change in scope, risk, regulation, portfolio priority, or S13 decision triggers S0 re-baseline. |

4. **Inspect evidence by reference only.** Use customer-approved records for the governance charter, decision forum minutes/reference, RACI, control-framework baseline, exception register, and backlog. Do not copy customer evidence into this repository.
5. **Record the outcome and handoff.** Approve only when the forum, baseline, record location, gap owner, target date, recheck trigger, and receiving owner are complete. Otherwise defer with a specific acceptance test, reject if the proposed path cannot meet the bounded scope, or route to the accountable owner/forum.

## Decision record

Fill this record in the customer-approved records system. Store only safe references here; completed evidence remains in customer systems.

| Field | Record |
|---|---|
| Work item | Foundation operating-model decision |
| Decision forum | Named customer governance forum, approval path, and meeting/review cadence reference |
| Baseline framework | Cloud Adoption Framework for AI, Well-Architected Framework for AI, AI CoE guidance, or mapped customer baseline reference |
| Operating model / RACI | Accountable owner, implementation owner, evidence owner, consulted teams, receiving process, and split-ownership notes |
| Decision-register location | Customer-approved record location and reference format |
| Gap or blocker | Missing owner/forum, split ownership, missing baseline, unclear exception path, or missing acceptance criteria |
| Acceptance checks | Forum named, baseline mapped, record location identified, gap owner assigned, target date set, recheck trigger recorded, and handoff accepted |
| S13 dependency | Portfolio decision, risk/value conflict, roadmap change, or capacity/cost decision that would trigger S0 re-baseline |
| Handoff | Owner and customer process that accepts the decision or backlog item |

## Decision tree

- **Approve** when the governance forum is named, baseline is mapped, decision record location is known, gap owner and target date are recorded where needed, and the receiving owner accepts the handoff.
- **Defer** when an owner, forum, baseline, record location, acceptance test, target date, or recheck trigger is missing.
- **Reject** when the proposed operating model cannot meet the bounded scope or leaves accountability unresolved.
- **Route** when another customer governance, risk, security, data, platform, finance, or business owner must decide first.

For an exception, record: reason, affected operating-model control, equivalent customer-owned control if one exists, owner, evidence location reference, acceptance test, target date, receiving forum, and review trigger.

## Acceptance checks

| Check | Accepted when... | Handoff |
|---|---|---|
| Forum named | the accountable decision forum, approval path, cadence, and escalation owner are recorded by reference | Governance lead |
| Baseline mapped | the Microsoft or customer baseline framework is mapped to the bounded scope, with known exclusions or gaps | Baseline owner |
| Record location | the decision register and evidence-reference location are customer-approved and accessible to the receiving owner | Evidence owner |
| Gap owner | each missing owner, split-ownership issue, baseline gap, or unclear exception path has a named owner and backlog item | Receiving process owner |
| Target and recheck | each defer or route item has a target date and recheck trigger tied to a forum, portfolio event, or scope change | Governance forum |
| Handoff clarity | the next owner can accept, reject, or route the backlog item using the acceptance test without additional workshop context | Implementation owner |
| Workshop safety | the activity records decisions only, copies no customer evidence into the repository, changes no tenant policy, and makes no deployment, enforcement, runtime-proof, or production-approval claim | Workshop facilitator |

**Boundary:** Keep customer evidence in customer-approved systems; store references only. This workshop records operating-model decisions and handoffs only.
