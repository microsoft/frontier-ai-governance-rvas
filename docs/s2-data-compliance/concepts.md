# S2 · Data & Compliance Concepts

!!! info "Freshness"
    Last reviewed: 2026-07-06 · Confirm tenant licensing and product availability in the [Governance capability guide](../reference/governance-capability-guide.md).

This page explains the compliance-plane controls used in S2. [S2 Prepare](index.md) starts the safe delivery sequence.

## The compliance plane answers a data question

![S2 compliance flow: DSPM for AI surfaces exposure, producing prioritised findings that drive sensitivity labels and DLP policies, which feed an evidence trail (Audit, eDiscovery, Insider Risk Management, Communication Compliance) routed to the customer compliance and change process; gateway masking complements but does not replace Purview.](../assets/diagrams/s2-compliance-flow.svg)

AI governance needs to answer more than "is this agent allowed to run?" It also needs to answer which data reaches the agent, which sensitive data can appear in prompts or responses, and which evidence remains after an interaction.

Microsoft Purview brings data security and compliance capabilities into AI workloads and connected applications.[^purview] S2 uses Purview for data classification, discovery, policy review, investigation, and evidence references. It does not build a new model gateway.

## Compliance findings become implementation backlog

S2 should recommend the next data-governance path with assumptions and owners.

Typical backlog items include Purview DSPM coverage remediation, sensitivity label or classification work, DLP report-only change review, audit/eDiscovery route validation, retention or legal-hold dependency, workload support checks, gateway masking dependency, and `accepted_risk` or `blocked` status.

The recommendation is not a policy deployment. Moving from design to report-only or enforcement stays in the customer's compliance and change process. That process owns rollback, communications, observation, and verification.

## DSPM for AI finds exposure before enforcement

Data Security Posture Management for AI helps surface oversharing, sensitive-data exposure, risky access patterns, and possible exfiltration paths.[^dspm]

Its role is diagnostic. It gives the customer a prioritized view of where data risk may exist before a policy blocks or notifies users.

**In Co-deliver:** an empty result is still evidence. It can mean no discovered in-scope workload, no findings in the checked scope, or a prerequisite gap. Record which one the customer can support.

## Labels and DLP turn classification into controls

Sensitivity labels describe how data should be handled. DLP policies use conditions, such as labels or sensitive information types, to govern inappropriate sharing or use.[^purview]

For AI, that can mean detecting protected information in a prompt, response, or connected workflow. The customer must confirm which workloads, locations, and conditions Purview supports in its tenant.

The Co-deliver chapter uses simulation or test mode first. The customer observes matches and false positives before deciding whether enforcement is safe.

## Investigation needs an evidence trail

Audit, eDiscovery, Insider Risk Management, and Communication Compliance serve different investigation needs.[^purview] Together, where supported, they help route concerning activity through established compliance processes.

A DLP policy alone is not an evidence strategy. The customer must know which logs, exports, review queues, retention rules, and owners are available.

## Gateway masking complements, but does not replace, compliance

Purview governs data use and evidence in the tenant. A gateway such as AI Hub Gateway or Citadel Governance Hub can add a runtime pattern, including PII masking before a request reaches a model backend.[^citadel]

These controls work together. Gateway masking does not replace data classification, DLP review, or audit retention. A Purview policy does not implement a runtime gateway.

[^purview]: Microsoft Learn - [Microsoft Purview for AI](https://learn.microsoft.com/en-us/purview/ai-microsoft-purview).
[^dspm]: Microsoft Learn - [Data Security Posture Management](https://learn.microsoft.com/en-us/purview/data-security-posture-management-learn-about).
[^citadel]: Microsoft - [AI Hub Gateway / Citadel Governance Hub](https://aka.ms/ai-hub-gateway); [PII masking guide](https://github.com/Azure-Samples/ai-hub-gateway-solution-accelerator/blob/citadel-v1/guides/pii-masking-apim.md).

## Related official references

See the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) for Purview, DSPM, DLP, sensitivity, audit, eDiscovery, and compliance sources.
