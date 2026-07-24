# S12 · LLMOps

**Facilitator deck**

LLMOps owner - AI developer - Service owner - 90-minute lifecycle review

---

## LLMOps is the end-to-end operating model

> **"Can learning move safely from data to production and back again?"**

LLMOps manages the full lifecycle of developing, deploying, and maintaining
LLM-based applications.

Record **approve, defer, reject, or route**. The default is protected source
and customer change control, Foundry evaluation/observability where supported,
and Azure Monitor/Application Insights for operation. Verify service fit before
using an exception.

---

## Inner loop: build a candidate

1. **Data curation** - prepare governed, fit-for-purpose data.
2. **Experimentation** - test hypotheses across prompts, retrieval, models, and
   other solution components.
3. **Evaluation** - use defined measures, scenarios, and human judgment to
   compare candidates.

Every stage needs an owner, version/provenance reference, coverage limit, and
exit decision.

---

## Outer loop: operate the approved solution

4. **Validate and deploy** - promote deliberately through DEV -> PRE -> PRO.
5. **Inference** - provide a reliable service route with known dependencies.
6. **Monitor** - interpret health, performance, safety, privacy, and resource
   signals.
7. **Feedback and data collection** - collect governed learning for the next
   inner-loop iteration.

Feedback never changes production directly.

---

## Azure implementation mapping

- Protected source and reproducible candidate references.
- Microsoft Foundry evaluation/observability where supported.
- Customer CI/CD, IaC, and change control for promotion.
- Foundry deployment aliases and customer platform route for inference.
- Application Insights/Azure Monitor and customer alerting for operation.

The services support LLMOps; they do not replace its decisions and ownership.

---

## The stage gates prevent unsafe shortcuts

| From | To | Required evidence |
|---|---|---|
| Curation | Experiment | Approved purpose/provenance and S2 route |
| Experiment | Evaluation | Reproducible candidate and hypothesis |
| Evaluation | PRE/PRO | S7 decision, coverage, threshold, and change authority |
| Production feedback | Curation | Purpose, privacy/retention, quality rule, and owner |

---

## Workshop: map one application

1. Complete the seven-stage lifecycle canvas.
2. Trace one feedback item back to governed curation.
3. Trace one candidate through evaluation and promotion.
4. Find the weakest gate and create an implementation work item.

---

## Keep accountability clear

- **S2**: data governance.
- **S4**: initial selection and admission.
- **S7**: evaluation and release assurance.
- **S11**: production monitoring and FinOps.
- **S12**: the lifecycle, stage gates, artifact ownership, and closed loop.

---

## Decide and hand over

- [ ] Seven stages have one artifact, one gate, owners, evidence, acceptance
  criteria, target dates, and exit decisions.
- [ ] Data and feedback use approved routes.
- [ ] Candidates cannot bypass evaluation or promotion.
- [ ] Production route and rollback target are reconstructable.
- [ ] Backlog has owners, acceptance evidence, target dates, and review cadence.

Handoff to S2, S4, S7, and S11 is explicit. This session makes no
customer-system change or production approval.
