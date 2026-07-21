# S2 Data & Compliance Review Checklist

> **Boundary:** this is a review-and-decision session. It does not deploy,
> export, roll back, or simulate a Purview policy from this repository.

## Activity card

**90 minutes.** Facilitator keeps the timebox and evidence boundary;
Compliance/Data administrator performs the customer action; governance lead or
delegated risk authority decides; evidence owner retains references; pilot-agent
owner maps the path; Audit/eDiscovery investigator or legal specialist confirms
the investigation route.

**Entry condition:** bounded representative AI path, approved customer evidence
location, named investigation route/owner, Compliance/Data administrator, and
decision owner. If an entry condition is absent, record the dependency, owner,
target date, and impact; stop the dependent step. Evidence stays in the
customer-approved system, never use a mock, facilitator note, or copied payload
as proof.

**Customer action:** review actual supported tenant evidence for one path,
decide its safe next control state, and hand off a verifiable investigation
route. This is not a product tour or policy-creation exercise.

## 1. Set the evidence and investigation question *(10 min)*

- [ ] Customer states the question: “What sensitive-data exposure and
  investigation evidence must this path support?” Record pilot, sponsor, safe
  posture, evidence reference, decision owner, and stop condition.

## 2. Customer maps the path and dependencies *(15 min)*

- [ ] Customer traces input data, retrieval sources, tool outputs, user-facing
  responses, locations, classifications, and regulated-data concerns.
- [ ] Facilitator asks: “Where can sensitive data enter, persist, or leave?”;
  “What classification/label is expected?”; and “Which permission or runtime
  control changes the exposure?”
- [ ] Record dependencies on classification/labels, source permissions, DLP
  workload/location support, audit retention, eDiscovery permissions/holds,
  IRM/Communication Compliance where applicable, and separate gateway
  protection. Do not treat a gateway control as Purview DLP coverage.
- [ ] Meaningful result: bounded path and named investigation route. Blocked:
  no record location, activity owner, or investigation owner; assign
  owner/date and stop the dependent activity.

## 3. Customer reviews DSPM for AI evidence *(20 min)*

- [ ] Review applicable **DSPM for AI** findings and record the customer
  records-system reference, scope, date, reviewer, and interpretation.
- [ ] Ask: “What does this finding cover?”, “What does it exclude?”, and “What
  later reviewer can verify our interpretation?”
- [ ] Classify the outcome explicitly:
  - **Result:** scoped finding/posture evidence with an interpretation.
  - **No-result:** no in-scope finding after the checked scope/date/reviewer is
    recorded; it does not prove absence of exposure.
  - **Unsupported:** documented workload/capability limitation; record the
    supporting documentation reference and alternative-control owner.
  - **Blocked:** licensing, role, or prerequisite prevents review; record
    dependency, owner, target date, and effect on the decision.
- [ ] Do not infer coverage from an empty dashboard or create an export.

## 4. Review DLP coverage and report-only readiness *(15 min)*

- [ ] Customer confirms current supported DLP workload, location, data type or
  sensitivity-label condition, and candidate path. Record the supporting
  customer configuration/documentation reference.
- [ ] Facilitator asks: “Can this policy cover this workload and condition?”,
  “What false positive is unacceptable?”, and “Who observes and interprets
  matches?”
- [ ] Record one outcome: no DLP change, `designed`, or a customer-owned
  proposal for `report_only_deployed`. DLP simulation mode is for observing
  possible policy impact without enforcement; this kit creates nothing.
- [ ] A documented absence of applicable coverage is a no-result; unsupported
  workload/condition or unavailable license is unsupported/blocked. Route
  customer implementation, observation duration, rollback, communications, and
  verification to its approved change process.

## 5. Review Audit/eDiscovery investigation route *(15 min)*

- [ ] Investigator and administrator verify which supported Audit records and
  eDiscovery scope can locate relevant AI interactions or administrative
  changes for this workload; record route, responsible role, retention/hold
  limitation, and customer evidence reference.
