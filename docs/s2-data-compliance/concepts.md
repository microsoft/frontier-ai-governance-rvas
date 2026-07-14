# S2 · Data & Compliance Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Confirm tenant licensing and product availability in the [Governance capability guide](../reference/governance-capability-guide.md).

This page explains the compliance-plane controls used in S2. [S2 Prepare](index.md) starts the safe delivery sequence.

## The compliance plane answers a data question

AI governance needs to answer more than “is this agent allowed to run?” It also needs to answer what data reaches the agent, what sensitive data can appear in prompts or responses, and what evidence remains after an interaction. Microsoft Purview brings existing data-security and compliance capabilities into AI workloads and connected applications.[^purview]

S2 focuses on the tenant compliance plane: data classification, policy, investigation, and retained evidence. It does not attempt to build a new model gateway.

## DSPM for AI finds exposure before enforcement

Data Security Posture Management for AI helps surface oversharing, sensitive-data exposure, risky access patterns, and potential exfiltration paths. Its role is diagnostic: it gives the customer a prioritized view of where data risk may exist before a policy blocks or notifies users.[^dspm]

**In Co-deliver:** an empty export is still evidence. It can mean the tenant has no discovered in-scope workload, no findings, or a prerequisite gap that should be recorded and investigated.

## Labels and DLP turn classification into controls

Sensitivity labels describe how data should be handled; DLP policies apply rules to prevent or govern inappropriate use of that data. For AI, this can mean detecting protected information in a prompt, response, or connected workflow. Policy scope and supported workloads must always be validated for the tenant.[^purview]

The Co-deliver chapter uses simulation or test mode first. This is the data-plane equivalent of report-only: the customer observes matches and false positives before deciding whether an enforcement rule is safe.

## Investigation needs an evidence trail

Audit, eDiscovery, Insider Risk Management, and Communication Compliance serve different investigation needs, but together they help preserve discoverability and route concerning activity through established compliance processes where supported.[^purview]

A DLP policy alone is not an evidence strategy. The customer must know which logs, exports, and review queues are available and who owns them.

## Gateway masking complements, but does not replace, compliance

Purview governs data use and evidence in the tenant. A gateway such as AI Hub Gateway / Citadel Governance Hub can provide a separate runtime enforcement pattern, including PII masking before a request reaches a model backend.[^citadel]

These are complementary controls. Gateway masking does not replace data classification, DLP review, or audit retention; likewise, a Purview policy does not implement a runtime gateway.

[^purview]: Microsoft Learn - [Microsoft Purview for AI](https://learn.microsoft.com/en-us/purview/ai-microsoft-purview).
[^dspm]: Microsoft Learn - [Data Security Posture Management](https://learn.microsoft.com/en-us/purview/data-security-posture-management-learn-about).
[^citadel]: Microsoft - [AI Hub Gateway / Citadel Governance Hub](https://aka.ms/ai-hub-gateway); [PII masking guide](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/blob/citadel-v1/guides/pii-masking-apim.md).
