# S3 · Security Posture & Runtime Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Check Defender and Content Safety availability in [Product Status](../reference/product-status.md).

This page separates the security ideas behind S3. Use the [S3 Runbook](index.md) to perform the customer-owned validation steps.

## Posture management and runtime detection are different jobs

AI Security Posture Management (AI-SPM) discovers AI resources, assembles an AI bill of materials, and highlights configuration weaknesses, vulnerabilities, and attack paths. It answers “what exposure do we have?” before an incident occurs.[^defender]

AI Threat Protection addresses a different question: “what suspicious behavior or attack signal is happening now?” It raises alerts that can be correlated in Defender XDR. A mature program needs both the preventive posture view and the operational detection view.[^defender]

**In the Runbook:** export posture findings first, then verify alert routing. Do not treat a successful alert test as proof that the environment has no configuration risk.

## An AI-BOM connects the risk picture

An AI bill of materials is an inventory of the AI components and dependencies that need to be governed: model services, data sources, identities, network paths, tools, and related resources. Attack paths become meaningful because they connect those components; a weak identity or data path can create risk even when the model endpoint itself is configured correctly.

This is why S3 hands off posture findings to both red teaming and the control-plane reconciliation. Security evidence should be usable by the people who own remediation.

## Prompt injection is an instruction-trust problem

Prompt Shields help detect direct prompt attacks and indirect cross-prompt injection (XPIA), where instructions are hidden in untrusted content such as a retrieved document, email, ticket, or web page.[^contentsafety] The key issue is not simply that text is hostile; it is that an agent may treat untrusted content as if it had the authority of system or developer instructions.

**Boundary:** prompt-injection detection is one layer. It does not eliminate the need for scoped tool permissions, data controls, human review, or adversarial testing.

## Content Safety is a runtime safety floor

Azure AI Content Safety includes capabilities such as Prompt Shields, harm-category analysis, protected-material detection, and groundedness-related features. Availability differs by capability and must be checked before relying on a control in production.[^contentsafety]

S3 verifies the customer’s deployed path rather than creating a parallel one. In the Citadel model, the gateway and Content Safety configuration are part of the Security Fabric; RVAS captures the evidence and operating ownership.[^citadel]

## Alert-first is safer than block-first

A new runtime control can create false positives, blind spots, or unexpected service disruption. S3 therefore starts with scoped, customer-owned non-production tests and alert routing. The SOC can then validate triage, ownership, and evidence before anyone proposes an enforcement change.

**Common misconception:** blocking production traffic is not a proof that a control is mature. A control is mature when its scope, owner, failure mode, and response process are understood.

[^defender]: Microsoft Learn - [AI security posture management](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-security-posture); [AI threat protection](https://learn.microsoft.com/en-us/azure/defender-for-cloud/ai-threat-protection).
[^contentsafety]: Microsoft Learn - [Prompt Shields](https://learn.microsoft.com/en-us/azure/ai-services/content-safety/concepts/jailbreak-detection).
[^citadel]: Microsoft - [Foundry Citadel Platform](https://github.com/Azure-Samples/foundry-citadel-platform); [AI Hub Gateway](https://aka.ms/ai-hub-gateway).
