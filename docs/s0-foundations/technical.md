# S0 · Foundations & Governance Operating Model: Technical decisions

!!! info "Freshness"
    Last reviewed: 2026-07-24 · Start from Microsoft Cloud Adoption Framework for AI, Well-Architected Framework for AI, and AI Center of Excellence guidance. Verify current Microsoft guidance, tenant tooling, region, and license status before delivery.

## Microsoft default

Default to a customer AI governance forum anchored in Microsoft Cloud Adoption Framework for AI, Well-Architected Framework for AI, and AI Center of Excellence guidance. S0 records the operating model, baseline framework, and system of record that every later session uses.

## Decision tree

1. **If a customer governance forum already owns AI risk**, use it and add agent-specific decision rights.
2. **If ownership is split across business, security, data, and platform teams**, use a federated hub-and-spoke model with escalation to the central forum.
3. **If only product teams own decisions today**, keep embedded ownership but require the shared S0 baseline and exception route.
4. **If no owner can approve, defer, reject, or route**, block the roadmap item until a sponsor names the forum and record location.

| Decision | Microsoft default | Choose an exception only when |
|---|---|---|
| Operating model | CAF/AI Center of Excellence-aligned forum plus domain owners | A regulated internal forum is already authoritative and can carry S0-S13 fields |
| Baseline framework | CAF for AI + Well-Architected AI, mapped to NIST AI RMF or ISO/IEC 42001 as needed | Legal/compliance requires a different primary framework |
| Record location | Customer governance/control register with links to Purview, Foundry, API Center, or Azure work items | No approved register exists; use a temporary owned document with a migration trigger |

## Platform checks

Inspect these customer-owned records; store only safe references in this repo.

| Check | Microsoft product/control record |
|---|---|
| Governance owner and cadence | AI Center of Excellence charter, architecture review board, risk committee, or customer GRC record |
| Baseline maturity | CAF for AI assessment, Well-Architected AI review notes, NIST/ISO mapping, S0 roadmap |
| Decision register | Customer GRC/work-management record, Purview/Foundry/API Center links, retention owner |
| Exception handling | Exception record with reason, equivalent control, owner, evidence location, target date, and review trigger |

## Acceptance tests

| Work item | Accepted when... | Handoff |
|---|---|---|
| Operating model | one forum can approve, defer, reject, or route each AI-agent decision and has named domain owners | Governance sponsor |
| Baseline framework | the chosen Microsoft baseline and any regulatory overlay are mapped to S1-S13 ownership gaps | Governance/risk owner |
| Evidence record | decisions include alternatives, rationale, owner, evidence location, target date, and review trigger | Records/GRC owner |
| Roadmap | each S0 gap is assigned to a later session or customer process | S13 portfolio owner |

## Boundary note

S0 creates a governance baseline and backlog only; customer change, production approval, and sensitive evidence stay in customer systems.

## Related references

- [S0 Concepts](concepts.md): operating model, maturity baseline, risk routing, and customer-owned evidence.
- [Governance capability guide](../reference/governance-capability-guide.md): capability and availability context.
- [Microsoft platform governance playbook](../reference/microsoft-platform-governance-playbook.md): required playbook shape.
- [Microsoft AI governance reference map](../reference/ai-governance-reference-map.md): official reference sources.
