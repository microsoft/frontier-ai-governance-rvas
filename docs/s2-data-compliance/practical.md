# Practical activity: trace one data path

## What you will do

Customer compliance and workload owners trace one real AI-agent data path and
review the available Purview evidence for that bounded scope.

## Before you start

- Confirm the pilot path, compliance owner, investigation owner, and approved
  evidence location.
- Use only customer-approved Purview access. Do not export content, prompts, or
  investigation results into this repository.
- Stop if the path, investigation route, or decision owner is unknown.

## Customer-operated activity

1. Map the input, retrieval, tool, output, classification, and data-location
   points for the selected path in `labs/s2-data-compliance/review-checklist.md`.
2. The customer administrator reviews relevant DSPM for AI, classification, DLP,
   Audit, or eDiscovery coverage and records safe references and limitations.
3. If an approved report-only DLP proposal already exists, review its scope,
   observation owner, and rollback path. Do not create or enforce a policy here.

## What good looks like

The customer can explain where data enters and leaves, what Purview coverage
supports, and who investigates a concern. An unavailable capability or
unsupported workload is a recorded dependency.

## If the environment is not ready

Trace the path from approved architecture references and identify the missing
role, license, retention, or investigation prerequisite.

## Keep and hand over

Keep evidence references and the decision in the approved records system. Hand
classification, investigation, or report-only change work to the customer
compliance and change owners.
