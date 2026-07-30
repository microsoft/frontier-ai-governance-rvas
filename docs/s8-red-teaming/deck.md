# S8 · Authorized Red Teaming Runbook

**Facilitator deck**

Microsoft default: **AI Red Teaming Agent for supported Foundry targets; PyRIT,
manual expert review, or third-party route when support or customer policy
requires it**.

Concrete decision: **test, defer, route, block, remediate, retest, or accept
risk for one authorized non-production target and category set**.

---

## Gate before any test

- Written authorization and rules of engagement.
- Non-production target and version.
- Target support and category support.
- SOC/legal contacts where required.
- Evidence location and retention owner.
- Stop conditions, rate/cost boundary, and reset path.

Note:
If any gate is missing, do not test. Record blocked, unsupported, or
production-test deferred.

---

## Target support check

- Foundry project deployment.
- Connected Azure OpenAI or Foundry Tools deployment.
- Foundry Agent in the project.
- Approved PyRIT adapter or customer wrapper.
- Manual/third-party route with explicit handoff.

Note:
Unsupported is a result. Do not force a mock run to fill a control row.

---

## AI Red Teaming Agent playbook

1. Open `ai.azure.com` and select the Foundry project.
2. Copy project endpoint from **Overview**.
3. Confirm operator has **Foundry User** or approved equivalent.
4. Select supported target and categories.
5. Configure target, category list, sample/objective count, strategy scope,
   taxonomy/source, stop conditions, and monitoring.
6. Run through Microsoft Foundry SDK or approved automation.
7. Review status, ASR, category breakdown, limitations, and run ID.

Note:
Store run records and scorecards in customer systems. Keep only safe references
in the template.

---

## PyRIT playbook

- Use when native route does not cover target/category or custom repeatability is
  required.
- Confirm approved target adapter boundary.
- Load dataset/prompt source by safe reference.
- Run the customer-approved notebook or documented wrapper command.
- Store scorecard and row-level data in customer records.
- Record method, target/run ID, categories, threshold verdict, support status,
  finding route, and retest result.

Note:
Do not invent payloads, paste prompt content, or store raw outputs in this repo.

---

## Manual or third-party branch

Minimum handoff:

- Authorization reference and ROE.
- Target alias, version, owner, reset path, monitoring window.
- Method and operator.
- Categories, excluded categories, and success condition.
- Threshold/severity owner and accepted-risk authority.
- Evidence location and retention owner.
- Remediation owner, release impact, stop condition, and retest method.

Note:
Keep reports and raw notes in customer systems; store only a safe reference.

---

## Expected signals

| Signal | Action |
|---|---|
| Target supported | Continue within ROE. |
| Category unsupported | Route or choose approved alternate. |
| Run blocked by authorization | Do not test. |
| ASR above threshold | Open finding, hold/route release impact, retest after fix. |
| Result not comparable | Mark diagnostic-only and define rerun. |
| Finding retested | Close only with owner acceptance and remaining-risk note. |

Note:
ASR below threshold supports only the tested target, version, category, method,
sample, and threshold.

---

## Decide and hand over

- Final action: test completed, hold, route, block, remediation required, retest
  required, accepted risk, or diagnostic-only.
- Handoff owners: target, red-team lead, SOC/legal, severity, remediation,
  retest, evidence, release/lifecycle.
- Retest trigger and reopen trigger are explicit.

Note:
S8 creates remediation and retest work. It does not approve production or
authorize production testing.
