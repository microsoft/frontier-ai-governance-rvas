# Plan the engagement

Use this guide to prepare the S0-S13 AI Governance curriculum. The facilitator runs the method; customer administrators use their own tools, and customer decision owners approve changes and accept risk.

## Bring the right people

| Role | Main contribution |
|---|---|
| Executive sponsor | Sets direction, clears blockers, and accepts portfolio priorities. |
| Governance lead | Owns the operating model, evidence record, and improvement backlog. |
| Platform owner | Owns the platform path, trust-boundary decisions, and platform evidence. |
| Identity, data, and security administrators | Open and operate the relevant customer controls. |
| AI developer or maker | Explains agent implementation, testing, changes, and tool boundaries. |
| Evidence owner | Maintains evidence references, retention treatment, and decision traceability. |

## Establish the initial scope

Before S0, write down the first agent group or use-case question. Name the customer records location, decision owner, known architecture limits, and safe stop condition.

The customer may already have a platform path, or platform readiness may be a backlog item. Accept control readiness only from the customer record.

Before scheduling any session, use [Check whether a session is ready](../delivery/session-readiness.md).
It identifies the small amount of prework that keeps a 90-minute session focused
on a decision rather than missing prerequisites.

## Start with S0

S0 sets the baseline and roadmap. Run the assessment with the customer; use it for prioritization, not as a pre-engagement pass/fail gate.

Missing roles, records, licenses, platform evidence, or safe targets become readiness items with owners.

The assessment can select any S1-S13 session. Keep these dependencies:

- S3 sets the platform assumptions used by S4-S8.
- S4 admission standards feed S5 publication and later change decisions.
- S5 authority and exposure decisions feed S6-S10 assurance.
- S6-S8 require a customer-approved non-production target when live activity is proposed.
- S9 reconciles evidence from the earlier sessions you selected.
- S10 runs only when an in-process tool-call boundary exists.
- S11 uses customer-held operational evidence and decisions.
- S12 governs model and prompt operations where the customer can control or materially change those assets.
- S13 aggregates the selected session outcomes into the portfolio roadmap.

## Deliver safely

Start with the least disruptive posture: report-only access controls; simulated, test, or notify-mode data controls; and decisions before platform or engineering deployment. Runtime assurance, evaluation, and adversarial testing need an approved non-production or explicitly authorized target. Production promotion remains a customer change decision.

Before a privileged change, confirm the approver, window, rollback path, and evidence-retention route. Notify security operations before adversarial testing. See [How to Deliver](../how-to-deliver.md#non-production-hard-exit-gate) for the live-action exit gate.

## Evidence flow

| From | Evidence or decision | Used in |
|---|---|---|
| S0 | Baseline, operating model, and roadmap | All selected sessions; S13 roadmap refresh |
| S1-S2 | Authority and data findings | S3-S8 design and assurance context |
| S3-S5 | Platform, admission, and publication decisions | S6-S10 runtime and change context |
| S6-S8 | Runtime, evaluation, and adversarial findings | S9 reconciliation and S11 operating review |
| S9 | Reconciliation, lifecycle, and closure backlog | S10-S13 |
| S10 | Applicability or adoption decision | S11 operating backlog |
| S11 | Operating evidence, drift, cost, and remediation decisions | S12 operating-model decision and S13 portfolio review |
| S12 | Model/prompt operations decision, lifecycle gaps, and handoffs | S13 portfolio review |
| S13 | Portfolio decision and next roadmap | Next S0 cycle |

## Start the curriculum

Begin with [S0 · Foundations & Governance Operating Model](../s0-foundations/index.md). Use [How to Deliver](../how-to-deliver.md) and the individual session guides to plan the selected sequence.
