# Practical activity: reconcile one bounded population

## What you will do

Customer stewards run the existing read-only reconciliation on one minimized,
normalized agent and tool population, then triage one finding.

## Before you start

- Confirm the bounded population, approved records location, catalog steward,
  identity owner, and closeout decision owner.
- Use customer-normalized identifiers only in the approved customer environment.
  Do not copy raw exports or personal data into this repository.
- Stop if records cannot be matched by their explicit identifiers.

## Customer-operated activity

1. Prepare the customer-normalized catalog and identity inventory in the shape
   described by `rvas.s9.control-plane-registry.v1`.
2. Follow `labs/s9-control-plane/runbook.md` to run
   `scripts/reconcile-registry.py` against those customer-held inputs.
3. Classify one result as a record-quality gap, stewardship gap, governed
   change need, or unsupported coverage, then assign its owner and review date.

## What good looks like

The reconciliation produces an explicit finding or an explicit no-finding for
the checked population. A no-finding never extends beyond its stated coverage.

## If the environment is not ready

Run the tool on supplied sample data and map the exact customer inputs and
owners required for a real reconciliation.

## Keep and hand over

Keep the report reference and closeout decision in approved customer records.
Hand open record, stewardship, lifecycle, or governed-change work to its owner.
