# Staged rollout decision record

Copy this blank record into the customer's approved records system. It assembles
customer-held references; it does not authorize a deployment, change a
production environment, or replace the customer's change authority.

## Candidate and decision

| Field | Record |
|---|---|
| Agent / workload reference | |
| Admission-record reference | |
| Customer change authority | |
| Decision: proceed to next stage / hold / defer / rejected | |
| Decision owner and review date | |

## Environment and promotion model

The labels below are a recommended DEV → PRE → PRO model. Map them to the
customer's approved environment names. A stage record names a promotion
decision; it does not approve deployment or change a production environment.

| Stage | Purpose | Minimum control expectation | Evidence / promotion decision |
|---|---|---|---|
| DEV | Rapid development and isolated experimentation | No static credentials; bounded data/actions; basic logging; explicit non-production label | Customer engineering evidence and admission to the next controlled activity |
| PRE | Integration, certification, and regression validation | Production-equivalent control intent for the selected path; test data where appropriate; runtime/evaluation evidence available | Accepted gateway proof and assurance decision, subject to stated coverage limits |
| PRO | Live user or business operation | Customer-approved change, operational ownership, configured response/rollback path, and retained evidence references | Separate production-change decision and customer lifecycle/operating review |

## Stage plan

| Stage | Environment label | Population | Entry-condition references | Exit condition / promotion decision | Rollback reference | Owner | Status |
|---|---|---|---|---|---|---|
| DEV / non-production development | | | Admission record | | | | |
| PRE / certification | | | Platform profile; accepted gateway proof; assurance decision | | | | |
| Limited or expanded preview, if used | | | Security finding-disposition reference, if applicable | | | | |
| PRO / production | | | Catalog-registration reference and customer change decision | | | | |

## Cross-session evidence assembly

| Reference | Record |
|---|---|
| Gateway-proof reference and accepted result | |
| Assurance reference and outcome | |
| Security-test finding disposition, if applicable | |
| Catalog registration, if applicable | |
| Rollback owner, communication route, and post-rollback verification | |

Production promotion is always a separate customer change-authority decision.

## Implementation backlog

| Backlog item | Applies / N/A / unknown / follow-up | Recommendation and confidence | Evidence reference or gap | Owner | Follow-up customer process |
|---|---|---|---|---|---|
| Stage entry / exit conditions and rollback readiness | | | | | Customer change process |
| Gateway proof, assurance, and finding-disposition dependencies | | | | | Customer security and evaluation processes |
| Catalog and lifecycle-record dependency | | | | | Customer service-management process |
