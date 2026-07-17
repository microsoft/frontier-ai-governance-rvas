# S2 · Data Governance & Compliance — Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-17 · Microsoft Purview, DSPM for AI, DLP,
    sensitivity-label, gateway, and Azure AI safety capabilities vary by tenant,
    licensing, region, and workload. Verify current status and availability in
    the [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md)
    before delivery.

S2 turns the data review into three **technical decisions** that are also
compliance decisions: how sensitive data is classified, where you cut prompt
and retrieval exposure, and how regulatory obligations are mapped. The customer
leaves with recorded options, evidence, and owners — not a copied data export or
a tenant change.

These are decision **menus**, not deployment recommendations. The kit works
offline, changes nothing in production, and any rollout stays with the
customer's compliance, data, security, and change processes.

## Decision 1 — How is data classified and sensitivity handled?

Choose based on how mature the label taxonomy already is, whether it covers
agent prompts, retrieval sources, and outputs, and whether the customer's
current DLP setup can watch the path safely. Confirm current Microsoft Purview
Information Protection and DLP status before treating any option as available.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Microsoft Purview Information Protection** (sensitivity labels and DLP) | The customer already uses labels/DLP and the in-scope workloads, locations, and conditions are supported | Coverage, licensing, and workload behavior must be verified; label taxonomies may need cleanup before policy action | Strong fit when labels are trusted; record supported scope, gaps, and the customer owner for any report-only change review |
| **Existing enterprise DLP or classification process** | A non-Purview or broader enterprise control already governs the data path | May not see all AI prompt, response, or retrieval activity; evidence may live outside Purview | Accept if it is customer-owned and evidence-backed; record what it covers and what S2 must backlog |
| **Manual / customer-defined classification** | Early review, incomplete taxonomy, or regulated data that needs human interpretation before automation | Slower and less scalable; cannot prove ongoing enforcement by itself | Valid as a starting decision; record owner, review cadence, and when label/DLP maturity must be revisited |

## Decision 2 — How is grounding, retrieval, and PII exposure governed?

The deciding test is where sensitive data enters — prompts, retrieval results,
tool outputs, or responses — where the sources live, and which least-privilege
boundary limits what the agent can reach. Verify current status for each named
Microsoft or Azure capability before selection.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Gateway PII masking** (AI Hub Gateway / Citadel pattern) | Sensitive data can be reduced at the runtime boundary before model calls | Gateway masking is a separate platform control and does not replace source classification, permissions, or audit | Record gateway owner, masked fields, evidence route, and S3/S6 dependency |
| **Upstream data minimization at the source** | Retrieval sources can be narrowed, redacted, partitioned, or permissioned before an agent sees them | Requires source-system owners and may take longer than a gateway rule | Best when least privilege is the control; record source owner, access boundary, and residual sensitive fields |
| **Microsoft Purview data map / DSPM for AI review** | The customer needs exposure findings, oversharing signals, or data-estate context before deciding | Diagnostic, not an enforcement guarantee; workload support and results must be interpreted | Record findings or documented no-results, gaps, and the owner for remediation or accepted risk |
| **Azure AI Content Safety** | The concern is unsafe generated content or moderation of model inputs/outputs | It is not a PII, residency, retention, or source-permission control | Use only for the safety slice; record why data-governance risk remains covered elsewhere |

## Decision 3 — How are compliance, residency, and retention obligations mapped?

Map the path to regulatory exposure, cross-border data movement, records of
processing, and retention ownership. Confirm current region, residency, and
product availability before relying on any Microsoft or Azure capability.

| Option | When it fits | Trade-off / limitation | Governance implication |
|---|---|---|---|
| **Data residency / region pinning** | The path has cross-border or customer-policy constraints on where data is processed or stored | Region support and service behavior vary; pinning does not solve classification or retention | Record approved regions, exceptions, and owner for product-status verification |
| **GDPR and records-of-processing mapping** | Personal data may enter prompts, retrieval, logs, or outputs | Requires legal/privacy ownership; technical evidence alone is not the record | Record lawful basis, processing purpose, evidence references, and privacy owner |
| **Sector-specific regulation mapping** | Finance, health, public-sector, or other regulated data is in scope | Obligations differ by jurisdiction and policy; this kit does not provide legal approval | Record applicable rule set, control owner, and blocker or accepted-risk path |
| **Retention ownership** | Audit, eDiscovery, legal hold, or records-management obligations decide whether evidence is usable | Retention gaps can make later investigation impossible even when controls exist | Record retention owner, review date, and S5/S6/S12 dependency |

## Decisions made & adoption progress

S2 should move the data part of the **S0 maturity baseline** forward and produce
an S12-ready record of the data situation, evidence, and review actions.

| Adoption stage | What "done" looks like at S2 |
|---|---|
| **Decided** | Data-classification, PII/retrieval handling, and compliance/residency options are selected for the bounded path with evidence references and owners |
| **Backlogged** | Classification gaps, source-permission work, report-only DLP review, residency checks, retention gaps, or gateway dependencies are routed with owners |
| **In adoption** | Customer data, compliance, platform, or change teams implement outside this session; S3/S5/S6 reconcile the evidence and residual gaps |

Capture the chosen option, alternatives, rationale, owner, and adoption stage in
the technical decision record (`labs/s2-data-compliance/templates/technical-decision-record.template.md`).
The decision, evidence references, and review actions are what S2 leaves behind.

## Related references

- [S2 Concepts](concepts.md) — Purview review, labels and DLP, investigation evidence, and gateway masking boundaries.
- [Governance capability guide](../reference/governance-capability-guide.md) — capability and tenant-readiness context to verify before delivery.
- [Platform technical guide](../reference/platform-technical-guide.md) — Citadel/gateway and platform-governance boundary context.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md) — Purview, DSPM, DLP, sensitivity, audit, eDiscovery, residency, and compliance sources.
