# Check whether a session is ready

Use this checklist before scheduling a selected S0-S13 session. It is a quick
go/no-go check, not another governance record. If an item is missing, record
the blocker, owner, and next date in the customer register. Do not use the
workshop to discover basic prerequisites.

## Every session needs these seven things

1. **One simple decision.** State the question and its possible result:
   approve, defer, reject, or route.
2. **The right people.** Name the decision owner, activity owner, evidence
   owner, and any specialist reviewer.
3. **A safe source.** Name the customer record, inventory, or environment that
   will be reviewed. Do not use a template as evidence.
4. **A technical default.** State the recommended Azure/Microsoft pattern and
   the equivalent control required if it does not fit.
5. **A stop condition.** Agree what would make the team defer or block the
   decision.
6. **A useful artifact.** Name the decision record, work package, or review
   that will be completed, including acceptance evidence and target date.
7. **A named handoff.** Name the next customer process or session that owns
   implementation or review.

If all seven are present, run the session. If not, prepare the missing item or
select another ready session.

## Session-specific checks

| Session | Confirm before the session |
|---|---|
| S0 | A bounded agent group or use case, sponsor, governance lead, and initial records location. |
| S1 | The identity inventory source, its coverage, its owner, and the agent platform or identity path in scope. |
| S2 | Data classification, data owner, applicable records, and whether a safe simulation or review is available. |
| S3 | Current architecture or platform evidence, platform owner, intended environment, and known trust-boundary decisions. |
| S4 | One bounded agent candidate, its technical owner, architecture summary, and the decision that needs to be made. |
| S5 | A bounded list of tools, APIs, or MCP services; their owners; caller identity; and current version or source. |
| S6 | An approved non-production route, test caller, test window, telemetry reviewer, and a safe way to correlate the request. |
| S7 | The accepted S6 proof when a gateway path is in scope, an evaluation-plan owner, and the decision the evidence will support. |
| S8 | Written authorization, rules of engagement, SOC contact, non-production target, stop conditions, and remediation owner. |
| S9 | A normalized agent and tool inventory, identity source, lifecycle policy, and owners for reconciliation findings. |
| S10 | One in-process tool-call boundary, the existing controls around it, and the application owner. |
| S11 | One workload population, one operating question, evidence coverage limits, and the owners who act on a signal. |
| S12 | One LLM application, stage owners for the inner and outer LLMOps loops, and approved data, evaluation, promotion, monitoring, and feedback routes. |
| S13 | The S0 baseline, in-scope portfolio records, open exceptions, and the sponsor decision needed next. |

## Product and platform checks

Before relying on a Microsoft product, confirm the customer has the required
tenant, licensing, region, and supported workload. If the product does not fit,
record the limitation and use an equivalent customer control or defer the
session. The [Governance capability guide](../reference/governance-capability-guide.md)
lists product-specific checks. The
[Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md)
defines the default control path, exception rule, and acceptance-test fields
each session should use.

## Record a blocker simply

| Missing item | Owner | Next date | Effect on delivery |
|---|---|---|---|
| | | | Run another session, prepare offline, or reschedule |
