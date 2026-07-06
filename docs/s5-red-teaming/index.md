# S5 · Adversarial Testing

!!! info "Freshness"
    **Last reviewed:** 2026-07-06 · Concepts sourced from [Reference — Landscape](../reference/index.md). PyRIT status and AI Red Teaming Agent preview status in [Product Status](../reference/product-status.md).

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">AI developer / maker</span>

## 1. Outcome & durable artifact

The customer leaves with an **authorized adversarial test of a customer-owned, non-production AI agent/endpoint** and a dated scorecard that can be reviewed by governance, security, and engineering:

- A scoped red-team run using **AI Red Teaming Agent** <span class="rvas-badge rvas-preview">Preview</span> at Tier A, or **PyRIT-style local simulation** <span class="rvas-badge rvas-ga">GA</span> at Tier B.
- An **Attack Success Rate (ASR) scorecard** by risk category and attack strategy.
- A remediation backlog for categories above the agreed threshold.
- Evidence artifacts captured in `labs/s5-red-teaming/evidence/`.

**Durable artifact:** `labs/s5-red-teaming/` — safe prompt dataset, ASR thresholds, mock red-team harness, Tier A AI Red Teaming Agent reference script, runbook, rollback, verification steps, and the generated scorecard.

## 2. Prerequisites

=== "Tier A — Full production"
    - Written authorization and rules of engagement for a **customer-owned NON-PRODUCTION test agent/endpoint ONLY**.
    - The **SOC is notified before any red-team / adversarial activity (S5)**, with a named contact and expected test window.
    - Azure subscription + Microsoft Foundry project with permission to run AI Red Teaming Agent <span class="rvas-badge rvas-preview">Preview</span>.[^airt]
    - Python environment for `azure-ai-evaluation[redteam]` and `azure-ai-projects`; credentials configured by the customer's operator.
    - Test endpoint owner available to pause, disable, or reset the endpoint if alerts or unexpected behavior occur.

=== "Tier B — Baseline / simulation"
    - No cloud, no live model, and no network required.
    - Run the local PyRIT-style mock harness against a deterministic echo target:
      ```bash
      python labs/s5-red-teaming/pipelines/run_mock.py
      ```
    - Produce `labs/s5-red-teaming/evidence/asr-scorecard.json` as the durable artifact, then document what changes at Tier A: replace the mock target with the authorized customer test deployment and run the managed red-team workflow.

## 3. Concepts

- **PyRIT** <span class="rvas-badge rvas-ga">GA</span> is Microsoft's open-source Python Risk Identification Toolkit for adversarial probing and scoring. Core components include **Datasets, Attacks (orchestrators), Converters, Targets, Scoring, and Memory**.[^pyrit]
- **Attack orchestrators** automate repeatable probes. PyRIT includes multi-turn strategies such as **Crescendo**, where an attacker gradually escalates over several turns rather than using one direct prompt.[^pyrit]
- **AI Red Teaming Agent** <span class="rvas-badge rvas-preview">Preview</span> in Microsoft Foundry is a managed red-teaming capability that wraps PyRIT, supports local use through `azure-ai-evaluation[redteam]` (`RedTeam` class) and cloud use through `azure-ai-projects`, and produces **Attack Success Rate (ASR) scorecards** across risk categories and attack strategies.[^airt]
- **ASR** is the proportion of adversarial attempts that succeed against the stated objective. It is a break-fix metric: lower is better, and thresholds must be agreed before the run.
- **XPIA / indirect prompt injection** is a must-test agent risk: untrusted content in tool outputs, retrieved documents, emails, tickets, or web pages can carry instructions that conflict with system or developer policy.
- **Safety boundary:** this curriculum teaches workflow, scoring, and governance. The kit uses benign placeholders, not real harmful payloads.

## 4. Co-delivery walkthrough

!!! danger "Authorized test endpoint only"
    Before any adversarial activity, confirm **SOC notification**, written authorization, and rules of engagement. The target must be a **customer-owned NON-PRODUCTION test agent/endpoint ONLY**. Do not test third-party systems, production agents, user-facing workloads, or endpoints outside the written scope. Stop if alerts, instability, or scope questions arise.

