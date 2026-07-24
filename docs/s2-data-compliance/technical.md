# S2 · Data Governance & Compliance: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Microsoft Purview DSPM for AI, DLP, sensitivity labels, audit, eDiscovery, gateway masking, and Azure AI safety features vary by tenant, workload, region, and license. Verify official docs and tenant status before delivery.

## Microsoft default

Default to Microsoft Purview Data Security Posture Management, sensitivity labels, Data Loss Prevention, audit, and eDiscovery for data governance. Use gateway masking or Azure AI Content Safety only for the runtime slices they officially support.

## Decision tree

1. **If sensitivity labels and DLP already cover the data path**, use Purview as the primary classification and policy record.
2. **If Purview findings show oversharing or unknown exposure**, backlog source-permission and retention fixes before broad agent access.
3. **If data enters through prompts, retrieval, tools, or responses**, map each entry point to a source owner and least-privilege boundary.
4. **If residency, retention, legal basis, or eDiscovery is unresolved**, defer or route to privacy/compliance before release decisions.

| Decision | Microsoft default | Exception criteria |
|---|---|---|
| Classification | Purview sensitivity labels and DLP | existing enterprise classifier is authoritative and maps to Purview gaps |
| Exposure review | Purview DSPM for AI / data map findings | manual review is required for unsupported data stores |
| PII/runtime handling | source minimization plus gateway masking where supported | app-specific redaction is the only supported point |
| Compliance records | Purview audit, eDiscovery, retention labels, privacy records | regulated customer system is the legal record |

## Platform checks

| Check | Microsoft product/control record |
|---|---|
| Classification status | Purview Information Protection labels, label policy, DLP policy, policy simulation/report |
| Exposure and oversharing | Purview DSPM for AI/data map finding, SharePoint/OneDrive permissions, data-source ACLs |
| Audit/eDiscovery | Purview audit log, eDiscovery case/hold, retention policy, records-management owner |
| Runtime data path | gateway masking rule, Azure API Management route, Azure AI Content Safety setting if used |
| Residency/privacy | approved Azure region, service residency docs, privacy/legal processing record |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Data classification | each in-scope source has label/DLP coverage or a named gap with owner and target date | Data/compliance owner |
| Retrieval and prompt exposure | sources, sensitive fields, least-privilege boundary, and residual risk are recorded | Source-system owner |
| Compliance mapping | lawful basis, residency, retention, audit/eDiscovery route, and privacy owner are recorded | Privacy/legal |
| Runtime minimization | gateway/app/source control owner and validation reference are recorded for any masking/redaction claim | Platform/security |

## Boundary note

S2 records data decisions and routes remediation; it exports no customer data and changes no compliance policy.

## Related references

- [S2 Concepts](concepts.md): Purview review, labels, DLP, investigation evidence, and gateway masking boundaries.
- [S6 technical decisions](../s6-security-runtime/technical.md): runtime safety placement.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md): Purview, DLP, audit, eDiscovery, residency, and compliance sources.
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md).
