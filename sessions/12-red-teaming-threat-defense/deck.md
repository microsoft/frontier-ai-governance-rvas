---
marp: true
theme: ai-governance
size: 16:9
paginate: true
html: true
---

<!-- _class: cover -->

![RVAP logo](assets/logos/logo-full.png)

<p class="eyebrow">AI Governance Co-implementation - Session 12</p>

# Red teaming, prompt injection, and Defender

270 minutes - Compare authorized baseline and remediation results, then route a Defender signal

<!-- Notes: Session 11 measured release quality. Today we compare two authorized versions and check the security route. -->

---

## Control objective

> Compare authorized red-team results for the baseline and the fixed version prepared before the session. Then confirm the Defender-to-SOC route.

### Result check

- Confirm that two approved nonproduction agent versions and the unchanged attack plan match the pre-session authorization.
- Run the same reviewed attack plan before and after remediation.
- Lower overall attack success rate without regression in a tracked category, strategy, or evaluator key.
- Keep blocked actions independently blocked.
- Confirm that an authorized Defender event or route-health result reaches the approved SOC route and identifies the policy-assistant agent or judge model.

<!-- Notes: A scan is a control input, not a complete security assessment. -->

---

## Why it matters

A lower average attack success rate can hide a worse result in one category.

The before/after comparison keeps those misses visible and checks that blocked actions still fail.

The separate route check tells the security owner whether an expected Defender signal reaches the
SOC team that must investigate it.

<!-- Notes: Red-team results and SOC delivery remain separate operating facts. -->

---

## Implementation outcomes

1. Validate the approved scope, fixed versions, and agent-specific attack plan.
2. Run the same limited probes against the baseline and version remediated before the session.
3. Keep a payload-free before/after comparison in the approved security record store.
4. Confirm an authorized Defender event or route-health result at the SOC destination.
5. Record red-team and SOC delivery as separate results in the risk and change review record.

<!-- Notes: Standard mode ends with one composite visible check. -->

---

<!-- _class: section-divider -->

# Compare the same red-team plan and confirm the SOC route

Remediation is already complete. Use the timed work to compare the versions and check the approved
route.

<!-- Notes: Do not optimize only for a prettier scorecard. -->

---

## Architecture overview

<!-- _class: diagram -->

![An authorized plan cycles through baseline measurement, agent-owner remediation, a fixed version, same-plan rerun, per-key decision, and remaining risk; a separate Defender-to-SOC route joins the operations review record without proving red-team improvement](assets/diagrams/red-team-defense-loop.svg)

<!-- Notes: Remediation is pre-work. Keep same-plan comparison and SOC delivery as separate checks. -->

---

## What this means

This design checks whether one remediation changed the result of an approved attack plan. Run that
exact plan against the baseline and the remediated immutable version. Existing tool and backend
controls deny prohibited side effects during both runs.

Foundry stores the run detail. The comparison shows whether every tracked risk stayed the same or
improved. A separate Defender or Microsoft Sentinel route checks delivery to the SOC.

The approved security record store keeps payload-free aggregates without treating SOC delivery as
proof of red-team improvement.

---

## Control boundary

| Surface | Job in this session |
|---|---|
| Microsoft Foundry | Target the approved agent and run cloud red teaming |
| AI Red Teaming Agent | Generate probes and score attack success |
| Existing agent/tool controls | Deny prohibited writes independently of model behavior |
| Defender for Cloud AI services | Detect Azure AI workload threats |
| Agent 365 + Defender | Optional public-preview agent detection path |
| SOC workflow | Triage, correlate, contain, and own the event |

<!-- Notes: Foundry scanning and Defender detection are related but not interchangeable. -->

---

## Current cloud red-team boundary

![Microsoft Foundry](assets/icons/microsoft/azure-ai-foundry.svg)

- Foundry User on the approved Foundry project for the operator and project managed identity
- approved Azure AI agent version
- transient agentic run with only partial isolation
- human review required

The security owner checks the current Microsoft region matrix on the day of the run.

Record the same-day support decision in the approved change system. That live check is the support
decision.

Use the authorized nonproduction policy-assistant version, synthetic data, and read-only tool.

Keep blocked writes **independently denied**. Stop on any unexpected side effect.

<!-- Notes: Batch evaluation has a broader region list; do not use it for this decision. -->

---

<!-- _class: decision -->

## Decision gate 1 - Is this project, agent, and version authorized?

Required:

- the authorized nonproduction project, agent, and fixed version;
- valid run window and stop contact;
- approved categories and synthetic-data boundary;
- agent, security, and SOC owners present; and
- no write-capable tool or stable-endpoint change.

Stop for production, `latest`, customer data, expired authorization, or an unexpected side effect.