1. **Pre-flight** *(facilitator + <span class="rvas-badge rvas-persona">Security / SOC</span>)* — open `labs/s5-red-teaming/runbook.md`; confirm SOC notification, authorization, rules of engagement, target URI/name, time window, and rollback contact.
2. **Choose the tier** — Tier A runs `labs/s5-red-teaming/scripts/redteam-airt.py` against the approved customer test deployment; Tier B runs `labs/s5-red-teaming/pipelines/run_mock.py` offline.
3. **Review safe test data** — inspect `labs/s5-red-teaming/datasets/attack-prompts.jsonl`. It contains category-labeled, benign stand-ins for prompt injection, XPIA, system prompt exposure, and Crescendo-style multi-turn testing.
4. **Agree thresholds** — review `labs/s5-red-teaming/policies/asr-thresholds.json` with Security/SOC and the endpoint owner before running anything.
5. **Run the scan** — the customer operator runs the selected path and saves outputs under `labs/s5-red-teaming/evidence/`.
6. **Triage findings** — compare ASR to thresholds, identify categories above tolerance, and open remediation items for prompt hardening, tool-output isolation, retrieval filtering, monitoring, or Content Safety controls.
7. **Debrief** — SOC confirms whether any alerts were raised; endpoint owner confirms whether any test data, logs, or incidents need cleanup.

## 5. Verification & evidence capture

The primary evidence is the **ASR scorecard**:

- [ ] `labs/s5-red-teaming/evidence/asr-scorecard.json` exists.
- [ ] Every tested category reports attempts, successes, ASR, and max acceptable ASR.
- [ ] Categories above threshold have remediation owners and due dates.
- [ ] SOC de-brief notes record whether alerts or incidents were generated.

Tier B capture:

```bash
python labs/s5-red-teaming/pipelines/run_mock.py
```

Tier A capture: export the AI Red Teaming Agent run summary and ASR scorecard into `labs/s5-red-teaming/evidence/` per `verify.md`.

## 6. Rollback

Adversarial runs do not deploy a control, but they **do create artifacts**: scorecards, local evidence files, application logs, security alerts, and possibly incident records.

Use `labs/s5-red-teaming/rollback.md` to:

- stop any in-progress scan;
- disable or reset the non-production test endpoint if it was changed for testing;
- remove local generated evidence files only after the customer has retained the required governance record;
- close or annotate SOC alerts as authorized test activity;
- complete a SOC de-brief and capture lessons learned.

## 7. Governance mapping

| Artifact | NIST AI RMF | ISO/IEC 42001 | EU AI Act |
|----------|-------------|---------------|-----------|
| PyRIT / AI Red Teaming Agent scan + ASR scorecard | **Measure**, **Manage** | A.6 (AI system lifecycle), A.10 (operations, logging) | Art. 15 (robustness, cybersecurity) |
| Written scope, rules of engagement, and SOC notification | **Govern**, **Manage** | A.3 (roles), A.10 (operations) | Art. 9 (risk management), Art. 12 (record-keeping / logging) |
| Remediation backlog for categories above ASR threshold | **Manage** | A.6 (verification & validation), A.10 | Art. 15 (accuracy, robustness, cybersecurity) |

Consolidated in [Reference — Governance Mapping](../reference/governance-mapping.md).

## 8. Facilitator notes

- **Timing:** ~half day. Pre-flight + authorization ~45 min, concepts + dataset review ~45 min, scan execution ~60 min, scorecard review + remediation planning ~60 min, SOC de-brief ~30 min.
- **RACI:** Security/SOC = **R**, Governance lead = **A**, AI developer / maker = **C**, endpoint owner = **C**.
- **Common blockers:**
    - *No written authorization or SOC notification* → **stop**; do not run adversarial activity.
    - *Only production endpoint is available* → use Tier B; never test production in this session.
    - *Preview feature unavailable* → use Tier B mock harness and record Tier A prerequisites.
    - *ASR threshold disagreement* → pause until Security/SOC and Governance lead approve thresholds.
    - *Alerts triggered during run* → stop, follow SOC procedure, annotate as authorized test if confirmed.
- **Hand-off:** ASR findings feed S6 operationalization and the customer's ongoing evaluation gate.

[^pyrit]: Azure/PyRIT — [Python Risk Identification Toolkit](https://github.com/Azure/PyRIT), open-source adversarial testing framework; product status tracked as GA v0.14.x in [Product Status](../reference/product-status.md).
[^airt]: Microsoft Learn — [AI Red Teaming Agent](https://learn.microsoft.com/en-us/azure/ai-foundry/concepts/ai-red-teaming-agent), Preview managed red-teaming in Microsoft Foundry with local `azure-ai-evaluation[redteam]` and cloud `azure-ai-projects` paths.