- [ ] Ask: “Which event or item answers the investigation question?”, “What
  retention, permission, and legal-hold constraints apply?”, and “Who receives
  and assesses a concern?”
- [ ] A route that is named, scoped, and evidence-referenced is a result. A
  reviewed search with no relevant item is a no-result only with scope/date/
  reviewer. Missing support, retention, or permission is unsupported/blocked;
  assign the risk, retention, licensing, or legal owner and do not call it
  investigation-ready.

## 6. Make the control decision *(10 min)*

For each proposed DLP or data-protection change, the customer records:

| Decision input | Required record |
|---|---|
| Scope | Approved workload, data type, location, and pilot path |
| State | `designed`, `report_only_deployed`, `observed`, `approved_for_enforcement`, `enforced`, `accepted_risk`, or `blocked` |
| Owner and approver | Named customer roles |
| Evidence | Reference to the approved customer records system, not a copied payload |
| Observation | Report-only duration, review date, and false-positive owner |
| Change safety | Customer change, rollback, communication, and verification references |

Use this decision tree before recording a state:

```text
Path, owner, and evidence location known?
  No → blocked; close the dependency.
  Yes → scoped DSPM review result or documented no-result?
    No, unsupported/blocked → accepted_risk or blocked; assign alternative control/review.
    Yes → DLP coverage supported for workload, location, and condition?
      No → no DLP change; assess classification, access, retention, or gateway dependency.
      Yes → approver, observation owner, change safety, and investigation route ready?
        No → designed; close prerequisites.
        Yes → submit only a separate, customer-owned report-only change for approval.
```

Decision criteria: evidence scope/quality, supported coverage, classification
and access dependencies, investigation readiness, decision authority, and
change safety. This session cannot promote a control to enforcement.

## 6a. Record the data-governance implementation backlog

| Backlog item | Applies / N/A / unknown / later | Recommendation and confidence | Evidence reference or gap | Owner | Later session or customer process |
|---|---|---|---|---|---|
| Purview DSPM for AI coverage or prerequisite remediation | | | | | Compliance process |
| Sensitivity label, classification, or data-source permission gap | | | | | Data governance process |
| DLP report-only change review | | | | | Customer compliance/change process |
| Audit, eDiscovery, retention, or investigation route | | | | | Legal/compliance process |
| Copilot, Foundry, Copilot Studio, or connector workload support check | | | | | S4 / product owner |
| Gateway masking or runtime data-protection dependency | | | | | S3 / S6 |
| Accepted-risk or blocked data exposure decision | | | | | Governance/risk process |

## 7. Handoff and blocker path *(5 min)*

- [ ] Add evidence references and classification/retention metadata to the
  generated workspace's `04-operate/evidence-register.json`.
- [ ] Add the control decision, risk owner, approver, and review date to
  `04-operate/decision-register.json`.
- [ ] If a policy change is proposed, hand it to the customer's approved change
  process in report-only mode. Do not promote enforcement in this workshop.
- [ ] Add unresolved exposure, licensing, workload-coverage, or retention gaps
  to the S6 residual-gap backlog.
- [ ] Facilitator reads back DSPM, DLP, and Audit/eDiscovery references;
  result/no-result/unsupported/blocked interpretation; control state; owner;
  date; and S3/S5/S6 dependency. For a blocker, stop only the dependent work
  and retain its customer-owned backlog/change/risk reference.

## Official product context

Validate capability and workload support immediately before the session using
[DSPM for AI](https://learn.microsoft.com/en-us/purview/dspm-for-ai),
[DLP simulation mode](https://learn.microsoft.com/en-us/purview/dlp-simulation-mode-learn),
[DLP for Microsoft 365 Copilot and Copilot Chat](https://learn.microsoft.com/en-us/purview/dlp-microsoft365-copilot-location-learn-about),
[Audit for Copilot and AI applications](https://learn.microsoft.com/en-us/purview/audit-copilot), and
[eDiscovery of AI data](https://learn.microsoft.com/en-us/purview/edisc-search-copilot-data).
They validate product context, not the customer’s result.
