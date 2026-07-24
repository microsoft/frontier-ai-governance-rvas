# Practical activity: score one bounded pilot

## What you will do

Customer participants score the 13-domain baseline for one real pilot, then run
the offline scorer to see the highest-priority gaps. The result is a starting
point for a roadmap, not an automatic decision.

## Before you start

- Confirm a bounded pilot, named governance lead, decision owner, and approved
  customer records location.
- Copy the scorecard to that customer location. Do not enter customer content in
  this repository.
- Stop if participants cannot explain the evidence for a score or cannot retain
  the result safely.

## Customer-operated activity

1. Score the questions relevant to the pilot, marking unsupported answers as
   unanswered rather than guessing.
2. Record the evidence reference and owner behind each material score.
3. In the approved customer workspace, run:
   ```bash
   python labs/s0-foundations/assessment/score.py /approved/customer/path/scorecard.csv
   ```
4. Discuss the first-ranked gap with the sponsor and identify the customer
   process that can own the next action.

## What good looks like

The customer has a visible score, a prioritized gap, and an owner. An
unanswered domain is a useful finding when its evidence gap, owner, and review
date are explicit.

## If the environment is not ready

Score a representative scenario using the blank scorecard and record the
assumptions. Do not present it as the customer's maturity baseline.

## Keep and hand over

Keep the scorecard and roadmap in the approved records system. Hand the first
roadmap item to the relevant governance, architecture, security, compliance, or
change owner.
