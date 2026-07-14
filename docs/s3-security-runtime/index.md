# S3 · Security Posture & Runtime

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Capability and availability context is in the [Governance capability guide](../reference/governance-capability-guide.md).

<span class="rvas-badge rvas-persona">Security / SOC</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

The customer leaves with a runtime security baseline for AI workloads in their own Azure environment:

- A **Defender for Cloud AI-SPM review** exported from the customer subscription: AI bill of materials (AI-BOM), posture recommendations, and attack paths.
- AI Threat Protection enabled or staged in an alerts-only operating mode so SOC correlation can happen in Defender XDR without blocking production traffic on day one.
- Prompt Shields / Content Safety verified through Citadel Governance Hub as the runtime safety floor.

Durable artifact: `labs/s3-security-runtime/` - read-only Defender export scripts, Prompt Shield test scripts, JSON baseline configuration, runbook, rollback, verification, and evidence placeholders. Runtime safety platform deployment belongs to Citadel Governance Hub.

## 2. Prerequisites

- An Azure subscription hosting Azure OpenAI / Microsoft Foundry / other AI workloads that Defender for Cloud can discover.
- Roles held by the customer's admins (facilitator guides only): Security Administrator or equivalent Defender for Cloud permissions.
- Microsoft Defender for Cloud plan coverage appropriate for AI Security Posture Management and AI Threat Protection.
- Defender XDR access for SOC alert review and correlation.
- AI Hub Gateway / Citadel Governance Hub deployed or pre-provisioned, with gateway endpoint and Content Safety configuration available for evidence.
- A **customer-owned non-production/test endpoint** for any runtime prompt tests.

## 3. Why this session

Runtime protection needs both a posture view of the environment and a tested path for detecting and triaging suspicious behavior. S3 records that security evidence and validates alert-first controls without changing production traffic.

Read the [S3 Concepts](concepts.md) for AI-SPM, runtime detection, prompt injection, Content Safety, and the alert-first operating model.

## 4. Co-delivery walkthrough

!!! warning "Report-only / audit-first"
    Enable or stage Defender AI threat protection so it **alerts first**. Do not block, throttle, or red-team production traffic during S3. Prompt Shield tests use a customer-owned test endpoint/string and are coordinated with the SOC.

1. **Pre-flight** *(facilitator + <span class="rvas-badge rvas-persona">Security / SOC</span>)* - confirm change window, approver, SOC notification, target subscription, and non-production test scope. Open `labs/s3-security-runtime/rollback.md`.
2. **Locate Citadel runtime safety** - capture the AI Hub Gateway / Citadel Governance Hub endpoint and Content Safety / Prompt Shields configuration as evidence. If the hub is not deployed, stop and make Citadel deployment the prerequisite; do not create a parallel Content Safety deployment through the AI Governance programme.
3. **Review Defender AI-SPM** - run `labs/s3-security-runtime/scripts/export_defender_ai_recommendations.sh` to export AI-related security recommendations and posture findings to `evidence/defender-ai-recommendations.json`.
4. **Stage AI Threat Protection** - follow `labs/s3-security-runtime/runbook.md` to verify AI Threat Protection status, connect Content Safety / Prompt Shields where required, and confirm alerts route to Defender XDR.
5. **Run Prompt Shield test** - run `labs/s3-security-runtime/scripts/test_prompt_shield.sh` with `CONTENT_SAFETY_ENDPOINT` set to the deployed account endpoint. Use only the shipped test string or another customer-approved non-production string.
6. **Triage findings** - SOC reviews Defender recommendations and Prompt Shield output. Record owners, severity, and next actions in the evidence folder; do not remediate production controls during the workshop unless the customer opens a separate change.

## 5. Verification & evidence capture

- [ ] Gateway-level Content Safety evidence records the APIM gateway endpoint and Prompt Shield path.
- [ ] Defender AI-SPM export exists, or the evidence file states that no AI resources were discovered.
- [ ] AI Threat Protection status and Defender XDR routing path are documented.
- [ ] Prompt Shield test result is captured from a customer-owned test string / endpoint.
- [ ] Any posture findings have owner, severity, and due date.

Evidence to capture (into `labs/s3-security-runtime/evidence/`): Citadel runtime safety note, Defender AI recommendations export, AI Threat Protection status notes, Prompt Shield result JSON, and SOC triage notes.

```bash
./scripts/export_defender_ai_recommendations.sh ./evidence/defender-ai-recommendations.json
CONTENT_SAFETY_ENDPOINT="https://<account>.cognitiveservices.azure.com" \
  ./scripts/test_prompt_shield.sh ./evidence/prompt-shield-result.json
```

## 6. Rollback

Every S3 change has a rollback path in `labs/s3-security-runtime/rollback.md`:

- No Content Safety account is created by this kit. Runtime safety rollback belongs to the Citadel Governance Hub change path.
- Revert any Defender pricing / plan change made through the customer-approved portal, CLI, or platform change record.
- Remove only test artifacts and evidence files if the customer does not want them retained.

Because S3 is audit-first, rollback should not affect production traffic unless the customer deliberately promoted a control outside the workshop.

## 7. Facilitator notes

- **Timing:** ~half day. Pre-flight + session context ~45 min, Citadel runtime safety evidence ~30 min, Defender AI-SPM export + AI Threat Protection review ~75 min, Prompt Shield test + evidence ~45 min.
- **RACI:** Security/SOC = R, Governance lead = A, AI developer / maker = C (test endpoint), Compliance / Data admin = C (sensitive data findings), Identity admin = I.
- **Common blockers:**
    - *Defender plan not enabled* → stop S3 runtime validation and capture a plan-enablement action item.
    - *No AI workloads discovered* → evidence the empty AI-BOM and schedule a re-scan after S4/S6 deployments.
    - *AI Hub Gateway not deployed* → stop before Prompt Shield validation and route the prerequisite to the Citadel deployment workstream.
    - *No SOC intake path* → stop before runtime testing; define alert owner and triage queue first.
    - *Only production endpoint available* → do not test; create or nominate a non-production endpoint/string.
    - *Preview capability needed* → mark it explicitly and verify status against Microsoft Learn before delivery.
- **Hand-off:** S3 findings feed S5 adversarial testing scope and S6 control-plane reconciliation.
