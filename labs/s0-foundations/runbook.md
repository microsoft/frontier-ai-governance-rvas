# S0 Runbook

> **Boundary:** S0 is an offline baseline-and-decision session. Do not run
> tenant discovery, collect tenant identifiers, or save customer records in this
> repository.

## 1. Prepare the customer record

- [ ] Create a dated baseline record in the customer's approved records system
  or generated delivery workspace.
- [ ] Copy the blank `assessment/scorecard.csv`, `coe/operating-model.md`, and
  `coe/raci.csv` there before adding customer names, scores, or notes.
- [ ] Confirm the governance lead and executive sponsor who will review the
  result.

## 2. Perform the one safe customer-operated action

With the customer, score the 21 questions in the customer copy of the
scorecard. For each question, agree a `1`–`4` score and record the rationale in
the customer record. Then run the offline scorer against that copy:

```bash
python labs/s0-foundations/assessment/score.py /approved/customer/path/scorecard.csv
```

The output is a prioritization aid, not an audit verdict or an automatic session
prerequisite. The customer decides the sequence and any prerequisite work.

## 3. Review and hand off

- [ ] Record the baseline record reference, score date, owner, sponsor, and
  agreed session sequence in the customer's governance record.
- [ ] Record the roadmap decision, residual gaps, decision owner, approver, and
  review date in the generated workspace's
  `04-operate/decision-register.json`.
- [ ] Add only a reference and retention/classification metadata for the
  customer baseline to `04-operate/evidence-register.json`; do not copy the
  scorecard, roadmap, or meeting notes into Git.
- [ ] Hand unresolved ownership, capability, licensing, or delivery questions
  to the customer-owned backlog.
