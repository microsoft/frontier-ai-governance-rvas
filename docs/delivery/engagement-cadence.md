# Engagement cadence

Use this as the facilitator's planning view. It assumes a six-week core programme and allows two additional weeks for customer change approval, observation, or blocked dependencies.

## Six-week core

| Week | Governance delivery track | Customer change and observation track | Required outcome |
|---|---|---|---|
| 1 | Mobilise and run S0. Complete the baseline, operating model, session order, and engagement register. | Confirm roles, evidence location, platform path, access, licensing, and change route. | Signed baseline and owned prerequisite backlog. |
| 2 | Run S1 and S2 where ready. Review inventories, sponsors, DSPM findings, and tenant-specific policy definitions. | Submit customer-owned report-only Conditional Access and DLP simulation changes if approved. | Identity and data evidence; observation start dates if controls are applied. |
| 3 | Run S3 and S4 where their prerequisites pass. Review security posture, safe runtime-test readiness, datasets, thresholds, and evaluation approach. | Complete platform work, configure safe test targets, and collect S1/S2 observation evidence. | Security and evaluation evidence; blocked runtime work is recorded. |
| 4 | Review observation results. Run S5 only when its authorization and non-production gate pass. | Continue report-only, simulation, and non-production evaluation observation. Triage findings and prepare remediation changes. | Authorized ASR evidence or a recorded reason S5 did not run. |
| 5 | Reconcile evidence, confirm control states, and prepare S6 inputs. | Owners close evidence gaps, validate rollback material, and prepare any requested production-readiness packages. | Complete evidence and decision register. |
| 6 | Run S6: registry reconciliation, exit assessment, `compare.py` output, residual backlog, and sponsor review. | Customer accepts the backlog and takes production-readiness packages through its own change authority. | Close package and next governance review date. |

## Weeks seven and eight

Use these weeks when the customer needs longer policy observation, a platform workstream, additional remediation, or scheduling for the sponsor review. Optional S7 can run after S6 during this period. Do not use the extension to delay the core close.

## Facilitator rhythm

Hold a short working review each week with the governance lead. Review:

- items that passed or failed a gate;
- evidence received, missing, or unsuitable for the stated control state;
- customer-owned changes and observation dates; and
- decisions or risks that need sponsor escalation.

Keep technical working sessions separate from approval meetings. The facilitator can prepare a decision, but the customer approves tenant changes and accepts risk.

## When the plan changes

Move an unready session rather than improvising around a missing license, role, platform record, or safe target. Update the session order, dependency, owner, and target date in the register. Preserve S0 first, S6 last, and S7 after S6.
