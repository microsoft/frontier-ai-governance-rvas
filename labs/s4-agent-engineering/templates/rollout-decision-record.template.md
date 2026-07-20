# Staged rollout decision record

Copy this blank record into the customer's approved records system. It assembles
customer-held references; it does not authorize a deployment, change a
production environment, or replace the customer's change authority.

## Candidate and decision

| Field | Record |
|---|---|
| Agent / workload reference | |
| Admission-record reference (S4) | |
| Customer change authority | |
| Decision: proceed to next stage / hold / defer / rejected | |
| Decision owner and review date | |

## Environment and promotion model

The labels below are a recommended DEV → PRE → PRO model. Map them to the
customer's approved environment names. A stage record names a promotion
decision; it does not approve deployment or change a production environment.

| Stage | Purpose | Minimum control expectation | Evidence / promotion decision |
|---|---|---|---|
| DEV | Rapid development and isolated experimentation | No static credentials; bounded data/actions; basic logging; explicit non-production label | Customer engineering evidence and S4 admission to the next controlled activity |
| PRE | Integration, certification, and regression validation | Production-equivalent control intent for the selected path; test data where appropriate; runtime/evaluation evidence available | Accepted S6 proof and S7 assurance decision, subject to stated coverage limits |
| PRO | Live user or business operation | Customer-approved change, operational ownership, configured response/rollback path, and retained evidence references | Separate production-change decision; S9/S11 lifecycle and operating handoff |

## Stage plan

| Stage | Environment label | Population | Entry-condition references | Exit condition / promotion decision | Rollback reference | Owner | Status |
|---|---|---|---|---|---|---|
| DEV / non-production development | | | S4 admission record | | | | |
| PRE / certification | | | S3 platform profile; S6 gateway proof; S7 assurance handoff | | | | |
| Limited or expanded preview, if used | | | S8 finding-disposition reference, if applicable | | | | |
| PRO / production | | | S9 catalog-registration reference and customer change decision | | | | |

## Cross-session evidence assembly

| Reference | Record |
|---|---|
| S6 gateway-proof reference and accepted result | |
| S7 assurance-handoff reference and outcome | |
| S8 red-team finding disposition, if applicable | |
| S9 catalog registration, if applicable | |
| Rollback owner, communication route, and post-rollback verification | |

Production promotion is always a separate customer change-authority decision.

## Implementation backlog

| Backlog item | Applies / N/A / unknown / later | Recommendation and confidence | Evidence reference or gap | Owner | Later session or customer process |
|---|---|---|---|---|---|
| Stage entry / exit conditions and rollback readiness | | | | | Customer change process |
| Gateway proof, assurance, and finding-disposition dependencies | | | | | S6 / S7 / S8 |
| Catalog and lifecycle-record dependency | | | | | S9 |
