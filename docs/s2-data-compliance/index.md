# S2 · Data & Compliance

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Concepts sourced from [Reference - Landscape](../reference/index.md). Purview DSPM status in [Product Status](../reference/product-status.md).

<span class="rvas-badge rvas-persona">Compliance / Data admin</span> <span class="rvas-badge rvas-persona">Governance lead</span>

## 1. Outcome & durable artifact

The customer leaves with AI data exposure governed in Microsoft Purview in their own tenant:

- A **DSPM for AI findings export** showing oversharing, exfiltration, and sensitive-data-in-prompts risk across AI apps and agents.
- A DLP for AI policy definition authored in test/simulation mode, stored as exported JSON and ready for customer-owned deployment.
- A compliance evidence bundle tying Purview Audit, eDiscovery, Insider Risk Management (IRM), and Communication Compliance signals to AI interactions.

Durable artifact: `labs/s2-data-compliance/` - the read-only findings export script, simulation-mode DLP policy definition, and verification runbook. Customer evidence remains local and is not committed to this repository.

## 2. Prerequisites

- Microsoft Purview capabilities licensed for **DSPM for AI**, DLP, Audit, eDiscovery, IRM, and Communication Compliance.
- Roles held by the customer's admins (facilitator guides only): Compliance Administrator, Compliance Data Administrator, or equivalent Purview role groups for DLP and audit export.
- Microsoft Graph PowerShell SDK and Security & Compliance PowerShell available on the operator workstation.
- A named **change window** and approver for policy creation. Break-glass is not directly in scope for DLP, but an escalation contact must be available.
- At least one AI workload in scope, such as Microsoft 365 Copilot, Microsoft Foundry agents, Copilot Studio, Security Copilot, or approved enterprise ChatGPT connectors.

## 3. Concepts

