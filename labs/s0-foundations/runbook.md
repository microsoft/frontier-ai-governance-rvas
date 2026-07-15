# S0 Runbook

> **Boundary:** S0 is an offline baseline-and-decision session. Do not run
> tenant discovery, collect tenant identifiers, or save customer records in this
> repository.

## Activity card

**90 minutes.** Facilitator runs the method; governance lead performs the
customer action; executive sponsor is the decision owner; evidence owner keeps
references in the approved customer system. Entry condition: named sponsor and
governance lead, a bounded pilot question, and an approved evidence location.
If an owner or location is missing, record the blocker, owner, and date, then
stop the affected work.

## 1. Set the room and question

- [ ] Customer states the priority question, safe offline posture, decision
  owner, evidence reference location, and stop condition.

## 2. Create the customer copy

- [ ] Customer creates a dated baseline record and copies the blank
  `assessment/scorecard.csv`, `coe/operating-model.md`, and `coe/raci.csv`
  there before entering customer information.
- [ ] Facilitator asks: “What proof supports a maturity score?” and “Who
  resolves a disagreement?” A template or facilitator note is not evidence.

## 3. Customer-led baseline review

- [ ] Customer scores the 21 questions and captures rationale/dissent in its
  record. Ask: “What observed practice supports this?” and “What is the gap,
  not the aspiration?”
- [ ] Record a score or explicitly unanswered question as the result. For a
  no-result, record the reviewed question, unavailable evidence, scope, and
  reviewer—do not call it a pass.
- [ ] For unsupported assessment evidence or an absent required owner, record
  the limitation/blocker, owner, and review date; do not invent a score.

## 4. Generate and interpret the roadmap

- [ ] Customer runs the scorer against its approved copy:
  ```bash
  python labs/s0-foundations/assessment/score.py /approved/customer/path/scorecard.csv
  ```
  Ask whether its ranking matches risk and dependencies. This output is a
  recommendation, not an audit verdict.

## 5. Decide and hand off

- [ ] Decision owner selects the next session(s), defers with a date, or accepts
  a residual gap based on evidence-supported maturity, risk, owner, and
  prerequisites. Record `designed`, `accepted_risk`, or `blocked`.
- [ ] Retain references to the dated baseline, RACI/operating model, scorer
  output, and decision in the customer system. If the decision owner is absent,
  mark **deferred** and assign owner/date.

- [ ] Register only evidence references and retention/classification metadata
  in `04-operate/evidence-register.json`; put decision/owner/review date in
  `04-operate/decision-register.json`.
- [ ] Handoff names next owner, S1/S2 dependency, and blocker path. Do not copy
  scorecards, roadmaps, names, evidence, or notes into Git.