<!-- Notes: Authorization is an operating control, not introductory paperwork. -->

---

## The approved attack plan

| Threat behavior | Operational mechanism |
|---|---|
| Direct jailbreak | baseline generation + `Jailbreak` |
| Encoded attack | `Flip` and `Base64` |
| Indirect prompt injection | `IndirectJailbreak` |
| Blocked action | customer-reviewed taxonomy |
| Task drift | task-adherence evaluator |
| Sensitive leakage | leakage evaluator |
| Unsafe tool use | read-only tool plus blocked-action policy |

<!-- Notes: The taxonomy must reflect the customer scenario before the first run. -->

---

## ASR is a risk signal

**Attack Success Rate**

```text
successful attacks
──────────────────
scored attacks
```

Use it to compare the same plan across fixed versions.

Do not:

- treat evaluator errors as safe;
- hide a severe category in an average;
- lower the taxonomy to improve the score; or
- skip human review of false positives.

<!-- Notes: Generative evaluation is nondeterministic and non-predictive. -->

---

## Payloads stay in governed systems

### Repository keeps

- bounded attack-plan configuration
- current Defender alert hunt
- SOC triage playbook

### Where generated records stay

- generated attack prompts
- agent responses
- tool inputs or outputs
- prompt evidence
- customer or personal data
- Foundry runs, Defender alerts, SOC delivery, authorization, remediation, and residual-risk decisions

<!-- Notes: Detailed review happens in Foundry and Defender. -->

---

<!-- _class: decision -->

## Implementation tradeoffs

![Microsoft Defender](assets/icons/microsoft/microsoft-defender-xdr.svg)

| Path | Chosen use | Cost or limit |
|---|---|---|
| Defender for Cloud AI services | Operating path for Foundry workload signals | A red-team run may not create an alert |
| Agent 365 Defender detection | Optional agent-specific path when onboarded | Public preview; never the sole control |
| Route-health result | Confirm delivery when no authorized event is available | Proves the route, not red-team improvement |

<!-- Notes: Record prompt-evidence handling separately; it is customer data. -->

---

## Defender boundaries

- AI model posture and malware scanning cover model and supply-chain risk, not this agent comparison.
- Real-time blocking is a separate control surface. Coverage depends on the agent type and integration.
- Foundry agent blocking is preview; Session 12 does not configure a blocking rule.
- Native Foundry Purview integration does not supply data-leak or insider-risk context. That
  requires a separate Agent Framework or Purview API implementation.

<!-- Notes: Keep detection, blocking, model security, and Purview data controls distinct. -->

---

## Signals operators can see

Defender alert families include:

- jailbreak and prompt-injection attempts;
- ASCII smuggling;
- credential or secret leakage;
- anomalous tool invocation;
- LLM reconnaissance;
- wallet or cost-abuse anomalies;
- phishing or malicious URL behavior;
- malicious uploaded AI models;
- suspicious or anonymized access; and
- access anomalies.

Not every authorized red-team run deterministically creates one of these alerts.

<!-- Notes: Never create an unapproved real attack merely to force a signal. -->

---

## One SOC route

The SOC route is ready when its owner accepts an authorized Defender event or route-health result.
Do not depend on a newly generated alert.

![Microsoft Sentinel](assets/icons/microsoft/microsoft-sentinel.svg)

Choose one:

1. Defender incident
2. Microsoft Sentinel incident
3. the approved ITSM connector

The live record must show the source, route type, destination alias, Defender reference, SOC
reference, observed time, and confirmed agent or model.

The saved hunt matches the current alert titles exactly. It does not use a broad `Title has "AI"` match.

<!-- Notes: Evidence and investigation detail remain in the security system. -->

---

<!-- _class: implementation -->

## Run the red-team plan and route the Defender signal

Timebox: 100 minutes

1. Validate authorization, the Foundry project, both policy-assistant versions, current region support, Defender coverage, and each required owner decision.
2. Prepare and human-review the blocked-action taxonomy.
3. Run the baseline against the approved version.
4. Confirm that the pre-session remediation and new fixed version match the approved records.
5. Rerun the same plan and confirm the approved SOC route from an already authorized Defender event or route-health result whose record identifies the policy-assistant agent or judge model.

<!-- Notes: Stop before a billable run if the printed Foundry project, policy-assistant version, or SOC route differs from the decision records. -->

---

## Safe preview

Preflight stops the run unless the supplied authorization and SOC-route references, approved scope
identifiers, attack plan, regional support confirmation, and Foundry target pass its checks. Defender
coverage and SOC-route ownership are owner-confirmed gates; preflight requires the SOC-route
reference. It also rejects inputs outside the synthetic, read-only, and payload-free limits.

