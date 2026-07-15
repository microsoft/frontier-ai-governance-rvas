# S2 Data & Compliance Review Checklist

> **Boundary:** this is a review-and-decision session. It does not deploy,
> export, roll back, or simulate a Purview policy from this repository.

## 1. Scope the pilot path

- [ ] Name the representative non-production agent and its accountable sponsor.
- [ ] Trace its input data, retrieval sources, tool outputs, and user-facing
  responses.
- [ ] Record the data classifications and regulated-data concerns that apply.
- [ ] Confirm the Compliance/Data administrator and investigation owner.

## 2. Review the customer tenant

- [ ] Review applicable **DSPM for AI** findings and record the customer
  records-system reference, including an empty-result or unavailable-capability
  outcome where applicable.
- [ ] Confirm which AI workloads, locations, and data types are supported by
  the tenant's current **DLP** configuration.
- [ ] Confirm where **Audit** and **eDiscovery** can locate the relevant AI
  interactions, administrative changes, and review records.
- [ ] Record any dependency on IRM, Communication Compliance, labels, or a
  gateway data-protection control.

## 3. Make the control decision

For each proposed DLP or data-protection change, the customer records:

| Decision input | Required record |
|---|---|
| Scope | Approved workload, data type, location, and pilot path |
| State | `designed`, `report_only_deployed`, `observed`, `approved_for_enforcement`, `enforced`, `accepted_risk`, or `blocked` |
| Owner and approver | Named customer roles |
| Evidence | Reference to the approved customer records system, not a copied payload |
| Observation | Report-only duration, review date, and false-positive owner |
| Change safety | Customer change, rollback, communication, and verification references |

## 4. Handoff

- [ ] Add evidence references and classification/retention metadata to the
  generated workspace's `04-operate/evidence-register.json`.
- [ ] Add the control decision, risk owner, approver, and review date to
  `04-operate/decision-register.json`.
- [ ] If a policy change is proposed, hand it to the customer's approved change
  process in report-only mode. Do not promote enforcement in this workshop.
- [ ] Add unresolved exposure, licensing, workload-coverage, or retention gaps
  to the S6 residual-gap backlog.
