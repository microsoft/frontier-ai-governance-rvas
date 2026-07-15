# Plan the engagement

Use this guide to prepare and deliver the S0-S12 AI Governance curriculum. The
facilitator guides the method; customer administrators perform privileged
activities, and customer decision owners approve changes and accept risk.

## Bring the right people

| Role | Main contribution |
|---|---|
| Executive sponsor | Sets direction, resolves blockers, and accepts portfolio priorities. |
| Governance lead | Owns the operating model, evidence record, and improvement backlog. |
| Platform owner | Owns the platform path, trust-boundary decisions, and platform evidence. |
| Identity, data, and security administrators | Review and operate the relevant customer controls. |
| AI developer or maker | Explains agent implementation, testing, changes, and tool boundaries. |
| Evidence owner | Maintains references, retention treatment, and decision traceability. |

## Establish the initial scope

Before S0, record the bounded agent population or use-case question, customer
records location, decision owner, known architecture constraints, and safe stop
condition. The customer may begin with an existing platform path or identify
platform readiness as a backlog item; neither case justifies inferring that a
platform control is deployed.

## Start with S0

S0 establishes the baseline and roadmap. The assessment is performed with the
customer, not used as a pre-engagement pass/fail gate. Missing roles, records,
licenses, platform evidence, or safe targets become owned readiness items.

The assessment can select any S1-S12 session. Preserve hard dependencies:

- S3 informs the platform assumptions used by S4-S8.
- S4 admission standards inform S5 publication and later change decisions.
- S5 authority/exposure decisions inform S6-S10 assurance.
- S6-S8 require a customer-approved non-production target when live activity
  is proposed.
- S9 reconciles the evidence from selected earlier sessions.
- S10 runs only when an in-process tool-call boundary is meaningful.
- S11 and S12 use customer-held evidence and decisions; they do not require a
  platform implementation to start.

## Deliver safely

Every session starts from the least disruptive posture that can produce useful
evidence:

- access controls start report-only;
- data controls start in simulation, test, or notify mode;
- platform and engineering sessions record decisions rather than deploy;
- runtime assurance, evaluation, and adversarial testing use an approved
  non-production or explicitly authorised target; and
- production promotion remains a separate customer change decision.

Before a privileged change, confirm the customer approver, change window,
rollback, and evidence-retention route. Notify security operations before
adversarial testing.

## Evidence flow

| From | Evidence or decision | Used in |
|---|---|---|
| S0 | Baseline, operating model, and roadmap | All selected sessions; S12 roadmap refresh |
| S1-S2 | Authority and data findings | S3-S8 design and assurance context |
| S3-S5 | Platform, admission, and publication decisions | S6-S10 runtime and change context |
| S6-S8 | Runtime, evaluation, and adversarial findings | S9 reconciliation and S11 operating review |
| S9 | Reconciliation, lifecycle, and closure backlog | S10-S12 |
| S10 | Applicability/adoption decision | S11 operating backlog |
| S11 | Operating evidence, drift, cost, and remediation decisions | S12 portfolio review |
| S12 | Portfolio decision and next roadmap | Next S0 cycle |

## Start the curriculum

Begin with [S0 · Foundations & Governance Operating Model](../s0-foundations/index.md).
Use [How to Deliver](../how-to-deliver.md) and the individual session guides
to plan the selected sequence.