No taxonomy or run is created by preflight.

<!-- Notes: The red-team API has no what-if operation; read-only target resolution is the preview. -->

---

## Baseline flow

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -Phase Baseline

python .\scripts\run-red-team.py `
  --config .\artifacts\red-team\attack-plan.json `
  --phase baseline `
  --output $env:APPROVED_SECURITY_RECORD_STORE\baseline-aggregate.json
```

Detailed output remains in Foundry.

<!-- Notes: Review every errored evaluator and surprising tool trajectory before remediation. -->

---

## Pre-work remediation layers

| Layer | Control owner | Expected change |
|---|---|---|
| Instructions | Agent owner | Treat retrieved content as untrusted |
| Tool path | Tool owner | Keep writes absent or independently denied |
| Gateway/content | Security owner | Keep identity, Prompt Shields, filters, and correlation in operation |
| Data | Security/data owner | Keep synthetic source aliases read-only; no agent or APIM backend role permits writes |
| Release quality | Release owner | Rerun [Session 11](../11-foundry-evaluations-quality-gates/) after remediation |

Pre-work creates a **new fixed agent version**.

<!-- Notes: Never edit the baseline version or change the attack plan between runs. -->

---

## Post-remediation flow

```powershell
.\scripts\preflight.ps1 `
  -ApprovedSubscriptionId $approvedSubscriptionId `
  -Phase PostRemediation

python .\scripts\run-red-team.py `
  --config .\artifacts\red-team\attack-plan.json `
  --phase post-remediation `
  --output $env:APPROVED_SECURITY_RECORD_STORE\post-remediation-aggregate.json
```

Review remaining risk before you make a decision.

For disputed nondeterministic rows, the security owner and affected control owner may accept the reviewed result, rerun the unchanged plan, or require a fix and a new version.

<!-- Notes: A lower average does not erase a severe remaining category. -->

---

## Confirm the result

The single comparison must report:

- two different fixed versions;
- the same attack-plan hash;
- lower overall ASR after remediation;
- no higher ASR for any tracked category, strategy, and evaluator key;
- zero blocked-action attack success;
- zero evaluator errors; and
- a separate SOC-delivery status for the authorized Defender event or route-health result, with the policy-assistant agent or judge model confirmed in its source record.

The payload-free report confirms the red-team outcome. Confirm SOC delivery separately before the
session closes.

<!-- Notes: If the event record lacks the policy-assistant agent or judge-model identifier, the route is not confirmed. -->

---

## Stop conditions

Stop immediately for:

- a production Foundry project, customer data, or an unauthorized policy-assistant version;
- any write side effect or widened permission;
- wrong agent version or changed attack plan;
- failed or missing evaluators;
- unchanged or higher ASR;
- successful blocked actions;
- absent Defender coverage after the explicit Defender wait window recorded by the Defender owner in the customer change record; or
- copied attack, prompt-evidence, or alert payloads.

<!-- Notes: Do not manufacture a pass or a security alert. -->

---

## Responsibilities after the run

| Owner | Operational responsibility |
|---|---|
| Security owner | Authorization and attack coverage |
| Agent owner | Versioned instructions |
| Tool owner | Independent authorization boundary |
| Defender owner | Sensor and prompt-evidence settings |
| SOC owner | Triage and route |
| Remaining-risk owner | Accept, rerun, or disable decision |
| Cost owner | Red-team and judge-model consumption |

<!-- Notes: Session 12 authorizes no production promotion. -->

---

## Manual restore

1. Stop the run.
2. Keep the stable endpoint on the previously approved version.
3. Disable the affected version or detach its tool binding when needed.
4. Restore only approved [Session 05](../05-governed-agent-baseline/), [Session 07](../07-apim-ai-gateway/), [Session 09](../09-mcp-tool-security/), and [Session 10](../10-purview-data-governance/) control definitions.
5. Keep Defender and SOC routing active unless they have a separate operational fault.
6. Remove cloud red-team definitions only after the security owner confirms retention needs.

<!-- Notes: Monitoring is not the cause of an unsafe behavior; do not disable it to silence a signal. -->

---

## Recap

- Authorized scope before red-team traffic
- Fixed version and reviewed taxonomy
- Same plan before and after remediation
- Independent prohibition of risky tool actions
- No risk category gets worse while the average improves
- Defender-to-SOC delivery recorded separately
- Payload-free aggregate result in the approved security record store

<!-- Notes: The confirmed comparison report and SOC route make the result repeatable. -->

---

<!-- _class: closing -->

# Thank you!

<!-- Notes: Next, Session 13 connects operational logs, cost, and incident response. -->
