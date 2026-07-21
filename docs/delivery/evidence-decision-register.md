# Evidence and decision register

The governance lead owns the customer copy; the facilitator keeps it current through S12. Store links and identifiers rather than sensitive exports in meeting notes.

## Evidence boundary

Classify every artifact before using it in a decision:

| Class | What it proves | Examples |
|---|---|---|
| Reference only | The customer reviewed a reusable starting point. It does not prove a control exists. | Policy template, sample dataset, mock pipeline output, reference script. |
| Customer evidence | A customer environment, decision, or operating process produced the artifact. | Tenant export, policy re-export, approved change record, observation summary, test result. |
| Production-readiness evidence | The customer has enough material to take a specific change through its own approval process. It does not prove enforcement occurred. | Impact review, rollback plan, implementation plan, approval package. |

Do not label templates, samples, or offline mock results as deployed, observed, enforced, or production evidence.

## Register template

Use one row per control, prerequisite, finding, or exception.

| ID | Session / use case / agent | Item and control state | Evidence class and location | Gate or decision | Customer owner / approver | Next action and due date | Validation / recurrence / exception reference | Review date |
|---|---|---|---|---|---|---|---|---|
| GOV-001 | S1 / agent name | Sponsor register: Designed | Customer evidence: repository path | Customer change | Identity admin / governance lead | Apply report-only policy | Customer change validation and reapproval reference | YYYY-MM-DD |
| GOV-002 | S8 / endpoint name | Test target: Blocked | Customer evidence: authorization record | Non-production hard exit | Endpoint owner / SOC owner | Provide safe target and notify SOC | Blocker escalation and recurrence-review reference | YYYY-MM-DD |

## Minimum close record

Before S12 closes, confirm that the register points to:

- S0 baseline scorecard, roadmap, operating model, and RACI;
- available S1 through S8 evidence, including blocked or reference-only work;
- the S9 registry reconciliation, S0/S12 maturity comparison, and
  `compare.py` maturity-lift output;
- the S11 operating-review and remediation references;
- residual gaps with owners, due dates, and the next governance review;
- the S12 portfolio decision and next roadmap; and
- any production-readiness package handed to the customer change authority.

Apply the customer's retention, access, and data-classification rules to the register, links, and supporting artifacts.