- **Purview is the data-security layer for AI.** Microsoft Purview for AI extends compliance controls to AI apps and agents, including Copilot, Foundry, enterprise ChatGPT, and other connected AI apps.[^purview]
- **DSPM for AI maps exposure before enforcement.** Data Security Posture Management for AI surfaces oversharing, user access risk, exfiltration paths, and sensitive data used in prompts/responses so teams can prioritize remediation.[^dspm] <span class="rvas-badge rvas-ga">GA</span>
- **Sensitivity labels and DLP govern AI use.** Labels and DLP rules can govern what protected data agents can access or return. DLP is authored in test/notify mode first - the data-plane equivalent of report-only.[^purview] <span class="rvas-badge rvas-ga">GA</span>
- **PII has compliance and gateway planes.** S2 covers the compliance plane: Purview sensitivity labels, DLP for AI, and audit trails. If the customer uses [AI Hub Gateway / Citadel Governance Hub (`citadel-v1`)](https://aka.ms/ai-hub-gateway), its APIM-layer PII masking pattern provides a complementary gateway enforcement plane that can anonymize sensitive values before requests reach model backends.[^citadel]
- **IRM and Communication Compliance extend the investigation surface.** Insider Risk Management and Communication Compliance can include AI interactions so risky prompt behavior and policy violations are reviewed through existing compliance workflows.[^purview]
- **Audit and eDiscovery preserve discoverability.** Purview Audit and eDiscovery provide the evidence trail for prompts, responses, user context, and policy events where supported.[^purview]
- **Tenant-plane is not ARM/Bicep.** Purview and M365 compliance configuration is administered through the Microsoft Purview portal, Microsoft Graph / PowerShell, and exported JSON - not Azure ARM or Bicep.

## 4. Co-delivery walkthrough

!!! warning "Report-only / audit-first"
    DLP policy creation in this session is **simulation/test only**. It must not block users or agents during the workshop. Promotion to enforcement is a separate, customer-owned change after findings review, legal/compliance approval, and communications.

1. **Pre-flight** *(facilitator + <span class="rvas-badge rvas-persona">Compliance / Data admin</span>)* - confirm the change window, approver, Purview roles, and evidence location. Open `labs/s2-data-compliance/rollback.md`.
2. **Export DSPM for AI findings (read-only)** - the customer runs:
   ```powershell
   ./scripts/Get-AISensitiveDataFindings.ps1 -OutFile ./evidence/dspm-ai-findings.json
   ```
   If the tenant has no findings, capture the empty result as evidence. If the feature is not licensed, stop and route licensing to the prerequisite backlog.
3. **Review the simulation policy** - inspect `policies/dlp-ai-simulation.json`. Replace tenant-specific IDs, sensitive information type IDs, and notification group placeholders.
4. **Run the offline safety gate** - from `labs/s2-data-compliance/`:
   ```bash
   python pipelines/run_mock.py
   ```
   The check must print `PASS` and warn only about placeholders that the customer still needs to fill.
5. **Hand it off for customer-owned change** - this kit intentionally does not create or remove tenant policy. The customer may apply the reviewed definition through its approved change process, retaining simulation/test mode.
6. **Let it bake** - if the customer applies the policy, leave it in simulation while Purview collects policy matches and user notifications. Compliance review determines any later enforcement.

## 5. Verification & evidence capture

- [ ] `dspm-ai-findings.json` exists and documents findings or an empty result.
- [ ] If independently applied by the customer, the DLP policy remains in **TestWithoutNotifications**, TestWithNotifications, or equivalent simulation/test state.
- [ ] Audit/eDiscovery search can locate AI interaction records where the tenant supports them.
- [ ] IRM and Communication Compliance reviewers know where AI interaction alerts will appear.

Evidence to capture (into `labs/s2-data-compliance/evidence/`): DSPM for AI findings export, deployed DLP policy export, policy match summary after bake time, and the named approver/change record.

```powershell
./scripts/Get-AISensitiveDataFindings.ps1 -OutFile ./evidence/dspm-ai-findings.json
```

## 6. Customer-owned rollback

This kit makes no tenant changes. If the customer independently applies a simulation/test policy, its approved change process owns reversal and confirmation. DSPM exports, audit searches, and evidence files are read-only artifacts - nothing to revert in the tenant.

## 7. Governance mapping

| Artifact | NIST AI RMF | ISO/IEC 42001 | EU AI Act |
|----------|-------------|---------------|-----------|
| DSPM for AI findings export | Map (data exposure, context), Manage (prioritized remediation) | A.7 (data), A.8 (impact) | Art. 10 (data governance), Art. 12 (logging) |
| DLP for AI policy in simulation/test | Manage (data-use controls) | A.7 (data), A.8 (impact) | Art. 10 (data governance) |
| IRM, Communication Compliance, Audit/eDiscovery evidence | Map, Manage | A.7 (data), A.8 (impact) | Art. 12 (logging) |

Consolidated in [Reference - Governance Mapping](../reference/governance-mapping.md): DSPM for AI, DLP, IRM, audit → Map, Manage → A.7 (data), A.8 (impact) → Art. 10 (data governance), Art. 12 (logging).

## 8. Facilitator notes

- **Timing:** ~half day. Pre-flight + concepts ~45 min, DSPM review ~60 min, DLP simulation authoring ~60 min, verification/evidence ~30 min.
- **RACI:** Compliance/Data admin = R, Governance lead = A, Security/SOC = C (IRM/Communication Compliance), AI developer = I.
- **Common blockers:**
    - *DSPM for AI not licensed* → stop S2 live delivery and route licensing to the prerequisite backlog. *No findings* → capture the empty export as evidence.
    - *Policy owner asks to enforce immediately* → **stop**; this session creates simulation/test only.
    - *Tenant-specific IDs unknown* → leave placeholders, capture warnings, and assign follow-up to the Compliance/Data admin.
    - *Customer asks about PII masking before the LLM call* → keep the S2 DLP simulation in scope, then point the platform team to the Citadel Governance Hub [PII masking guide](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/blob/citadel-v1/guides/pii-masking-apim.md) for gateway-layer anonymization/deanonymization.
    - *Audit retention insufficient* → document the gap and route to the governance backlog.
- **Hand-off:** findings feed S3 security posture, S5 adversarial testing evidence, and S6 control-plane reconciliation.

[^purview]: Microsoft Learn - [Microsoft Purview for AI](https://learn.microsoft.com/en-us/purview/ai-microsoft-purview).
[^dspm]: Microsoft Learn - [Learn about Data Security Posture Management](https://learn.microsoft.com/en-us/purview/data-security-posture-management-learn-about).
[^citadel]: Microsoft - [AI Hub Gateway / Citadel Governance Hub](https://aka.ms/ai-hub-gateway); see the `citadel-v1` [PII masking at the gateway guide](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/blob/citadel-v1/guides/pii-masking-apim.md).
