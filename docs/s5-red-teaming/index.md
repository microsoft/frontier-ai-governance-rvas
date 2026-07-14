# S5 · Adversarial Testing

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">AI developer / maker</span>

## 1. Outcome & durable artifact

The customer leaves with an authorized adversarial test of a customer-owned, non-production AI agent/endpoint and a dated scorecard that can be reviewed by governance, security, and engineering:

- A scoped red-team run using **AI Red Teaming Agent** <span class="rvas-badge rvas-preview">Preview</span> / PyRIT against an authorized customer-owned non-production endpoint.
- An Attack Success Rate (ASR) scorecard by risk category and attack strategy.
- A remediation backlog for categories above the agreed threshold.
- Evidence artifacts captured in `labs/s5-red-teaming/evidence/`.

Durable artifact: `labs/s5-red-teaming/` - safe prompt dataset, ASR thresholds, AI Red Teaming Agent reference script, runbook, rollback, verification steps, and the generated scorecard. The mock harness is CI validation only, not a customer delivery path.

## 2. Prerequisites

- Written authorization and rules of engagement for a **customer-owned non-production test agent/endpoint only**.
- The **SOC is notified before any red-team/adversarial activity (S5)**, with a named contact and expected test window.
- Azure subscription + Microsoft Foundry project with permission to run AI Red Teaming Agent <span class="rvas-badge rvas-preview">Preview</span>.[^airt]
- Python environment for `azure-ai-evaluation[redteam]` (installs PyRIT); add `azure-ai-projects` only if uploading results to a Foundry project. Credentials configured by the customer's operator.
- Test endpoint owner available to pause, disable, or reset the endpoint if alerts or unexpected behavior occur.

## 3. Why this session

Adversarial testing is useful only when the target, success criteria, safety limits, and response path are agreed before the first probe. S5 creates a repeatable, authorized way to measure weaknesses and assign remediation without testing production or third-party systems.

Read the [S5 Concepts](concepts.md) for PyRIT, Attack Success Rate, indirect prompt injection, and the managed versus open-source testing paths.

## 4. Co-delivery walkthrough

!!! danger "Authorized test endpoint only"
    Before any adversarial activity, confirm **SOC notification**, written authorization, and rules of engagement. The target must be a customer-owned non-production test agent/endpoint only. Do not test third-party systems, production agents, user-facing workloads, or endpoints outside the written scope. Stop if alerts, instability, or scope questions arise.

1. **Pre-flight** *(facilitator + <span class="rvas-badge rvas-persona">Security / SOC</span>)* - open `labs/s5-red-teaming/runbook.md`; confirm SOC notification, authorization, rules of engagement, target URI/name, time window, and rollback contact.
2. **Confirm the live test path** - run `labs/s5-red-teaming/scripts/redteam-airt.py` against the approved customer test deployment. The local mock harness is only for CI/static validation.
3. **Review safe test data** - inspect `labs/s5-red-teaming/datasets/attack-prompts.jsonl`. It contains category-labeled, benign stand-ins for prompt injection, XPIA, system prompt exposure, and Crescendo-style multi-turn testing.
4. **Agree thresholds** - review `labs/s5-red-teaming/policies/asr-thresholds.json` with Security/SOC and the endpoint owner before running anything.
5. **Run the scan** - the customer operator runs the selected path and saves outputs under `labs/s5-red-teaming/evidence/`.
6. **Triage findings** - compare ASR to thresholds, identify categories above tolerance, and open remediation items for prompt hardening, tool-output isolation, retrieval filtering, monitoring, or Content Safety controls.
7. **Debrief** - SOC confirms whether any alerts were raised; endpoint owner confirms whether any test data, logs, or incidents need cleanup.

## 5. Verification & evidence capture

The primary evidence is the ASR scorecard:

- [ ] `labs/s5-red-teaming/evidence/asr-scorecard.json` exists.
- [ ] Every tested category reports attempts, successes, ASR, and max acceptable ASR.
- [ ] Categories above threshold have remediation owners and due dates.
- [ ] SOC de-brief notes record whether alerts or incidents were generated.

Export the AI Red Teaming Agent run summary and ASR scorecard into `labs/s5-red-teaming/evidence/` per `verify.md`.

## 6. Rollback

Adversarial runs do not deploy a control, but they **do create artifacts**: scorecards, local evidence files, application logs, security alerts, and possibly incident records.

Use `labs/s5-red-teaming/rollback.md` to:

- stop any in-progress scan;
- disable or reset the non-production test endpoint if it was changed for testing;
- remove local generated evidence files only after the customer has retained the required governance record;
- close or annotate SOC alerts as authorized test activity;
- complete a SOC de-brief and capture lessons learned.

## 7. Facilitator notes

- **Timing:** ~half day. Pre-flight + authorization ~45 min, session context + dataset review ~45 min, scan execution ~60 min, scorecard review + remediation planning ~60 min, SOC de-brief ~30 min.
- **RACI:** Security/SOC = R, Governance lead = A, AI developer / maker = C, endpoint owner = C.
- **Common blockers:**
    - *No written authorization or SOC notification* → **stop**; do not run adversarial activity.
    - *Only production endpoint is available* → stop; never test production in this session.
    - *Preview feature unavailable* → stop and route Foundry / AI Red Teaming Agent readiness to the prerequisite backlog.
    - *ASR threshold disagreement* → pause until Security/SOC and Governance lead approve thresholds.
    - *Alerts triggered during run* → stop, follow SOC procedure, annotate as authorized test if confirmed.
- **Hand-off:** ASR findings feed S6 operationalization and the customer's ongoing evaluation gate.

[^airt]: Microsoft Learn - [AI Red Teaming Agent](https://learn.microsoft.com/en-us/azure/foundry/concepts/ai-red-teaming-agent), Preview managed red-teaming in Microsoft Foundry with local `azure-ai-evaluation[redteam]` and cloud `azure-ai-projects` paths.
