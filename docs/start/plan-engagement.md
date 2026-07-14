# Plan the engagement

Use this guide to prepare and deliver the AI Governance engagement. The work is co-delivered: the facilitator frames the outcome and guides the process, while the customer's administrators perform privileged steps and approve changes in their own environment.

## Bring the right people

| Role | Main contribution |
|---|---|
| Executive sponsor | Sets direction, removes blockers, and accepts prioritisation decisions. |
| Governance lead | Owns the operating model, evidence record, and improvement backlog. |
| Platform owner | Confirms the Citadel or equivalent platform path and provides platform records. |
| Identity, data, and security administrators | Perform tenant configuration and review the resulting evidence. |
| AI developer or maker | Supplies representative agent behavior, test cases, and release context. |

The same person may hold more than one role. Name the responsible people before S0, even when they cannot all attend every session.

## Decide the platform path

Citadel is recommended for the full integrated path. Establish which of these states applies before dependent runtime validation:

| Current state | Delivery approach |
|---|---|
| Existing Citadel or equivalent platform | Record the platform owner, gateway or registry evidence, safety configuration, and telemetry location. |
| Citadel ready to deploy | Run deployment as a platform-team workstream. Keep it separate from the live governance sessions. |
| Platform readiness still needed | Schedule the platform work. Begin S0 ownership and baseline work; wait to run gateway-dependent validation until the platform path is available. |

Use the [Platform technical guide](../reference/platform-technical-guide.md) with the platform team when architecture or deployment detail is needed.

## Start with S0

The readiness assessment is performed during S0, not as a pre-engagement gate. Run the read-only tenant readiness report first and convert unavailable prerequisites into owned backlog items. The room then reviews the seven governance domains, records evidence for each score, and agrees the session order with the customer.

The detailed [Readiness Assessment](../assessment/index.md) explains the scoring scale and links to the fillable scorecard. S6 repeats the instrument to document the current state and remaining gaps.

## Deliver safely

Every session starts from the least disruptive posture that can produce useful evidence:

- Conditional Access starts report-only.
- DLP starts in test or notify mode.
- Evaluations and adversarial testing use a non-production or explicitly authorised target.
- Promotion to enforcement is a separate customer decision after impact review.

Before a privileged change, confirm a break-glass account, change window, named approver, and rollback. Notify the SOC before adversarial testing. Store exports, logs, policy definitions, and scorecards with the customer's governance record.

## Follow the session sequence

S0 establishes ownership and the baseline. S1 through S5 address the priority domains: identity, data, security, evaluation, and adversarial testing. S6 reconciles records across the platform and governance work, then records the remaining backlog.

The assessment may change the order after S0. Keep the dependencies visible: a session that relies on a missing role, license, platform record, or safe test target becomes an owned readiness item rather than an improvised workshop activity.

## Evidence flow between sessions

| From | Evidence | Used in |
|---|---|---|
| S0 | Baseline scorecard | S6 maturity comparison |
| S1 | Agent inventory | S6 registry reconciliation |
| S2 | Compliance findings | S3 posture context and S6 backlog |
| S3 | Defender recommendations | S5 scope and S6 backlog |
| S4 | Evaluation results | S5 scope and S6 exit assessment |
| S5 | ASR scorecard | S6 backlog and exit assessment |

## Start the curriculum

Begin with [S0 · Foundations & Operating Model](../s0-foundations/index.md). Each session page contains the prerequisites, co-delivery walkthrough, evidence capture, rollback, and facilitator notes.
